package com.mindskip.xzs.viewmodel.student.ai;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import java.util.List;

@JsonIgnoreProperties(ignoreUnknown = true)
public class AiWorkbenchKnowledgePointVM {

    private Integer id;
    private String name;
    private String summary;
    private String description;
    private String htmlRef;
    private String sourceUrl;
    private List<Integer> relatedQuestionIds;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getSummary() {
        return summary;
    }

    public void setSummary(String summary) {
        this.summary = summary;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getHtmlRef() {
        return htmlRef;
    }

    public void setHtmlRef(String htmlRef) {
        this.htmlRef = htmlRef;
    }

    public String getSourceUrl() {
        return sourceUrl;
    }

    public void setSourceUrl(String sourceUrl) {
        this.sourceUrl = sourceUrl;
    }

    public List<Integer> getRelatedQuestionIds() {
        return relatedQuestionIds;
    }

    public void setRelatedQuestionIds(List<Integer> relatedQuestionIds) {
        this.relatedQuestionIds = relatedQuestionIds;
    }
}
