package com.mindskip.xzs.service;

import com.mindskip.xzs.viewmodel.student.ai.AiWorkbenchContextVM;
import com.mindskip.xzs.viewmodel.student.ai.AiWorkbenchRequestVM;
import org.springframework.stereotype.Service;

@Service
public class AiIntentRouter {

    public static final String EXPLAIN_QUESTION = "explain_question";
    public static final String EXPLAIN_KNOWLEDGE = "explain_knowledge";
    public static final String LEARNING_PROFILE = "learning_profile";
    public static final String PRACTICE_PLAN = "practice_plan";
    public static final String COMPOSE_PAPER = "compose_paper";
    public static final String FREE_CHAT = "free_chat";

    public String resolve(AiWorkbenchRequestVM request) {
        String explicit = normalize(request == null ? null : request.getIntent());
        if (isSupported(explicit)) {
            return explicit;
        }

        String message = normalize(request == null ? null : request.getUserMessage());
        if (looksLikePractice(message)) {
            return PRACTICE_PLAN;
        }
        if (looksLikeProfile(message)) {
            return LEARNING_PROFILE;
        }
        if (looksLikeCompose(message)) {
            return COMPOSE_PAPER;
        }

        AiWorkbenchContextVM context = request == null ? null : request.getContext();
        if (context != null) {
            if (context.getQuestion() != null || normalize(context.getPastedText()) != null) {
                return EXPLAIN_QUESTION;
            }
            if (context.getKnowledgePoint() != null) {
                return EXPLAIN_KNOWLEDGE;
            }
        }

        return FREE_CHAT;
    }

    private boolean isSupported(String intent) {
        return EXPLAIN_QUESTION.equals(intent)
                || EXPLAIN_KNOWLEDGE.equals(intent)
                || LEARNING_PROFILE.equals(intent)
                || PRACTICE_PLAN.equals(intent)
                || COMPOSE_PAPER.equals(intent)
                || FREE_CHAT.equals(intent);
    }

    private boolean looksLikePractice(String message) {
        return message != null && message.matches(".*(练习|组卷|出题|挑选|生成.*卷|针对.*题|同类题).*");
    }

    private boolean looksLikeProfile(String message) {
        return message != null && message.matches(".*(学习画像|薄弱点|学习状态|掌握情况|复习建议|正确率).*");
    }

    private boolean looksLikeCompose(String message) {
        return message != null && (message.contains("/compose paper") || message.matches(".*(直接建卷|确认生成试卷).*"));
    }

    private String normalize(String value) {
        return value == null || value.trim().isEmpty() ? null : value.trim();
    }
}
