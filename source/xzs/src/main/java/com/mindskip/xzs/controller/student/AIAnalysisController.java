package com.mindskip.xzs.controller.student;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.mindskip.xzs.ai.AnalysisService;
import com.mindskip.xzs.ai.PromptTemplate;
import com.mindskip.xzs.ai.RagService;
import com.mindskip.xzs.base.BaseApiController;
import com.mindskip.xzs.base.RestResponse;
import com.mindskip.xzs.service.AiAgentPlannerService;
import com.mindskip.xzs.service.AiPaperComposeService;
import com.mindskip.xzs.viewmodel.student.ai.AiAgentConfirmRequestVM;
import com.mindskip.xzs.viewmodel.student.ai.AiAgentPlanRequestVM;
import com.mindskip.xzs.viewmodel.student.ai.AiAgentPlanResponseVM;
import com.mindskip.xzs.viewmodel.student.ai.AiPaperComposeRequestVM;
import com.mindskip.xzs.viewmodel.student.ai.AiPaperComposeResponseVM;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CompletableFuture;
import java.util.stream.Collectors;

@RestController("StudentAIAnalysisController")
@RequestMapping("/api/student/ai")
public class AIAnalysisController extends BaseApiController {

    private static final Logger logger = LoggerFactory.getLogger(AIAnalysisController.class);
    private static final ObjectMapper objectMapper = new ObjectMapper();

    private final AnalysisService analysisService;
    private final RagService ragService;
    private final AiPaperComposeService aiPaperComposeService;
    private final AiAgentPlannerService aiAgentPlannerService;

    @Autowired
    public AIAnalysisController(AnalysisService analysisService, RagService ragService,
                                AiPaperComposeService aiPaperComposeService,
                                AiAgentPlannerService aiAgentPlannerService) {
        this.analysisService = analysisService;
        this.ragService = ragService;
        this.aiPaperComposeService = aiPaperComposeService;
        this.aiAgentPlannerService = aiAgentPlannerService;
    }

    @GetMapping("/styles")
    public RestResponse<List<String>> getAvailableStyles() {
        List<String> styles = analysisService.getAvailableStyles();
        return RestResponse.ok(styles);
    }

    @GetMapping("/template/{style}")
    public RestResponse<PromptTemplate> getTemplate(@PathVariable String style) {
        PromptTemplate template = analysisService.getTemplate(style);
        return RestResponse.ok(template);
    }

    @PostMapping("/generate-prompt")
    public RestResponse<Map<String, String>> generatePrompt(@RequestBody Map<String, String> request) {
        String style = request.getOrDefault("style", "default");
        String question = request.get("question");
        String knowledgePoints = request.get("knowledgePoints");
        String taskType = request.getOrDefault("taskType", "chat");

        String prompt = analysisService.generatePrompt(style, question, knowledgePoints, null, taskType);
        PromptTemplate template = analysisService.getTemplate(style);

        Map<String, String> result = new HashMap<>();
        result.put("prompt", prompt);
        result.put("systemPrompt", template.getSystemPrompt());
        result.put("style", template.getStyle());

        return RestResponse.ok(result);
    }

