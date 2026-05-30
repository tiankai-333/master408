package com.mindskip.xzs.ai;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.mindskip.xzs.domain.TextContent;
import com.mindskip.xzs.domain.ai.AiProviderConfig;
import com.mindskip.xzs.domain.ai.AiUserKey;
import com.mindskip.xzs.domain.ai.AiUsageLog;
import com.mindskip.xzs.repository.AiUsageLogMapper;
import com.mindskip.xzs.repository.TextContentMapper;
import com.mindskip.xzs.service.AiProviderConfigService;
import com.mindskip.xzs.service.AiUserKeyService;
import com.mindskip.xzs.service.RagIndexService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.*;

@Service
public class RagService {

    private static final Logger logger = LoggerFactory.getLogger(RagService.class);
    private static final ThreadLocal<Integer> currentUser = new ThreadLocal<>();

    public static void setCurrentUserId(Integer userId) { currentUser.set(userId); }
    public static void clearCurrentUserId() { currentUser.remove(); }

    private final ObjectMapper objectMapper = new ObjectMapper();

    @Autowired
    private TextContentMapper textContentMapper;

    @Autowired
    private AiProviderConfigService aiProviderConfigService;

    @Autowired
    private AiUserKeyService aiUserKeyService;

    @Autowired
    private AiUsageLogMapper aiUsageLogMapper;

    @Autowired
    private RagIndexService ragIndexService;

    @Value("${ai.api.key:}")
    private String aiApiKey;

    @Value("${ai.embedding.url:https://open.bigmodel.cn/api/paas/v4/embeddings}")
    private String embeddingApiUrl;

    @Value("${ai.embedding.model:embedding-2}")
    private String embeddingModel;

    private volatile List<RagCandidate> cachedCandidates = null;
    private volatile List<float[]> cachedEmbeddings = null;
    private volatile long lastCacheTime = 0;
    private static final long CACHE_TTL_MS = 5 * 60 * 1000;

    public List<RagCandidate> loadCandidates() {
        long now = System.currentTimeMillis();
        if (cachedCandidates != null && (now - lastCacheTime) < CACHE_TTL_MS) {
            return cachedCandidates;
        }
        List<TextContent> textContents = textContentMapper.selectAllWithEmbedding();
        List<RagCandidate> candidates = new ArrayList<>();
        List<float[]> embeddings = new ArrayList<>();
        for (TextContent tc : textContents) {
            if (tc.getEmbedding() != null && tc.getContent() != null) {
                String title = "真题解析 #" + tc.getId();
                if (tc.getContent().length() > 100) {
                    String contentPreview = tc.getContent().substring(0, 100);
                    int end = contentPreview.lastIndexOf("\\\"");
                    if (end > 0) {
                        contentPreview = contentPreview.substring(0, end);
                    }
                    title = contentPreview.replace("\\\"", "").replace("\"", "").replace("{", "").trim();
                    if (title.length() > 80) title = title.substring(0, 80) + "...";
                }
                candidates.add(new RagCandidate(
                    tc.getId(),
                    "题#" + tc.getId() + ": " + title,
                    tc.getContent(),
                    tc.getEmbedding()
                ));
                embeddings.add(parseEmbedding(tc.getEmbedding()));
            }
        }
        cachedCandidates = candidates;
        cachedEmbeddings = embeddings;
        lastCacheTime = now;
        logger.info("Loaded {} RAG candidates from database (cached)", candidates.size());
        return candidates;
    }

    public List<RagDocument> retrieve(String query, int topK) throws Exception {
        if (ragIndexService.isEnabled()) {
            return retrieveFromQdrant(query, topK);
        }
        List<RagCandidate> candidates = loadCandidates();
        return retrieve(candidates, query, topK);
    }

