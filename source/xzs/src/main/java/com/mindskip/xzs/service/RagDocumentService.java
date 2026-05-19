package com.mindskip.xzs.service;

import com.mindskip.xzs.domain.rag.RagChunkRecord;

import java.util.List;

public interface RagDocumentService {

    int backfillFromLegacyKnowledgeBase();

    List<RagChunkRecord> listIndexableChunks(int limit);

    void markIndexed(Long chunkId, String model, Integer dimension, String collectionName, String vectorId);

    void markIndexFailed(Long chunkId, String model, Integer dimension, String collectionName, String vectorId, String errorMessage);
}
