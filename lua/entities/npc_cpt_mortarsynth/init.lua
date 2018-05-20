if !CPTBase then return end
AddCSLuaFile('shared.lua')
include('shared.lua')

ENT.ModelTable = {"models/mortarsynth.mdl"}
ENT.StartHealth = 100

ENT.Faction = "FACTION_COMBINE"

ENT.BackAwayDistance = 200
ENT.ComeBackDistance = 2000
ENT.HasDeathRagdoll = false

ENT.RangeAttackDistance = 800
ENT.RangeAttackDamageDistance = 60
ENT.RangeAttackDamageType = DMG_DISSOLVE
ENT.RangeAttackDamage = 15
ENT.RangeAttackHitTime = 0.8

ENT.BloodEffect = {"blood_impact_green_01"}

ENT.tbl_Animations = {
	["Walk"] = {ACT_WALK},
	["Run"] = {ACT_RUN},
	["RangeAttack"] = {ACT_RANGE_ATTACK1}
}

ENT.tbl_Sounds = {
	["Charge"] = {"npc/strider/charging.wav"},
	["Fire"] = {"npc/strider/fire.wav"},
	["Injured"] = {"npc/strider/striderx_pain8.wav"},
	["IdleLoop"] = {"npc/attack_helicopter/aheli_mine_seek_loop1.wav"},
	["Alert"] = {"barnacle/bcl_alert2.wav"},
	["TraceHit"] = {"weapons/stunstick/alyx_stunner1.wav","weapons/stunstick/alyx_stunner2.wav"},
	["Idle"] = {"buttons/combine_button1.wav"}
}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetInit()
	self:SetHullType(HULL_MEDIUM)
	self:SetFlySpeed(200)
	self:SetMovementType(MOVETYPE_FLY,true)
	self.IsRangeAttacking = false
	self:SetCollisionBounds(Vector(33,33,26),Vector(-33,-33,-30))
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThink()
	if self.IsPossessed then
		if self.IsRangeAttacking then self:FaceEnemy() end
		self.RangeAttackDistance = 1500
	else
		self.RangeAttackDistance = 800
	end
	if self.IsPossessed == false && !IsValid(self:GetEnemy()) && (self.IsStartingUp == false or self:GetVelocity():Length() < 10) then self:SetLocalVelocity(Vector(0,0,0)) end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Possess_Jump(possessor) self:SetLocalVelocity(Vector(0,0,0)) end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:DoAttack()
	if self:CanPerformProcess() == false then return end
	if !self.IsPossessed && (IsValid(self:GetEnemy()) && !self:GetEnemy():Visible(self)) then return end
	self:StopCompletely()
	self:PlayAnimation("RangeAttack")
	self:PlaySound("Charge",80,90,120)
	self.IsRangeAttacking = true
	timer.Simple(self.RangeAttackHitTime,function()
		if self:IsValid() then
			self:PlaySound("Fire",80,90,170)
			self:DoTraceAttack(self.RangeAttackDistance,self.RangeAttackDamage,self.RangeAttackDamageType,self.RangeAttackDamageDistance)
		end
	end)
	self:AttackFinish()
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnTraceRun(traceHit)
	util.CreateWorldLight(self,traceHit.HitPos,"255 42 0 250","2","50","0","0.2")
	util.CreateWorldLight(self,self:GetAttachment(self:LookupAttachment("0")).Pos,"255 42 0 250","1","80","0","0.2")
	util.CreateWorldLight(self,self:GetAttachment(self:LookupAttachment("1")).Pos,"255 42 0 250","1","80","0","0.2")
	ParticleEffectAttach("mortarsynth_beam_charge_glow_cp0b",PATTACH_POINT_FOLLOW,self,self:LookupAttachment(0))
	ParticleEffectAttach("mortarsynth_beam_charge_glow_cp0b",PATTACH_POINT_FOLLOW,self,self:LookupAttachment(1))
	util.ParticleTracerEx("mortarsynth_beam_b", self:GetPos(), traceHit.HitPos, false, self:EntIndex(), 1)
	util.ParticleTracerEx("mortarsynth_beam_b", self:GetPos(), traceHit.HitPos, false, self:EntIndex(), 2)
	util.ParticleTracerEx("mortarsynth_beam_charge_b", self:GetPos(), traceHit.HitPos, false, self:EntIndex(), 1)
	util.ParticleTracerEx("mortarsynth_beam_charge_b", self:GetPos(), traceHit.HitPos, false, self:EntIndex(), 2)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnTraceHit(ent,traceHit)
	ent:EmitSound(ent:SelectFromTable(self.tbl_Sounds["TraceHit"]),50,100)
	for i = 0,ent:GetBoneCount() -1 do
		ParticleEffect("mortarsynth_beam_charge_glow_cp0b",ent:GetBonePosition(i),Angle(0,0,0),nil)
	end
	util.CreateWorldLight(ent,traceHit.HitPos,"255 42 0 250","2","150","0","0.2")
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnDeath(dmg,dmginfo,hitbox)
	util.CreateCustomExplosion(self:GetPos(),30,200,self)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:HandleSchedules_Fly(enemy,dist,nearest,disp)
	if self.IsPossessed == true then return end
	if self.IsStartingUp == true then
		self.IsStartingUp = false
		self:SetLocalVelocity(Vector(0,0,0))
	end
	if(disp == D_HT) then
		self:HandleFlying(enemy,dist,nearest)
		if nearest <= self.RangeAttackDistance && enemy:Visible(self) then
			self:DoAttack()
		end
	end
end