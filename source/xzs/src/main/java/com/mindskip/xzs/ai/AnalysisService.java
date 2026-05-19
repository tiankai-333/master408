package com.mindskip.xzs.ai;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.mindskip.xzs.domain.ai.AiProviderConfig;
import com.mindskip.xzs.domain.ai.AiUsageLog;
import com.mindskip.xzs.repository.AiUsageLogMapper;
import com.mindskip.xzs.service.AiProviderConfigService;
import org.springframework.beans.factory.annotation.Autowired;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Service;

import java.io.InputStream;
import java.io.BufferedReader;
import java.io.OutputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.*;

@Service
public class AnalysisService {

    private static final Logger logger = LoggerFactory.getLogger(AnalysisService.class);

    private final Map<String, PromptTemplate> promptTemplates;
    private final ObjectMapper objectMapper;

    public interface StreamTokenConsumer {
        void accept(String token) throws Exception;
    }

    @Autowired
    private AiProviderConfigService aiProviderConfigService;

    @Autowired
    private AiUsageLogMapper aiUsageLogMapper;

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
        return generatePrompt(style, question, knowledgePoints, null);
    }

    public String generatePrompt(String style, String question, String knowledgePoints, String referenceDocs) {
        return generatePrompt(style, question, knowledgePoints, referenceDocs, "chat");
    }

    public String generatePrompt(String style, String question, String knowledgePoints, String referenceDocs, String taskType) {
        if (isWorkbenchTask(taskType)) {
            return buildWorkbenchPrompt(taskType, style, question, knowledgePoints, referenceDocs);
        }
        PromptTemplate template = getTemplate(style);
        return template.formatUserPrompt(question, knowledgePoints, referenceDocs);
    }

    public String analyzeWithAI(String style, String question, String knowledgePoints) throws Exception {
        return analyzeWithAI(style, question, knowledgePoints, null);
    }

    public String analyzeWithAI(String style, String question, String knowledgePoints, String referenceDocs) throws Exception {
        return analyzeWithAI(style, question, knowledgePoints, referenceDocs, "chat");
    }

    public String analyzeWithAI(String style, String question, String knowledgePoints, String referenceDocs, String taskType) throws Exception {
        PromptTemplate template = getTemplate(style);
        String userPrompt = generatePrompt(style, question, knowledgePoints, referenceDocs, taskType);
        String systemPrompt = template.getSystemPrompt();
        String model = "glm-4.5-air";
        AiProviderConfig provider = aiProviderConfigService.getFirstEnabled();
        if (provider != null) {
            String providerType = apiType(provider.getProviderCode());
            String providerKey = aiProviderConfigService.resolveApiKey(provider.getProviderCode());
            String providerUrl = chatEndpoint(provider);
            String providerModel = provider.getChatModel() == null || provider.getChatModel().isEmpty() ? model : provider.getChatModel();
            return callAiApi(systemPrompt, userPrompt, providerType, providerKey, providerUrl, providerModel);
        }
        return callAiApi(systemPrompt, userPrompt, aiApiType, aiApiKey, aiApiUrl, model);
    }

    public String analyzeWithAIStream(String style, String question, String knowledgePoints, String referenceDocs,
                                      String taskType, StreamTokenConsumer tokenConsumer) throws Exception {
        PromptTemplate template = getTemplate(style);
        String userPrompt = generatePrompt(style, question, knowledgePoints, referenceDocs, taskType);
        String systemPrompt = template.getSystemPrompt();
        String model = "glm-4.5-air";
        AiProviderConfig provider = aiProviderConfigService.getFirstEnabled();
        if (provider != null) {
            String providerType = apiType(provider.getProviderCode());
            String providerKey = aiProviderConfigService.resolveApiKey(provider.getProviderCode());
            String providerUrl = chatEndpoint(provider);
            String providerModel = provider.getChatModel() == null || provider.getChatModel().isEmpty() ? model : provider.getChatModel();
            return callAiApiStream(systemPrompt, userPrompt, providerType, providerKey, providerUrl, providerModel, tokenConsumer);
        }
        return callAiApiStream(systemPrompt, userPrompt, aiApiType, aiApiKey, aiApiUrl, model, tokenConsumer);
    }

    private String apiType(String providerCode) {
        return "zhipu".equals(providerCode) ? "glm" : "openai";
    }

    private String chatEndpoint(AiProviderConfig provider) {
        String baseUrl = provider.getApiBaseUrl() == null ? "" : provider.getApiBaseUrl().replaceAll("/+$", "");
        if (baseUrl.endsWith("/chat/completions")) {
            return baseUrl;
        }
        return baseUrl + "/chat/completions";
    }

    public String analyzeWithCustomAI(String aiType, String apiKey, String apiUrl, String model, 
                                      String style, String question, String knowledgePoints) throws Exception {
        return analyzeWithCustomAI(aiType, apiKey, apiUrl, model, style, question, knowledgePoints, null);
    }

    public String analyzeWithCustomAI(String aiType, String apiKey, String apiUrl, String model, 
                                      String style, String question, String knowledgePoints, String referenceDocs) throws Exception {
        return analyzeWithCustomAI(aiType, apiKey, apiUrl, model, style, question, knowledgePoints, referenceDocs, "chat");
    }

    public String analyzeWithCustomAI(String aiType, String apiKey, String apiUrl, String model, 
                                      String style, String question, String knowledgePoints, String referenceDocs, String taskType) throws Exception {
        PromptTemplate template = getTemplate(style);
        String userPrompt = generatePrompt(style, question, knowledgePoints, referenceDocs, taskType);
        String systemPrompt = template.getSystemPrompt();
        return callAiApi(systemPrompt, userPrompt, aiType, apiKey, apiUrl, model);
    }

    public String analyzeWithCustomAIStream(String aiType, String apiKey, String apiUrl, String model,
                                            String style, String question, String knowledgePoints, String referenceDocs,
                                            String taskType, StreamTokenConsumer tokenConsumer) throws Exception {
        PromptTemplate template = getTemplate(style);
        String userPrompt = generatePrompt(style, question, knowledgePoints, referenceDocs, taskType);
        String systemPrompt = template.getSystemPrompt();
        return callAiApiStream(systemPrompt, userPrompt, aiType, apiKey, apiUrl, model, tokenConsumer);
    }

    private boolean isWorkbenchTask(String taskType) {
        return "explain".equals(taskType) || "exam".equals(taskType) || "practice".equals(taskType);
    }

    private String buildWorkbenchPrompt(String taskType, String style, String question, String knowledgePoints, String referenceDocs) {
        StringBuilder prompt = new StringBuilder();
        prompt.append("你正在 408Master 的 AI 学习工作台中回答学生。请遵守：\n")
            .append("1. 输出必须是标准 Markdown，不要把标题写成普通文本，不要把所有内容挤成一段。\n")
            .append("2. 面向学生表达，不要暴露 RAG、向量检索、prompt、上下文注入等技术实现词。\n")
            .append("3. 如果参考资料不足，要明确说明“不确定”，不要编造真题年份、题号或答案。\n")
            .append("4. 讲解要围绕 408 的四科：数据结构、组成原理、操作系统、计算机网络。\n")
            .append("5. 当前讲法：").append(styleName(style)).append("。\n\n");

        if (knowledgePoints != null && !knowledgePoints.trim().isEmpty()) {
            prompt.append("## 当前知识点\n").append(knowledgePoints.trim()).append("\n\n");
        }

        if (referenceDocs != null && !referenceDocs.trim().isEmpty()) {
            prompt.append("## 可参考资料\n").append(referenceDocs.trim()).append("\n\n");
        }

        prompt.append("## 学生请求\n").append(question != null ? question.trim() : "").append("\n\n");

        if ("practice".equals(taskType)) {
            prompt.append("## 输出要求\n")
                .append("请严格按以下顺序输出：\n")
                .append("### 练习题\n")
                .append("- 先给出完整题干。\n")
                .append("- 如果是选择题，必须给出 A、B、C、D 四个选项。\n")
                .append("- 题目必须能独立作答，不要一上来给答案。\n\n")
                .append("### 请先作答\n")
                .append("用一句话提醒学生先自己做，再看解析。\n\n")
                .append("### 答案与解析\n")
                .append("- 明确答案。\n")
                .append("- 分步骤解释为什么。\n")
                .append("- 对选择题逐项说明选项对错。\n\n")
                .append("### 关联知识点\n")
                .append("- 列出所属科目和 2-4 个核心考点。\n")
                .append("- 给出一个变式练习方向。\n");
        } else if ("exam".equals(taskType)) {
            prompt.append("## 输出要求\n")
                .append("请按以下结构输出：\n")
                .append("### 真题考法\n说明这个知识点在 408 中通常怎么设问。\n\n")
                .append("### 解题抓手\n给出读题时优先抓的关键词和条件。\n\n")
                .append("### 典型题型示例\n给一个简短示例，必须先给题干或题型场景，再解释思路。\n\n")
                .append("### 易错点\n列出 2-3 个常见误区。\n\n")
                .append("### 复习建议\n给出下一步练习建议。\n");
        } else {
            prompt.append("## 输出要求\n")
                .append("请按以下结构输出：\n")
                .append("### 核心定义\n用准确但易懂的话解释概念。\n\n")
                .append("### 为什么重要\n说明它在 408 中解决什么问题。\n\n")
                .append("### 常见考法\n列出 3 个常见设问方式。\n\n")
                .append("### 易错提醒\n列出 2-3 个易错点。\n\n")
                .append("### 小练习\n最后给一个 1 分钟小问题，让学生可以立刻练习。\n");
        }

        return prompt.toString();
    }

    private String styleName(String style) {
        if ("feynman".equals(style)) {
            return "费曼学习法，用白话、类比和反问帮助理解";
        }
        if ("first-principles".equals(style)) {
            return "第一性原理，从定义和基本约束推导";
        }
        if ("plato".equals(style)) {
            return "柏拉图式对话，用层层追问启发思考";
        }
        return "常规解析，结构清楚、考点明确";
    }

    private String callAiApi(String systemPrompt, String userPrompt, String aiType, 
                            String apiKey, String apiUrl, String model) throws Exception {
        long startTime = System.currentTimeMillis();
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
            
            int tokensUsed = rootNode.path("usage").path("total_tokens").asInt(estimateTokens(systemPrompt, userPrompt, resultContent));
            saveUsageLog(aiType, model, userPrompt, systemPrompt, resultContent, tokensUsed,
                    (int) (System.currentTimeMillis() - startTime), true, null);
            return resultContent;
        } catch (Exception e) {
            System.err.println("AI API调用失败: " + e.getMessage());
            saveUsageLog(aiType, model, userPrompt, systemPrompt, null, estimateTokens(systemPrompt, userPrompt, null),
                    (int) (System.currentTimeMillis() - startTime), false, e.getMessage());
            throw new Exception("AI分析失败: " + e.getMessage(), e);
        }
    }

    private String callAiApiStream(String systemPrompt, String userPrompt, String aiType,
                                   String apiKey, String apiUrl, String model,
                                   StreamTokenConsumer tokenConsumer) throws Exception {
        long startTime = System.currentTimeMillis();
        String resolvedModel = model != null && !model.isEmpty() ? model : ("glm".equals(aiType) ? "glm-4.5-air" : "gpt-4o");
        Map<String, Object> requestBody = new HashMap<>();
        requestBody.put("model", resolvedModel);
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
        requestBody.put("stream", true);

        StringBuilder fullResponse = new StringBuilder();
        HttpURLConnection connection = null;
        try {
            URL url = new URL(apiUrl);
            connection = (HttpURLConnection) url.openConnection();
            connection.setRequestMethod("POST");
            connection.setDoOutput(true);
            connection.setConnectTimeout(60000);
            connection.setReadTimeout(600000);
            connection.setRequestProperty("Content-Type", "application/json");
            connection.setRequestProperty("Accept", "text/event-stream");
            connection.setRequestProperty("Authorization", "Bearer " + apiKey);

            byte[] body = objectMapper.writeValueAsString(requestBody).getBytes(StandardCharsets.UTF_8);
            try (OutputStream outputStream = connection.getOutputStream()) {
                outputStream.write(body);
            }

            int statusCode = connection.getResponseCode();
            InputStream inputStream = statusCode >= 200 && statusCode < 300
                ? connection.getInputStream()
                : connection.getErrorStream();

            if (statusCode < 200 || statusCode >= 300) {
                String errorBody = readAll(inputStream);
                throw new Exception("AI流式调用失败: HTTP " + statusCode + " - " + errorBody);
            }

            try (BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream, StandardCharsets.UTF_8))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    String trimmed = line.trim();
                    if (!trimmed.startsWith("data:")) {
                        continue;
                    }
                    String data = trimmed.substring(5).trim();
                    if (data.isEmpty()) {
                        continue;
                    }
                    if ("[DONE]".equals(data)) {
                        break;
                    }
                    String token = extractStreamToken(data);
                    if (token != null && !token.isEmpty()) {
                        fullResponse.append(token);
                        tokenConsumer.accept(token);
                    }
                }
            }

            String result = fullResponse.toString();
            saveUsageLog(aiType, resolvedModel, userPrompt, systemPrompt, result, estimateTokens(systemPrompt, userPrompt, result),
                (int) (System.currentTimeMillis() - startTime), true, null);
            return result;
        } catch (Exception e) {
            saveUsageLog(aiType, resolvedModel, userPrompt, systemPrompt, fullResponse.length() == 0 ? null : fullResponse.toString(),
                estimateTokens(systemPrompt, userPrompt, fullResponse.toString()),
                (int) (System.currentTimeMillis() - startTime), false, e.getMessage());
            throw new Exception("AI流式分析失败: " + e.getMessage(), e);
        } finally {
            if (connection != null) {
                connection.disconnect();
            }
        }
    }

    private String extractStreamToken(String data) {
        try {
            com.fasterxml.jackson.databind.JsonNode rootNode = objectMapper.readTree(data);
            com.fasterxml.jackson.databind.JsonNode choices = rootNode.path("choices");
            if (choices.isArray() && choices.size() > 0) {
                com.fasterxml.jackson.databind.JsonNode choice = choices.get(0);
                com.fasterxml.jackson.databind.JsonNode delta = choice.path("delta");
                String content = delta.path("content").asText();
                if (!content.isEmpty()) {
                    return content;
                }
                content = delta.path("reasoning_content").asText();
                if (!content.isEmpty()) {
                    return content;
                }
                com.fasterxml.jackson.databind.JsonNode message = choice.path("message");
                content = message.path("content").asText();
                if (!content.isEmpty()) {
                    return content;
                }
            }
            String response = rootNode.path("response").asText();
            if (!response.isEmpty()) {
                return response;
            }
            return rootNode.path("data").path("content").asText();
        } catch (Exception e) {
            logger.debug("Failed to parse stream chunk: {}", e.getMessage());
            return "";
        }
    }

    private String readAll(InputStream inputStream) throws Exception {
        if (inputStream == null) {
            return "";
        }
        StringBuilder builder = new StringBuilder();
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream, StandardCharsets.UTF_8))) {
            String line;
            while ((line = reader.readLine()) != null) {
                builder.append(line).append('\n');
            }
        }
        return builder.toString();
    }

    private void saveUsageLog(String aiType, String model, String question, String prompt, String response,
                              Integer tokensUsed, Integer durationMs, Boolean success, String errorMessage) {
        try {
            AiUsageLog log = new AiUsageLog();
            log.setStyle("runtime");
            log.setAiType(aiType);
            log.setModel(model);
            log.setQuestion(limitText(question, 6000));
            log.setKnowledgePoints("");
            log.setPrompt(limitText(prompt, 6000));
            log.setResponse(limitText(response, 6000));
            log.setResponseLength(response == null ? 0 : response.length());
            log.setTokensUsed(tokensUsed);
            log.setCost(0D);
            log.setDurationMs(durationMs);
            log.setSuccess(success);
            log.setErrorMessage(limitText(errorMessage, 1000));
            log.setCreateTime(new Date());
            aiUsageLogMapper.insert(log);
        } catch (Exception logError) {
            logger.warn("Failed to save AI usage log: {}", logError.getMessage());
        }
    }

    private int estimateTokens(String systemPrompt, String userPrompt, String response) {
        int length = 0;
        if (systemPrompt != null) {
            length += systemPrompt.length();
        }
        if (userPrompt != null) {
            length += userPrompt.length();
        }
        if (response != null) {
            length += response.length();
        }
        return Math.max(1, length / 3);
    }

    private String limitText(String value, int maxLength) {
        if (value == null) {
            return null;
        }
        return value.length() <= maxLength ? value : value.substring(0, maxLength);
    }
}