    @PostMapping("/analyze")
    public RestResponse<Map<String, Object>> analyzeWithAI(@RequestBody Map<String, Object> request) {
        AnalysisService.setCurrentUserId(getCurrentUser().getId());
        RagService.setCurrentUserId(getCurrentUser().getId());
        try {
            String style = (String) request.getOrDefault("style", "default");
            String taskType = (String) request.getOrDefault("taskType", "chat");
            String question = (String) request.get("question");
            String knowledgePoints = (String) request.get("knowledgePoints");
            String conversationContext = conversationContextValue(request.get("conversationContext"));
            question = withConversationContext(question, style, conversationContext);

            logger.info("开始AI分析 - 风格: {}, 任务: {}, 内容长度: {}", 
                style, taskType, question != null ? question.length() : 0);

            if (question == null || question.trim().isEmpty()) {
                logger.warn("题目内容为空");
                return RestResponse.fail(2, "题目内容不能为空");
            }

            if (shouldComposePaper(taskType, question, request)) {
                AiPaperComposeResponseVM paper = composePaperFromRequest(request, question);
                Map<String, Object> result = new HashMap<>();
                result.put("analysis", composePaperMarkdown(paper));
                result.put("paper", paper);
                result.put("style", style);
                result.put("taskType", taskType);
                result.put("tool", "composePaper");
                return RestResponse.ok(result);
            }

            String referenceDocs = null;
            List<RagService.RagDocument> ragDocs = null;
            try {
                ragDocs = ragService.retrieve(question, 5);
                if (ragDocs != null && !ragDocs.isEmpty()) {
                    referenceDocs = ragService.formatReferenceDocs(ragDocs);
                    logger.info("RAG检索到 {} 条参考资料", ragDocs.size());
                }
            } catch (Exception e) {
                logger.warn("RAG检索失败，继续无参考分析: {}", e.getMessage());
            }

            String aiType = (String) request.getOrDefault("aiType", "");
            String apiKey = (String) request.getOrDefault("apiKey", "");
            String apiUrl = (String) request.getOrDefault("apiUrl", "");
            String model = (String) request.getOrDefault("model", "");

            String aiResult;

            if (apiKey != null && !apiKey.trim().isEmpty()) {
                logger.info("使用前端配置的AI - 类型: {}, 模型: {}", aiType, model);
                aiResult = analysisService.analyzeWithCustomAI(
                    aiType, apiKey, apiUrl, model, style, question, knowledgePoints, referenceDocs, taskType
                );
            } else {
                logger.info("使用后端配置的默认AI");
                aiResult = analysisService.analyzeWithAI(style, question, knowledgePoints, referenceDocs, taskType);
            }
            
            String prompt = analysisService.generatePrompt(style, question, knowledgePoints, referenceDocs, taskType);
            PromptTemplate template = analysisService.getTemplate(style);

            Map<String, Object> result = new HashMap<>();
            result.put("analysis", aiResult);
            result.put("prompt", prompt);
            result.put("systemPrompt", template.getSystemPrompt());
            result.put("style", style);
            result.put("taskType", taskType);
            
            if (ragDocs != null && !ragDocs.isEmpty()) {
                List<Map<String, Object>> references = ragDocs.stream().map(doc -> {
                    Map<String, Object> ref = new HashMap<>();
                    ref.put("title", doc.getTitle());
                    ref.put("similarity", String.format("%.2f", doc.getSimilarity()));
                    ref.put("id", doc.getId());
                    return ref;
                }).collect(Collectors.toList());
                result.put("references", references);
            }

            logger.info("AI分析完成 - 结果长度: {}", aiResult.length());
            
            return RestResponse.ok(result);
        } catch (Exception e) {
            logger.error("AI分析失败", e);
            return RestResponse.fail(2, "AI分析失败: " + e.getMessage());
        } finally {
            RagService.clearCurrentUserId();
            AnalysisService.clearCurrentUserId();
        }
    }

    @PostMapping("/compose-paper")
    public RestResponse<AiPaperComposeResponseVM> composePaper(@RequestBody AiPaperComposeRequestVM request) {
        try {
            return RestResponse.ok(aiPaperComposeService.compose(request, getCurrentUser()));
        } catch (Exception e) {
            logger.error("AI组卷失败", e);
            return RestResponse.fail(2, e.getMessage());
        }
    }

    @PostMapping("/agent/plan")
    public RestResponse<AiAgentPlanResponseVM> agentPlan(@RequestBody AiAgentPlanRequestVM request) {
        try {
            return RestResponse.ok(aiAgentPlannerService.plan(request, getCurrentUser()));
        } catch (Exception e) {
            logger.error("Agent草案生成失败", e);
            return RestResponse.fail(2, e.getMessage());
        }
    }

    @PostMapping("/agent/confirm")
    public RestResponse<AiPaperComposeResponseVM> agentConfirm(@RequestBody AiAgentConfirmRequestVM request) {
        try {
            return RestResponse.ok(aiAgentPlannerService.confirm(request, getCurrentUser()));
        } catch (Exception e) {
            logger.error("Agent草案确认失败", e);
            return RestResponse.fail(2, e.getMessage());
        }
    }

