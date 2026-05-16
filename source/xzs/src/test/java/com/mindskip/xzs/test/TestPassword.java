import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

public class TestPassword {
    public static void main(String[] args) {
        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
        
        // 数据库中的密码
        String hashedPassword = "$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH";
        
        // 测试几个常见密码
        String[] passwords = {"123456", "student", "123", "admin", "password"};
        
        for (String pwd : passwords) {
            boolean matches = encoder.matches(pwd, hashedPassword);
            System.out.println("密码 '" + pwd + "' 匹配: " + matches);
        }
    }
}
