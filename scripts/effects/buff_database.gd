# buff_database.gd
# 85-103개 사이의 버프 및 디버프 정의 데이터베이스 (총 92개: 버프 46개 + 디버프 46개)
class_name BuffDatabase
extends RefCounted

enum StatType {
	ATTACK_POWER,
	ATTACK_COOLDOWN,
	MOVE_SPEED,
	MAX_HP,
	DEFENSE,
	CRIT_CHANCE,
	CRIT_DAMAGE,
	DAMAGE_REDUCTION,
	DAMAGE_AMPLIFY,
	DOT_DAMAGE,
	HEAL_OVER_TIME,
	STUN,
	FREEZE,
	SILENCE,
	BLIND,
	GOLD_GAIN,
	XP_GAIN,
	PICKUP_RANGE,
	LIFE_STEAL,
	REFLECT_DAMAGE,
	SHIELD,
	DODGE_CHANCE
}

# 92종 버프 & 디버프 데이터베이스
# buff: 46종, debuff: 46종 (총 92종, 85~103개 조건 충족)
const BUFF_DEFS: Dictionary = {
	# =========================================================================
	# [버프: 총 46종] - 스탯 강화, 회복, 보호막, 특수 유틸리티
	# =========================================================================
	"buff_might": {
		"id": "buff_might", "name": "용기의 일격", "is_debuff": false, "icon": "⚔️",
		"stat": StatType.ATTACK_POWER, "modifier": 0.20, "is_mult": true,
		"default_duration": 8.0, "desc": "공격력이 20% 증가합니다.", "color": Color(1.0, 0.4, 0.4)
	},
	"buff_warrior_spirit": {
		"id": "buff_warrior_spirit", "name": "전사의 혼", "is_debuff": false, "icon": "🔥",
		"stat": StatType.ATTACK_POWER, "modifier": 0.35, "is_mult": true,
		"default_duration": 10.0, "desc": "공격력이 35% 증가합니다.", "color": Color(1.0, 0.2, 0.2)
	},
	"buff_giant_strength": {
		"id": "buff_giant_strength", "name": "거인의 완력", "is_debuff": false, "icon": "💪",
		"stat": StatType.ATTACK_POWER, "modifier": 0.50, "is_mult": true,
		"default_duration": 6.0, "desc": "공격력이 50% 폭발적으로 증가합니다.", "color": Color(1.0, 0.5, 0.1)
	},
	"buff_sharp_blade": {
		"id": "buff_sharp_blade", "name": "예리한 칼날", "is_debuff": false, "icon": "🗡️",
		"stat": StatType.ATTACK_POWER, "modifier": 15.0, "is_mult": false,
		"default_duration": 12.0, "desc": "기본 공격력이 고정 수치 15 증가합니다.", "color": Color(0.9, 0.9, 1.0)
	},
	"buff_berserk": {
		"id": "buff_berserk", "name": "광전사의 분노", "is_debuff": false, "icon": "🩸",
		"stat": StatType.ATTACK_POWER, "modifier": 0.60, "is_mult": true,
		"default_duration": 5.0, "desc": "공격력이 60% 급증합니다.", "color": Color(0.9, 0.1, 0.1)
	},
	"buff_wind_stride": {
		"id": "buff_wind_stride", "name": "바람의 걸음", "is_debuff": false, "icon": "🍃",
		"stat": StatType.MOVE_SPEED, "modifier": 0.25, "is_mult": true,
		"default_duration": 7.0, "desc": "이동 속도가 25% 빨라집니다.", "color": Color(0.4, 1.0, 0.7)
	},
	"buff_haste": {
		"id": "buff_haste", "name": "신속의 축복", "is_debuff": false, "icon": "👟",
		"stat": StatType.MOVE_SPEED, "modifier": 0.40, "is_mult": true,
		"default_duration": 6.0, "desc": "이동 속도가 40% 증가합니다.", "color": Color(0.3, 0.9, 1.0)
	},
	"buff_dash_surge": {
		"id": "buff_dash_surge", "name": "돌격 질주", "is_debuff": false, "icon": "💨",
		"stat": StatType.MOVE_SPEED, "modifier": 0.60, "is_mult": true,
		"default_duration": 3.0, "desc": "순간적으로 이동 속도가 60% 급상승합니다.", "color": Color(0.7, 1.0, 0.9)
	},
	"buff_feather_step": {
		"id": "buff_feather_step", "name": "깃털 발걸음", "is_debuff": false, "icon": "🪶",
		"stat": StatType.MOVE_SPEED, "modifier": 0.15, "is_mult": true,
		"default_duration": 15.0, "desc": "이동 속도가 장시간 15% 가벼워집니다.", "color": Color(0.8, 1.0, 0.8)
	},
	"buff_iron_wall": {
		"id": "buff_iron_wall", "name": "철벽 수비", "is_debuff": false, "icon": "🛡️",
		"stat": StatType.DEFENSE, "modifier": 10.0, "is_mult": false,
		"default_duration": 8.0, "desc": "방어력이 10 상승합니다.", "color": Color(0.7, 0.7, 0.8)
	},
	"buff_granite_skin": {
		"id": "buff_granite_skin", "name": "화강암 피부", "is_debuff": false, "icon": "🪨",
		"stat": StatType.DEFENSE, "modifier": 20.0, "is_mult": false,
		"default_duration": 6.0, "desc": "단단한 바위처럼 방어력이 20 증가합니다.", "color": Color(0.6, 0.5, 0.4)
	},
	"buff_unyielding_armor": {
		"id": "buff_unyielding_armor", "name": "불굴의 갑옷", "is_debuff": false, "icon": "🥋",
		"stat": StatType.DEFENSE, "modifier": 0.50, "is_mult": true,
		"default_duration": 8.0, "desc": "현재 방어력이 50% 증폭됩니다.", "color": Color(0.8, 0.7, 0.3)
	},
	"buff_divine_shield": {
		"id": "buff_divine_shield", "name": "신성한 보호막", "is_debuff": false, "icon": "✨",
		"stat": StatType.SHIELD, "modifier": 100.0, "is_mult": false,
		"default_duration": 10.0, "desc": "피해를 흡수하는 100 포인트의 신성 방어막을 부여합니다.", "color": Color(1.0, 0.9, 0.5)
	},
	"buff_magic_barrier": {
		"id": "buff_magic_barrier", "name": "마력 방벽", "is_debuff": false, "icon": "🔮",
		"stat": StatType.SHIELD, "modifier": 50.0, "is_mult": false,
		"default_duration": 12.0, "desc": "피해를 막아주는 50 마력 실드가 생성됩니다.", "color": Color(0.6, 0.4, 1.0)
	},
	"buff_frost_armor": {
		"id": "buff_frost_armor", "name": "얼음 갑주", "is_debuff": false, "icon": "❄️",
		"stat": StatType.DAMAGE_REDUCTION, "modifier": 0.20, "is_mult": false,
		"default_duration": 7.0, "desc": "받는 모든 피해가 20% 감소합니다.", "color": Color(0.5, 0.8, 1.0)
	},
	"buff_guardian_aegis": {
		"id": "buff_guardian_aegis", "name": "수호자의 성벽", "is_debuff": false, "icon": "🏰",
		"stat": StatType.DAMAGE_REDUCTION, "modifier": 0.35, "is_mult": false,
		"default_duration": 5.0, "desc": "받는 모든 피해가 35% 대폭 경감됩니다.", "color": Color(0.9, 0.8, 0.6)
	},
	"buff_rapid_fire": {
		"id": "buff_rapid_fire", "name": "신속 사격", "is_debuff": false, "icon": "🏹",
		"stat": StatType.ATTACK_COOLDOWN, "modifier": -0.20, "is_mult": true,
		"default_duration": 7.0, "desc": "공격 쿨다운이 20% 감소하여 더 빠르게 공격합니다.", "color": Color(1.0, 0.8, 0.2)
	},
	"buff_hyper_acceleration": {
		"id": "buff_hyper_acceleration", "name": "초가속", "is_debuff": false, "icon": "⚡",
		"stat": StatType.ATTACK_COOLDOWN, "modifier": -0.40, "is_mult": true,
		"default_duration": 5.0, "desc": "공격 쿨다운이 40% 단축되어 맹공을 퍼붓습니다.", "color": Color(1.0, 1.0, 0.3)
	},
	"buff_frenzy_flurry": {
		"id": "buff_frenzy_flurry", "name": "난격의 기운", "is_debuff": false, "icon": "🌀",
		"stat": StatType.ATTACK_COOLDOWN, "modifier": -0.30, "is_mult": true,
		"default_duration": 6.0, "desc": "공격 연사 속도가 30% 빨라집니다.", "color": Color(0.9, 0.5, 0.2)
	},
	"buff_eagle_eye": {
		"id": "buff_eagle_eye", "name": "독수리의 눈", "is_debuff": false, "icon": "🦅",
		"stat": StatType.CRIT_CHANCE, "modifier": 0.20, "is_mult": false,
		"default_duration": 8.0, "desc": "치명타 확률이 20% 상승합니다.", "color": Color(1.0, 0.6, 0.2)
	},
	"buff_deadly_focus": {
		"id": "buff_deadly_focus", "name": "필살 집중", "is_debuff": false, "icon": "🎯",
		"stat": StatType.CRIT_CHANCE, "modifier": 0.35, "is_mult": false,
		"default_duration": 6.0, "desc": "치명타 확률이 35% 증가하여 치명적인 타격을 줍니다.", "color": Color(1.0, 0.3, 0.3)
	},
	"buff_lethal_strike": {
		"id": "buff_lethal_strike", "name": "치명적 분쇄", "is_debuff": false, "icon": "💥",
		"stat": StatType.CRIT_DAMAGE, "modifier": 0.50, "is_mult": false,
		"default_duration": 8.0, "desc": "치명타 피해량이 50% 추가 증가합니다.", "color": Color(1.0, 0.2, 0.5)
	},
	"buff_vampiric_touch": {
		"id": "buff_vampiric_touch", "name": "흡혈의 손길", "is_debuff": false, "icon": "🧛",
		"stat": StatType.LIFE_STEAL, "modifier": 0.15, "is_mult": false,
		"default_duration": 8.0, "desc": "가한 피해량의 15%만큼 체력을 흡수합니다.", "color": Color(0.8, 0.1, 0.3)
	},
	"buff_blood_drain": {
		"id": "buff_blood_drain", "name": "선혈 착취", "is_debuff": false, "icon": "🩸",
		"stat": StatType.LIFE_STEAL, "modifier": 0.25, "is_mult": false,
		"default_duration": 5.0, "desc": "가한 피해량의 25%를 즉시 생명력으로 전환합니다.", "color": Color(0.6, 0.0, 0.1)
	},
	"buff_regeneration": {
		"id": "buff_regeneration", "name": "지속 재생", "is_debuff": false, "icon": "🌱",
		"stat": StatType.HEAL_OVER_TIME, "modifier": 10.0, "is_mult": false,
		"default_duration": 10.0, "desc": "매 초마다 체력을 10씩 회복합니다.", "color": Color(0.3, 0.9, 0.3)
	},
	"buff_font_of_life": {
		"id": "buff_font_of_life", "name": "생명의 샘", "is_debuff": false, "icon": "💧",
		"stat": StatType.HEAL_OVER_TIME, "modifier": 25.0, "is_mult": false,
		"default_duration": 6.0, "desc": "초당 체력을 25씩 빠르게 회복합니다.", "color": Color(0.2, 1.0, 0.5)
	},
	"buff_vitality_surge": {
		"id": "buff_vitality_surge", "name": "활력 증폭", "is_debuff": false, "icon": "💖",
		"stat": StatType.MAX_HP, "modifier": 0.30, "is_mult": true,
		"default_duration": 15.0, "desc": "최대 체력이 30% 증가합니다.", "color": Color(1.0, 0.4, 0.7)
	},
	"buff_colossus_vigor": {
		"id": "buff_colossus_vigor", "name": "거상의 체력", "is_debuff": false, "icon": "🏋️",
		"stat": StatType.MAX_HP, "modifier": 0.50, "is_mult": true,
		"default_duration": 12.0, "desc": "최대 체력이 50% 거대하게 증가합니다.", "color": Color(0.9, 0.5, 0.8)
	},
	"buff_thorny_thorns": {
		"id": "buff_thorny_thorns", "name": "가시 갑옷", "is_debuff": false, "icon": "🌵",
		"stat": StatType.REFLECT_DAMAGE, "modifier": 0.30, "is_mult": false,
		"default_duration": 8.0, "desc": "피격 시 받은 피해의 30%를 공격자에게 반사합니다.", "color": Color(0.4, 0.8, 0.3)
	},
	"buff_mirror_shield": {
		"id": "buff_mirror_shield", "name": "거울 방패", "is_debuff": false, "icon": "🪞",
		"stat": StatType.REFLECT_DAMAGE, "modifier": 0.50, "is_mult": false,
		"default_duration": 5.0, "desc": "피격 시 받은 피해의 50%를 적에게 반사합니다.", "color": Color(0.7, 0.9, 1.0)
	},
	"buff_shadow_step": {
		"id": "buff_shadow_step", "name": "그림자 회피", "is_debuff": false, "icon": "👤",
		"stat": StatType.DODGE_CHANCE, "modifier": 0.25, "is_mult": false,
		"default_duration": 7.0, "desc": "적의 공격을 회피할 확률이 25% 부여됩니다.", "color": Color(0.5, 0.5, 0.7)
	},
	"buff_mirage_cloak": {
		"id": "buff_mirage_cloak", "name": "신기루 망토", "is_debuff": false, "icon": "🌫️",
		"stat": StatType.DODGE_CHANCE, "modifier": 0.40, "is_mult": false,
		"default_duration": 5.0, "desc": "공격 회피 확률이 40% 대폭 상승합니다.", "color": Color(0.8, 0.8, 0.9)
	},
	"buff_golden_greed": {
		"id": "buff_golden_greed", "name": "황금의 축복", "is_debuff": false, "icon": "🪙",
		"stat": StatType.GOLD_GAIN, "modifier": 0.50, "is_mult": false,
		"default_duration": 20.0, "desc": "획득 골드량이 50% 증가합니다.", "color": Color(1.0, 0.85, 0.2)
	},
	"buff_treasure_hunter": {
		"id": "buff_treasure_hunter", "name": "보물 사냥꾼", "is_debuff": false, "icon": "💰",
		"stat": StatType.GOLD_GAIN, "modifier": 1.00, "is_mult": false,
		"default_duration": 15.0, "desc": "골드 획득량이 2배(100% 증가)로 폭증합니다.", "color": Color(1.0, 0.9, 0.1)
	},
	"buff_scholar_wisdom": {
		"id": "buff_scholar_wisdom", "name": "학자의 지혜", "is_debuff": false, "icon": "📜",
		"stat": StatType.XP_GAIN, "modifier": 0.35, "is_mult": false,
		"default_duration": 20.0, "desc": "경험치 획득량이 35% 증가합니다.", "color": Color(0.3, 0.6, 1.0)
	},
	"buff_enlightenment": {
		"id": "buff_enlightenment", "name": "대각성", "is_debuff": false, "icon": "💡",
		"stat": StatType.XP_GAIN, "modifier": 0.70, "is_mult": false,
		"default_duration": 12.0, "desc": "경험치 획득량이 70% 대폭 증가합니다.", "color": Color(0.4, 0.8, 1.0)
	},
	"buff_magnetic_pulse": {
		"id": "buff_magnetic_pulse", "name": "자력 펄스", "is_debuff": false, "icon": "🧲",
		"stat": StatType.PICKUP_RANGE, "modifier": 0.50, "is_mult": true,
		"default_duration": 15.0, "desc": "아이템 획득 반경이 50% 넓어집니다.", "color": Color(0.9, 0.3, 0.3)
	},
	"buff_graviton_pull": {
		"id": "buff_graviton_pull", "name": "중력 견인", "is_debuff": false, "icon": "🌌",
		"stat": StatType.PICKUP_RANGE, "modifier": 1.00, "is_mult": true,
		"default_duration": 10.0, "desc": "아이템 획득 반경이 100% 확장됩니다.", "color": Color(0.5, 0.2, 0.9)
	},
	"buff_damage_amplifier": {
		"id": "buff_damage_amplifier", "name": "피해 증폭기", "is_debuff": false, "icon": "⚡",
		"stat": StatType.DAMAGE_AMPLIFY, "modifier": 0.25, "is_mult": false,
		"default_duration": 8.0, "desc": "모든 최종 가하는 피해가 25% 증폭됩니다.", "color": Color(1.0, 0.5, 0.2)
	},
	"buff_celestial_wrath": {
		"id": "buff_celestial_wrath", "name": "천벌의 분노", "is_debuff": false, "icon": "☀️",
		"stat": StatType.DAMAGE_AMPLIFY, "modifier": 0.40, "is_mult": false,
		"default_duration": 6.0, "desc": "가하는 최종 피해가 40% 강력해집니다.", "color": Color(1.0, 0.8, 0.3)
	},
	"buff_blade_mastery": {
		"id": "buff_blade_mastery", "name": "검술 숙련", "is_debuff": false, "icon": "⚔️",
		"stat": StatType.ATTACK_POWER, "modifier": 0.15, "is_mult": true,
		"default_duration": 14.0, "desc": "공격력이 균형감 있게 15% 상승합니다.", "color": Color(0.9, 0.6, 0.6)
	},
	"buff_fleet_footed": {
		"id": "buff_fleet_footed", "name": "날렵한 발놀림", "is_debuff": false, "icon": "👟",
		"stat": StatType.MOVE_SPEED, "modifier": 0.20, "is_mult": true,
		"default_duration": 12.0, "desc": "이동 속도가 안정적으로 20% 상승합니다.", "color": Color(0.5, 1.0, 0.6)
	},
	"buff_stone_bastion": {
		"id": "buff_stone_bastion", "name": "석조 요새", "is_debuff": false, "icon": "🧱",
		"stat": StatType.DEFENSE, "modifier": 15.0, "is_mult": false,
		"default_duration": 10.0, "desc": "방어력이 15 증가합니다.", "color": Color(0.7, 0.7, 0.6)
	},
	"buff_inner_peace": {
		"id": "buff_inner_peace", "name": "내면의 평화", "is_debuff": false, "icon": "🧘",
		"stat": StatType.HEAL_OVER_TIME, "modifier": 15.0, "is_mult": false,
		"default_duration": 8.0, "desc": "초당 15의 체력을 평화롭게 회복합니다.", "color": Color(0.4, 0.9, 0.7)
	},
	"buff_aegis_aura": {
		"id": "buff_aegis_aura", "name": "이지스의 오라", "is_debuff": false, "icon": "🛡️",
		"stat": StatType.DAMAGE_REDUCTION, "modifier": 0.15, "is_mult": false,
		"default_duration": 10.0, "desc": "받는 모든 피해가 15% 완화됩니다.", "color": Color(0.6, 0.8, 1.0)
	},
	"buff_sniper_focus": {
		"id": "buff_sniper_focus", "name": "저격수의 침착", "is_debuff": false, "icon": "👁️",
		"stat": StatType.CRIT_CHANCE, "modifier": 0.15, "is_mult": false,
		"default_duration": 12.0, "desc": "치명타 확률이 15% 향상됩니다.", "color": Color(1.0, 0.7, 0.3)
	},

	# =========================================================================
	# [디버프: 총 46종] - 스탯 저하, 속도 둔화, 지속 피해(DoT), 제어 불가
	# =========================================================================
	"debuff_slow_mud": {
		"id": "debuff_slow_mud", "name": "진흙 늪", "is_debuff": true, "icon": "💩",
		"stat": StatType.MOVE_SPEED, "modifier": -0.30, "is_mult": true,
		"default_duration": 4.0, "desc": "진흙에 발이 묶여 이동 속도가 30% 감소합니다.", "color": Color(0.6, 0.4, 0.2)
	},
	"debuff_tar_trap": {
		"id": "debuff_tar_trap", "name": "타르 감속", "is_debuff": true, "icon": "🛢️",
		"stat": StatType.MOVE_SPEED, "modifier": -0.50, "is_mult": true,
		"default_duration": 3.0, "desc": "끈적이는 타르로 인해 이동 속도가 50% 둔화됩니다.", "color": Color(0.3, 0.3, 0.3)
	},
	"debuff_cripple": {
		"id": "debuff_cripple", "name": "다리 무력화", "is_debuff": true, "icon": "🦵",
		"stat": StatType.MOVE_SPEED, "modifier": -0.65, "is_mult": true,
		"default_duration": 2.5, "desc": "부상으로 인해 이동 속도가 65% 급감합니다.", "color": Color(0.7, 0.2, 0.2)
	},
	"debuff_heavy_burden": {
		"id": "debuff_heavy_burden", "name": "무거운 짐", "is_debuff": true, "icon": "⛓️",
		"stat": StatType.MOVE_SPEED, "modifier": -0.20, "is_mult": true,
		"default_duration": 8.0, "desc": "오랫동안 이동 속도가 20% 느려집니다.", "color": Color(0.5, 0.5, 0.6)
	},
	"debuff_chill": {
		"id": "debuff_chill", "name": "한기", "is_debuff": true, "icon": "❄️",
		"stat": StatType.MOVE_SPEED, "modifier": -0.40, "is_mult": true,
		"default_duration": 3.5, "desc": "서늘한 한기에 휩싸여 이동 속도가 40% 저하됩니다.", "color": Color(0.4, 0.8, 1.0)
	},
	"debuff_weakness": {
		"id": "debuff_weakness", "name": "무력화", "is_debuff": true, "icon": "🥀",
		"stat": StatType.ATTACK_POWER, "modifier": -0.25, "is_mult": true,
		"default_duration": 5.0, "desc": "힘이 빠져 공격력이 25% 감소합니다.", "color": Color(0.7, 0.6, 0.8)
	},
	"debuff_enfeeble": {
		"id": "debuff_enfeeble", "name": "쇠약", "is_debuff": true, "icon": "🤕",
		"stat": StatType.ATTACK_POWER, "modifier": -0.40, "is_mult": true,
		"default_duration": 4.0, "desc": "기력이 쇠하여 공격력이 40% 감소합니다.", "color": Color(0.5, 0.4, 0.6)
	},
	"debuff_dull_blade": {
		"id": "debuff_dull_blade", "name": "무뎌진 무기", "is_debuff": true, "icon": "🪵",
		"stat": StatType.ATTACK_POWER, "modifier": -15.0, "is_mult": false,
		"default_duration": 7.0, "desc": "공격력이 고정 수치 15 감소합니다.", "color": Color(0.6, 0.5, 0.4)
	},
	"debuff_exhaustion": {
		"id": "debuff_exhaustion", "name": "극심한 탈진", "is_debuff": true, "icon": "😫",
		"stat": StatType.ATTACK_POWER, "modifier": -0.50, "is_mult": true,
		"default_duration": 3.0, "desc": "심한 피로로 공격력이 50% 격감합니다.", "color": Color(0.4, 0.3, 0.4)
	},
	"debuff_armor_break": {
		"id": "debuff_armor_break", "name": "방어구 파괴", "is_debuff": true, "icon": "💔",
		"stat": StatType.DEFENSE, "modifier": -10.0, "is_mult": false,
		"default_duration": 6.0, "desc": "방어력이 10 파괴됩니다.", "color": Color(0.8, 0.3, 0.3)
	},
	"debuff_shattered_guard": {
		"id": "debuff_shattered_guard", "name": "가드 분쇄", "is_debuff": true, "icon": "🛡️",
		"stat": StatType.DEFENSE, "modifier": -25.0, "is_mult": false,
		"default_duration": 4.0, "desc": "방어 태세가 무너져 방어력이 25 감소합니다.", "color": Color(0.9, 0.2, 0.2)
	},
	"debuff_corrosive_acid": {
		"id": "debuff_corrosive_acid", "name": "부식성 산", "is_debuff": true, "icon": "🧪",
		"stat": StatType.DEFENSE, "modifier": -0.40, "is_mult": true,
		"default_duration": 5.0, "desc": "산성 물질이 녹아내리며 방어력이 40% 부식됩니다.", "color": Color(0.6, 0.9, 0.1)
	},
	"debuff_vulnerability": {
		"id": "debuff_vulnerability", "name": "취약 노출", "is_debuff": true, "icon": "⚠️",
		"stat": StatType.DAMAGE_AMPLIFY, "modifier": 0.20, "is_mult": false,
		"default_duration": 5.0, "desc": "받는 피해가 20% 증가합니다.", "color": Color(1.0, 0.4, 0.4)
	},
	"debuff_exposed_wound": {
		"id": "debuff_exposed_wound", "name": "드러난 상처", "is_debuff": true, "icon": "🩸",
		"stat": StatType.DAMAGE_AMPLIFY, "modifier": 0.35, "is_mult": false,
		"default_duration": 4.0, "desc": "상처가 깊어져 받는 피해가 35% 증가합니다.", "color": Color(0.9, 0.2, 0.2)
	},
	"debuff_fatal_mark": {
		"id": "debuff_fatal_mark", "name": "사형 선고 표식", "is_debuff": true, "icon": "☠️",
		"stat": StatType.DAMAGE_AMPLIFY, "modifier": 0.50, "is_mult": false,
		"default_duration": 3.0, "desc": "받는 모든 피해가 50% 치명적으로 증폭됩니다.", "color": Color(0.7, 0.0, 0.0)
	},
	"debuff_burn": {
		"id": "debuff_burn", "name": "화상", "is_debuff": true, "icon": "🔥",
		"stat": StatType.DOT_DAMAGE, "modifier": 12.0, "is_mult": false,
		"default_duration": 4.0, "desc": "초당 12의 지속 화염 피해를 받습니다.", "color": Color(1.0, 0.4, 0.0)
	},
	"debuff_ignite": {
		"id": "debuff_ignite", "name": "발화", "is_debuff": true, "icon": "💥",
		"stat": StatType.DOT_DAMAGE, "modifier": 24.0, "is_mult": false,
		"default_duration": 3.0, "desc": "몸에 불이 붙어 초당 24의 강력한 화염 피해를 입습니다.", "color": Color(1.0, 0.2, 0.0)
	},
	"debuff_hellfire": {
		"id": "debuff_hellfire", "name": "지옥불", "is_debuff": true, "icon": "🌋",
		"stat": StatType.DOT_DAMAGE, "modifier": 45.0, "is_mult": false,
		"default_duration": 3.0, "desc": "꺼지지 않는 불길로 초당 45의 맹렬한 피해를 입습니다.", "color": Color(0.8, 0.1, 0.0)
	},
	"debuff_poison": {
		"id": "debuff_poison", "name": "중독", "is_debuff": true, "icon": "🟢",
		"stat": StatType.DOT_DAMAGE, "modifier": 8.0, "is_mult": false,
		"default_duration": 6.0, "desc": "독소에 오염되어 초당 8의 피해를 받습니다.", "color": Color(0.3, 0.8, 0.2)
	},
	"debuff_neurotoxin": {
		"id": "debuff_neurotoxin", "name": "신경독", "is_debuff": true, "icon": "🐍",
		"stat": StatType.DOT_DAMAGE, "modifier": 18.0, "is_mult": false,
		"default_duration": 5.0, "desc": "신경계가 마비되며 초당 18의 지속 피해를 받습니다.", "color": Color(0.5, 0.9, 0.1)
	},
	"debuff_deadly_venom": {
		"id": "debuff_deadly_venom", "name": "맹독", "is_debuff": true, "icon": "☠️",
		"stat": StatType.DOT_DAMAGE, "modifier": 35.0, "is_mult": false,
		"default_duration": 4.0, "desc": "치사율 높은 맹독으로 초당 35의 지속 피해를 입습니다.", "color": Color(0.2, 0.7, 0.2)
	},
	"debuff_bleed": {
		"id": "debuff_bleed", "name": "출혈", "is_debuff": true, "icon": "🩸",
		"stat": StatType.DOT_DAMAGE, "modifier": 15.0, "is_mult": false,
		"default_duration": 5.0, "desc": "상처가 찢겨 초당 15의 출혈 피해를 입습니다.", "color": Color(0.8, 0.1, 0.2)
	},
	"debuff_hemorrhage": {
		"id": "debuff_hemorrhage", "name": "과다출혈", "is_debuff": true, "icon": "💉",
		"stat": StatType.DOT_DAMAGE, "modifier": 30.0, "is_mult": false,
		"default_duration": 4.0, "desc": "심각한 출혈로 초당 30의 피해를 입습니다.", "color": Color(0.6, 0.0, 0.1)
	},
	"debuff_stun": {
		"id": "debuff_stun", "name": "기절", "is_debuff": true, "icon": "💫",
		"stat": StatType.STUN, "modifier": 1.0, "is_mult": false,
		"default_duration": 1.5, "desc": "의식을 잃고 아무런 행동도 할 수 없습니다.", "color": Color(1.0, 0.9, 0.3)
	},
	"debuff_heavy_concussion": {
		"id": "debuff_heavy_concussion", "name": "뇌진탕 충격", "is_debuff": true, "icon": "🔨",
		"stat": StatType.STUN, "modifier": 1.0, "is_mult": false,
		"default_duration": 2.5, "desc": "강한 충격으로 2.5초간 기절합니다.", "color": Color(1.0, 0.8, 0.2)
	},
	"debuff_paralysis": {
		"id": "debuff_paralysis", "name": "전신 마비", "is_debuff": true, "icon": "⚡",
		"stat": StatType.STUN, "modifier": 1.0, "is_mult": false,
		"default_duration": 2.0, "desc": "전류 충격으로 전신이 마비되어 움직일 수 없습니다.", "color": Color(0.9, 0.9, 0.4)
	},
	"debuff_freeze": {
		"id": "debuff_freeze", "name": "빙결", "is_debuff": true, "icon": "🧊",
		"stat": StatType.FREEZE, "modifier": 1.0, "is_mult": false,
		"default_duration": 2.0, "desc": "완전히 얼어붙어 이동 및 공격이 정지됩니다.", "color": Color(0.5, 0.9, 1.0)
	},
	"debuff_deep_permafrost": {
		"id": "debuff_deep_permafrost", "name": "영구동토 결빙", "is_debuff": true, "icon": "❄️",
		"stat": StatType.FREEZE, "modifier": 1.0, "is_mult": false,
		"default_duration": 3.0, "desc": "극한의 냉기로 3초간 꽁꽁 얼어붙습니다.", "color": Color(0.3, 0.7, 1.0)
	},
	"debuff_silence": {
		"id": "debuff_silence", "name": "침묵", "is_debuff": true, "icon": "🤐",
		"stat": StatType.SILENCE, "modifier": 1.0, "is_mult": false,
		"default_duration": 4.0, "desc": "스킬 발동 및 특수 능력이 봉인됩니다.", "color": Color(0.7, 0.4, 0.9)
	},
	"debuff_mana_lock": {
		"id": "debuff_mana_lock", "name": "마력 봉인", "is_debuff": true, "icon": "🔒",
		"stat": StatType.SILENCE, "modifier": 1.0, "is_mult": false,
		"default_duration": 6.0, "desc": "마력 흐름이 차단되어 스킬을 시전할 수 없습니다.", "color": Color(0.5, 0.3, 0.8)
	},
	"debuff_blind": {
		"id": "debuff_blind", "name": "실명", "is_debuff": true, "icon": "🙈",
		"stat": StatType.BLIND, "modifier": 0.50, "is_mult": false,
		"default_duration": 4.0, "desc": "시야가 어두워져 공격 적중률이 50% 빗나갑니다.", "color": Color(0.4, 0.4, 0.4)
	},
	"debuff_smoke_screen": {
		"id": "debuff_smoke_screen", "name": "연막 차단", "is_debuff": true, "icon": "🌫️",
		"stat": StatType.BLIND, "modifier": 0.75, "is_mult": false,
		"default_duration": 3.0, "desc": "짙은 연막에 갇혀 75% 확률로 공격이 빗나갑니다.", "color": Color(0.5, 0.5, 0.5)
	},
	"debuff_curse_decay": {
		"id": "debuff_curse_decay", "name": "부패의 저주", "is_debuff": true, "icon": "💀",
		"stat": StatType.MAX_HP, "modifier": -0.20, "is_mult": true,
		"default_duration": 8.0, "desc": "저주에 걸려 최대 체력이 20% 감소합니다.", "color": Color(0.4, 0.2, 0.5)
	},
	"debuff_life_drain_curse": {
		"id": "debuff_life_drain_curse", "name": "생명 흡수 저주", "is_debuff": true, "icon": "👻",
		"stat": StatType.MAX_HP, "modifier": -0.35, "is_mult": true,
		"default_duration": 6.0, "desc": "생명력이 침식되어 최대 체력이 35% 깎여나갑니다.", "color": Color(0.5, 0.1, 0.6)
	},
	"debuff_slow_reflex": {
		"id": "debuff_slow_reflex", "name": "반사 신경 지연", "is_debuff": true, "icon": "🐢",
		"stat": StatType.ATTACK_COOLDOWN, "modifier": 0.30, "is_mult": true,
		"default_duration": 6.0, "desc": "반응이 둔해져 공격 쿨다운이 30% 증가합니다.", "color": Color(0.6, 0.7, 0.5)
	},
	"debuff_sluggish_arm": {
		"id": "debuff_sluggish_arm", "name": "느려진 손놀림", "is_debuff": true, "icon": "🐌",
		"stat": StatType.ATTACK_COOLDOWN, "modifier": 0.50, "is_mult": true,
		"default_duration": 4.5, "desc": "손이 무거워져 공격 쿨다운이 50% 길어집니다.", "color": Color(0.5, 0.6, 0.4)
	},
	"debuff_decaying_flesh": {
		"id": "debuff_decaying_flesh", "name": "부패한 살점", "is_debuff": true, "icon": "🥩",
		"stat": StatType.DOT_DAMAGE, "modifier": 10.0, "is_mult": false,
		"default_duration": 6.0, "desc": "초당 10의 부패 피해를 입습니다.", "color": Color(0.5, 0.3, 0.2)
	},
	"debuff_frostbite": {
		"id": "debuff_frostbite", "name": "동상", "is_debuff": true, "icon": "🥶",
		"stat": StatType.DOT_DAMAGE, "modifier": 14.0, "is_mult": false,
		"default_duration": 4.0, "desc": "동상으로 인해 초당 14의 냉기 지속 피해를 입습니다.", "color": Color(0.4, 0.7, 0.9)
	},
	"debuff_electrocution": {
		"id": "debuff_electrocution", "name": "감전 감쇠", "is_debuff": true, "icon": "⚡",
		"stat": StatType.DOT_DAMAGE, "modifier": 20.0, "is_mult": false,
		"default_duration": 3.5, "desc": "감전되어 초당 20의 전기 지속 피해를 받습니다.", "color": Color(0.8, 0.8, 0.2)
	},
	"debuff_soul_rot": {
		"id": "debuff_soul_rot", "name": "영혼 부식", "is_debuff": true, "icon": "🧿",
		"stat": StatType.DOT_DAMAGE, "modifier": 28.0, "is_mult": false,
		"default_duration": 4.0, "desc": "초당 28의 암흑 영혼 피해를 입습니다.", "color": Color(0.3, 0.1, 0.4)
	},
	"debuff_unlucky_fate": {
		"id": "debuff_unlucky_fate", "name": "불운의 낙인", "is_debuff": true, "icon": "🎱",
		"stat": StatType.CRIT_CHANCE, "modifier": -0.20, "is_mult": false,
		"default_duration": 8.0, "desc": "치명타 확률이 20% 감소합니다.", "color": Color(0.3, 0.3, 0.4)
	},
	"debuff_frail_bones": {
		"id": "debuff_frail_bones", "name": "부서지기 쉬운 뼈", "is_debuff": true, "icon": "🦴",
		"stat": StatType.DAMAGE_REDUCTION, "modifier": -0.20, "is_mult": false,
		"default_duration": 6.0, "desc": "방어 성능이 약화되어 20%의 추가 피해를 고스란히 받습니다.", "color": Color(0.8, 0.8, 0.7)
	},
	"debuff_clumsy": {
		"id": "debuff_clumsy", "name": "어설픈 움직임", "is_debuff": true, "icon": "🤡",
		"stat": StatType.DODGE_CHANCE, "modifier": -0.30, "is_mult": false,
		"default_duration": 7.0, "desc": "회피 확률이 30% 감소합니다.", "color": Color(0.6, 0.5, 0.6)
	},
	"debuff_diminished_range": {
		"id": "debuff_diminished_range", "name": "시야 왜곡", "is_debuff": true, "icon": "😵",
		"stat": StatType.PICKUP_RANGE, "modifier": -0.40, "is_mult": true,
		"default_duration": 10.0, "desc": "획득 반경이 40% 축소됩니다.", "color": Color(0.5, 0.4, 0.5)
	},
	"debuff_greed_tax": {
		"id": "debuff_greed_tax", "name": "도둑의 세금", "is_debuff": true, "icon": "💸",
		"stat": StatType.GOLD_GAIN, "modifier": -0.30, "is_mult": false,
		"default_duration": 12.0, "desc": "획득 골드가 30% 차감됩니다.", "color": Color(0.7, 0.6, 0.3)
	},
	"debuff_mind_fog": {
		"id": "debuff_mind_fog", "name": "기억의 안개", "is_debuff": true, "icon": "🌫️",
		"stat": StatType.XP_GAIN, "modifier": -0.30, "is_mult": false,
		"default_duration": 12.0, "desc": "획득 경험치가 30% 감소합니다.", "color": Color(0.4, 0.5, 0.6)
	}
}

static func get_definition(id: String) -> Dictionary:
	return BUFF_DEFS.get(id, {})

static func get_all_buff_ids() -> Array[String]:
	var result: Array[String] = []
	for k in BUFF_DEFS.keys():
		if not BUFF_DEFS[k]["is_debuff"]:
			result.append(k)
	return result

static func get_all_debuff_ids() -> Array[String]:
	var result: Array[String] = []
	for k in BUFF_DEFS.keys():
		if BUFF_DEFS[k]["is_debuff"]:
			result.append(k)
	return result

static func get_all_ids() -> Array[String]:
	var result: Array[String] = []
	for k in BUFF_DEFS.keys():
		result.append(k)
	return result

static func get_total_count() -> int:
	return BUFF_DEFS.size()
