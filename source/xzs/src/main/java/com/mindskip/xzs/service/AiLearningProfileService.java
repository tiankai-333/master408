package com.mindskip.xzs.service;

public interface AiLearningProfileService {

    String buildProfileSummary(Integer userId);

    String buildFeedbackNotes(Integer userId, String style);

    void recordAiAnalyze(Integer userId, String style, Integer usageLogId, String question, String response);

    void saveSkillFeedback(Integer userId, Integer usageLogId, String style, Integer rating, String feedback);
}
