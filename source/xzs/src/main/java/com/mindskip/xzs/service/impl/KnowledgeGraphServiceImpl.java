package com.mindskip.xzs.service.impl;

import com.mindskip.xzs.domain.KnowledgePoint;
import com.mindskip.xzs.domain.Question;
import com.mindskip.xzs.domain.QuestionKnowledgePoint;
import com.mindskip.xzs.domain.Subject;
import com.mindskip.xzs.repository.KnowledgePointMapper;
import com.mindskip.xzs.repository.QuestionKnowledgePointMapper;
import com.mindskip.xzs.repository.QuestionMapper;
import com.mindskip.xzs.repository.SubjectMapper;
import com.mindskip.xzs.service.KnowledgeGraphService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
public class KnowledgeGraphServiceImpl implements KnowledgeGraphService {

    private final KnowledgePointMapper knowledgePointMapper;
    private final QuestionKnowledgePointMapper questionKnowledgePointMapper;
    private final QuestionMapper questionMapper;
    private final SubjectMapper subjectMapper;

    @Autowired
    public KnowledgeGraphServiceImpl(KnowledgePointMapper knowledgePointMapper,
                                     QuestionKnowledgePointMapper questionKnowledgePointMapper,
                                     QuestionMapper questionMapper,
                                     SubjectMapper subjectMapper) {
        this.knowledgePointMapper = knowledgePointMapper;
        this.questionKnowledgePointMapper = questionKnowledgePointMapper;
        this.questionMapper = questionMapper;
        this.subjectMapper = subjectMapper;
    }

    @Override
    public Map<String, Object> getKnowledgeGraph(Integer subjectId) {
        Map<String, Object> result = new HashMap<>();
        
        List<Map<String, Object>> nodes = new ArrayList<>();
        List<Map<String, Object>> links = new ArrayList<>();
        List<Map<String, Object>> categoryList = new ArrayList<>();

        try {
            List<KnowledgePoint> knowledgePoints;
            if (subjectId != null) {
                knowledgePoints = knowledgePointMapper.findBySubjectId(subjectId);
            } else {
                knowledgePoints = knowledgePointMapper.findAll();
            }

            if (knowledgePoints == null || knowledgePoints.isEmpty()) {
                result.put("nodes", nodes);
                result.put("links", links);
                result.put("categories", categoryList);
                return result;
            }

            Set<Integer> subjectIds = new HashSet<>();
            for (KnowledgePoint kp : knowledgePoints) {
                if (kp != null && kp.getSubjectId() != null) {
                    subjectIds.add(kp.getSubjectId());
                }
            }

            Map<Integer, Subject> subjectMap = new HashMap<>();
            for (Integer id : subjectIds) {
                try {
                    Subject subject = subjectMapper.selectByPrimaryKey(id);
                    if (subject != null) {
                        subjectMap.put(id, subject);
                    }
                } catch (Exception e) {
                    // 忽略单个学科查询失败
                }
            }

            int categoryIndex = 0;
            Map<String, Integer> categoryMap = new HashMap<>();

            for (Subject subject : subjectMap.values()) {
                if (subject == null) continue;
                String categoryName = subject.getName();
                if (!categoryMap.containsKey(categoryName)) {
                    categoryMap.put(categoryName, categoryIndex);
                    Map<String, Object> category = new HashMap<>();
                    category.put("name", categoryName);
                    categoryList.add(category);
                    categoryIndex++;
                }

                Map<String, Object> node = new HashMap<>();
                node.put("id", "subject_" + subject.getId());
                node.put("name", subject.getName());
                node.put("category", categoryMap.get(categoryName));
                node.put("type", "subject");
                node.put("symbolSize", 80);
                nodes.add(node);
            }

            Map<Integer, KnowledgePoint> kpMap = new HashMap<>();
            for (KnowledgePoint kp : knowledgePoints) {
                if (kp == null) continue;
                kpMap.put(kp.getId(), kp);

                Subject subject = subjectMap.get(kp.getSubjectId());
                String categoryName = subject != null ? subject.getName() : "未分类";
                if (!categoryMap.containsKey(categoryName)) {
                    categoryMap.put(categoryName, categoryIndex);
                    Map<String, Object> category = new HashMap<>();
                    category.put("name", categoryName);
                    categoryList.add(category);
                    categoryIndex++;
                }

                Map<String, Object> node = new HashMap<>();
                node.put("id", "kp_" + kp.getId());
                node.put("name", kp.getName());
                node.put("category", categoryMap.get(categoryName));
                node.put("type", "knowledge_point");
                node.put("symbolSize", 40 + (kp.getLevel() != null ? kp.getLevel() * 5 : 0));
                node.put("level", kp.getLevel());
                node.put("description", kp.getDescription());
                nodes.add(node);

                if (subject != null) {
                    Map<String, Object> link = new HashMap<>();
                    link.put("source", "subject_" + subject.getId());
                    link.put("target", "kp_" + kp.getId());
                    link.put("relation", "包含");
                    links.add(link);
                }

                if (kp.getParentId() != null && kpMap.containsKey(kp.getParentId())) {
                    Map<String, Object> link = new HashMap<>();
                    link.put("source", "kp_" + kp.getParentId());
                    link.put("target", "kp_" + kp.getId());
                    link.put("relation", "包含");
                    links.add(link);
                }
            }
        } catch (Exception e) {
            // 记录错误日志
            e.printStackTrace();
        }

        result.put("nodes", nodes);
        result.put("links", links);
        result.put("categories", categoryList);

        return result;
    }

