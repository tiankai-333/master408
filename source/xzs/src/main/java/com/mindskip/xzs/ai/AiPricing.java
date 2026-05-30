package com.mindskip.xzs.ai;

import java.util.HashMap;
import java.util.Map;

public final class AiPricing {

    // {input_per_M, output_per_M, cache_hit_input_per_M} in CNY
    private static final Map<String, double[]> PRICES = new HashMap<>();
    static {
        // DeepSeek（三类：input cache miss / output / input cache hit）
        PRICES.put("deepseek-v4-flash", new double[]{1.0, 2.0, 0.02});
        PRICES.put("deepseek-v4-pro", new double[]{3.0, 6.0, 0.025});
        PRICES.put("deepseek-chat", new double[]{1.0, 2.0, 0.02});
        PRICES.put("deepseek-reasoner", new double[]{3.0, 6.0, 0.025});
        // GLM 暂不计费
        PRICES.put("glm-4.5-air", new double[]{0D, 0D, 0D});
        PRICES.put("glm-4-air", new double[]{0D, 0D, 0D});
        PRICES.put("glm-4-flash", new double[]{0D, 0D, 0D});
        PRICES.put("glm-4v-flash", new double[]{0D, 0D, 0D});
        PRICES.put("glm-4.6v-flash", new double[]{0D, 0D, 0D});
        PRICES.put("glm-4v-plus", new double[]{0D, 0D, 0D});
        PRICES.put("embedding-2", new double[]{0.5, 0D, 0.5});
        PRICES.put("embedding-3", new double[]{0D, 0D, 0D});
        // OpenAI (USD, 无 cache hit 区分)
        PRICES.put("gpt-4.1-mini", new double[]{0.4, 1.6, 0.4});
        PRICES.put("gpt-4o-mini", new double[]{0.15, 0.6, 0.15});
        PRICES.put("gpt-4o", new double[]{2.5, 10.0, 2.5});
        PRICES.put("text-embedding-3-small", new double[]{0.02, 0D, 0.02});
        PRICES.put("text-embedding-3-large", new double[]{0.13, 0D, 0.13});
    }

    /**
     * 三类计价：input = prompt_tokens - cache_hit_tokens, cache_hit, output
     */
    public static double calculateCost(String model, int inputTokens, int outputTokens, int cacheHitTokens) {
        if (model == null) return 0D;
        double[] prices = PRICES.getOrDefault(model.toLowerCase(), new double[]{0D, 0D, 0D});
        int inputMiss = Math.max(0, inputTokens - cacheHitTokens);
        return inputMiss * prices[0] / 1_000_000
             + outputTokens * prices[1] / 1_000_000
             + cacheHitTokens * prices[2] / 1_000_000;
    }

    public static double calculateCost(String model, int inputTokens, int outputTokens) {
        return calculateCost(model, inputTokens, outputTokens, 0);
    }

    public static double calculateCost(String model, int tokensUsed) {
        if (model == null || tokensUsed <= 0) return 0D;
        double[] prices = PRICES.getOrDefault(model.toLowerCase(), new double[]{0D, 0D, 0D});
        return tokensUsed * Math.max(prices[0], prices[1]) / 1_000_000;
    }
}
