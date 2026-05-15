SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- 清理原有数据（根据新年级结构重新导入）
-- ----------------------------
DELETE FROM `t_question` WHERE `subject_id` BETWEEN 100 AND 111;
DELETE FROM `t_text_content` WHERE `id` BETWEEN 1000 AND 1016;
DELETE FROM `t_subject` WHERE `id` BETWEEN 100 AND 111;

-- ----------------------------
-- 1. 插入学科数据（4门课 × 3个年级 = 12条）
-- level: 1=期末考, 2=考研, 3=复试
-- ----------------------------
INSERT INTO `t_subject` (`id`, `name`, `level`, `level_name`, `item_order`, `deleted`) VALUES
(100, '数据结构', 1, '期末考', 1, b'0'),
(101, '数据结构', 2, '考研', 2, b'0'),
(102, '数据结构', 3, '复试', 3, b'0'),
(103, '计算机组成原理', 1, '期末考', 4, b'0'),
(104, '计算机组成原理', 2, '考研', 5, b'0'),
(105, '计算机组成原理', 3, '复试', 6, b'0'),
(106, '操作系统', 1, '期末考', 7, b'0'),
(107, '操作系统', 2, '考研', 8, b'0'),
(108, '操作系统', 3, '复试', 9, b'0'),
(109, '计算机网络', 1, '期末考', 10, b'0'),
(110, '计算机网络', 2, '考研', 11, b'0'),
(111, '计算机网络', 3, '复试', 12, b'0');

