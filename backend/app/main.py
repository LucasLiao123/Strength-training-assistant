from __future__ import annotations

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware

from .exercise_seed import EXERCISES
from .models import AdjustPlanRequest, AdjustPlanResponse, Exercise, ExerciseInput, PlanResponse, UserProfile, VoiceParseRequest, VoiceParseResponse
from .planner import adjust_plan, generate_plan
from .voice_parser import parse_command

app = FastAPI(
    title='Strength Training MVP API',
    version='0.1.0',
    description='力量训练智能 APP 的 MVP 后端，仅面向普通用户训练管理，不包含任何教练端功能。',
)

# 允许所有来源（前端部署在 Vercel 等任意域名均可访问）
app.add_middleware(
    CORSMiddleware,
    allow_origins=['*'],
    allow_methods=['*'],
    allow_headers=['*'],
)

exercise_store = list(EXERCISES)


@app.get('/health')
def health() -> dict[str, str]:
    return {'status': 'ok'}


@app.get('/exercises', response_model=list[Exercise])
def list_exercises(muscle_group: str | None = None, difficulty: str | None = None, type: str | None = None) -> list[Exercise]:
    result = exercise_store
    if muscle_group:
        result = [item for item in result if item.muscle_group == muscle_group]
    if difficulty:
        result = [item for item in result if item.difficulty == difficulty]
    if type:
        result = [item for item in result if item.type == type]
    return result


@app.get('/exercises/{exercise_id}', response_model=Exercise)
def get_exercise(exercise_id: int) -> Exercise:
    for exercise in exercise_store:
        if exercise.id == exercise_id:
            return exercise
    raise HTTPException(status_code=404, detail='Exercise not found')


@app.post('/exercises', response_model=Exercise)
def create_exercise(payload: ExerciseInput) -> Exercise:
    next_id = max((exercise.id for exercise in exercise_store), default=0) + 1
    exercise = Exercise(id=next_id, **payload.model_dump())
    exercise_store.append(exercise)
    return exercise


@app.put('/exercises/{exercise_id}', response_model=Exercise)
def update_exercise(exercise_id: int, payload: ExerciseInput) -> Exercise:
    for index, exercise in enumerate(exercise_store):
        if exercise.id == exercise_id:
            updated = Exercise(id=exercise_id, **payload.model_dump())
            exercise_store[index] = updated
            return updated
    raise HTTPException(status_code=404, detail='Exercise not found')


@app.delete('/exercises/{exercise_id}')
def delete_exercise(exercise_id: int) -> dict[str, str]:
    for index, exercise in enumerate(exercise_store):
        if exercise.id == exercise_id:
            del exercise_store[index]
            return {'status': 'deleted'}
    raise HTTPException(status_code=404, detail='Exercise not found')


@app.post('/plans/generate', response_model=PlanResponse)
def create_plan(profile: UserProfile) -> PlanResponse:
    return generate_plan(profile)


@app.post('/plans/adjust', response_model=AdjustPlanResponse)
def update_plan(request: AdjustPlanRequest) -> AdjustPlanResponse:
    return adjust_plan(request)


@app.post('/voice/parse', response_model=VoiceParseResponse)
def parse_voice(request: VoiceParseRequest) -> VoiceParseResponse:
    return parse_command(request.text)
