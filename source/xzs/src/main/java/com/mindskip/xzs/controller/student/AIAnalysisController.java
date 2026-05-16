package com.mindskip.xzs.controller.student;

import com.mindskip.xzs.ai.AnalysisService;
import com.mindskip.xzs.ai.PromptTemplate;
import com.mindskip.xzs.ai.RagService;
import com.mindskip.xzs.base.BaseApiController;
import com.mindskip.xzs.base.RestResponse;
import com.mindskip.xzs.domain.User;
import com.mindskip.xzs.domain.ai.AiUsageLog;
import com.mindskip.xzs.repository.AiUsageLogMapper;
import com.mindskip.xzs.service.AiLearningProfileService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController("StudentAIAnalysisController")
@RequestMapping("/api/student/ai")
public class AIAnalysisController extends BaseApiController {

    private static final Logger logger = LoggerFactory.getLogger(AIAnalysisController.class);

    private final AnalysisService analysisService;
    private final RagService ragService;
    private final AiUsageLogMapper aiUsageLogMapper;
    private final AiLearningProfileService aiLearningProfileService;

    @Autowired
    public AIAnalysisController(AnalysisService analysisService, RagService ragService,
                                AiUsageLogMapper aiUsageLogMapper,
                                AiLearningProfileService aiLearningProfileService) {
        this.analysisService = analysisService;
        this.ragService = ragService;
        this.aiUsageLogMapper = aiUsageLogMapper;
        this.aiLearningProfileService = aiLearningProfileService;
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

        String prompt = analysisService.generatePrompt(style, question, knowledgePoints);
        PromptTemplate template = analysisService.getTemplate(style);

        Map<String, String> result = new HashMap<>();
        result.put("prompt", prompt);
        result.put("systemPrompt", template.getSystemPrompt());
        result.put("style", template.getStyle());

        return RestResponse.ok(result);
    }

    @PostMapping("/analyze")
    public RestResponse<Map<String, Object>> analyzeWithAI(@RequestBody Map<String, Object> request) {
        try {
            String style = (String) request.getOrDefault("style", "default");
            String question = (String) request.get("question");
            String knowledgePoints = (String) request.get("knowledgePoints");
            Boolean useStudentProfile = (Boolean) request.getOrDefault("useStudentProfile", Boolean.TRUE);
            User currentUser = getCurrentUser();
            Integer userId = currentUser != null ? currentUser.getId() : null;

            logger.info("开始AI分析题目 - 风格: {}, 内容长度: {}", 
                style, question != null ? question.length() : 0);

            if (question == null || question.trim().isEmpty()) {
                logger.warn("题目内容为空");
                return RestResponse.fail(2, "题目内容不能为空");
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
            String studentProfile = Boolean.TRUE.equals(useStudentProfile)
                ? aiLearningProfileService.buildProfileSummary(userId)
                : "";
            String feedbackNotes = Boolean.TRUE.equals(useStudentProfile)
                ? aiLearningProfileService.buildFeedbackNotes(userId, style)
                : "";

            String aiResult;

            if (apiKey != null && !apiKey.trim().isEmpty()) {
                logger.info("使用前端配置的AI - 类型: {}, 模型: {}", aiType, model);
                aiResult = analysisService.analyzeWithCustomAI(
                    aiType, apiKey, apiUrl, model, style, question, knowledgePoints, referenceDocs,
                    studentProfile, feedbackNotes
                );
            } else {
                logger.info("使用后端配置的默认AI");
                aiResult = analysisService.analyzeWithAI(style, question, knowledgePoints, referenceDocs,
                    studentProfile, feedbackNotes);
            }
            
            String prompt = analysisService.generatePrompt(style, question, knowledgePoints, referenceDocs,
                studentProfile, feedbackNotes);
            PromptTemplate template = analysisService.getTemplate(style);

            AiUsageLog usageLog = new AiUsageLog();
            usageLog.setStyle(style);
            usageLog.setAiType(apiKey != null && !apiKey.trim().isEmpty() ? aiType : "backend-default");
            usageLog.setModel(model);
            usageLog.setQuestion(question);
            usageLog.setKnowledgePoints(knowledgePoints);
            usageLog.setPrompt(prompt);
            usageLog.setResponse(aiResult);
            usageLog.setResponseLength(aiResult != null ? aiResult.length() : 0);
            usageLog.setSuccess(true);
            usageLog.setCreateTime(new Date());
            if (ragDocs != null && !ragDocs.isEmpty()) {
                usageLog.setKnowledgeBaseIds(ragDocs.stream()
                    .map(doc -> String.valueOf(doc.getId()))
                    .collect(Collectors.joining(",")));
            }
            aiUsageLogMapper.insert(usageLog);
            aiLearningProfileService.recordAiAnalyze(userId, style, usageLog.getId(), question, aiResult);

            Map<String, Object> result = new HashMap<>();
            result.put("analysis", aiResult);
            result.put("prompt", prompt);
            result.put("systemPrompt", template.getSystemPrompt());
            result.put("style", style);
            result.put("usageLogId", usageLog.getId());
            result.put("studentProfileSummary", studentProfile);
            
            if (ragDocs != null && !ragDocs.isEmpty()) {
                List<Map<String, Object>> references = ragDocs.stream().map(doc -> {
                    Map<String, Object> ref = new HashMap<>();
                    ref.put("title", doc.getTitle());
                    ref.put("similarity", String.format("%.2f", doc.getSimilarity()));
                    ref.put("id", doc.getId());
                    ref.put("category", doc.getCategory());
                    ref.put("sourceType", doc.getSourceType());
                    return ref;
                }).collect(Collectors.toList());
                result.put("references", references);
            }

            logger.info("AI分析完成 - 结果长度: {}", aiResult != null ? aiResult.length() : 0);
            
            return RestResponse.ok(result);
        } catch (Exception e) {
            logger.error("AI分析失败", e);
            return RestResponse.fail(2, "AI分析失败: " + e.getMessage());
        }
    }

    @PostMapping("/feedback")
    public RestResponse<Map<String, Object>> saveFeedback(@RequestBody Map<String, Object> request) {
        try {
            User currentUser = getCurrentUser();
            Integer userId = currentUser != null ? currentUser.getId() : null;
            Integer usageLogId = toInteger(request.get("usageLogId"));
            String style = (String) request.getOrDefault("style", "default");
            Integer rating = toInteger(request.get("rating"));
            String feedback = (String) request.getOrDefault("feedback", "");

            if (usageLogId != null) {
                AiUsageLog usageLog = aiUsageLogMapper.selectById(usageLogId);
                if (usageLog != null) {
                    usageLog.setUserRating(rating);
                    usageLog.setUserFeedback(feedback);
                    aiUsageLogMapper.update(usageLog);
                }
            }
            aiLearningProfileService.saveSkillFeedback(userId, usageLogId, style, rating, feedback);

            Map<String, Object> result = new HashMap<>();
            result.put("usageLogId", usageLogId);
            result.put("style", style);
            result.put("rating", rating);
            return RestResponse.ok(result);
        } catch (Exception e) {
            logger.error("保存AI反馈失败", e);
            return RestResponse.fail(2, "保存反馈失败: " + e.getMessage());
        }
    }

    private Integer toInteger(Object value) {
        if (value == null) {
            return null;
        }
        if (value instanceof Number) {
            return ((Number) value).intValue();
        }
        try {
            return Integer.parseInt(String.valueOf(value));
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
