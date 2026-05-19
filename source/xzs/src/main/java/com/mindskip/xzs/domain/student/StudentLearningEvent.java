package com.mindskip.xzs.domain.student;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;

public class StudentLearningEvent implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long id;
    private Integer userId;
    private String eventType;
    private String targetType;
    private Integer targetId;
    private Integer questionId;
    private Integer knowledgePointId;
    private Integer examPaperAnswerId;
    private Integer customerAnswerId;
    private Boolean correct;
    private BigDecimal scoreRate;
    private Integer durationSeconds;
    private String summary;
    private String metadata;
    private Date createTime;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Integer getUserId() { return userId; }
    public void setUserId(Integer userId) { this.userId = userId; }
    public String getEventType() { return eventType; }
    public void setEventType(String eventType) { this.eventType = eventType; }
    public String getTargetType() { return targetType; }
    public void setTargetType(String targetType) { this.targetType = targetType; }
    public Integer getTargetId() { return targetId; }
    public void setTargetId(Integer targetId) { this.targetId = targetId; }
    public Integer getQuestionId() { return questionId; }
    public void setQuestionId(Integer questionId) { this.questionId = questionId; }
    public Integer getKnowledgePointId() { return knowledgePointId; }
    public void setKnowledgePointId(Integer knowledgePointId) { this.knowledgePointId = knowledgePointId; }
    public Integer getExamPaperAnswerId() { return examPaperAnswerId; }
    public void setExamPaperAnswerId(Integer examPaperAnswerId) { this.examPaperAnswerId = examPaperAnswerId; }
    public Integer getCustomerAnswerId() { return customerAnswerId; }
    public void setCustomerAnswerId(Integer customerAnswerId) { this.customerAnswerId = customerAnswerId; }
    public Boolean getCorrect() { return correct; }
    public void setCorrect(Boolean correct) { this.correct = correct; }
    public BigDecimal getScoreRate() { return scoreRate; }
    public void setScoreRate(BigDecimal scoreRate) { this.scoreRate = scoreRate; }
    public Integer getDurationSeconds() { return durationSeconds; }
    public void setDurationSeconds(Integer durationSeconds) { this.durationSeconds = durationSeconds; }
    public String getSummary() { return summary; }
    public void setSummary(String summary) { this.summary = summary; }
    public String getMetadata() { return metadata; }
    public void setMetadata(String metadata) { this.metadata = metadata; }
    public Date getCreateTime() { return createTime; }
    public void setCreateTime(Date createTime) { this.createTime = createTime; }
}
