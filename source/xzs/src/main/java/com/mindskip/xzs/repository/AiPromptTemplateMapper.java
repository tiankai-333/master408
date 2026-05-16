package com.mindskip.xzs.repository;

import com.mindskip.xzs.domain.ai.AiPromptTemplate;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface AiPromptTemplateMapper {

    List<AiPromptTemplate> selectAll();

    List<AiPromptTemplate> selectEnabled();

    AiPromptTemplate selectById(@Param("id") Integer id);

    AiPromptTemplate selectByStyle(@Param("style") String style);

    int insert(AiPromptTemplate template);

    int update(AiPromptTemplate template);

    int deleteById(@Param("id") Integer id);

    int incrementUsageCount(@Param("id") Integer id);
}