-- ----------------------------
-- 2. 插入题目内容（t_text_content，16条，复用原有内容）
-- ----------------------------
INSERT INTO `t_text_content` (`id`, `content`, `create_time`) VALUES
(1001, '{"titleContent":"若一个栈的输入序列为1,2,3,4,5，则下列序列中不可能是栈的输出序列的是（）","analyze":"栈遵循后进先出规则。D选项中，当输出4、5后，栈内剩余元素为1、2、3，此时栈顶是3，下一个输出不可能是2（必须先弹出3才能弹出2），因此该序列非法。","questionItemObjects":[{"prefix":"A","content":"2,3,4,1,5","itemUuid":"a1b2c3d4-0001"},{"prefix":"B","content":"5,4,3,2,1","itemUuid":"a1b2c3d4-0002"},{"prefix":"C","content":"2,4,3,5,1","itemUuid":"a1b2c3d4-0003"},{"prefix":"D","content":"4,5,2,3,1","itemUuid":"a1b2c3d4-0004"}]}', NOW()),
(1002, '{"titleContent":"一棵3阶B树，除根节点外，每个节点的关键字个数最少为（）","analyze":"m阶B树的规则：每个节点的子节点数最多为m，最少为⌈m/2⌉（根节点除外）。3阶B树的最少子节点数为⌈3/2⌉=2，而关键字数=子节点数-1，因此最少关键字数为1。","questionItemObjects":[{"prefix":"A","content":"1","itemUuid":"b1b2c3d4-0001"},{"prefix":"B","content":"2","itemUuid":"b1b2c3d4-0002"},{"prefix":"C","content":"3","itemUuid":"b1b2c3d4-0003"},{"prefix":"D","content":"4","itemUuid":"b1b2c3d4-0004"}]}', NOW()),
(1003, '{"titleContent":"设计一个算法，删除单链表中所有值为x的节点，要求时间复杂度O(n)，空间复杂度O(1)。","analyze":"通过双指针遍历链表，找到目标节点直接修改前驱指针完成删除，仅遍历一次，无需额外空间。pre指向当前节点的前驱，p指向当前节点。当p->data==x时，修改pre->next=p->next，释放p，然后p=pre->next；否则pre和p都后移。","questionItemObjects":[{"prefix":"代码","content":"typedef struct LNode { int data; struct LNode *next; } LNode, *LinkList; void deleteX(LinkList &L, int x) { LNode *pre = L, *p = L->next; while (p != NULL) { if (p->data == x) { pre->next = p->next; free(p); p = pre->next; } else { pre = p; p = p->next; } } }","itemUuid":"c1b2c3d4-0001"}],"correct":"通过双指针遍历链表，找到目标节点直接修改前驱指针完成删除，仅遍历一次，无需额外空间。"}', NOW()),
(1004, '{"titleContent":"已知一棵二叉树的前序遍历为ABDEGCFH，中序遍历为DBGEAFHC，请还原该二叉树，并写出后序遍历序列。","analyze":"1. 前序第一个节点A是根节点，中序中A左边的DBGE是左子树，右边的FHC是右子树。2. 左子树前序为BDEG，根为B，中序左子树中B左边D是左节点，右边GE是右子树。3. 以此类推还原出完整二叉树，最终后序遍历序列为：DGEBHFCA。","questionItemObjects":[],"correct":"后序遍历序列为：DGEBHFCA"}', NOW()),
(1005, '{"titleContent":"某计算机Cache容量为16KB，块大小为16B，采用2路组相联映射，则Cache的组数为（）","analyze":"总块数 = Cache容量 / 块大小 = 16KB / 16B = 1024 块。2路组相联意味着每组包含2个块，因此组数 = 总块数 / 路数 = 1024 / 2 = 512。","questionItemObjects":[{"prefix":"A","content":"128","itemUuid":"d1b2c3d4-0001"},{"prefix":"B","content":"256","itemUuid":"d1b2c3d4-0002"},{"prefix":"C","content":"512","itemUuid":"d1b2c3d4-0003"},{"prefix":"D","content":"1024","itemUuid":"d1b2c3d4-0004"}]}', NOW()),
(1006, '{"titleContent":"某指令系统指令字长16位，每个操作数地址码6位，指令分为二地址、一地址、零地址三种。若二地址指令有12种，零地址指令有64种，则一地址指令最多有（）种。","analyze":"二地址指令的操作码占16-6-6=4位，最多16种，用了12种，剩余4个编码用来扩展。这4个编码可以扩展出4*2^6=256种一地址指令，其中最后一部分编码用来扩展零地址，零地址有64种，占用了64/2^6=1个一地址的编码。因此一地址最多有256-1=255种。","questionItemObjects":[{"prefix":"A","content":"255","itemUuid":"e1b2c3d4-0001"},{"prefix":"B","content":"256","itemUuid":"e1b2c3d4-0002"},{"prefix":"C","content":"511","itemUuid":"e1b2c3d4-0003"},{"prefix":"D","content":"1024","itemUuid":"e1b2c3d4-0004"}]}', NOW()),
(1007, '{"titleContent":"已知两个浮点数（阶码用移码，尾数用补码）：x=2^01 × 0.11011011，y=2^10 × 0.10101100，求x+y的结果。","analyze":"1. 对阶：小阶向大阶对齐，x的阶码1，y的阶码2，x的阶码加1，尾数右移1位：x=2^10 × 0.011011011\\n2. 尾数相加：0.011011011 + 0.10101100 = 1.000110011\\n3. 规格化：结果需要右规一次，阶码+1，变为2^11 × 0.100011001\\n4. 舍入：尾数保留8位，采用0舍1入，最终尾数为0.10001101\\n最终结果：x+y=2^11 × 0.10001101","questionItemObjects":[],"correct":"x+y=2^11 × 0.10001101"}', NOW()),
(1008, '{"titleContent":"某计算机主存地址空间256MB，按字节编址，用512K×8位的SRAM芯片，设计32位字长的存储器，问：\\n1. 需要多少个SRAM芯片？\\n2. 地址线如何分配？","analyze":"1. 芯片数量：\\n   - 总容量：256MB = 256M×8位，32位字长需要4位一组位扩展\\n   - 每个芯片容量512K×8位，因此字扩展需要 256M / 512K = 512 组\\n   - 总芯片数：512 × 4 = 2048 个\\n2. 地址分配：\\n   - 地址总长度28位（256MB=2^28），其中低19位是芯片内地址（512K=2^19），高9位是字扩展的片选地址","questionItemObjects":[],"correct":"1. 需要2048个SRAM芯片\\n2. 地址线共28位：低19位为芯片内地址，高9位为片选地址"}', NOW()),
(1009, '{"titleContent":"有三个作业，到达时间分别为0、1、2，运行时间分别为3、2、1，采用非抢占式短作业优先（SJF）调度，平均周转时间为（）","analyze":"非抢占式SJF会等当前作业运行完再调度：\\n- 作业1：0时刻到达，先运行3个单位，结束时间3，周转时间3-0=3\\n- 作业2：接下来运行2个单位，结束时间5，周转时间5-1=4\\n- 作业3：最后运行1个单位，结束时间6，周转时间6-2=4\\n平均周转时间：(3+4+4)/3 ≈ 3.67","questionItemObjects":[{"prefix":"A","content":"3.33","itemUuid":"f1b2c3d4-0001"},{"prefix":"B","content":"3.67","itemUuid":"f1b2c3d4-0002"},{"prefix":"C","content":"4.0","itemUuid":"f1b2c3d4-0003"},{"prefix":"D","content":"4.33","itemUuid":"f1b2c3d4-0004"}]}', NOW()),
(1010, '{"titleContent":"进程页面走向为4,3,2,1,4,3,5,4,3,2,1,5，物理块数为3，采用LRU置换算法，缺页次数为（）","analyze":"LRU会淘汰最久未使用的页面，逐次模拟后，缺页发生在第1、2、3、4、5、6、7、9、10、12次访问，共10次缺页。\\n具体过程：\\n4(缺),3(缺),2(缺),1(缺-淘汰4),4(缺-淘汰3),3(缺-淘汰2),5(缺-淘汰1),4(命中),3(命中),2(缺-淘汰5),1(缺-淘汰4),5(缺-淘汰3)","questionItemObjects":[{"prefix":"A","content":"9","itemUuid":"g1b2c3d4-0001"},{"prefix":"B","content":"10","itemUuid":"g1b2c3d4-0002"},{"prefix":"C","content":"11","itemUuid":"g1b2c3d4-0003"},{"prefix":"D","content":"12","itemUuid":"g1b2c3d4-0004"}]}', NOW()),
(1011, '{"titleContent":"有一个大小为1的缓冲区，生产者负责生产产品放入缓冲区，消费者负责取出产品消费，用PV操作实现同步互斥。","analyze":"通过empty和full实现同步，保证生产者不会在缓冲区满时放入，消费者不会在空时取出；mutex实现互斥，保证同一时间只有一个进程访问缓冲区。\\n\\nsemaphore empty = 1; semaphore full = 0; semaphore mutex = 1;\\n\\n生产者：\\nP(empty); P(mutex); 放入产品; V(mutex); V(full);\\n\\n消费者：\\nP(full); P(mutex); 取出产品; V(mutex); V(empty);","questionItemObjects":[],"correct":"使用三个信号量：empty=1（缓冲区空位），full=0（缓冲区产品数），mutex=1（互斥锁）。生产者先P(empty)再P(mutex)，放入后V(mutex)V(full)；消费者先P(full)再P(mutex)，取出后V(mutex)V(empty)。"}', NOW()),
(1012, '{"titleContent":"某文件系统盘块大小为1KB，每个盘块号占4B，索引节点包含10个直接地址、1个一级间接、1个二级间接、1个三级间接，求单个文件的最大长度。","analyze":"每个盘块可以存 1KB / 4B = 256 个盘块号。\\n- 直接块：10 × 1KB = 10KB\\n- 一级间接：256 × 1KB = 256KB\\n- 二级间接：256 × 256 × 1KB = 65536KB = 64MB\\n- 三级间接：256 × 256 × 256 × 1KB = 16777216KB = 16GB\\n- 总最大长度：10+256+65536+16777216 = 16843018KB ≈ 16GB+64MB+266KB","questionItemObjects":[],"correct":"单个文件最大长度 = 10KB + 256KB + 64MB + 16GB = 16GB+64MB+266KB（约16843018KB）"}', NOW()),
(1013, '{"titleContent":"TCP拥塞控制中，初始cwnd=1，ssthresh=8，当cwnd增长到12时发生了超时，此时新的ssthresh和cwnd分别为（）","analyze":"TCP超时后，会将ssthresh设置为当前cwnd的一半（12/2=6），同时将cwnd重置为1，重新开始慢开始。","questionItemObjects":[{"prefix":"A","content":"6,1","itemUuid":"h1b2c3d4-0001"},{"prefix":"B","content":"6,6","itemUuid":"h1b2c3d4-0002"},{"prefix":"C","content":"8,1","itemUuid":"h1b2c3d4-0003"},{"prefix":"D","content":"8,6","itemUuid":"h1b2c3d4-0004"}]}', NOW()),
(1014, '{"titleContent":"网络192.168.5.0/24，要划分5个子网，每个子网最少18台主机，子网掩码应为（）","analyze":"每个子网需要18台主机，主机位至少需要5位（2^5-2=30≥18，减2是去掉网络号和广播号）。因此网络位为32-5=27位，子网掩码为255.255.255.224，刚好可以划分8个子网，满足5个的需求。","questionItemObjects":[{"prefix":"A","content":"255.255.255.192","itemUuid":"i1b2c3d4-0001"},{"prefix":"B","content":"255.255.255.224","itemUuid":"i1b2c3d4-0002"},{"prefix":"C","content":"255.255.255.240","itemUuid":"i1b2c3d4-0003"},{"prefix":"D","content":"255.255.255.248","itemUuid":"i1b2c3d4-0004"}]}', NOW()),
(1015, '{"titleContent":"TCP连接中，接收方的接收窗口rwnd=400，发送方拥塞窗口cwnd=500，MSS=100B。\\n1. 此时发送方最多可以发送多少字节？\\n2. 之后发送方收到了确认号300，接收方更新rwnd=300，此时发送方最多还能发送多少字节？","analyze":"1. 发送方的实际窗口是min(cwnd, rwnd) = min(500,400)=400B，因此最多发送400B。\\n2. 确认号300说明前300B已经被确认，剩下100B未确认。新的rwnd=300，所以可用窗口是300，减去未确认的100B，还能发送300-100=200B。","questionItemObjects":[],"correct":"1. 最多发送400字节\\n2. 还能发送200字节"}', NOW()),
(1016, '{"titleContent":"路由器R1的路由表：\\n| 目的网络 | 下一跳 | 距离 |\\n| 10.0.0.0 | - | 0 |\\n| 20.0.0.0 | R2 | 2 |\\n| 30.0.0.0 | R3 | 5 |\\n\\n收到邻居R2的路由更新：\\n| 目的网络 | 距离 |\\n| 20.0.0.0 | 2 |\\n| 30.0.0.0 | 3 |\\n| 40.0.0.0 | 4 |\\n\\n求更新后的R1路由表。","analyze":"RIP路由更新规则：\\n1. 收到相同下一跳的更新，无条件接受\\n2. 若新路由距离更短，则更新\\n3. 若是新网络，添加到路由表，距离+1\\n\\n更新过程：\\n- 20.0.0.0：原来下一跳就是R2，更新距离为2+1=3\\n- 30.0.0.0：原来距离5，R2的距离3+1=4<5，更新下一跳为R2，距离4\\n- 40.0.0.0：新网络，添加，下一跳R2，距离4+1=5","questionItemObjects":[],"correct":"更新后路由表：\\n10.0.0.0 → 直连(0)\\n20.0.0.0 → R2(3)\\n30.0.0.0 → R2(4)\\n40.0.0.0 → R2(5)"}', NOW());