    @Override
    public Map<String, Object> getKnowledgePointDetail(Integer knowledgePointId) {
        Map<String, Object> result = new HashMap<>();

        KnowledgePoint kp = knowledgePointMapper.findById(knowledgePointId);
        if (kp == null) {
            return result;
        }

        result.put("id", kp.getId());
        result.put("name", kp.getName());
        result.put("description", kp.getDescription());
        result.put("level", kp.getLevel());

        if (kp.getSubjectId() != null) {
            Subject subject = subjectMapper.selectByPrimaryKey(kp.getSubjectId());
            if (subject != null) {
                result.put("subjectName", subject.getName());
            }
        }

        if (kp.getParentId() != null) {
            KnowledgePoint parent = knowledgePointMapper.findById(kp.getParentId());
            if (parent != null) {
                result.put("parentName", parent.getName());
            }
        }

        List<KnowledgePoint> children = knowledgePointMapper.findByParentId(knowledgePointId);
        List<Map<String, Object>> childList = new ArrayList<>();
        for (KnowledgePoint child : children) {
            Map<String, Object> childMap = new HashMap<>();
            childMap.put("id", child.getId());
            childMap.put("name", child.getName());
            childList.add(childMap);
        }
        result.put("children", childList);

        List<QuestionKnowledgePoint> qkps = questionKnowledgePointMapper.findByKnowledgePointId(knowledgePointId);
        List<Map<String, Object>> questionList = new ArrayList<>();
        for (QuestionKnowledgePoint qkp : qkps) {
            Question question = questionMapper.selectByPrimaryKey(qkp.getQuestionId());
            if (question != null) {
                Map<String, Object> questionMap = new HashMap<>();
                questionMap.put("id", question.getId());
                questionMap.put("questionType", question.getQuestionType());
                questionMap.put("difficult", question.getDifficult());
                questionList.add(questionMap);
            }
        }
        result.put("relatedQuestions", questionList);

        return result;
    }

    @Override
    public List<Map<String, Object>> getQuestionKnowledgePoints(Integer questionId) {
        List<Map<String, Object>> result = new ArrayList<>();

        List<QuestionKnowledgePoint> qkps = questionKnowledgePointMapper.findByQuestionId(questionId);
        for (QuestionKnowledgePoint qkp : qkps) {
            KnowledgePoint kp = knowledgePointMapper.findById(qkp.getKnowledgePointId());
            if (kp != null) {
                Map<String, Object> map = new HashMap<>();
                map.put("id", kp.getId());
                map.put("name", kp.getName());
                map.put("relevance", qkp.getRelevance());
                result.add(map);
            }
        }

        return result;
    }

    @Override
    public List<Map<String, Object>> getKnowledgePointQuestions(Integer knowledgePointId, Integer limit) {
        List<Map<String, Object>> result = new ArrayList<>();

        List<QuestionKnowledgePoint> qkps = questionKnowledgePointMapper.findByKnowledgePointId(knowledgePointId);
        if (limit != null && qkps.size() > limit) {
            qkps = qkps.subList(0, limit);
        }

        for (QuestionKnowledgePoint qkp : qkps) {
            Question question = questionMapper.selectByPrimaryKey(qkp.getQuestionId());
            if (question != null) {
                Map<String, Object> map = new HashMap<>();
                map.put("id", question.getId());
                map.put("questionType", question.getQuestionType());
                map.put("difficult", question.getDifficult());
                map.put("subjectId", question.getSubjectId());
                result.add(map);
            }
        }

        return result;
    }
}