    private List<RagDocument> retrieveFromQdrant(String query, int topK) throws Exception {
        float[] queryEmbedding = embed(query);
        if (queryEmbedding == null) {
            return Collections.emptyList();
        }
        List<Map<String, Object>> hits = ragIndexService.search(queryEmbedding, topK);
        List<RagDocument> results = new ArrayList<>();
        for (Map<String, Object> hit : hits) {
            Map<String, Object> payload = (Map<String, Object>) hit.get("payload");
            if (payload == null) continue;
            double score = hit.get("score") instanceof Number ? ((Number) hit.get("score")).doubleValue() : 0;
            if (score <= 0.5) continue;
            String title = payload.get("citation_label") != null ? String.valueOf(payload.get("citation_label")) : "未知";
            String content = payload.get("title") != null ? String.valueOf(payload.get("title")) : "";
            Object idObj = payload.get("chunk_id");
            Integer id = idObj instanceof Number ? ((Number) idObj).intValue() : null;
            results.add(new RagDocument(title, content, score, id));
        }
        logger.info("Qdrant RAG retrieved {} documents (topK={})", results.size(), topK);
        return results;
    }

    public float[] embed(String text) throws Exception {
        if (text == null || text.trim().isEmpty()) {
            return null;
        }
        long startTime = System.currentTimeMillis();

        EmbeddingProvider ep = resolveEmbeddingProvider();

        RestTemplate restTemplate = new RestTemplate();
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.set("Authorization", "Bearer " + ep.apiKey);

        Map<String, Object> requestBody = new HashMap<>();
        requestBody.put("model", ep.model);
        requestBody.put("input", text.substring(0, Math.min(text.length(), 8000)));

        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(requestBody, headers);

        try {
            ResponseEntity<String> response = restTemplate.postForEntity(ep.apiUrl, entity, String.class);
            JsonNode rootNode = objectMapper.readTree(response.getBody());
            JsonNode data = rootNode.path("data");
            if (data.isArray() && data.size() > 0) {
                JsonNode embeddingNode = data.get(0).path("embedding");
                float[] embedding = new float[embeddingNode.size()];
                for (int i = 0; i < embeddingNode.size(); i++) {
                    embedding[i] = (float) embeddingNode.get(i).asDouble();
                }
                int tokensUsed = rootNode.path("usage").path("total_tokens").asInt(estimateTokens(text));
                saveEmbeddingUsageLog(ep.providerCode, ep.model, text, embedding.length,
                        tokensUsed, (int) (System.currentTimeMillis() - startTime), true, null, ep.keySource);
                logger.info("Embedding generated, dimensions: {}, provider: {}", embedding.length, ep.providerCode);
                return embedding;
            }
        } catch (Exception e) {
            saveEmbeddingUsageLog(ep.providerCode, ep.model, text, 0,
                    estimateTokens(text), (int) (System.currentTimeMillis() - startTime), false, e.getMessage(), ep.keySource);
            logger.error("Embedding API call failed ({}): {}", ep.providerCode, e.getMessage());
            throw e;
        }
        return null;
    }

