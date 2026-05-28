package com.mindskip.xzs.repository;

import com.mindskip.xzs.domain.other.KeyValue;
import com.mindskip.xzs.domain.Question;
import com.mindskip.xzs.viewmodel.admin.question.QuestionPageRequestVM;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.Date;
import java.util.List;

@Mapper
public interface QuestionMapper extends BaseMapper<Question> {

    List<Question> page(QuestionPageRequestVM requestVM);

    List<Question> selectByIds(@Param("ids") List<Integer> ids);

    List<Question> selectForAiPaper(@Param("subjectId") Integer subjectId,
                                    @Param("knowledgePoint") String knowledgePoint,
                                    @Param("sourceYear") Integer sourceYear,
                                    @Param("questionTypes") List<Integer> questionTypes,
                                    @Param("excludeQuestionIds") List<Integer> excludeQuestionIds,
                                    @Param("excludeSourceYears") List<Integer> excludeSourceYears,
                                    @Param("limit") Integer limit);

    List<Question> selectMistakesForAiPaper(@Param("userId") Integer userId,
                                            @Param("subjectId") Integer subjectId,
                                            @Param("knowledgePoint") String knowledgePoint,
                                            @Param("sourceYear") Integer sourceYear,
                                            @Param("questionTypes") List<Integer> questionTypes,
                                            @Param("excludeQuestionIds") List<Integer> excludeQuestionIds,
                                            @Param("excludeSourceYears") List<Integer> excludeSourceYears,
                                            @Param("limit") Integer limit);

    Integer selectAllCount();

    List<KeyValue> selectCountByDate(@Param("startTime") Date startTime,@Param("endTime") Date endTime);
}
