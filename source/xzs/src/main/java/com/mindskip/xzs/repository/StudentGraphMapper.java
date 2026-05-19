package com.mindskip.xzs.repository;

import com.mindskip.xzs.domain.student.StudentLearningEvent;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface StudentGraphMapper {

    int insertEvent(StudentLearningEvent event);

    int upsertKnowledgeStateFromEvent(@Param("userId") Integer userId,
                                      @Param("knowledgePointId") Integer knowledgePointId,
                                      @Param("correct") Boolean correct);

    int upsertMistakeFromEvent(StudentLearningEvent event);
}
