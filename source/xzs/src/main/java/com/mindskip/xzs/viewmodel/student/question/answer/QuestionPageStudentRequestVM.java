package com.mindskip.xzs.viewmodel.student.question.answer;

import com.mindskip.xzs.base.BasePage;
import java.util.List;

public class QuestionPageStudentRequestVM extends BasePage {
    private Integer createUser;
    private Integer subjectId;
    private List<Integer> subjectIds;

    public Integer getCreateUser() {
        return createUser;
    }

    public void setCreateUser(Integer createUser) {
        this.createUser = createUser;
    }

    public Integer getSubjectId() {
        return subjectId;
    }

    public void setSubjectId(Integer subjectId) {
        this.subjectId = subjectId;
    }

    public List<Integer> getSubjectIds() {
        return subjectIds;
    }

    public void setSubjectIds(List<Integer> subjectIds) {
        this.subjectIds = subjectIds;
    }
}
