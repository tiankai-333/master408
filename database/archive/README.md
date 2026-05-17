# database/archive

历史 SQL 归档目录。这里的脚本不属于当前默认部署链路。

## 子目录

| 目录 | 说明 |
|---|---|
| `legacy-knowledge/` | 早期知识体系实验脚本，表名和当前代码主线不同。 |
| `backups/` | 历史数据库备份。 |

当前代码主线使用：

- `knowledge_point`
- `question_knowledge_point`
- `t_ai_knowledge_base`
- `t_user_learning_profile`
- `t_user_learning_event`
- `t_user_skill_feedback`

如果要查历史设计，可以阅读这里；如果要部署，请使用 `database/current/`。
