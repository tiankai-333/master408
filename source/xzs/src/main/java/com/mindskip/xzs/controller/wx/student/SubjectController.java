package com.mindskip.xzs.controller.wx.student;

import com.mindskip.xzs.base.RestResponse;
import com.mindskip.xzs.controller.wx.BaseWXApiController;
import com.mindskip.xzs.domain.Subject;
import com.mindskip.xzs.service.SubjectService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Controller("WXStudentSubjectController")
@RequestMapping(value = "/api/wx/student/subject")
@ResponseBody
public class SubjectController extends BaseWXApiController {

    private final SubjectService subjectService;

    @Autowired
    public SubjectController(SubjectService subjectService) {
        this.subjectService = subjectService;
    }

    @RequestMapping(value = "/list", method = RequestMethod.POST)
    public RestResponse<List<Subject>> list() {
        return RestResponse.ok(subjectService.allSubject());
    }
}
