package com.mindskip.xzs.repository;

import com.mindskip.xzs.domain.canonical.QuestionContent;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface QuestionContentMapper {

    QuestionContent selectCurrentByQuestionId(@Param("questionId") Integer questionId);

    int insert(QuestionContent content);

    Integer selectMaxVersion(@Param("questionId") Integer questionId);

    int clearCurrent(@Param("questionId") Integer questionId);

    int backfillFromLegacy();

    int countCurrent();
}
