package com.mindskip.xzs.viewmodel.student.ai;

import java.util.List;

public class AiAgentPlanResponseVM {

    private String intent;
    private String status;
    private String title;
    private Integer questionCount;
    private Integer minutes;
    private Boolean preferMistakes;
    private String knowledgePoint;
    private List<String> fallbackKnowledgePoints;
    private List<Integer> candidateQuestionIds;
    private Boolean candidateEnough;
    private String reason;
    private String confirmText;
    private String toolCallJson;
    private Long runLogId;

    public String getIntent() { return intent; }
    public void setIntent(String intent) { this.intent = intent; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public Integer getQuestionCount() { return questionCount; }
    public void setQuestionCount(Integer questionCount) { this.questionCount = questionCount; }
    public Integer getMinutes() { return minutes; }
    public void setMinutes(Integer minutes) { this.minutes = minutes; }
    public Boolean getPreferMistakes() { return preferMistakes; }
    public void setPreferMistakes(Boolean preferMistakes) { this.preferMistakes = preferMistakes; }
    public String getKnowledgePoint() { return knowledgePoint; }
    public void setKnowledgePoint(String knowledgePoint) { this.knowledgePoint = knowledgePoint; }
    public List<String> getFallbackKnowledgePoints() { return fallbackKnowledgePoints; }
    public void setFallbackKnowledgePoints(List<String> fallbackKnowledgePoints) { this.fallbackKnowledgePoints = fallbackKnowledgePoints; }
    public List<Integer> getCandidateQuestionIds() { return candidateQuestionIds; }
    public void setCandidateQuestionIds(List<Integer> candidateQuestionIds) { this.candidateQuestionIds = candidateQuestionIds; }
    public Boolean getCandidateEnough() { return candidateEnough; }
    public void setCandidateEnough(Boolean candidateEnough) { this.candidateEnough = candidateEnough; }
    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }
    public String getConfirmText() { return confirmText; }
    public void setConfirmText(String confirmText) { this.confirmText = confirmText; }
    public String getToolCallJson() { return toolCallJson; }
    public void setToolCallJson(String toolCallJson) { this.toolCallJson = toolCallJson; }
    public Long getRunLogId() { return runLogId; }
    public void setRunLogId(Long runLogId) { this.runLogId = runLogId; }
}
