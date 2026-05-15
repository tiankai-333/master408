package com.mindskip.xzs.controller.student;

import com.mindskip.xzs.ai.AnalysisService;
import com.mindskip.xzs.ai.PromptTemplate;
import com.mindskip.xzs.base.RestResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController("StudentAIAnalysisController")
@RequestMapping("/api/student/ai")
public class AIAnalysisController {

    private static final Logger logger = LoggerFactory.getLogger(AIAnalysisController.class);

    private final AnalysisService analysisService;

    @Autowired
    public AIAnalysisController(AnalysisService analysisService) {
        this.analysisService = analysisService;
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
    public RestResponse<Map<String, String>> analyzeWithAI(@RequestBody Map<String, Object> request) {
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

            // 获取前端传入的AI配置
            String aiType = (String) request.getOrDefault("aiType", "");
            String apiKey = (String) request.getOrDefault("apiKey", "");
            String apiUrl = (String) request.getOrDefault("apiUrl", "");
            String model = (String) request.getOrDefault("model", "");

            String aiResult;

            // 如果前端传入了AI配置，使用前端配置；否则使用后端默认配置
            if (apiKey != null && !apiKey.trim().isEmpty()) {
                logger.info("使用前端配置的AI - 类型: {}, 模型: {}", aiType, model);
                aiResult = analysisService.analyzeWithCustomAI(
                    aiType, apiKey, apiUrl, model, style, question, knowledgePoints
                );
            } else {
                logger.info("使用后端配置的默认AI");
                aiResult = analysisService.analyzeWithAI(style, question, knowledgePoints);
            }
            
            String prompt = analysisService.generatePrompt(style, question, knowledgePoints);
            PromptTemplate template = analysisService.getTemplate(style);

            Map<String, String> result = new HashMap<>();
            result.put("analysis", aiResult);
            result.put("prompt", prompt);
            result.put("systemPrompt", template.getSystemPrompt());
            result.put("style", style);

            logger.info("AI分析完成 - 结果长度: {}", aiResult.length());
            
            return RestResponse.ok(result);
        } catch (Exception e) {
            logger.error("AI分析失败", e);
            return RestResponse.fail(2, "AI分析失败: " + e.getMessage());
        }
    }
}
