package com.mindskip.xzs.repository;

import com.mindskip.xzs.domain.rag.RagChunkRecord;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface RagDocumentMapper {

    int backfillDocumentsFromLegacyKnowledgeBase();

    int backfillChunksFromLegacyKnowledgeBase();

    List<RagChunkRecord> selectIndexableChunks(@Param("limit") Integer limit);

    int upsertEmbeddingMetadata(@Param("chunkId") Long chunkId,
                                @Param("embeddingModel") String embeddingModel,
                                @Param("embeddingDimension") Integer embeddingDimension,
                                @Param("vectorStore") String vectorStore,
                                @Param("collectionName") String collectionName,
                                @Param("vectorId") String vectorId,
                                @Param("status") String status,
                                @Param("errorMessage") String errorMessage);
}
