/*
 * ============================================
 * 添加2024年408真题到数据库
 * ============================================
 * 执行此脚本可添加2024年考研计算机学科专业基础综合真题
 * 
 * 使用方法：
 * mysql -u root -p123456 -D xzs < add_2024_exam.sql
 * ============================================
 */

USE xzs;

-- ----------------------------
-- 1. 添加2024年真题内容（t_text_content）
-- ----------------------------

-- 2024年真题 - 数据结构单选题1
INSERT INTO `t_text_content` (`id`, `content`, `create_time`) VALUES
(2001, '{"titleContent":"下列关于栈和队列的叙述中，正确的是（）","analyze":"A选项：栈和队列都是线性结构，但栈是后进先出（LIFO），队列是先进先出（FIFO）。B选项：循环队列可以用数组实现，但也可以用链表实现。C选项：栈可以用顺序存储也可以用链式存储。D选项：利用两个栈可以模拟队列的操作（一个栈负责入队，一个栈负责出队）。","questionItemObjects":[{"prefix":"A","content":"栈和队列都只能在端点处插入和删除元素","itemUuid":"2024ds001-001"},{"prefix":"B","content":"循环队列是队列的一种链式存储结构","itemUuid":"2024ds001-002"},{"prefix":"C","content":"栈只能采用顺序存储结构","itemUuid":"2024ds001-003"},{"prefix":"D","content":"利用两个栈可以模拟一个队列的操作","itemUuid":"2024ds001-004"}]}', NOW()),

-- 2024年真题 - 数据结构单选题2
(2002, '{"titleContent":"某二叉树的前序遍历序列为ABCDEFG，中序遍历序列为BDCAFEG，则该二叉树的后序遍历序列为（）","analyze":"根据前序和中序遍历还原二叉树：前序第一个节点A是根，中序中A左边BDC是左子树，右边FEG是右子树。左子树前序为BCD，根为B，中序中B左边为空，右边DC是右子树。继续还原可得后序遍历为DCBFE GA。","questionItemObjects":[{"prefix":"A","content":"DCBFEAG","itemUuid":"2024ds002-001"},{"prefix":"B","content":"DCBFEGA","itemUuid":"2024ds002-002"},{"prefix":"C","content":"BDCAFEG","itemUuid":"2024ds002-003"},{"prefix":"D","content":"BDCAGEF","itemUuid":"2024ds002-004"}]}', NOW()),

-- 2024年真题 - 数据结构单选题3
(2003, '{"titleContent":"在一棵具有n个结点的二叉链表中，空指针域的个数是（）","analyze":"在二叉链表中，每个结点有两个指针域（左孩子和右孩子），总共有2n个指针域。除了根结点外，每个结点都有一个指针指向它，共有n-1个非空指针域。因此空指针域的个数 = 2n - (n-1) = n+1。","questionItemObjects":[{"prefix":"A","content":"n","itemUuid":"2024ds003-001"},{"prefix":"B","content":"n+1","itemUuid":"2024ds003-002"},{"prefix":"C","content":"n-1","itemUuid":"2024ds003-003"},{"prefix":"D","content":"2n","itemUuid":"2024ds003-004"}]}', NOW()),

-- 2024年真题 - 计算机组成原理单选题1
(2004, '{"titleContent":"某计算机字长为32位，按字节编址，采用小端方式。若主存地址为1000H处存放的32位字为12345678H，则在地址1000H、1001H、1002H、1003H处存放的字节分别是（）","analyze":"小端方式下，低位字节存放在低地址，高位字节存放在高地址。32位字12345678H中，78H是最低位字节，56H次之，34H再次之，12H是最高位字节。因此地址1000H存78H，1001H存56H，1002H存34H，1003H存12H。","questionItemObjects":[{"prefix":"A","content":"12H,34H,56H,78H","itemUuid":"2024co001-001"},{"prefix":"B","content":"78H,56H,34H,12H","itemUuid":"2024co001-002"},{"prefix":"C","content":"34H,12H,78H,56H","itemUuid":"2024co001-003"},{"prefix":"D","content":"56H,78H,12H,34H","itemUuid":"2024co001-004"}]}', NOW()),

