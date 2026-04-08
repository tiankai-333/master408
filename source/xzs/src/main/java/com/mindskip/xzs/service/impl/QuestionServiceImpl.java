package com.mindskip.xzs.service.impl;

import com.mindskip.xzs.domain.other.KeyValue;
import com.mindskip.xzs.domain.Question;
import com.mindskip.xzs.domain.TextContent;
import com.mindskip.xzs.domain.enums.QuestionStatusEnum;
import com.mindskip.xzs.domain.enums.QuestionTypeEnum;
import com.mindskip.xzs.domain.question.QuestionItemObject;
import com.mindskip.xzs.domain.question.QuestionObject;
import com.mindskip.xzs.repository.QuestionMapper;
import com.mindskip.xzs.service.QuestionService;
import com.mindskip.xzs.service.SubjectService;
import com.mindskip.xzs.service.TextContentService;
import com.mindskip.xzs.utility.DateTimeUtil;
import com.mindskip.xzs.utility.JsonUtil;
import com.mindskip.xzs.utility.ModelMapperSingle;
import com.mindskip.xzs.utility.ExamUtil;
import com.mindskip.xzs.viewmodel.admin.question.QuestionEditItemVM;
import com.mindskip.xzs.viewmodel.admin.question.QuestionEditRequestVM;
import com.mindskip.xzs.viewmodel.admin.question.QuestionPageRequestVM;
import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import org.modelmapper.ModelMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.Date;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class QuestionServiceImpl extends BaseServiceImpl<Question> implements QuestionService {

    protected final static ModelMapper modelMapper = ModelMapperSingle.Instance();
    private final QuestionMapper questionMapper;
    private final TextContentService textContentService;
    private final SubjectService subjectService;

    @Value("${ai.api.key}")
    private String aiApiKey;

    @Value("${ai.api.url}")
    private String aiApiUrl;

    @Value("${ai.api.type}")
    private String aiApiType;

    @Autowired
    public QuestionServiceImpl(QuestionMapper questionMapper, TextContentService textContentService, SubjectService subjectService) {
        super(questionMapper);
        this.textContentService = textContentService;
        this.questionMapper = questionMapper;
        this.subjectService = subjectService;
    }

    @Override
    public PageInfo<Question> page(QuestionPageRequestVM requestVM) {
        return PageHelper.startPage(requestVM.getPageIndex(), requestVM.getPageSize(), "id desc").doSelectPageInfo(() ->
                questionMapper.page(requestVM)
        );
    }


    @Override
    @Transactional
    public Question insertFullQuestion(QuestionEditRequestVM model, Integer userId) {
        Date now = new Date();
        Integer gradeLevel = subjectService.levelBySubjectId(model.getSubjectId());

        //题干、解析、选项等 插入
        TextContent infoTextContent = new TextContent();
        infoTextContent.setCreateTime(now);
        setQuestionInfoFromVM(infoTextContent, model);
        textContentService.insertByFilter(infoTextContent);

        Question question = new Question();
        question.setSubjectId(model.getSubjectId());
        question.setGradeLevel(gradeLevel);
        question.setCreateTime(now);
        question.setQuestionType(model.getQuestionType());
        question.setStatus(QuestionStatusEnum.OK.getCode());
        question.setCorrectFromVM(model.getCorrect(), model.getCorrectArray());
        question.setScore(ExamUtil.scoreFromVM(model.getScore()));
        question.setDifficult(model.getDifficult());
        question.setInfoTextContentId(infoTextContent.getId());
        question.setCreateUser(userId);
        question.setDeleted(false);
        questionMapper.insertSelective(question);
        return question;
    }

    @Override
    @Transactional
    public Question updateFullQuestion(QuestionEditRequestVM model) {
        Integer gradeLevel = subjectService.levelBySubjectId(model.getSubjectId());
        Question question = questionMapper.selectByPrimaryKey(model.getId());
        question.setSubjectId(model.getSubjectId());
        question.setGradeLevel(gradeLevel);
        question.setScore(ExamUtil.scoreFromVM(model.getScore()));
        question.setDifficult(model.getDifficult());
        question.setCorrectFromVM(model.getCorrect(), model.getCorrectArray());
        questionMapper.updateByPrimaryKeySelective(question);

        //题干、解析、选项等 更新
        TextContent infoTextContent = textContentService.selectById(question.getInfoTextContentId());
        setQuestionInfoFromVM(infoTextContent, model);
        textContentService.updateByIdFilter(infoTextContent);

        return question;
    }

    @Override
    public QuestionEditRequestVM getQuestionEditRequestVM(Integer questionId) {
        //题目映射
        Question question = questionMapper.selectByPrimaryKey(questionId);
        return getQuestionEditRequestVM(question);
    }

    @Override
    public QuestionEditRequestVM getQuestionEditRequestVM(Question question) {
        //题目映射
        TextContent questionInfoTextContent = textContentService.selectById(question.getInfoTextContentId());
        QuestionObject questionObject = JsonUtil.toJsonObject(questionInfoTextContent.getContent(), QuestionObject.class);
        QuestionEditRequestVM questionEditRequestVM = modelMapper.map(question, QuestionEditRequestVM.class);
        questionEditRequestVM.setTitle(questionObject.getTitleContent());

        //答案
        QuestionTypeEnum questionTypeEnum = QuestionTypeEnum.fromCode(question.getQuestionType());
        switch (questionTypeEnum) {
            case SingleChoice:
            case TrueFalse:
                questionEditRequestVM.setCorrect(question.getCorrect());
                break;
            case MultipleChoice:
                questionEditRequestVM.setCorrectArray(ExamUtil.contentToArray(question.getCorrect()));
                break;
            case GapFilling:
                List<String> correctContent = questionObject.getQuestionItemObjects().stream().map(d -> d.getContent()).collect(Collectors.toList());
                questionEditRequestVM.setCorrectArray(correctContent);
                break;
            case ShortAnswer:
                questionEditRequestVM.setCorrect(questionObject.getCorrect());
                break;
            default:
                break;
        }
        questionEditRequestVM.setScore(ExamUtil.scoreToVM(question.getScore()));
        questionEditRequestVM.setAnalyze(questionObject.getAnalyze());


        //题目项映射
        List<QuestionEditItemVM> editItems = questionObject.getQuestionItemObjects().stream().map(o -> {
            QuestionEditItemVM questionEditItemVM = modelMapper.map(o, QuestionEditItemVM.class);
            if (o.getScore() != null) {
                questionEditItemVM.setScore(ExamUtil.scoreToVM(o.getScore()));
            }
            return questionEditItemVM;
        }).collect(Collectors.toList());
        questionEditRequestVM.setItems(editItems);
        return questionEditRequestVM;
    }

    public void setQuestionInfoFromVM(TextContent infoTextContent, QuestionEditRequestVM model) {
        List<QuestionItemObject> itemObjects = model.getItems().stream().map(i ->
                {
                    QuestionItemObject item = new QuestionItemObject();
                    item.setPrefix(i.getPrefix());
                    item.setContent(i.getContent());
                    item.setItemUuid(i.getItemUuid());
                    item.setScore(ExamUtil.scoreFromVM(i.getScore()));
                    return item;
                }
        ).collect(Collectors.toList());
        QuestionObject questionObject = new QuestionObject();
        questionObject.setQuestionItemObjects(itemObjects);
        questionObject.setAnalyze(model.getAnalyze());
        questionObject.setTitleContent(model.getTitle());
        questionObject.setCorrect(model.getCorrect());
        infoTextContent.setContent(JsonUtil.toJsonStr(questionObject));
    }

    @Override
    public Integer selectAllCount() {
        return questionMapper.selectAllCount();
    }

    @Override
    public List<Integer> selectMothCount() {
        Date startTime = DateTimeUtil.getMonthStartDay();
        Date endTime = DateTimeUtil.getMonthEndDay();
        List<String> mothStartToNowFormat = DateTimeUtil.MothStartToNowFormat();
        List<KeyValue> mouthCount = questionMapper.selectCountByDate(startTime, endTime);
        return mothStartToNowFormat.stream().map(md -> {
            KeyValue keyValue = mouthCount.stream().filter(kv -> kv.getName().equals(md)).findAny().orElse(null);
            return null == keyValue ? 0 : keyValue.getValue();
        }).collect(Collectors.toList());
    }

    @Override
    @Transactional
    public int uploadAndAnalyzeTxt(MultipartFile file, Integer userId) throws Exception {
        // 读取txt文件内容
        StringBuilder content = new StringBuilder();
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(file.getInputStream(), "UTF-8"))) {
            String line;
            while ((line = reader.readLine()) != null) {
                content.append(line).append("\n");
            }
        }

        // 调用AI API分析题目
        String analysisResult = callAiApi(content.toString());

        // 解析AI返回的结果并插入数据库
        return parseAndInsertQuestions(analysisResult, userId);
    }

    private String callAiApi(String content) throws Exception {
        // 构建AI API请求
        org.springframework.web.client.RestTemplate restTemplate = new org.springframework.web.client.RestTemplate();
        org.springframework.http.HttpHeaders headers = new org.springframework.http.HttpHeaders();
        headers.set("Content-Type", "application/json");

        java.util.Map<String, Object> requestBody = new java.util.HashMap<>();

        if ("glm".equals(aiApiType)) {
            // GLM API调用
            headers.set("Authorization", "Bearer " + aiApiKey);
            requestBody.put("model", "chatglm3-6b");
            requestBody.put("messages", java.util.Arrays.asList(
                new java.util.HashMap<String, String>() {{ put("role", "system"); put("content", "你是一个题目分析助手，需要将txt文件中的题目分解为符合数据库格式的结构。每个题目需要包含：题目类型、学科ID、分数、年级、难度、正确答案、题目内容（包括题干、选项、解析等）。请以JSON格式返回分析结果，每个题目为一个JSON对象，包含所有必要字段。" );
                }},
                new java.util.HashMap<String, String>() {{ put("role", "user"); put("content", content); }}
            ));
            requestBody.put("temperature", 0.7);
        } else {
            // OpenAI API调用
            headers.set("Authorization", "Bearer " + aiApiKey);
            requestBody.put("model", "gpt-3.5-turbo");
            requestBody.put("messages", java.util.Arrays.asList(
                new java.util.HashMap<String, String>() {{ put("role", "system"); put("content", "你是一个题目分析助手，需要将txt文件中的题目分解为符合数据库格式的结构。每个题目需要包含：题目类型、学科ID、分数、年级、难度、正确答案、题目内容（包括题干、选项、解析等）。请以JSON格式返回分析结果，每个题目为一个JSON对象，包含所有必要字段。" );
                }},
                new java.util.HashMap<String, String>() {{ put("role", "user"); put("content", content); }}
            ));
            requestBody.put("temperature", 0.7);
        }

        org.springframework.http.HttpEntity<java.util.Map<String, Object>> entity = new org.springframework.http.HttpEntity<>(requestBody, headers);
        org.springframework.http.ResponseEntity<String> response = restTemplate.postForEntity(aiApiUrl, entity, String.class);

        // 解析AI返回的结果
        com.fasterxml.jackson.databind.ObjectMapper mapper = new com.fasterxml.jackson.databind.ObjectMapper();
        com.fasterxml.jackson.databind.JsonNode rootNode = mapper.readTree(response.getBody());
        
        if ("glm".equals(aiApiType)) {
            // GLM API返回格式解析
            return rootNode.path("choices").get(0).path("message").path("content").asText();
        } else {
            // OpenAI API返回格式解析
            return rootNode.path("choices").get(0).path("message").path("content").asText();
        }
    }

    private int parseAndInsertQuestions(String analysisResult, Integer userId) throws Exception {
        // 解析AI返回的JSON结果
        com.fasterxml.jackson.databind.ObjectMapper mapper = new com.fasterxml.jackson.databind.ObjectMapper();
        java.util.List<java.util.Map<String, Object>> questions = mapper.readValue(analysisResult, java.util.List.class);

        int count = 0;
        for (java.util.Map<String, Object> questionMap : questions) {
            // 创建QuestionEditRequestVM对象
            QuestionEditRequestVM model = new QuestionEditRequestVM();
            model.setQuestionType((Integer) questionMap.get("questionType"));
            model.setSubjectId((Integer) questionMap.get("subjectId"));
            model.setScore((String) questionMap.get("score"));
            model.setDifficult((Integer) questionMap.get("difficult"));
            model.setCorrect((String) questionMap.get("correct"));
            model.setTitle((String) questionMap.get("title"));
            model.setAnalyze((String) questionMap.get("analyze"));

            // 处理选项
            java.util.List<java.util.Map<String, Object>> items = (java.util.List<java.util.Map<String, Object>>) questionMap.get("items");
            if (items != null) {
                java.util.List<QuestionEditItemVM> editItems = new java.util.ArrayList<>();
                for (java.util.Map<String, Object> item : items) {
                    QuestionEditItemVM editItem = new QuestionEditItemVM();
                    editItem.setPrefix((String) item.get("prefix"));
                    editItem.setContent((String) item.get("content"));
                    editItem.setItemUuid(java.util.UUID.randomUUID().toString());
                    if (item.containsKey("score")) {
                        editItem.setScore((String) item.get("score"));
                    }
                    editItems.add(editItem);
                }
                model.setItems(editItems);
            }

            // 插入题目
            insertFullQuestion(model, userId);
            count++;
        }

        return count;
    }


}
