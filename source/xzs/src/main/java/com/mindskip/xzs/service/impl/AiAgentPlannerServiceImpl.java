package com.mindskip.xzs.service.impl;

import com.mindskip.xzs.domain.Question;
import com.mindskip.xzs.domain.User;
import com.mindskip.xzs.domain.ai.AgentRunRecord;
import com.mindskip.xzs.repository.AgentRuntimeMapper;
import com.mindskip.xzs.repository.QuestionMapper;
import com.mindskip.xzs.service.AiAgentPlannerService;
import com.mindskip.xzs.service.AiPaperComposeService;
import com.mindskip.xzs.service.KnowledgeGraphService;
import com.mindskip.xzs.utility.JsonUtil;
import com.mindskip.xzs.viewmodel.student.ai.AiAgentConfirmRequestVM;
import com.mindskip.xzs.viewmodel.student.ai.AiAgentPlanRequestVM;
import com.mindskip.xzs.viewmodel.student.ai.AiAgentPlanResponseVM;
import com.mindskip.xzs.viewmodel.student.ai.AiPaperComposeRequestVM;
import com.mindskip.xzs.viewmodel.student.ai.AiPaperComposeResponseVM;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class AiAgentPlannerServiceImpl implements AiAgentPlannerService {

    private static final int DEFAULT_QUESTION_COUNT = 3;
    private static final int DEFAULT_MINUTES = 10;
    private static final int MAX_QUESTION_COUNT = 5;
    private static final String INTENT_COMPOSE_PAPER = "compose_paper";

    private final QuestionMapper questionMapper;
    private final KnowledgeGraphService knowledgeGraphService;
    private final AiPaperComposeService aiPaperComposeService;
    private final AgentRuntimeMapper agentRuntimeMapper;

    public AiAgentPlannerServiceImpl(QuestionMapper questionMapper,
                                     KnowledgeGraphService knowledgeGraphService,
                                     AiPaperComposeService aiPaperComposeService,
                                     AgentRuntimeMapper agentRuntimeMapper) {
        this.questionMapper = questionMapper;
        this.knowledgeGraphService = knowledgeGraphService;
        this.aiPaperComposeService = aiPaperComposeService;
        this.agentRuntimeMapper = agentRuntimeMapper;
    }

    @Override
    public AiAgentPlanResponseVM plan(AiAgentPlanRequestVM request, User user) {
        long start = System.currentTimeMillis();
        if (request == null) {
            request = new AiAgentPlanRequestVM();
        }

        int count = normalizeCount(request.getQuestionCount());
        int minutes = request.getMinutes() == null || request.getMinutes() <= 0 ? DEFAULT_MINUTES : request.getMinutes();
        boolean preferMistakes = request.getPreferMistakes() == null || request.getPreferMistakes();
        String message = normalize(request.getMessage());
        String knowledgePoint = resolveKnowledgePoint(request, message);
        Integer userId = user == null ? null : user.getId();

        List<Question> preciseCandidates = selectCandidates(request, userId, knowledgePoint, preferMistakes, count);
        List<Question> finalCandidates = new ArrayList<>(preciseCandidates);
        if (finalCandidates.size() < count) {
            List<Integer> excludeIds = ids(finalCandidates);
            finalCandidates.addAll(questionMapper.selectForAiPaper(
                    request.getSubjectId(),
                    null,
                    null,
                    request.getQuestionTypes(),
                    mergeIds(request.getExcludeQuestionIds(), excludeIds),
                    request.getExcludeSourceYears(),
                    count - finalCandidates.size()
            ));
        }
        finalCandidates = distinctById(finalCandidates);

        List<String> fallbackKnowledgePoints = findFallbackKnowledgePoints(request.getSubjectId(), knowledgePoint);
        List<Integer> candidateIds = ids(finalCandidates).stream().limit(count).collect(Collectors.toList());
        boolean preciseEnough = preciseCandidates.size() >= count;

        AiAgentPlanResponseVM response = new AiAgentPlanResponseVM();
        response.setIntent(INTENT_COMPOSE_PAPER);
        response.setStatus("draft");
        response.setKnowledgePoint(knowledgePoint);
        response.setQuestionCount(count);
        response.setMinutes(minutes);
        response.setPreferMistakes(preferMistakes);
        response.setFallbackKnowledgePoints(fallbackKnowledgePoints);
        response.setCandidateQuestionIds(candidateIds);
        response.setCandidateEnough(preciseEnough);
        response.setTitle(buildTitle(knowledgePoint));
        response.setReason(buildReason(knowledgePoint, preciseCandidates.size(), candidateIds.size(), count, preciseEnough));
        response.setConfirmText(buildConfirmText(knowledgePoint, preciseCandidates.size(), candidateIds.size(), count, preciseEnough));

        Map<String, Object> toolCall = new LinkedHashMap<>();
        toolCall.put("tools", new String[]{"search_student_mistakes", "search_questions", "get_knowledge_graph_context"});
        toolCall.put("knowledgePoint", knowledgePoint);
        toolCall.put("questionCount", count);
        toolCall.put("minutes", minutes);
        toolCall.put("preferMistakes", preferMistakes);
        toolCall.put("candidateQuestionIds", candidateIds);
        toolCall.put("fallbackKnowledgePoints", fallbackKnowledgePoints);
        String toolCallJson = JsonUtil.toJsonStr(toolCall);
        response.setToolCallJson(toolCallJson);
        response.setRunLogId(insertRunLog(user, message, JsonUtil.toJsonStr(response), toolCallJson,
                candidateIds.isEmpty() ? "candidate_empty" : "draft", null, (int) (System.currentTimeMillis() - start)));
        return response;
    }

    @Override
    public AiPaperComposeResponseVM confirm(AiAgentConfirmRequestVM request, User user) {
        if (request == null) {
            throw new IllegalArgumentException("缺少待确认的组卷草案。");
        }
        if (request.getQuestionIds() == null || request.getQuestionIds().isEmpty()) {
            throw new IllegalArgumentException("草案中没有可用题目，请先放宽条件重新生成草案。");
        }

        AiPaperComposeRequestVM composeRequest = new AiPaperComposeRequestVM();
        composeRequest.setName(request.getTitle());
        composeRequest.setSubjectId(request.getSubjectId());
        composeRequest.setKnowledgePoint(request.getKnowledgePoint());
        composeRequest.setQuestionCount(request.getQuestionCount());
        composeRequest.setMinutes(request.getMinutes());
        composeRequest.setPreferMistakes(false);
        composeRequest.setQuestionIds(request.getQuestionIds());
        AiPaperComposeResponseVM response = aiPaperComposeService.compose(composeRequest, user);

        Map<String, Object> toolCall = new LinkedHashMap<>();
        toolCall.put("tools", new String[]{"compose_paper"});
        toolCall.put("runLogId", request.getRunLogId());
        toolCall.put("questionIds", request.getQuestionIds());
        toolCall.put("paperId", response.getPaperId());
        insertRunLog(user, request.getTitle(), JsonUtil.toJsonStr(response), JsonUtil.toJsonStr(toolCall),
                "confirmed", null, null);
        return response;
    }

    private List<Question> selectCandidates(AiAgentPlanRequestVM request, Integer userId, String knowledgePoint,
                                            boolean preferMistakes, int count) {
        List<Question> selected = new ArrayList<>();
        if (preferMistakes && userId != null) {
            selected.addAll(questionMapper.selectMistakesForAiPaper(
                    userId,
                    request.getSubjectId(),
                    knowledgePoint,
                    null,
                    request.getQuestionTypes(),
                    request.getExcludeQuestionIds(),
                    request.getExcludeSourceYears(),
                    count
            ));
        }
        if (selected.size() < count) {
            selected.addAll(questionMapper.selectForAiPaper(
                    request.getSubjectId(),
                    knowledgePoint,
                    null,
                    request.getQuestionTypes(),
                    mergeIds(request.getExcludeQuestionIds(), ids(selected)),
                    request.getExcludeSourceYears(),
                    count - selected.size()
            ));
        }
        return distinctById(selected);
    }

    private String resolveKnowledgePoint(AiAgentPlanRequestVM request, String message) {
        String explicit = normalize(request.getContextKnowledgePoint());
        if (explicit != null) {
            return explicit;
        }
        if (message == null) {
            return null;
        }
        int start = message.indexOf('「');
        int end = message.indexOf('」', start + 1);
        if (start >= 0 && end > start) {
            return message.substring(start + 1, end).trim();
        }
        Map<String, Object> graph = knowledgeGraphService.getKnowledgeGraph(request.getSubjectId());
        Object nodesObj = graph.get("nodes");
        if (nodesObj instanceof List) {
            for (Object nodeObj : (List<?>) nodesObj) {
                if (nodeObj instanceof Map) {
                    Map<?, ?> node = (Map<?, ?>) nodeObj;
                    Object type = node.get("type");
                    Object name = node.get("name");
                    if ("knowledge_point".equals(type) && name != null && message.contains(String.valueOf(name))) {
                        return String.valueOf(name);
                    }
                }
            }
        }
        return null;
    }

    private List<String> findFallbackKnowledgePoints(Integer subjectId, String knowledgePoint) {
        List<String> result = new ArrayList<>();
        Map<String, Object> graph = knowledgeGraphService.getKnowledgeGraph(subjectId);
        Object nodesObj = graph.get("nodes");
        if (!(nodesObj instanceof List)) {
            return result;
        }
        for (Object nodeObj : (List<?>) nodesObj) {
            if (!(nodeObj instanceof Map)) {
                continue;
            }
            Map<?, ?> node = (Map<?, ?>) nodeObj;
            if (!"knowledge_point".equals(node.get("type")) || node.get("name") == null) {
                continue;
            }
            String name = String.valueOf(node.get("name"));
            if (knowledgePoint != null && knowledgePoint.equals(name)) {
                continue;
            }
            result.add(name);
            if (result.size() >= 3) {
                break;
            }
        }
        return result;
    }

    private Long insertRunLog(User user, String requestText, String responseText, String toolCallJson,
                              String status, String errorMessage, Integer latencyMs) {
        try {
            Map<String, Object> agent = agentRuntimeMapper.selectAgentByCode("cs408_tutor");
            AgentRunRecord record = new AgentRunRecord();
            if (agent != null && agent.get("id") instanceof Number) {
                record.setAgentId(((Number) agent.get("id")).intValue());
            }
            record.setUserId(user == null ? null : user.getId());
            record.setRequestText(limit(requestText, 6000));
            record.setResponseText(limit(responseText, 6000));
            record.setToolCallJson(limit(toolCallJson, 6000));
            record.setStatus(status);
            record.setErrorMessage(limit(errorMessage, 1000));
            record.setLatencyMs(latencyMs);
            agentRuntimeMapper.insertRunLog(record);
            return record.getId();
        } catch (Exception ignored) {
            return null;
        }
    }

    private String buildTitle(String knowledgePoint) {
        return normalize(knowledgePoint) == null ? "AI 408 针对练习草案" : knowledgePoint + "专项练习草案";
    }

    private String buildReason(String knowledgePoint, int preciseCount, int candidateCount, int count, boolean preciseEnough) {
        String target = normalize(knowledgePoint) == null ? "当前学习目标" : "「" + knowledgePoint + "」";
        if (candidateCount == 0) {
            return "没有找到" + target + "相关候选题，需要放宽知识点、题型或年份条件。";
        }
        if (preciseEnough) {
            return "已找到足够的" + target + "相关候选题，可直接生成限时练习。";
        }
        return "精确匹配" + target + "的候选题只有 " + preciseCount + " 道，建议用相邻或普通题库候选补足。";
    }

    private String buildConfirmText(String knowledgePoint, int preciseCount, int candidateCount, int count, boolean preciseEnough) {
        String target = normalize(knowledgePoint) == null ? "当前目标" : "「" + knowledgePoint + "」";
        if (candidateCount == 0) {
            return "暂未找到可组卷的题目，请调整知识点或减少限制。";
        }
        if (preciseEnough) {
            return "已找到 " + candidateCount + " 道" + target + "候选题，是否生成 " + Math.min(candidateCount, count) + " 题限时练习？";
        }
        return "找到" + target + "精确候选 " + preciseCount + " 道，已补充到 " + candidateCount + " 道候选，是否生成练习卷？";
    }

    private int normalizeCount(Integer count) {
        if (count == null || count <= 0) {
            return DEFAULT_QUESTION_COUNT;
        }
        return Math.min(count, MAX_QUESTION_COUNT);
    }

    private String normalize(String value) {
        return value == null || value.trim().isEmpty() ? null : value.trim();
    }

    private List<Integer> ids(List<Question> questions) {
        if (questions == null) {
            return new ArrayList<>();
        }
        return questions.stream().filter(q -> q != null && q.getId() != null)
                .map(Question::getId).collect(Collectors.toList());
    }

    private List<Integer> mergeIds(List<Integer> first, List<Integer> second) {
        List<Integer> ids = new ArrayList<>();
        if (first != null) {
            ids.addAll(first);
        }
        if (second != null) {
            ids.addAll(second);
        }
        return ids;
    }

    private List<Question> distinctById(List<Question> questions) {
        Map<Integer, Question> map = new LinkedHashMap<>();
        if (questions != null) {
            for (Question question : questions) {
                if (question != null && question.getId() != null) {
                    map.put(question.getId(), question);
                }
            }
        }
        return new ArrayList<>(map.values());
    }

    private String limit(String value, int max) {
        if (value == null || value.length() <= max) {
            return value;
        }
        return value.substring(0, max);
    }
}
