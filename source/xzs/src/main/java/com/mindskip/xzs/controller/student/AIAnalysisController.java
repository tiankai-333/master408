package com.mindskip.xzs.controller.student;

import com.mindskip.xzs.ai.AnalysisService;
import com.mindskip.xzs.ai.PromptTemplate;
import com.mindskip.xzs.ai.RagService;
import com.mindskip.xzs.base.RestResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController("StudentAIAnalysisController")
@RequestMapping("/api/student/ai")
public class AIAnalysisController {

    private static final Logger logger = LoggerFactory.getLogger(AIAnalysisController.class);

    private final AnalysisService analysisService;
    private final RagService ragService;

    @Autowired
    public AIAnalysisController(AnalysisService analysisService, RagService ragService) {
        this.analysisService = analysisService;
        this.ragService = ragService;
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

            String aiResult;

            if (apiKey != null && !apiKey.trim().isEmpty()) {
                logger.info("使用前端配置的AI - 类型: {}, 模型: {}", aiType, model);
                aiResult = analysisService.analyzeWithCustomAI(
                    aiType, apiKey, apiUrl, model, style, question, knowledgePoints, referenceDocs
                );
            } else {
                logger.info("使用后端配置的默认AI");
                aiResult = analysisService.analyzeWithAI(style, question, knowledgePoints, referenceDocs);
            }
            
            String prompt = analysisService.generatePrompt(style, question, knowledgePoints, referenceDocs);
            PromptTemplate template = analysisService.getTemplate(style);

            Map<String, Object> result = new HashMap<>();
            result.put("analysis", aiResult);
            result.put("prompt", prompt);
            result.put("systemPrompt", template.getSystemPrompt());
            result.put("style", style);
            
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
        }
    }
}
