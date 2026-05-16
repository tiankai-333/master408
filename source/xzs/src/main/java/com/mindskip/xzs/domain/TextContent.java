package com.mindskip.xzs.domain;

import java.io.Serializable;
import java.util.Date;

public class TextContent implements Serializable {

    private static final long serialVersionUID = -1279530310964668131L;

    public TextContent(){

    }

    public TextContent(String content, Date createTime) {
        this.content = content;
        this.createTime = createTime;
    }

    private Integer id;

    /**
     * 内容(Json)
     */
    private String content;

    /**
     * 创建时间
     */
    private Date createTime;

    /**
     * 向量嵌入(Embedding JSON)
     */
    private String embedding;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content == null ? null : content.trim();
    }

    public Date getCreateTime() {
        return createTime;
    }

    public void setCreateTime(Date createTime) {
        this.createTime = createTime;
    }

    public String getEmbedding() {
        return embedding;
    }

    public void setEmbedding(String embedding) {
        this.embedding = embedding;
    }
}
