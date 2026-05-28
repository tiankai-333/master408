package com.mindskip.xzs.viewmodel.student.ai;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

@JsonIgnoreProperties(ignoreUnknown = true)
public class AiWorkbenchRequestVM {

    private String intent;
    private String style;
    private AiWorkbenchContextVM context;
    private String userMessage;

    public String getIntent() {
        return intent;
    }

    public void setIntent(String intent) {
        this.intent = intent;
    }

    public String getStyle() {
        return style;
    }

    public void setStyle(String style) {
        this.style = style;
    }

    public AiWorkbenchContextVM getContext() {
        return context;
    }

    public void setContext(AiWorkbenchContextVM context) {
        this.context = context;
    }

    public String getUserMessage() {
        return userMessage;
    }

    public void setUserMessage(String userMessage) {
        this.userMessage = userMessage;
    }
}
