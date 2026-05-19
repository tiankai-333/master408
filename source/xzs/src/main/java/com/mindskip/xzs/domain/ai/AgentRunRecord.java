package com.mindskip.xzs.domain.ai;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;

public class AgentRunRecord implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long id;
    private Integer agentId;
    private Integer skillId;
    private Integer userId;
    private String sessionId;
    private String requestText;
    private String responseText;
    private Long retrievalLogId;
    private String toolCallJson;
    private String modelName;
    private Integer promptTokens;
    private Integer completionTokens;
    private Integer latencyMs;
    private BigDecimal costAmount;
    private String status;
    private String errorMessage;
    private Date createTime;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Integer getAgentId() { return agentId; }
    public void setAgentId(Integer agentId) { this.agentId = agentId; }
    public Integer getSkillId() { return skillId; }
    public void setSkillId(Integer skillId) { this.skillId = skillId; }
    public Integer getUserId() { return userId; }
    public void setUserId(Integer userId) { this.userId = userId; }
    public String getSessionId() { return sessionId; }
    public void setSessionId(String sessionId) { this.sessionId = sessionId; }
    public String getRequestText() { return requestText; }
    public void setRequestText(String requestText) { this.requestText = requestText; }
    public String getResponseText() { return responseText; }
    public void setResponseText(String responseText) { this.responseText = responseText; }
    public Long getRetrievalLogId() { return retrievalLogId; }
    public void setRetrievalLogId(Long retrievalLogId) { this.retrievalLogId = retrievalLogId; }
    public String getToolCallJson() { return toolCallJson; }
    public void setToolCallJson(String toolCallJson) { this.toolCallJson = toolCallJson; }
    public String getModelName() { return modelName; }
    public void setModelName(String modelName) { this.modelName = modelName; }
    public Integer getPromptTokens() { return promptTokens; }
    public void setPromptTokens(Integer promptTokens) { this.promptTokens = promptTokens; }
    public Integer getCompletionTokens() { return completionTokens; }
    public void setCompletionTokens(Integer completionTokens) { this.completionTokens = completionTokens; }
    public Integer getLatencyMs() { return latencyMs; }
    public void setLatencyMs(Integer latencyMs) { this.latencyMs = latencyMs; }
    public BigDecimal getCostAmount() { return costAmount; }
    public void setCostAmount(BigDecimal costAmount) { this.costAmount = costAmount; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getErrorMessage() { return errorMessage; }
    public void setErrorMessage(String errorMessage) { this.errorMessage = errorMessage; }
    public Date getCreateTime() { return createTime; }
    public void setCreateTime(Date createTime) { this.createTime = createTime; }
}
