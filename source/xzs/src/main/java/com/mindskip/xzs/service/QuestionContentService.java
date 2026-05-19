package com.mindskip.xzs.service;

import com.mindskip.xzs.domain.canonical.QuestionContent;
import com.mindskip.xzs.domain.Question;
import com.mindskip.xzs.viewmodel.admin.question.QuestionEditRequestVM;

public interface QuestionContentService {

    QuestionContent getCurrent(Integer questionId);

    QuestionContent saveFromEdit(Question question, QuestionEditRequestVM model);

    int backfillFromLegacy();

    int countCurrent();
}