-- ----------------------------
-- 3. 插入题目记录（t_question）
-- 每门课每个年级包含 2 道单选题（题型1）和 2 道简答题（题型5）
-- 期末考：单选题20分，简答题20分
-- 考研/复试：单选题3分，简答题8分
-- ----------------------------

-- 数据结构（期末考 subject_id=100）
INSERT INTO `t_question` (`id`, `question_type`, `subject_id`, `score`, `grade_level`, `difficult`, `correct`, `info_text_content_id`, `create_user`, `status`, `create_time`, `deleted`) VALUES
(1001, 1, 100, 20, 1, 3, 'D', 1001, 2, 1, NOW(), b'0'),
(1002, 1, 100, 20, 1, 3, 'A', 1002, 2, 1, NOW(), b'0'),
(1003, 5, 100, 20, 1, 4, '双指针遍历', 1003, 2, 1, NOW(), b'0'),
(1004, 5, 100, 20, 1, 4, 'DGEBHFCA', 1004, 2, 1, NOW(), b'0');

-- 数据结构（考研 subject_id=101）
INSERT INTO `t_question` (`id`, `question_type`, `subject_id`, `score`, `grade_level`, `difficult`, `correct`, `info_text_content_id`, `create_user`, `status`, `create_time`, `deleted`) VALUES
(1011, 1, 101, 20, 2, 3, 'D', 1001, 2, 1, NOW(), b'0'),
(1012, 1, 101, 20, 2, 3, 'A', 1002, 2, 1, NOW(), b'0'),
(1013, 5, 101, 20, 2, 5, '双指针遍历', 1003, 2, 1, NOW(), b'0'),
(1014, 5, 101, 20, 2, 5, 'DGEBHFCA', 1004, 2, 1, NOW(), b'0');

