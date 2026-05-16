package com.mindskip.xzs.service;

import com.mindskip.xzs.domain.Question;
import com.mindskip.xzs.viewmodel.admin.question.QuestionEditRequestVM;
import com.mindskip.xzs.viewmodel.admin.question.QuestionPageRequestVM;
import com.github.pagehelper.PageInfo;

import java.util.List;

public interface QuestionService extends BaseService<Question> {

    PageInfo<Question> page(QuestionPageRequestVM requestVM);

    Question insertFullQuestion(QuestionEditRequestVM model, Integer userId);

    Question updateFullQuestion(QuestionEditRequestVM model);

    QuestionEditRequestVM getQuestionEditRequestVM(Integer questionId);

    QuestionEditRequestVM getQuestionEditRequestVM(Question question);

    Integer selectAllCount();

    List<Integer> selectMothCount();

    int uploadAndAnalyzeTxt(org.springframework.web.multipart.MultipartFile file, Integer userId) throws Exception;

    String analyzeImageQuestion(org.springframework.web.multipart.MultipartFile file) throws Exception;

    String analyzeQuestion(String questionType, String questionContent, String options, String correctAnswer) throws Exception;
}
