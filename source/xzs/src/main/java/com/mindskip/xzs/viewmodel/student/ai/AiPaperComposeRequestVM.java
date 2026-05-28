package com.mindskip.xzs.viewmodel.student.ai;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import java.util.List;

@JsonIgnoreProperties(ignoreUnknown = true)
public class AiPaperComposeRequestVM {

    private String instruction;
    private Integer subjectId;
    private String knowledgePoint;
    private Integer sourceYear;
    private List<Integer> questionTypes;
    private List<Integer> questionIds;
    private List<Integer> excludeQuestionIds;
    private List<Integer> excludeSourceYears;
    private Boolean preferMistakes;
    private Integer questionCount;
    private Integer minutes;
    private String name;

    public String getInstruction() {
        return instruction;
    }

    public void setInstruction(String instruction) {
        this.instruction = instruction;
    }

    public Integer getSubjectId() {
        return subjectId;
    }

    public void setSubjectId(Integer subjectId) {
        this.subjectId = subjectId;
    }

    public String getKnowledgePoint() {
        return knowledgePoint;
    }

    public void setKnowledgePoint(String knowledgePoint) {
        this.knowledgePoint = knowledgePoint;
    }

    public Integer getSourceYear() {
        return sourceYear;
    }

    public void setSourceYear(Integer sourceYear) {
        this.sourceYear = sourceYear;
    }

    public List<Integer> getQuestionTypes() {
        return questionTypes;
    }

    public void setQuestionTypes(List<Integer> questionTypes) {
        this.questionTypes = questionTypes;
    }

    public List<Integer> getQuestionIds() {
        return questionIds;
    }

    public void setQuestionIds(List<Integer> questionIds) {
        this.questionIds = questionIds;
    }

    public List<Integer> getExcludeQuestionIds() {
        return excludeQuestionIds;
    }

    public void setExcludeQuestionIds(List<Integer> excludeQuestionIds) {
        this.excludeQuestionIds = excludeQuestionIds;
    }

    public List<Integer> getExcludeSourceYears() {
        return excludeSourceYears;
    }

    public void setExcludeSourceYears(List<Integer> excludeSourceYears) {
        this.excludeSourceYears = excludeSourceYears;
    }

    public Boolean getPreferMistakes() {
        return preferMistakes;
    }

    public void setPreferMistakes(Boolean preferMistakes) {
        this.preferMistakes = preferMistakes;
    }

    public Integer getQuestionCount() {
        return questionCount;
    }

    public void setQuestionCount(Integer questionCount) {
        this.questionCount = questionCount;
    }

    public Integer getMinutes() {
        return minutes;
    }

    public void setMinutes(Integer minutes) {
        this.minutes = minutes;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }
}
