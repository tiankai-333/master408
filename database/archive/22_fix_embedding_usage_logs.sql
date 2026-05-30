-- Fix historical embedding usage logs: backfill key_source = 'public' for records where it is NULL
UPDATE t_ai_usage_log
SET key_source = 'public'
WHERE key_source IS NULL;
