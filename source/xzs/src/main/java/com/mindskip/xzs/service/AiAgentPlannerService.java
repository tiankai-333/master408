package com.mindskip.xzs.service;

import com.mindskip.xzs.domain.User;
import com.mindskip.xzs.viewmodel.student.ai.AiAgentConfirmRequestVM;
import com.mindskip.xzs.viewmodel.student.ai.AiAgentPlanRequestVM;
import com.mindskip.xzs.viewmodel.student.ai.AiAgentPlanResponseVM;
import com.mindskip.xzs.viewmodel.student.ai.AiPaperComposeResponseVM;

public interface AiAgentPlannerService {

    AiAgentPlanResponseVM plan(AiAgentPlanRequestVM request, User user);

    AiPaperComposeResponseVM confirm(AiAgentConfirmRequestVM request, User user);
}
