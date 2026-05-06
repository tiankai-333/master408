package com.mindskip.xzs.service;

import java.util.List;
import java.util.Map;

public interface KnowledgeGraphService {

    /**
     * 获取知识图谱数据
     * @param subjectId 学科ID，可选
     * @return 知识图谱数据
     */
    Map<String, Object> getKnowledgeGraph(Integer subjectId);

    /**
     * 获取知识点详情
     * @param knowledgePointId 知识点ID
     * @return 知识点详情及关联信息
     */
    Map<String, Object> getKnowledgePointDetail(Integer knowledgePointId);

    /**
     * 获取题目关联的知识点
     * @param questionId 题目ID
     * @return 知识点列表
     */
    List<Map<String, Object>> getQuestionKnowledgePoints(Integer questionId);

    /**
     * 获取知识点关联的题目
     * @param knowledgePointId 知识点ID
     * @param limit 返回数量限制
     * @return 题目列表
     */
    List<Map<String, Object>> getKnowledgePointQuestions(Integer knowledgePointId, Integer limit);
}