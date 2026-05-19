package com.mindskip.xzs.service.impl;

import com.mindskip.xzs.domain.rag.RagChunkRecord;
import com.mindskip.xzs.repository.RagDocumentMapper;
import com.mindskip.xzs.service.RagDocumentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class RagDocumentServiceImpl implements RagDocumentService {

    @Autowired
    private RagDocumentMapper ragDocumentMapper;

    @Override
    public int backfillFromLegacyKnowledgeBase() {
        int documents = ragDocumentMapper.backfillDocumentsFromLegacyKnowledgeBase();
        int chunks = ragDocumentMapper.backfillChunksFromLegacyKnowledgeBase();
        return documents + chunks;
    }

    @Override
    public List<RagChunkRecord> listIndexableChunks(int limit) {
        int safeLimit = limit <= 0 ? 100 : Math.min(limit, 1000);
        return ragDocumentMapper.selectIndexableChunks(safeLimit);
    }

    @Override
    public void markIndexed(Long chunkId, String model, Integer dimension, String collectionName, String vectorId) {
        ragDocumentMapper.upsertEmbeddingMetadata(chunkId, model, dimension, "qdrant", collectionName, vectorId, "indexed", null);
    }

    @Override
    public void markIndexFailed(Long chunkId, String model, Integer dimension, String collectionName, String vectorId, String errorMessage) {
        String message = errorMessage == null ? null : errorMessage.substring(0, Math.min(errorMessage.length(), 1000));
        ragDocumentMapper.upsertEmbeddingMetadata(chunkId, model, dimension, "qdrant", collectionName, vectorId, "failed", message);
    }
}
