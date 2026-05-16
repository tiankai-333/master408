package com.mindskip.xzs.controller.student;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.mindskip.xzs.base.BaseApiController;
import com.mindskip.xzs.base.RestResponse;
import com.mindskip.xzs.domain.Subject;
import com.mindskip.xzs.domain.User;
import com.mindskip.xzs.repository.ExamPaperAnswerMapper;
import com.mindskip.xzs.service.SubjectService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;

import java.util.*;

@RestController("StudentChatController")
@RequestMapping(value = "/api/student")
public class ChatController extends BaseApiController {

    private static final Logger logger = LoggerFactory.getLogger(ChatController.class);

    private final ObjectMapper objectMapper = new ObjectMapper();

    @Autowired
    private SubjectService subjectService;

    @Autowired
    private ExamPaperAnswerMapper examPaperAnswerMapper;

    @Value("${ai.api.type:glm}")
    private String aiApiType;

    @Value("${ai.api.key:}")
    private String aiApiKey;

    @Value("${ai.api.url:https://open.bigmodel.cn/api/paas/v4/chat/completions}")
    private String aiApiUrl;

    @RequestMapping(value = "/chat", method = RequestMethod.POST)
    public RestResponse chat(@RequestBody Map<String, Object> requestData) {
        try {
            String message = (String) requestData.get("message");
            @SuppressWarnings("unchecked")
            List<Map<String, String>> history = (List<Map<String, String>>) requestData.get("history");

            logger.info("收到聊天请求 - 消息长度: {}, 历史记录数: {}", 
                message != null ? message.length() : 0, 
                history != null ? history.size() : 0);

            if (message == null || message.trim().isEmpty()) {
                return RestResponse.fail(2, "消息内容不能为空");
            }

            String response = generateChatResponse(message, history);
            
            logger.info("聊天响应生成完成 - 响应长度: {}", response.length());
            return RestResponse.ok(response);

        } catch (Exception e) {
            logger.error("聊天处理失败", e);
            return RestResponse.fail(2, "聊天处理失败：" + e.getMessage());
        }
    }

    private String generateChatResponse(String message, List<Map<String, String>> history) throws Exception {
        String systemPrompt = buildSystemPrompt();
        
        List<Map<String, String>> messages = new ArrayList<>();
        
        Map<String, String> systemMsg = new HashMap<>();
        systemMsg.put("role", "system");
        systemMsg.put("content", systemPrompt);
        messages.add(systemMsg);

        if (history != null) {
            for (Map<String, String> msg : history) {
                Map<String, String> historyMsg = new HashMap<>();
                historyMsg.put("role", msg.get("role"));
                historyMsg.put("content", msg.get("content"));
                messages.add(historyMsg);
            }
        }

        Map<String, String> userMsg = new HashMap<>();
        userMsg.put("role", "user");
        userMsg.put("content", message);
        messages.add(userMsg);

        return callAiApi(messages);
    }

    private String buildSystemPrompt() {
        return "你是 408Master，一个专业的考研408智能导师。\n\n" +
            "【角色定位】\n" +
            "- 你精通计算机考研408的四门课程：数据结构、计算机组成原理、操作系统、计算机网络\n" +
            "- 你的目标是帮助学生理解知识点，而不仅仅是给出答案\n" +
            "- 你有记忆能力，会根据学生的学习历史提供个性化建议\n\n" +
            "【核心能力】\n" +
            "1. 题目解析：可以用四种风格讲解题目\n" +
            "   - 标准解析：老师讲课式，结构化讲解\n" +
            "   - 费曼风格：用大白话和生活类比解释\n" +
            "   - 柏拉图式：启发式提问，引导思考\n" +
            "   - 第一性原理：从本质出发，逻辑推导\n" +
            "\n" +
            "2. 知识讲解：解释任何408相关知识点\n" +
            "3. 练习生成：根据知识点生成练习题\n" +
            "4. 学习建议：分析薄弱点，给出学习建议\n\n" +
            "【交互方式】\n" +
            "- 用友好、鼓励的语气说话\n" +
            "- 适当使用 emoji 让回复更生动\n" +
            "- 当学生问'帮我分析这道题'时，可以询问他们想用哪种风格\n" +
            "- 主动关注学生的薄弱点\n\n" +
            "【回答格式】\n" +
            "- 重要内容用 **粗体** 标注\n" +
            "- 列表项用 - 或 数字开头\n" +
            "- 代码或专业术语用 `反引号` 包裹\n" +
            "- 保持回复简洁但信息丰富";
    }

