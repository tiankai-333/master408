package com.mindskip.xzs.service.impl;

import com.mindskip.xzs.domain.ai.AiUserKey;
import com.mindskip.xzs.repository.AiUserKeyMapper;
import com.mindskip.xzs.service.AiUserKeyService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
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
public class AiUserKeyServiceImpl implements AiUserKeyService {

    private static final Logger logger = LoggerFactory.getLogger(AiUserKeyServiceImpl.class);

    private static final int GCM_TAG_LENGTH = 128;
    private static final int GCM_IV_LENGTH = 12;

    @Autowired
    private AiUserKeyMapper mapper;

    private final RestTemplate restTemplate = new RestTemplate();
    private final SecureRandom secureRandom = new SecureRandom();

    @Value("${ai.secret.master-key:${system.pwdKey.privateKey:408MasterLocalSecret}}")
    private String masterKey;

    @Override
    public List<AiUserKey> listByUser(Integer userId) {
        List<AiUserKey> keys = mapper.selectByUserId(userId);
        for (AiUserKey key : keys) {
            key.setApiKeyCipher(null);
        }
        return keys;
    }

    @Override
    public AiUserKey save(Integer userId, AiUserKey config, String plainApiKey) {
        config.setUserId(userId);
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
        if (config.getId() == null) {
            mapper.insert(config);
        } else {
            mapper.update(config);
        }
        AiUserKey saved = mapper.selectById(config.getId());
        saved.setApiKeyCipher(null);
        return saved;
    }

    @Override
    public Map<String, Object> test(Integer id, Integer userId) {
        AiUserKey config = mapper.selectById(id);
        Map<String, Object> result = new HashMap<>();
        if (config == null || !userId.equals(config.getUserId())) {
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
    public void deleteById(Integer id, Integer userId) {
        AiUserKey config = mapper.selectById(id);
        if (config != null && userId.equals(config.getUserId())) {
            mapper.deleteById(id);
        }
    }

    @Override
    public AiUserKey resolveBestEnabled(Integer userId) {
        List<AiUserKey> keys = mapper.selectByUserId(userId);
        for (AiUserKey key : keys) {
            if (Boolean.TRUE.equals(key.getEnabled()) && key.getApiKeyCipher() != null && !key.getApiKeyCipher().isEmpty()) {
                return key;
            }
        }
        return null;
    }

    @Override
    public List<AiUserKey> listEnabledByUser(Integer userId) {
        return mapper.selectByUserId(userId);
    }

    public String decryptKey(String cipher) {
        return decrypt(cipher);
    }

    private void normalizeDefaults(AiUserKey config) {
        if (config == null || config.getProviderCode() == null) {
            return;
        }
        String providerCode = config.getProviderCode().trim().toLowerCase();
        config.setProviderCode(providerCode);
        if ("zhipu".equals(providerCode)) {
            if (isBlank(config.getApiBaseUrl())) config.setApiBaseUrl("https://open.bigmodel.cn/api/paas/v4");
            if (isBlank(config.getChatModel())) config.setChatModel("glm-4.5-air");
            if (isBlank(config.getEmbeddingModel())) config.setEmbeddingModel("embedding-2");
            if (isBlank(config.getVisionModel())) config.setVisionModel("glm-4.6v-flash");
        } else if ("openai".equals(providerCode)) {
            if (isBlank(config.getApiBaseUrl())) config.setApiBaseUrl("https://api.openai.com/v1");
            if (isBlank(config.getEmbeddingModel())) config.setEmbeddingModel("text-embedding-3-small");
            if (isBlank(config.getVisionModel())) config.setVisionModel("gpt-4o");
        } else if ("deepseek".equals(providerCode)) {
            if (isBlank(config.getApiBaseUrl())) config.setApiBaseUrl("https://api.deepseek.com");
        }
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

    private void testProvider(AiUserKey config, String apiKey) {
        String provider = config.getProviderCode() == null ? "" : config.getProviderCode().toLowerCase();
        if ("zhipu".equals(provider)) {
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

    private String mask(String key) {
        if (key.length() <= 8) return "****";
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
        if (cipherText == null || cipherText.trim().isEmpty()) return null;
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
