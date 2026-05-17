# source/wx

微信小程序源码目录。

当前包含一个学生端原生小程序：

```text
source/wx/xzs-student
```

## 已有能力

- 微信登录绑定到系统账号。
- 首页。
- 试卷列表。
- 做题页。
- 做题记录。
- 我的、个人信息、消息。

当前小程序先用于跑通传统刷题流程，AI/RAG/Skill 亮点主要仍在 Web 学生端。

## 本地运行

1. 启动后端：

```bash
cd source/xzs
mvn package -DskipTests
java -jar target/xzs-3.9.0.jar
```

2. 用微信开发者工具导入：

```text
source/wx/xzs-student
```

3. 开发者工具中勾选：

```text
不校验合法域名、TLS 版本及 HTTPS 证书
```

4. 使用账号：

```text
student / 123456
```

## 配置项

| 文件 | 说明 |
|---|---|
| `xzs-student/app.js` | `globalData.baseAPI` 配置后端接口地址。 |
| `xzs-student/project.config.json` | 小程序项目配置和 `appid`。 |
| 后端 `application.yml` | `system.wx.appid`、`system.wx.secret`。 |

## 开发模式说明

当前后端在 `system.wx.secret` 为空时，会使用开发模式绑定账号，方便本地跑通：

```text
用户名 + 密码 -> 开发 openId -> token
```

正式上线必须配置真实微信小程序的 AppID 和 AppSecret。

## 上线前检查

1. `app.js` 中 `baseAPI` 改为 HTTPS 域名。
2. 微信公众平台配置 `request 合法域名`。
3. 后端配置真实 `system.wx.appid` 和 `system.wx.secret`。
4. 小程序后台完成备案、类目、隐私协议等审核要求。
