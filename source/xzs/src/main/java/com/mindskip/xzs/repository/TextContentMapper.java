package com.mindskip.xzs.repository;

import com.mindskip.xzs.domain.TextContent;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface TextContentMapper extends BaseMapper<TextContent> {

    List<TextContent> selectAllWithEmbedding();
}
