package com.mindskip.xzs.service.impl;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.mindskip.xzs.domain.ai.AiPromptTemplate;
import com.mindskip.xzs.domain.ai.AiKnowledgeBase;
import com.mindskip.xzs.domain.ai.AiAdjustmentLog;
import com.mindskip.xzs.domain.ai.AiUsageLog;
import com.mindskip.xzs.repository.AiPromptTemplateMapper;
import com.mindskip.xzs.repository.AiKnowledgeBaseMapper;
import com.mindskip.xzs.repository.AiAdjustmentLogMapper;
import com.mindskip.xzs.repository.AiUsageLogMapper;
import com.mindskip.xzs.service.AiAgentService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

@Service
public class AiAgentServiceImpl implements AiAgentService {

    private static final Logger logger = LoggerFactory.getLogger(AiAgentServiceImpl.class);
    
    @Autowired
    private AiPromptTemplateMapper templateMapper;
    
    @Autowired
    private AiKnowledgeBaseMapper knowledgeBaseMapper;
    
    @Autowired
    private AiAdjustmentLogMapper adjustmentLogMapper;
    
    @Autowired
    private AiUsageLogMapper usageLogMapper;

    private final ObjectMapper objectMapper = new ObjectMapper();

    // ============ 模板管理 ============

    @Override
    public List<AiPromptTemplate> getAllTemplates() {
        return templateMapper.selectAll();
    }

    @Override
    public List<AiPromptTemplate> getEnabledTemplates() {
        return templateMapper.selectEnabled();
    }

    @Override
    public AiPromptTemplate getTemplateByStyle(String style) {
        AiPromptTemplate template = templateMapper.selectByStyle(style);
        if (template != null && template.getKnowledgeBaseIds() != null && !template.getKnowledgeBaseIds().isEmpty()) {
            List<Integer> ids = parseIds(template.getKnowledgeBaseIds());
            List<AiKnowledgeBase> knowledgeBases = knowledgeBaseMapper.selectByIds(ids);
            template.setKnowledgeBases(knowledgeBases);
        }
        return template;
    }

    @Override
    public AiPromptTemplate getTemplateById(Integer id) {
        AiPromptTemplate template = templateMapper.selectById(id);
        if (template != null && template.getKnowledgeBaseIds() != null && !template.getKnowledgeBaseIds().isEmpty()) {
            List<Integer> ids = parseIds(template.getKnowledgeBaseIds());
            List<AiKnowledgeBase> knowledgeBases = knowledgeBaseMapper.selectByIds(ids);
            template.setKnowledgeBases(knowledgeBases);
        }
        return template;
    }

    @Override
    public AiPromptTemplate createTemplate(AiPromptTemplate template) {
        template.setCreateTime(new Date());
        template.setUpdateTime(new Date());
        template.setUsageCount(0);
        template.setRatingSum(0);
        template.setRatingCount(0);
        templateMapper.insert(template);
        
        // 记录创建日志
        AiAdjustmentLog log = new AiAdjustmentLog();
        log.setTemplateId(template.getId());
        log.setStyle(template.getStyle());
        log.setAdjustmentType("create");
        log.setAfterContent(objectMapper.toString());
        log.setAdjustmentReason("创建新模板");
        log.setCreateTime(new Date());
        adjustmentLogMapper.insert(log);
        
        return template;
    }

    @Override
    public AiPromptTemplate updateTemplate(Integer id, AiPromptTemplate template) {
        AiPromptTemplate oldTemplate = templateMapper.selectById(id);
        template.setId(id);
        template.setUpdateTime(new Date());
        templateMapper.update(template);
        
        // 记录更新日志
        AiAdjustmentLog log = new AiAdjustmentLog();
        log.setTemplateId(id);
        log.setStyle(template.getStyle());
        log.setAdjustmentType("update");
        log.setBeforeContent(objectMapper.valueToTree(oldTemplate).toString());
        log.setAfterContent(objectMapper.valueToTree(template).toString());
        log.setAdjustmentReason(template.getDescription());
        log.setCreateTime(new Date());
        adjustmentLogMapper.insert(log);
        
        return template;
    }

