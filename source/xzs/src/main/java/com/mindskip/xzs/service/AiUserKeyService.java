package com.mindskip.xzs.service;

import com.mindskip.xzs.domain.ai.AiUserKey;

import java.util.List;
import java.util.Map;

public interface AiUserKeyService {

    List<AiUserKey> listByUser(Integer userId);

    AiUserKey save(Integer userId, AiUserKey config, String plainApiKey);

    Map<String, Object> test(Integer id, Integer userId);

    void deleteById(Integer id, Integer userId);

    AiUserKey resolveBestEnabled(Integer userId);

    List<AiUserKey> listEnabledByUser(Integer userId);

    String decryptKey(String cipher);
}
