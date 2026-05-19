package com.mindskip.xzs.repository;

import com.mindskip.xzs.domain.ai.AiProviderConfig;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

@Mapper
public interface AiProviderConfigMapper {

    List<AiProviderConfig> selectAll();

    AiProviderConfig selectByProviderCode(@Param("providerCode") String providerCode);

    AiProviderConfig selectById(@Param("id") Integer id);

    int insert(AiProviderConfig config);

    int update(AiProviderConfig config);

    int updateTestResult(@Param("id") Integer id,
                         @Param("success") Boolean success,
                         @Param("message") String message);

    List<Map<String, Object>> selectUsageByProvider(@Param("days") Integer days);

    List<Map<String, Object>> selectUsageByDay(@Param("days") Integer days);

    Map<String, Object> selectUsageSummary(@Param("days") Integer days);
}
