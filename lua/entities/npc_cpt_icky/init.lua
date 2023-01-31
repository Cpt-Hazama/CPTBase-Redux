if !CPTBase then return end
AddCSLuaFile('shared.lua')
include('shared.lua')

ENT.ModelTable = {"models/cpthazama/ichthyosaur_hlr.mdl"} // Credits to Silverlan for adding events to the vanilla model
ENT.StartHealth = 150
ENT.ViewAngle = 135

ENT.Faction = "FACTION_XEN"
ENT.Swim_WaterLevelCheck = 1

ENT.MeleeAttackDistance = 100
ENT.MeleeAttackDamageDistance = 120
ENT.MeleeAttackType = DMG_SLASH
ENT.MeleeAttackDamage = 25

ENT.BloodEffect = {"blood_impact_yellow_01"}
ENT.HasFlinchAnimation = true
ENT.FlinchChance = 30
ENT.HasDeathAnimation = true

ENT.tbl_Animations = {
	["Walk"] = {ACT_WALK},
	["Run"] = {ACT_RUN},
	["Attack"] = {ACT_MELEE_ATTACK1},
	["Pain"] = {"thrash"},
	["Death"] = {ACT_DIESIMPLE}
}

ENT.SoundDirectory = "cptbase/icky/"
ENT.tbl_Sounds = {
	["Idle"] = {"ichy_idle1.wav","ichy_idle2.wav","ichy_idle3.wav","ichy_idle4.wav"},
	["Attack"] = {"attack_growl1.wav","attack_growl2.wav","attack_growl3.wav"},
	["Alert"] = {"ichy_alert1.wav","ichy_alert2.wav","ichy_alert3.wav"},
	["Pain"] = {"ichy_pain1.wav","ichy_pain2.wav","ichy_pain3.wav","ichy_pain4.wav"},
	["Death"] = {"ichy_die1.wav","ichy_die2.wav","ichy_die3.wav","ichy_die4.wav"},
	["Strike"] = {"snap.wav"}
}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetInit()
	self:SetHullType(HULL_WIDE_SHORT)
	self:SetCollisionBounds(Vector(50,30,35),-(Vector(160,30,25))) // Causes major splash issues :/
	self:SetMovementType(MOVETYPE_SWIM)
	self.IsAttacking = false
	self:SetSwimSpeed(280)
	self:SetMaxYawSpeed(5)
	self.NextDrownT = 0
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnOutsideWater()
	self:SetLocalVelocity(Vector(0,0,0))
	self:SetIdleAnimation(ACT_IDLE)
	if CurTime() > self.NextDrownT then
		self:TakeDamage(1,nil)
		self.NextDrownT = CurTime() +0.2
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThink()
	if IsValid(self:GetEnemy()) then
		self:CPT_LookAtPosition(self:CPT_FindCenter(self:GetEnemy()),{"sidetoside","upanddown"},10)
		self:SetMaxYawSpeed(8)
	else
		self:SetMaxYawSpeed(5)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:HandleEvents(...)
	local event = select(1,...)
	local arg1 = select(2,...)
	if(event == "play") then
		if(arg1 == "Attack") then
			self:CPT_PlaySound("Attack")
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
	if (IsValid(self:GetEnemy()) && !self:GetEnemy():Visible(self)) then return end
	self:CPT_StopCompletely()
	self:CPT_PlayAnimation("Attack",2)
	self.IsAttacking = true
	self:CPT_AttackFinish()
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:HandleSchedules(enemy,dist,nearest,disp)
	if self.IsPossessed == true then return end
	if(disp == D_HT) then
		if nearest <= self.MeleeAttackDistance && self:CPT_FindInCone(enemy,self.MeleeAngle) && self.IsAttacking == false then
			self:DoAttack()
		end
	end
end