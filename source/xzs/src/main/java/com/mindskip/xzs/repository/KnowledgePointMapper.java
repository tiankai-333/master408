package com.mindskip.xzs.repository;

import com.mindskip.xzs.domain.KnowledgePoint;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface KnowledgePointMapper {

    List<KnowledgePoint> findAll();

    List<KnowledgePoint> findBySubjectId(@Param("subjectId") Integer subjectId);

    List<KnowledgePoint> findByParentId(@Param("parentId") Integer parentId);

    KnowledgePoint findById(@Param("id") Integer id);

    int insert(KnowledgePoint knowledgePoint);

    int update(KnowledgePoint knowledgePoint);

    int deleteById(@Param("id") Integer id);
}