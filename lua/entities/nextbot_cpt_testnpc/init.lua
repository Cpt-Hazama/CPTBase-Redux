if !CPTBase then return end
AddCSLuaFile('shared.lua')
include('shared.lua')

ENT.ModelTable = {"models/Zombie/Classic.mdl"}
ENT.CollisionBounds = Vector(18,18,70)
ENT.StartHealth = 200

ENT.Faction = "FACTION_ZOMBIE"

ENT.MeleeAttackDistance = 95
ENT.MeleeAttackDamageDistance = 65
ENT.MeleeAttackType = DMG_SLASH
ENT.MeleeAttackDamage = 15
ENT.MeleeAttackHitTime = 0.95

ENT.tbl_Animations = {
	["Idle"] = {ACT_IDLE},
	["Walk"] = {ACT_WALK},
	["Run"] = {ACT_WALK},
	["Attack"] = {ACT_MELEE_ATTACK1},
}

ENT.tbl_Sounds = {
	["Attack"] = {
		"npc/zombie/zo_attack1.wav",
		"npc/zombie/zo_attack2.wav",
	},
	["Pain"] = {
		"npc/zombie/zombie_pain1.wav",
		"npc/zombie/zombie_pain2.wav",
		"npc/zombie/zombie_pain3.wav",
		"npc/zombie/zombie_pain4.wav",
		"npc/zombie/zombie_pain5.wav",
		"npc/zombie/zombie_pain6.wav",
	},
	["Death"] = {
		"npc/zombie/zombie_die1.wav",
		"npc/zombie/zombie_die2.wav",
		"npc/zombie/zombie_die3.wav",
	},
}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnInit()
	self:SetRunSpeed(170)
	self:SetWalkSpeed(170)
	self.IsAttacking = false
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:DoAttack()
	self:PlayNextbotAnimation("Attack","act",false)
	self:EmitSound(self:SelectFromTable(self.tbl_Sounds["Attack"]),75,100)
	self.IsAttacking = true
	timer.Simple(self.MeleeAttackHitTime,function()
		if IsValid(self) then
			self:DoDamage(self.MeleeAttackDamageDistance,self.MeleeAttackDamage,self.MeleeAttackType)
		end
	end)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnAnimationFinished(act)
	if self.IsAttacking then
		self.IsAttacking = false
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:HandleSchedules(enemy,dist,nearest,disp)
	if nearest <= self.MeleeAttackDistance && !self.IsAttacking then
		self:DoAttack()
	end
end