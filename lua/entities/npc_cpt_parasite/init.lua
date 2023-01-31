if !CPTBase then return end
AddCSLuaFile('shared.lua')
include('shared.lua')

ENT.ModelTable = {"models/antlion.mdl"}
ENT.StartHealth = 60
ENT.CollisionBounds = Vector(18,18,50)

ENT.Faction = "FACTION_ANTLION"

ENT.MeleeAttackDistance = 50
ENT.MeleeAttackDamageDistance = 95
ENT.MeleeAttackType = DMG_SLASH
ENT.MeleeAttackDamage = 15
ENT.MeleeAttackHitTime = 0.55

ENT.RangeAttackDistance = 90

ENT.BloodEffect = {"blood_impact_yellow"}

ENT.tbl_Animations = {
	["Walk"] = {ACT_WALK},
	["Run"] = {"RunAgitated"},
	["Attack"] = {ACT_MELEE_ATTACK1},
	["RangeAttack"] = {"pounce2"},
}

ENT.tbl_Sounds = {
	["Miss"] = {"cptbase/parasite/claw_miss1.wav","cptbase/parasite/claw_miss2.wav"},
	["Strike"] = {"cptbase/parasite/claw_miss1.wav","cptbase/parasite/claw_miss2.wav"},
	["Attack"] = {"npc/antlion/attack_single1.wav","npc/antlion/attack_single2.wav","npc/antlion/attack_single3.wav","npc/antlion/attack_double1.wav","npc/antlion/attack_double2.wav"},
	["Idle"] = {"npc/antlion/idle1.wav","npc/antlion/idle2.wav","npc/antlion/idle3.wav","npc/antlion/idle4.wav","npc/antlion/idle5.wav"},
	["Alert"] = {"npc/antlion/attack_double3.wav"},
	["Pain"] = {"npc/antlion/distract1.wav"},
	["Death"] = {"npc/antlion/pain1.wav","npc/antlion/pain2.wav"},
	["FootStep"] = {"npc/antlion/foot1.wav","npc/antlion/foot2.wav","npc/antlion/foot3.wav","npc/antlion/foot4.wav"},
}

ENT.tbl_Capabilities = {CAP_OPEN_DOORS,CAP_USE,CAP_MOVE_CLIMB,CAP_MOVE_JUMP}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetInit()
	self:SetHullType(HULL_HUMAN)
	self:SetMovementType(MOVETYPE_STEP)
	self.IsAttacking = false
	self.IsRangeAttacking = false
	self.NextRangeAttackT = 0
	self:SetColor(Color(116,255,225))
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
	self:CPT_StopCompletely()
	self:CPT_PlaySound("Attack",75)
	self:CPT_PlayAnimation("Attack",2)
	self.IsAttacking = true
	timer.Simple(self.MeleeAttackHitTime,function()
		if IsValid(self) then
			self:DoDamage(self.MeleeAttackDamageDistance,self.MeleeAttackDamage,self.MeleeAttackType)
		end
	end)
	self:CPT_AttackFinish()
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:DoRangeAttack()
	if CurTime() > self.NextRangeAttackT then
		if self:CanPerformProcess() == false then return end
		if (!self.IsPossessed && IsValid(self:GetEnemy()) && !self:GetEnemy():Visible(self)) then return end
		self:CPT_StopCompletely()
		self:CPT_PlaySound("Attack",75)
		self:CPT_PlayAnimation("RangeAttack",2)
		self.IsRangeAttacking = true
		timer.Simple(self.MeleeAttackHitTime,function()
			if IsValid(self) then
				local spit = ents.Create("obj_cpt_antlionspit")
				spit:SetPos(self:CPT_FindCenter(self))
				spit:SetOwner(self)
				spit:SetDamage(30,DMG_POISON)
				spit:SetMassAmount(5)
				spit.CanFade = true
				spit.FadeTime = 0.5
				spit:Spawn()
				spit:Activate()
				local phys = spit:GetPhysicsObject()
				if IsValid(phys) then
					phys:SetVelocity(self:SetUpRangeAttackTarget() *1 +self:GetForward() *200 +self:GetUp() *150)
				end
			end
		end)
		self:CPT_AttackFinish()
		self.NextRangeAttackT = CurTime() +math.random(2,3)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:HandleSchedules(enemy,dist,nearest,disp)
	if self.IsPossessed then return end
	if(disp == D_HT) then
		if nearest <= self.MeleeAttackDistance && self:CPT_FindInCone(enemy,self.MeleeAngle) then
			self:DoAttack()
		end
		if nearest <= self.RangeAttackDistance && !self.IsLoopRangeAttacking && self:CPT_FindInCone(enemy,self.MeleeAngle) then
			self:DoRangeAttack()
		end
		if self:CanPerformProcess() then
			self:ChaseEnemy()
		end
	end
end