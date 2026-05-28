package com.mindskip.xzs.viewmodel.student.ai;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import java.util.List;

@JsonIgnoreProperties(ignoreUnknown = true)
public class AiAgentPlanRequestVM {

    private String message;
    private String contextKnowledgePoint;
    private String mode;
    private Integer subjectId;
    private Integer questionCount;
    private Integer minutes;
    private Boolean preferMistakes;
    private List<Integer> questionTypes;
    private List<Integer> excludeQuestionIds;
    private List<Integer> excludeSourceYears;

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
    public String getContextKnowledgePoint() { return contextKnowledgePoint; }
    public void setContextKnowledgePoint(String contextKnowledgePoint) { this.contextKnowledgePoint = contextKnowledgePoint; }
    public String getMode() { return mode; }
    public void setMode(String mode) { this.mode = mode; }
    public Integer getSubjectId() { return subjectId; }
    public void setSubjectId(Integer subjectId) { this.subjectId = subjectId; }
    public Integer getQuestionCount() { return questionCount; }
    public void setQuestionCount(Integer questionCount) { this.questionCount = questionCount; }
    public Integer getMinutes() { return minutes; }
    public void setMinutes(Integer minutes) { this.minutes = minutes; }
    public Boolean getPreferMistakes() { return preferMistakes; }
    public void setPreferMistakes(Boolean preferMistakes) { this.preferMistakes = preferMistakes; }
    public List<Integer> getQuestionTypes() { return questionTypes; }
    public void setQuestionTypes(List<Integer> questionTypes) { this.questionTypes = questionTypes; }
    public List<Integer> getExcludeQuestionIds() { return excludeQuestionIds; }
    public void setExcludeQuestionIds(List<Integer> excludeQuestionIds) { this.excludeQuestionIds = excludeQuestionIds; }
    public List<Integer> getExcludeSourceYears() { return excludeSourceYears; }
    public void setExcludeSourceYears(List<Integer> excludeSourceYears) { this.excludeSourceYears = excludeSourceYears; }
}
