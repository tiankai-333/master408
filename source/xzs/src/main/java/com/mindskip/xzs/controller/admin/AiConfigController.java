package com.mindskip.xzs.controller.admin;

import com.mindskip.xzs.base.BaseApiController;
import com.mindskip.xzs.base.RestResponse;
import com.mindskip.xzs.domain.ai.AiProviderConfig;
import com.mindskip.xzs.service.AiProviderConfigService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController("AdminAiConfigController")
@RequestMapping("/api/admin/ai-config")
public class AiConfigController extends BaseApiController {

    @Autowired
    private AiProviderConfigService aiProviderConfigService;

    @PostMapping("/providers")
    public RestResponse<List<AiProviderConfig>> providers() {
        return RestResponse.ok(aiProviderConfigService.listSafe());
    }

    @PostMapping("/provider/save")
    public RestResponse<AiProviderConfig> saveProvider(@RequestBody Map<String, Object> request) {
        AiProviderConfig config = new AiProviderConfig();
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
        return RestResponse.ok(aiProviderConfigService.save(config, plainApiKey));
    }

    @PostMapping("/provider/{id}/test")
    public RestResponse<Map<String, Object>> testProvider(@PathVariable Integer id) {
        return RestResponse.ok(aiProviderConfigService.test(id));
    }

    @PostMapping("/usage")
    public RestResponse<Map<String, Object>> usage(@RequestBody(required = false) Map<String, Object> request) {
        Integer days = 30;
        if (request != null && request.get("days") != null) {
            days = Integer.valueOf(String.valueOf(request.get("days")));
        }
        return RestResponse.ok(aiProviderConfigService.usage(days));
    }

    private String stringValue(Object value) {
        return value == null ? null : String.valueOf(value).trim();
    }

    private Boolean booleanValue(Object value) {
        if (value == null) {
            return false;
        }
        if (value instanceof Boolean) {
            return (Boolean) value;
        }
        return "true".equalsIgnoreCase(String.valueOf(value)) || "1".equals(String.valueOf(value));
    }
}
