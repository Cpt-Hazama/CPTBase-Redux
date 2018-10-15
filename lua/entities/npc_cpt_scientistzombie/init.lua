if !CPTBase then return end
AddCSLuaFile('shared.lua')
include('shared.lua')

ENT.ModelTable = {"models/cpthazama/hl2/zombie_scientist.mdl"}
ENT.StartHealth = 150
ENT.UsePlayermodelMovement = true
ENT.PlayermodelMovementSpeed_Forward = 1
ENT.PlayermodelMovementSpeed_Backward = -0.5
ENT.PlayermodelMovementSpeed_Left = -0.75
ENT.PlayermodelMovementSpeed_Right = 0.75

ENT.Faction = "FACTION_ZOMBIE"

ENT.MeleeAttackDistance = 90
ENT.MeleeAttackDamageDistance = 75
ENT.MeleeAttackType = DMG_SLASH
ENT.MeleeAttackDamage = 10
ENT.GlobalAnimationSpeed = 0.5
ENT.AllowPropDamage = true
ENT.PropAttackForce = Vector(5000,0,500)

ENT.BloodEffect = {"blood_impact_red_01"}

ENT.UseTimedSteps = true
ENT.NextFootSound_Walk = 0.4
ENT.NextFootSound_Run = 0.4

ENT.Possessor_CanTurnWhileAttacking = false

ENT.tbl_Animations = {
	["Walk"] = {"zombie_run"},
	["Run"] = {"zombie_run"},
	["Attack"] = {
		"cptges_zombie_attack_01",
		"cptges_zombie_attack_02",
		"cptges_zombie_attack_03",
		"cptges_zombie_attack_04",
		"cptges_zombie_attack_05",
		"cptges_zombie_attack_06"
	},
}

ENT.tbl_Sounds = {
	["Attack"] = {"npc/zombie/zo_attack1.wav","npc/zombie/zo_attack2.wav"},
	["Pain"] = {"npc/zombie/zombie_pain1.wav","npc/zombie/zombie_pain2.wav","npc/zombie/zombie_pain3.wav","npc/zombie/zombie_pain4.wav","npc/zombie/zombie_pain5.wav","npc/zombie/zombie_pain6.wav"},
	["Death"] = {"npc/zombie/zombie_die1.wav","npc/zombie/zombie_die2.wav","npc/zombie/zombie_die3.wav"},
	["FootStep"] = {"npc/zombie/foot1.wav","npc/zombie/foot2.wav","npc/zombie/foot3.wav"},
	["Strike"] = {"npc/zombie/claw_strike1.wav","npc/zombie/claw_strike2.wav","npc/zombie/claw_strike3.wav"},
	["Miss"] = {"npc/zombie/claw_miss1.wav","npc/zombie/claw_miss2.wav"}
}

ENT.tbl_Capabilities = {CAP_OPEN_DOORS,CAP_USE,CAP_MOVE_JUMP}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetInit()
	self:SetHullType(HULL_HUMAN)
	self:SetMovementType(MOVETYPE_STEP)
	self.IsAttacking = false
	self.NextPropAttackT = 0
	self:SetIdleAnimation("zombie_idle_01")
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:FootStepCode()
	if self.IsRagdolled == true then return end
	local xpp = "move_x"
	local ypp = "move_y"
	local x = self:GetPoseParameter(xpp)
	local y = self:GetPoseParameter(ypp)
	if self:IsOnGround() && self:IsMoving() && self.UseTimedSteps == true then
		if (x != 0 || y != 0) && CurTime() > self.NextFootSoundT_Run then
			self:PlaySound("FootStep",self.RunSoundVolume,90,self.StepSoundPitch,true)
			self:DoPlaySound("FootStep")
			self:OnStep("Run")
			self.NextFootSoundT_Run = CurTime() + self.NextFootSound_Run
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThink()
	if self.IsPossessed then
		self:SetAngles(Angle(0,(self:Possess_AimTarget() -self:GetPos()):Angle().y,0))
	end
	if !self.IsPossessed && CurTime() > self.NextPropAttackT then
		for _,ent in ipairs(ents.FindInSphere(self:GetPos() +self:OBBCenter() +self:GetForward() *20,self.MeleeAttackDamageDistance)) do
			if ent:IsValid() && self:Visible(ent) then
				if table.HasValue(self.AttackablePropNames,ent:GetClass()) then
					self:DoAttack()
				end
			end
		end
		self.NextPropAttackT = CurTime() +1
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:DoAttack()
	if self:CanPerformProcess() == false then return end
	if (!self.IsPossessed && IsValid(self:GetEnemy()) && !self:GetEnemy():Visible(self)) then return end
	self:PlaySound("Attack",75,90,85)
	self:PlayAnimation("Attack")
	self.IsAttacking = true
	timer.Simple(0.6,function()
		if self:IsValid() then
			self:DoDamage(self.MeleeAttackDamageDistance,self.MeleeAttackDamage,self.MeleeAttackType,Vector(0,0,0),Angle(0,0,0),function(ent,dmginfo)
				util.AddAttackEffect(self,ent,5,DMG_POI,1,10)
				return
			end)
		end
	end)
	timer.Simple(1,function()
		if self:IsValid() then
			self.IsAttacking = false
			self.IsRangeAttacking = false
			self.HasStoppedMovingToAttack = false
			self:CustomOnAttackFinish()
		end
	end)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:HandleSchedules(enemy,dist,nearest,disp)
	if self.IsPossessed == true then return end
	if(disp == D_HT) then
		if nearest <= self.MeleeAttackDistance && self:FindInCone(enemy,self.MeleeAngle) then
			self:DoAttack()
		end
		self:ChaseEnemy()
	end
end