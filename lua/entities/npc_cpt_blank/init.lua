if !CPTBase then return end
AddCSLuaFile('shared.lua')
include('shared.lua')

ENT.ModelTable = {}
ENT.StartHealth = 50

ENT.Faction = "FACTION_NONE"

ENT.MeleeAttackDistance = 80
ENT.MeleeAttackDamageDistance = 90
ENT.MeleeAttackType = DMG_SLASH
ENT.MeleeAttackDamage = 0

ENT.RangeAttackDistance = 500

ENT.BloodEffect = {"blood_impact_red_01"}

ENT.tbl_Animations = {
	["Walk"] = {ACT_WALK},
	["Run"] = {ACT_RUN},
	["Attack"] = {ACT_MELEE_ATTACK1},
	["RangeAttack"] = {ACT_RANGE_ATTACK1}
}

ENT.tbl_Sounds = {
	["FootStep"] = {},
	["Idle"] = {},
	["Alert"] = {},
	["Attack"] = {},
	["Pain"] = {},
	["Death"] = {},
}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetInit()
	self:SetHullType(HULL_HUMAN)
	self:CapabilitiesAdd(bit.bor(CAP_MOVE_GROUND))
	self.IsAttacking = false
	self.IsRangeAttacking = false
	self.NextRangeAttackT = 0
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:HandleEvents(...)
	local event = select(1,...)
	local arg1 = select(2,...)
	local arg2 = select(3,...)
	if(event == "emit") then
		if(arg1 == "step") then
			self:PlaySound("FootStep",self.RunSoundVolume,90,self.StepSoundPitch,true)
		end
		return true
	end
	if(event == "mattack") then
		self:DoDamage(self.MeleeAttackDamageDistance,self.MeleeAttackDamage,self.MeleeAttackType)
		return true
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:DoAttack()
	if self:CanPerformProcess() == false then return end
	self:PlayAnimation("Attack",2)
	self:PlaySound("Attack")
	self.IsAttacking = true
	self:AttackFinish()
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:DoRangeAttack()
	if CurTime() > self.NextRangeAttackT then
		if self:CanPerformProcess() == false then return end
		self:PlayAnimation("RangeAttack",2)
		self.IsRangeAttacking = true
		self:AttackFinish()
		self.NextRangeAttackT = CurTime() +math.random(2,6)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:HandleSchedules(enemy,dist,nearest,disp)
	if(disp == D_HT) then
		if nearest <= self.MeleeAttackDistance && self:FindInCone(enemy,self.MeleeAngle) then
			self:DoAttack()
		end
		if nearest <= self.RangeAttackDistance && self:FindInCone(enemy,self.MeleeAngle) then
			self:DoRangeAttack()
		end
		if self:CanPerformProcess() then
			self:ChaseEnemy()
		end
	elseif(disp == D_FR) then
		self:Hide()
	end
end