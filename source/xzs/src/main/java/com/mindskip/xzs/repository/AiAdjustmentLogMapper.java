package com.mindskip.xzs.repository;

import com.mindskip.xzs.domain.ai.AiAdjustmentLog;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface AiAdjustmentLogMapper {

    List<AiAdjustmentLog> selectLogs(@Param("templateId") Integer templateId, 
                                      @Param("style") String style, 
                                      @Param("limit") int limit);

    AiAdjustmentLog selectById(@Param("id") Integer id);

    int insert(AiAdjustmentLog log);

    int update(AiAdjustmentLog log);

    int deleteById(@Param("id") Integer id);
}
