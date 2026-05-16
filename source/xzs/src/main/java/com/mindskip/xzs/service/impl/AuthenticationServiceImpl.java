package com.mindskip.xzs.service.impl;

import com.mindskip.xzs.domain.User;
import com.mindskip.xzs.service.AuthenticationService;
import com.mindskip.xzs.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class AuthenticationServiceImpl implements AuthenticationService {

    private final UserService userService;
    private final BCryptPasswordEncoder passwordEncoder;

    @Autowired
    public AuthenticationServiceImpl(UserService userService) {
        this.userService = userService;
        this.passwordEncoder = new BCryptPasswordEncoder();
    }

    @Override
    public boolean authUser(String username, String password) {
        User user = userService.getUserByUserName(username);
        return authUser(user, username, password);
    }

    @Override
    public boolean authUser(User user, String username, String password) {
        if (user == null) {
            return false;
        }
        String encodePwd = user.getPassword();
        if (null == encodePwd || encodePwd.length() == 0) {
            return false;
        }
        return passwordEncoder.matches(password, encodePwd);
    }

    @Override
    public String pwdEncode(String password) {
        return passwordEncoder.encode(password);
    }

    @Override
    public String pwdDecode(String encodePwd) {
        return null;
    }

}
