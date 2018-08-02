if !CPTBase then return end
AddCSLuaFile('shared.lua')
include('shared.lua')

ENT.ModelTable = {"models/cpthazama/para.mdl"}
ENT.StartHealth = 120
ENT.CollisionBounds = Vector(18,18,50)

ENT.Faction = "FACTION_CLOVERFIELD"

ENT.MeleeAttackDistance = 50
ENT.MeleeAttackDamageDistance = 95
ENT.MeleeAttackType = DMG_SLASH
ENT.MeleeAttackDamage = 15
ENT.MeleeAttackHitTime = 0.3

ENT.RangeAttackDistance = 100

ENT.BloodEffect = {"blood_impact_yellow"}

ENT.tbl_Animations = {
	["Walk"] = {ACT_WALK},
	["Run"] = {ACT_RUN},
	["Attack"] = {ACT_MELEE_ATTACK1},
	["RangeAttack"] = {"BR2_Attack"},
}

ENT.tbl_Sounds = {
	["Miss"] = {"cptbase/parasite/claw_miss1.wav","cptbase/parasite/claw_miss2.wav"},
	["Strike"] = {"cptbase/parasite/claw_miss1.wav","cptbase/parasite/claw_miss2.wav"},
	["Attack"] = {"cptbase/parasite/claw_strike1.wav","cptbase/parasite/claw_strike2.wav","cptbase/parasite/claw_strike3.wav"},
	["Idle"] = {"cptbase/parasite/idle1.wav","cptbase/parasite/idle2.wav","cptbase/parasite/idle3.wav"},
	["Alert"] = {"cptbase/parasite/wake1.wav","cptbase/parasite/pa_alert1.wav","cptbase/parasite/pa_alert2.wav","cptbase/parasite/fz_frenzy1.wav","cptbase/parasite/fz_scream1.wav"},
}

ENT.tbl_Capabilities = {CAP_OPEN_DOORS,CAP_USE,CAP_MOVE_CLIMB}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetInit()
	self:SetHullType(HULL_HUMAN)
	self:SetMovementType(MOVETYPE_STEP)
	self.IsAttacking = false
	self.IsRangeAttacking = false
	self.NextRangeAttackT = 0
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Possess_OnPossessed(possessor)
	possessor:ChatPrint("Possessor Controls:")
	possessor:ChatPrint("LMB - Attack")
	possessor:ChatPrint("RMB - Spit Attack (Close Range)")
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:DoAttack()
	if self:CanPerformProcess() == false then return end
	if (!self.IsPossessed && IsValid(self:GetEnemy()) && !self:GetEnemy():Visible(self)) then return end
	self:StopCompletely()
	self:PlaySound("Attack",75)
	self:PlayAnimation("Attack",2)
	self.IsAttacking = true
	timer.Simple(self.MeleeAttackHitTime,function()
		if self:IsValid() then
			self:DoDamage(self.MeleeAttackDamageDistance,self.MeleeAttackDamage,self.MeleeAttackType)
		end
	end)
	self:AttackFinish()
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:DoRangeAttack()
	if CurTime() > self.NextRangeAttackT then
		if self:CanPerformProcess() == false then return end
		if (!self.IsPossessed && IsValid(self:GetEnemy()) && !self:GetEnemy():Visible(self)) then return end
		self:StopCompletely()
		self:PlayAnimation("RangeAttack",2)
		self.IsRangeAttacking = true
		timer.Simple(self.MeleeAttackHitTime,function()
			if self:IsValid() then
				local spit = ents.Create("obj_cpt_antlionspit")
				spit:SetPos(self:FindCenter(self))
				spit:SetOwner(self)
				spit:SetDamage(30,DMG_POISON)
				spit:SetMassAmount(5)
				spit.CanFade = true
				spit.FadeTime = 0.3
				spit:Spawn()
				spit:Activate()
				local phys = spit:GetPhysicsObject()
				if IsValid(phys) then
					phys:SetVelocity(self:SetUpRangeAttackTarget() *1 +self:GetForward() *200 +self:GetUp() *150)
				end
			end
		end)
		self:AttackFinish()
		self.NextRangeAttackT = CurTime() +math.random(2,3)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:HandleSchedules(enemy,dist,nearest,disp)
	if self.IsPossessed then return end
	if(disp == D_HT) then
		if nearest <= self.MeleeAttackDistance && self:FindInCone(enemy,self.MeleeAngle) then
			self:DoAttack()
		end
		if nearest <= self.RangeAttackDistance && !self.IsLoopRangeAttacking && self:FindInCone(enemy,self.MeleeAngle) then
			self:DoRangeAttack()
		end
		if self:CanPerformProcess() then
			self:ChaseEnemy()
		end
	end
end