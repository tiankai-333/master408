package com.mindskip.xzs.service.impl;

import com.mindskip.xzs.domain.rag.RagChunkRecord;
import com.mindskip.xzs.service.RagIndexService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.RestTemplate;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class QdrantRagIndexServiceImpl implements RagIndexService {

    private final RestTemplate restTemplate = new RestTemplate();

    @Value("${ai.rag.vector.enabled:false}")
    private Boolean enabled;

    @Value("${ai.rag.vector.qdrant.url:http://127.0.0.1:6333}")
    private String qdrantUrl;

    @Value("${ai.rag.vector.qdrant.collection:xzs_408_chunks}")
    private String collectionName;

    @Value("${ai.rag.vector.qdrant.distance:Cosine}")
    private String distance;

    @Value("${ai.rag.vector.qdrant.api-key:}")
    private String apiKey;

    @Override
    public boolean isEnabled() {
        return Boolean.TRUE.equals(enabled);
    }

    @Override
    public void upsert(RagChunkRecord chunk, float[] embedding) {
        if (!isEnabled()) {
            throw new IllegalStateException("Qdrant RAG index is disabled");
        }
        ensureCollection(embedding == null ? 0 : embedding.length);
        Map<String, Object> point = new HashMap<>();
        point.put("id", chunk.getId());
        point.put("vector", toList(embedding));

        Map<String, Object> payload = new HashMap<>();
        payload.put("chunk_id", chunk.getId());
        payload.put("document_id", chunk.getDocumentId());
        payload.put("title", chunk.getTitle());
        payload.put("citation_label", chunk.getCitationLabel());
        payload.put("subject_id", chunk.getSubjectId());
        payload.put("knowledge_point_id", chunk.getKnowledgePointId());
        point.put("payload", payload);

        Map<String, Object> request = new HashMap<>();
        List<Map<String, Object>> points = new ArrayList<>();
        points.add(point);
        request.put("points", points);

        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(request, headers());
        restTemplate.exchange(endpoint("/collections/" + collectionName + "/points?wait=true"), HttpMethod.PUT, entity, String.class);
    }

    @Override
    @SuppressWarnings("unchecked")
    public List<Map<String, Object>> search(float[] queryEmbedding, int topK) {
        if (!isEnabled()) {
            return new ArrayList<>();
        }
        Map<String, Object> request = new HashMap<>();
        request.put("vector", toList(queryEmbedding));
        request.put("limit", topK <= 0 ? 5 : topK);
        request.put("with_payload", true);

        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(request, headers());
        ResponseEntity<Map> response = restTemplate.postForEntity(endpoint("/collections/" + collectionName + "/points/search"), entity, Map.class);
        Object result = response.getBody() == null ? null : response.getBody().get("result");
        if (result instanceof List) {
            return (List<Map<String, Object>>) result;
        }
        return new ArrayList<>();
    }

    private HttpHeaders headers() {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        if (apiKey != null && !apiKey.trim().isEmpty()) {
            headers.set("api-key", apiKey);
        }
        return headers;
    }

    private String endpoint(String path) {
        return qdrantUrl.replaceAll("/+$", "") + path;
    }

    private List<Float> toList(float[] embedding) {
        List<Float> values = new ArrayList<>();
        if (embedding != null) {
            for (float value : embedding) {
                values.add(value);
            }
        }
        return values;
    }

    private void ensureCollection(int dimension) {
        if (dimension <= 0) {
            throw new IllegalArgumentException("Qdrant vector dimension must be positive");
        }
        try {
            restTemplate.exchange(endpoint("/collections/" + collectionName), HttpMethod.GET, new HttpEntity<>(headers()), String.class);
            return;
        } catch (HttpClientErrorException e) {
            if (e.getStatusCode() != HttpStatus.NOT_FOUND) {
                throw e;
            }
        }

        Map<String, Object> vectors = new HashMap<>();
        vectors.put("size", dimension);
        vectors.put("distance", distance);

        Map<String, Object> request = new HashMap<>();
        request.put("vectors", vectors);

        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(request, headers());
        restTemplate.exchange(endpoint("/collections/" + collectionName), HttpMethod.PUT, entity, String.class);
    }
}
