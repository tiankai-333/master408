package com.mindskip.xzs.test;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

public class DatabaseConnectionTest {
    public static void main(String[] args) {
        String url = "jdbc:mysql://localhost:3306/xzs?useSSL=false&useUnicode=true&serverTimezone=Asia/Shanghai&characterEncoding=utf8&zeroDateTimeBehavior=convertToNull&allowPublicKeyRetrieval=true&allowMultiQueries=true";
        String username = "root";
        String password = "wutiankai";
        
        try {
            // 加载驱动
            Class.forName("com.mysql.cj.jdbc.Driver");
            System.out.println("驱动加载成功");
            
            // 建立连接
            Connection conn = DriverManager.getConnection(url, username, password);
            System.out.println("数据库连接成功");
            
            // 执行查询
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT 1");
            if (rs.next()) {
                System.out.println("查询成功: " + rs.getInt(1));
            }
            
            // 检查数据库表
            rs = stmt.executeQuery("SHOW TABLES");
            System.out.println("数据库表:");
            while (rs.next()) {
                System.out.println("- " + rs.getString(1));
            }
            
            // 关闭连接
            rs.close();
            stmt.close();
            conn.close();
            System.out.println("连接已关闭");
            
        } catch (Exception e) {
            System.out.println("连接失败: " + e.getMessage());
            e.printStackTrace();
        }
    }
}