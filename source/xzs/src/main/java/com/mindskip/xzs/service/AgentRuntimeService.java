package com.mindskip.xzs.service;

import com.mindskip.xzs.domain.ai.AgentRunRecord;

import java.util.List;
import java.util.Map;

public interface AgentRuntimeService {

    Map<String, Object> getAgent(String code);

    List<Map<String, Object>> getAgentSkills(String code);

    AgentRunRecord logRun(AgentRunRecord record);
}