-- 数据结构（复试 subject_id=102）
INSERT INTO `t_question` (`id`, `question_type`, `subject_id`, `score`, `grade_level`, `difficult`, `correct`, `info_text_content_id`, `create_user`, `status`, `create_time`, `deleted`) VALUES
(1021, 1, 102, 20, 3, 3, 'D', 1001, 2, 1, NOW(), b'0'),
(1022, 1, 102, 20, 3, 3, 'A', 1002, 2, 1, NOW(), b'0'),
(1023, 5, 102, 20, 3, 5, '双指针遍历', 1003, 2, 1, NOW(), b'0'),
(1024, 5, 102, 20, 3, 5, 'DGEBHFCA', 1004, 2, 1, NOW(), b'0');

-- 计算机组成原理（期末考 subject_id=103）
INSERT INTO `t_question` (`id`, `question_type`, `subject_id`, `score`, `grade_level`, `difficult`, `correct`, `info_text_content_id`, `create_user`, `status`, `create_time`, `deleted`) VALUES
(1031, 1, 103, 20, 1, 3, 'C', 1005, 2, 1, NOW(), b'0'),
(1032, 1, 103, 20, 1, 4, 'A', 1006, 2, 1, NOW(), b'0'),
(1033, 5, 103, 20, 1, 4, '2^11×0.10001101', 1007, 2, 1, NOW(), b'0'),
(1034, 5, 103, 20, 1, 4, '2048芯片,28位地址', 1008, 2, 1, NOW(), b'0');

