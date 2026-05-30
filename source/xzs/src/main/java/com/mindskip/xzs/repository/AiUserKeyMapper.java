package com.mindskip.xzs.repository;

import com.mindskip.xzs.domain.ai.AiUserKey;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface AiUserKeyMapper {

    List<AiUserKey> selectByUserId(@Param("userId") Integer userId);

    AiUserKey selectById(@Param("id") Integer id);

    void insert(AiUserKey config);

    void update(AiUserKey config);

    void deleteById(@Param("id") Integer id);

    void updateTestResult(@Param("id") Integer id, @Param("success") Boolean success, @Param("message") String message);
}
