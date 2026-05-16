package com.mindskip.xzs.service.impl;

import com.mindskip.xzs.service.AiLearningProfileService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
public class AiLearningProfileServiceImpl implements AiLearningProfileService {

    private static final Logger logger = LoggerFactory.getLogger(AiLearningProfileServiceImpl.class);

    private final JdbcTemplate jdbcTemplate;

    public AiLearningProfileServiceImpl(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    public String buildProfileSummary(Integer userId) {
        if (userId == null) {
            return "";
        }
        try {
            ensureProfile(userId);
            List<Map<String, Object>> rows = jdbcTemplate.queryForList(
                "SELECT profile_summary, strengths, weaknesses, preferred_style, total_ai_requests " +
                    "FROM t_user_learning_profile WHERE user_id = ?",
                userId
            );
            if (rows.isEmpty()) {
                return "";
            }
            Map<String, Object> row = rows.get(0);
            StringBuilder summary = new StringBuilder();
            appendLine(summary, "画像摘要", row.get("profile_summary"));
            appendLine(summary, "优势", row.get("strengths"));
            appendLine(summary, "薄弱点", row.get("weaknesses"));
            appendLine(summary, "偏好风格", row.get("preferred_style"));
            appendLine(summary, "AI使用次数", row.get("total_ai_requests"));
            return summary.toString().trim();
        } catch (Exception e) {
            logger.warn("Failed to build learning profile summary: {}", e.getMessage());
            return "";
        }
    }

    @Override
    public String buildFeedbackNotes(Integer userId, String style) {
        if (userId == null || style == null || style.trim().isEmpty() || "default".equals(style)) {
            return "";
        }
        try {
            List<Map<String, Object>> rows = jdbcTemplate.queryForList(
                "SELECT rating, adjustment_note FROM t_user_skill_feedback " +
                    "WHERE user_id = ? AND style = ? ORDER BY create_time DESC LIMIT 5",
                userId, style
            );
            StringBuilder notes = new StringBuilder();
            for (Map<String, Object> row : rows) {
                appendLine(notes, "评分", row.get("rating"));
                appendLine(notes, "反馈", row.get("adjustment_note"));
            }
            return notes.toString().trim();
        } catch (Exception e) {
            logger.warn("Failed to build feedback notes: {}", e.getMessage());
            return "";
        }
    }

    @Override
    public void recordAiAnalyze(Integer userId, String style, Integer usageLogId, String question, String response) {
        if (userId == null) {
            return;
        }
        try {
            ensureProfile(userId);
            String summary = abbreviate(question, 180);
            jdbcTemplate.update(
                "INSERT INTO t_user_learning_event(user_id, event_type, style, target_type, target_id, summary, metadata, create_time) " +
                    "VALUES (?, 'ai_analyze', ?, 'ai_usage_log', ?, ?, ?, NOW())",
                userId, style, usageLogId, summary, "{\"responseLength\":" + (response == null ? 0 : response.length()) + "}"
            );
            jdbcTemplate.update(
                "UPDATE t_user_learning_profile SET total_ai_requests = total_ai_requests + 1, " +
                    "profile_summary = ?, preferred_style = COALESCE(preferred_style, ?), last_event_time = NOW() " +
                    "WHERE user_id = ?",
                "最近使用AI解析题目，偏好会随反馈逐步更新。", style, userId
            );
        } catch (Exception e) {
            logger.warn("Failed to record AI analyze event: {}", e.getMessage());
        }
    }

    @Override
    public void saveSkillFeedback(Integer userId, Integer usageLogId, String style, Integer rating, String feedback) {
        if (userId == null || style == null || style.trim().isEmpty()) {
            return;
        }
        try {
            ensureProfile(userId);
            String note = buildAdjustmentNote(style, rating, feedback);
            jdbcTemplate.update(
                "INSERT INTO t_user_skill_feedback(user_id, usage_log_id, style, rating, feedback, adjustment_note, create_time) " +
                    "VALUES (?, ?, ?, ?, ?, ?, NOW())",
                userId, usageLogId, style, rating == null ? 0 : rating, feedback, note
            );
            jdbcTemplate.update(
                "INSERT INTO t_user_learning_event(user_id, event_type, style, target_type, target_id, summary, metadata, create_time) " +
                    "VALUES (?, 'ai_feedback', ?, 'ai_usage_log', ?, ?, NULL, NOW())",
                userId, style, usageLogId, note
            );
            jdbcTemplate.update(
                "UPDATE t_user_learning_profile SET preferred_style = ?, last_event_time = NOW() WHERE user_id = ?",
                style, userId
            );
        } catch (Exception e) {
            logger.warn("Failed to save skill feedback: {}", e.getMessage());
        }
    }

    private void ensureProfile(Integer userId) {
        jdbcTemplate.update(
            "INSERT INTO t_user_learning_profile(user_id, profile_summary, total_ai_requests, create_time, update_time) " +
                "VALUES (?, '', 0, NOW(), NOW()) " +
                "ON DUPLICATE KEY UPDATE update_time = update_time",
            userId
        );
    }

    private String buildAdjustmentNote(String style, Integer rating, String feedback) {
        String text = feedback == null ? "" : feedback.trim();
        if (rating != null && rating > 0 && rating <= 3) {
            return "学生对" + style + "风格满意度偏低；下次请更慢、更具体，并减少空泛表述。" +
                (text.isEmpty() ? "" : " 学生反馈：" + abbreviate(text, 160));
        }
        if (!text.isEmpty()) {
            return "学生对" + style + "风格的偏好：" + abbreviate(text, 180);
        }
        return "学生最近使用并反馈了" + style + "风格。";
    }

    private void appendLine(StringBuilder sb, String label, Object value) {
        if (value != null && !String.valueOf(value).trim().isEmpty()) {
            sb.append("- ").append(label).append(": ").append(value).append("\n");
        }
    }

    private String abbreviate(String value, int max) {
        if (value == null) {
            return "";
        }
        String trimmed = value.trim();
        if (trimmed.length() <= max) {
            return trimmed;
        }
        return trimmed.substring(0, max) + "...";
    }
}
