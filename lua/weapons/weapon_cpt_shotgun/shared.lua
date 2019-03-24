SWEP.PrintName		= "Shotgun"
SWEP.HUDSlot = 4
SWEP.HUDImportance = 1
SWEP.Author 		= "Cpt. Hazama"
SWEP.Category		= "CPTBase"
SWEP.ViewModelFOV	= 55
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/weapons/c_shotgun.mdl"
SWEP.WorldModel		= "models/weapons/w_shotgun.mdl"
SWEP.HoldType		= "shotgun"
SWEP.Base = "weapon_cpt_base"
SWEP.Spawnable = true
SWEP.AdminSpawnable = false
SWEP.UseHands = true

SWEP.AmmoNameTypes = "shells"
SWEP.DrawTime = false
SWEP.ReloadTime = false
SWEP.WeaponWeight = 7
SWEP.UseSingleReload = true

SWEP.Primary.TotalShots = 7
SWEP.Primary.Spread = 0.08
SWEP.Primary.Tracer = 1
SWEP.Primary.Force = 8
SWEP.Primary.Damage = 4
SWEP.Primary.Delay = 1.3

SWEP.Primary.ClipSize		= 8
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "Buckshot"
SWEP.NPCFireRate = 1.3
SWEP.tbl_NPCFireTimes = {0}
SWEP.NPC_EnemyFarDistance = 700 -- Too Far, chase
SWEP.NPC_FireDistance = 1000
SWEP.NPC_FireDistanceStop = 400
SWEP.NPC_FireDistanceMoveAway = 200
SWEP.NPC_Spread = 10
SWEP.ReloadSpeed = 0.5
SWEP.OverrideBulletPos = true

SWEP.DrawAnimation = ACT_VM_DRAW
SWEP.IdleAnimation = ACT_VM_IDLE
SWEP.FireAnimation = ACT_VM_PRIMARYATTACK
SWEP.ReloadAnimation = ACT_VM_RELOAD

SWEP.tbl_Sounds = {
	["Fire"] = {"weapons/shotgun/shotgun_fire7.wav"},
	["Reload"] = {"weapons/shotgun/shotgun_reload3.wav"},
	["Cock"] = {"weapons/shotgun/shotgun_cock.wav"},
}
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:OnInit()
	if self.Owner:IsNPC() && self.Owner.CPTBase_NPC != true then
		self:Remove()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:OnNPCThink()
	if self.Owner.WeaponIsDrawn then
		self.Owner.tbl_Animations["Walk"] = {"Walk_aiming_all_SG"}
		self.Owner.tbl_Animations["Run"] = {"RunAIMALL1_SG"}
		self:SetNoDraw(false)
		self:DrawShadow(true)
	else
		self.Owner.tbl_Animations["Walk"] = {"WalkUnarmed_all"}
		self.Owner.tbl_Animations["Run"] = {"WalkUnarmed_all"}
		self:SetNoDraw(true)
		self:DrawShadow(false)
	end
	self.Owner.tbl_Animations["Fire"] = {"gesture_shoot_shotgun"}
	self.Owner.tbl_Animations["Reload"] = {"gesture_reload"}
	if self.Owner.WeaponIsDrawn then
		self.Owner:SetIdleAnimation("CombatIdle1_SG")
	else
		self.Owner:SetIdleAnimation("Idle_Unarmed")
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:OverrideBulletPosition()
	return self:GetAttachment(1).Pos
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:OnPrimaryAttack()
	if self.Owner:IsNPC() then
		if self.Owner.tbl_Animations != nil && self.Owner.tbl_Animations["Fire"] != nil then
			self:NPC_FireGesture(self:SelectFromTable(self.Owner.tbl_Animations["Fire"]))
		end
		timer.Simple(0.6,function()
			if self:IsValid() && self.Owner:GetActiveWeapon():GetClass() == self:GetClass() then
				if self.Owner:IsPlayer() then self:UseDefinedSequence("pump") end
				self:PlayWeaponSound("Cock",75)
			end
		end)
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