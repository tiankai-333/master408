package com.mindskip.xzs.controller.student;

import com.mindskip.xzs.base.BaseApiController;
import com.mindskip.xzs.base.RestResponse;
import com.mindskip.xzs.service.QuestionService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletRequest;

@RestController("StudentQuestionController")
@RequestMapping(value = "/api/student/question")
public class QuestionController extends BaseApiController {

    private static final Logger logger = LoggerFactory.getLogger(QuestionController.class);

    private final QuestionService questionService;

    @Autowired
    public QuestionController(QuestionService questionService) {
        this.questionService = questionService;
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

    @RequestMapping(value = "/analyze-question", method = RequestMethod.POST)
    public RestResponse analyzeQuestion(@RequestBody java.util.Map<String, String> requestData) {
        try {
            String questionType = requestData.get("questionType");
            String questionContent = requestData.get("questionContent");
            String options = requestData.get("options");
            String correctAnswer = requestData.get("correctAnswer");
            
            logger.info("开始分析题目 - 类型: {}, 内容长度: {}", questionType, questionContent != null ? questionContent.length() : 0);
            
            if (questionContent == null || questionContent.trim().isEmpty()) {
                logger.warn("题目内容为空");
                return RestResponse.fail(2, "题目内容不能为空");
            }
            
            String result = questionService.analyzeQuestion(questionType, questionContent, options, correctAnswer);
            
            if (result == null || result.trim().isEmpty()) {
                logger.warn("AI返回结果为空");
                return RestResponse.fail(2, "AI分析结果为空，请稍后重试");
            }
            
            logger.info("题目分析完成 - 结果长度: {}", result.length());
            logger.debug("题目分析结果: {}", result);
            
            return RestResponse.ok(result);
        } catch (Exception e) {
            logger.error("题目分析失败", e);
            return RestResponse.fail(2, "题目分析失败：" + e.getMessage());
        }
    }
}
