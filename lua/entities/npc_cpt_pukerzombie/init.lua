if !CPTBase then return end
AddCSLuaFile('shared.lua')
include('shared.lua')

ENT.ModelTable = {"models/cpt_zombies/Soldier_Zombie.mdl"}
ENT.StartHealth = 150

ENT.Faction = "FACTION_ZOMBIE"

ENT.MeleeAttackDistance = 90
ENT.MeleeAttackDamageDistance = 90
ENT.MeleeAttackType = DMG_SLASH
ENT.MeleeAttackDamage = 18
ENT.MeleeAttackHitTime = 0.7

ENT.RangeAttackDistance = 250
ENT.RangeAttackThrowTime = 0.8

ENT.BloodEffect = {"blood_impact_red_01"}

ENT.UseTimedSteps = true
ENT.NextFootSound_Walk = 0.42
ENT.NextFootSound_Run = 0.42

ENT.tbl_Animations = {
	["Walk"] = {ACT_WALK},
	["Run"] = {ACT_WALK},
	["Attack"] = {"swatleftlow","swatrightlow"},
	["Recover"] = {ACT_FLINCH_RIGHTLEG},
	["RangeAttack"] = {"releasecrab"}
}

ENT.tbl_Sounds = {
	["Idle"] = {"npc/barnacle/barnacle_gulp1.wav","npc/barnacle/barnacle_gulp2.wav"},
	["Alert"] = {"npc/zombie/zombie_pain3.wav"},
	["Attack"] = {"npc/zombie/zombie_pain3.wav"},
	["Pain"] = {"npc/zombie/zombie_pain1.wav"},
	["Death"] = {"player/pl_pain6.wav"},
}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetInit()
	self:SetHullType(HULL_HUMAN)
	self:CapabilitiesAdd(bit.bor(CAP_MOVE_GROUND))
	self.IsAttacking = false
	self.IsRangeAttacking = false
	self.NextRangeAttackT = 0
	self:SetBodygroup(1,1)
