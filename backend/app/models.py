from __future__ import annotations

from typing import Any, Literal

from pydantic import BaseModel, Field

Goal = Literal['增肌', '减脂', '力量']
Level = Literal['新手', '中级', '高级']
Intent = Literal['exercise_library', 'plan', 'record', 'query', 'unknown']


class Exercise(BaseModel):
    id: int
    name: str
    muscle_group: str
    type: str
    difficulty: str
    default_sets: int = 4
    default_reps: int = 10
    weight_range: tuple[float, float] = (0, 60)
    description: str = ''


class ExerciseInput(BaseModel):
    name: str
    muscle_group: str
    type: str
    difficulty: str
    default_sets: int = 4
    default_reps: int = 10
    weight_range: tuple[float, float] = (0, 60)
    description: str = ''


class UserProfile(BaseModel):
    goal: Goal
    level: Level
    days_per_week: int = Field(ge=2, le=6)
    minutes_per_session: int = Field(ge=30, le=120)
    avoid_muscles: list[str] = Field(default_factory=list)


class PlanExercise(BaseModel):
    exercise_id: int
    exercise_name: str
    sets: int
    reps: int
    weight: float
    order_index: int
    rest_seconds: int = 90


class PlanDay(BaseModel):
    day_of_week: int
    focus: str
    exercises: list[PlanExercise]


class PlanResponse(BaseModel):
    name: str
    goal: Goal
    level: Level
    days_per_week: int
    minutes_per_session: int
    avoid_muscles: list[str]
    days: list[PlanDay]


class TrainingFeedback(BaseModel):
    exercise_id: int | None = None
    exercise_name: str
    muscle_group: str
    completed_sets: int = 0
    completed_reps: int = 0
    completed_weight: float = 0
    completion_score: int = Field(ge=1, le=10)
    fatigue_score: int = Field(ge=1, le=10)
    target_met: bool = False
    notes: str | None = None


class AdjustPlanRequest(BaseModel):
    plan: dict[str, Any]
    records: list[TrainingFeedback]


class AdjustPlanResponse(BaseModel):
    summary: str
    changes: list[str]
    adjusted_plan: dict[str, Any]


class VoiceParseRequest(BaseModel):
    text: str


class VoiceParseResponse(BaseModel):
    intent: Intent
    entities: dict[str, Any]
    reply: str
