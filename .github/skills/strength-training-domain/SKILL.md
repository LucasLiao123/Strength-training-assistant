---
name: strength-training-domain
description: "Domain knowledge skill for the strength training app. USE WHEN: implementing training plan logic, exercise library features, voice command parsing, or dynamic plan adjustment. Contains the business rules for progressive overload, fatigue-based deload, injury substitution, and training split patterns."
---

# Strength Training Domain Skill

## Business Context

This app is a personal strength training manager. There is **no coach-side functionality** — no coach profiles, matchmaking, sessions, or messaging. All features serve a single end user managing their own training.

## Exercise Library Rules

- 50+ preset exercises across 6 muscle groups: 胸/背/肩/腿/手臂/核心
- Each exercise has: name, muscle group, type (复合/孤立), difficulty (新手/中级/高级), default sets/reps, weight range, description
- Users can add/edit/delete custom exercises
- Preset exercises should not be deletable by default

## Plan Generation Rules

### Split Patterns by Days/Week
| Days | Pattern |
|------|---------|
| 2 | 上肢 / 下肢 |
| 3 | 推 / 拉 / 腿 |
| 4 | 胸+三头 / 背+二头 / 腿 / 肩+核心 |
| 5 | 胸 / 背 / 腿 / 肩 / 手臂+核心 |
| 6 | 胸 / 背 / 腿 / 肩 / 手臂 / 核心 |

### Exercise Selection Priority
1. Compound movements first
2. Difficulty must not exceed user level
3. Skip muscles in user's avoid list
4. Target 3-5 exercises per session based on time budget

### Rep Ranges by Goal
| Goal | Reps |
|------|------|
| 力量 | 4-6 |
| 增肌 | 8-12 |
| 减脂 | 12-15 |

## Dynamic Adjustment Rules

### Progressive Overload (completion ≥ 8 AND fatigue ≤ 5)
- Increase weight by 5-10%
- Optionally add 1 set

### Deload (completion ≤ 5 OR fatigue ≥ 8)
- Reduce weight by 10%
- Remove 1 set (minimum 2 sets)
- Consider swapping to an easier variant

### Injury Response
When notes contain injury keywords (膝盖/膝/肩/腰):
- Replace high-stress exercises with safer alternatives
- Example: 杠铃深蹲 → 相扑深蹲 (knee), 肩推 → 地雷杆推举 (shoulder), 硬拉 → 罗马尼亚硬拉 (lower back)

## Voice Command Intents

| Intent | Trigger Examples |
|--------|-----------------|
| exercise_library | "添加动作 平板支撑", "删除动作 侧平举", "查找胸肌的复合动作" |
| plan | "生成本周训练计划", "调整周一的练腿动作" |
| record | "记录今天深蹲完成4组12次，重量60kg" |
| query | "我的近2周训练完成率", "推荐新手练肩的动作" |

## Weekly Report Metrics

- Completion rate = actual sessions / planned sessions
- Muscle coverage = count of exercises per muscle group
- Average completion score and fatigue score
- Strength progress = weight trends per exercise
