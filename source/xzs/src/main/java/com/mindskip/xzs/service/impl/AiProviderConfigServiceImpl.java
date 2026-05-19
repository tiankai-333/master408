package com.mindskip.xzs.service.impl;

import com.mindskip.xzs.domain.ai.AiProviderConfig;
import com.mindskip.xzs.repository.AiProviderConfigMapper;
import com.mindskip.xzs.service.AiProviderConfigService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import javax.crypto.Cipher;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.*;

@Service
public class AiProviderConfigServiceImpl implements AiProviderConfigService {

    private static final int GCM_TAG_LENGTH = 128;
    private static final int GCM_IV_LENGTH = 12;

    @Autowired
    private AiProviderConfigMapper mapper;

    private final RestTemplate restTemplate = new RestTemplate();
    private final SecureRandom secureRandom = new SecureRandom();

    @Value("${ai.secret.master-key:${system.pwdKey.privateKey:408MasterLocalSecret}}")
    private String masterKey;

    @Override
    public List<AiProviderConfig> listSafe() {
        List<AiProviderConfig> configs = mapper.selectAll();
        for (AiProviderConfig config : configs) {
            hideSecret(config);
        }
        return configs;
    }

    @Override
    public AiProviderConfig save(AiProviderConfig config, String plainApiKey) {
        normalizeDefaults(config);
        if (plainApiKey != null && !plainApiKey.trim().isEmpty()) {
            config.setApiKeyCipher(encrypt(plainApiKey.trim()));
            config.setApiKeyMask(mask(plainApiKey.trim()));
        }
        if (config.getPriority() == null) {
            config.setPriority(100);
        }
        if (config.getEnabled() == null) {
            config.setEnabled(false);
        }
        AiProviderConfig exists = config.getId() == null ? mapper.selectByProviderCode(config.getProviderCode()) : mapper.selectById(config.getId());
        if (exists == null) {
            mapper.insert(config);
        } else {
            config.setId(exists.getId());
            mapper.update(config);
        }
        AiProviderConfig saved = mapper.selectById(config.getId());
        hideSecret(saved);
        return saved;
    }

    private void normalizeDefaults(AiProviderConfig config) {
        if (config == null || config.getProviderCode() == null) {
            return;
        }
        String providerCode = config.getProviderCode().trim().toLowerCase();
        config.setProviderCode(providerCode);
        if ("zhipu".equals(providerCode)) {
            if (isBlank(config.getApiBaseUrl())) {
                config.setApiBaseUrl("https://open.bigmodel.cn/api/paas/v4");
            }
            if (isBlank(config.getChatModel())) {
                config.setChatModel("glm-4.5-air");
            }
            if (isBlank(config.getEmbeddingModel())) {
                config.setEmbeddingModel("embedding-2");
            }
        } else if ("openai".equals(providerCode)) {
            if (isBlank(config.getApiBaseUrl())) {
                config.setApiBaseUrl("https://api.openai.com/v1");
            }
            if (isBlank(config.getEmbeddingModel())) {
                config.setEmbeddingModel("text-embedding-3-small");
            }
        } else if ("deepseek".equals(providerCode)) {
            if (isBlank(config.getApiBaseUrl())) {
                config.setApiBaseUrl("https://api.deepseek.com");
            }
        }
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

    @Override
    public Map<String, Object> test(Integer id) {
        AiProviderConfig config = mapper.selectById(id);
        Map<String, Object> result = new HashMap<>();
        if (config == null) {
            result.put("success", false);
            result.put("message", "配置不存在");
            return result;
        }
        try {
            String apiKey = decrypt(config.getApiKeyCipher());
            if (apiKey == null || apiKey.trim().isEmpty()) {
                throw new IllegalStateException("请先保存 API Key");
            }
            testProvider(config, apiKey);
            mapper.updateTestResult(id, true, "连接成功");
            result.put("success", true);
            result.put("message", "连接成功");
        } catch (Exception e) {
            String message = e.getMessage() == null ? e.getClass().getSimpleName() : e.getMessage();
            if (message.length() > 1000) {
                message = message.substring(0, 1000);
            }
            mapper.updateTestResult(id, false, message);
            result.put("success", false);
            result.put("message", message);
        }
        return result;
    }

    @Override
    public Map<String, Object> usage(Integer days) {
        int safeDays = days == null || days <= 0 ? 30 : Math.min(days, 365);
        Map<String, Object> result = new HashMap<>();
        result.put("days", safeDays);
        result.put("summary", mapper.selectUsageSummary(safeDays));
        result.put("byProvider", mapper.selectUsageByProvider(safeDays));
        result.put("byDay", mapper.selectUsageByDay(safeDays));
        return result;
    }

    @Override
    public String resolveApiKey(String providerCode) {
        AiProviderConfig config = mapper.selectByProviderCode(providerCode);
        if (config == null || !Boolean.TRUE.equals(config.getEnabled())) {
            return null;
        }
        return decrypt(config.getApiKeyCipher());
    }

    @Override
    public AiProviderConfig getEnabled(String providerCode) {
        AiProviderConfig config = mapper.selectByProviderCode(providerCode);
        if (config == null || !Boolean.TRUE.equals(config.getEnabled())) {
            return null;
        }
        return config;
    }

    @Override
    public AiProviderConfig getFirstEnabled() {
        List<AiProviderConfig> configs = mapper.selectAll();
        for (AiProviderConfig config : configs) {
            if (Boolean.TRUE.equals(config.getEnabled())) {
                return config;
            }
        }
        return null;
    }

    private void testProvider(AiProviderConfig config, String apiKey) {
        String provider = config.getProviderCode() == null ? "" : config.getProviderCode().toLowerCase();
        if ("deepseek".equals(provider)) {
            get(config.getApiBaseUrl(), "/models", apiKey);
        } else if ("openai".equals(provider)) {
            get(config.getApiBaseUrl(), "/models", apiKey);
        } else if ("zhipu".equals(provider)) {
            postEmbedding(config.getApiBaseUrl(), apiKey, config.getEmbeddingModel());
        } else {
            get(config.getApiBaseUrl(), "/models", apiKey);
        }
    }

    private void get(String baseUrl, String path, String apiKey) {
        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", "Bearer " + apiKey);
        HttpEntity<Void> entity = new HttpEntity<>(headers);
        restTemplate.exchange(endpoint(baseUrl, path), HttpMethod.GET, entity, String.class);
    }

    private void postEmbedding(String baseUrl, String apiKey, String model) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.set("Authorization", "Bearer " + apiKey);
        Map<String, Object> body = new HashMap<>();
        body.put("model", model == null || model.trim().isEmpty() ? "embedding-2" : model);
        body.put("input", "connection test");
        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(body, headers);
        restTemplate.postForEntity(endpoint(baseUrl, "/embeddings"), entity, String.class);
    }

