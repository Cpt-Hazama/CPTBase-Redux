SWEP.PrintName		= "Pulse Rifle"
SWEP.HUDSlot		= 3
SWEP.HUDImportance 	= 3
SWEP.Author 		= "Cpt. Hazama"
SWEP.Category		= "CPTBase"
SWEP.ViewModelFOV	= 55
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/weapons/c_irifle.mdl"
SWEP.WorldModel		= "models/weapons/w_irifle.mdl"
SWEP.HoldType = "ar2"
SWEP.Base = "weapon_cpt_base"
SWEP.Spawnable = true
SWEP.AdminSpawnable = false
SWEP.UseHands = true

SWEP.AmmoNameTypes = "combine dark energy containers"
SWEP.DrawTime = false
SWEP.ReloadTime = false
SWEP.WeaponWeight = 7
SWEP.HasShells = false

SWEP.Primary.TotalShots = 1
SWEP.Primary.Spread = 0.03
SWEP.Primary.Tracer = 1
SWEP.Primary.Force = 1
SWEP.Primary.Damage = 14
SWEP.Primary.Delay = 0.09
SWEP.MuzzleEffect = "cpt_muzzle_combine"
SWEP.Primary.TracerEffect = "cpt_tracer_combine"
SWEP.MuzzleFlash_Color = Color(0,178,255)

SWEP.Primary.ClipSize		= 30
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "darkpulseenergy"
SWEP.OverrideBulletPos = true
SWEP.NPC_MoveRandomlyChance = 60

SWEP.NPCFireRate = 0.8
SWEP.tbl_NPCFireTimes = {0,0.1,0.2,0.3,0.4}
SWEP.NPC_EnemyFarDistance = 1350 -- Too Far, chase
SWEP.NPC_FireDistance = 2500
SWEP.NPC_FireDistanceStop = 500
SWEP.NPC_FireDistanceMoveAway = 200
SWEP.NPC_Spread = 10
SWEP.ReloadSpeed = 1

SWEP.DrawAnimation = ACT_VM_DRAW
SWEP.IdleAnimation = ACT_VM_IDLE
SWEP.FireAnimation = ACT_VM_PRIMARYATTACK
SWEP.ReloadAnimation = ACT_VM_RELOAD

SWEP.AdjustWorldModel = true
SWEP.WorldModelAdjust = {
	Pos = {Right = -4.3,Forward = -6.2,Up = 5},
	Ang = {Right = -10,Up = 180,Forward = 0}
}

SWEP.tbl_Sounds = {
	["DryFire"] = {"weapons/ar2/ar2_empty.wav"},
	["Fire"] = {"^weapons/ar1/ar1_dist1.wav","^weapons/ar1/ar1_dist2.wav"},
}
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:OnInit()
	if CLIENT then return end
	if self.Owner:IsNPC() && self.Owner.CPTBase_NPC != true then
		self:Remove()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:OnNPCThink()
	if self.Owner.WeaponIsDrawn then
		self.Owner.tbl_Animations["Walk"] = {"Walk_aiming_all"}
		self.Owner.tbl_Animations["Run"] = {"RunAIMALL1"}
		self:SetNoDraw(false)
		self:DrawShadow(true)
	else
		self.Owner.tbl_Animations["Walk"] = {"WalkUnarmed_all"}
		self.Owner.tbl_Animations["Run"] = {"WalkUnarmed_all"}
		self:SetNoDraw(true)
		self:DrawShadow(false)
	end
	self.Owner.tbl_Animations["Fire"] = {"gesture_shoot_ar2"}
	self.Owner.tbl_Animations["Reload"] = {"gesture_reload"}
	if self.Owner.WeaponIsDrawn then
		self.Owner:SetIdleAnimation("CombatIdle1")
	else
		self.Owner:SetIdleAnimation("Idle_Unarmed")
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:OverrideBulletPosition()
	return self:GetAttachment(1).Pos
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:FiredBullet(attacker,tr,dmginfo)
	local effectdata = EffectData()
	effectdata:SetOrigin(tr.HitPos)
	effectdata:SetScale(1)
	util.Effect("AR2Impact",effectdata)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:OnPrimaryAttack()
	if self.Owner:IsNPC() then
		if self.Owner.tbl_Animations != nil && self.Owner.tbl_Animations["Fire"] != nil then
			self:NPC_FireGesture(self:SelectFromTable(self.Owner.tbl_Animations["Fire"]))
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:OnReload()
	if self.Owner:IsNPC() then
		if self.Owner.tbl_Animations != nil && self.Owner.tbl_Animations["Reload"] != nil then
			self:NPC_FireGesture(self:SelectFromTable(self.Owner.tbl_Animations["Reload"]),2,self.ReloadSpeed)
		end
	end
end