    @PostMapping(value = "/analyze-stream", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public SseEmitter analyzeWithAIStream(@RequestBody Map<String, Object> request) {
        SseEmitter emitter = new SseEmitter(600000L);
        final Integer userId = getCurrentUser().getId();
        CompletableFuture.runAsync(() -> {
            AnalysisService.setCurrentUserId(userId);
            RagService.setCurrentUserId(userId);
            try {
                String style = (String) request.getOrDefault("style", "default");
                String taskType = (String) request.getOrDefault("taskType", "chat");
                String question = (String) request.get("question");
                String knowledgePoints = (String) request.get("knowledgePoints");
                String conversationContext = conversationContextValue(request.get("conversationContext"));
                question = withConversationContext(question, style, conversationContext);

                if (question == null || question.trim().isEmpty()) {
                    sendEvent(emitter, "error", "题目内容不能为空");
                    emitter.complete();
                    return;
                }

                if (shouldComposePaper(taskType, question, request)) {
                    AiPaperComposeResponseVM paper = composePaperFromRequest(request, question);
                    sendEvent(emitter, "chunk", composePaperMarkdown(paper));
                    sendEvent(emitter, "done", "ok");
                    emitter.complete();
                    return;
                }

                String referenceDocs = null;
                List<RagService.RagDocument> ragDocs = null;
                try {
                    sendEvent(emitter, "status", "正在检索知识库资料...");
                    ragDocs = ragService.retrieve(question, 5);
                    if (ragDocs != null && !ragDocs.isEmpty()) {
                        referenceDocs = ragService.formatReferenceDocs(ragDocs);
                        List<Map<String, Object>> references = ragDocs.stream().map(doc -> {
                            Map<String, Object> ref = new HashMap<>();
                            ref.put("title", doc.getTitle());
                            ref.put("similarity", String.format("%.2f", doc.getSimilarity()));
                            ref.put("id", doc.getId());
                            return ref;
                        }).collect(Collectors.toList());
                        sendEvent(emitter, "references", objectMapper.writeValueAsString(references));
                    }
                } catch (Exception e) {
                    logger.warn("RAG检索失败，继续无参考分析: {}", e.getMessage());
                    sendEvent(emitter, "status", "知识库检索暂不可用，正在直接回答...");
                }

                sendEvent(emitter, "status", "AI 正在生成回答...");
                String aiType = (String) request.getOrDefault("aiType", "");
                String apiKey = (String) request.getOrDefault("apiKey", "");
                String apiUrl = (String) request.getOrDefault("apiUrl", "");
                String model = (String) request.getOrDefault("model", "");

                if (apiKey != null && !apiKey.trim().isEmpty()) {
                    analysisService.analyzeWithCustomAIStream(aiType, apiKey, apiUrl, model, style, question, knowledgePoints, referenceDocs, taskType,
                        token -> sendEvent(emitter, "chunk", token));
                } else {
                    analysisService.analyzeWithAIStream(style, question, knowledgePoints, referenceDocs, taskType,
                        token -> sendEvent(emitter, "chunk", token));
                }

                sendEvent(emitter, "done", "ok");
                emitter.complete();
            } catch (Exception e) {
                logger.error("流式AI分析失败", e);
                try {
                    sendEvent(emitter, "error", "AI分析失败：" + e.getMessage());
                } catch (Exception ignored) {
                }
                emitter.completeWithError(e);
            } finally {
                RagService.clearCurrentUserId();
                AnalysisService.clearCurrentUserId();
            }
        });
        return emitter;
    }

    private void sendEvent(SseEmitter emitter, String name, String data) throws IOException {
        emitter.send(SseEmitter.event().name(name).data(data == null ? "" : data));
    }

    private String conversationContextValue(Object value) {
        if (value instanceof Map) {
            Object previous = ((Map<?, ?>) value).get("previousAssistant");
            return previous == null ? null : String.valueOf(previous);
        }
        return value == null ? null : String.valueOf(value);
    }

    private String withConversationContext(String question, String style, String conversationContext) {
        if (!"plato".equals(style) || conversationContext == null || conversationContext.trim().isEmpty()) {
            return question;
        }
        StringBuilder builder = new StringBuilder(question == null ? "" : question);
        builder.append("\n\n【上一轮AI引导内容】\n")
            .append(limitText(conversationContext, 1800))
            .append("\n\n【本轮要求】\n")
            .append("延续上一轮已经提出的问题、学生可能卡住的位置和已有结论，不要重新从零开始。先用一句话承接上一轮，再继续用柏拉图式追问推进。\n");
        return builder.toString();
    }

    private String limitText(String value, int maxLength) {
        String text = value == null ? "" : value.trim();
        if (text.length() <= maxLength) {
            return text;
        }
        return text.substring(0, maxLength) + "\n...(已截断)";
    }

    private boolean shouldComposePaper(String taskType, String question, Map<String, Object> request) {
        if (Boolean.TRUE.equals(request.get("composePaper"))) {
            return true;
        }
        if (!"practice".equals(taskType) || question == null) {
            return false;
        }
        return question.contains("/compose paper");
    }

    private AiPaperComposeResponseVM composePaperFromRequest(Map<String, Object> request, String question) {
        AiPaperComposeRequestVM composeRequest = objectMapper.convertValue(request, AiPaperComposeRequestVM.class);
        composeRequest.setInstruction(question);
        if (composeRequest.getKnowledgePoint() == null || composeRequest.getKnowledgePoint().trim().isEmpty()) {
            Object knowledgePoints = request.get("knowledgePoints");
            if (knowledgePoints instanceof String) {
                composeRequest.setKnowledgePoint((String) knowledgePoints);
            }
        }
        return aiPaperComposeService.compose(composeRequest, getCurrentUser());
    }

    private String composePaperMarkdown(AiPaperComposeResponseVM paper) {
        StringBuilder markdown = new StringBuilder();
        markdown.append("## 已生成限时练习\n\n")
                .append("- 试卷：").append(paper.getPaperName()).append("\n")
                .append("- 题量：").append(paper.getQuestionCount()).append(" 道\n")
                .append("- 限时：").append(paper.getMinutes()).append(" 分钟\n")
                .append("- 选题策略：").append(paper.getStrategy()).append("\n")
                .append("- 题目 ID：").append(paper.getQuestionIds()).append("\n\n");
        markdown.append("[开始答题](").append(paper.getUrl()).append(")");
        return markdown.toString();
    }
}
