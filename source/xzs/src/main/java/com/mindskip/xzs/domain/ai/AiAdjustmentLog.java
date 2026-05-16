package com.mindskip.xzs.domain.ai;

import java.util.Date;

public class AiAdjustmentLog {
    private Integer id;
    private Integer templateId;
    private String style;
    private String adjustmentType;
    private String beforeContent;
    private String afterContent;
    private String adjustmentReason;
    private String adjustmentDetails;
    private String testResult;
    private String testQuestion;
    private String testFeedback;
    private Integer rating;
    private String status;
    private Integer approverId;
    private Date approveTime;
    private String approveComment;
    private Integer createUser;
    private Date createTime;
    private String ipAddress;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getTemplateId() {
        return templateId;
    }

    public void setTemplateId(Integer templateId) {
        this.templateId = templateId;
    }

    public String getStyle() {
        return style;
    }

    public void setStyle(String style) {
        this.style = style;
    }

    public String getAdjustmentType() {
        return adjustmentType;
    }

    public void setAdjustmentType(String adjustmentType) {
        this.adjustmentType = adjustmentType;
    }

    public String getBeforeContent() {
        return beforeContent;
    }

    public void setBeforeContent(String beforeContent) {
        this.beforeContent = beforeContent;
    }

    public String getAfterContent() {
        return afterContent;
    }

    public void setAfterContent(String afterContent) {
        this.afterContent = afterContent;
    }

    public String getAdjustmentReason() {
        return adjustmentReason;
    }

    public void setAdjustmentReason(String adjustmentReason) {
        this.adjustmentReason = adjustmentReason;
    }

    public String getAdjustmentDetails() {
        return adjustmentDetails;
    }

    public void setAdjustmentDetails(String adjustmentDetails) {
        this.adjustmentDetails = adjustmentDetails;
    }

    public String getTestResult() {
        return testResult;
    }

    public void setTestResult(String testResult) {
        this.testResult = testResult;
    }

    public String getTestQuestion() {
        return testQuestion;
    }

    public void setTestQuestion(String testQuestion) {
        this.testQuestion = testQuestion;
    }

    public String getTestFeedback() {
        return testFeedback;
    }

    public void setTestFeedback(String testFeedback) {
        this.testFeedback = testFeedback;
    }

    public Integer getRating() {
        return rating;
    }

    public void setRating(Integer rating) {
        this.rating = rating;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Integer getApproverId() {
        return approverId;
    }

    public void setApproverId(Integer approverId) {
        this.approverId = approverId;
    }

    public Date getApproveTime() {
        return approveTime;
    }

    public void setApproveTime(Date approveTime) {
        this.approveTime = approveTime;
    }

    public String getApproveComment() {
        return approveComment;
    }

    public void setApproveComment(String approveComment) {
        this.approveComment = approveComment;
    }

    public Integer getCreateUser() {
        return createUser;
    }

    public void setCreateUser(Integer createUser) {
        this.createUser = createUser;
    }

    public Date getCreateTime() {
        return createTime;
    }

    public void setCreateTime(Date createTime) {
        this.createTime = createTime;
    }

    public String getIpAddress() {
        return ipAddress;
    }

    public void setIpAddress(String ipAddress) {
        this.ipAddress = ipAddress;
    }
}
