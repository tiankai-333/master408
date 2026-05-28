package com.mindskip.xzs.service.impl;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.mindskip.xzs.ai.AnalysisService;
import com.mindskip.xzs.ai.RagService;
import com.mindskip.xzs.domain.User;
import com.mindskip.xzs.service.AiAgentPlannerService;
import com.mindskip.xzs.service.AiIntentRouter;
import com.mindskip.xzs.service.AiOrchestratorService;
import com.mindskip.xzs.service.AiPaperComposeService;
import com.mindskip.xzs.viewmodel.student.ai.*;
import org.springframework.stereotype.Service;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class AiOrchestratorServiceImpl implements AiOrchestratorService {

    private final AnalysisService analysisService;
    private final RagService ragService;
    private final AiAgentPlannerService aiAgentPlannerService;
    private final AiPaperComposeService aiPaperComposeService;
    private final AiIntentRouter aiIntentRouter;
    private final ObjectMapper objectMapper;

    public AiOrchestratorServiceImpl(AnalysisService analysisService,
                                     RagService ragService,
                                     AiAgentPlannerService aiAgentPlannerService,
                                     AiPaperComposeService aiPaperComposeService,
                                     AiIntentRouter aiIntentRouter) {
        this.analysisService = analysisService;
        this.ragService = ragService;
        this.aiAgentPlannerService = aiAgentPlannerService;
        this.aiPaperComposeService = aiPaperComposeService;
        this.aiIntentRouter = aiIntentRouter;
        this.objectMapper = new ObjectMapper();
    }

    @Override
    public void handleStream(AiWorkbenchRequestVM request, User user, WorkbenchEventConsumer consumer) throws Exception {
        if (request == null) {
            request = new AiWorkbenchRequestVM();
        }
        String intent = aiIntentRouter.resolve(request);
        String style = normalize(request.getStyle(), "default");
        String userMessage = normalize(request.getUserMessage(), defaultUserMessage(intent));

        if (AiIntentRouter.PRACTICE_PLAN.equals(intent)) {
            emitAgentDraft(request, userMessage, user, consumer);
            return;
        }
        if (AiIntentRouter.COMPOSE_PAPER.equals(intent)) {
            emitComposedPaper(request, userMessage, user, consumer);
            return;
        }

        String contextText = buildContextText(request.getContext(), intent);
        String question = buildStudentRequest(intent, userMessage, request.getContext());
        String retrievalQuery = buildRetrievalQuery(question, contextText);
        String referenceDocs = null;
        List<RagService.RagDocument> ragDocs = null;
        try {
            consumer.send("status", "正在检索知识库资料...");
            ragDocs = ragService.retrieve(retrievalQuery, 5);
            if (ragDocs != null && !ragDocs.isEmpty()) {
                referenceDocs = ragService.formatReferenceDocs(ragDocs);
                consumer.send("references", objectMapper.writeValueAsString(toReferenceList(ragDocs)));
            }
        } catch (Exception e) {
            consumer.send("status", "知识库检索暂不可用，正在直接回答...");
        }

        consumer.send("status", statusFor(intent));
        analysisService.analyzeWithAIStream(style, question, contextText, referenceDocs, intent,
                token -> consumer.send("chunk", token));
    }

    private void emitAgentDraft(AiWorkbenchRequestVM request, String userMessage, User user, WorkbenchEventConsumer consumer) throws Exception {
        AiWorkbenchContextVM context = request.getContext();
        AiAgentPlanRequestVM planRequest = new AiAgentPlanRequestVM();
        planRequest.setMessage(userMessage);
        planRequest.setMode("compose_paper");
        planRequest.setQuestionCount(3);
        planRequest.setMinutes(10);
        planRequest.setPreferMistakes(true);
        planRequest.setSubjectId(context == null ? null : context.getSubjectId());
        planRequest.setContextKnowledgePoint(resolveKnowledgePointName(context));

        AiAgentPlanResponseVM draft = aiAgentPlannerService.plan(planRequest, user);
        consumer.send("agentDraft", objectMapper.writeValueAsString(draft));
    }

    private void emitComposedPaper(AiWorkbenchRequestVM request, String userMessage, User user, WorkbenchEventConsumer consumer) throws Exception {
        AiWorkbenchContextVM context = request.getContext();
        AiPaperComposeRequestVM composeRequest = new AiPaperComposeRequestVM();
        composeRequest.setInstruction(userMessage);
        composeRequest.setSubjectId(context == null ? null : context.getSubjectId());
        composeRequest.setKnowledgePoint(resolveKnowledgePointName(context));
        composeRequest.setPreferMistakes(true);
        composeRequest.setQuestionCount(3);
        composeRequest.setMinutes(10);
        String knowledgeName = resolveKnowledgePointName(context);
        composeRequest.setName(knowledgeName == null ? "AI限时练习" : "AI限时练习-" + knowledgeName);
        AiPaperComposeResponseVM paper = aiPaperComposeService.compose(composeRequest, user);
        consumer.send("paper", objectMapper.writeValueAsString(paper));
    }

    private String buildStudentRequest(String intent, String userMessage, AiWorkbenchContextVM context) {
        StringBuilder builder = new StringBuilder();
        if (AiIntentRouter.LEARNING_PROFILE.equals(intent)) {
            builder.append("请根据我的学习状态、当前上下文和做题记录，生成 408 学习画像。");
        } else if (AiIntentRouter.EXPLAIN_KNOWLEDGE.equals(intent)) {
            builder.append("请围绕当前知识点进行讲解。");
        } else if (AiIntentRouter.EXPLAIN_QUESTION.equals(intent)) {
            builder.append("请围绕当前题目进行讲解。");
        } else {
            builder.append("请围绕当前上下文回答学生问题。");
        }
        builder.append("\n\n## 用户请求\n").append(userMessage);
        String pastedText = context == null ? null : normalize(context.getPastedText(), null);
        if (pastedText != null && context.getQuestion() == null) {
            builder.append("\n\n## 粘贴题目\n").append(pastedText);
        }
        return builder.toString();
    }

    private String buildContextText(AiWorkbenchContextVM context, String intent) {
        StringBuilder builder = new StringBuilder();
        if (context == null) {
            return "";
        }
        appendLine(builder, "上下文类型", context.getContextType());
        appendLine(builder, "科目", context.getSubjectName());

        AiWorkbenchKnowledgePointVM knowledgePoint = context.getKnowledgePoint();
        if (knowledgePoint != null) {
            builder.append("\n## 当前知识点\n");
            appendLine(builder, "名称", knowledgePoint.getName());
            appendLine(builder, "摘要", firstNonEmpty(knowledgePoint.getSummary(), knowledgePoint.getDescription()));
            appendLine(builder, "HTML 引用", knowledgePoint.getHtmlRef());
        }

        AiWorkbenchQuestionVM question = context.getQuestion();
        if (question != null) {
            builder.append("\n## 当前题目\n");
            appendLine(builder, "来源", question.getSource());
            appendLine(builder, "题干", firstNonEmpty(question.getBody(), question.getTitle()));
            if (question.getOptions() != null && !question.getOptions().isEmpty()) {
                builder.append("选项：\n");
                for (Map<String, Object> option : question.getOptions()) {
                    builder.append("- ").append(optionText(option)).append("\n");
                }
            }
            appendLine(builder, "数据库正确答案", question.getCorrectAnswer());
            appendLine(builder, "数据库解析", question.getAnalysis());
        }

        AiWorkbenchAnswerRecordVM answerRecord = context.getAnswerRecord();
        if (answerRecord != null) {
            builder.append("\n## 我的作答记录\n");
            appendLine(builder, "我的答案", answerRecord.getUserAnswer());
            if (answerRecord.getCorrect() != null) {
                appendLine(builder, "是否正确", answerRecord.getCorrect() ? "正确" : "错误");
            }
            appendLine(builder, "做题时间", answerRecord.getDoTime());
        }

        if (AiIntentRouter.LEARNING_PROFILE.equals(intent) && context.getUserStats() != null) {
            builder.append("\n## 学习统计\n").append(formatMap(context.getUserStats())).append("\n");
        }

        String pastedText = normalize(context.getPastedText(), null);
        if (pastedText != null && question == null) {
            builder.append("\n## 粘贴内容\n").append(pastedText).append("\n");
        }

        return builder.toString().trim();
    }

    private String buildRetrievalQuery(String question, String contextText) {
        String merged = (question == null ? "" : question) + "\n" + (contextText == null ? "" : contextText);
        return merged.length() > 3000 ? merged.substring(0, 3000) : merged;
    }

    private List<Map<String, Object>> toReferenceList(List<RagService.RagDocument> docs) {
        return docs.stream().map(doc -> {
            Map<String, Object> ref = new LinkedHashMap<>();
            ref.put("title", doc.getTitle());
            ref.put("similarity", String.format("%.2f", doc.getSimilarity()));
            ref.put("id", doc.getId());
            return ref;
        }).collect(Collectors.toList());
    }

    private String statusFor(String intent) {
        if (AiIntentRouter.LEARNING_PROFILE.equals(intent)) {
            return "AI 正在生成学习画像...";
        }
        if (AiIntentRouter.EXPLAIN_KNOWLEDGE.equals(intent)) {
            return "AI 正在讲解知识点...";
        }
        if (AiIntentRouter.EXPLAIN_QUESTION.equals(intent)) {
            return "AI 正在解析题目...";
        }
        return "AI 正在生成回答...";
    }

    private String defaultUserMessage(String intent) {
        if (AiIntentRouter.LEARNING_PROFILE.equals(intent)) {
            return "生成学习画像";
        }
        if (AiIntentRouter.PRACTICE_PLAN.equals(intent)) {
            return "生成针对练习草案";
        }
        return "请围绕当前上下文进行讲解";
    }

    private String resolveKnowledgePointName(AiWorkbenchContextVM context) {
        if (context == null || context.getKnowledgePoint() == null) {
            return null;
        }
        return normalize(context.getKnowledgePoint().getName(), null);
    }

    private String optionText(Map<String, Object> option) {
        if (option == null) {
            return "";
        }
        Object key = firstPresent(option, "key", "prefix", "label");
        Object text = firstPresent(option, "text", "content", "value");
        String prefix = key == null ? "" : String.valueOf(key).trim();
        String body = text == null ? "" : String.valueOf(text).trim();
        return prefix.isEmpty() ? body : prefix + ". " + body;
    }

    private Object firstPresent(Map<String, Object> map, String... keys) {
        for (String key : keys) {
            Object value = map.get(key);
            if (value != null && !String.valueOf(value).trim().isEmpty()) {
                return value;
            }
        }
        return null;
    }

    private String formatMap(Map<String, Object> map) {
        StringBuilder builder = new StringBuilder();
        for (Map.Entry<String, Object> entry : map.entrySet()) {
            builder.append("- ").append(entry.getKey()).append("：").append(entry.getValue()).append("\n");
        }
        return builder.toString();
    }

    private void appendLine(StringBuilder builder, String label, String value) {
        String normalized = normalize(value, null);
        if (normalized != null) {
            builder.append(label).append("：").append(normalized).append("\n");
        }
    }

    private String firstNonEmpty(String first, String second) {
        return normalize(first, normalize(second, null));
    }

    private String normalize(String value, String fallback) {
        return value == null || value.trim().isEmpty() ? fallback : value.trim();
    }
}
