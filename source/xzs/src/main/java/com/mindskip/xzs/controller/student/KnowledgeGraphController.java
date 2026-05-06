package com.mindskip.xzs.controller.student;

import com.mindskip.xzs.base.BaseApiController;
import com.mindskip.xzs.base.RestResponse;
import com.mindskip.xzs.service.KnowledgeGraphService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController("StudentKnowledgeGraphController")
@RequestMapping(value = "/api/student/knowledge-graph")
public class KnowledgeGraphController extends BaseApiController {

    private final KnowledgeGraphService knowledgeGraphService;

    @Autowired
    public KnowledgeGraphController(KnowledgeGraphService knowledgeGraphService) {
        this.knowledgeGraphService = knowledgeGraphService;
    }

    @RequestMapping(value = "/graph", method = RequestMethod.GET)
    public RestResponse getKnowledgeGraph(@RequestParam(value = "subjectId", required = false) Integer subjectId) {
        Map<String, Object> graph = knowledgeGraphService.getKnowledgeGraph(subjectId);
        return RestResponse.ok(graph);
    }

    @RequestMapping(value = "/knowledge-point/{id}", method = RequestMethod.GET)
    public RestResponse getKnowledgePointDetail(@PathVariable Integer id) {
        Map<String, Object> detail = knowledgeGraphService.getKnowledgePointDetail(id);
        return RestResponse.ok(detail);
    }

    @RequestMapping(value = "/question/{questionId}/knowledge-points", method = RequestMethod.GET)
    public RestResponse getQuestionKnowledgePoints(@PathVariable Integer questionId) {
        return RestResponse.ok(knowledgeGraphService.getQuestionKnowledgePoints(questionId));
    }

    @RequestMapping(value = "/knowledge-point/{id}/questions", method = RequestMethod.GET)
    public RestResponse getKnowledgePointQuestions(
            @PathVariable Integer id,
            @RequestParam(value = "limit", defaultValue = "10") Integer limit) {
        return RestResponse.ok(knowledgeGraphService.getKnowledgePointQuestions(id, limit));
    }
}