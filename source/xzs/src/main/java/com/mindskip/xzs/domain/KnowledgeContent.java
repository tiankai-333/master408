package com.mindskip.xzs.domain;

import java.io.Serializable;
import java.util.Date;

public class KnowledgeContent implements Serializable {

    private static final long serialVersionUID = 1L;

    private Integer id;
    private Integer knowledgePointId;
    private String htmlRef;
    private String summaryText;
    private String sourceUrl;
    private String assetDir;
    private String metadata;
    private Date createTime;
    private Date updateTime;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getKnowledgePointId() {
        return knowledgePointId;
    }

    public void setKnowledgePointId(Integer knowledgePointId) {
        this.knowledgePointId = knowledgePointId;
    }

    public String getHtmlRef() {
        return htmlRef;
    }

    public void setHtmlRef(String htmlRef) {
        this.htmlRef = htmlRef == null ? null : htmlRef.trim();
    }

    public String getSummaryText() {
        return summaryText;
    }

    public void setSummaryText(String summaryText) {
        this.summaryText = summaryText == null ? null : summaryText.trim();
    }

    public String getSourceUrl() {
        return sourceUrl;
    }

    public void setSourceUrl(String sourceUrl) {
        this.sourceUrl = sourceUrl == null ? null : sourceUrl.trim();
    }

    public String getAssetDir() {
        return assetDir;
    }

    public void setAssetDir(String assetDir) {
        this.assetDir = assetDir == null ? null : assetDir.trim();
    }

    public String getMetadata() {
        return metadata;
    }

    public void setMetadata(String metadata) {
        this.metadata = metadata;
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
}
