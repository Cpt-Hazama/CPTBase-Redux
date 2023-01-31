if !CPTBase then return end
AddCSLuaFile('shared.lua')
include('shared.lua')

ENT.ModelTable = {"models/cpthazama/cptbase/sprite.mdl"}
ENT.StartHealth = 60
ENT.CollisionBounds = Vector(18,18,70)

ENT.Faction = {"FACTION_DOOM_DEMON","FACTION_DEMON"}

ENT.MeleeAttackDistance = 50
ENT.MeleeAttackDamageDistance = 95
ENT.MeleeAttackType = DMG_SLASH
ENT.MeleeAttackDamage = 1

ENT.RangeAttackDistance = 500

ENT.BloodEffect = {"blood_impact_red"}

ENT.tbl_Animations = {
	["Walk"] = {ACT_RUN},
	["Run"] = {ACT_RUN},
}

ENT.tbl_Sounds = {
	["Idle"] = {"cptbase/imp/dsbgact.wav"},
	["Alert"] = {"cptbase/imp/dsbgsit1.wav","cptbase/imp/dsbgsit2.wav"},
	["RangeAttack"] = {"cptbase/imp/dsfirsht.wav"},
	["Pain"] = {"cptbase/imp/dspopain.wav"},
	["Death"] = {"cptbase/imp/dsbgdth1.wav","cptbase/imp/dsbgdth2.wav"},
	["Strike"] = {"cptbase/imp/dsclaw.wav"}
}

ENT.MoveSpeed = 5

ENT.tbl_Capabilities = {CAP_OPEN_DOORS,CAP_USE,CAP_MOVE_CLIMB}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SpawnFunction(ply,tr,class)
	if not tr.Hit then return end

	local ent = ents.Create(class)
	ent:SetPos(tr.HitPos +tr.HitNormal *100)
	local ang = ply:EyeAngles()
	ent:SetAngles(Angle(0,ang.y +180,0))
	ent:Spawn()
	ent:Activate()

	return ent
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetInit()
	self:SetHullType(HULL_HUMAN)
	self:SetMovementType(MOVETYPE_STEP)
	self.IsAttacking = false
	self.IsRangeAttacking = false
	self.NextRangeAttackT = 0

	-- self:SetModelScale(5.35)
	self:SetSpriteAnim("move")
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Possess_OnPossessed(possessor)
	possessor:ChatPrint("Possessor Controls:")
	possessor:ChatPrint("LMB - Attack")
	possessor:ChatPrint("RMB - Spit Attack (Close Range)")
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnSpriteAnimEnd(parentName,seqName,dir,animData)
	if seqName == "attack" then
		self:SetSpriteAnim("move")
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnInputAccepted(event,activator)
	if event == "attack" then
		if self.IsAttacking then
			self:DoDamage(self.MeleeAttackDamageDistance,math.random(3,24),self.MeleeAttackType)
		elseif self.IsRangeAttacking then
			local spit = ents.Create("obj_cpt_doom1_projectile")
			spit:SetPos(self:CPT_FindCenter(self))
			spit:SetOwner(self)
			spit:SetDamage(math.random(3,24),DMG_BURN)
			spit.SpriteID = "proj_fireball"
			spit.SpriteScale = 1
			spit.SpriteOffset = Vector(0,-6.5,6.5)
			spit.SpriteHeight = 0
			spit.SpriteSize = 128
			spit.IdleAnimation = "idle"
			spit.ImpactAnimation = "explode"
			spit.RemovalDelay = self:CalculateSpriteAnimTime(2,5)
			spit.ImpactSounds = {"cptbase/imp/dsfirxpl.wav"}
			spit:Spawn()
			spit:Activate()
			local phys = spit:GetPhysicsObject()
			if IsValid(phys) then
				phys:SetVelocity(self:SetUpRangeAttackTarget() *1 +self:GetForward() *200)
			end
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:DoAttack()
	if self:CanPerformProcess() == false then return end
	if (!self.IsPossessed && IsValid(self:GetEnemy()) && !self:GetEnemy():Visible(self)) then return end
	self:CPT_StopCompletely()
	self:CPT_PlaySound("Attack",75)
	self:SetSpriteAnim("attack")
	self.IsAttacking = true
	self:CPT_AttackFinish(nil,self:CalculateSpriteAnimTime(3,5))
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:DoRangeAttack()
	if CurTime() > self.NextRangeAttackT then
		if self:CanPerformProcess() == false then return end
		if (!self.IsPossessed && IsValid(self:GetEnemy()) && !self:GetEnemy():Visible(self)) then return end
		self:CPT_StopCompletely()
		self:CPT_PlaySound("RangeAttack",75)
		self:SetSpriteAnim("attack")
		self.IsRangeAttacking = true
		self:CPT_AttackFinish(nil,self:CalculateSpriteAnimTime(3,5))
		self.NextRangeAttackT = CurTime() +math.random(4,7)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:HandleSchedules(enemy,dist,nearest,disp)
	self:SetPoseParameter("move_speed",self.MoveSpeed)
	if self.IsPossessed then return end
	if disp == D_HT then
		if nearest <= self.MeleeAttackDistance && self:CPT_FindInCone(enemy,self.MeleeAngle) then
			self:DoAttack()
		end
		if nearest <= self.RangeAttackDistance && nearest > self.MeleeAttackDistance && self:CPT_FindInCone(enemy,self.MeleeAngle) then
			self:DoRangeAttack()
		end
		if self:CanPerformProcess() then
			self:ChaseEnemy()
		end
	end
end