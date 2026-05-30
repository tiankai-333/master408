package com.mindskip.xzs.controller.wx.student;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.mindskip.xzs.ai.AnalysisService;
import com.mindskip.xzs.ai.RagService;
import com.mindskip.xzs.base.RestResponse;
import com.mindskip.xzs.controller.wx.BaseWXApiController;
import com.mindskip.xzs.domain.User;
import com.mindskip.xzs.service.AiAgentPlannerService;
import com.mindskip.xzs.service.AiOrchestratorService;
import com.mindskip.xzs.service.AiPaperComposeService;
import com.mindskip.xzs.viewmodel.student.ai.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@Controller("WxAiWorkbenchController")
@RequestMapping(value = "/api/wx/student/ai")
@ResponseBody
public class WxAiWorkbenchController extends BaseWXApiController {

    private static final Logger logger = LoggerFactory.getLogger(WxAiWorkbenchController.class);
    private static final ObjectMapper objectMapper = new ObjectMapper();

    private final AiOrchestratorService aiOrchestratorService;
    private final AiAgentPlannerService aiAgentPlannerService;
    private final AiPaperComposeService aiPaperComposeService;

    @Autowired
    public WxAiWorkbenchController(AiOrchestratorService aiOrchestratorService,
                                   AiAgentPlannerService aiAgentPlannerService,
                                   AiPaperComposeService aiPaperComposeService) {
        this.aiOrchestratorService = aiOrchestratorService;
        this.aiAgentPlannerService = aiAgentPlannerService;
        this.aiPaperComposeService = aiPaperComposeService;
    }

    @PostMapping("/workbench")
    public RestResponse workbench(@RequestBody AiWorkbenchRequestVM request) {
        User user = getCurrentUser();
        AnalysisService.setCurrentUserId(user.getId());
        RagService.setCurrentUserId(user.getId());
        try {
            List<Map<String, String>> events = new ArrayList<>();
            StringBuilder analysis = new StringBuilder();
            String agentDraft = null;
            List<Map<String, Object>> references = null;

            AiOrchestratorService.WorkbenchEventConsumer consumer = (eventName, data) -> {
                Map<String, String> evt = new HashMap<>();
                evt.put("event", eventName);
                evt.put("data", data);
                events.add(evt);
            };

            aiOrchestratorService.handleStream(request, user, consumer);

            for (Map<String, String> evt : events) {
                String eventName = evt.get("event");
                String data = evt.get("data");
                switch (eventName) {
                    case "chunk":
                        analysis.append(data);
                        break;
                    case "agentDraft":
                        agentDraft = data;
                        break;
                    case "references":
                        try {
                            references = objectMapper.readValue(data, List.class);
                        } catch (Exception ignored) {
                        }
                        break;
                }
            }

            Map<String, Object> result = new LinkedHashMap<>();
            result.put("analysis", analysis.toString());
            if (agentDraft != null) {
                result.put("agentDraft", objectMapper.readValue(agentDraft, AiAgentPlanResponseVM.class));
            }
            if (references != null) {
                result.put("references", references);
            }
            return RestResponse.ok(result);
        } catch (Exception e) {
            logger.error("WX AI 工作台处理失败", e);
            return RestResponse.fail(2, "AI处理失败：" + e.getMessage());
        } finally {
            RagService.clearCurrentUserId();
            AnalysisService.clearCurrentUserId();
        }
    }

    @PostMapping("/agent/plan")
    public RestResponse<AiAgentPlanResponseVM> agentPlan(@RequestBody AiAgentPlanRequestVM request) {
        try {
            return RestResponse.ok(aiAgentPlannerService.plan(request, getCurrentUser()));
        } catch (Exception e) {
            logger.error("Agent草案生成失败", e);
            return RestResponse.fail(2, e.getMessage());
        }
    }

    @PostMapping("/agent/confirm")
    public RestResponse<AiPaperComposeResponseVM> agentConfirm(@RequestBody AiAgentConfirmRequestVM request) {
        try {
            return RestResponse.ok(aiAgentPlannerService.confirm(request, getCurrentUser()));
        } catch (Exception e) {
            logger.error("Agent草案确认失败", e);
            return RestResponse.fail(2, e.getMessage());
        }
    }

    @PostMapping("/compose-paper")
    public RestResponse<AiPaperComposeResponseVM> composePaper(@RequestBody AiPaperComposeRequestVM request) {
        try {
            return RestResponse.ok(aiPaperComposeService.compose(request, getCurrentUser()));
        } catch (Exception e) {
            logger.error("AI组卷失败", e);
            return RestResponse.fail(2, e.getMessage());
        }
    }
}
