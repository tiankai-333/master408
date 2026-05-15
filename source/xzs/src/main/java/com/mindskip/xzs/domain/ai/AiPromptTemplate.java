package com.mindskip.xzs.domain.ai;

import java.util.Date;
import java.util.List;

public class AiPromptTemplate {
    private Integer id;
    private String style;
    private String name;
    private String description;
    private String icon;
    private String systemPrompt;
    private String userPromptTemplate;
    private String knowledgeBaseIds;
    private String referenceMaterials;
    private String variables;
    private String outputFormat;
    private Double temperature;
    private Integer maxTokens;
    private Boolean enabled;
    private Boolean isDefault;
    private Integer usageCount;
    private Integer ratingSum;
    private Integer ratingCount;
    private Integer createUser;
    private Date createTime;
    private Date updateTime;
    private Boolean deleted;

    // 非数据库字段
    private List<AiKnowledgeBase> knowledgeBases;
    private Double averageRating;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getStyle() {
        return style;
    }

    public void setStyle(String style) {
        this.style = style;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getIcon() {
        return icon;
    }

    public void setIcon(String icon) {
        this.icon = icon;
    }

    public String getSystemPrompt() {
        return systemPrompt;
    }

    public void setSystemPrompt(String systemPrompt) {
        this.systemPrompt = systemPrompt;
    }

    public String getUserPromptTemplate() {
        return userPromptTemplate;
    }

    public void setUserPromptTemplate(String userPromptTemplate) {
        this.userPromptTemplate = userPromptTemplate;
    }

    public String getKnowledgeBaseIds() {
        return knowledgeBaseIds;
    }

    public void setKnowledgeBaseIds(String knowledgeBaseIds) {
        this.knowledgeBaseIds = knowledgeBaseIds;
    }

    public String getReferenceMaterials() {
        return referenceMaterials;
    }

    public void setReferenceMaterials(String referenceMaterials) {
        this.referenceMaterials = referenceMaterials;
    }

    public String getVariables() {
        return variables;
    }

    public void setVariables(String variables) {
        this.variables = variables;
    }

    public String getOutputFormat() {
        return outputFormat;
    }

    public void setOutputFormat(String outputFormat) {
        this.outputFormat = outputFormat;
    }

    public Double getTemperature() {
        return temperature;
    }

    public void setTemperature(Double temperature) {
        this.temperature = temperature;
    }

    public Integer getMaxTokens() {
        return maxTokens;
    }

    public void setMaxTokens(Integer maxTokens) {
        this.maxTokens = maxTokens;
    }

    public Boolean getEnabled() {
        return enabled;
    }

    public void setEnabled(Boolean enabled) {
        this.enabled = enabled;
    }

    public Boolean getIsDefault() {
        return isDefault;
    }

    public void setIsDefault(Boolean isDefault) {
        this.isDefault = isDefault;
    }

    public Integer getUsageCount() {
        return usageCount;
    }

    public void setUsageCount(Integer usageCount) {
        this.usageCount = usageCount;
    }

    public Integer getRatingSum() {
        return ratingSum;
    }

    public void setRatingSum(Integer ratingSum) {
        this.ratingSum = ratingSum;
    }

    public Integer getRatingCount() {
        return ratingCount;
    }

    public void setRatingCount(Integer ratingCount) {
        this.ratingCount = ratingCount;
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

    public Date getUpdateTime() {
        return updateTime;
    }

    public void setUpdateTime(Date updateTime) {
        this.updateTime = updateTime;
    }

    public Boolean getDeleted() {
        return deleted;
    }

    public void setDeleted(Boolean deleted) {
        this.deleted = deleted;
    }

    public List<AiKnowledgeBase> getKnowledgeBases() {
        return knowledgeBases;
    }

    public void setKnowledgeBases(List<AiKnowledgeBase> knowledgeBases) {
        this.knowledgeBases = knowledgeBases;
    }

    public Double getAverageRating() {
        if (ratingCount != null && ratingCount > 0) {
            return (double) ratingSum / ratingCount;
        }
        return 0.0;
    }

    public void setAverageRating(Double averageRating) {
        this.averageRating = averageRating;
    }

    public String formatUserPrompt(String question, String knowledgePoints) {
        String prompt = userPromptTemplate;
        if (prompt != null && question != null) {
            prompt = prompt.replace("{question}", question);
        }
        if (prompt != null && knowledgePoints != null) {
            prompt = prompt.replace("{knowledge_points}", knowledgePoints);
        }
        return prompt;
    }
}
