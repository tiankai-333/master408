package com.mindskip.xzs.viewmodel.student.ai;

import java.util.List;

public class AiPaperComposeResponseVM {

    private Integer paperId;
    private String paperName;
    private String url;
    private Integer questionCount;
    private Integer minutes;
    private List<Integer> questionIds;
    private String strategy;

    public Integer getPaperId() {
        return paperId;
    }

    public void setPaperId(Integer paperId) {
        this.paperId = paperId;
    }

    public String getPaperName() {
        return paperName;
    }

    public void setPaperName(String paperName) {
        this.paperName = paperName;
    }

    public String getUrl() {
        return url;
    }

    public void setUrl(String url) {
        this.url = url;
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

    public List<Integer> getQuestionIds() {
        return questionIds;
    }

    public void setQuestionIds(List<Integer> questionIds) {
        this.questionIds = questionIds;
    }

    public String getStrategy() {
        return strategy;
    }

    public void setStrategy(String strategy) {
        this.strategy = strategy;
    }

}
