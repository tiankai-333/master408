package com.mindskip.xzs.ai;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Service;

import java.io.InputStream;
import java.util.*;

@Service
public class AnalysisService {

    private static final Logger logger = LoggerFactory.getLogger(AnalysisService.class);

    private final Map<String, PromptTemplate> promptTemplates;
    private final ObjectMapper objectMapper;

    @Value("${ai.api.type:glm}")
    private String aiApiType;

    @Value("${ai.api.key:}")
    private String aiApiKey;

    @Value("${ai.api.url:https://open.bigmodel.cn/api/paas/v4/chat/completions}")
    private String aiApiUrl;

    public AnalysisService() {
        this.promptTemplates = new HashMap<>();
        this.objectMapper = new ObjectMapper();
        loadTemplates();
    }

    private void loadTemplates() {
        try {
            String[] styles = {"default", "feynman", "plato", "first-principles"};
            for (String style : styles) {
                String path = "ai/prompts/analysis/" + style + ".json";
                ClassPathResource resource = new ClassPathResource(path);
                if (resource.exists()) {
                    try (InputStream is = resource.getInputStream()) {
                        PromptTemplate template = objectMapper.readValue(is, PromptTemplate.class);
                        promptTemplates.put(style, template);
                        logger.info("Successfully loaded prompt template: {}", style);
                    }
                } else {
                    logger.warn("Prompt template not found: {}", path);
                }
            }
            logger.info("Total loaded prompt templates: {}", promptTemplates.size());
        } catch (Exception e) {
            logger.error("Failed to load prompt templates: " + e.getMessage(), e);
            loadDefaultTemplates();
        }
    }

    private void loadDefaultTemplates() {
        PromptTemplate defaultTemplate = new PromptTemplate();
        defaultTemplate.setName("default");
        defaultTemplate.setStyle("default");
        defaultTemplate.setSystemPrompt("你是一个专业的计算机考研408辅导老师。");
        defaultTemplate.setUserPromptTemplate("请解析以下题目：\n\n{question}\n\n相关知识点：{knowledge_points}");
        defaultTemplate.setVariables(Arrays.asList("question", "knowledge_points"));
        promptTemplates.put("default", defaultTemplate);
    }

    public List<String> getAvailableStyles() {
        return new ArrayList<>(promptTemplates.keySet());
    }

    public PromptTemplate getTemplate(String style) {
        return promptTemplates.getOrDefault(style, promptTemplates.get("default"));
    }

    public String generatePrompt(String style, String question, String knowledgePoints) {
        PromptTemplate template = getTemplate(style);
        return template.formatUserPrompt(question, knowledgePoints);
    }

    public String analyzeWithAI(String style, String question, String knowledgePoints) throws Exception {
        PromptTemplate template = getTemplate(style);
        String userPrompt = template.formatUserPrompt(question, knowledgePoints);
        String systemPrompt = template.getSystemPrompt();
        String model = "glm-4.5-air";
        return callAiApi(systemPrompt, userPrompt, aiApiType, aiApiKey, aiApiUrl, model);
    }

    public String analyzeWithCustomAI(String aiType, String apiKey, String apiUrl, String model, 
                                      String style, String question, String knowledgePoints) throws Exception {
        PromptTemplate template = getTemplate(style);
        String userPrompt = template.formatUserPrompt(question, knowledgePoints);
        String systemPrompt = template.getSystemPrompt();
        return callAiApi(systemPrompt, userPrompt, aiType, apiKey, apiUrl, model);
    }

    private String callAiApi(String systemPrompt, String userPrompt, String aiType, 
                            String apiKey, String apiUrl, String model) throws Exception {
        org.springframework.http.client.SimpleClientHttpRequestFactory factory = new org.springframework.http.client.SimpleClientHttpRequestFactory();
        factory.setConnectTimeout(60000);
        factory.setReadTimeout(600000);
        org.springframework.web.client.RestTemplate restTemplate = new org.springframework.web.client.RestTemplate(factory);
        org.springframework.http.HttpHeaders headers = new org.springframework.http.HttpHeaders();
        headers.set("Content-Type", "application/json");

        Map<String, Object> requestBody = new HashMap<>();

        if ("glm".equals(aiType)) {
            headers.set("Authorization", "Bearer " + apiKey);
            requestBody.put("model", model != null && !model.isEmpty() ? model : "glm-4.5-air");
            requestBody.put("messages", Arrays.asList(
                new HashMap<String, Object>() {{
                    put("role", "system");
                    put("content", systemPrompt != null ? systemPrompt : "你是一个专业的计算机考研408辅导老师。");
                }},
                new HashMap<String, Object>() {{
                    put("role", "user");
                    put("content", userPrompt);
                }}
            ));
            requestBody.put("temperature", 0.7);
            requestBody.put("max_tokens", 4096);
        } else {
            headers.set("Authorization", "Bearer " + apiKey);
            requestBody.put("model", model != null && !model.isEmpty() ? model : "gpt-4o");
            requestBody.put("messages", Arrays.asList(
                new HashMap<String, Object>() {{
                    put("role", "system");
                    put("content", systemPrompt != null ? systemPrompt : "你是一个专业的计算机考研408辅导老师。");
                }},
                new HashMap<String, Object>() {{
                    put("role", "user");
                    put("content", userPrompt);
                }}
            ));
            requestBody.put("temperature", 0.7);
            requestBody.put("max_tokens", 4096);
        }

        org.springframework.http.HttpEntity<Map<String, Object>> entity = new org.springframework.http.HttpEntity<>(requestBody, headers);
        
        try {
            org.springframework.http.ResponseEntity<String> response = restTemplate.postForEntity(apiUrl, entity, String.class);
            
            System.out.println("AI API响应状态: " + response.getStatusCode());

            ObjectMapper mapper = new ObjectMapper();
            com.fasterxml.jackson.databind.JsonNode rootNode = mapper.readTree(response.getBody());
            
            String resultContent = "";
            if ("glm".equals(aiType)) {
                com.fasterxml.jackson.databind.JsonNode choices = rootNode.path("choices");
                if (choices.isArray() && choices.size() > 0) {
                    com.fasterxml.jackson.databind.JsonNode message = choices.get(0).path("message");
                    resultContent = message.path("content").asText();
                    if (resultContent.isEmpty()) {
                        resultContent = message.path("reasoning_content").asText();
                    }
                } else {
                    System.out.println("GLM API返回格式异常，尝试其他路径...");
                    resultContent = rootNode.path("response").asText();
                    if (resultContent.isEmpty()) {
                        resultContent = rootNode.path("data").path("content").asText();
                    }
                }
            } else {
                resultContent = rootNode.path("choices").get(0).path("message").path("content").asText();
            }
            
            return resultContent;
        } catch (Exception e) {
            System.err.println("AI API调用失败: " + e.getMessage());
            throw new Exception("AI分析失败: " + e.getMessage(), e);
        }
    }
}
