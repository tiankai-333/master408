package com.mindskip.xzs.service;

import com.mindskip.xzs.domain.rag.RagChunkRecord;

import java.util.List;
import java.util.Map;

public interface RagIndexService {

    boolean isEnabled();

    void upsert(RagChunkRecord chunk, float[] embedding);

    List<Map<String, Object>> search(float[] queryEmbedding, int topK);
}
