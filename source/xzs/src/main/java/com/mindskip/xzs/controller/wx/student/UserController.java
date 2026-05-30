package com.mindskip.xzs.controller.wx.student;

import com.mindskip.xzs.base.RestResponse;
import com.mindskip.xzs.controller.wx.BaseWXApiController;
import com.mindskip.xzs.domain.Message;
import com.mindskip.xzs.domain.MessageUser;
import com.mindskip.xzs.domain.User;
import com.mindskip.xzs.domain.UserEventLog;
import com.mindskip.xzs.domain.enums.RoleEnum;
import com.mindskip.xzs.domain.enums.UserStatusEnum;
import com.mindskip.xzs.event.UserEvent;
import com.mindskip.xzs.service.AuthenticationService;
import com.mindskip.xzs.service.MessageService;
import com.mindskip.xzs.service.UserEventLogService;
import com.mindskip.xzs.service.UserService;
import org.springframework.jdbc.core.JdbcTemplate;
import com.mindskip.xzs.utility.DateTimeUtil;
import com.mindskip.xzs.utility.PageInfoHelper;
import com.mindskip.xzs.viewmodel.student.user.*;
import com.github.pagehelper.PageInfo;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.util.*;
import java.util.stream.Collectors;


@Controller("WXStudentUserController")
@RequestMapping(value = "/api/wx/student/user")
@ResponseBody
public class UserController extends BaseWXApiController {

    private final UserService userService;
    private final UserEventLogService userEventLogService;
    private final MessageService messageService;
    private final AuthenticationService authenticationService;
    private final ApplicationEventPublisher eventPublisher;
    private final JdbcTemplate jdbcTemplate;

    @Autowired
    public UserController(UserService userService, UserEventLogService userEventLogService, MessageService messageService, AuthenticationService authenticationService, ApplicationEventPublisher eventPublisher, JdbcTemplate jdbcTemplate) {
        this.userService = userService;
        this.userEventLogService = userEventLogService;
        this.messageService = messageService;
        this.authenticationService = authenticationService;
        this.eventPublisher = eventPublisher;
        this.jdbcTemplate = jdbcTemplate;
    }

    @RequestMapping(value = "/current", method = RequestMethod.POST)
    public RestResponse<UserResponseVM> current() {
        User user = getCurrentUser();
        UserResponseVM userVm = UserResponseVM.from(user);
        userVm.setBirthDay(DateTimeUtil.dateShortFormat(user.getBirthDay()));
        return RestResponse.ok(userVm);
    }

    @RequestMapping(value = "/register", method = RequestMethod.POST)
    public RestResponse register(@Valid UserRegisterVM model) {
        User existUser = userService.getUserByUserName(model.getUserName());
        if (null != existUser) {
            return new RestResponse<>(2, "用户已存在");
        }
        User user = modelMapper.map(model, User.class);
        String encodePwd = authenticationService.pwdEncode(model.getPassword());
        user.setUserUuid(UUID.randomUUID().toString());
        user.setPassword(encodePwd);
        user.setRole(RoleEnum.STUDENT.getCode());
        user.setStatus(UserStatusEnum.Enable.getCode());
        user.setLastActiveTime(new Date());
        user.setCreateTime(new Date());
        user.setDeleted(false);
        userService.insertByFilter(user);
        UserEventLog userEventLog = new UserEventLog(user.getId(), user.getUserName(), user.getRealName(), new Date());
        userEventLog.setContent("欢迎 " + user.getUserName() + " 注册来到408Master 智能学习系统");
        eventPublisher.publishEvent(new UserEvent(userEventLog));
        return RestResponse.ok();
    }

    @RequestMapping(value = "/update", method = RequestMethod.POST)
    public RestResponse<UserResponseVM> update(@Valid UserUpdateVM model) {
        if (StringUtils.isBlank(model.getBirthDay())) {
            model.setBirthDay(null);
        }
        User user = userService.selectById(getCurrentUser().getId());
        modelMapper.map(model, user);
        user.setModifyTime(new Date());
        userService.updateByIdFilter(user);
        UserEventLog userEventLog = new UserEventLog(user.getId(), user.getUserName(), user.getRealName(), new Date());
        userEventLog.setContent(user.getUserName() + " 更新了个人资料");
        eventPublisher.publishEvent(new UserEvent(userEventLog));
        UserResponseVM userVm = UserResponseVM.from(user);
        return RestResponse.ok(userVm);
    }

    @RequestMapping(value = "/log", method = RequestMethod.POST)
    public RestResponse<List<UserEventLogVM>> log() {
        User user = getCurrentUser();
        List<UserEventLog> userEventLogs = userEventLogService.getUserEventLogByUserId(user.getId());
        List<UserEventLogVM> userEventLogVMS = userEventLogs.stream().map(d -> {
            UserEventLogVM vm = modelMapper.map(d, UserEventLogVM.class);
            vm.setCreateTime(DateTimeUtil.dateFormat(d.getCreateTime()));
            return vm;
        }).collect(Collectors.toList());
        return RestResponse.ok(userEventLogVMS);
    }

