package com.mindskip.xzs.domain.rag;

import java.io.Serializable;

public class RagChunkRecord implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long id;
    private Long documentId;
    private Integer chunkIndex;
    private String title;
    private String content;
    private String contentText;
    private Integer subjectId;
    private Integer knowledgePointId;
    private String citationLabel;
    private String sourcePosition;
    private String vectorId;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getDocumentId() { return documentId; }
    public void setDocumentId(Long documentId) { this.documentId = documentId; }
    public Integer getChunkIndex() { return chunkIndex; }
    public void setChunkIndex(Integer chunkIndex) { this.chunkIndex = chunkIndex; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    public String getContentText() { return contentText; }
    public void setContentText(String contentText) { this.contentText = contentText; }
    public Integer getSubjectId() { return subjectId; }
    public void setSubjectId(Integer subjectId) { this.subjectId = subjectId; }
    public Integer getKnowledgePointId() { return knowledgePointId; }
    public void setKnowledgePointId(Integer knowledgePointId) { this.knowledgePointId = knowledgePointId; }
    public String getCitationLabel() { return citationLabel; }
    public void setCitationLabel(String citationLabel) { this.citationLabel = citationLabel; }
    public String getSourcePosition() { return sourcePosition; }
    public void setSourcePosition(String sourcePosition) { this.sourcePosition = sourcePosition; }
    public String getVectorId() { return vectorId; }
    public void setVectorId(String vectorId) { this.vectorId = vectorId; }
}
