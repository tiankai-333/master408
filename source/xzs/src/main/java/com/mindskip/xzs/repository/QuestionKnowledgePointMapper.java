package com.mindskip.xzs.repository;

import com.mindskip.xzs.domain.QuestionKnowledgePoint;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface QuestionKnowledgePointMapper {

    List<QuestionKnowledgePoint> findByQuestionId(@Param("questionId") Integer questionId);

    List<QuestionKnowledgePoint> findByKnowledgePointId(@Param("knowledgePointId") Integer knowledgePointId);

    int insert(QuestionKnowledgePoint questionKnowledgePoint);

    int deleteByQuestionId(@Param("questionId") Integer questionId);

    int deleteByKnowledgePointId(@Param("knowledgePointId") Integer knowledgePointId);
}