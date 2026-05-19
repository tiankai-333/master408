package com.mindskip.xzs.viewmodel.student.user;


import javax.validation.constraints.NotBlank;

public class UserRegisterVM {

    private static final int DEFAULT_USER_LEVEL = 1;

    @NotBlank
    private String userName;

    @NotBlank
    private String password;

    private Integer userLevel;

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public Integer getUserLevel() {
        return userLevel == null ? DEFAULT_USER_LEVEL : userLevel;
    }

    public void setUserLevel(Integer userLevel) {
        this.userLevel = userLevel;
    }
}
