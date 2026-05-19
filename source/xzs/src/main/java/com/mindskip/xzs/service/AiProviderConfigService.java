package com.mindskip.xzs.service;

import com.mindskip.xzs.domain.ai.AiProviderConfig;

import java.util.List;
import java.util.Map;

public interface AiProviderConfigService {

    List<AiProviderConfig> listSafe();

    AiProviderConfig save(AiProviderConfig config, String plainApiKey);

    Map<String, Object> test(Integer id);

    Map<String, Object> usage(Integer days);

    String resolveApiKey(String providerCode);

    AiProviderConfig getEnabled(String providerCode);

    AiProviderConfig getFirstEnabled();
}
