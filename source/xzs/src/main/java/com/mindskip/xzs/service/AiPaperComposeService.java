package com.mindskip.xzs.service;

import com.mindskip.xzs.domain.User;
import com.mindskip.xzs.viewmodel.student.ai.AiPaperComposeRequestVM;
import com.mindskip.xzs.viewmodel.student.ai.AiPaperComposeResponseVM;

public interface AiPaperComposeService {

    AiPaperComposeResponseVM compose(AiPaperComposeRequestVM request, User user);
}
