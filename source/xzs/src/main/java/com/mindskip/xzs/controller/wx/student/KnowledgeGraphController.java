package com.mindskip.xzs.controller.wx.student;

import com.mindskip.xzs.base.RestResponse;
import com.mindskip.xzs.controller.wx.BaseWXApiController;
import com.mindskip.xzs.service.KnowledgeGraphService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@Controller("WXStudentKnowledgeGraphController")
@RequestMapping(value = "/api/wx/student/knowledge-graph")
@ResponseBody
public class KnowledgeGraphController extends BaseWXApiController {

    private final KnowledgeGraphService knowledgeGraphService;

    @Autowired
    public KnowledgeGraphController(KnowledgeGraphService knowledgeGraphService) {
        this.knowledgeGraphService = knowledgeGraphService;
    }

    @RequestMapping(value = "/graph", method = RequestMethod.POST)
    public RestResponse<Map<String, Object>> getKnowledgeGraph(@RequestParam(value = "subjectId", required = false) Integer subjectId) {
        Map<String, Object> graph = knowledgeGraphService.getKnowledgeGraph(subjectId);
        return RestResponse.ok(graph);
    }

    @RequestMapping(value = "/knowledge-point/{id}", method = RequestMethod.POST)
    public RestResponse<Map<String, Object>> getKnowledgePointDetail(@PathVariable Integer id) {
        Map<String, Object> detail = knowledgeGraphService.getKnowledgePointDetail(id);
        return RestResponse.ok(detail);
    }

    @RequestMapping(value = "/knowledge-point/{id}/questions", method = RequestMethod.POST)
    public RestResponse getKnowledgePointQuestions(
            @PathVariable Integer id,
            @RequestParam(value = "limit", defaultValue = "10") Integer limit) {
        return RestResponse.ok(knowledgeGraphService.getKnowledgePointQuestions(id, limit));
    }
}