    @Override
    public void deleteTemplate(Integer id) {
        AiPromptTemplate template = templateMapper.selectById(id);
        if (template != null) {
            template.setDeleted(true);
            templateMapper.update(template);
            
            // 记录删除日志
            AiAdjustmentLog log = new AiAdjustmentLog();
            log.setTemplateId(id);
            log.setStyle(template.getStyle());
            log.setAdjustmentType("delete");
            log.setBeforeContent(objectMapper.valueToTree(template).toString());
            log.setAdjustmentReason("删除模板");
            log.setCreateTime(new Date());
            adjustmentLogMapper.insert(log);
        }
    }

    @Override
    public AiPromptTemplate updateTemplateRating(Integer id, Integer rating) {
        AiPromptTemplate template = templateMapper.selectById(id);
        if (template != null) {
            template.setRatingSum(template.getRatingSum() + rating);
            template.setRatingCount(template.getRatingCount() + 1);
            templateMapper.update(template);
        }
        return template;
    }

    // ============ 知识库管理 ============

    @Override
    public List<AiKnowledgeBase> getAllKnowledgeBase() {
        return knowledgeBaseMapper.selectAll();
    }

    @Override
    public List<AiKnowledgeBase> getKnowledgeBaseByCategory(String category) {
        return knowledgeBaseMapper.selectByCategory(category);
    }

    @Override
    public List<AiKnowledgeBase> getKnowledgeBaseByDomain(String domain) {
        return knowledgeBaseMapper.selectByDomain(domain);
    }

    @Override
    public List<AiKnowledgeBase> getKnowledgeBaseByIds(List<Integer> ids) {
        return knowledgeBaseMapper.selectByIds(ids);
    }

    @Override
    public AiKnowledgeBase getKnowledgeBaseById(Integer id) {
        return knowledgeBaseMapper.selectById(id);
    }

    @Override
    public AiKnowledgeBase createKnowledgeBase(AiKnowledgeBase knowledgeBase) {
        knowledgeBase.setCreateTime(new Date());
        knowledgeBase.setUpdateTime(new Date());
        knowledgeBase.setUsageCount(0);
        knowledgeBaseMapper.insert(knowledgeBase);
        return knowledgeBase;
    }

    @Override
    public AiKnowledgeBase updateKnowledgeBase(Integer id, AiKnowledgeBase knowledgeBase) {
        knowledgeBase.setId(id);
        knowledgeBase.setUpdateTime(new Date());
        knowledgeBaseMapper.update(knowledgeBase);
        return knowledgeBase;
    }

    @Override
    public void deleteKnowledgeBase(Integer id) {
        knowledgeBaseMapper.deleteById(id);
    }

    @Override
    public List<AiKnowledgeBase> searchKnowledgeBase(String keyword) {
        return knowledgeBaseMapper.search(keyword);
    }

    // ============ 调整日志 ============

    @Override
    public List<AiAdjustmentLog> getAdjustmentLogs(Integer templateId, String style, int limit) {
        return adjustmentLogMapper.selectLogs(templateId, style, limit);
    }

    @Override
    public AiAdjustmentLog createAdjustmentLog(AiAdjustmentLog log) {
        log.setCreateTime(new Date());
        adjustmentLogMapper.insert(log);
        return log;
    }

    @Override
    public AiAdjustmentLog testTemplate(Integer templateId, String question) {
        AiPromptTemplate template = getTemplateById(templateId);
        if (template == null) {
            throw new RuntimeException("模板不存在");
        }
        
        String result = analyzeWithTemplate(template.getStyle(), question, "", "glm", "", "", "");
        
        AiAdjustmentLog log = new AiAdjustmentLog();
        log.setTemplateId(templateId);
        log.setStyle(template.getStyle());
        log.setAdjustmentType("test");
        log.setTestQuestion(question);
        log.setTestResult(result);
        log.setCreateTime(new Date());
        adjustmentLogMapper.insert(log);
        
        return log;
    }

