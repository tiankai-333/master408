package com.mindskip.xzs.ai;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.mindskip.xzs.domain.TextContent;
import com.mindskip.xzs.domain.ai.AiKnowledgeBase;
import com.mindskip.xzs.repository.AiKnowledgeBaseMapper;
import com.mindskip.xzs.repository.TextContentMapper;
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
    private AiKnowledgeBaseMapper aiKnowledgeBaseMapper;

    @Value("${ai.api.key:}")
    private String aiApiKey;

    @Value("${ai.embedding.url:https://open.bigmodel.cn/api/paas/v4/embeddings}")
    private String embeddingApiUrl;

    @Value("${ai.embedding.model:embedding-2}")
    private String embeddingModel;

    public List<RagCandidate> loadCandidates() {
        List<RagCandidate> candidates = new ArrayList<>();
        candidates.addAll(loadKnowledgeBaseCandidates());

        List<TextContent> textContents = textContentMapper.selectAllWithEmbedding();
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
                    tc.getEmbedding(),
                    "真题解析",
                    "text_content"
                ));
            }
        }
        logger.info("Loaded {} RAG candidates from database", candidates.size());
        return candidates;
    }

    public List<RagCandidate> loadKnowledgeBaseCandidates() {
        List<RagCandidate> candidates = new ArrayList<>();
        try {
            List<AiKnowledgeBase> knowledgeBases = aiKnowledgeBaseMapper.selectAllWithEmbedding();
            for (AiKnowledgeBase kb : knowledgeBases) {
                if (kb.getEmbedding() != null && kb.getContent() != null) {
                    candidates.add(new RagCandidate(
                        kb.getId(),
                        buildKnowledgeBaseTitle(kb),
                        kb.getContent(),
                        kb.getEmbedding(),
                        kb.getCategory(),
                        kb.getSourceType()
                    ));
                }
            }
        } catch (Exception e) {
            logger.warn("Failed to load AI knowledge-base embeddings: {}", e.getMessage());
        }
        return candidates;
    }

    public List<RagDocument> retrieve(String query, int topK) throws Exception {
        List<RagCandidate> candidates = loadCandidates();
        List<RagDocument> docs = retrieve(candidates, query, topK);
        if (!docs.isEmpty()) {
            return docs;
        }
        return keywordFallback(query, topK);
    }

    public float[] embed(String text) throws Exception {
        if (text == null || text.trim().isEmpty()) {
            return null;
        }

        RestTemplate restTemplate = new RestTemplate();
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.set("Authorization", "Bearer " + aiApiKey);

        Map<String, Object> requestBody = new HashMap<>();
        requestBody.put("model", embeddingModel);
        requestBody.put("input", text.substring(0, Math.min(text.length(), 8000)));

        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(requestBody, headers);

        try {
            ResponseEntity<String> response = restTemplate.postForEntity(embeddingApiUrl, entity, String.class);
            JsonNode rootNode = objectMapper.readTree(response.getBody());
            JsonNode data = rootNode.path("data");
            if (data.isArray() && data.size() > 0) {
                JsonNode embeddingNode = data.get(0).path("embedding");
                float[] embedding = new float[embeddingNode.size()];
                for (int i = 0; i < embeddingNode.size(); i++) {
                    embedding[i] = (float) embeddingNode.get(i).asDouble();
                }
                logger.info("Embedding generated, dimensions: {}", embedding.length);
                return embedding;
            }
        } catch (Exception e) {
            logger.error("GLM Embedding API call failed: {}", e.getMessage());
            throw e;
        }
        return null;
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
                            candidate.getId(),
                            candidate.getCategory(),
                            candidate.getSourceType()
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

    public List<RagDocument> keywordFallback(String query, int topK) {
        if (query == null || query.trim().isEmpty()) {
            return Collections.emptyList();
        }

        String keyword = extractKeyword(query);
        if (keyword.isEmpty()) {
            return Collections.emptyList();
        }

        try {
            List<AiKnowledgeBase> rows = aiKnowledgeBaseMapper.search(keyword);
            List<RagDocument> docs = new ArrayList<>();
            for (AiKnowledgeBase kb : rows) {
                if (kb.getContent() == null || kb.getContent().trim().isEmpty()) {
                    continue;
                }
                docs.add(new RagDocument(
                    buildKnowledgeBaseTitle(kb),
                    kb.getContent(),
                    0.50,
                    kb.getId(),
                    kb.getCategory(),
                    kb.getSourceType()
                ));
                if (docs.size() >= topK) {
                    break;
                }
            }
            logger.info("RAG keyword fallback retrieved {} documents for keyword={}", docs.size(), keyword);
            return docs;
        } catch (Exception e) {
            logger.warn("RAG keyword fallback failed: {}", e.getMessage());
            return Collections.emptyList();
        }
    }

    private String extractKeyword(String query) {
        String cleaned = query.replaceAll("[^\\u4e00-\\u9fa5A-Za-z0-9]", " ").trim();
        String[] parts = cleaned.split("\\s+");
        String best = "";
        for (String part : parts) {
            if (part.length() > best.length()) {
                best = part;
            }
        }
        if (best.length() > 30) {
            best = best.substring(0, 30);
        }
        return best;
    }

    private String buildKnowledgeBaseTitle(AiKnowledgeBase kb) {
        String category = kb.getCategory() != null ? kb.getCategory() : "知识库";
        String title = kb.getTitle() != null ? kb.getTitle() : "未命名资料";
        return category + "：" + title;
    }

    public String formatReferenceDocs(List<RagDocument> docs) {
        if (docs == null || docs.isEmpty()) {
            return "";
        }
        StringBuilder sb = new StringBuilder();
        sb.append("\n\n## 参考资料（来自知识库/RAG检索，供辅助参考）\n\n");
        for (int i = 0; i < docs.size(); i++) {
            RagDocument doc = docs.get(i);
            sb.append("【参考").append(i + 1).append("】").append(doc.getTitle()).append("\n");
            if (doc.getCategory() != null && !doc.getCategory().isEmpty()) {
                sb.append("类型：").append(doc.getCategory());
                if (doc.getSourceType() != null && !doc.getSourceType().isEmpty()) {
                    sb.append(" / ").append(doc.getSourceType());
                }
                sb.append("\n");
            }
            if (doc.getContent() != null && !doc.getContent().isEmpty()) {
                String content = doc.getContent();
                sb.append(content, 0, Math.min(content.length(), 1800)).append("\n\n");
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
        private String category;
        private String sourceType;

        public RagDocument() {}

        public RagDocument(String title, String content, double similarity, Integer id) {
            this(title, content, similarity, id, null, null);
        }

        public RagDocument(String title, String content, double similarity, Integer id, String category, String sourceType) {
            this.title = title;
            this.content = content;
            this.similarity = similarity;
            this.id = id;
            this.category = category;
            this.sourceType = sourceType;
        }

        public String getTitle() { return title; }
        public void setTitle(String title) { this.title = title; }
        public String getContent() { return content; }
        public void setContent(String content) { this.content = content; }
        public double getSimilarity() { return similarity; }
        public void setSimilarity(double similarity) { this.similarity = similarity; }
        public Integer getId() { return id; }
        public void setId(Integer id) { this.id = id; }
        public String getCategory() { return category; }
        public void setCategory(String category) { this.category = category; }
        public String getSourceType() { return sourceType; }
        public void setSourceType(String sourceType) { this.sourceType = sourceType; }

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
        private String category;
        private String sourceType;

        public RagCandidate() {}

        public RagCandidate(Integer id, String title, String content, String embedding) {
            this(id, title, content, embedding, null, null);
        }

        public RagCandidate(Integer id, String title, String content, String embedding, String category, String sourceType) {
            this.id = id;
            this.title = title;
            this.content = content;
            this.embedding = embedding;
            this.category = category;
            this.sourceType = sourceType;
        }

        public Integer getId() { return id; }
        public void setId(Integer id) { this.id = id; }
        public String getTitle() { return title; }
        public void setTitle(String title) { this.title = title; }
        public String getContent() { return content; }
        public void setContent(String content) { this.content = content; }
        public String getEmbedding() { return embedding; }
        public void setEmbedding(String embedding) { this.embedding = embedding; }
        public String getCategory() { return category; }
        public void setCategory(String category) { this.category = category; }
        public String getSourceType() { return sourceType; }
        public void setSourceType(String sourceType) { this.sourceType = sourceType; }
    }
}
