package com.mindskip.xzs.ai;

import java.util.List;

public class PromptTemplate {
    private String name;
    private String description;
    private String style;
    private String systemPrompt;
    private String userPromptTemplate;
    private List<String> variables;
    private String outputFormat;

    public PromptTemplate() {
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

    public String getStyle() {
        return style;
    }

    public void setStyle(String style) {
        this.style = style;
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

    public List<String> getVariables() {
        return variables;
    }

    public void setVariables(List<String> variables) {
        this.variables = variables;
    }

    public String getOutputFormat() {
        return outputFormat;
    }

    public void setOutputFormat(String outputFormat) {
        this.outputFormat = outputFormat;
    }

    public String formatUserPrompt(String question, String knowledgePoints) {
        return formatUserPrompt(question, knowledgePoints, null);
    }

    public String formatUserPrompt(String question, String knowledgePoints, String referenceDocs) {
        String prompt = userPromptTemplate;
        prompt = prompt.replace("{question}", question != null ? question : "");
        
        String knowledgePointsBlock = "";
        if (knowledgePoints != null && !knowledgePoints.trim().isEmpty()) {
            knowledgePointsBlock = "**相关知识点**：\n" + knowledgePoints;
        }
        prompt = prompt.replace("{knowledge_points_block}", knowledgePointsBlock);
        prompt = prompt.replace("{knowledge_points}", knowledgePoints != null ? knowledgePoints : "");
        
        String referenceBlock = "";
        if (referenceDocs != null && !referenceDocs.trim().isEmpty()) {
            referenceBlock = "\n\n**以下内容来自题库中的相关题目，请参考这些内容确保你的答案准确无误，不要编造与参考答案矛盾的信息**：\n" + referenceDocs;
        }
        prompt = prompt.replace("{reference_docs}", referenceBlock);
        return prompt;
    }
}
