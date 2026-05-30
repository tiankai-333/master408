package com.mindskip.xzs.controller.student;

import com.mindskip.xzs.base.BaseApiController;
import com.mindskip.xzs.base.RestResponse;
import com.mindskip.xzs.domain.ai.AiProviderConfig;
import com.mindskip.xzs.domain.ai.AiUserKey;
import com.mindskip.xzs.repository.AiUsageLogMapper;
import com.mindskip.xzs.service.AiProviderConfigService;
import com.mindskip.xzs.service.AiUserKeyService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController("StudentAiConfigController")
@RequestMapping("/api/student/ai-config")
public class StudentAiConfigController extends BaseApiController {

    @Autowired
    private AiProviderConfigService aiProviderConfigService;

    @Autowired
    private AiUserKeyService aiUserKeyService;

    @Autowired
    private AiUsageLogMapper aiUsageLogMapper;

    @PostMapping("/providers")
    public RestResponse<List<AiProviderConfig>> publicProviders() {
        return RestResponse.ok(aiProviderConfigService.listSafe());
    }

    @PostMapping("/provider/{id}/test")
    public RestResponse<Map<String, Object>> testPublicProvider(@PathVariable Integer id) {
        return RestResponse.ok(aiProviderConfigService.test(id));
    }

    @PostMapping("/user-keys")
    public RestResponse<List<AiUserKey>> userKeys() {
        return RestResponse.ok(aiUserKeyService.listByUser(getCurrentUser().getId()));
    }

    @PostMapping("/user-key/save")
    public RestResponse<AiUserKey> saveUserKey(@RequestBody Map<String, Object> request) {
        AiUserKey config = new AiUserKey();
        Object id = request.get("id");
        config.setId(id == null || "".equals(String.valueOf(id)) ? null : Integer.valueOf(String.valueOf(id)));
        config.setProviderCode(stringValue(request.get("providerCode")));
        config.setProviderName(stringValue(request.get("providerName")));
        config.setApiBaseUrl(stringValue(request.get("apiBaseUrl")));
        config.setChatModel(stringValue(request.get("chatModel")));
        config.setEmbeddingModel(stringValue(request.get("embeddingModel")));
        config.setEnabled(booleanValue(request.get("enabled")));
        Object priority = request.get("priority");
        config.setPriority(priority == null || "".equals(String.valueOf(priority)) ? 100 : Integer.valueOf(String.valueOf(priority)));
        String plainApiKey = stringValue(request.get("apiKey"));
        return RestResponse.ok(aiUserKeyService.save(getCurrentUser().getId(), config, plainApiKey));
    }

    @PostMapping("/user-key/{id}/test")
    public RestResponse<Map<String, Object>> testUserKey(@PathVariable Integer id) {
        return RestResponse.ok(aiUserKeyService.test(id, getCurrentUser().getId()));
    }

    @PostMapping("/user-key/delete/{id}")
    public RestResponse deleteUserKey(@PathVariable Integer id) {
        aiUserKeyService.deleteById(id, getCurrentUser().getId());
        return RestResponse.ok();
    }

    @PostMapping("/usage")
    public RestResponse<Map<String, Object>> usage(@RequestBody(required = false) Map<String, Object> request) {
        int days = 30;
        if (request != null && request.get("days") != null) {
            days = Math.min(Integer.valueOf(String.valueOf(request.get("days"))), 365);
        }
        Integer userId = getCurrentUser().getId();
        Map<String, Object> result = new HashMap<>();
        result.put("days", days);
        result.put("summary", aiUsageLogMapper.selectUserUsageSummary(userId, days));
        result.put("summaryByKeySource", aiUsageLogMapper.selectUserUsageSummaryByKeySource(userId, days));
        result.put("byProvider", aiUsageLogMapper.selectUserUsageByProvider(userId, days));
        result.put("recentLogs", aiUsageLogMapper.selectUserRecentLogs(userId, days, 50));
        return RestResponse.ok(result);
    }

    private String stringValue(Object value) {
        return value == null ? null : String.valueOf(value).trim();
    }

    private Boolean booleanValue(Object value) {
        if (value == null) return false;
        if (value instanceof Boolean) return (Boolean) value;
        return "true".equalsIgnoreCase(String.valueOf(value)) || "1".equals(String.valueOf(value));
    }
}
