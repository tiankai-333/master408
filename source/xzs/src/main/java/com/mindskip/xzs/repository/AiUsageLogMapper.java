package com.mindskip.xzs.repository;

import com.mindskip.xzs.domain.ai.AiUsageLog;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

@Mapper
public interface AiUsageLogMapper {

    List<AiUsageLog> selectByTemplateId(@Param("templateId") Integer templateId, @Param("limit") int limit);

    AiUsageLog selectById(@Param("id") Integer id);

    int insert(AiUsageLog usageLog);

    int update(AiUsageLog usageLog);

    int deleteById(@Param("id") Integer id);

    int countTotal();

    double countSuccessRate();

    List<Map<String, Object>> getTopStyles(@Param("limit") int limit);
}