    private String endpoint(String baseUrl, String path) {
        String base = baseUrl == null || baseUrl.trim().isEmpty() ? "" : baseUrl.trim().replaceAll("/+$", "");
        return base + path;
    }

    private void hideSecret(AiProviderConfig config) {
        if (config != null) {
            config.setApiKeyCipher(null);
        }
    }

    private String mask(String key) {
        if (key.length() <= 8) {
            return "****";
        }
        return key.substring(0, 4) + "****" + key.substring(key.length() - 4);
    }

    private String encrypt(String plainText) {
        try {
            byte[] iv = new byte[GCM_IV_LENGTH];
            secureRandom.nextBytes(iv);
            Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding");
            cipher.init(Cipher.ENCRYPT_MODE, aesKey(), new GCMParameterSpec(GCM_TAG_LENGTH, iv));
            byte[] cipherText = cipher.doFinal(plainText.getBytes(StandardCharsets.UTF_8));
            byte[] all = new byte[iv.length + cipherText.length];
            System.arraycopy(iv, 0, all, 0, iv.length);
            System.arraycopy(cipherText, 0, all, iv.length, cipherText.length);
            return Base64.getEncoder().encodeToString(all);
        } catch (Exception e) {
            throw new RuntimeException("API Key 加密失败", e);
        }
    }

    private String decrypt(String cipherText) {
        if (cipherText == null || cipherText.trim().isEmpty()) {
            return null;
        }
        try {
            byte[] all = Base64.getDecoder().decode(cipherText);
            byte[] iv = Arrays.copyOfRange(all, 0, GCM_IV_LENGTH);
            byte[] payload = Arrays.copyOfRange(all, GCM_IV_LENGTH, all.length);
            Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding");
            cipher.init(Cipher.DECRYPT_MODE, aesKey(), new GCMParameterSpec(GCM_TAG_LENGTH, iv));
            return new String(cipher.doFinal(payload), StandardCharsets.UTF_8);
        } catch (Exception e) {
            throw new RuntimeException("API Key 解密失败，请检查 ai.secret.master-key 是否变化");
        }
    }

    private SecretKeySpec aesKey() throws Exception {
        MessageDigest digest = MessageDigest.getInstance("SHA-256");
        byte[] key = digest.digest(masterKey.getBytes(StandardCharsets.UTF_8));
        return new SecretKeySpec(key, "AES");
    }
}
