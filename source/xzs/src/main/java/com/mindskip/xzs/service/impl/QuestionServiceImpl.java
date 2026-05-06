package com.mindskip.xzs.service.impl;

import com.mindskip.xzs.domain.other.KeyValue;
import com.mindskip.xzs.domain.Question;
import com.mindskip.xzs.domain.TextContent;
import com.mindskip.xzs.domain.enums.QuestionStatusEnum;
import com.mindskip.xzs.domain.enums.QuestionTypeEnum;
import com.mindskip.xzs.domain.question.QuestionItemObject;
import com.mindskip.xzs.domain.question.QuestionObject;
import com.mindskip.xzs.repository.QuestionMapper;
import com.mindskip.xzs.service.QuestionService;
import com.mindskip.xzs.service.SubjectService;
import com.mindskip.xzs.service.TextContentService;
import com.mindskip.xzs.utility.DateTimeUtil;
import com.mindskip.xzs.utility.JsonUtil;
import com.mindskip.xzs.utility.ModelMapperSingle;
import com.mindskip.xzs.utility.ExamUtil;
import com.mindskip.xzs.viewmodel.admin.question.QuestionEditItemVM;
import com.mindskip.xzs.viewmodel.admin.question.QuestionEditRequestVM;
import com.mindskip.xzs.viewmodel.admin.question.QuestionPageRequestVM;
import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import org.modelmapper.ModelMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.Base64;
import java.util.Date;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class QuestionServiceImpl extends BaseServiceImpl<Question> implements QuestionService {

    protected final static ModelMapper modelMapper = ModelMapperSingle.Instance();
    private final QuestionMapper questionMapper;
    private final TextContentService textContentService;
    private final SubjectService subjectService;

    @Value("${ai.api.key}")
    private String aiApiKey;

    @Value("${ai.api.url}")
    private String aiApiUrl;

    @Value("${ai.api.type}")
    private String aiApiType;

    @Autowired
    public QuestionServiceImpl(QuestionMapper questionMapper, TextContentService textContentService, SubjectService subjectService) {
        super(questionMapper);
        this.textContentService = textContentService;
        this.questionMapper = questionMapper;
        this.subjectService = subjectService;
    }

    @Override
    public PageInfo<Question> page(QuestionPageRequestVM requestVM) {
        return PageHelper.startPage(requestVM.getPageIndex(), requestVM.getPageSize(), "id desc").doSelectPageInfo(() ->
                questionMapper.page(requestVM)
        );
    }


    @Override
    @Transactional
    public Question insertFullQuestion(QuestionEditRequestVM model, Integer userId) {
        Date now = new Date();
        Integer gradeLevel = subjectService.levelBySubjectId(model.getSubjectId());

        //题干、解析、选项等 插入
        TextContent infoTextContent = new TextContent();
        infoTextContent.setCreateTime(now);
        setQuestionInfoFromVM(infoTextContent, model);
        textContentService.insertByFilter(infoTextContent);

        Question question = new Question();
        question.setSubjectId(model.getSubjectId());
        question.setGradeLevel(gradeLevel);
        question.setCreateTime(now);
        question.setQuestionType(model.getQuestionType());
        question.setStatus(QuestionStatusEnum.OK.getCode());
        question.setCorrectFromVM(model.getCorrect(), model.getCorrectArray());
        question.setScore(ExamUtil.scoreFromVM(model.getScore()));
        question.setDifficult(model.getDifficult());
        question.setInfoTextContentId(infoTextContent.getId());
        question.setCreateUser(userId);
        question.setDeleted(false);
        questionMapper.insertSelective(question);
        return question;
    }

    @Override
    @Transactional
    public Question updateFullQuestion(QuestionEditRequestVM model) {
        Integer gradeLevel = subjectService.levelBySubjectId(model.getSubjectId());
        Question question = questionMapper.selectByPrimaryKey(model.getId());
        question.setSubjectId(model.getSubjectId());
        question.setGradeLevel(gradeLevel);
        question.setScore(ExamUtil.scoreFromVM(model.getScore()));
        question.setDifficult(model.getDifficult());
        question.setCorrectFromVM(model.getCorrect(), model.getCorrectArray());
        questionMapper.updateByPrimaryKeySelective(question);

        //题干、解析、选项等 更新
        TextContent infoTextContent = textContentService.selectById(question.getInfoTextContentId());
        setQuestionInfoFromVM(infoTextContent, model);
        textContentService.updateByIdFilter(infoTextContent);

        return question;
    }

    @Override
    public QuestionEditRequestVM getQuestionEditRequestVM(Integer questionId) {
        //题目映射
        Question question = questionMapper.selectByPrimaryKey(questionId);
        return getQuestionEditRequestVM(question);
    }

    @Override
    public QuestionEditRequestVM getQuestionEditRequestVM(Question question) {
        //题目映射
        TextContent questionInfoTextContent = textContentService.selectById(question.getInfoTextContentId());
        QuestionObject questionObject = JsonUtil.toJsonObject(questionInfoTextContent.getContent(), QuestionObject.class);
        QuestionEditRequestVM questionEditRequestVM = modelMapper.map(question, QuestionEditRequestVM.class);
        questionEditRequestVM.setTitle(questionObject.getTitleContent());

        //答案
        QuestionTypeEnum questionTypeEnum = QuestionTypeEnum.fromCode(question.getQuestionType());
        switch (questionTypeEnum) {
            case SingleChoice:
            case TrueFalse:
                questionEditRequestVM.setCorrect(question.getCorrect());
                break;
            case MultipleChoice:
                questionEditRequestVM.setCorrectArray(ExamUtil.contentToArray(question.getCorrect()));
                break;
            case GapFilling:
                List<String> correctContent = questionObject.getQuestionItemObjects().stream().map(d -> d.getContent()).collect(Collectors.toList());
                questionEditRequestVM.setCorrectArray(correctContent);
                break;
            case ShortAnswer:
                questionEditRequestVM.setCorrect(questionObject.getCorrect());
                break;
            default:
                break;
        }
        questionEditRequestVM.setScore(ExamUtil.scoreToVM(question.getScore()));
        questionEditRequestVM.setAnalyze(questionObject.getAnalyze());


        //题目项映射
        List<QuestionEditItemVM> editItems = questionObject.getQuestionItemObjects().stream().map(o -> {
            QuestionEditItemVM questionEditItemVM = modelMapper.map(o, QuestionEditItemVM.class);
            if (o.getScore() != null) {
                questionEditItemVM.setScore(ExamUtil.scoreToVM(o.getScore()));
            }
            return questionEditItemVM;
        }).collect(Collectors.toList());
        questionEditRequestVM.setItems(editItems);
        return questionEditRequestVM;
    }

    public void setQuestionInfoFromVM(TextContent infoTextContent, QuestionEditRequestVM model) {
        List<QuestionItemObject> itemObjects = model.getItems().stream().map(i ->
                {
                    QuestionItemObject item = new QuestionItemObject();
                    item.setPrefix(i.getPrefix());
                    item.setContent(i.getContent());
                    item.setItemUuid(i.getItemUuid());
                    item.setScore(ExamUtil.scoreFromVM(i.getScore()));
                    return item;
                }
        ).collect(Collectors.toList());
        QuestionObject questionObject = new QuestionObject();
        questionObject.setQuestionItemObjects(itemObjects);
        questionObject.setAnalyze(model.getAnalyze());
        questionObject.setTitleContent(model.getTitle());
        questionObject.setCorrect(model.getCorrect());
        infoTextContent.setContent(JsonUtil.toJsonStr(questionObject));
    }

    @Override
    public Integer selectAllCount() {
        return questionMapper.selectAllCount();
    }

    @Override
    public List<Integer> selectMothCount() {
        Date startTime = DateTimeUtil.getMonthStartDay();
        Date endTime = DateTimeUtil.getMonthEndDay();
        List<String> mothStartToNowFormat = DateTimeUtil.MothStartToNowFormat();
        List<KeyValue> mouthCount = questionMapper.selectCountByDate(startTime, endTime);
        return mothStartToNowFormat.stream().map(md -> {
            KeyValue keyValue = mouthCount.stream().filter(kv -> kv.getName().equals(md)).findAny().orElse(null);
            return null == keyValue ? 0 : keyValue.getValue();
        }).collect(Collectors.toList());
    }

    @Override
    @Transactional
    public int uploadAndAnalyzeTxt(MultipartFile file, Integer userId) throws Exception {
        // 读取txt文件内容
        StringBuilder content = new StringBuilder();
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(file.getInputStream(), "UTF-8"))) {
            String line;
            while ((line = reader.readLine()) != null) {
                content.append(line).append("\n");
            }
        }

        // 调用AI API分析题目
        String analysisResult = callAiApi(content.toString());

        // 解析AI返回的结果并插入数据库
        return parseAndInsertQuestions(analysisResult, userId);
    }

    private String callAiApiForTxtContent(String content) throws Exception {
        // 构建AI API请求
        org.springframework.web.client.RestTemplate restTemplate = new org.springframework.web.client.RestTemplate();
        org.springframework.http.HttpHeaders headers = new org.springframework.http.HttpHeaders();
        headers.set("Content-Type", "application/json");

        java.util.Map<String, Object> requestBody = new java.util.HashMap<>();

        if ("glm".equals(aiApiType)) {
            // GLM API调用
            headers.set("Authorization", "Bearer " + aiApiKey);
            requestBody.put("model", "glm-4.5-air");
            requestBody.put("messages", java.util.Arrays.asList(
                new java.util.HashMap<String, String>() {{ put("role", "system"); put("content", "你是一个题目分析助手，需要将txt文件中的题目分解为符合数据库格式的结构。每个题目需要包含：题目类型、学科ID、分数、年级、难度、正确答案、题目内容（包括题干、选项、解析等）。请以JSON格式返回分析结果，每个题目为一个JSON对象，包含所有必要字段。" );
                }},
                new java.util.HashMap<String, String>() {{ put("role", "user"); put("content", content); }}
            ));
            requestBody.put("temperature", 0.7);
        } else {
            // OpenAI API调用
            headers.set("Authorization", "Bearer " + aiApiKey);
            requestBody.put("model", "gpt-3.5-turbo");
            requestBody.put("messages", java.util.Arrays.asList(
                new java.util.HashMap<String, String>() {{ put("role", "system"); put("content", "你是一个题目分析助手，需要将txt文件中的题目分解为符合数据库格式的结构。每个题目需要包含：题目类型、学科ID、分数、年级、难度、正确答案、题目内容（包括题干、选项、解析等）。请以JSON格式返回分析结果，每个题目为一个JSON对象，包含所有必要字段。" );
                }},
                new java.util.HashMap<String, String>() {{ put("role", "user"); put("content", content); }}
            ));
            requestBody.put("temperature", 0.7);
        }

        org.springframework.http.HttpEntity<java.util.Map<String, Object>> entity = new org.springframework.http.HttpEntity<>(requestBody, headers);
        org.springframework.http.ResponseEntity<String> response = restTemplate.postForEntity(aiApiUrl, entity, String.class);

        // 解析AI返回的结果
        com.fasterxml.jackson.databind.ObjectMapper mapper = new com.fasterxml.jackson.databind.ObjectMapper();
        com.fasterxml.jackson.databind.JsonNode rootNode = mapper.readTree(response.getBody());
        
        if ("glm".equals(aiApiType)) {
            // GLM API返回格式解析
            String resultContent = rootNode.path("choices").get(0).path("message").path("content").asText();
            // 清理AI返回的内容，去除多余的格式标记
            resultContent = resultContent.replaceAll("^[`\\s]*json[\\s]*", "");
            resultContent = resultContent.replaceAll("[`\\s]*$", "");
            return resultContent;
        } else {
            // OpenAI API返回格式解析
            String resultContent = rootNode.path("choices").get(0).path("message").path("content").asText();
            // 清理AI返回的内容，去除多余的格式标记
            resultContent = resultContent.replaceAll("^[`\\s]*json[\\s]*", "");
            resultContent = resultContent.replaceAll("[`\\s]*$", "");
            return resultContent;
        }
    }

    private int parseAndInsertQuestions(String analysisResult, Integer userId) throws Exception {
        // 解析AI返回的JSON结果
        com.fasterxml.jackson.databind.ObjectMapper mapper = new com.fasterxml.jackson.databind.ObjectMapper();
        
        // 首先检查是否包含错误信息
        if (analysisResult.contains("error") && analysisResult.contains("message")) {
            // 解析错误信息
            com.fasterxml.jackson.databind.JsonNode errorNode = mapper.readTree(analysisResult);
            if (errorNode.has("error")) {
                String errorMessage = errorNode.path("message").asText();
                throw new Exception("AI分析错误: " + errorMessage);
            }
        }
        
        java.util.List<java.util.Map<String, Object>> questions = mapper.readValue(analysisResult, java.util.List.class);

        int count = 0;
        for (java.util.Map<String, Object> questionMap : questions) {
            // 创建QuestionEditRequestVM对象
            QuestionEditRequestVM model = new QuestionEditRequestVM();
            model.setQuestionType((Integer) questionMap.get("questionType"));
            model.setSubjectId((Integer) questionMap.get("subjectId"));
            model.setScore((String) questionMap.get("score"));
            model.setDifficult((Integer) questionMap.get("difficult"));
            model.setCorrect((String) questionMap.get("correct"));
            model.setTitle((String) questionMap.get("title"));
            model.setAnalyze((String) questionMap.get("analyze"));

            // 处理选项
            java.util.List<java.util.Map<String, Object>> items = (java.util.List<java.util.Map<String, Object>>) questionMap.get("items");
            if (items != null) {
                java.util.List<QuestionEditItemVM> editItems = new java.util.ArrayList<>();
                for (java.util.Map<String, Object> item : items) {
                    QuestionEditItemVM editItem = new QuestionEditItemVM();
                    editItem.setPrefix((String) item.get("prefix"));
                    editItem.setContent((String) item.get("content"));
                    editItem.setItemUuid(java.util.UUID.randomUUID().toString());
                    if (item.containsKey("score")) {
                        editItem.setScore((String) item.get("score"));
                    }
                    editItems.add(editItem);
                }
                model.setItems(editItems);
            }

            // 验证学科ID是否存在
            Integer subjectId = model.getSubjectId();
            if (subjectId == null) {
                throw new Exception("题目数据中缺少学科ID");
            }
            com.mindskip.xzs.domain.Subject subject = subjectService.selectById(subjectId);
            if (subject == null) {
                throw new Exception("学科ID不存在: " + subjectId);
            }

            // 插入题目
            insertFullQuestion(model, userId);
            count++;
        }

        return count;
    }

    @Override
    public String analyzeImageQuestion(MultipartFile file) throws Exception {
        // 将图片转换为Base64编码
        byte[] fileBytes = file.getBytes();
        String base64Image = Base64.getEncoder().encodeToString(fileBytes);
        
        // 获取文件扩展名
        String originalFilename = file.getOriginalFilename();
        String extension = originalFilename != null && originalFilename.contains(".") 
            ? originalFilename.substring(originalFilename.lastIndexOf(".") + 1) 
            : "png";
        
        // 构建图片数据URL
        String imageDataUrl = "data:image/" + extension + ";base64," + base64Image;
        
        System.out.println("Image file: " + originalFilename + ", size: " + fileBytes.length + " bytes");
        System.out.println("Image data URL length: " + imageDataUrl.length());
        
        // 调用AI API分析图片
        String result = callAiApiWithImage(imageDataUrl);
        System.out.println("AI API response: " + result);
        
        return result;
    }

    private String callAiApiWithImage(String imageDataUrl) throws Exception {
        org.springframework.http.client.SimpleClientHttpRequestFactory factory = new org.springframework.http.client.SimpleClientHttpRequestFactory();
        factory.setConnectTimeout(60000);
        factory.setReadTimeout(300000);
        org.springframework.web.client.RestTemplate restTemplate = new org.springframework.web.client.RestTemplate(factory);
        org.springframework.http.HttpHeaders headers = new org.springframework.http.HttpHeaders();
        headers.set("Content-Type", "application/json");

        java.util.Map<String, Object> requestBody = new java.util.HashMap<>();

        if ("glm".equals(aiApiType)) {
            headers.set("Authorization", "Bearer " + aiApiKey);
            requestBody.put("model", "glm-4.6v");
            requestBody.put("messages", java.util.Arrays.asList(
                new java.util.HashMap<String, Object>() {{ 
                    put("role", "system"); 
                    put("content", "你是一个题目分析助手，需要识别图片中的所有题目内容。图片中可能包含多道题目，请逐一分析。对于每道题目，提取以下信息：题目类型（单选题、多选题、判断题、填空题、简答题）、题目内容（题干）、选项（如果有）、正确答案、解析（如果有）。请以JSON数组格式返回结果，数组中每个元素代表一道题目，不要包含任何多余的文字描述。");
                }},
                new java.util.HashMap<String, Object>() {{ 
                    put("role", "user"); 
                    put("content", java.util.Arrays.asList(
                        new java.util.HashMap<String, String>() {{ put("type", "text"); put("text", "请分析这张图片中的所有题目，以JSON数组格式返回"); }},
                        new java.util.HashMap<String, Object>() {{ 
                            put("type", "image_url"); 
                            java.util.Map<String, String> imageUrlMap = new java.util.HashMap<>();
                            imageUrlMap.put("url", imageDataUrl);
                            put("image_url", imageUrlMap); 
                        }}
                    ));
                }}
            ));
            requestBody.put("temperature", 0.7);
            requestBody.put("max_tokens", 8192);
        } else {
            headers.set("Authorization", "Bearer " + aiApiKey);
            requestBody.put("model", "gpt-4o");
            requestBody.put("messages", java.util.Arrays.asList(
                new java.util.HashMap<String, Object>() {{ 
                    put("role", "system"); 
                    put("content", "你是一个题目分析助手，需要识别图片中的所有题目内容。图片中可能包含多道题目，请逐一分析。对于每道题目，提取以下信息：题目类型（单选题、多选题、判断题、填空题、简答题）、题目内容（题干）、选项（如果有）、正确答案、解析（如果有）。请以JSON数组格式返回结果，数组中每个元素代表一道题目，不要包含任何多余的文字描述。");
                }},
                new java.util.HashMap<String, Object>() {{ 
                    put("role", "user"); 
                    put("content", java.util.Arrays.asList(
                        new java.util.HashMap<String, String>() {{ put("type", "text"); put("text", "请分析这张图片中的题目"); }},
                        new java.util.HashMap<String, String>() {{ put("type", "image_url"); put("image_url", imageDataUrl); }}
                    ));
                }}
            ));
            requestBody.put("temperature", 0.7);
        }

        org.springframework.http.HttpEntity<java.util.Map<String, Object>> entity = new org.springframework.http.HttpEntity<>(requestBody, headers);
        
        try {
            org.springframework.http.ResponseEntity<String> response = restTemplate.postForEntity(aiApiUrl, entity, String.class);

            com.fasterxml.jackson.databind.ObjectMapper mapper = new com.fasterxml.jackson.databind.ObjectMapper();
            com.fasterxml.jackson.databind.JsonNode rootNode = mapper.readTree(response.getBody());
            
            if ("glm".equals(aiApiType)) {
                String resultContent = rootNode.path("choices").get(0).path("message").path("content").asText();
                resultContent = resultContent.replaceAll("^[`\\s]*json[\\s]*", "");
                resultContent = resultContent.replaceAll("[`\\s]*$", "");
                return resultContent;
            } else {
                String resultContent = rootNode.path("choices").get(0).path("message").path("content").asText();
                resultContent = resultContent.replaceAll("^[`\\s]*json[\\s]*", "");
                resultContent = resultContent.replaceAll("[`\\s]*$", "");
                return resultContent;
            }
        } catch (org.springframework.web.client.HttpClientErrorException e) {
            throw new Exception("API调用失败: " + e.getStatusCode() + " - " + e.getResponseBodyAsString());
        }
    }

    @Override
    public String analyzeQuestion(String questionType, String questionContent, String options, String correctAnswer) throws Exception {
        String prompt = buildQuestionAnalysisPrompt(questionType, questionContent, options, correctAnswer);
        return callAiApi(prompt);
    }

    private String buildQuestionAnalysisPrompt(String questionType, String questionContent, String options, String correctAnswer) {
        StringBuilder prompt = new StringBuilder();
        prompt.append("直接给出答案，不要思考过程。分析以下题目，输出JSON格式，包含解题思路、知识点、易错点、答案解析四个字段，每个字段不超过50字。\n\n");
        prompt.append("题目：").append(questionContent != null ? questionContent : "").append("\n");
        
        if (options != null && !options.isEmpty()) {
            prompt.append("选项：").append(options).append("\n");
        }
        
        if (correctAnswer != null && !correctAnswer.isEmpty()) {
            prompt.append("答案：").append(correctAnswer).append("\n");
        }
        
        prompt.append("\nJSON输出：");
        
        return prompt.toString();
    }

    private String callAiApi(String prompt) throws Exception {
        org.springframework.http.client.SimpleClientHttpRequestFactory factory = new org.springframework.http.client.SimpleClientHttpRequestFactory();
        factory.setConnectTimeout(60000);
        factory.setReadTimeout(600000);
        org.springframework.web.client.RestTemplate restTemplate = new org.springframework.web.client.RestTemplate(factory);
        org.springframework.http.HttpHeaders headers = new org.springframework.http.HttpHeaders();
        headers.set("Content-Type", "application/json");

        java.util.Map<String, Object> requestBody = new java.util.HashMap<>();

        if ("glm".equals(aiApiType)) {
            headers.set("Authorization", "Bearer " + aiApiKey);
            requestBody.put("model", "glm-4.6v");
            requestBody.put("messages", java.util.Arrays.asList(
                new java.util.HashMap<String, Object>() {{ 
                    put("role", "system"); 
                    put("content", "快速分析题目，简短回答。");
                }},
                new java.util.HashMap<String, Object>() {{ 
                    put("role", "user"); 
                    put("content", prompt);
                }}
            ));
            requestBody.put("temperature", 0.9);
            requestBody.put("max_tokens", 1024);
        } else {
            headers.set("Authorization", "Bearer " + aiApiKey);
            requestBody.put("model", "gpt-4o");
            requestBody.put("messages", java.util.Arrays.asList(
                new java.util.HashMap<String, Object>() {{ 
                    put("role", "system"); 
                    put("content", "快速分析题目，简短回答。");
                }},
                new java.util.HashMap<String, Object>() {{ 
                    put("role", "user"); 
                    put("content", prompt);
                }}
            ));
            requestBody.put("temperature", 0.9);
            requestBody.put("max_tokens", 1024);
        }

        org.springframework.http.HttpEntity<java.util.Map<String, Object>> entity = new org.springframework.http.HttpEntity<>(requestBody, headers);
        
        try {
            org.springframework.http.ResponseEntity<String> response = restTemplate.postForEntity(aiApiUrl, entity, String.class);
            
            System.out.println("AI API响应状态: " + response.getStatusCode());
            System.out.println("AI API响应体: " + response.getBody());

            com.fasterxml.jackson.databind.ObjectMapper mapper = new com.fasterxml.jackson.databind.ObjectMapper();
            com.fasterxml.jackson.databind.JsonNode rootNode = mapper.readTree(response.getBody());
            
            String resultContent = "";
            if ("glm".equals(aiApiType)) {
                com.fasterxml.jackson.databind.JsonNode choices = rootNode.path("choices");
                if (choices.isArray() && choices.size() > 0) {
                    com.fasterxml.jackson.databind.JsonNode message = choices.get(0).path("message");
                    resultContent = message.path("content").asText();
                    // GLM-4.6v可能将内容放在reasoning_content字段中
                    if (resultContent.isEmpty()) {
                        resultContent = message.path("reasoning_content").asText();
                    }
                } else {
                    System.out.println("GLM API返回格式异常，尝试其他路径...");
                    resultContent = rootNode.path("response").asText();
                    if (resultContent.isEmpty()) {
                        resultContent = rootNode.path("data").path("content").asText();
                    }
                }
            } else {
                resultContent = rootNode.path("choices").get(0).path("message").path("content").asText();
            }
            
            System.out.println("提取的内容: '" + resultContent + "'");
            
            resultContent = resultContent.replaceAll("^[`\\s]*json[\\s]*", "");
            resultContent = resultContent.replaceAll("[`\\s]*$", "");
            
            return resultContent;
        } catch (org.springframework.web.client.HttpClientErrorException e) {
            throw new Exception("API调用失败: " + e.getStatusCode() + " - " + e.getResponseBodyAsString());
        } catch (Exception e) {
            throw new Exception("AI响应解析失败: " + e.getMessage());
        }
    }


}