    @RequestMapping(value = "/message/page", method = RequestMethod.POST)
    public RestResponse<PageInfo<MessageResponseVM>> messagePageList(MessageRequestVM messageRequestVM) {
        messageRequestVM.setReceiveUserId(getCurrentUser().getId());
        PageInfo<MessageUser> messageUserPageInfo = messageService.studentPage(messageRequestVM);
        List<Integer> ids = messageUserPageInfo.getList().stream().map(d -> d.getMessageId()).collect(Collectors.toList());
        List<Message> messages = ids.size() != 0 ? messageService.selectMessageByIds(ids) : null;
        PageInfo<MessageResponseVM> page = PageInfoHelper.copyMap(messageUserPageInfo, e -> {
            MessageResponseVM vm = modelMapper.map(e, MessageResponseVM.class);
            messages.stream().filter(d -> e.getMessageId().equals(d.getId())).findFirst().ifPresent(message -> {
                vm.setTitle(message.getTitle());
                vm.setContent(message.getContent());
                vm.setSendUserName(message.getSendUserName());
            });
            vm.setCreateTime(DateTimeUtil.dateFormat(e.getCreateTime()));
            return vm;
        });
        return RestResponse.ok(page);
    }

    @RequestMapping(value = "/message/detail/{id}", method = RequestMethod.POST)
    public RestResponse messageDetail(@PathVariable Integer id) {
        Message message = messageService.messageDetail(id);
        return RestResponse.ok(message);
    }


    @RequestMapping(value = "/message/unreadCount", method = RequestMethod.POST)
    public RestResponse unReadCount() {
        Integer count = messageService.unReadCount(getCurrentUser().getId());
        return RestResponse.ok(count);
    }

    @RequestMapping(value = "/message/read/{id}", method = RequestMethod.POST)
    public RestResponse read(@PathVariable Integer id) {
        messageService.read(id);
        return RestResponse.ok();
    }

    @RequestMapping(value = "/stats", method = RequestMethod.POST)
    public RestResponse<Map<String, Object>> stats() {
        try {
            Integer userId = getCurrentUser().getId();
            Map<String, Object> stats = new HashMap<>();

            Map<String, Object> totalRow = jdbcTemplate.queryForMap(
                    "SELECT COUNT(*) AS total_questions, " +
                            "COALESCE(SUM(CASE WHEN do_right = TRUE THEN 1 ELSE 0 END), 0) AS correct_questions " +
                            "FROM t_exam_paper_question_customer_answer WHERE create_user = ? AND subject_id IN (1,2,3,4)",
                    userId);
            int totalQuestions = toInt(totalRow.get("total_questions"));
            int correctQuestions = toInt(totalRow.get("correct_questions"));
            stats.put("totalQuestions", totalQuestions);
            stats.put("accuracy", totalQuestions == 0 ? 0 : Math.round(correctQuestions * 100.0 / totalQuestions));
            stats.put("weakPoints", Math.max(0, totalQuestions - correctQuestions));

            List<Map<String, Object>> subjects = new ArrayList<>();
            List<Map<String, Object>> rows = jdbcTemplate.queryForList(
                    "SELECT s.id, s.name, " +
                            "COUNT(a.id) AS total_questions, " +
                            "COALESCE(SUM(CASE WHEN a.do_right = TRUE THEN 1 ELSE 0 END), 0) AS correct_questions " +
                            "FROM t_subject s " +
                            "LEFT JOIN t_exam_paper_question_customer_answer a " +
                            "  ON a.subject_id = s.id AND a.create_user = ? " +
                            "WHERE s.deleted = FALSE AND s.id <> 5 " +
                            "GROUP BY s.id, s.name, s.item_order " +
                            "ORDER BY s.item_order",
                    userId);
            for (Map<String, Object> row : rows) {
                int subjectTotal = toInt(row.get("total_questions"));
                int subjectCorrect = toInt(row.get("correct_questions"));
                Map<String, Object> subject = new HashMap<>();
                subject.put("id", row.get("id"));
                subject.put("name", row.get("name"));
                subject.put("totalQuestions", subjectTotal);
                subject.put("done", subjectTotal);
                subject.put("accuracy", subjectTotal == 0 ? 0 : Math.round(subjectCorrect * 100.0 / subjectTotal));
                subjects.add(subject);
            }
            stats.put("subjects", subjects);

            return RestResponse.ok(stats);
        } catch (Exception e) {
            return RestResponse.fail(2, "获取统计数据失败");
        }
    }

    private int toInt(Object value) {
        if (value instanceof Number) {
            return ((Number) value).intValue();
        }
        if (value == null) {
            return 0;
        }
        try {
            return Integer.parseInt(String.valueOf(value));
        } catch (NumberFormatException e) {
            return 0;
        }
    }

}
