package com.mindskip.xzs.domain.ai;

import java.io.Serializable;
import java.util.Date;

public class AiProviderConfig implements Serializable {

    private static final long serialVersionUID = 1L;

    private Integer id;
    private String providerCode;
    private String providerName;
    private String apiBaseUrl;
    private String chatModel;
    private String embeddingModel;
    private String apiKeyCipher;
    private String apiKeyMask;
    private Boolean enabled;
    private Integer priority;
    private Boolean lastTestSuccess;
    private String lastTestMessage;
    private Date lastTestTime;
    private Date createTime;
    private Date updateTime;

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }
    public String getProviderCode() { return providerCode; }
    public void setProviderCode(String providerCode) { this.providerCode = providerCode; }
    public String getProviderName() { return providerName; }
    public void setProviderName(String providerName) { this.providerName = providerName; }
    public String getApiBaseUrl() { return apiBaseUrl; }
    public void setApiBaseUrl(String apiBaseUrl) { this.apiBaseUrl = apiBaseUrl; }
    public String getChatModel() { return chatModel; }
    public void setChatModel(String chatModel) { this.chatModel = chatModel; }
    public String getEmbeddingModel() { return embeddingModel; }
    public void setEmbeddingModel(String embeddingModel) { this.embeddingModel = embeddingModel; }
    public String getApiKeyCipher() { return apiKeyCipher; }
    public void setApiKeyCipher(String apiKeyCipher) { this.apiKeyCipher = apiKeyCipher; }
    public String getApiKeyMask() { return apiKeyMask; }
    public void setApiKeyMask(String apiKeyMask) { this.apiKeyMask = apiKeyMask; }
    public Boolean getEnabled() { return enabled; }
    public void setEnabled(Boolean enabled) { this.enabled = enabled; }
    public Integer getPriority() { return priority; }
    public void setPriority(Integer priority) { this.priority = priority; }
    public Boolean getLastTestSuccess() { return lastTestSuccess; }
    public void setLastTestSuccess(Boolean lastTestSuccess) { this.lastTestSuccess = lastTestSuccess; }
    public String getLastTestMessage() { return lastTestMessage; }
    public void setLastTestMessage(String lastTestMessage) { this.lastTestMessage = lastTestMessage; }
    public Date getLastTestTime() { return lastTestTime; }
    public void setLastTestTime(Date lastTestTime) { this.lastTestTime = lastTestTime; }
    public Date getCreateTime() { return createTime; }
    public void setCreateTime(Date createTime) { this.createTime = createTime; }
    public Date getUpdateTime() { return updateTime; }
    public void setUpdateTime(Date updateTime) { this.updateTime = updateTime; }
}