-- 计算机组成原理（考研 subject_id=104）
INSERT INTO `t_question` (`id`, `question_type`, `subject_id`, `score`, `grade_level`, `difficult`, `correct`, `info_text_content_id`, `create_user`, `status`, `create_time`, `deleted`) VALUES
(1041, 1, 104, 20, 2, 3, 'C', 1005, 2, 1, NOW(), b'0'),
(1042, 1, 104, 20, 2, 4, 'A', 1006, 2, 1, NOW(), b'0'),
(1043, 5, 104, 20, 2, 5, '2^11×0.10001101', 1007, 2, 1, NOW(), b'0'),
(1044, 5, 104, 20, 2, 5, '2048芯片,28位地址', 1008, 2, 1, NOW(), b'0');

-- 计算机组成原理（复试 subject_id=105）
INSERT INTO `t_question` (`id`, `question_type`, `subject_id`, `score`, `grade_level`, `difficult`, `correct`, `info_text_content_id`, `create_user`, `status`, `create_time`, `deleted`) VALUES
(1051, 1, 105, 20, 3, 3, 'C', 1005, 2, 1, NOW(), b'0'),
(1052, 1, 105, 20, 3, 4, 'A', 1006, 2, 1, NOW(), b'0'),
(1053, 5, 105, 20, 3, 5, '2^11×0.10001101', 1007, 2, 1, NOW(), b'0'),
(1054, 5, 105, 20, 3, 5, '2048芯片,28位地址', 1008, 2, 1, NOW(), b'0');

-- 操作系统（期末考 subject_id=106）
INSERT INTO `t_question` (`id`, `question_type`, `subject_id`, `score`, `grade_level`, `difficult`, `correct`, `info_text_content_id`, `create_user`, `status`, `create_time`, `deleted`) VALUES
(1061, 1, 106, 20, 1, 3, 'B', 1009, 2, 1, NOW(), b'0'),
(1062, 1, 106, 20, 1, 3, 'B', 1010, 2, 1, NOW(), b'0'),
(1063, 5, 106, 20, 1, 4, 'PV操作同步互斥', 1011, 2, 1, NOW(), b'0'),
(1064, 5, 106, 20, 1, 4, '16GB+64MB+266KB', 1012, 2, 1, NOW(), b'0');

