package com.mindskip.xzs.controller.wx.student;

import com.mindskip.xzs.base.RestResponse;
import com.mindskip.xzs.controller.wx.BaseWXApiController;
import com.mindskip.xzs.domain.ai.AiProviderConfig;
import com.mindskip.xzs.domain.ai.AiUserKey;
import com.mindskip.xzs.service.AiProviderConfigService;
import com.mindskip.xzs.service.AiUserKeyService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@Controller("WXStudentAiConfigController")
@RequestMapping(value = "/api/wx/student/ai-config")
@ResponseBody
public class AiConfigController extends BaseWXApiController {

    private final AiProviderConfigService aiProviderConfigService;
    private final AiUserKeyService aiUserKeyService;

    @Autowired
    public AiConfigController(AiProviderConfigService aiProviderConfigService, AiUserKeyService aiUserKeyService) {
        this.aiProviderConfigService = aiProviderConfigService;
        this.aiUserKeyService = aiUserKeyService;
    }

    @RequestMapping(value = "/providers", method = RequestMethod.POST)
    public RestResponse<List<AiProviderConfig>> publicProviders() {
        return RestResponse.ok(aiProviderConfigService.listSafe());
    }

    @RequestMapping(value = "/provider/{id}/test", method = RequestMethod.POST)
    public RestResponse<Map<String, Object>> testPublicProvider(@PathVariable Integer id) {
        return RestResponse.ok(aiProviderConfigService.test(id));
    }

    @RequestMapping(value = "/user-keys", method = RequestMethod.POST)
    public RestResponse<List<AiUserKey>> userKeys() {
        return RestResponse.ok(aiUserKeyService.listByUser(getCurrentUser().getId()));
    }

    @RequestMapping(value = "/user-key/{id}/test", method = RequestMethod.POST)
    public RestResponse<Map<String, Object>> testUserKey(@PathVariable Integer id) {
        return RestResponse.ok(aiUserKeyService.test(id, getCurrentUser().getId()));
    }
}
