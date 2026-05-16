package com.mindskip.xzs.controller.student;

import com.mindskip.xzs.base.BaseApiController;
import com.mindskip.xzs.base.RestResponse;
import com.mindskip.xzs.domain.Subject;
import com.mindskip.xzs.repository.SubjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController("StudentSubjectController")
@RequestMapping(value = "/api/student/subject")
public class SubjectController extends BaseApiController {

    private final SubjectMapper subjectMapper;

    @Autowired
    public SubjectController(SubjectMapper subjectMapper) {
        this.subjectMapper = subjectMapper;
    }

    @RequestMapping(value = "/list", method = RequestMethod.GET)
    public RestResponse list() {
        try {
            List<Subject> subjects = subjectMapper.allSubject();
            return RestResponse.ok(subjects);
        } catch (Exception e) {
            e.printStackTrace();
            return RestResponse.fail(500, "获取学科列表失败");
        }
    }

    @RequestMapping(value = "/{id}", method = RequestMethod.GET)
    public RestResponse getById(@PathVariable Integer id) {
        try {
            Subject subject = subjectMapper.selectByPrimaryKey(id);
            if (subject != null) {
                return RestResponse.ok(subject);
            }
            return RestResponse.fail(500, "学科不存在");
        } catch (Exception e) {
            e.printStackTrace();
            return RestResponse.fail(500, "获取学科信息失败");
        }
    }
}