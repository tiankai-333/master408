package com.mindskip.xzs.controller.student;

import com.mindskip.xzs.ai.AnalysisService;
import com.mindskip.xzs.ai.PromptTemplate;
import com.mindskip.xzs.base.BaseApiController;
import com.mindskip.xzs.base.RestResponse;
import com.mindskip.xzs.service.QuestionService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import javax.servlet.http.HttpServletRequest;
import java.io.IOException;
import java.util.concurrent.CompletableFuture;

@RestController("StudentQuestionController")
@RequestMapping(value = "/api/student/question")
public class QuestionController extends BaseApiController {

    private static final Logger logger = LoggerFactory.getLogger(QuestionController.class);

    private final QuestionService questionService;
    private final AnalysisService analysisService;

    @Autowired
    public QuestionController(QuestionService questionService, AnalysisService analysisService) {
        this.questionService = questionService;
        this.analysisService = analysisService;
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
            String style = requestData.getOrDefault("style", "default");
            
            logger.info("开始分析题目 - 类型: {}, 风格: {}, 内容长度: {}", questionType, style, questionContent != null ? questionContent.length() : 0);
            
            if (questionContent == null || questionContent.trim().isEmpty()) {
                logger.warn("题目内容为空");
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
                logger.warn("AI返回结果为空");
                return RestResponse.fail(2, "AI分析结果为空，请稍后重试");
            }
            
            logger.info("题目分析完成 - 风格: {}, 结果长度: {}", style, result.length());
            logger.debug("题目分析结果: {}", result);
            
            return RestResponse.ok(result);
        } catch (Exception e) {
            logger.error("题目分析失败", e);
            return RestResponse.fail(2, "题目分析失败：" + e.getMessage());
        }
    }

    @RequestMapping(value = "/analyze-question-stream", method = RequestMethod.POST, produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public SseEmitter analyzeQuestionStream(@RequestBody java.util.Map<String, String> requestData) {
        SseEmitter emitter = new SseEmitter(600000L);
        CompletableFuture.runAsync(() -> {
            try {
                String questionType = requestData.get("questionType");
                String questionContent = requestData.get("questionContent");
                String options = requestData.get("options");
                String correctAnswer = requestData.get("correctAnswer");
                String style = requestData.getOrDefault("style", "default");

                if (questionContent == null || questionContent.trim().isEmpty()) {
                    sendEvent(emitter, "error", "题目内容不能为空");
                    emitter.complete();
                    return;
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

                analysisService.analyzeWithAIStream(style, questionFull.toString(), null, null, "chat", token ->
                    sendEvent(emitter, "chunk", token)
                );
                sendEvent(emitter, "done", "ok");
                emitter.complete();
            } catch (Exception e) {
                logger.error("流式题目分析失败", e);
                try {
                    sendEvent(emitter, "error", "题目分析失败：" + e.getMessage());
                } catch (Exception ignored) {
                }
                emitter.completeWithError(e);
            }
        });
        return emitter;
    }

    private void sendEvent(SseEmitter emitter, String name, String data) throws IOException {
        emitter.send(SseEmitter.event().name(name).data(data == null ? "" : data));
    }
}