    private EmbeddingProvider resolveEmbeddingProvider() {
        List<EmbeddingProvider> candidates = new ArrayList<>();
        Integer userId = currentUser.get();

        // 1. User private keys with embedding model
        if (userId != null) {
            try {
                for (AiUserKey uk : aiUserKeyService.listEnabledByUser(userId)) {
                    if (uk.getApiKeyCipher() == null) continue;
                    String embModel = uk.getEmbeddingModel();
                    if (embModel == null || embModel.trim().isEmpty()) continue;
                    EmbeddingProvider ep = new EmbeddingProvider();
                    ep.providerCode = uk.getProviderCode();
                    ep.apiKey = aiUserKeyService.decryptKey(uk.getApiKeyCipher());
                    ep.apiUrl = (uk.getApiBaseUrl() != null ? uk.getApiBaseUrl().replaceAll("/+$", "") : embeddingApiUrl.replaceAll("/+$", "")) + "/embeddings";
                    ep.model = embModel;
                    ep.keySource = "private";
                    ep.priority = uk.getPriority() != null ? uk.getPriority() : 100;
                    candidates.add(ep);
                }
            } catch (Exception e) {
                logger.warn("Failed to load user embedding keys: {}", e.getMessage());
            }
        }

        // 2. Public providers with embedding model
        try {
            for (AiProviderConfig pc : aiProviderConfigService.listSafe()) {
                if (!Boolean.TRUE.equals(pc.getEnabled())) continue;
                String embModel = pc.getEmbeddingModel();
                if (embModel == null || embModel.trim().isEmpty()) continue;
                String apiKey = aiProviderConfigService.resolveApiKey(pc.getProviderCode());
                if (apiKey == null || apiKey.trim().isEmpty()) continue;
                EmbeddingProvider ep = new EmbeddingProvider();
                ep.providerCode = pc.getProviderCode();
                ep.apiKey = apiKey;
                ep.apiUrl = (pc.getApiBaseUrl() != null ? pc.getApiBaseUrl().replaceAll("/+$", "") : embeddingApiUrl.replaceAll("/+$", "")) + "/embeddings";
                ep.model = embModel;
                ep.keySource = "public";
                ep.priority = pc.getPriority() != null ? pc.getPriority() : 100;
                candidates.add(ep);
            }
        } catch (Exception e) {
            logger.warn("Failed to load public embedding providers: {}", e.getMessage());
        }

        if (!candidates.isEmpty()) {
            candidates.sort(Comparator.comparingInt(e -> e.priority));
            return candidates.get(0);
        }

        // 3. Fallback to application.yml defaults
        EmbeddingProvider fallback = new EmbeddingProvider();
        fallback.providerCode = "zhipu";
        fallback.apiKey = aiApiKey;
        fallback.apiUrl = embeddingApiUrl;
        fallback.model = embeddingModel;
        fallback.keySource = "public";
        fallback.priority = 999;
        return fallback;
    }

    private static class EmbeddingProvider {
        String providerCode, apiKey, apiUrl, model, keySource;
        int priority;
    }

    private void saveEmbeddingUsageLog(String provider, String model, String text, int dimensions,
                                       Integer tokensUsed, Integer durationMs, Boolean success, String errorMessage,
                                       String keySource) {
        try {
            AiUsageLog log = new AiUsageLog();
            log.setStyle("embedding");
            log.setAiType(provider);
            log.setModel(model);
            log.setQuestion(limitText(text, 6000));
            log.setKnowledgePoints("");
            log.setPrompt("embedding");
            log.setResponse(success ? "dimensions=" + dimensions : "");
            log.setResponseLength(dimensions);
            log.setTokensUsed(tokensUsed);
            log.setInputTokens(tokensUsed);
            log.setOutputTokens(0);
            log.setCacheHitTokens(0);
            log.setCost(AiPricing.calculateCost(model, tokensUsed, 0, 0));
            log.setDurationMs(durationMs);
            log.setSuccess(success);
            log.setUserId(currentUser.get());
            log.setKeySource(keySource);
            log.setErrorMessage(limitText(errorMessage, 1000));
            log.setCreateTime(new Date());
            aiUsageLogMapper.insert(log);
        } catch (Exception logError) {
            logger.warn("Failed to save embedding usage log: {}", logError.getMessage());
        }
    }

    private int estimateTokens(String text) {
        return text == null ? 0 : Math.max(1, text.length() / 3);
    }

    private String limitText(String value, int maxLength) {
        if (value == null) {
            return null;
        }
        return value.length() <= maxLength ? value : value.substring(0, maxLength);
    }

    public double cosineSimilarity(float[] a, float[] b) {
        if (a == null || b == null || a.length != b.length) {
            return 0.0;
        }
        double dotProduct = 0.0;
        double normA = 0.0;
        double normB = 0.0;
        for (int i = 0; i < a.length; i++) {
            dotProduct += a[i] * b[i];
            normA += a[i] * a[i];
            normB += b[i] * b[i];
        }
        if (normA == 0.0 || normB == 0.0) {
            return 0.0;
        }
        return dotProduct / (Math.sqrt(normA) * Math.sqrt(normB));
    }

