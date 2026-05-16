package com.mindskip.xzs.controller.admin;

import com.mindskip.xzs.base.BaseApiController;
import com.mindskip.xzs.base.RestResponse;
import com.mindskip.xzs.ai.RagService;
import com.mindskip.xzs.domain.ai.AiPromptTemplate;
import com.mindskip.xzs.domain.ai.AiKnowledgeBase;
import com.mindskip.xzs.domain.ai.AiAdjustmentLog;
import com.mindskip.xzs.service.AiAgentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController("AdminAiAgentController")
@RequestMapping("/api/admin/ai-agent")
public class AiAgentController extends BaseApiController {

    @Autowired
    private AiAgentService aiAgentService;

    @Autowired
    private RagService ragService;

    // ============ 模板管理 ============

    @GetMapping("/templates")
    public RestResponse<List<AiPromptTemplate>> getAllTemplates() {
        return RestResponse.ok(aiAgentService.getAllTemplates());
    }

    @GetMapping("/templates/enabled")
    public RestResponse<List<AiPromptTemplate>> getEnabledTemplates() {
        return RestResponse.ok(aiAgentService.getEnabledTemplates());
    }

    @GetMapping("/template/{id}")
    public RestResponse<AiPromptTemplate> getTemplate(@PathVariable Integer id) {
        return RestResponse.ok(aiAgentService.getTemplateById(id));
    }

    @GetMapping("/template/style/{style}")
    public RestResponse<AiPromptTemplate> getTemplateByStyle(@PathVariable String style) {
        return RestResponse.ok(aiAgentService.getTemplateByStyle(style));
    }

    @PostMapping("/template")
    public RestResponse<AiPromptTemplate> createTemplate(@RequestBody AiPromptTemplate template) {
        AiPromptTemplate result = aiAgentService.createTemplate(template);
        return RestResponse.ok(result);
    }

    @PutMapping("/template/{id}")
    public RestResponse<AiPromptTemplate> updateTemplate(@PathVariable Integer id, @RequestBody AiPromptTemplate template) {
        AiPromptTemplate result = aiAgentService.updateTemplate(id, template);
        return RestResponse.ok(result);
    }

    @DeleteMapping("/template/{id}")
    public RestResponse<Void> deleteTemplate(@PathVariable Integer id) {
        aiAgentService.deleteTemplate(id);
        return RestResponse.ok();
    }

    // ============ 知识库管理 ============

    @GetMapping("/knowledge-base")
    public RestResponse<List<AiKnowledgeBase>> getAllKnowledgeBase() {
        return RestResponse.ok(aiAgentService.getAllKnowledgeBase());
    }

    @GetMapping("/knowledge-base/category/{category}")
    public RestResponse<List<AiKnowledgeBase>> getKnowledgeBaseByCategory(@PathVariable String category) {
        return RestResponse.ok(aiAgentService.getKnowledgeBaseByCategory(category));
    }

    @GetMapping("/knowledge-base/domain/{domain}")
    public RestResponse<List<AiKnowledgeBase>> getKnowledgeBaseByDomain(@PathVariable String domain) {
        return RestResponse.ok(aiAgentService.getKnowledgeBaseByDomain(domain));
    }

    @GetMapping("/knowledge-base/search")
    public RestResponse<List<AiKnowledgeBase>> searchKnowledgeBase(@RequestParam String keyword) {
        return RestResponse.ok(aiAgentService.searchKnowledgeBase(keyword));
    }

    @GetMapping("/knowledge-base/statistics")
    public RestResponse<List<Map<String, Object>>> getKnowledgeBaseStatistics() {
        return RestResponse.ok(aiAgentService.getKnowledgeBaseStatistics());
    }

    @GetMapping("/knowledge-base/{id}")
    public RestResponse<AiKnowledgeBase> getKnowledgeBase(@PathVariable Integer id) {
        return RestResponse.ok(aiAgentService.getKnowledgeBaseById(id));
    }

    @PostMapping("/knowledge-base")
    public RestResponse<AiKnowledgeBase> createKnowledgeBase(@RequestBody AiKnowledgeBase knowledgeBase) {
        AiKnowledgeBase result = aiAgentService.createKnowledgeBase(knowledgeBase);
        return RestResponse.ok(result);
    }

    @PutMapping("/knowledge-base/{id}")
    public RestResponse<AiKnowledgeBase> updateKnowledgeBase(@PathVariable Integer id, @RequestBody AiKnowledgeBase knowledgeBase) {
        AiKnowledgeBase result = aiAgentService.updateKnowledgeBase(id, knowledgeBase);
        return RestResponse.ok(result);
    }

    @DeleteMapping("/knowledge-base/{id}")
    public RestResponse<Void> deleteKnowledgeBase(@PathVariable Integer id) {
        aiAgentService.deleteKnowledgeBase(id);
        return RestResponse.ok();
    }

    // ============ 调整日志 ============

    @GetMapping("/adjustment-logs")
    public RestResponse<List<AiAdjustmentLog>> getAdjustmentLogs(
            @RequestParam(required = false) Integer templateId,
            @RequestParam(required = false) String style,
            @RequestParam(defaultValue = "50") int limit) {
        return RestResponse.ok(aiAgentService.getAdjustmentLogs(templateId, style, limit));
    }

    @PostMapping("/adjustment-log")
    public RestResponse<AiAdjustmentLog> createAdjustmentLog(@RequestBody AiAdjustmentLog log) {
        return RestResponse.ok(aiAgentService.createAdjustmentLog(log));
    }

    @PostMapping("/template/{id}/test")
    public RestResponse<AiAdjustmentLog> testTemplate(@PathVariable Integer id, @RequestBody Map<String, String> request) {
        String question = request.get("question");
        return RestResponse.ok(aiAgentService.testTemplate(id, question));
    }

    @PostMapping("/adjustment-log/{logId}/approve")
    public RestResponse<AiAdjustmentLog> approveAdjustment(
            @PathVariable Integer logId,
            @RequestBody Map<String, String> request) {
        Integer approverId = getCurrentUser() != null ? getCurrentUser().getId() : 1;
        String comment = request.get("comment");
        return RestResponse.ok(aiAgentService.approveAdjustment(logId, approverId, comment));
    }

    @PostMapping("/adjustment-log/{logId}/reject")
    public RestResponse<AiAdjustmentLog> rejectAdjustment(
            @PathVariable Integer logId,
            @RequestBody Map<String, String> request) {
        Integer approverId = getCurrentUser() != null ? getCurrentUser().getId() : 1;
        String comment = request.get("comment");
        return RestResponse.ok(aiAgentService.rejectAdjustment(logId, approverId, comment));
    }

    // ============ 统计 ============

    @GetMapping("/statistics")
    public RestResponse<Map<String, Object>> getStatistics() {
        return RestResponse.ok(aiAgentService.getUsageStatistics());
    }

    @GetMapping("/rag/debug")
    public RestResponse<List<RagService.RagDocument>> debugRag(
            @RequestParam String keyword,
            @RequestParam(defaultValue = "5") int topK) {
        return RestResponse.ok(ragService.keywordFallback(keyword, topK));
    }
}
