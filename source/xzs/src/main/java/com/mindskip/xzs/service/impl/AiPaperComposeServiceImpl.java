package com.mindskip.xzs.service.impl;

import com.mindskip.xzs.domain.ExamPaper;
import com.mindskip.xzs.domain.Question;
import com.mindskip.xzs.domain.TaskExam;
import com.mindskip.xzs.domain.TextContent;
import com.mindskip.xzs.domain.User;
import com.mindskip.xzs.domain.enums.ExamPaperTypeEnum;
import com.mindskip.xzs.domain.task.TaskItemObject;
import com.mindskip.xzs.repository.ExamPaperMapper;
import com.mindskip.xzs.repository.QuestionMapper;
import com.mindskip.xzs.repository.TaskExamMapper;
import com.mindskip.xzs.service.AiPaperComposeService;
import com.mindskip.xzs.service.ExamPaperService;
import com.mindskip.xzs.service.TextContentService;
import com.mindskip.xzs.utility.DateTimeUtil;
import com.mindskip.xzs.utility.ExamUtil;
import com.mindskip.xzs.utility.JsonUtil;
import com.mindskip.xzs.viewmodel.admin.exam.ExamPaperEditRequestVM;
import com.mindskip.xzs.viewmodel.admin.exam.ExamPaperTitleItemVM;
import com.mindskip.xzs.viewmodel.admin.question.QuestionEditRequestVM;
import com.mindskip.xzs.viewmodel.student.ai.AiPaperComposeRequestVM;
import com.mindskip.xzs.viewmodel.student.ai.AiPaperComposeResponseVM;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class AiPaperComposeServiceImpl implements AiPaperComposeService {

    private static final int DEFAULT_SUBJECT_ID = 1;
    private static final int DEFAULT_MINUTES = 15;
    private static final int DEFAULT_QUESTION_COUNT = 5;
    private static final int MAX_QUESTION_COUNT = 5;
    private static final List<Integer> CORE_408_SUBJECT_IDS = Arrays.asList(1, 2, 3, 4);

    private final QuestionMapper questionMapper;
    private final ExamPaperService examPaperService;
    private final TextContentService textContentService;
    private final TaskExamMapper taskExamMapper;
    private final ExamPaperMapper examPaperMapper;

    public AiPaperComposeServiceImpl(QuestionMapper questionMapper, ExamPaperService examPaperService,
                                     TextContentService textContentService, TaskExamMapper taskExamMapper,
                                     ExamPaperMapper examPaperMapper) {
        this.questionMapper = questionMapper;
        this.examPaperService = examPaperService;
        this.textContentService = textContentService;
        this.taskExamMapper = taskExamMapper;
        this.examPaperMapper = examPaperMapper;
    }

    @Override
    @Transactional
    public AiPaperComposeResponseVM compose(AiPaperComposeRequestVM request, User user) {
        if (request == null) {
            request = new AiPaperComposeRequestVM();
        }
        Integer userId = user == null ? null : user.getId();
        Integer subjectId = request.getSubjectId();
        int count = normalizeQuestionCount(request.getQuestionCount());
        int minutes = request.getMinutes() == null || request.getMinutes() <= 0 ? DEFAULT_MINUTES : request.getMinutes();

        List<Question> selected = new ArrayList<>();
        if (request.getQuestionIds() != null && !request.getQuestionIds().isEmpty()) {
            selected.addAll(questionMapper.selectByIds(request.getQuestionIds()));
            selected = selected.stream().limit(count).collect(Collectors.toList());
        }

        List<Integer> subjectIds = (subjectId != null) ? Collections.singletonList(subjectId) : CORE_408_SUBJECT_IDS;

        for (Integer sid : subjectIds) {
            if (selected.size() >= count) break;
            int remain = count - selected.size();

            if (Boolean.TRUE.equals(request.getPreferMistakes()) && userId != null) {
                selected.addAll(questionMapper.selectMistakesForAiPaper(
                        userId,
                        sid,
                        normalize(request.getKnowledgePoint()),
                        request.getSourceYear(),
                        request.getQuestionTypes(),
                        mergeExcludeIds(request.getExcludeQuestionIds(), selected),
                        request.getExcludeSourceYears(),
                        remain
                ));
            }

            if (selected.size() < count) {
                remain = count - selected.size();
                selected.addAll(questionMapper.selectForAiPaper(
                        sid,
                        normalize(request.getKnowledgePoint()),
                        request.getSourceYear(),
                        request.getQuestionTypes(),
                        mergeExcludeIds(request.getExcludeQuestionIds(), selected),
                        request.getExcludeSourceYears(),
                        remain
                ));
            }
        }

        selected = distinctById(selected);
        if (selected.isEmpty()) {
            throw new IllegalArgumentException("没有找到符合条件的题目，请放宽知识点、年份或题型限制。");
        }

        Integer paperSubjectId = subjectId == null ? subjectIdFromQuestions(selected) : subjectId;
        ExamPaperEditRequestVM paperVM = buildPaperVM(request, paperSubjectId, minutes, selected);
        ExamPaper paper = examPaperService.savePaperFromVM(paperVM, user);

        createPersonalTask(paper, user);

        AiPaperComposeResponseVM response = new AiPaperComposeResponseVM();
        response.setPaperId(paper.getId());
        response.setPaperName(paper.getName());
        response.setUrl("/do?id=" + paper.getId());
        response.setQuestionCount(selected.size());
        response.setMinutes(minutes);
        response.setQuestionIds(selected.stream().map(Question::getId).collect(Collectors.toList()));
        response.setStrategy(buildStrategy(request, selected));
        return response;
    }

    private ExamPaperEditRequestVM buildPaperVM(AiPaperComposeRequestVM request, Integer subjectId, int minutes, List<Question> questions) {
        ExamPaperEditRequestVM paperVM = new ExamPaperEditRequestVM();
        paperVM.setSubjectId(subjectId);
        paperVM.setLevel(1);
        paperVM.setPaperType(ExamPaperTypeEnum.TimeLimit.getCode());
        paperVM.setName(resolvePaperName(request));
        paperVM.setSuggestTime(minutes);

        Date start = new Date();
        LocalDateTime endOfDay = LocalDate.now().atTime(23, 59, 59);
        Date end = Date.from(endOfDay.atZone(ZoneId.systemDefault()).toInstant());
        paperVM.setLimitDateTime(Arrays.asList(DateTimeUtil.dateFormat(start), DateTimeUtil.dateFormat(end)));

        ExamPaperTitleItemVM titleItem = new ExamPaperTitleItemVM();
        titleItem.setName(paperVM.getName());
        List<QuestionEditRequestVM> questionItems = questions.stream().map(q -> {
            QuestionEditRequestVM item = new QuestionEditRequestVM();
            item.setId(q.getId());
            item.setQuestionType(q.getQuestionType());
            item.setSubjectId(q.getSubjectId());
            item.setScore(ExamUtil.scoreToVM(q.getScore()));
            return item;
        }).collect(Collectors.toList());
        titleItem.setQuestionItems(questionItems);
        paperVM.setTitleItems(Arrays.asList(titleItem));
        return paperVM;
    }

    private String defaultPaperName(AiPaperComposeRequestVM request) {
        String knowledgePoint = normalize(request.getKnowledgePoint());
        String timeText = new SimpleDateFormat("MM-dd HH:mm").format(new Date());
        if (knowledgePoint != null) {
            return "AI限时练习-" + knowledgePoint + "-" + timeText;
        }
        return "AI限时练习-" + timeText;
    }

    private String resolvePaperName(AiPaperComposeRequestVM request) {
        String name = normalize(request.getName());
        if (name == null || "AI限时练习".equals(name)) {
            return defaultPaperName(request);
        }
        return name;
    }

    private String buildStrategy(AiPaperComposeRequestVM request, List<Question> selected) {
        List<String> parts = new ArrayList<>();
        if (Boolean.TRUE.equals(request.getPreferMistakes())) {
            parts.add("优先错题");
        }
        if (normalize(request.getKnowledgePoint()) != null) {
            parts.add("知识点：" + request.getKnowledgePoint().trim());
        }
        if (request.getSourceYear() != null) {
            parts.add("来源年份：" + request.getSourceYear());
        }
        if (request.getExcludeSourceYears() != null && !request.getExcludeSourceYears().isEmpty()) {
            parts.add("排除年份：" + request.getExcludeSourceYears());
        }
        parts.add("实际选题：" + selected.size() + " 道");
        return String.join("；", parts);
    }

    private int normalizeQuestionCount(Integer questionCount) {
        if (questionCount == null || questionCount <= 0) {
            return DEFAULT_QUESTION_COUNT;
        }
        return Math.min(questionCount, MAX_QUESTION_COUNT);
    }

    private String normalize(String value) {
        return value == null || value.trim().isEmpty() ? null : value.trim();
    }

    private Integer subjectIdFromQuestions(List<Question> selected) {
        if (selected != null) {
            for (Question question : selected) {
                if (question != null && question.getSubjectId() != null) {
                    return question.getSubjectId();
                }
            }
        }
        return DEFAULT_SUBJECT_ID;
    }

    private List<Integer> mergeExcludeIds(List<Integer> requestExcludeIds, List<Question> selected) {
        List<Integer> ids = new ArrayList<>();
        if (requestExcludeIds != null) {
            ids.addAll(requestExcludeIds);
        }
        ids.addAll(selected.stream().map(Question::getId).collect(Collectors.toList()));
        return ids;
    }

    private List<Question> distinctById(List<Question> questions) {
        Map<Integer, Question> map = new LinkedHashMap<>();
        for (Question question : questions) {
            if (question != null && question.getId() != null) {
                map.put(question.getId(), question);
            }
        }
        return new ArrayList<>(map.values());
    }

    private void createPersonalTask(ExamPaper paper, User user) {
        Date now = new Date();
        TaskItemObject itemObject = new TaskItemObject();
        itemObject.setExamPaperId(paper.getId());
        itemObject.setExamPaperName(paper.getName());
        itemObject.setItemOrder(1);

        TextContent textContent = new TextContent();
        textContent.setContent(JsonUtil.toJsonStr(Collections.singletonList(itemObject)));
        textContent.setCreateTime(now);
        textContentService.insertByFilter(textContent);

        TaskExam taskExam = new TaskExam();
        taskExam.setTitle(paper.getName());
        taskExam.setFrameTextContentId(textContent.getId());
        taskExam.setCreateUser(user == null ? null : user.getId());
        taskExam.setCreateUserName(user == null ? null : user.getUserName());
        taskExam.setCreateTime(now);
        taskExam.setDeleted(false);
        taskExamMapper.insertSelective(taskExam);
        examPaperMapper.updateTaskPaper(taskExam.getId(), Collections.singletonList(paper.getId()));
    }
}
