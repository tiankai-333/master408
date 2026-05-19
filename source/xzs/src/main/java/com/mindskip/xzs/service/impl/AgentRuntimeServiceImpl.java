package com.mindskip.xzs.service.impl;

import com.mindskip.xzs.domain.ai.AgentRunRecord;
import com.mindskip.xzs.repository.AgentRuntimeMapper;
import com.mindskip.xzs.service.AgentRuntimeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
public class AgentRuntimeServiceImpl implements AgentRuntimeService {

    @Autowired
    private AgentRuntimeMapper agentRuntimeMapper;

    @Override
    public Map<String, Object> getAgent(String code) {
        return agentRuntimeMapper.selectAgentByCode(code);
    }

    @Override
    public List<Map<String, Object>> getAgentSkills(String code) {
        return agentRuntimeMapper.selectSkillsByAgentCode(code);
    }

    @Override
    public AgentRunRecord logRun(AgentRunRecord record) {
        if (record.getStatus() == null) {
            record.setStatus("success");
        }
        agentRuntimeMapper.insertRunLog(record);
        return record;
    }
}
