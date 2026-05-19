package com.mindskip.xzs.domain.canonical;

import java.io.Serializable;
import java.util.Date;

public class QuestionContent implements Serializable {

    private static final long serialVersionUID = 1L;

    private Integer id;
    private Integer questionId;
    private Integer version;
    private String title;
    private String options;
    private String correctAnswer;
    private String analysis;
    private String titleText;
    private String analysisText;
    private String contentFormat;
    private Boolean hasImage;
    private Boolean hasCode;
    private Integer legacyTextContentId;
    private String sourceHash;
    private Boolean current;
    private Date createTime;
    private Date updateTime;

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }
    public Integer getQuestionId() { return questionId; }
    public void setQuestionId(Integer questionId) { this.questionId = questionId; }
    public Integer getVersion() { return version; }
    public void setVersion(Integer version) { this.version = version; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getOptions() { return options; }
    public void setOptions(String options) { this.options = options; }
    public String getCorrectAnswer() { return correctAnswer; }
    public void setCorrectAnswer(String correctAnswer) { this.correctAnswer = correctAnswer; }
    public String getAnalysis() { return analysis; }
    public void setAnalysis(String analysis) { this.analysis = analysis; }
    public String getTitleText() { return titleText; }
    public void setTitleText(String titleText) { this.titleText = titleText; }
    public String getAnalysisText() { return analysisText; }
    public void setAnalysisText(String analysisText) { this.analysisText = analysisText; }
    public String getContentFormat() { return contentFormat; }
    public void setContentFormat(String contentFormat) { this.contentFormat = contentFormat; }
    public Boolean getHasImage() { return hasImage; }
    public void setHasImage(Boolean hasImage) { this.hasImage = hasImage; }
    public Boolean getHasCode() { return hasCode; }
    public void setHasCode(Boolean hasCode) { this.hasCode = hasCode; }
    public Integer getLegacyTextContentId() { return legacyTextContentId; }
    public void setLegacyTextContentId(Integer legacyTextContentId) { this.legacyTextContentId = legacyTextContentId; }
    public String getSourceHash() { return sourceHash; }
    public void setSourceHash(String sourceHash) { this.sourceHash = sourceHash; }
    public Boolean getCurrent() { return current; }
    public void setCurrent(Boolean current) { this.current = current; }
    public Date getCreateTime() { return createTime; }
    public void setCreateTime(Date createTime) { this.createTime = createTime; }
    public Date getUpdateTime() { return updateTime; }
    public void setUpdateTime(Date updateTime) { this.updateTime = updateTime; }
}
