package com.mindskip.xzs.service.impl;

import com.mindskip.xzs.domain.Question;
import com.mindskip.xzs.domain.canonical.QuestionContent;
import com.mindskip.xzs.repository.QuestionContentMapper;
import com.mindskip.xzs.service.QuestionContentService;
import com.mindskip.xzs.utility.JsonUtil;
import com.mindskip.xzs.viewmodel.admin.question.QuestionEditRequestVM;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;

@Service
public class QuestionContentServiceImpl implements QuestionContentService {

    @Autowired
    private QuestionContentMapper questionContentMapper;

    @Override
    public QuestionContent getCurrent(Integer questionId) {
        if (questionId == null) {
            return null;
        }
        return questionContentMapper.selectCurrentByQuestionId(questionId);
    }

    @Override
    @Transactional
    public QuestionContent saveFromEdit(Question question, QuestionEditRequestVM model) {
        if (question == null || question.getId() == null || model == null) {
            return null;
        }
        Integer maxVersion = questionContentMapper.selectMaxVersion(question.getId());
        QuestionContent content = new QuestionContent();
        content.setQuestionId(question.getId());
        content.setVersion(maxVersion == null ? 1 : maxVersion + 1);
        content.setTitle(model.getTitle());
        content.setOptions(JsonUtil.toJsonStr(model.getItems()));
        content.setCorrectAnswer(question.getCorrect());
        content.setAnalysis(model.getAnalyze());
        content.setTitleText(stripHtml(model.getTitle()));
        content.setAnalysisText(stripHtml(model.getAnalyze()));
        content.setContentFormat("html");
        content.setHasImage(containsIgnoreCase(model.getTitle(), "<img") || containsIgnoreCase(model.getAnalyze(), "<img"));
        content.setHasCode(containsIgnoreCase(model.getTitle(), "<code") || containsIgnoreCase(model.getAnalyze(), "<code")
                || containsIgnoreCase(model.getTitle(), "```") || containsIgnoreCase(model.getAnalyze(), "```"));
        content.setLegacyTextContentId(question.getInfoTextContentId());
        content.setSourceHash(sha256(question.getId() + "|" + content.getTitle() + "|" + content.getOptions() + "|" + content.getCorrectAnswer() + "|" + content.getAnalysis()));
        content.setCurrent(true);
        questionContentMapper.clearCurrent(question.getId());
        questionContentMapper.insert(content);
        return content;
    }

    @Override
    public int backfillFromLegacy() {
        return questionContentMapper.backfillFromLegacy();
    }

    @Override
    public int countCurrent() {
        return questionContentMapper.countCurrent();
    }

    private boolean containsIgnoreCase(String text, String keyword) {
        return text != null && keyword != null && text.toLowerCase().contains(keyword.toLowerCase());
    }

    private String stripHtml(String html) {
        if (html == null) {
            return null;
        }
        return html.replaceAll("<[^>]+>", " ").replaceAll("\\s+", " ").trim();
    }

    private String sha256(String text) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(text.getBytes(StandardCharsets.UTF_8));
            StringBuilder builder = new StringBuilder();
            for (byte b : hash) {
                builder.append(String.format("%02x", b));
            }
            return builder.toString();
        } catch (Exception e) {
            return null;
        }
    }
}
