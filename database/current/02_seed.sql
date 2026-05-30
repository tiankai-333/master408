-- MySQL dump 10.13  Distrib 8.0.33, for Linux (x86_64)
--
-- Host: localhost    Database: xzs
-- ------------------------------------------------------
-- Server version	8.0.33

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Dumping data for table `ai_agent`
--

/*!40000 ALTER TABLE `ai_agent` DISABLE KEYS */;
INSERT INTO `ai_agent` VALUES (1,'cs408_tutor','408 导学老师','综合调用题库、RAG、学生图谱和错题本的默认学习 Agent','student_tutor',NULL,'glm',NULL,_binary '',1,'2026-05-19 00:22:56','2026-05-19 00:22:56');
/*!40000 ALTER TABLE `ai_agent` ENABLE KEYS */;

--
-- Dumping data for table `ai_agent_skill`
--

/*!40000 ALTER TABLE `ai_agent_skill` DISABLE KEYS */;
INSERT INTO `ai_agent_skill` VALUES (1,1,3,10,_binary '','2026-05-19 00:22:56'),(2,1,2,10,_binary '','2026-05-19 00:22:56'),(3,1,1,10,_binary '','2026-05-19 00:22:56'),(4,1,4,10,_binary '','2026-05-19 00:22:56');
/*!40000 ALTER TABLE `ai_agent_skill` ENABLE KEYS */;

--
-- Dumping data for table `ai_provider_config`
--

/*!40000 ALTER TABLE `ai_provider_config` DISABLE KEYS */;
INSERT INTO `ai_provider_config` VALUES (1,'deepseek','DeepSeek','https://api.deepseek.com','deepseek-v4-pro','','Rfo2ouiZo3ZYsmSYkgho/29XA6ZbZt5uNEnAJJRgHRtCnxNxftueOMDV80Q6cRjuXgOFXFi8Z/ZwE2DlsMpk','sk-9****207d',_binary '\0',10,_binary '','连接成功','2026-05-22 17:32:40','2026-05-19 00:45:41','2026-05-22 17:32:45'),(2,'zhipu','智谱 GLM','https://open.bigmodel.cn/api/paas/v4','glm-4.5-air','embedding-2','JMBlSdtLyHnQuGsjGxBllw1qit47XIKmGxfjESFqFOzDWIiCW/+6ZrDf8/lPBeqcuZEgCk4VkRHtvraXsLoiWiS279DnZtbV9tyJ8ZI=','bc95****nwTo',_binary '',20,_binary '','连接成功','2026-05-22 17:32:50','2026-05-19 00:45:41','2026-05-22 17:32:50'),(3,'openai','OpenAI','https://api.openai.com/v1','gpt-4.1-mini','text-embedding-3-small',NULL,NULL,_binary '\0',30,NULL,NULL,NULL,'2026-05-19 00:45:41','2026-05-19 00:45:41');
/*!40000 ALTER TABLE `ai_provider_config` ENABLE KEYS */;

--
-- Dumping data for table `ai_skill`
--

/*!40000 ALTER TABLE `ai_skill` DISABLE KEYS */;
INSERT INTO `ai_skill` VALUES (1,'mistake_explain','错题讲解','结合题目、知识点和学生错因生成讲解','analysis',NULL,NULL,_binary '',1,'2026-05-19 00:22:56','2026-05-19 00:22:56'),(2,'knowledge_diagnosis','知识点诊断','根据学习事件和错题定位薄弱知识点','diagnosis',NULL,NULL,_binary '',1,'2026-05-19 00:22:56','2026-05-19 00:22:56'),(3,'exam_analysis','真题解析','面向408真题进行结构化解析','analysis',NULL,NULL,_binary '',1,'2026-05-19 00:22:56','2026-05-19 00:22:56'),(4,'review_plan','复习计划','根据知识状态生成短周期复习计划','planning',NULL,NULL,_binary '',1,'2026-05-19 00:22:56','2026-05-19 00:22:56');
/*!40000 ALTER TABLE `ai_skill` ENABLE KEYS */;

--
-- Dumping data for table `ai_tool`
--

/*!40000 ALTER TABLE `ai_tool` DISABLE KEYS */;
INSERT INTO `ai_tool` VALUES (1,'rag_search','RAG 检索','从向量库和 rag_chunk 中检索参考资料','service','ragIndexService.search',NULL,NULL,_binary '','2026-05-19 00:22:56','2026-05-19 00:22:56'),(2,'student_graph_query','学生图谱查询','查询学生知识点掌握状态和错题状态','service','studentGraphService',NULL,NULL,_binary '','2026-05-19 00:22:56','2026-05-19 00:22:56');
/*!40000 ALTER TABLE `ai_tool` ENABLE KEYS */;

--
-- Dumping data for table `t_subject`
--

/*!40000 ALTER TABLE `t_subject` DISABLE KEYS */;
INSERT INTO `t_subject` VALUES (1,'数据结构',1,'408统考',1,_binary '\0'),(2,'计算机组成原理',1,'408统考',2,_binary '\0'),(3,'操作系统',1,'408统考',3,_binary '\0'),(4,'计算机网络',1,'408统考',4,_binary '\0'),(5,'计算机408综合',1,'408综合',5,_binary '\0'),(6,'数学一',1,NULL,6,_binary '\0'),(7,'数学二',1,NULL,7,_binary '\0'),(8,'数学三',1,NULL,8,_binary '\0'),(9,'英语一',1,NULL,9,_binary '\0'),(10,'英语二',1,NULL,10,_binary '\0'),(11,'思想政治理论',1,NULL,11,_binary '\0');
/*!40000 ALTER TABLE `t_subject` ENABLE KEYS */;

--
-- Dumping data for table `t_user`
--

/*!40000 ALTER TABLE `t_user` DISABLE KEYS */;
INSERT INTO `t_user` VALUES (1,'a38a3b24-51d9-11f1-9aeb-9a2a8fc26999','admin','$2a$10$BOJWNJAQUNeSL8GI2uD8Fu3iqDit8HDO3ct1Ig5i/Actg0mqwTHQq','管理员',NULL,NULL,NULL,1,NULL,3,1,NULL,'2026-05-17 18:17:41',NULL,NULL,_binary '\0',NULL),(2,'a38a420a-51d9-11f1-9aeb-9a2a8fc26999','student','$2a$10$a0UdBI6U5KbJJFWwEN6jXe4eZTaWZfwYAdu1QK9Pbdv6bAvv3GWFi','学生用户',NULL,NULL,NULL,1,NULL,1,1,NULL,'2026-05-17 18:17:41',NULL,NULL,_binary '\0',NULL),(3,'a38a44ee-51d9-11f1-9aeb-9a2a8fc26999','teacher','$2a$10$BOJWNJAQUNeSL8GI2uD8Fu3iqDit8HDO3ct1Ig5i/Actg0mqwTHQq','教师',NULL,NULL,NULL,1,NULL,2,1,NULL,'2026-05-17 18:17:41',NULL,NULL,_binary '\0',NULL),(4,'a38a45c0-51d9-11f1-9aeb-9a2a8fc26999','231310423','$2a$10$a0UdBI6U5KbJJFWwEN6jXe4eZTaWZfwYAdu1QK9Pbdv6bAvv3GWFi','学生用户',NULL,NULL,NULL,1,NULL,1,1,NULL,'2026-05-17 18:17:41',NULL,NULL,_binary '\0',NULL);
/*!40000 ALTER TABLE `t_user` ENABLE KEYS */;

-- Dump completed on 2026-05-30
