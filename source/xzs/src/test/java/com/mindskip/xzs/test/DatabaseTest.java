package com.mindskip.xzs.test;

import com.mindskip.xzs.XzsApplication;
import com.mindskip.xzs.domain.User;
import com.mindskip.xzs.service.UserService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest(classes = XzsApplication.class)
public class DatabaseTest {

    @Autowired
    private UserService userService;

    @Test
    public void  stDatabaseConnection() {
        System.out.println("测试数据库连接...");
        
        // 测试获取用户列表
        try {
            System.out.println("尝试获取用户列表...");
            java.util.List<User> users = userService.getUsers();
            System.out.println("获取到 " + users.size() + " 个用户");
            // 测试插入用户
            System.out.println("尝试插入测试用户...");
            User user = new User();
            user.setUserName("test_user_" + System.currentTimeMillis());
            user.setPassword("123456");
            user.setRealName("测试用户");
            user.setAge(20);
            user.setUserUuid("test_uuid_" + System.currentTimeMillis());
            user.setDeleted(false);
            
            int result = userService.insertByFilter(user);
            System.out.println("插入用户结果: " + result);
            System.out.println("插入的用户ID: " + user.getId());
            
            // 测试查询刚插入的用户
            if (user.getId() != null) {
                System.out.println("尝试查询刚插入的用户...");
                User insertedUser = userService.getUserById(user.getId());
                if (insertedUser != null) {
                    System.out.println("查询到用户: " + insertedUser.getUserName());
                } else {
                    System.out.println("未查询到刚插入的用户");
                }
            }
            
        } catch (Exception e) {
            System.out.println("测试过程中出现异常: " + e.getMessage());
            e.printStackTrace();
        }
    }
}