local ActIndex = {
	["pistol"] 		= ACT_HL2MP_IDLE_PISTOL,
	["smg"] 			= ACT_HL2MP_IDLE_SMG1,
	["grenade"] 		= ACT_HL2MP_IDLE_GRENADE,
	["ar2"] 			= ACT_HL2MP_IDLE_AR2,
	["shotgun"] 		= ACT_HL2MP_IDLE_SHOTGUN,
	["rpg"]	 		= ACT_HL2MP_IDLE_RPG,
	["physgun"] 		= ACT_HL2MP_IDLE_PHYSGUN,
	["crossbow"] 		= ACT_HL2MP_IDLE_CROSSBOW,
	["melee"] 		= ACT_HL2MP_IDLE_MELEE,
	["slam"] 			= ACT_HL2MP_IDLE_SLAM,
	["normal"]		= ACT_HL2MP_IDLE,
	["fist"]			= ACT_HL2MP_IDLE_FIST,
	["melee2"]		= ACT_HL2MP_IDLE_MELEE2,
	["passive"]		= ACT_HL2MP_IDLE_PASSIVE,
	["knife"]			= ACT_HL2MP_IDLE_KNIFE
}

function SWEP:SetWeaponHoldType(t)
	local index = ActIndex[t]
	if index == nil then
		return
	end
	self.ActivityTranslate = {}
	self.ActivityTranslate[ACT_MP_STAND_IDLE] 				= index
	self.ActivityTranslate[ACT_MP_WALK] 						= index+1
	self.ActivityTranslate[ACT_MP_RUN] 						= index+2
	self.ActivityTranslate[ACT_MP_CROUCH_IDLE] 				= index+3
	self.ActivityTranslate[ACT_MP_CROUCHWALK] 				= index+4
	self.ActivityTranslate[ACT_MP_ATTACK_STAND_PRIMARYFIRE] 	= index+5
	self.ActivityTranslate[ACT_MP_ATTACK_CROUCH_PRIMARYFIRE] = index+5
	self.ActivityTranslate[ACT_MP_RELOAD_STAND]		 		= index+6
	self.ActivityTranslate[ACT_MP_RELOAD_CROUCH]		 		= index+6
	self.ActivityTranslate[ACT_MP_JUMP] 						= index+7
	self.ActivityTranslate[ACT_RANGE_ATTACK1] 				= index+8
	
	if t == "normal" then
		self.ActivityTranslate [ACT_MP_JUMP] = ACT_HL2MP_JUMP_SLAM
	end
	self:SetupWeaponHoldTypeForAI(t)
end
SWEP:SetWeaponHoldType("pistol")

function SWEP:TranslateActivity(act)
	if self.Owner:IsNPC() then
		if self.ActivityTranslateAI[act] then
			return self.ActivityTranslateAI[act]
		end
		return -1
	end

	if self.ActivityTranslate[ act ] != nil then
		return self.ActivityTranslate[act]
	end
	return -1
end