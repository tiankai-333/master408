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
-- Dumping data for table `student_learning_event`
--

/*!40000 ALTER TABLE `student_learning_event` DISABLE KEYS */;
/*!40000 ALTER TABLE `student_learning_event` ENABLE KEYS */;

--
-- Dumping data for table `student_mistake_book`
--

/*!40000 ALTER TABLE `student_mistake_book` DISABLE KEYS */;
/*!40000 ALTER TABLE `student_mistake_book` ENABLE KEYS */;

--
-- Dumping data for table `t_message`
--

/*!40000 ALTER TABLE `t_message` DISABLE KEYS */;
/*!40000 ALTER TABLE `t_message` ENABLE KEYS */;

--
-- Dumping data for table `t_message_user`
--

/*!40000 ALTER TABLE `t_message_user` DISABLE KEYS */;
/*!40000 ALTER TABLE `t_message_user` ENABLE KEYS */;

--
-- Dumping data for table `t_task_exam`
--

/*!40000 ALTER TABLE `t_task_exam` DISABLE KEYS */;
INSERT INTO `t_task_exam` VALUES (2,'AI学习任务-05-20 16:30-2',1,790,2,'2026-05-20 16:30:23',_binary '\0','student'),(3,'AI学习任务-05-20 16:32-3',1,793,2,'2026-05-20 16:32:36',_binary '\0','student');
/*!40000 ALTER TABLE `t_task_exam` ENABLE KEYS */;

--
-- Dumping data for table `t_task_exam_customer_answer`
--

/*!40000 ALTER TABLE `t_task_exam_customer_answer` DISABLE KEYS */;
/*!40000 ALTER TABLE `t_task_exam_customer_answer` ENABLE KEYS */;

--
-- Dumping data for table `t_user_event_log`
--

