-- ============================================
-- 大题（综合应用题）导入SQL
-- ============================================

USE xzs;

START TRANSACTION;
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(1, 2011, 41, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(1, 2011, 42, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(2, 2011, 43, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(2, 2011, 44, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(3, 2011, 45, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(3, 2011, 46, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(4, 2011, 47, '某主机的 MAC 地址为 00-15-C5-C1-5E-28，IP 地址为 10.2.128.100（私有地址）。题 47-a 图是网络拓扑，题 47-b 图是该主机进行 Web 请求的 1 个以太网数据帧前 80 个字节的十六进制及 ASCII 码内容。
确认号头部长度服务类型总长度标识标志片偏移生存时间（TTL）协议头部校验和源 IP 地址目的 IP 地址47-d 图  IP 分组头结构08162432位目的 MAC 地址源 MAC 地址类型数  据CRC6B6B2B46~1500B4B47-c 图  以太网帧结构0021272151ee0015c5c15e280800450001ef113b40008006ba9d0a02806440aa622004ff0050e0e200fa7bf9f8055018faf01ac40000474554202f7266632e68746d6c20485454502f312e310d0a416300000010002000300040.!!Q.. ..^(..E....:@... .....d@.b ...P.. ..{...P.......GET /rfc.htmI HTTP /1.1..Ac47-b 图  以太网数据帧（前 80B）Internet10.2.128.10010.2.128.1101.12.123.15MTU = 1500B47-a 图 网络拓扑
确认号头部长度服务类型总长度标识标志片偏移生存时间（TTL）协议头部校验和源 IP 地址目的 IP 地址47-d 图  IP 分组头结构08162432位目的 MAC 地址源 MAC 地址类型数  据CRC6B6B2B46~1500B4B47-c 图  以太网帧结构0021272151ee0015c5c15e280800450001ef113b40008006ba9d0a02806440aa622004ff0050e0e200fa7bf9f8055018faf01ac40000474554202f7266632e68746d6c20485454502f312e310d0a416300000010002000300040.!!Q.. ..^(..E....:@... .....d@.b ...P.. ..{...P.......GET /rfc.htmI HTTP /1.1..Ac47-b 图  以太网数据帧（前 80B）Internet10.2.128.10010.2.128.1101.12.123.15MTU = 1500B47-a 图 网络拓扑
确认号
确认号
确认号
头部长度
头部长度
头部长度
服务类型
服务类型
服务类型
总长度
总长度
总长度
标识
标识
标识
标志
标志
标志
片偏移
片偏移
片偏移
生存时间（TTL）
生存时间（TTL）
生存时间（TTL）
协议
协议
协议
', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(1, 2012, 41, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(1, 2012, 42, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(2, 2012, 43, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(2, 2012, 44, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(3, 2012, 45, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(3, 2012, 46, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(4, 2012, 47, '主机 H 通过快速以太网连接 Internet，IP 地址为 192.168.0.8，服务器 S 的 IP 地址为 211.68.71.80。H 与 S 使用 TCP 通信时，在 H 上捕获的其中 5 个 IP 分组如题 47-a 表所示。

请回答下列问题。
(1) 题 47-a 表中的 IP 分组中，哪几个是由 H 发送的？哪几个完成了 TCP 连接建立过程？哪几个在通过快速以太网传输时进行了填充？
(2) 根据题 47-a 表中的 IP 分组，分析 S 已经收到的应用层数据字节数是多少？
(3) 若题 47-a 表中的某个 IP 分组在 S 发出时的前 40 字节如题 47-b 表所示，则该 IP 分组到达 H 时经过了多少个路由器？
45 00 00 2868 11 40 0040 06 ec add3 44 47 50ca 76 01 0613 88 a1 08e0 s9 9f f084 6b 41 d650 10 16 d0b7 d6 00 00来自 S 的分组47-b 表注意：IP 分组头 和 TCP 段头结构分别如 47-a 图和 47-b 图所示确认号头部长度服务类型总长度标识标志片偏移生存时间（TTL）协议头部校验和源 IP 地址目的 IP 地址47-a 图  IP 分组头结构08162432位源端口确认号序号确认号保留URGACKPSHRSTSYNFIN保留目的端口校验和紧急指针选项（长度可变）填充47-b 图 TCP 段头结构08162432TCP首部20B的固定首部
45 00 00 2868 11 40 0040 06 ec add3 44 47 50ca 76 01 0613 88 a1 08e0 s9 9f f084 6b 41 d650 10 16 d0b7 d6 00 00来自 S 的分组47-b 表注意：IP 分组头 和 TCP 段头结构分别如 47-a 图和 47-b 图所示确认号头部长度服务类型总长度标识标志片偏移生存时间（TTL）协议头部校验和源 IP 地址目的 IP 地址47-a 图  IP 分组头结构08162432位源端口确认号序号确认号保留URGACKPSHRSTSYNFIN保留目的端口校验和紧急指针选项（长度可变）填充47-b 图 TCP 段头结构08162432TCP首部20B的固定首部
45 00 00 2868 11 40 0040 06 ec add3 44 47 50ca 76 01 06
45 00 00 2868 11 40 0040 06 ec add3 44 47 50ca 76 01 06
45 00 00 2868 11 40 0040 06 ec add3 44 47 50ca 76 01 06
13 88 a1 08e0 s9 9f f084 6b 41 d650 10 16 d0b7 d6 00 00
13 88 a1 08e0 s9 9f f084 6b 41 d650 10 16 d0b7 d6 00 00
13 88 a1 08e0 s9 9f f084 6b 41 d650 10 16 d0b7 d6 00 00
来自 S 的分组
来自 S 的分组
来自 S 的分组
47-b 表
47-b 表
47-b 表
注意：IP 分组头 和 TCP 段头结构分别如 47-a 图和 47-b 图所示
注意：IP 分组头 和 TCP 段头结构分别如 47-a 图和 47-b 图所示
注意：IP 分组头 和 TCP 段头结构分别如 47-a 图和 47-b 图所示
确认号
确认号
确认号
头部长度
头部长度
头部长度
服务类型
', '[]', 10, '', '(2) 根据题 47-a 表中的 IP 分组，分析 S 已经收到的应用层数据字节数是多少？
', 'crawler\data\essay_images\2012_计算机网络_47_1.svg');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(1, 2013, 41, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(1, 2013, 42, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(2, 2013, 43, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(2, 2013, 44, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(3, 2013, 45, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(3, 2013, 46, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(4, 2013, 47, '假设 Internet 的两个自治系统构成的网络如题 47 图所示，自治系统 AS1 由路由器 R1 连接两个子网构成；自治系统 AS2 由路由器 R2、R3 互联并连接 3 个子网构成。各子网地址、R2 的接口名、R1 与 R3 的部分接口 IP 地址如题 47 图所示。
153.14.5.128/25194.17.20.128/25194.17.21.0/25194.17.20.0/25153.14.5.0/25R1R2S0S1E0R3153.14.3.2194.17.24.2AS1AS2
153.14.5.128/25194.17.20.128/25194.17.21.0/25194.17.20.0/25153.14.5.0/25R1R2S0S1E0R3153.14.3.2194.17.24.2AS1AS2
153.14.5.128/25
153.14.5.128/25
153.14.5.128/25
194.17.20.128/25
194.17.20.128/25
194.17.20.128/25
194.17.21.0/25
194.17.21.0/25
194.17.21.0/25
194.17.20.0/25
194.17.20.0/25
194.17.20.0/25
153.14.5.0/25
153.14.5.0/25
153.14.5.0/25
R1
R1
R1
R2
R2
R2
S0
S0
S0
S1
S1
S1
', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(1, 2014, 41, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(1, 2014, 42, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(4, 2014, 43, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(2, 2014, 44, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(2, 2014, 45, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(3, 2014, 46, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(3, 2014, 47, '系统中有多个生产者进程和多个消费者进程，共享一个能存放 1000 件产品的环形缓冲区（初始为空）。当缓冲区未满时，生产者进程可以放入其生产的一件产品，否则等待；当缓冲区未空时，消费者进程可以从缓冲区取走一件产品，否则等待。要求一个消费者进程从缓冲区连续取出 10 件产品后，其他消费者进程才可以取产品。请使用信号量 P、V（wait()，signal()）操作实现进程间的互斥与同步，要求写出完整的过程，并说明所用信号量的含义和初值。
同步问题设计查看答案与解析收藏
同步问题设计
查看答案与解析收藏
这是典型的生产者和消费者问题，只对典型问题加了一个条件，只需在标准模型上新加一
个信号量，即可完成指定要求。设置四个变量 consumer_mutex、buffer_mutex、empty 和 full, consumer_mutex 用于一个控制一个消费者进程一个
周期（10 次）内对于缓冲区的控制，初值为 1；buffer_mutex 用于进程单次互斥的访问缓冲区，初值
为 1；empty 代表缓冲区的空位数，初值为 0；full 代表缓冲区的产品数，初值为 1000，具体进
程的描述如下：semaphoreconsumer_mutex=1;semaphorebuffer_mutex=1;semaphorefull=0;semaphoreempty=1000;Consumer(){while(1){P(consumer_mutex);for(inti=0;i<10;i++){P(full);P(buffer_mutex);从缓冲区取出产品;V(buffer_mutex);V(empty);消费产品;}V(consumer_mutex);}}Producer(){while(1){P(empty);生产产品;P(buffer_mutex);将产品放入缓冲区;V(buffer_mutex);V(full);}}【评分说明】①信号量的初值和含义都正确给 2 分。②生产者之间的互斥操作正确给 1 分；生产者与消费者之间的同步操作正确给 2 分；消费者之间互斥操作正确给 1 分。③控制消费者连续取产品数量正确给 2 分。④仅给出经典生产者 - 消费者问题的信号量定义和伪代码描述最多给 3 分。⑤若考生将题意理解成缓冲区至少有 10 件产品，消费者才能开始取，其他均正确，得 6 分。⑥部分完全正确，酌情给分。
这是典型的生产者和消费者问题，只对典型问题加了一个条件，只需在标准模型上新加一
个信号量，即可完成指定要求。
设置四个变量 consumer_mutex、buffer_mutex、empty 和 full, consumer_mutex 用于一个控制一个消费者进程一个
周期（10 次）内对于缓冲区的控制，初值为 1；buffer_mutex 用于进程单次互斥的访问缓冲区，初值
为 1；empty 代表缓冲区的空位数，初值为 0；full 代表缓冲区的产品数，初值为 1000，具体进
程的描述如下：
semaphoreconsumer_mutex=1;semaphorebuffer_mutex=1;semaphorefull=0;semaphoreempty=1000;Consumer(){while(1){P(consumer_mutex);for(inti=0;i<10;i++){P(full);P(buffer_mutex);从缓冲区取出产品;V(buffer_mutex);V(empty);消费产品;}V(consumer_mutex);}}Producer(){while(1){P(empty);生产产品;P(buffer_mutex);将产品放入缓冲区;V(buffer_mutex);V(full);}}
semaphoreconsumer_mutex=1;semaphorebuffer_mutex=1;semaphorefull=0;semaphoreempty=1000;Consumer(){while(1){P(consumer_mutex);for(inti=0;i<10;i++){P(full);P(buffer_mutex);从缓冲区取出产品;V(buffer_mutex);V(empty);消费产品;}V(consumer_mutex);}}Producer(){while(1){P(empty);生产产品;P(buffer_mutex);将产品放入缓冲区;V(buffer_mutex);V(full);}}
【评分说明】
①信号量的初值和含义都正确给 2 分。
②生产者之间的互斥操作正确给 1 分；生产者与消费者之间的同步操作正确给 2 分；消费者之间互斥操作正确给 1 分。
③控制消费者连续取产品数量正确给 2 分。
④仅给出经典生产者 - 消费者问题的信号量定义和伪代码描述最多给 3 分。
⑤若考生将题意理解成缓冲区至少有 10 件产品，消费者才能开始取，其他均正确，得 6 分。
⑥部分完全正确，酌情给分。


©
2026计算机考研杂货铺保留所有权利皖ICP备2023022234号
©
2026计算机考研杂货铺保留所有权利皖ICP备2023022234号


©
2026计算机考研杂货铺保留所有权利皖ICP备2023022234号



', '[]', 10, '同步问题设计查看答案与解析收藏
查看答案与解析收藏
', '同步问题设计查看答案与解析收藏
查看答案与解析收藏
', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(1, 2015, 41, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(1, 2015, 42, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(2, 2015, 43, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(2, 2015, 44, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(3, 2015, 45, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(3, 2015, 46, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(4, 2015, 47, '某网络拓扑如题 47 图所示，其中路由器内网接口、DHCP 服务器、WWW 服务器与主机 1 均采用静态 IP 地址配置，相关地址信息见图中标注；主机 2～主机 N 通过 DHCP 服务器动态获取 IP 地址等配置信息。
Internetwww 服务器DHCP 服务器%3CmxGraphModel%3E%3Croot%3E%3CmxCell%20id%3D%220%22%2F%3E%3CmxCell%20id%3D%221%22%20parent%3D%220%22%2F%3E%3CmxCell%20id%3D%222%22%20value%3D%22%26lt%3Bfont%20style%3D%26quot%3Bfont-size%3A%2018px%3B%26quot%3B%26gt%3Bwww%20%E6%9C%8D%E5%8A%A1%E5%99%A8%26lt%3B%2Ffont%26gt%3B%22%20style%3D%22text%3Bhtml%3D1%3Balign%3Dcenter%3BverticalAlign%3Dmiddle%3BwhiteSpace%3Dwrap%3Brounded%3D0%3B%22%20vertex%3D%221%22%20parent%3D%221%22%3E%3CmxGeometry%20x%3D%223.3900000000000006%22%20y%3D%2260%22%20width%3D%22120%22%20height%3D%2240%22%20as%3D%22geometry%22%2F%3E%3C%2FmxCell%3E%3C%2Froot%3E%3C%2FmxGraphModel%3E主机 1主机 2主机 N以太网交换机111.123.15.4/24111.123.15.3/24111.123.15.2/2400-b1-b1-b1-b1-b1111.123.15.1/2400-a1-a1-a1-a1-a1路由器
Internetwww 服务器DHCP 服务器%3CmxGraphModel%3E%3Croot%3E%3CmxCell%20id%3D%220%22%2F%3E%3CmxCell%20id%3D%221%22%20parent%3D%220%22%2F%3E%3CmxCell%20id%3D%222%22%20value%3D%22%26lt%3Bfont%20style%3D%26quot%3Bfont-size%3A%2018px%3B%26quot%3B%26gt%3Bwww%20%E6%9C%8D%E5%8A%A1%E5%99%A8%26lt%3B%2Ffont%26gt%3B%22%20style%3D%22text%3Bhtml%3D1%3Balign%3Dcenter%3BverticalAlign%3Dmiddle%3BwhiteSpace%3Dwrap%3Brounded%3D0%3B%22%20vertex%3D%221%22%20parent%3D%221%22%3E%3CmxGeometry%20x%3D%223.3900000000000006%22%20y%3D%2260%22%20width%3D%22120%22%20height%3D%2240%22%20as%3D%22geometry%22%2F%3E%3C%2FmxCell%3E%3C%2Froot%3E%3C%2FmxGraphModel%3E主机 1主机 2主机 N以太网交换机111.123.15.4/24111.123.15.3/24111.123.15.2/2400-b1-b1-b1-b1-b1111.123.15.1/2400-a1-a1-a1-a1-a1路由器
Internet
Internet
Internet
www 服务器
www 服务器
www 服务器
DHCP 服务器%3CmxGraphModel%3E%3Croot%3E%3CmxCell%20id%3D%220%22%2F%3E%3CmxCell%20id%3D%221%22%20parent%3D%220%22%2F%3E%3CmxCell%20id%3D%222%22%20value%3D%22%26lt%3Bfont%20style%3D%26quot%3Bfont-size%3A%2018px%3B%26quot%3B%26gt%3Bwww%20%E6%9C%8D%E5%8A%A1%E5%99%A8%26lt%3B%2Ffont%26gt%3B%22%20style%3D%22text%3Bhtml%3D1%3Balign%3Dcenter%3BverticalAlign%3Dmiddle%3BwhiteSpace%3Dwrap%3Brounded%3D0%3B%22%20vertex%3D%221%22%20parent%3D%221%22%3E%3CmxGeometry%20x%3D%223.3900000000000006%22%20y%3D%2260%22%20width%3D%22120%22%20height%3D%2240%22%20as%3D%22geometry%22%2F%3E%3C%2FmxCell%3E%3C%2Froot%3E%3C%2FmxGraphModel%3E
DHCP 服务器%3CmxGraphModel%3E%3Croot%3E%3CmxCell%20id%3D%220%22%2F%3E%3CmxCell%20id%3D%221%22%20parent%3D%220%22%2F%3E%3CmxCell%20id%3D%222%22%20value%3D%22%26lt%3Bfont%20style%3D%26quot%3Bfont-size%3A%2018px%3B%26quot%3B%26gt%3Bwww%20%E6%9C%8D%E5%8A%A1%E5%99%A8%26lt%3B%2Ffont%26gt%3B%22%20style%3D%22text%3Bhtml%3D1%3Balign%3Dcenter%3BverticalAlign%3Dmiddle%3BwhiteSpace%3Dwrap%3Brounded%3D0%3B%22%20vertex%3D%221%22%20parent%3D%221%22%3E%3CmxGeometry%20x%3D%223.3900000000000006%22%20y%3D%2260%22%20width%3D%22120%22%20height%3D%2240%22%20as%3D%22geometry%22%2F%3E%3C%2FmxCell%3E%3C%2Froot%3E%3C%2FmxGraphModel%3E
DHCP 服务器%3CmxGraphModel%3E%3Croot%3E%3CmxCell%20id%3D%220%22%2F%3E%3CmxCell%20id%3D%221%22%20parent%3D%220%22%2F%3E%3CmxCell%20id%3D%222%22%20value%3D%22%26lt%3Bfont%20style%3D%26quot%3Bfont-size%3A%2018px%3B%26quot%3B%26gt%3Bwww%20%E6%9C%8D%E5%8A%A1%E5%99%A8%26lt%3B%2Ffont%26gt%3B%22%20style%3D%22text%3Bhtml%3D1%3Balign%3Dcenter%3BverticalAlign%3Dmiddle%3BwhiteSpace%3Dwrap%3Brounded%3D0%3B%22%20vertex%3D%221%22%20parent%3D%221%22%3E%3CmxGeometry%20x%3D%223.3900000000000006%22%20y%3D%2260%22%20width%3D%22120%22%20height%3D%2240%22%20as%3D%22geometry%22%2F%3E%3C%2FmxCell%3E%3C%2Froot%3E%3C%2FmxGraphModel%3E
主机 1
主机 1
主机 1
主机 2
主机 2
主机 2
主机 N
主机 N
主机 N
以太网交换机
以太网交换机
以太网交换机
111.123.15.4/24
111.123.15.4/24
111.123.15.4/24
111.123.15.3/24
111.123.15.3/24
111.123.15.3/24
', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(4, 2016, 41, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(1, 2016, 42, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(1, 2016, 43, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(2, 2016, 44, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(2, 2016, 45, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(3, 2016, 46, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(3, 2016, 47, '某磁盘文件系统使用链接分配方式组织文件，簇大小为 4KB。目录文件的每个目录项包括文件名和文件的第一个簇号，其他簇号存放在文件分配表 FAT 中。
(1) 假定目录树如下图所示，各文件占用的簇号及顺序如下表所示，其中 dir、dir1 是目录，file1、file2 是用户文件。请给出所有目录文件的内容。
dirdir1file1file2文件名簇号dir1dir148file1100、106、108file2200、201、202
dirdir1file1file2文件名簇号dir1dir148file1100、106、108file2200、201、202
dir
dir
dir
dir1
dir1
dir1
file1
file1
file1
file2
file2
file2
文件名
文件名
文件名
簇号
簇号
簇号
dir
dir
dir
1
1
1
dir1
dir1
', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(1, 2017, 41, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(1, 2017, 42, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(2, 2017, 43, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(2, 2017, 44, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(3, 2017, 45, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(3, 2017, 46, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(4, 2017, 47, '甲乙双方均采用后退 N 帧协议 (GBN) 进行持续的双向数据传输，且双方始终采用捎带确认，帧长均为 1000 B。Sx,y​和Rx,y​分别表示甲方和乙方发送的数据帧，其中：x是发送序号；y是确认序号（表示希望接收对方的下一帧序号）；数据帧的发送序号和确认序号字段均为 3 比特。信道传输速率为 100 Mbps，RTT = 0.96 ms。下图给出了甲方发送数据帧和接收数据帧的两种场景，其中t0​为初始时刻，此时甲方的发送和确认序号均为 0，t1​时刻甲方有足够多的数据待发送。

请回答下列问题。
(1) 对于图 (a)，t0​时刻到t1​时刻期间，甲方可以断定乙方已正确接收的数据帧数是多少？正确接收的是哪几个帧（请用Sx,y​形式给出）？
(2) 对于图 (a)，从t1​时刻起，甲方在不出现超时且未收到乙方新的数据帧之前，最多还可以发送多少个数据帧？其中第一个帧和最后一个帧分别是哪个（请用Sx,y​形式给出）？
(3) 对于图 (b)，从t1​时刻起，甲方在不出现新的超时且未收到乙方新的数据帧之前，需要重发多少个数据帧？重发的第一个帧是哪个（请用Sx,y​形式给出）？
(4) 甲方可以达到的最大信道利用率是多少？
ARQ协议信道利用率查看答案与解析收藏
ARQ协议信道利用率
查看答案与解析收藏
1）6 时刻到 t 时刻期间，甲方可以断定乙方已正确接收了 3 个数据帧，（1 分）分别是S0,0​,S1,0​,S2,0​（1 分）。R3,3​说明乙发送的数据帧确认号是 3，即希望甲发送序号 3 的数据帧，说明乙已经接收了序号为 0~2 的数据帧。2）从t1​时刻起，甲方最多还可以发送 5 个数据帧（1 分），其中第一个帧是S5,2​（1 分），最后一个数据帧是S1,2​（1 分）。发送序号 3 位，有 8 个序号。在 GBN 协议中，序号个数 ≥ 发送窗口 + 1，所以这里发送窗口最大为 7。此时已发送了S3,0​和S4,1​，所以最多还可以发送 5 个帧。3）甲方需要重发 3 个数据帧（1 分），重发的第一个帧是S2,3​（1 分）。在 GBN 协议中，接收方发送了 N 帧后，检测出错，则需要发送出错帧及其之后的帧。S2,0​超时，所以重发的第一帧是S2​。已收到乙的R2​帧，所以确认号应为 3。\\[
\\frac{7 \\times \\frac{8 \\times 1000}{100 \\times 10^6}}{0.96 \\times 10^{-3} + 2 \\times \\frac{8 \\times 1000}{100 \\times 10^6}} \\times 100\\% = 50%
\\]4）甲方可以达到的最大信道利用率是U= 发送数据的时间/从开始发送第一帧到收到第一个确认帧的时间 =N⋅Td/(Td+RTT+Ta)U是信道利用率，N是发送窗口的最大值，Td是发送一数据帧的时间，RTT是往返时间，Ta是发送一确认帧的时间。这里采用捎带确认，Td=Ta。【评分说明】答案部分正确，酌情给分。
1）6 时刻到 t 时刻期间，甲方可以断定乙方已正确接收了 3 个数据帧，（1 分）分别是S0,0​,S1,0​,S2,0​（1 分）。R3,3​说明乙发送的数据帧确认号是 3，即希望甲发送序号 3 的数据帧，说明乙已经接收了序号为 0~2 的数据帧。
2）从t1​时刻起，甲方最多还可以发送 5 个数据帧（1 分），其中第一个帧是S5,2​（1 分），最后一个数据帧是S1,2​（1 分）。发送序号 3 位，有 8 个序号。在 GBN 协议中，序号个数 ≥ 发送窗口 + 1，所以这里发送窗口最大为 7。此时已发送了S3,0​和S4,1​，所以最多还可以发送 5 个帧。
3）甲方需要重发 3 个数据帧（1 分），重发的第一个帧是S2,3​（1 分）。在 GBN 协议中，接收方发送了 N 帧后，检测出错，则需要发送出错帧及其之后的帧。S2,0​超时，所以重发的第一帧是S2​。已收到乙的R2​帧，所以确认号应为 3。
\\[
\\frac{7 \\times \\frac{8 \\times 1000}{100 \\times 10^6}}{0.96 \\times 10^{-3} + 2 \\times \\frac{8 \\times 1000}{100 \\times 10^6}} \\times 100\\% = 50%
\\]
4）甲方可以达到的最大信道利用率是
U= 发送数据的时间/从开始发送第一帧到收到第一个确认帧的时间 =N⋅Td/(Td+RTT+Ta)
U是信道利用率，N是发送窗口的最大值，Td是发送一数据帧的时间，RTT是往返时间，Ta是发送一确认帧的时间。这里采用捎带确认，Td=Ta。
【评分说明】答案部分正确，酌情给分。


©
2026计算机考研杂货铺保留所有权利皖ICP备2023022234号
©
2026计算机考研杂货铺保留所有权利皖ICP备2023022234号


©
2026计算机考研杂货铺保留所有权利皖ICP备2023022234号



', '[]', 10, 'ARQ协议信道利用率查看答案与解析收藏
查看答案与解析收藏
1）6 时刻到 t 时刻期间，甲方可以断定乙方已正确接收了 3 个数据帧，（1 分）分别是S0,0​,S1,0​,S2,0​（1 分）。R3,3​说明乙发送的数据帧确认号是 3，即希望甲发送序号 3 的数据帧，说明乙已经接收了序号为 0~2 的数据帧。2）从t1​时刻起，甲方最多还可以发送 5 个数据帧（1 分），其中第一个帧是S5,2​（1 分），最后一个数据帧是S1,2​（1 分）。发送序号 3 位，有 8 个序号。在 GBN 协议中，序号个数 ≥ 发送窗口 + 1，所以这里发送窗口最大为 7。此时已发送了S3,0​和S4,1​，所以最多还可以发送 5 个帧。3）甲方需要重发 3 个数据帧（1 分），重发的第一个帧是S2,3​（1 分）。在 GBN 协议中，接收方发送了 N 帧后，检测出错，则需要发送出错帧及其之后的帧。S2,0​超时，所以重发的第一帧是S2​。已收到乙的R2​帧，所以确认号应为 3。\\[
\\frac{7 \\times \\frac{8 \\times 1000}{100 \\times 10^6}}{0.96 \\times 10^{-3} + 2 \\times \\frac{8 \\times 1000}{100 \\times 10^6}} \\times 100\\% = 50%
\\]4）甲方可以达到的最大信道利用率是U= 发送数据的时间/从开始发送第一帧到收到第一个确认帧的时间 =N⋅Td/(Td+RTT+Ta)U是信道利用率，N是发送窗口的最大值，Td是发送一数据帧的时间，RTT是往返时间，Ta是发送一确认帧的时间。这里采用捎带确认，Td=Ta。【评分说明】答案部分正确，酌情给分。
【评分说明】答案部分正确，酌情给分。
', 'ARQ协议信道利用率查看答案与解析收藏
查看答案与解析收藏
', 'crawler\data\essay_images\2017_计算机网络_47_1.svg');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(1, 2018, 41, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(1, 2018, 42, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(2, 2018, 43, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(2, 2018, 44, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(3, 2018, 45, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(3, 2018, 46, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(4, 2018, 47, '某公司网络如题 47 图所示。IP 地址空间 192.168.1.0/24 被均分给销售部和技术部两个子网，并已分别为部分主机和路由器接口分配了 IP 地址，销售部子网的 MTU=1500 B，技术部子网的 MTU=800 B。
技术部已分配地址192.168.1.129 ~ 192.168.1.208销售部已分配地址192.168.1.1 ~ 192.168.1.20路由器F0F1192.168.1.126192.168.1.254MTU = 1500BMTU = 800B
技术部已分配地址192.168.1.129 ~ 192.168.1.208销售部已分配地址192.168.1.1 ~ 192.168.1.20路由器F0F1192.168.1.126192.168.1.254MTU = 1500BMTU = 800B
技术部
技术部
技术部
已分配地址
已分配地址
已分配地址
192.168.1.129 ~ 192.168.1.208
192.168.1.129 ~ 192.168.1.208
192.168.1.129 ~ 192.168.1.208
销售部
销售部
销售部
已分配地址
已分配地址
已分配地址
192.168.1.1 ~ 192.168.1.20
192.168.1.1 ~ 192.168.1.20
192.168.1.1 ~ 192.168.1.20
路由器
路由器
路由器
F0
F0
F0
F1
F1
F1
', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(1, 2019, 41, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(1, 2019, 42, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(3, 2019, 43, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(3, 2019, 44, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(2, 2019, 45, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(2, 2019, 46, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(4, 2019, 47, '某网络拓扑如题 47 图所示，其中 R 为路由器，主机 HI~H4 的 IP 地址配置以及 R 的各接口 IP 地址配置如图中所示。现有若干台以太网交换机（无 VLAN 功能）和路由器两类网络互连设备可供选择。
Internet设备 1设备 2设备 3101.1.2.10192.168.1.253/30IF1IF2IF3IF1IF2IF3IF1IF2IF3H1H2H3H4IP 地址：192.168.1.2/26默认网关：192.168.1.1IP 地址：192.168.1.3/26默认网关：192.168.1.1IP 地址：192.168.1.66/26默认网关：192.168.1.65IP 地址：192.168.1.67/26默认网关：192.168.1.65
Internet设备 1设备 2设备 3101.1.2.10192.168.1.253/30IF1IF2IF3IF1IF2IF3IF1IF2IF3H1H2H3H4IP 地址：192.168.1.2/26默认网关：192.168.1.1IP 地址：192.168.1.3/26默认网关：192.168.1.1IP 地址：192.168.1.66/26默认网关：192.168.1.65IP 地址：192.168.1.67/26默认网关：192.168.1.65
Internet
Internet
Internet
设备 1
设备 1
设备 1
设备 2
设备 2
设备 2
设备 3
设备 3
设备 3
101.1.2.10
101.1.2.10
101.1.2.10
192.168.1.253/30
192.168.1.253/30
192.168.1.253/30
IF1
IF1
IF1
IF2
IF2
IF2
IF3
IF3
IF3
', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(1, 2020, 41, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(1, 2020, 42, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(2, 2020, 43, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(2, 2020, 44, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(3, 2020, 45, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(3, 2020, 46, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(4, 2020, 47, '某校园网有两个局域网，通过路由器 R1、R2 和 R3 互联后接入 Internet，S1 和 S2 为 以太网交换机，局域网采用静态 IP 地址配置，路由器部分接口以及各主机的 IP 地址如图所示：
Internet203.10.2.5/30203.10.2.1/30203.10.2.2/30192.168.1.1NATNAT203.10.2.6/30192.168.1.1S1S2web 服务器H1192.168.1.2192.168.1.3H2H3192.168.1.2192.168.1.3R1R2R3
Internet203.10.2.5/30203.10.2.1/30203.10.2.2/30192.168.1.1NATNAT203.10.2.6/30192.168.1.1S1S2web 服务器H1192.168.1.2192.168.1.3H2H3192.168.1.2192.168.1.3R1R2R3
Internet
Internet
Internet
203.10.2.5/30
203.10.2.5/30
203.10.2.5/30
203.10.2.1/30
203.10.2.1/30
203.10.2.1/30
203.10.2.2/30
203.10.2.2/30
203.10.2.2/30
192.168.1.1
192.168.1.1
192.168.1.1
NAT
NAT
NAT
NAT
NAT
NAT
203.10.2.6/30
203.10.2.6/30
203.10.2.6/30
192.168.1.1
192.168.1.1
192.168.1.1
', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(1, 2021, 41, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(1, 2021, 42, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(2, 2021, 43, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(2, 2021, 44, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(3, 2021, 45, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(3, 2021, 46, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(4, 2021, 47, '某网络拓扑如题 47 图所示，以太网交换机 S 通过路由器 R 与 Internet 互联。路由器部分接口、本地域名服务器、H1、H2 的 IP 地址和 MAC 地址如图中所示。在 t0 时刻 H1 的 ARP 表和 S 的交换表均为空，H1 在此刻利用浏览器通过域名www.abc.com请求访问 Web 服务器，在 t1 时刻（t1→t0）S 第一次收到了封装 HTTP 请求报文的以太网帧，假设从 t0 到 t1 期间网络未发生任何与此次 Web 访问无关的网络通信。
www.abc.comWeb 服务器192.168.1.1/2500-11-22-33-44-aaR本地域名服务器192.168.1.126/2500-11-22-33-44-bb192.168.1.2/2500-11-22-33-44-ccH2192.168.1.3/2500-11-22-33-44-ddS1234H1Internet
www.abc.comWeb 服务器192.168.1.1/2500-11-22-33-44-aaR本地域名服务器192.168.1.126/2500-11-22-33-44-bb192.168.1.2/2500-11-22-33-44-ccH2192.168.1.3/2500-11-22-33-44-ddS1234H1Internet
www.abc.com
www.abc.com
www.abc.com
Web 服务器
Web 服务器
Web 服务器
192.168.1.1/25
192.168.1.1/25
192.168.1.1/25
00-11-22-33-44-aa
00-11-22-33-44-aa
00-11-22-33-44-aa
R
R
R
本地域名服务器
本地域名服务器
本地域名服务器
192.168.1.126/25
192.168.1.126/25
192.168.1.126/25
00-11-22-33-44-bb
00-11-22-33-44-bb
00-11-22-33-44-bb
192.168.1.2/25
192.168.1.2/25
192.168.1.2/25
', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(1, 2022, 41, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(1, 2022, 42, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(2, 2022, 43, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(2, 2022, 44, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(3, 2022, 45, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(3, 2022, 46, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(4, 2022, 47, '某网络拓扑如题 47 图所示，R 为路由器，S 为以太网交换机，AP 是 802.11 接入点，路由器的 E0 接口和 DHCP 服务器的 IP 地址配置如图中所示；H1 与 H2 属于同一个广播域，但不属于同一个冲突域；H2 和 H3 属于同一个冲突域；H4 和 H5 已经接入网络，并通过 DHCP 动态获取了 IP 地址。现有路由器、100BaseT 以太网交换机和 100BaseT 集线器 (Hub) 三类设备各若干台。
Internet设备1设备2192.168.0.1/2500-11-11-11-11-A1E0SAP00-11-11-11-11-C1DHCP 服务器192.168.0.2/2500-11-11-11-11-B1192.168.0.3/25192.168.0.4/25H4H5H1H2H300-11-11-11-11-D100-11-11-11-11-E1
Internet设备1设备2192.168.0.1/2500-11-11-11-11-A1E0SAP00-11-11-11-11-C1DHCP 服务器192.168.0.2/2500-11-11-11-11-B1192.168.0.3/25192.168.0.4/25H4H5H1H2H300-11-11-11-11-D100-11-11-11-11-E1
Internet
Internet
Internet
设备1
设备1
设备1
设备2
设备2
设备2
192.168.0.1/25
192.168.0.1/25
192.168.0.1/25
00-11-11-11-11-A1
00-11-11-11-11-A1
00-11-11-11-11-A1
E0
E0
E0
S
S
S
AP
AP
AP
00-11-11-11-11-C1
00-11-11-11-11-C1
00-11-11-11-11-C1
', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(1, 2023, 41, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(1, 2023, 42, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(2, 2023, 43, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(2, 2023, 44, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(3, 2023, 45, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(3, 2023, 46, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(4, 2023, 47, '如图，主机 H 登录到 FTP 服务器后，向服务器上传一个大小为 18000B 的文件 F，假设 H 传输 F 建立数据链接时，选择的初始序号为 100，MSS=1000B，拥塞控制的初始阈值是 4MSS，RTT=10ms，忽略 TCP 的传输时延，在 F 的传送过程中，H 以 MSS 段向服务器发送数据，且始终没有错误，丢包和乱序。
H路由器FTP 服务器Intern%3CmxGraphModel%3E%3Croot%3E%3CmxCell%20id%3D%220%22%2F%3E%3CmxCell%20id%3D%221%22%20parent%3D%220%22%2F%3E%3CmxCell%20id%3D%222%22%20value%3D%22%26lt%3Bfont%20face%3D%26quot%3BTimes%20New%20Roman%26quot%3B%26gt%3B%26lt%3Bspan%20style%3D%26quot%3Bfont-size%3A%2016px%3B%26quot%3B%26gt%3BNAT%26amp%3Bnbsp%3B%20R2%26lt%3B%2Fspan%26gt%3B%26lt%3B%2Ffont%26gt%3B%22%20style%3D%22text%3Bhtml%3D1%3Balign%3Dcenter%3BverticalAlign%3Dmiddle%3Bresizable%3D0%3Bpoints%3D%5B%5D%3Bautosize%3D1%3BstrokeColor%3Dnone%3BfillColor%3Dnone%3B%22%20vertex%3D%221%22%20parent%3D%221%22%3E%3CmxGeometry%20x%3D%22818%22%20y%3D%22461%22%20width%3D%2276%22%20height%3D%2231%22%20as%3D%22geometry%22%2F%3E%3C%2FmxCell%3E%3C%2Froot%3E%3C%2FmxGraphModel%3Eet交换机
H路由器FTP 服务器Intern%3CmxGraphModel%3E%3Croot%3E%3CmxCell%20id%3D%220%22%2F%3E%3CmxCell%20id%3D%221%22%20parent%3D%220%22%2F%3E%3CmxCell%20id%3D%222%22%20value%3D%22%26lt%3Bfont%20face%3D%26quot%3BTimes%20New%20Roman%26quot%3B%26gt%3B%26lt%3Bspan%20style%3D%26quot%3Bfont-size%3A%2016px%3B%26quot%3B%26gt%3BNAT%26amp%3Bnbsp%3B%20R2%26lt%3B%2Fspan%26gt%3B%26lt%3B%2Ffont%26gt%3B%22%20style%3D%22text%3Bhtml%3D1%3Balign%3Dcenter%3BverticalAlign%3Dmiddle%3Bresizable%3D0%3Bpoints%3D%5B%5D%3Bautosize%3D1%3BstrokeColor%3Dnone%3BfillColor%3Dnone%3B%22%20vertex%3D%221%22%20parent%3D%221%22%3E%3CmxGeometry%20x%3D%22818%22%20y%3D%22461%22%20width%3D%2276%22%20height%3D%2231%22%20as%3D%22geometry%22%2F%3E%3C%2FmxCell%3E%3C%2Froot%3E%3C%2FmxGraphModel%3Eet交换机
H
H
H
路由器
路由器
路由器
FTP 服务器
FTP 服务器
FTP 服务器
Intern%3CmxGraphModel%3E%3Croot%3E%3CmxCell%20id%3D%220%22%2F%3E%3CmxCell%20id%3D%221%22%20parent%3D%220%22%2F%3E%3CmxCell%20id%3D%222%22%20value%3D%22%26lt%3Bfont%20face%3D%26quot%3BTimes%20New%20Roman%26quot%3B%26gt%3B%26lt%3Bspan%20style%3D%26quot%3Bfont-size%3A%2016px%3B%26quot%3B%26gt%3BNAT%26amp%3Bnbsp%3B%20R2%26lt%3B%2Fspan%26gt%3B%26lt%3B%2Ffont%26gt%3B%22%20style%3D%22text%3Bhtml%3D1%3Balign%3Dcenter%3BverticalAlign%3Dmiddle%3Bresizable%3D0%3Bpoints%3D%5B%5D%3Bautosize%3D1%3BstrokeColor%3Dnone%3BfillColor%3Dnone%3B%22%20vertex%3D%221%22%20parent%3D%221%22%3E%3CmxGeometry%20x%3D%22818%22%20y%3D%22461%22%20width%3D%2276%22%20height%3D%2231%22%20as%3D%22geometry%22%2F%3E%3C%2FmxCell%3E%3C%2Froot%3E%3C%2FmxGraphModel%3Eet
Intern%3CmxGraphModel%3E%3Croot%3E%3CmxCell%20id%3D%220%22%2F%3E%3CmxCell%20id%3D%221%22%20parent%3D%220%22%2F%3E%3CmxCell%20id%3D%222%22%20value%3D%22%26lt%3Bfont%20face%3D%26quot%3BTimes%20New%20Roman%26quot%3B%26gt%3B%26lt%3Bspan%20style%3D%26quot%3Bfont-size%3A%2016px%3B%26quot%3B%26gt%3BNAT%26amp%3Bnbsp%3B%20R2%26lt%3B%2Fspan%26gt%3B%26lt%3B%2Ffont%26gt%3B%22%20style%3D%22text%3Bhtml%3D1%3Balign%3Dcenter%3BverticalAlign%3Dmiddle%3Bresizable%3D0%3Bpoints%3D%5B%5D%3Bautosize%3D1%3BstrokeColor%3Dnone%3BfillColor%3Dnone%3B%22%20vertex%3D%221%22%20parent%3D%221%22%3E%3CmxGeometry%20x%3D%22818%22%20y%3D%22461%22%20width%3D%2276%22%20height%3D%2231%22%20as%3D%22geometry%22%2F%3E%3C%2FmxCell%3E%3C%2Froot%3E%3C%2FmxGraphModel%3Eet
Intern%3CmxGraphModel%3E%3Croot%3E%3CmxCell%20id%3D%220%22%2F%3E%3CmxCell%20id%3D%221%22%20parent%3D%220%22%2F%3E%3CmxCell%20id%3D%222%22%20value%3D%22%26lt%3Bfont%20face%3D%26quot%3BTimes%20New%20Roman%26quot%3B%26gt%3B%26lt%3Bspan%20style%3D%26quot%3Bfont-size%3A%2016px%3B%26quot%3B%26gt%3BNAT%26amp%3Bnbsp%3B%20R2%26lt%3B%2Fspan%26gt%3B%26lt%3B%2Ffont%26gt%3B%22%20style%3D%22text%3Bhtml%3D1%3Balign%3Dcenter%3BverticalAlign%3Dmiddle%3Bresizable%3D0%3Bpoints%3D%5B%5D%3Bautosize%3D1%3BstrokeColor%3Dnone%3BfillColor%3Dnone%3B%22%20vertex%3D%221%22%20parent%3D%221%22%3E%3CmxGeometry%20x%3D%22818%22%20y%3D%22461%22%20width%3D%2276%22%20height%3D%2231%22%20as%3D%22geometry%22%2F%3E%3C%2FmxCell%3E%3C%2Froot%3E%3C%2FmxGraphModel%3Eet
交换机
交换机
交换机
(1) FTP 的控制连接是持久的还是非持久的？FTP 的数据连接是持久的还是非持久的？H 登录服务器时，建立的 FTP 连接是数据连接还是控制连接。
(2) H 通过数据连接发送 F 时，F 的第一个字节序号是多少？在断开数据连接的过程中，FTP 发送的第二次挥手的 ACK 序号是？
(3) F 发送过程中，当 H 收到确认序号为 2101 的确认时，H 的拥塞调整为多少？收到确认序号为 7101 的确认段时，H 的拥窗口调整为多少
(4) H 从请求建立数据连接开始，到确认 F 已被服务全部接收为止，至少要多长时间？期间应用层数平均发送速率是多少？
FTPTCP四次挥手TCP滑动窗口查看答案与解析收藏
FTPTCP四次挥手TCP滑动窗口
查看答案与解析收藏
1）FTP 的控制连接是持久的；数据连接是非持久的；H 登录 FTP 服务器时，建立的 TCP 连接是控制连接。2）F 的第 1 个字节的序号是 101；第二次挥手 ACK 段的确认序号是 18102。3）当 H 收到确认序号为 2101 的确认段时，H 的拥塞窗口调整为 3MSS；收到确认序号为 7101 的确认段时，H 的拥塞窗口调整为 5MSS。4）H 从请求建立数据连接开始，到确认 F 已被服务器全部接收为止，至少需要 6RTT=6*10ms=60ms；期间应用层数据平均发送速率是 18000B/60ms=300*10³B/s=0.3MB/s=2.4Mb/s。
1）FTP 的控制连接是持久的；数据连接是非持久的；H 登录 FTP 服务器时，建立的 TCP 连接是控制连接。
2）F 的第 1 个字节的序号是 101；第二次挥手 ACK 段的确认序号是 18102。
3）当 H 收到确认序号为 2101 的确认段时，H 的拥塞窗口调整为 3MSS；收到确认序号为 7101 的确认段时，H 的拥塞窗口调整为 5MSS。
4）H 从请求建立数据连接开始，到确认 F 已被服务器全部接收为止，至少需要 6RTT=6*10ms=60ms；期间应用层数据平均发送速率是 18000B/60ms=300*10³B/s=0.3MB/s=2.4Mb/s。
', '[]', 10, 'FTPTCP四次挥手TCP滑动窗口查看答案与解析收藏
查看答案与解析收藏
', 'FTPTCP四次挥手TCP滑动窗口查看答案与解析收藏
查看答案与解析收藏
', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(1, 2024, 41, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(1, 2024, 42, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(2, 2024, 43, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(2, 2024, 44, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(3, 2024, 45, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(3, 2024, 46, '', '[]', 10, '', '', '');
INSERT INTO `t_essay_question` (`subject_id`, `year`, `question_no`, `title`, `sub_questions`, `total_score`, `answer`, `analysis`, `images`) VALUES
(4, 2024, 47, '网络空间是继陆海空地之后的"第五疆域"，网络技术是网络疆域建设与治理的基础。路由算法与协议是网络核心技术之一。对其准确认知，合理选择与应用，对网络建设十分重要。假设现有互联网中的 4 个自治系统互连拓扑示意图如题 47 图所示。其中，AS1 运行内部网关协议 RIP；AS3 规模较小，自治系统内任意两个主机间通信，经过路由器数不超过 15 个；AS4 规模较大，自治系统内任意两个主机间通信，经过路由器数量可能超过 20 个。
R11R12R13R14R15R16R33AS1210.2.3.0/24210.2.4.0/24R22R44AS2AS3AS4内部网关协议：RIP136.5.16.0/20
R11R12R13R14R15R16R33AS1210.2.3.0/24210.2.4.0/24R22R44AS2AS3AS4内部网关协议：RIP136.5.16.0/20
R11
R11
R11
R12
R12
R12
R13
R13
R13
R14
R14
R14
R15
R15
R15
R16
R16
R16
R33
R33
R33
AS1
AS1
AS1
210.2.3.0/24
210.2.3.0/24
210.2.3.0/24
', '[]', 10, '', '', '');

COMMIT;
-- 共插入 98 道大题
-- 大题导入完成