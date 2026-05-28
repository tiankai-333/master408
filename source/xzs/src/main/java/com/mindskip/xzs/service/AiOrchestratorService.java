package com.mindskip.xzs.service;

import com.mindskip.xzs.domain.User;
import com.mindskip.xzs.viewmodel.student.ai.AiWorkbenchRequestVM;

public interface AiOrchestratorService {

    interface WorkbenchEventConsumer {
        void send(String eventName, String data) throws Exception;
    }

    void handleStream(AiWorkbenchRequestVM request, User user, WorkbenchEventConsumer consumer) throws Exception;
}
