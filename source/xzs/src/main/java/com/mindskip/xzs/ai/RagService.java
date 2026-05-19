package com.mindskip.xzs.ai;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.mindskip.xzs.domain.TextContent;
import com.mindskip.xzs.domain.ai.AiProviderConfig;
import com.mindskip.xzs.domain.ai.AiUsageLog;
import com.mindskip.xzs.repository.AiUsageLogMapper;
import com.mindskip.xzs.repository.TextContentMapper;
import com.mindskip.xzs.service.AiProviderConfigService;
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

    private final ObjectMapper objectMapper = new ObjectMapper();

    @Autowired
    private TextContentMapper textContentMapper;

    @Autowired
    private AiProviderConfigService aiProviderConfigService;

    @Autowired
    private AiUsageLogMapper aiUsageLogMapper;

    @Value("${ai.api.key:}")
    private String aiApiKey;

    @Value("${ai.embedding.url:https://open.bigmodel.cn/api/paas/v4/embeddings}")
    private String embeddingApiUrl;

    @Value("${ai.embedding.model:embedding-2}")
    private String embeddingModel;

    public List<RagCandidate> loadCandidates() {
        List<TextContent> textContents = textContentMapper.selectAllWithEmbedding();
        List<RagCandidate> candidates = new ArrayList<>();
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
            }
        }
        logger.info("Loaded {} RAG candidates from database", candidates.size());
        return candidates;
    }

    public List<RagDocument> retrieve(String query, int topK) throws Exception {
        List<RagCandidate> candidates = loadCandidates();
        return retrieve(candidates, query, topK);
    }

    public float[] embed(String text) throws Exception {
        if (text == null || text.trim().isEmpty()) {
            return null;
        }
        long startTime = System.currentTimeMillis();

        RestTemplate restTemplate = new RestTemplate();
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        AiProviderConfig provider = aiProviderConfigService.getEnabled("zhipu");
        String apiKey = provider != null ? aiProviderConfigService.resolveApiKey("zhipu") : aiApiKey;
        String apiUrl = provider != null && provider.getApiBaseUrl() != null && !provider.getApiBaseUrl().isEmpty()
                ? provider.getApiBaseUrl().replaceAll("/+$", "") + "/embeddings"
                : embeddingApiUrl;
        String model = provider != null && provider.getEmbeddingModel() != null && !provider.getEmbeddingModel().isEmpty()
                ? provider.getEmbeddingModel()
                : embeddingModel;

        headers.set("Authorization", "Bearer " + apiKey);

        Map<String, Object> requestBody = new HashMap<>();
        requestBody.put("model", model);
        requestBody.put("input", text.substring(0, Math.min(text.length(), 8000)));

        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(requestBody, headers);

        try {
            ResponseEntity<String> response = restTemplate.postForEntity(apiUrl, entity, String.class);
            JsonNode rootNode = objectMapper.readTree(response.getBody());
            JsonNode data = rootNode.path("data");
            if (data.isArray() && data.size() > 0) {
                JsonNode embeddingNode = data.get(0).path("embedding");
                float[] embedding = new float[embeddingNode.size()];
                for (int i = 0; i < embeddingNode.size(); i++) {
                    embedding[i] = (float) embeddingNode.get(i).asDouble();
                }
                int tokensUsed = rootNode.path("usage").path("total_tokens").asInt(estimateTokens(text));
                saveEmbeddingUsageLog(provider != null ? provider.getProviderCode() : "zhipu", model, text, embedding.length,
                        tokensUsed, (int) (System.currentTimeMillis() - startTime), true, null);
                logger.info("Embedding generated, dimensions: {}", embedding.length);
                return embedding;
            }
        } catch (Exception e) {
            saveEmbeddingUsageLog(provider != null ? provider.getProviderCode() : "zhipu", model, text, 0,
                    estimateTokens(text), (int) (System.currentTimeMillis() - startTime), false, e.getMessage());
            logger.error("GLM Embedding API call failed: {}", e.getMessage());
            throw e;
        }
        return null;
    }

    private void saveEmbeddingUsageLog(String provider, String model, String text, int dimensions,
                                       Integer tokensUsed, Integer durationMs, Boolean success, String errorMessage) {
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
            log.setCost(0D);
            log.setDurationMs(durationMs);
            log.setSuccess(success);
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

        List<RagDocument> results = new ArrayList<>();
        for (RagCandidate candidate : candidates) {
            if (candidate.getEmbedding() != null) {
                try {
                    float[] candidateEmbedding = parseEmbedding(candidate.getEmbedding());
                    if (candidateEmbedding != null) {
                        double similarity = cosineSimilarity(queryEmbedding, candidateEmbedding);
                        results.add(new RagDocument(
                            candidate.getTitle(),
                            candidate.getContent(),
                            similarity,
                            candidate.getId()
                        ));
                    }
                } catch (Exception e) {
                    logger.warn("Failed to parse embedding for doc: {}", candidate.getTitle());
                }
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