-- 2024年真题 - 计算机组成原理单选题2
(2005, '{"titleContent":"某CPU的指令系统中，指令字长固定为16位，操作码占4位，地址码占12位。若采用扩展操作码技术，二地址指令有12条，则一地址指令最多有（）条。","analyze":"操作码占4位，最多可表示16条指令。二地址指令用了12条，剩余4个编码用于扩展。每个扩展编码可扩展出2^12=4096条一地址指令，因此最多有4×4096=16384条。","questionItemObjects":[{"prefix":"A","content":"12","itemUuid":"2024co002-001"},{"prefix":"B","content":"4096","itemUuid":"2024co002-002"},{"prefix":"C","content":"16384","itemUuid":"2024co002-003"},{"prefix":"D","content":"65536","itemUuid":"2024co002-004"}]}', NOW()),

-- 2024年真题 - 操作系统单选题1
(2006, '{"titleContent":"下列关于进程和线程的叙述中，正确的是（）","analyze":"A选项：线程是CPU调度的基本单位，进程是资源分配的基本单位。B选项：同一进程内的线程共享进程的资源，但有各自独立的栈和寄存器。C选项：进程切换的开销远大于线程切换。D选项：线程之间可以共享进程的代码段和数据段。","questionItemObjects":[{"prefix":"A","content":"进程是CPU调度的基本单位","itemUuid":"2024os001-001"},{"prefix":"B","content":"线程是资源分配的基本单位","itemUuid":"2024os001-002"},{"prefix":"C","content":"进程切换的开销比线程切换小","itemUuid":"2024os001-003"},{"prefix":"D","content":"同一进程内的线程共享进程的资源","itemUuid":"2024os001-004"}]}', NOW()),

-- 2024年真题 - 操作系统单选题2
(2007, '{"titleContent":"采用银行家算法避免死锁时，需要检查系统是否处于安全状态。若系统处于安全状态，则（）","analyze":"安全状态是指系统能按某种顺序为每个进程分配资源，使每个进程都能顺利完成。处于安全状态的系统一定不会发生死锁，但安全状态并不意味着所有进程都能立即获得所需资源，而是存在一种分配顺序可以避免死锁。","questionItemObjects":[{"prefix":"A","content":"一定不会发生死锁","itemUuid":"2024os002-001"},{"prefix":"B","content":"一定会发生死锁","itemUuid":"2024os002-002"},{"prefix":"C","content":"可能发生死锁","itemUuid":"2024os002-003"},{"prefix":"D","content":"无法判断是否会发生死锁","itemUuid":"2024os002-004"}]}', NOW()),

-- 2024年真题 - 计算机网络单选题1
(2008, '{"titleContent":"TCP三次握手过程中，第二次握手时服务器发送的报文段中，SYN和ACK标志位分别为（）","analyze":"TCP三次握手：第一次握手（客户端→服务器）：SYN=1；第二次握手（服务器→客户端）：SYN=1, ACK=1；第三次握手（客户端→服务器）：ACK=1。","questionItemObjects":[{"prefix":"A","content":"SYN=0, ACK=0","itemUuid":"2024net001-001"},{"prefix":"B","content":"SYN=0, ACK=1","itemUuid":"2024net001-002"},{"prefix":"C","content":"SYN=1, ACK=0","itemUuid":"2024net001-003"},{"prefix":"D","content":"SYN=1, ACK=1","itemUuid":"2024net001-004"}]}', NOW()),

-- 2024年真题 - 计算机网络单选题2
(2009, '{"titleContent":"某网络的IP地址为192.168.1.0/24，要划分为4个子网，每个子网最少30台主机，则子网掩码应为（）","analyze":"每个子网需要30台主机，主机位至少需要5位（2^5-2=30）。网络位=32-5=27位，子网掩码为255.255.255.224。","questionItemObjects":[{"prefix":"A","content":"255.255.255.128","itemUuid":"2024net002-001"},{"prefix":"B","content":"255.255.255.192","itemUuid":"2024net002-002"},{"prefix":"C","content":"255.255.255.224","itemUuid":"2024net002-003"},{"prefix":"D","content":"255.255.255.240","itemUuid":"2024net002-004"}]}', NOW()),

