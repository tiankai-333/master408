package com.mindskip.xzs.domain;

import java.io.Serializable;

public class QuestionKnowledgePoint implements Serializable {

    private static final long serialVersionUID = 1L;

    private Integer id;

    /**
     * 题目ID
     */
    private Integer questionId;

    /**
     * 知识点ID
     */
    private Integer knowledgePointId;

    /**
     * 关联强度（1-10）
     */
    private Integer relevance;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getQuestionId() {
        return questionId;
    }

    public void setQuestionId(Integer questionId) {
        this.questionId = questionId;
    }

    public Integer getKnowledgePointId() {
        return knowledgePointId;
    }

    public void setKnowledgePointId(Integer knowledgePointId) {
        this.knowledgePointId = knowledgePointId;
    }

    public Integer getRelevance() {
        return relevance;
    }

    public void setRelevance(Integer relevance) {
        this.relevance = relevance;
    }
}