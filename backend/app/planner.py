from __future__ import annotations

from collections import defaultdict
from copy import deepcopy
from random import Random

from .exercise_seed import EXERCISES
from .models import AdjustPlanRequest, AdjustPlanResponse, Exercise, PlanDay, PlanExercise, PlanResponse, TrainingFeedback, UserProfile

_RANDOM = Random(42)

FOCUS_PATTERNS = {
    2: ['上肢', '下肢'],
    3: ['推', '拉', '腿'],
    4: ['胸+三头', '背+二头', '腿', '肩+核心'],
    5: ['胸', '背', '腿', '肩', '手臂+核心'],
    6: ['胸', '背', '腿', '肩', '手臂', '核心'],
}

REHAB_REPLACEMENTS = {
    '膝': {'杠铃深蹲': '相扑深蹲'},
    '膝盖': {'杠铃深蹲': '相扑深蹲'},
    '肩': {'肩推': '地雷杆推举'},
    '腰': {'硬拉': '罗马尼亚硬拉'},
}

FALLBACK_EXERCISES = {
    '地雷杆推举': Exercise(id=101, name='地雷杆推举', muscle_group='肩', type='复合', difficulty='新手', default_sets=4, default_reps=10, weight_range=(10, 35), description='肩友好型推举。'),
    '罗马尼亚硬拉': Exercise(id=102, name='罗马尼亚硬拉', muscle_group='腿', type='复合', difficulty='中级', default_sets=4, default_reps=8, weight_range=(20, 100), description='髋主导拉伸腘绳肌。'),
}


def _level_score(level: str) -> int:
    return {'新手': 0, '中级': 1, '高级': 2}.get(level, 1)


def _goal_rep_range(goal: str) -> tuple[int, int]:
    if goal == '力量':
        return 4, 6
    if goal == '减脂':
        return 12, 15
    return 8, 12


# 焦点 -> 部位映射，处理"胸+三头"等复合描述
_FOCUS_MUSCLE_MAP: dict[str, set[str]] = {
    '推': {'胸', '肩', '手臂'},
    '拉': {'背', '手臂'},
    '上肢': {'胸', '背', '肩', '手臂'},
    '下肢': {'腿', '核心'},
    '胸+三头': {'胸', '手臂'},
    '背+二头': {'背', '手臂'},
    '肩+核心': {'肩', '核心'},
    '手臂+核心': {'手臂', '核心'},
}


def _match_focus(exercise: Exercise, focus: str) -> bool:
    mapped = _FOCUS_MUSCLE_MAP.get(focus)
    if mapped:
        return exercise.muscle_group in mapped
    # 单部位焦点或动作名直接匹配
    return exercise.muscle_group in focus or exercise.muscle_group == focus


def _build_day_pool(profile: UserProfile, focus: str) -> list[Exercise]:
    allowed = []
    for exercise in EXERCISES:
        if exercise.muscle_group in profile.avoid_muscles:
            continue
        if _level_score(exercise.difficulty) > _level_score(profile.level):
            continue
        if _match_focus(exercise, focus):
            allowed.append(exercise)
    return allowed


def generate_plan(profile: UserProfile) -> PlanResponse:
    focuses = FOCUS_PATTERNS.get(profile.days_per_week, FOCUS_PATTERNS[4])
    rep_min, rep_max = _goal_rep_range(profile.goal)
    exercises_per_day = max(3, min(5, profile.minutes_per_session // 18))
    days: list[PlanDay] = []

    for index, focus in enumerate(focuses, start=1):
        pool = _build_day_pool(profile, focus)
        if not pool:
            continue
        day_exercises: list[PlanExercise] = []
        selected = 0
        last_muscle = ''
        # 单焦点日（如纯"腿"）不限制连续同部位
        single_focus = focus in {'胸', '背', '肩', '腿', '手臂', '核心'}
        compound_first = sorted(pool, key=lambda item: 0 if item.type == '复合' else 1)
        for exercise in compound_first:
            if selected >= exercises_per_day:
                break
            if not single_focus and last_muscle == exercise.muscle_group and selected > 0:
                continue
            weight = exercise.weight_range[0] + (exercise.weight_range[1] - exercise.weight_range[0]) * 0.35
            reps = max(rep_min, min(rep_max, exercise.default_reps))
            day_exercises.append(
                PlanExercise(
                    exercise_id=exercise.id,
                    exercise_name=exercise.name,
                    sets=exercise.default_sets,
                    reps=reps,
                    weight=round(weight, 1),
                    order_index=selected,
                    rest_seconds=120 if exercise.type == '复合' else 75,
                )
            )
            last_muscle = exercise.muscle_group
            selected += 1

        days.append(PlanDay(day_of_week=index, focus=focus, exercises=day_exercises))

    return PlanResponse(
        name=f'{profile.goal}智能训练计划',
        goal=profile.goal,
        level=profile.level,
        days_per_week=profile.days_per_week,
        minutes_per_session=profile.minutes_per_session,
        avoid_muscles=profile.avoid_muscles,
        days=days,
    )


def _find_replacement(exercise_name: str, notes: str) -> str | None:
    for keyword, mapping in REHAB_REPLACEMENTS.items():
        if keyword in notes and exercise_name in mapping:
            return mapping[exercise_name]
    return None


def adjust_plan(request: AdjustPlanRequest) -> AdjustPlanResponse:
    adjusted_plan = deepcopy(request.plan)
    changes: list[str] = []
    feedback_by_name: dict[str, list[TrainingFeedback]] = defaultdict(list)
    for record in request.records:
        feedback_by_name[record.exercise_name].append(record)

    for day in adjusted_plan.get('daily_plans', []):
        for exercise in day.get('exercises', []):
            name = exercise.get('exercise_name', '')
            records = feedback_by_name.get(name, [])
            if not records:
                continue
            record = records[-1]
            if record.completion_score >= 8 and record.fatigue_score <= 5:
                exercise['weight'] = round(float(exercise.get('weight', 0)) * 1.075, 1)
                exercise['sets'] = int(exercise.get('sets', 4)) + 1
                changes.append(f'{name} 完成度高，下周重量上调约 7.5%，并增加 1 组。')
            elif record.completion_score <= 5 or record.fatigue_score >= 8:
                exercise['weight'] = round(float(exercise.get('weight', 0)) * 0.9, 1)
                exercise['sets'] = max(2, int(exercise.get('sets', 4)) - 1)
                changes.append(f'{name} 疲劳偏高或完成度偏低，下周重量下调 10%，并减少 1 组。')

            notes = (record.notes or '').strip()
            if notes:
                replacement = _find_replacement(name, notes)
                if replacement:
                    exercise['exercise_name'] = replacement
                    fallback = FALLBACK_EXERCISES.get(replacement)
                    if fallback is not None:
                        exercise['exercise_id'] = fallback.id
                    changes.append(f'检测到备注“{notes}”，已将 {name} 替换为 {replacement}。')

    summary = '；'.join(changes[:3]) if changes else '本周反馈整体稳定，暂不调整计划。'
    return AdjustPlanResponse(summary=summary, changes=changes, adjusted_plan=adjusted_plan)