    public List<RagDocument> retrieve(List<RagCandidate> candidates, String query, int topK) throws Exception {
        if (candidates == null || candidates.isEmpty() || query == null || query.trim().isEmpty()) {
            return Collections.emptyList();
        }

        float[] queryEmbedding = embed(query);
        if (queryEmbedding == null) {
            return Collections.emptyList();
        }

        List<float[]> embeddings = cachedEmbeddings;
        List<RagDocument> results = new ArrayList<>();
        for (int i = 0; i < candidates.size(); i++) {
            float[] candidateEmbedding = (embeddings != null && i < embeddings.size())
                ? embeddings.get(i)
                : parseEmbedding(candidates.get(i).getEmbedding());
            if (candidateEmbedding != null) {
                double similarity = cosineSimilarity(queryEmbedding, candidateEmbedding);
                results.add(new RagDocument(
                    candidates.get(i).getTitle(),
                    candidates.get(i).getContent(),
                    similarity,
                    candidates.get(i).getId()
                ));
            }
        }

        results.sort((a, b) -> Double.compare(b.getSimilarity(), a.getSimilarity()));

        List<RagDocument> topResults = new ArrayList<>();
        for (int i = 0; i < Math.min(topK, results.size()); i++) {
            if (results.get(i).getSimilarity() > 0.5) {
                topResults.add(results.get(i));
            }
        }

        logger.info("RAG retrieved {} documents (query topK={}, total candidates={})", 
            topResults.size(), topK, candidates.size());
        return topResults;
    }

    public String formatReferenceDocs(List<RagDocument> docs) {
        if (docs == null || docs.isEmpty()) {
            return "";
        }
        StringBuilder sb = new StringBuilder();
        sb.append("\n\n## 参考资料（来自题库，供辅助参考）\n\n");
        for (int i = 0; i < docs.size(); i++) {
            RagDocument doc = docs.get(i);
            sb.append("【参考").append(i + 1).append("】").append(doc.getTitle()).append("\n");
            if (doc.getContent() != null && !doc.getContent().isEmpty()) {
                sb.append(doc.getContent()).append("\n\n");
            }
        }
        return sb.toString();
    }

    public String toJson(float[] embedding) {
        if (embedding == null) return null;
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < embedding.length; i++) {
            if (i > 0) sb.append(",");
            sb.append(embedding[i]);
        }
        sb.append("]");
        return sb.toString();
    }

    public float[] parseEmbedding(String json) {
        if (json == null || json.trim().isEmpty()) return null;
        try {
            List<Double> list = objectMapper.readValue(json, new TypeReference<List<Double>>() {});
            float[] result = new float[list.size()];
            for (int i = 0; i < list.size(); i++) {
                result[i] = list.get(i).floatValue();
            }
            return result;
        } catch (Exception e) {
            return null;
        }
    }

    public static class RagDocument {
        private String title;
        private String content;
        private double similarity;
        private Integer id;

        public RagDocument() {}

        public RagDocument(String title, String content, double similarity, Integer id) {
            this.title = title;
            this.content = content;
            this.similarity = similarity;
            this.id = id;
        }

        public String getTitle() { return title; }
        public void setTitle(String title) { this.title = title; }
        public String getContent() { return content; }
        public void setContent(String content) { this.content = content; }
        public double getSimilarity() { return similarity; }
        public void setSimilarity(double similarity) { this.similarity = similarity; }
        public Integer getId() { return id; }
        public void setId(Integer id) { this.id = id; }

        @Override
        public String toString() {
            return String.format("[%.2f] %s", similarity, title);
        }
    }

    public static class RagCandidate {
        private Integer id;
        private String title;
        private String content;
        private String embedding;

        public RagCandidate() {}

        public RagCandidate(Integer id, String title, String content, String embedding) {
            this.id = id;
            this.title = title;
            this.content = content;
            this.embedding = embedding;
        }

        public Integer getId() { return id; }
        public void setId(Integer id) { this.id = id; }
        public String getTitle() { return title; }
        public void setTitle(String title) { this.title = title; }
        public String getContent() { return content; }
        public void setContent(String content) { this.content = content; }
        public String getEmbedding() { return embedding; }
        public void setEmbedding(String embedding) { this.embedding = embedding; }
    }
}
