-- ============================================================
-- 00_init_database_with_seed.sql
-- One-shot local initialization script.
--
-- Run from repository root:
--   mysql -uroot -p xzs < database/current/00_init_database_with_seed.sql
--
-- This imports table structure, exam/knowledge seed data, HTML refs,
-- AI provider config, and the test / 123456 demo student records.
-- ============================================================

SET NAMES utf8mb4;

SOURCE database/current/01_init_structure.sql;
SOURCE database/current/02_extend_fields.sql;
SOURCE database/current/04_exam_data.sql;
SOURCE database/current/05_rag_embeddings.sql;
SOURCE database/current/06_ai_knowledge_rag.sql;
SOURCE database/current/10_knowledge_points_data.sql;
SOURCE database/current/08_clean_knowledge_display_noise.sql;
SOURCE database/current/11_default_user_level.sql;
SOURCE database/current/12_canonical_ai_architecture.sql;
SOURCE database/current/13_backfill_canonical_ai_data.sql;
SOURCE database/current/14_ai_provider_config.sql;
SOURCE database/current/15_embed_question_images.sql;
SOURCE database/current/16_import_2026_html_mock_exam.sql;
SOURCE database/current/17_import_csgraduates_html_exams.sql;
SOURCE database/current/18_generate_408_subject_papers.sql;
SOURCE database/current/19_import_408_knowledge_html.sql;
SOURCE database/current/07_demo_student_learning_data.sql;

SELECT 'master408 database initialized with seed data for test / 123456' AS status;
