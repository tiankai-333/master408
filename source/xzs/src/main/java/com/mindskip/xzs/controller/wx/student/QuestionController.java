package com.mindskip.xzs.controller.wx.student;

import com.mindskip.xzs.ai.AnalysisService;
import com.mindskip.xzs.base.RestResponse;
import com.mindskip.xzs.controller.wx.BaseWXApiController;
import com.mindskip.xzs.service.QuestionService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletRequest;

@Controller("WXStudentQuestionController")
@RequestMapping(value = "/api/wx/student/question")
@ResponseBody
public class QuestionController extends BaseWXApiController {

    private static final Logger logger = LoggerFactory.getLogger(QuestionController.class);

    private final QuestionService questionService;
    private final AnalysisService analysisService;

    @Autowired
    public QuestionController(QuestionService questionService, AnalysisService analysisService) {
        this.questionService = questionService;
        this.analysisService = analysisService;
    }

    @RequestMapping(value = "/analyze-question", method = RequestMethod.POST)
    public RestResponse analyzeQuestion(HttpServletRequest request) {
        try {
            String questionType = request.getParameter("questionType");
            String questionContent = request.getParameter("questionContent");
            String options = request.getParameter("options");
            String correctAnswer = request.getParameter("correctAnswer");
            String style = request.getParameter("style");
            if (style == null || style.isEmpty()) {
                style = "default";
            }

            if (questionContent == null || questionContent.trim().isEmpty()) {
                return RestResponse.fail(2, "题目内容不能为空");
            }

            StringBuilder questionFull = new StringBuilder();
            questionFull.append("题目类型：").append(questionType).append("\n");
            questionFull.append("题目内容：").append(questionContent).append("\n");
            if (options != null && !options.trim().isEmpty()) {
                questionFull.append("选项：\n").append(options).append("\n");
            }
            if (correctAnswer != null && !correctAnswer.trim().isEmpty()) {
                questionFull.append("正确答案：").append(correctAnswer).append("\n");
            }

            String result = analysisService.analyzeWithAI(style, questionFull.toString(), null);

            if (result == null || result.trim().isEmpty()) {
                return RestResponse.fail(2, "AI分析结果为空，请稍后重试");
            }

            return RestResponse.ok(result);
        } catch (Exception e) {
            logger.error("题目分析失败", e);
            return RestResponse.fail(2, "题目分析失败：" + e.getMessage());
        }
    }

    @RequestMapping(value = "/analyze-image", method = RequestMethod.POST)
    public RestResponse analyzeImageQuestion(@RequestParam("file") MultipartFile file) {
        try {
            if (file == null || file.isEmpty()) {
                return RestResponse.fail(2, "请选择要识别的图片");
            }
            String result = questionService.analyzeImageQuestion(file);
            return RestResponse.ok(result);
        } catch (Exception e) {
            return RestResponse.fail(2, "图片识别失败：" + e.getMessage());
        }
    }
}