    @Override
    public AiAdjustmentLog approveAdjustment(Integer logId, Integer approverId, String comment) {
        AiAdjustmentLog log = adjustmentLogMapper.selectById(logId);
        if (log != null) {
            log.setStatus("approved");
            log.setApproverId(approverId);
            log.setApproveTime(new Date());
            log.setApproveComment(comment);
            adjustmentLogMapper.update(log);
        }
        return log;
    }

    @Override
    public AiAdjustmentLog rejectAdjustment(Integer logId, Integer approverId, String comment) {
        AiAdjustmentLog log = adjustmentLogMapper.selectById(logId);
        if (log != null) {
            log.setStatus("rejected");
            log.setApproverId(approverId);
            log.setApproveTime(new Date());
            log.setApproveComment(comment);
            adjustmentLogMapper.update(log);
        }
        return log;
    }

    // ============ 使用记录 ============

    @Override
    public void saveUsageLog(AiUsageLog usageLog) {
        usageLog.setCreateTime(new Date());
        usageLogMapper.insert(usageLog);
        
        // 更新模板使用次数
        if (usageLog.getTemplateId() != null) {
            templateMapper.incrementUsageCount(usageLog.getTemplateId());
        }
    }

    @Override
    public List<AiUsageLog> getUsageLogs(Integer templateId, int limit) {
        return usageLogMapper.selectByTemplateId(templateId, limit);
    }

    @Override
    public void updateUsageLogRating(Integer id, Integer rating, String feedback) {
        AiUsageLog log = usageLogMapper.selectById(id);
        if (log != null) {
            log.setUserRating(rating);
            log.setUserFeedback(feedback);
            usageLogMapper.update(log);
            
            // 更新模板评分
            if (log.getTemplateId() != null) {
                updateTemplateRating(log.getTemplateId(), rating);
            }
        }
    }

    @Override
    public Map<String, Object> getUsageStatistics() {
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalUsage", usageLogMapper.countTotal());
        stats.put("successRate", usageLogMapper.countSuccessRate());
        stats.put("topStyles", usageLogMapper.getTopStyles(5));
        return stats;
    }

    // ============ AI调用 ============

    @Override
    public String analyzeWithTemplate(String style, String question, String knowledgePoints, 
                                     String aiType, String apiKey, String apiUrl, String model) {
        AiPromptTemplate template = getTemplateByStyle(style);
        if (template == null) {
            throw new RuntimeException("模板不存在: " + style);
        }
        
        String systemPrompt = template.getSystemPrompt();
        String userPrompt = buildPromptWithKnowledgeBase(template, question, knowledgePoints);
        
        long startTime = System.currentTimeMillis();
        
        try {
            String result;
            if (apiKey != null && !apiKey.isEmpty()) {
                result = callAiApi(systemPrompt, userPrompt, aiType, apiKey, apiUrl, model);
            } else {
                result = callAiApi(systemPrompt, userPrompt, "glm", "", "", "");
            }
            
            long duration = System.currentTimeMillis() - startTime;
            
            // 记录使用日志
            AiUsageLog usageLog = new AiUsageLog();
            usageLog.setTemplateId(template.getId());
            usageLog.setStyle(style);
            usageLog.setAiType(aiType);
            usageLog.setModel(model);
            usageLog.setQuestion(question);
            usageLog.setKnowledgePoints(knowledgePoints);
            usageLog.setPrompt(systemPrompt + "\n\n" + userPrompt);
            usageLog.setResponse(result);
            usageLog.setResponseLength(result.length());
            usageLog.setDurationMs((int) duration);
            usageLog.setSuccess(true);
            saveUsageLog(usageLog);
            
            return result;
        } catch (Exception e) {
            logger.error("AI调用失败", e);
            
            // 记录失败日志
            AiUsageLog usageLog = new AiUsageLog();
            usageLog.setTemplateId(template.getId());
            usageLog.setStyle(style);
            usageLog.setQuestion(question);
            usageLog.setSuccess(false);
            usageLog.setErrorMessage(e.getMessage());
            saveUsageLog(usageLog);
            
            throw new RuntimeException("AI分析失败: " + e.getMessage(), e);
        }
    }

