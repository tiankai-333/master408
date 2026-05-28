package com.mindskip.xzs.viewmodel.student.ai;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import java.util.List;

@JsonIgnoreProperties(ignoreUnknown = true)
public class AiAgentConfirmRequestVM {

    private String title;
    private Integer subjectId;
    private String knowledgePoint;
    private Integer questionCount;
    private Integer minutes;
    private Boolean preferMistakes;
    private List<Integer> questionIds;
    private Long runLogId;

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public Integer getSubjectId() { return subjectId; }
    public void setSubjectId(Integer subjectId) { this.subjectId = subjectId; }
    public String getKnowledgePoint() { return knowledgePoint; }
    public void setKnowledgePoint(String knowledgePoint) { this.knowledgePoint = knowledgePoint; }
    public Integer getQuestionCount() { return questionCount; }
    public void setQuestionCount(Integer questionCount) { this.questionCount = questionCount; }
    public Integer getMinutes() { return minutes; }
    public void setMinutes(Integer minutes) { this.minutes = minutes; }
    public Boolean getPreferMistakes() { return preferMistakes; }
    public void setPreferMistakes(Boolean preferMistakes) { this.preferMistakes = preferMistakes; }
    public List<Integer> getQuestionIds() { return questionIds; }
    public void setQuestionIds(List<Integer> questionIds) { this.questionIds = questionIds; }
    public Long getRunLogId() { return runLogId; }
    public void setRunLogId(Long runLogId) { this.runLogId = runLogId; }
}
