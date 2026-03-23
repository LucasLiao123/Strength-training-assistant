# 力量训练智能 APP MVP

本项目包含两个子模块：

- `frontend/`：Flutter 移动端，覆盖动作库、智能计划、语音交互、训练报告
- `backend/`：FastAPI 后端，覆盖动作库 CRUD、计划生成/调整算法、语音指令解析

## 设计说明

- UI/交互方向：参考你提供的附件应用，采用深色运动风、顶部渐变头图、卡片化内容区、大按钮语音入口和弹窗式内容编辑。
- 业务边界：代码中明确不包含任何教练端功能，例如教练入驻、派单、一对一指导、教练后台管理。
- MVP 定位：优先保证新手可运行、结构清晰、方便后续扩展，而不是一次性引入复杂依赖。

## 目录结构

```text
strength/
├─ frontend/
│  ├─ lib/
│  │  ├─ models/
│  │  ├─ providers/
│  │  ├─ screens/
│  │  ├─ services/
│  │  ├─ theme/
│  │  └─ widgets/
│  └─ pubspec.yaml
├─ backend/
│  ├─ app/
│  │  ├─ main.py
│  │  ├─ models.py
│  │  ├─ planner.py
│  │  ├─ voice_parser.py
│  │  └─ exercise_seed.py
│  └─ requirements.txt
└─ README.md
```

## 后端启动

```bash
cd backend
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```

后端默认地址：`http://127.0.0.1:8000`

可访问：

- `GET /health`
- `GET /docs`
- `GET /exercises`
- `POST /plans/generate`
- `POST /plans/adjust`
- `POST /voice/parse`

## 前端启动

确保本机已安装 Flutter SDK。

```bash
cd frontend
flutter pub get
flutter run
```

## 已实现模块

### 1. 动作库管理

- 本地 SQLite 持久化
- 50+ 预设力量训练动作
- 搜索、筛选、添加、编辑、删除
- 预留导出/导入备份的服务层接口

### 2. 智能计划

- 收集目标、水平、每周天数、单次时长、禁忌部位
- 后端生成遵守“不连续训练同部位、复合动作优先、难度匹配”的计划
- 根据训练反馈执行渐进超负荷或降强度调整

### 3. 语音交互

- Flutter 端语音识别 + TTS 播报
- Python 端语音指令意图解析
- 支持动作库、计划、记录、查询四类基础指令

### 4. 周报告

- 完成率概览
- 部位覆盖柱状图
- 智能推荐卡片

## 可扩展点

- Firebase 云同步
- 更完整的训练日志与动作视频资源
- 更细粒度的 AI 问答与动作姿势纠错
- 更丰富的数据看板和社交分享
