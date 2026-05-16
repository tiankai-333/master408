package com.mindskip.xzs.repository;

import com.mindskip.xzs.domain.ai.AiKnowledgeBase;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface AiKnowledgeBaseMapper {

    List<AiKnowledgeBase> selectAll();

    List<AiKnowledgeBase> selectByIds(@Param("ids") List<Integer> ids);

    List<AiKnowledgeBase> selectByCategory(@Param("category") String category);

    List<AiKnowledgeBase> selectByDomain(@Param("domain") String domain);

    AiKnowledgeBase selectById(@Param("id") Integer id);

    List<AiKnowledgeBase> search(@Param("keyword") String keyword);

    int insert(AiKnowledgeBase knowledgeBase);

    int update(AiKnowledgeBase knowledgeBase);

    int deleteById(@Param("id") Integer id);
}
