from __future__ import annotations

import re

from .models import VoiceParseResponse


def parse_command(text: str) -> VoiceParseResponse:
    normalized = text.strip()
    if not normalized:
        return VoiceParseResponse(intent='unknown', entities={}, reply='没有收到有效语音内容，请再说一次。')

    if normalized.startswith('添加动作'):
        name = normalized.replace('添加动作', '', 1).strip()
        return VoiceParseResponse(
            intent='exercise_library',
            entities={'action': 'add', 'exercise_name': name},
            reply=f'已识别为添加动作指令，目标动作是{name}。',
        )

    if normalized.startswith('删除动作'):
        name = normalized.replace('删除动作', '', 1).strip()
        return VoiceParseResponse(
            intent='exercise_library',
            entities={'action': 'delete', 'exercise_name': name},
            reply=f'已识别为删除动作指令，目标动作是{name}。',
        )

    if '查找' in normalized and '动作' in normalized:
        muscle = ''
        move_type = ''
        for item in ['胸', '背', '肩', '腿', '手臂', '核心']:
            if item in normalized:
                muscle = item
                break
        for item in ['复合', '孤立']:
            if item in normalized:
                move_type = item
                break
        return VoiceParseResponse(
            intent='exercise_library',
            entities={'action': 'search', 'muscle_group': muscle, 'type': move_type},
            reply='已识别为动作搜索指令。',
        )

    if '生成' in normalized and '计划' in normalized:
        return VoiceParseResponse(
            intent='plan',
            entities={'action': 'generate'},
            reply='已识别为训练计划生成指令。',
        )

    if '调整' in normalized and '动作' in normalized:
        day = next((item for item in ['周一', '周二', '周三', '周四', '周五', '周六', '周日'] if item in normalized), '')
        muscle = next((item for item in ['练腿', '胸', '背', '肩', '手臂', '核心'] if item in normalized), '')
        return VoiceParseResponse(
            intent='plan',
            entities={'action': 'adjust', 'day': day, 'focus': muscle},
            reply='已识别为计划调整指令。若动作不明确，可以继续追问具体替换目标。',
        )

    if normalized.startswith('记录今天') or normalized.startswith('记录'):
        sets_match = re.search(r'(\d+)组', normalized)
        reps_match = re.search(r'(\d+)次', normalized)
        weight_match = re.search(r'(\d+(?:\.\d+)?)\s*kg', normalized, re.IGNORECASE)
        name = normalized.replace('记录今天', '').replace('记录', '').split('完成')[0].strip()
        return VoiceParseResponse(
            intent='record',
            entities={
                'exercise_name': name,
                'completed_sets': int(sets_match.group(1)) if sets_match else None,
                'completed_reps': int(reps_match.group(1)) if reps_match else None,
                'completed_weight': float(weight_match.group(1)) if weight_match else None,
            },
            reply=f'已记录 {name} 的训练结果。',
        )

    if '完成率' in normalized or '推荐' in normalized or '姿势' in normalized or '难度' in normalized:
        return VoiceParseResponse(
            intent='query',
            entities={'question': normalized},
            reply='已识别为查询类问题，可返回报告、推荐或动作说明。',
        )

    return VoiceParseResponse(
        intent='unknown',
        entities={'raw_text': normalized},
        reply='我还不能完全理解这条指令，请换一种更具体的说法。',
    )
