package com.mindskip.xzs.service;

import com.mindskip.xzs.domain.student.StudentLearningEvent;

public interface StudentGraphService {

    StudentLearningEvent recordEvent(StudentLearningEvent event);
}
