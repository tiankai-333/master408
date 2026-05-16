package com.mindskip.xzs.controller.test;

import com.mindskip.xzs.base.RestResponse;
import com.mindskip.xzs.domain.User;
import com.mindskip.xzs.service.UserService;
import com.mindskip.xzs.utility.RsaUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping(value = "/api/test")
public class TestController {

    private final UserService userService;
    private final JdbcTemplate jdbcTemplate;
    private final BCryptPasswordEncoder passwordEncoder;

    @Value("${system.pwdKey.privateKey}")
    private String privateKey;

    @Autowired
    public TestController(UserService userService, JdbcTemplate jdbcTemplate) {
        this.userService = userService;
        this.jdbcTemplate = jdbcTemplate;
        this.passwordEncoder = new BCryptPasswordEncoder();
    }

    @GetMapping("/resetPwd")
    public RestResponse<String> resetPwd(@RequestParam String userName, @RequestParam String password) {
        User user = userService.getUserByUserName(userName);
        if (user == null) {
            return new RestResponse<>(1, "用户不存在");
        }
        user.setPassword(passwordEncoder.encode(password));
        userService.updateByIdFilter(user);
        return RestResponse.ok("密码已重置为: " + password);
    }

    @GetMapping("/decryptRsa")
    public RestResponse<String> decryptRsa(@RequestParam String encrypted) {
        String decrypted = RsaUtil.rsaDecode(privateKey, encrypted);
        if (decrypted == null) {
            return new RestResponse<>(2, "解密失败");
        }
        return RestResponse.ok("解密结果: " + decrypted);
    }

    @GetMapping("/encryptRsa")
    public RestResponse<String> encryptRsa(@RequestParam String password, @RequestParam String publicKey) {
        String encrypted = RsaUtil.rsaEncode(publicKey, password);
        if (encrypted == null) {
            return new RestResponse<>(3, "加密失败");
        }
        return RestResponse.ok("加密结果: " + encrypted);
    }

    @GetMapping("/reset-role")
    public RestResponse<String> resetRole(@RequestParam String userName, @RequestParam Integer role) {
        User user = userService.getUserByUserName(userName);
        if (user == null) {
            return new RestResponse<>(1, "用户不存在");
        }
        user.setRole(role);
        userService.updateByIdFilter(user);
        return RestResponse.ok("角色已修改为: " + role);
    }

    @GetMapping("/check-subjects")
    public RestResponse<List<Map<String, Object>>> checkSubjects() {
        try {
            List<Map<String, Object>> subjects = jdbcTemplate.queryForList("SELECT id, name, level, level_name FROM t_subject WHERE deleted=0 ORDER BY id");
            return RestResponse.ok(subjects);
        } catch (Exception e) {
            return new RestResponse<>(5, "查询失败: " + e.getMessage());
        }
    }

    @GetMapping("/fix-subjects")
    public RestResponse<String> fixSubjects() {
        try {
            // 删除旧的学科数据
            jdbcTemplate.update("DELETE FROM t_subject WHERE id BETWEEN 100 AND 111");
            
            // 重新插入正确的学科数据
            jdbcTemplate.update("INSERT INTO `t_subject` (`id`, `name`, `level`, `level_name`, `item_order`, `deleted`) VALUES " +
                "(100, '数据结构', 1, '期末考', 1, b'0'), " +
                "(101, '数据结构', 2, '考研', 2, b'0'), " +
                "(102, '数据结构', 3, '复试', 3, b'0'), " +
                "(103, '计算机组成原理', 1, '期末考', 4, b'0'), " +
                "(104, '计算机组成原理', 2, '考研', 5, b'0'), " +
                "(105, '计算机组成原理', 3, '复试', 6, b'0'), " +
                "(106, '操作系统', 1, '期末考', 7, b'0'), " +
                "(107, '操作系统', 2, '考研', 8, b'0'), " +
                "(108, '操作系统', 3, '复试', 9, b'0'), " +
                "(109, '计算机网络', 1, '期末考', 10, b'0'), " +
                "(110, '计算机网络', 2, '考研', 11, b'0'), " +
                "(111, '计算机网络', 3, '复试', 12, b'0')");
            
            return RestResponse.ok("学科数据修复成功！");
        } catch (Exception e) {
            return new RestResponse<>(5, "修复失败: " + e.getMessage());
        }
    }
}
