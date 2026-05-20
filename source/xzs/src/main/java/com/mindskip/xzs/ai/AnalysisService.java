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
            .append("   标题必须写成“## 标题”，不要输出单独一行的 #。\n")
            .append("2. 面向学生表达，不要暴露 RAG、向量检索、prompt、上下文注入等技术实现词。\n")
            .append("3. 如果参考资料不足，要明确说明“不确定”，不要编造真题年份、题号或答案。\n")
            .append("4. 讲解要围绕 408 的四科：数据结构、组成原理、操作系统、计算机网络。\n")
            .append("5. 只输出最终教学答案，不输出自我规划、草稿、元说明或“我需要/我将/现在我”的过程描述。\n")
            .append("6. 不要重复整段结构；每个标题只出现一次。\n")
            .append("7. 当前讲法：").append(styleName(style)).append("。\n\n");

        if (knowledgePoints != null && !knowledgePoints.trim().isEmpty()) {
            prompt.append("## 当前知识点\n").append(knowledgePoints.trim()).append("\n\n");
        }

        if (referenceDocs != null && !referenceDocs.trim().isEmpty()) {
            prompt.append("## 可参考资料\n").append(referenceDocs.trim()).append("\n\n");
        }

        prompt.append("## 学生请求\n").append(question != null ? question.trim() : "").append("\n\n");
        prompt.append(buildStyleOutputRules(style, taskType)).append("\n");

        if ("practice".equals(taskType)) {
            prompt.append("## 输出要求\n")
                .append("- 这是“AI 辅助组卷/练习推荐”，不是自由出题。\n")
                .append("- 只能从题库已经存在的题目中挑选 1-5 道，不能编造新题、题号、年份、来源或选项。\n")
                .append("- 如果上下文没有提供可选题目 ID 或完整题库候选，请只输出筛选条件和组卷方案，不要输出虚构题目正文。\n")
                .append("- 推荐格式：## 选题目标 / ## 筛选条件 / ## 推荐题目 / ## 覆盖知识点。\n")
                .append("- 推荐题目必须标注题目 ID、知识点、题目来源；无法确认时写“不确定”。\n");
        } else {
            prompt.append("## 输出要求\n")
                .append("- 根据学生问题选择最合适的结构，不要机械套固定模板。\n")
                .append("- 普通刷题优先短答案；概念讲解可以稍展开，但不要写长篇背景。\n");
            if (wantsExamStyle(question)) {
                prompt.append("- 学生明确要求结合真题时，可以补充“## 常见考法”。\n");
            } else {
                prompt.append("- 不要默认输出“真题考法”“解题抓手”“典型题型示例”“复习建议”。\n");
            }
        }

        return prompt.toString();
    }

    private String buildStyleOutputRules(String style, String taskType) {
        StringBuilder rules = new StringBuilder("## 输出风格\n");
        if ("feynman".equals(style)) {
            rules.append("- 推荐结构：## 一句话解释 / ## 简单类比 / ## 回到题目 / ## 易错点。\n")
                .append("- 用白话和简单类比讲清楚，但不要啰嗦。\n");
        } else if ("first-principles".equals(style)) {
            rules.append("- 推荐结构：## 从定义出发 / ## 推出规则 / ## 应用到题目 / ## 结论。\n")
                .append("- 少背结论，多说明为什么。\n");
        } else if ("plato".equals(style)) {
            rules.append("- 推荐结构：## 关键追问 / ## 推出答案 / ## 结论。\n")
                .append("- 用 2-3 个关键追问引导判断，每个追问后直接给判断，不要假装等待学生回答。\n");
        } else {
            rules.append("- 推荐结构：## 考点 / ## 解题 / ## 答案 / ## 易错点。\n")
                .append("- 短、准、直接，先结论后原因。\n");
        }
        if ("practice".equals(taskType)) {
            rules.append("- 当前任务只允许推荐题库已有题目 1-5 道；没有题库候选时只给选题方案，不要编题。\n");
        }
        return rules.toString();
    }

    private boolean wantsExamStyle(String question) {
        return question != null && (question.contains("真题") || question.contains("408 真题"));
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
            
            String cleanedResult = cleanAiAnswer(resultContent);
            int tokensUsed = rootNode.path("usage").path("total_tokens").asInt(estimateTokens(systemPrompt, userPrompt, cleanedResult));
            saveUsageLog(aiType, model, userPrompt, systemPrompt, cleanedResult, tokensUsed,
                    (int) (System.currentTimeMillis() - startTime), true, null);
            return cleanedResult;
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

            String result = cleanAiAnswer(fullResponse.toString());
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
                com.fasterxml.jackson.databind.JsonNode contentNode = delta.path("content");
                String content = contentNode.isTextual() ? contentNode.asText() : "";
                if (!content.isEmpty() && !"null".equalsIgnoreCase(content)) {
                    return content;
                }
            }
            return "";
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

    private String cleanAiAnswer(String answer) {
        if (answer == null) {
            return null;
        }
        String cleaned = answer.trim();
        cleaned = cleaned.replaceFirst("^(?i)(?:null\\s*)+", "");
        cleaned = cleaned.replaceFirst("(?s)^(好的，?)?\\s*(我需要|让我|现在我将|我将|我来)\\s*[^#\\n]*(?:\\n|。|：|:)+\\s*", "");
        cleaned = cleaned.replaceFirst("(?s)\\s*(现在我已经完成|我已经完成|以上就是我|这样我就完成了)[^#]*$", "");
        cleaned = cleaned.replaceAll("(?m)^#\\s*$", "");
        return cleaned.trim();
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
