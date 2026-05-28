package com.mindskip.xzs.repository;

import com.mindskip.xzs.domain.KnowledgeContent;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface KnowledgeContentMapper {

    KnowledgeContent findCurrentByKnowledgePointId(@Param("knowledgePointId") Integer knowledgePointId);
}
