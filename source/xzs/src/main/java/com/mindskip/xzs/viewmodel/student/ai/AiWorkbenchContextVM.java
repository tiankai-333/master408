package com.mindskip.xzs.viewmodel.student.ai;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import java.util.Map;

@JsonIgnoreProperties(ignoreUnknown = true)
public class AiWorkbenchContextVM {

    private String contextType;
    private Integer subjectId;
    private String subjectName;
    private AiWorkbenchQuestionVM question;
    private AiWorkbenchKnowledgePointVM knowledgePoint;
    private AiWorkbenchAnswerRecordVM answerRecord;
    private String pastedText;
    private Map<String, Object> userStats;

    public String getContextType() {
        return contextType;
    }

    public void setContextType(String contextType) {
        this.contextType = contextType;
    }

    public Integer getSubjectId() {
        return subjectId;
    }

    public void setSubjectId(Integer subjectId) {
        this.subjectId = subjectId;
    }

    public String getSubjectName() {
        return subjectName;
    }

    public void setSubjectName(String subjectName) {
        this.subjectName = subjectName;
    }

    public AiWorkbenchQuestionVM getQuestion() {
        return question;
    }

    public void setQuestion(AiWorkbenchQuestionVM question) {
        this.question = question;
    }

    public AiWorkbenchKnowledgePointVM getKnowledgePoint() {
        return knowledgePoint;
    }

    public void setKnowledgePoint(AiWorkbenchKnowledgePointVM knowledgePoint) {
        this.knowledgePoint = knowledgePoint;
    }

    public AiWorkbenchAnswerRecordVM getAnswerRecord() {
        return answerRecord;
    }

    public void setAnswerRecord(AiWorkbenchAnswerRecordVM answerRecord) {
        this.answerRecord = answerRecord;
    }

    public String getPastedText() {
        return pastedText;
    }

    public void setPastedText(String pastedText) {
        this.pastedText = pastedText;
    }

    public Map<String, Object> getUserStats() {
        return userStats;
    }

    public void setUserStats(Map<String, Object> userStats) {
        this.userStats = userStats;
    }
}
