from .models import Exercise

# 这里维护后端动作种子数据，和 Flutter 本地动作库保持相同的领域边界。
# 明确剔除教练端数据实体，不包含教练档案、派单、会话等模型。
EXERCISES: list[Exercise] = [
    Exercise(id=1, name='杠铃深蹲', muscle_group='腿', type='复合', difficulty='中级', default_sets=4, default_reps=8, weight_range=(20, 100), description='核心收紧，膝盖与脚尖同向。'),
    Exercise(id=2, name='相扑深蹲', muscle_group='腿', type='复合', difficulty='新手', default_sets=4, default_reps=10, weight_range=(10, 60), description='膝部压力更友好的变式。'),
    Exercise(id=3, name='卧推', muscle_group='胸', type='复合', difficulty='中级', default_sets=4, default_reps=8, weight_range=(20, 100), description='肩胛稳定，杠铃下放至胸线。'),
    Exercise(id=4, name='上斜卧推', muscle_group='胸', type='复合', difficulty='中级', default_sets=4, default_reps=8, weight_range=(15, 80), description='侧重上胸刺激。'),
    Exercise(id=5, name='哑铃卧推', muscle_group='胸', type='复合', difficulty='新手', default_sets=4, default_reps=10, weight_range=(8, 40), description='轨迹更自由。'),
    Exercise(id=6, name='俯卧撑', muscle_group='胸', type='复合', difficulty='新手', default_sets=4, default_reps=15, weight_range=(0, 0), description='基础推类动作。'),
    Exercise(id=7, name='硬拉', muscle_group='背', type='复合', difficulty='中级', default_sets=4, default_reps=5, weight_range=(40, 160), description='背部中立，髋主导。'),
    Exercise(id=8, name='杠铃划船', muscle_group='背', type='复合', difficulty='中级', default_sets=4, default_reps=8, weight_range=(20, 80), description='肘向后带动。'),
    Exercise(id=9, name='高位下拉', muscle_group='背', type='复合', difficulty='新手', default_sets=4, default_reps=10, weight_range=(20, 70), description='肩胛下沉发力。'),
    Exercise(id=10, name='引体向上', muscle_group='背', type='复合', difficulty='中级', default_sets=4, default_reps=6, weight_range=(0, 20), description='胸主动找杠。'),
    Exercise(id=11, name='肩推', muscle_group='肩', type='复合', difficulty='中级', default_sets=4, default_reps=8, weight_range=(10, 60), description='核心稳定。'),
    Exercise(id=12, name='侧平举', muscle_group='肩', type='孤立', difficulty='新手', default_sets=4, default_reps=12, weight_range=(3, 15), description='肘带动。'),
    Exercise(id=13, name='反向飞鸟', muscle_group='肩', type='孤立', difficulty='新手', default_sets=3, default_reps=15, weight_range=(3, 12), description='后束主导。'),
    Exercise(id=14, name='窄握卧推', muscle_group='手臂', type='复合', difficulty='中级', default_sets=4, default_reps=8, weight_range=(20, 80), description='三头主导。'),
    Exercise(id=15, name='杠铃弯举', muscle_group='手臂', type='孤立', difficulty='新手', default_sets=4, default_reps=10, weight_range=(10, 40), description='上臂固定。'),
    Exercise(id=16, name='绳索下压', muscle_group='手臂', type='孤立', difficulty='新手', default_sets=4, default_reps=12, weight_range=(10, 35), description='三头收缩。'),
    Exercise(id=17, name='平板支撑', muscle_group='核心', type='孤立', difficulty='新手', default_sets=4, default_reps=45, weight_range=(0, 0), description='以秒记录。'),
    Exercise(id=18, name='悬垂举腿', muscle_group='核心', type='复合', difficulty='中级', default_sets=4, default_reps=12, weight_range=(0, 0), description='避免借摆动。'),
    Exercise(id=19, name='俄罗斯转体', muscle_group='核心', type='孤立', difficulty='新手', default_sets=3, default_reps=20, weight_range=(0, 15), description='旋转来自躯干。'),
    Exercise(id=20, name='保加利亚分腿蹲', muscle_group='腿', type='复合', difficulty='中级', default_sets=3, default_reps=10, weight_range=(0, 30), description='单腿稳定训练。'),
]