    @Override
    public String buildPromptWithKnowledgeBase(AiPromptTemplate template, String question, String knowledgePoints) {
        String userPrompt = template.formatUserPrompt(question, knowledgePoints);
        
        // 如果有关联的知识库，追加到提示词中
        if (template.getKnowledgeBases() != null && !template.getKnowledgeBases().isEmpty()) {
            StringBuilder kbContext = new StringBuilder();
            kbContext.append("\n\n【参考知识】\n");
            for (AiKnowledgeBase kb : template.getKnowledgeBases()) {
                kbContext.append("## ").append(kb.getTitle()).append("\n");
                kbContext.append(kb.getContent()).append("\n");
                if (kb.getSourceName() != null && !kb.getSourceName().isEmpty()) {
                    kbContext.append("来源：").append(kb.getSourceName());
                    if (kb.getSourceAuthor() != null && !kb.getSourceAuthor().isEmpty()) {
                        kbContext.append(" - ").append(kb.getSourceAuthor());
                    }
                    kbContext.append("\n");
                }
                kbContext.append("\n");
            }
            userPrompt += kbContext.toString();
        }
        
        return userPrompt;
    }

    private String callAiApi(String systemPrompt, String userPrompt, String aiType, 
                            String apiKey, String apiUrl, String model) throws Exception {
        org.springframework.http.client.SimpleClientHttpRequestFactory factory = 
            new org.springframework.http.client.SimpleClientHttpRequestFactory();
        factory.setConnectTimeout(60000);
        factory.setReadTimeout(600000);
        org.springframework.web.client.RestTemplate restTemplate = 
            new org.springframework.web.client.RestTemplate(factory);
        org.springframework.http.HttpHeaders headers = new org.springframework.http.HttpHeaders();
        headers.set("Content-Type", "application/json");

        Map<String, Object> requestBody = new HashMap<>();

        if ("glm".equals(aiType) || apiKey.isEmpty()) {
            // 使用默认配置
            headers.set("Authorization", "Bearer " + apiKey);
            requestBody.put("model", model != null && !model.isEmpty() ? model : "glm-4.5-air");
            requestBody.put("messages", Arrays.asList(
                new HashMap<String, Object>() {{
                    put("role", "system");
                    put("content", systemPrompt);
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
                    put("content", systemPrompt);
                }},
                new HashMap<String, Object>() {{
                    put("role", "user");
                    put("content", userPrompt);
                }}
            ));
            requestBody.put("temperature", 0.7);
            requestBody.put("max_tokens", 4096);
        }

        org.springframework.http.HttpEntity<Map<String, Object>> entity = 
            new org.springframework.http.HttpEntity<>(requestBody, headers);
        
        org.springframework.http.ResponseEntity<String> response = 
            restTemplate.postForEntity(apiUrl, entity, String.class);

        ObjectMapper mapper = new ObjectMapper();
        com.fasterxml.jackson.databind.JsonNode rootNode = mapper.readTree(response.getBody());
        
        String resultContent = "";
        if ("glm".equals(aiType)) {
            com.fasterxml.jackson.databind.JsonNode choices = rootNode.path("choices");
            if (choices.isArray() && choices.size() > 0) {
                resultContent = choices.get(0).path("message").path("content").asText();
            }
        } else {
            resultContent = rootNode.path("choices").get(0).path("message").path("content").asText();
        }
        
        return resultContent;
    }

    private List<Integer> parseIds(String ids) {
        if (ids == null || ids.isEmpty()) {
            return new ArrayList<>();
        }
        return Arrays.stream(ids.split(","))
            .map(String::trim)
            .filter(s -> !s.isEmpty())
            .map(Integer::parseInt)
            .collect(Collectors.toList());
    }
}
