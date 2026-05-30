package com.mindskip.xzs.controller.admin;

import com.mindskip.xzs.base.BaseApiController;
import com.mindskip.xzs.base.RestResponse;
import com.mindskip.xzs.ai.RagService;
import com.mindskip.xzs.domain.ai.AiProviderConfig;
import com.mindskip.xzs.domain.rag.RagChunkRecord;
import com.mindskip.xzs.service.AiProviderConfigService;
import com.mindskip.xzs.service.RagDocumentService;
import com.mindskip.xzs.service.RagIndexService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController("AdminAiConfigController")
@RequestMapping("/api/admin/ai-config")
public class AiConfigController extends BaseApiController {

    private static final Logger logger = LoggerFactory.getLogger(AiConfigController.class);

    @Autowired
    private AiProviderConfigService aiProviderConfigService;

    @Autowired
    private RagDocumentService ragDocumentService;

    @Autowired
    private RagService ragService;

    @Autowired
    private RagIndexService ragIndexService;

    @PostMapping("/providers")
    public RestResponse<List<AiProviderConfig>> providers() {
        return RestResponse.ok(aiProviderConfigService.listSafe());
    }

    @PostMapping("/provider/save")
    public RestResponse<AiProviderConfig> saveProvider(@RequestBody Map<String, Object> request) {
        AiProviderConfig config = new AiProviderConfig();
        Object id = request.get("id");
        config.setId(id == null || "".equals(String.valueOf(id)) ? null : Integer.valueOf(String.valueOf(id)));
        config.setProviderCode(stringValue(request.get("providerCode")));
        config.setProviderName(stringValue(request.get("providerName")));
        config.setApiBaseUrl(stringValue(request.get("apiBaseUrl")));
        config.setChatModel(stringValue(request.get("chatModel")));
        config.setEmbeddingModel(stringValue(request.get("embeddingModel")));
        config.setEnabled(booleanValue(request.get("enabled")));
        Object priority = request.get("priority");
        config.setPriority(priority == null || "".equals(String.valueOf(priority)) ? 100 : Integer.valueOf(String.valueOf(priority)));
        String plainApiKey = stringValue(request.get("apiKey"));
        return RestResponse.ok(aiProviderConfigService.save(config, plainApiKey));
    }

    @PostMapping("/provider/{id}/test")
    public RestResponse<Map<String, Object>> testProvider(@PathVariable Integer id) {
        return RestResponse.ok(aiProviderConfigService.test(id));
    }

    @PostMapping("/provider/delete/{id}")
    public RestResponse deleteProvider(@PathVariable Integer id) {
        aiProviderConfigService.deleteById(id);
        return RestResponse.ok();
    }

    @PostMapping("/usage")
    public RestResponse<Map<String, Object>> usage(@RequestBody(required = false) Map<String, Object> request) {
        Integer days = 30;
        if (request != null && request.get("days") != null) {
            days = Integer.valueOf(String.valueOf(request.get("days")));
        }
        return RestResponse.ok(aiProviderConfigService.usage(days));
    }

    @PostMapping("/rag/index")
    public RestResponse<Map<String, Object>> ragIndex(@RequestBody(required = false) Map<String, Object> request) {
        if (!ragIndexService.isEnabled()) {
            return RestResponse.fail(1, "Qdrant 未启用，请检查配置 ai.rag.vector.enabled");
        }

        String source = request != null ? stringValue(String.valueOf(request.getOrDefault("source", "all"))) : "all";
        int backfilled = 0;

        if ("questions".equals(source) || "all".equals(source)) {
            int count = ragDocumentService.backfillFromQuestions();
            backfilled += count;
            logger.info("Backfilled {} question records into rag_document/rag_chunk", count);
        }
        if ("knowledge".equals(source) || "all".equals(source)) {
            int count = ragDocumentService.backfillFromLegacyKnowledgeBase();
            backfilled += count;
            logger.info("Backfilled {} knowledge base records into rag_document/rag_chunk", count);
        }

        int indexed = 0;
        int failed = 0;
        String collectionName = "xzs_408_chunks";
        String model = "embedding-2";
        int batchSize = 20;
        List<RagChunkRecord> chunks;
        while (!(chunks = ragDocumentService.listIndexableChunks(batchSize)).isEmpty()) {
            for (RagChunkRecord chunk : chunks) {
                try {
                    float[] embedding = ragService.embed(chunk.getContentText() != null ? chunk.getContentText() : chunk.getContent());
                    if (embedding != null) {
                        ragIndexService.upsert(chunk, embedding);
                        ragDocumentService.markIndexed(chunk.getId(), model, embedding.length, collectionName, String.valueOf(chunk.getId()));
                        indexed++;
                    }
                } catch (Exception e) {
                    failed++;
                    ragDocumentService.markIndexFailed(chunk.getId(), model, 0, collectionName, String.valueOf(chunk.getId()), e.getMessage());
                    logger.warn("Failed to index chunk {}: {}", chunk.getId(), e.getMessage());
                }
            }
        }

        Map<String, Object> result = new java.util.HashMap<>();
        result.put("backfilled", backfilled);
        result.put("indexed", indexed);
        result.put("failed", failed);
        return RestResponse.ok(result);
    }

    private String stringValue(Object value) {
        return value == null ? null : String.valueOf(value).trim();
    }

    private Boolean booleanValue(Object value) {
        if (value == null) {
            return false;
        }
        if (value instanceof Boolean) {
            return (Boolean) value;
        }
        return "true".equalsIgnoreCase(String.valueOf(value)) || "1".equals(String.valueOf(value));
    }
}