-- 2024年真题 - 数据结构综合题
(2010, '{"titleContent":"已知一个整数序列A=(a1,a2,...,an)，其中n≥2。请设计一个时间复杂度为O(n)、空间复杂度为O(1)的算法，找出序列中第一个出现的重复元素。要求：\\n1. 描述算法的基本思想；\\n2. 写出算法的伪代码；\\n3. 分析算法的时间复杂度和空间复杂度。","analyze":"利用数组下标作为哈希表，将每个元素放到其值对应的下标位置上。遍历数组，对于元素a[i]，如果a[a[i]-1] == a[i]，说明a[i]是重复元素；否则交换a[i]和a[a[i]-1]，继续检查。","questionItemObjects":[],"correct":"1. 基本思想：利用数组本身作为哈希表，将元素放到其值对应的下标位置。\\n2. 伪代码：\\nfor i from 0 to n-1:\\n    while A[i] != i+1:\\n        if A[A[i]-1] == A[i]:\\n            return A[i]\\n        swap(A[i], A[A[i]-1])\\n3. 时间复杂度O(n)，空间复杂度O(1)"}', NOW()),

-- 2024年真题 - 计算机组成原理综合题
(2011, '{"titleContent":"某计算机主存容量为1MB，按字节编址，cache容量为16KB，块大小为64B，采用直接映射方式。\\n1. 计算主存地址的各字段位数；\\n2. 若主存地址为25301H，计算其对应的cache块号和块内地址。","analyze":"1. 主存容量1MB=2^20，地址共20位。块大小64B=2^6，块内地址6位。cache容量16KB/64B=256=2^8块，cache块号8位。主存标记=20-8-6=6位。\\n2. 25301H=0010 0101 0011 0000 0001B，cache块号=中间8位=01010011B=53H，块内地址=低6位=000001B=1。","questionItemObjects":[],"correct":"1. 主存标记6位，cache块号8位，块内地址6位。\\n2. cache块号为53H，块内地址为1。"}', NOW());

-- ----------------------------
-- 2. 添加题目记录（t_question）
-- ----------------------------

-- 2024年真题 - 数据结构（考研级别）
INSERT INTO `t_question` (`id`, `question_type`, `subject_id`, `score`, `grade_level`, `difficult`, `correct`, `info_text_content_id`, `create_user`, `status`, `create_time`, `deleted`) VALUES
(2001, 1, 101, 2, 2, 3, 'D', 2001, 1, 1, NOW(), b'0'),
(2002, 1, 101, 2, 2, 4, 'B', 2002, 1, 1, NOW(), b'0'),
(2003, 1, 101, 2, 2, 3, 'B', 2003, 1, 1, NOW(), b'0'),
(2010, 5, 101, 13, 2, 4, '哈希表法', 2010, 1, 1, NOW(), b'0');

-- 2024年真题 - 计算机组成原理（考研级别）
INSERT INTO `t_question` (`id`, `question_type`, `subject_id`, `score`, `grade_level`, `difficult`, `correct`, `info_text_content_id`, `create_user`, `status`, `create_time`, `deleted`) VALUES
(2004, 1, 104, 2, 2, 3, 'B', 2004, 1, 1, NOW(), b'0'),
(2005, 1, 104, 2, 2, 4, 'C', 2005, 1, 1, NOW(), b'0'),
(2011, 5, 104, 13, 2, 4, '标记6位，块号8位，块内6位', 2011, 1, 1, NOW(), b'0');

-- 2024年真题 - 操作系统（考研级别）
INSERT INTO `t_question` (`id`, `question_type`, `subject_id`, `score`, `grade_level`, `difficult`, `correct`, `info_text_content_id`, `create_user`, `status`, `create_time`, `deleted`) VALUES
(2006, 1, 107, 2, 2, 3, 'D', 2006, 1, 1, NOW(), b'0'),
(2007, 1, 107, 2, 2, 3, 'A', 2007, 1, 1, NOW(), b'0');

-- 2024年真题 - 计算机网络（考研级别）
INSERT INTO `t_question` (`id`, `question_type`, `subject_id`, `score`, `grade_level`, `difficult`, `correct`, `info_text_content_id`, `create_user`, `status`, `create_time`, `deleted`) VALUES
(2008, 1, 110, 2, 2, 3, 'D', 2008, 1, 1, NOW(), b'0'),
(2009, 1, 110, 2, 2, 3, 'C', 2009, 1, 1, NOW(), b'0');

-- 执行完成提示
SELECT '2024年408真题添加完成！' AS result;
SELECT COUNT(*) AS added_questions FROM t_question WHERE id BETWEEN 2001 AND 2011;
SELECT COUNT(*) AS added_text_content FROM t_text_content WHERE id BETWEEN 2001 AND 2011;
