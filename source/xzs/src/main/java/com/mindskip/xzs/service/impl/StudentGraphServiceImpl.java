package com.mindskip.xzs.service.impl;

import com.mindskip.xzs.domain.student.StudentLearningEvent;
import com.mindskip.xzs.repository.StudentGraphMapper;
import com.mindskip.xzs.service.StudentGraphService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class StudentGraphServiceImpl implements StudentGraphService {

    @Autowired
    private StudentGraphMapper studentGraphMapper;

    @Override
    public StudentLearningEvent recordEvent(StudentLearningEvent event) {
        studentGraphMapper.insertEvent(event);
        if (event.getUserId() != null && event.getKnowledgePointId() != null && event.getCorrect() != null) {
            studentGraphMapper.upsertKnowledgeStateFromEvent(event.getUserId(), event.getKnowledgePointId(), event.getCorrect());
        }
        if (Boolean.FALSE.equals(event.getCorrect()) && event.getQuestionId() != null) {
            studentGraphMapper.upsertMistakeFromEvent(event);
        }
        return event;
    }
}