end
---------------------------------------------------------------------------------------------------------------------------------------------
local chance = 0
function ENT:OnThink()
	if self:IsMoving() then chance = 30 elseif self.IsAttacking == true then chance = 10 else chance = 50 end
	if math.random(1,chance) == 1 then
		ParticleEffect("blood_impact_green_01",self:GetAttachment(self:LookupAttachment("head")).Pos,Angle(math.random(0,360),math.random(0,360),math.random(0,360)),self)
		ParticleEffect("blood_impact_red_01",self:GetAttachment(self:LookupAttachment("head")).Pos,Angle(math.random(0,360),math.random(0,360),math.random(0,360)),self)
		self:EmitSound(Sound("physics/flesh/flesh_bloody_impact_hard1.wav"),75,100)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:DoPlaySound(tbl)
	if tbl != "FootStep" then
		ParticleEffect("blood_impact_green_01",self:GetAttachment(self:LookupAttachment("head")).Pos,Angle(math.random(0,360),math.random(0,360),math.random(0,360)),self)
		ParticleEffect("blood_impact_red_01",self:GetAttachment(self:LookupAttachment("head")).Pos,Angle(math.random(0,360),math.random(0,360),math.random(0,360)),self)
		self:EmitSound(Sound("physics/flesh/flesh_bloody_impact_hard1.wav"),75,100)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnRagdollRecover()
	self:PlayAnimation("Recover")
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:DoAttack()
	if self:CanPerformProcess() == false then return end
	if !self.IsPossessed && (IsValid(self:GetEnemy()) && !self:GetEnemy():Visible(self)) then return end
	self:StopCompletely()
	self:PlayAnimation("Attack",2)
	self:PlaySound("Attack")
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
		if !self.IsPossessed && (IsValid(self:GetEnemy()) && !self:GetEnemy():Visible(self)) then return end
		self:StopCompletely()
		self:PlayAnimation("RangeAttack",2)
		self.IsRangeAttacking = true
		timer.Simple(0.1,function() if self:IsValid() then self:EmitSound(Sound("physics/flesh/flesh_squishy_impact_hard" .. math.random(1,4) .. ".wav"),75,100) end end)
		timer.Simple(0.3,function() if self:IsValid() then self:EmitSound(Sound("physics/flesh/flesh_squishy_impact_hard" .. math.random(1,4) .. ".wav"),75,100) end end)
		timer.Simple(0.5,function() if self:IsValid() then self:EmitSound(Sound("physics/flesh/flesh_squishy_impact_hard" .. math.random(1,4) .. ".wav"),75,100) end end)
		timer.Simple(0.7,function() if self:IsValid() then self:EmitSound(Sound("physics/flesh/flesh_squishy_impact_hard" .. math.random(1,4) .. ".wav"),75,100) end end)
		timer.Simple(0.8,function() if self:IsValid() then self:EmitSound(Sound("physics/flesh/flesh_bloody_break.wav"),75,100) ParticleEffect("blood_impact_yellow_01",self:GetAttachment(self:LookupAttachment("head")).Pos,Angle(math.random(0,360),math.random(0,360),math.random(0,360)),self) end end)
		timer.Simple(self.RangeAttackThrowTime,function()
			if self:IsValid() then
				if self:GetBodygroup(1) == 1 then
					self:SetBodygroup(1,0)
					local crab = ents.Create("prop_ragdoll")
					crab:SetModel("models/headcrabclassic.mdl")
					crab:SetPos(self:GetAttachment(self:LookupAttachment("headcrab")).Pos)
					crab:SetAngles(self:GetAttachment(self:LookupAttachment("headcrab")).Ang)
					crab:Spawn()
					crab:SetCollisionGroup(COLLISION_GROUP_NONE)
					local crabphys = crab:GetPhysicsObject()
					if IsValid(crabphys) then
						crabphys:SetVelocity(self:SetUpRangeAttackTarget() *3 +crab:GetUp() *1500)
					end
				else
					self:TakeDamage(40,self)
				end
				if self:Health() > 0 then
					local spit = ents.Create("obj_cpt_zombiepuke")
					spit:SetPos(self:GetAttachment(self:LookupAttachment("head")).Pos)
					spit:SetOwner(self)
					spit:SetDamage(26,DMG_ACID)
					spit:Spawn()
					spit:Activate()
					local phys = spit:GetPhysicsObject()
					if IsValid(phys) then
						phys:SetVelocity(self:SetUpRangeAttackTarget() *1.2 +self:GetUp() *200)
					end
				end
			end
		end)
		self:AttackFinish()
		self.NextRangeAttackT = CurTime() +math.random(2,6)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnDeath(dmg,dmginfo,hitbox)
	if self.IsRangeAttacking == true then
		self.HasDeathRagdoll = false
		for i=1,8 do
			local spit = ents.Create("obj_cpt_zombiepuke")
			spit:SetPos(self:GetPos() +self:OBBCenter())
			spit:SetAngles(Angle(math.random(0,360),math.random(0,360),math.random(0,360)))
			spit:SetOwner(self)
			spit:SetDamage(20,DMG_ACID)
			spit:Spawn()
			spit:Activate()
			spit:SetMaterial("models/flesh")
			spit:SetModel("models/gibs/strider_gib4.mdl")
			spit:SetModelScale(0.75,0)
			spit:SetNoDraw(false)
			spit:DrawShadow(true)
			local phys = spit:GetPhysicsObject()
			if IsValid(phys) then
				phys:SetVelocity(Vector(math.Rand(-100,100),math.Rand(-100,100),math.Rand(-100,100)) *2 +self:GetUp() *200)
			end
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:HandleSchedules(enemy,dist,nearest,disp)
	if(disp == D_HT) then
		if nearest <= self.MeleeAttackDistance && self:FindInCone(enemy,self.MeleeAngle) && self.IsAttacking == false then
			self:DoAttack()
		end
		if nearest <= self.RangeAttackDistance && self:FindInCone(enemy,self.MeleeAngle) && self.IsRangeAttacking == false then
			self:DoRangeAttack()
		end
		if nearest <= 200 then self.tbl_Animations["Run"] = {ACT_RUN} else self.tbl_Animations["Run"] = {ACT_WALK} end
		if self:CanPerformProcess() then
			self:ChaseEnemy()
		end
	elseif(disp == D_FR) then
		self:Hide()
	end
end