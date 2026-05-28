package com.mindskip.xzs.controller.student;

import com.mindskip.xzs.base.BaseApiController;
import com.mindskip.xzs.service.AiOrchestratorService;
import com.mindskip.xzs.viewmodel.student.ai.AiWorkbenchRequestVM;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.io.IOException;
import java.util.concurrent.CompletableFuture;

@RestController("StudentAiWorkbenchController")
@RequestMapping("/api/student/ai/workbench")
public class AiWorkbenchController extends BaseApiController {

    private static final Logger logger = LoggerFactory.getLogger(AiWorkbenchController.class);

    private final AiOrchestratorService aiOrchestratorService;

    public AiWorkbenchController(AiOrchestratorService aiOrchestratorService) {
        this.aiOrchestratorService = aiOrchestratorService;
    }

    @PostMapping(value = "/stream", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public SseEmitter stream(@RequestBody AiWorkbenchRequestVM request) {
        SseEmitter emitter = new SseEmitter(600000L);
        CompletableFuture.runAsync(() -> {
            try {
                aiOrchestratorService.handleStream(request, getCurrentUser(),
                        (eventName, data) -> sendEvent(emitter, eventName, data));
                sendEvent(emitter, "done", "ok");
                emitter.complete();
            } catch (Exception e) {
                logger.error("AI 工作台流式处理失败", e);
                try {
                    sendEvent(emitter, "error", "AI工作台处理失败：" + e.getMessage());
                } catch (Exception ignored) {
                }
                emitter.completeWithError(e);
            }
        });
        return emitter;
    }

    private void sendEvent(SseEmitter emitter, String name, String data) throws IOException {
        emitter.send(SseEmitter.event().name(name).data(data == null ? "" : data));
    }
}
