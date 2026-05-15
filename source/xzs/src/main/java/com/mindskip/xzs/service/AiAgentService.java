package com.mindskip.xzs.service;

import com.mindskip.xzs.domain.ai.AiPromptTemplate;
import com.mindskip.xzs.domain.ai.AiKnowledgeBase;
import com.mindskip.xzs.domain.ai.AiAdjustmentLog;
import com.mindskip.xzs.domain.ai.AiUsageLog;

import java.util.List;
import java.util.Map;

public interface AiAgentService {

    // ============ 模板管理 ============

    List<AiPromptTemplate> getAllTemplates();

    List<AiPromptTemplate> getEnabledTemplates();

    AiPromptTemplate getTemplateByStyle(String style);

    AiPromptTemplate getTemplateById(Integer id);

    AiPromptTemplate createTemplate(AiPromptTemplate template);

    AiPromptTemplate updateTemplate(Integer id, AiPromptTemplate template);

    void deleteTemplate(Integer id);

    AiPromptTemplate updateTemplateRating(Integer id, Integer rating);

    // ============ 知识库管理 ============

    List<AiKnowledgeBase> getAllKnowledgeBase();

    List<AiKnowledgeBase> getKnowledgeBaseByCategory(String category);

    List<AiKnowledgeBase> getKnowledgeBaseByDomain(String domain);

    List<AiKnowledgeBase> getKnowledgeBaseByIds(List<Integer> ids);

    AiKnowledgeBase getKnowledgeBaseById(Integer id);

    AiKnowledgeBase createKnowledgeBase(AiKnowledgeBase knowledgeBase);

    AiKnowledgeBase updateKnowledgeBase(Integer id, AiKnowledgeBase knowledgeBase);

    void deleteKnowledgeBase(Integer id);

    List<AiKnowledgeBase> searchKnowledgeBase(String keyword);

    // ============ 调整日志 ============

    List<AiAdjustmentLog> getAdjustmentLogs(Integer templateId, String style, int limit);

    AiAdjustmentLog createAdjustmentLog(AiAdjustmentLog log);

    AiAdjustmentLog testTemplate(Integer templateId, String question);

    AiAdjustmentLog approveAdjustment(Integer logId, Integer approverId, String comment);

    AiAdjustmentLog rejectAdjustment(Integer logId, Integer approverId, String comment);

    // ============ 使用记录 ============

    void saveUsageLog(AiUsageLog usageLog);

    List<AiUsageLog> getUsageLogs(Integer templateId, int limit);

    void updateUsageLogRating(Integer id, Integer rating, String feedback);

    Map<String, Object> getUsageStatistics();

    // ============ AI调用 ============

    String analyzeWithTemplate(String style, String question, String knowledgePoints, String aiType, String apiKey, String apiUrl, String model);

    String buildPromptWithKnowledgeBase(AiPromptTemplate template, String question, String knowledgePoints);
}
