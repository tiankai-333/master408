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
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
public class KnowledgeGraphServiceImpl implements KnowledgeGraphService {

    private final KnowledgePointMapper knowledgePointMapper;
    private final QuestionKnowledgePointMapper questionKnowledgePointMapper;
    private final QuestionMapper questionMapper;
    private final SubjectMapper subjectMapper;
    private final JdbcTemplate jdbcTemplate;

    @Autowired
    public KnowledgeGraphServiceImpl(KnowledgePointMapper knowledgePointMapper,
                                     QuestionKnowledgePointMapper questionKnowledgePointMapper,
                                     QuestionMapper questionMapper,
                                     SubjectMapper subjectMapper,
                                     JdbcTemplate jdbcTemplate) {
        this.knowledgePointMapper = knowledgePointMapper;
        this.questionKnowledgePointMapper = questionKnowledgePointMapper;
        this.questionMapper = questionMapper;
        this.subjectMapper = subjectMapper;
        this.jdbcTemplate = jdbcTemplate;
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
                Map<String, Object> questionMap = buildQuestionSummary(question);
                questionList.add(questionMap);
            }
        }
        if (questionList.isEmpty()) {
            questionList.addAll(findFallbackQuestions(kp));
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
                map.putAll(loadQuestionDisplayFields(question.getId()));
                result.add(map);
            }
        }

        return result;
    }

    private Map<String, Object> buildQuestionSummary(Question question) {
        Map<String, Object> questionMap = new HashMap<>();
        questionMap.put("id", question.getId());
        questionMap.put("questionType", question.getQuestionType());
        questionMap.put("difficult", question.getDifficult());
        questionMap.put("subjectId", question.getSubjectId());
        questionMap.putAll(loadQuestionDisplayFields(question.getId()));
        return questionMap;
    }

    private Map<String, Object> loadQuestionDisplayFields(Integer questionId) {
        Map<String, Object> result = new HashMap<>();
        if (questionId == null) return result;
        try {
            Map<String, Object> row = jdbcTemplate.queryForMap(
                    "SELECT q.title_text, JSON_UNQUOTE(JSON_EXTRACT(tc.content, '$.titleContent')) AS content_title, " +
                            "q.source, q.source_year, q.source_question_no " +
                            "FROM t_question q LEFT JOIN t_text_content tc ON q.info_text_content_id = tc.id WHERE q.id = ?",
                    questionId);
            String title = trimToLength(firstText(row.get("title_text"), row.get("content_title")), 72);
            if (title == null || title.isEmpty()) {
                title = "真题 #" + questionId;
            }
            result.put("title", title);
            Object year = row.get("source_year");
            Object no = row.get("source_question_no");
            String source = year != null ? year + "年408真题" : String.valueOf(row.getOrDefault("source", "408真题"));
            if (no != null) {
                source += " 第" + no + "题";
            }
            result.put("source", source);
        } catch (Exception e) {
            result.put("title", "真题 #" + questionId);
            result.put("source", "408真题");
        }
        return result;
    }

    private List<Map<String, Object>> findFallbackQuestions(KnowledgePoint kp) {
        List<Map<String, Object>> result = new ArrayList<>();
        if (kp == null || kp.getSubjectId() == null) return result;
        List<String> keywords = buildQuestionSearchKeywords(kp);
        try {
            List<Object> params = new ArrayList<>();
            params.add(kp.getSubjectId());
            StringBuilder matchSql = new StringBuilder();
            for (String keyword : keywords) {
                if (matchSql.length() > 0) {
                    matchSql.append(" OR ");
                }
                matchSql.append("(q.tags LIKE ? OR q.knowledge_point LIKE ? OR q.title_text LIKE ? OR q.analysis_text LIKE ? OR tc.content LIKE ?)");
                String like = "%" + keyword + "%";
                params.add(like);
                params.add(like);
                params.add(like);
                params.add(like);
                params.add(like);
            }
            List<Map<String, Object>> rows = matchSql.length() == 0 ? Collections.emptyList() : jdbcTemplate.queryForList(
                    "SELECT q.id, q.question_type, q.difficult, q.subject_id, q.title_text, " +
                            "JSON_UNQUOTE(JSON_EXTRACT(tc.content, '$.titleContent')) AS content_title, " +
                            "q.source, q.source_year, q.source_question_no, q.tags " +
                            "FROM t_question q LEFT JOIN t_text_content tc ON q.info_text_content_id = tc.id " +
                            "WHERE q.deleted = FALSE AND q.subject_id = ? AND (" + matchSql + ") " +
                            "ORDER BY CASE WHEN q.tags LIKE ? THEN 0 ELSE 1 END, q.source_year DESC, q.source_question_no ASC, q.id ASC LIMIT 8",
                    appendExactTagParam(params, kp.getName()).toArray());
            if (rows.isEmpty()) {
                rows = jdbcTemplate.queryForList(
                        "SELECT q.id, q.question_type, q.difficult, q.subject_id, q.title_text, " +
                                "JSON_UNQUOTE(JSON_EXTRACT(tc.content, '$.titleContent')) AS content_title, " +
                                "q.source, q.source_year, q.source_question_no " +
                                "FROM t_question q LEFT JOIN t_text_content tc ON q.info_text_content_id = tc.id " +
                                "WHERE q.deleted = FALSE AND q.subject_id = ? " +
                                "ORDER BY source_year DESC, source_question_no ASC, id ASC LIMIT 5",
                        kp.getSubjectId());
            }
            for (Map<String, Object> row : rows) {
                Map<String, Object> item = new HashMap<>();
                item.put("id", row.get("id"));
                item.put("questionType", row.get("question_type"));
                item.put("difficult", row.get("difficult"));
                item.put("subjectId", row.get("subject_id"));
                String title = trimToLength(firstText(row.get("title_text"), row.get("content_title")), 72);
                item.put("title", title == null || title.isEmpty() ? "真题 #" + row.get("id") : title);
                Object year = row.get("source_year");
                Object no = row.get("source_question_no");
                String source = year != null ? year + "年408真题" : String.valueOf(row.getOrDefault("source", "408真题"));
                if (no != null) {
                    source += " 第" + no + "题";
                }
                item.put("source", source);
                result.add(item);
            }
        } catch (Exception e) {
            return result;
        }
        return result;
    }

    private List<Object> appendExactTagParam(List<Object> params, String name) {
        List<Object> values = new ArrayList<>(params);
        values.add("%" + (name == null ? "" : name) + "%");
        return values;
    }

    private List<String> buildQuestionSearchKeywords(KnowledgePoint kp) {
        LinkedHashSet<String> keywords = new LinkedHashSet<>();
        addKeyword(keywords, kp.getName());
        try {
            for (KnowledgePoint child : knowledgePointMapper.findByParentId(kp.getId())) {
                addKeyword(keywords, child.getName());
            }
        } catch (Exception e) {
            // 子知识点只用于增强召回，失败时退回名称匹配。
        }

        Map<String, String[]> aliases = new HashMap<>();
        aliases.put("查找", new String[]{"顺序查找", "分块查找", "折半查找", "二叉排序树", "平衡二叉树", "B树", "B+树", "散列表", "哈希表", "平均查找长度"});
        aliases.put("进程管理", new String[]{"进程", "线程", "进程状态", "进程控制块", "进程同步", "进程互斥", "信号量", "管程", "死锁", "处理机调度", "CPU调度"});
        aliases.put("线性表", new String[]{"顺序表", "链表", "单链表", "双链表"});
        aliases.put("树与二叉树", new String[]{"二叉树", "树", "森林", "哈夫曼树", "哈夫曼编码", "线索二叉树", "完全二叉树"});
        aliases.put("图", new String[]{"邻接矩阵", "邻接表", "DFS", "BFS", "拓扑排序", "关键路径", "最小生成树", "最短路径"});
        aliases.put("排序", new String[]{"排序算法", "插入排序", "希尔排序", "快速排序", "归并排序", "堆排序", "基数排序"});
        aliases.put("传输层", new String[]{"TCP", "UDP", "拥塞控制", "流量控制", "可靠传输", "三次握手", "四次挥手"});

        for (Map.Entry<String, String[]> entry : aliases.entrySet()) {
            if (kp.getName() != null && kp.getName().contains(entry.getKey())) {
                for (String alias : entry.getValue()) {
                    addKeyword(keywords, alias);
                }
            }
        }
        return new ArrayList<>(keywords);
    }

    private void addKeyword(Set<String> keywords, String keyword) {
        if (keyword == null) return;
        String normalized = keyword.trim().replaceAll("\\s+", "");
        if (normalized.length() >= 2) {
            keywords.add(normalized);
        }
    }

    private String firstText(Object... values) {
        for (Object value : values) {
            if (value == null) continue;
            String text = String.valueOf(value).trim();
            if (!text.isEmpty() && !"null".equalsIgnoreCase(text)) {
                return text;
            }
        }
        return "";
    }

    private String trimToLength(String text, int maxLength) {
        if (text == null) return "";
        String normalized = text.replaceAll("\\s+", " ").trim();
        if (normalized.length() <= maxLength) return normalized;
        return normalized.substring(0, maxLength) + "...";
    }
}