/*!40000 ALTER TABLE `t_user_event_log` DISABLE KEYS */;
INSERT INTO `t_user_event_log` VALUES (1,4,'231310423','学生用户','231310423 登录了408Master 智能学习系统','2026-05-17 18:19:23'),(2,1,'admin','管理员','admin 登录了408Master 智能学习系统','2026-05-17 18:19:52'),(3,1,'admin','管理员','admin 登录了408Master 智能学习系统','2026-05-19 16:30:16'),(4,2,'student','学生用户','student 登录了408Master 智能学习系统','2026-05-19 16:33:57'),(5,1,'admin','管理员','admin 登录了408Master 智能学习系统','2026-05-19 16:36:04'),(6,2,'student','学生用户','student 登录了408Master 智能学习系统','2026-05-19 16:37:26'),(7,2,'student','学生用户','student 提交试卷：2024年全国硕士研究生招生考试计算机学科专业基础综合试题 得分：10 耗时：31 秒','2026-05-19 16:56:35'),(8,1,'admin','管理员','admin 登录了408Master 智能学习系统','2026-05-19 17:12:35'),(9,4,'231310423','学生用户','231310423 登录了408Master 智能学习系统','2026-05-19 17:14:59'),(10,1,'admin','管理员','admin 登录了408Master 智能学习系统','2026-05-19 22:02:38'),(11,2,'student','学生用户','student 登录了408Master 智能学习系统','2026-05-19 22:05:09'),(12,2,'student','学生用户','student 登录了408Master 智能学习系统','2026-05-19 22:21:19'),(13,2,'student','学生用户','student 登录了408Master 智能学习系统','2026-05-19 23:38:03'),(14,1,'admin','管理员','admin 登录了408Master 智能学习系统','2026-05-19 23:38:17'),(15,1,'admin','管理员','admin 登录了408Master 智能学习系统','2026-05-20 00:11:22'),(16,2,'student','学生用户','student 登录了408Master 智能学习系统','2026-05-20 00:12:05'),(17,2,'student','学生用户','student 登录了408Master 智能学习系统','2026-05-20 00:18:48'),(18,1,'admin','管理员','admin 登录了408Master 智能学习系统','2026-05-20 00:19:21'),(19,1,'admin','管理员','admin 登录了408Master 智能学习系统','2026-05-20 00:21:37'),(20,1,'admin','管理员','admin 登录了408Master 智能学习系统','2026-05-20 00:22:18'),(21,2,'student','学生用户','student 登录了408Master 智能学习系统','2026-05-20 00:22:30'),(22,2,'student','学生用户','student 登录了408Master 智能学习系统','2026-05-20 00:25:44'),(23,1,'admin','管理员','admin 登录了408Master 智能学习系统','2026-05-20 00:26:22'),(24,2,'student','学生用户','student 登录了408Master 智能学习系统','2026-05-20 10:30:53'),(25,2,'student','学生用户','student 登录了408Master 智能学习系统','2026-05-20 13:43:58'),(26,2,'student','学生用户','student 提交试卷：2024年全国硕士研究生招生考试计算机学科专业基础综合试题 得分：0 耗时：3分 47秒','2026-05-20 13:48:25'),(27,2,'student','学生用户','student 登录了408Master 智能学习系统','2026-05-20 16:05:14'),(28,2,'student','学生用户','student 登录了408Master 智能学习系统','2026-05-20 16:06:02'),(29,2,'student','学生用户','student 登录了408Master 智能学习系统','2026-05-20 16:16:56'),(30,2,'student','学生用户','student 登录了408Master 智能学习系统','2026-05-20 16:17:12'),(31,2,'student','学生用户','student 登录了408Master 智能学习系统','2026-05-20 16:17:33'),(32,2,'student','学生用户','student 登录了408Master 智能学习系统','2026-05-20 16:17:47'),(33,2,'student','学生用户','student 登录了408Master 智能学习系统','2026-05-20 16:18:38'),(34,2,'student','学生用户','student 登录了408Master 智能学习系统','2026-05-20 16:18:52'),(35,2,'student','学生用户','student 登录了408Master 智能学习系统','2026-05-20 16:21:07'),(36,2,'student','学生用户','student 登录了408Master 智能学习系统','2026-05-20 16:26:58'),(37,2,'student','学生用户','student 登录了408Master 智能学习系统','2026-05-20 16:27:18'),(38,2,'student','学生用户','student 登录了408Master 智能学习系统','2026-05-20 16:30:03'),(39,2,'student','学生用户','student 提交试卷：AI限时练习 得分：2 耗时：11 秒','2026-05-20 16:31:30'),(40,1,'admin','管理员','admin 登录了408Master 智能学习系统','2026-05-20 16:37:01'),(41,2,'student','学生用户','student 登录了408Master 智能学习系统','2026-05-20 16:41:40'),(42,1,'admin','管理员','admin 登录了408Master 智能学习系统','2026-05-20 16:46:07'),(43,1,'admin','管理员','admin 登录了408Master 智能学习系统','2026-05-20 16:50:32'),(44,2,'student','学生用户','student 登录了408Master 智能学习系统','2026-05-20 16:50:33'),(45,1,'admin','管理员','admin 登录了408Master 智能学习系统','2026-05-20 16:57:09'),(46,2,'student','学生用户','student 登录了408Master 智能学习系统','2026-05-20 16:58:48'),(47,2,'student','学生用户','student 提交试卷：AI限时练习 得分：0 耗时：2 秒','2026-05-20 16:59:08'),(48,2,'student','学生用户','student 登录了408Master 智能学习系统','2026-05-22 17:31:37'),(49,1,'admin','管理员','admin 登录了408Master 智能学习系统','2026-05-22 17:32:31'),(50,2,'student','学生用户','student 登录了408Master 智能学习系统','2026-05-22 17:32:57'),(51,2,'student','学生用户','student 登录了408Master 智能学习系统','2026-05-22 17:35:30'),(52,2,'student','学生用户','student 登录了408Master 智能学习系统','2026-05-22 19:06:07'),(53,2,'student','学生用户','student 登录了408Master 智能学习系统','2026-05-22 19:32:05'),(54,2,'student','学生用户','student 登录了408Master 智能学习系统','2026-05-30 00:27:34'),(55,1,'admin','管理员','admin 登录了408Master 智能学习系统','2026-05-30 00:28:25');
/*!40000 ALTER TABLE `t_user_event_log` ENABLE KEYS */;

--
-- Dumping data for table `t_user_learning_event`
--

/*!40000 ALTER TABLE `t_user_learning_event` DISABLE KEYS */;
/*!40000 ALTER TABLE `t_user_learning_event` ENABLE KEYS */;

--
-- Dumping data for table `t_user_learning_profile`
--

/*!40000 ALTER TABLE `t_user_learning_profile` DISABLE KEYS */;
/*!40000 ALTER TABLE `t_user_learning_profile` ENABLE KEYS */;

--
-- Dumping data for table `t_user_skill_feedback`
--

/*!40000 ALTER TABLE `t_user_skill_feedback` DISABLE KEYS */;
/*!40000 ALTER TABLE `t_user_skill_feedback` ENABLE KEYS */;

--
-- Dumping data for table `t_user_token`
--

/*!40000 ALTER TABLE `t_user_token` DISABLE KEYS */;
/*!40000 ALTER TABLE `t_user_token` ENABLE KEYS */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-05-30  0:37:33
-- Dump completed on 2026-05-30
