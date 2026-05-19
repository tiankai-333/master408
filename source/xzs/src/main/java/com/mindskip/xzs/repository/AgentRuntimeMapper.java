package com.mindskip.xzs.repository;

import com.mindskip.xzs.domain.ai.AgentRunRecord;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

@Mapper
public interface AgentRuntimeMapper {

    Map<String, Object> selectAgentByCode(@Param("code") String code);

    List<Map<String, Object>> selectSkillsByAgentCode(@Param("code") String code);

    int insertRunLog(AgentRunRecord record);
}