-- 操作系统（考研 subject_id=107）
INSERT INTO `t_question` (`id`, `question_type`, `subject_id`, `score`, `grade_level`, `difficult`, `correct`, `info_text_content_id`, `create_user`, `status`, `create_time`, `deleted`) VALUES
(1071, 1, 107, 20, 2, 3, 'B', 1009, 2, 1, NOW(), b'0'),
(1072, 1, 107, 20, 2, 3, 'B', 1010, 2, 1, NOW(), b'0'),
(1073, 5, 107, 20, 2, 5, 'PV操作同步互斥', 1011, 2, 1, NOW(), b'0'),
(1074, 5, 107, 20, 2, 5, '16GB+64MB+266KB', 1012, 2, 1, NOW(), b'0');

-- 操作系统（复试 subject_id=108）
INSERT INTO `t_question` (`id`, `question_type`, `subject_id`, `score`, `grade_level`, `difficult`, `correct`, `info_text_content_id`, `create_user`, `status`, `create_time`, `deleted`) VALUES
(1081, 1, 108, 20, 3, 3, 'B', 1009, 2, 1, NOW(), b'0'),
(1082, 1, 108, 20, 3, 3, 'B', 1010, 2, 1, NOW(), b'0'),
(1083, 5, 108, 20, 3, 5, 'PV操作同步互斥', 1011, 2, 1, NOW(), b'0'),
(1084, 5, 108, 20, 3, 5, '16GB+64MB+266KB', 1012, 2, 1, NOW(), b'0');

-- 计算机网络（期末考 subject_id=109）
INSERT INTO `t_question` (`id`, `question_type`, `subject_id`, `score`, `grade_level`, `difficult`, `correct`, `info_text_content_id`, `create_user`, `status`, `create_time`, `deleted`) VALUES
(1091, 1, 109, 20, 1, 3, 'A', 1013, 2, 1, NOW(), b'0'),
(1092, 1, 109, 20, 1, 3, 'B', 1014, 2, 1, NOW(), b'0'),
(1093, 5, 109, 20, 1, 4, '400B,200B', 1015, 2, 1, NOW(), b'0'),
(1094, 5, 109, 20, 1, 4, 'RIP路由更新', 1016, 2, 1, NOW(), b'0');

-- 计算机网络（考研 subject_id=110）
INSERT INTO `t_question` (`id`, `question_type`, `subject_id`, `score`, `grade_level`, `difficult`, `correct`, `info_text_content_id`, `create_user`, `status`, `create_time`, `deleted`) VALUES
(1101, 1, 110, 20, 2, 3, 'A', 1013, 2, 1, NOW(), b'0'),
(1102, 1, 110, 20, 2, 3, 'B', 1014, 2, 1, NOW(), b'0'),
(1103, 5, 110, 20, 2, 5, '400B,200B', 1015, 2, 1, NOW(), b'0'),
(1104, 5, 110, 20, 2, 5, 'RIP路由更新', 1016, 2, 1, NOW(), b'0');

-- 计算机网络（复试 subject_id=111）
INSERT INTO `t_question` (`id`, `question_type`, `subject_id`, `score`, `grade_level`, `difficult`, `correct`, `info_text_content_id`, `create_user`, `status`, `create_time`, `deleted`) VALUES
(1111, 1, 111, 20, 3, 3, 'A', 1013, 2, 1, NOW(), b'0'),
(1112, 1, 111, 20, 3, 3, 'B', 1014, 2, 1, NOW(), b'0'),
(1113, 5, 111, 20, 3, 5, '400B,200B', 1015, 2, 1, NOW(), b'0'),
(1114, 5, 111, 20, 3, 5, 'RIP路由更新', 1016, 2, 1, NOW(), b'0');

-- ----------------------------
-- 执行完成
-- 共插入：
-- - 12 条学科记录（4门课 × 3个年级）
-- - 16 条题目内容记录（t_text_content）
-- - 48 条题目记录（t_question，每门课每个年级4题）
-- ----------------------------
SET FOREIGN_KEY_CHECKS = 1;