    private String callAiApi(List<Map<String, String>> messages) throws Exception {
        RestTemplate restTemplate = new RestTemplate();
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        Map<String, Object> requestBody = new HashMap<>();
        
        if ("glm".equals(aiApiType)) {
            headers.set("Authorization", "Bearer " + aiApiKey);
            requestBody.put("model", "glm-4.5-air");
            requestBody.put("messages", messages);
            requestBody.put("temperature", 0.7);
            requestBody.put("max_tokens", 4096);
        } else {
            headers.set("Authorization", "Bearer " + aiApiKey);
            requestBody.put("model", "gpt-4o");
            requestBody.put("messages", messages);
            requestBody.put("temperature", 0.7);
            requestBody.put("max_tokens", 4096);
        }

        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(requestBody, headers);

        try {
            ResponseEntity<String> response = restTemplate.postForEntity(aiApiUrl, entity, String.class);
            
            JsonNode rootNode = objectMapper.readTree(response.getBody());
            String resultContent = "";
            
            if ("glm".equals(aiApiType)) {
                JsonNode choices = rootNode.path("choices");
                if (choices.isArray() && choices.size() > 0) {
                    JsonNode msgNode = choices.get(0).path("message");
                    resultContent = msgNode.path("content").asText();
                    if (resultContent.isEmpty()) {
                        resultContent = msgNode.path("reasoning_content").asText();
                    }
                }
            } else {
                resultContent = rootNode.path("choices").get(0).path("message").path("content").asText();
            }
            
            return resultContent;
        } catch (Exception e) {
            logger.error("AI API调用失败", e);
            throw new Exception("AI服务暂时不可用，请稍后重试");
        }
    }

    @RequestMapping(value = "/user/stats", method = RequestMethod.GET)
    public RestResponse<Map<String, Object>> getUserStats() {
        try {
            User user = getCurrentUser();
            Map<String, Object> summary = examPaperAnswerMapper.selectStudentQuestionSummary(user.getId());
            int totalQuestions = numberValue(summary.get("totalQuestions"));
            int correctQuestions = numberValue(summary.get("correctQuestions"));
            int accuracy = totalQuestions == 0 ? 0 : Math.round(correctQuestions * 100f / totalQuestions);

            Map<String, Object> stats = new HashMap<>();
            stats.put("totalQuestions", totalQuestions);
            stats.put("accuracy", accuracy);
            stats.put("weakPoints", numberValue(summary.get("weakPoints")));
            stats.put("subjects", examPaperAnswerMapper.selectStudentSubjectAccuracy(user.getId()));

            logger.info("用户统计数据返回: 总题目={}, 正确率={}%", 
                stats.get("totalQuestions"), stats.get("accuracy"));
            
            return RestResponse.ok(stats);
        } catch (Exception e) {
            logger.error("获取用户统计失败", e);
            return RestResponse.fail(2, "获取统计数据失败");
        }
    }

    private int numberValue(Object value) {
        if (value == null) {
            return 0;
        }
        if (value instanceof Number) {
            return ((Number) value).intValue();
        }
        return Integer.parseInt(value.toString());
    }

    @RequestMapping(value = "/knowledge-graph", method = RequestMethod.GET)
    public RestResponse<Map<String, Object>> getKnowledgeGraph(
            @RequestParam(required = false) Integer subjectId) {
        try {
            User user = getCurrentUser();
            List<Map<String, Object>> subjectStats = examPaperAnswerMapper.selectStudentSubjectAccuracy(user.getId());

            Map<String, Object> graph = new HashMap<>();
            List<Map<String, Object>> nodes = new ArrayList<>();
            List<Map<String, Object>> links = new ArrayList<>();
            List<Map<String, Object>> categories = new ArrayList<>();

            Map<String, Object> category = new HashMap<>();
            category.put("name", "学生答题统计");
            categories.add(category);

            nodes.add(createNode(-1, "当前学习记录", 70, "summary", 0));
            for (Map<String, Object> subject : subjectStats) {
                Integer id = numberValue(subject.get("id"));
                if (subjectId != null && !subjectId.equals(id)) {
                    continue;
                }
                Integer accuracy = numberValue(subject.get("accuracy"));
                String name = subject.get("name") + " " + accuracy + "%";
                nodes.add(createNode(id, name, 35 + Math.round(accuracy * 0.4f), "subject", 0));
                links.add(createLink(-1, id, "正确率"));
            }

            graph.put("nodes", nodes);
            graph.put("links", links);
            graph.put("categories", categories);
            
            logger.info("知识图谱返回: 节点数={}, 边数={}", nodes.size(), links.size());
            
            return RestResponse.ok(graph);
        } catch (Exception e) {
            logger.error("获取知识图谱失败", e);
            return RestResponse.fail(2, "获取知识图谱失败");
        }
    }

    private Map<String, Object> createNode(int id, String name, int size, String type, int category) {
        Map<String, Object> node = new HashMap<>();
        node.put("id", id);
        node.put("name", name);
        node.put("symbolSize", size);
        node.put("type", type);
        node.put("category", category);
        return node;
    }

    private Map<String, Object> createLink(int source, int target, String relation) {
        Map<String, Object> link = new HashMap<>();
        link.put("source", source);
        link.put("target", target);
        link.put("relation", relation);
        return link;
    }
}
