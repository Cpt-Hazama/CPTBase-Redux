SWEP.PrintName		= "Assault Rifle"
SWEP.Author 		= "Cpt. Hazama"
SWEP.ViewModelFOV	= 55
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/fallout/weapons/w_assaultrifle.mdl"
SWEP.WorldModel		= "models/fallout/weapons/w_assaultrifle.mdl"
SWEP.HoldType		= "ar2"
SWEP.Base = "weapon_cpt_base"
SWEP.Spawnable = false
SWEP.AdminSpawnable = false

SWEP.DrawTime = false
SWEP.Primary.TotalShots = 1
SWEP.Primary.Spread = 0.02
SWEP.Primary.Force = 8
SWEP.Primary.Damage = 6
SWEP.Primary.ClipSize		= 28
SWEP.Primary.Ammo			= "SMG1"

SWEP.NPCFireRate = 0.15
SWEP.NPC_CurrentReloadTime = 2.6
SWEP.NPC_FireDistance_Max = 2000
SWEP.NPC_FireDistance_Stop = 500
SWEP.NPC_UseWalk_Distance = 1400
SWEP.NPC_CanStrafe = true -- Allow the NPC to strafe when close enough?

SWEP.NPC_IdleAnimation = ACT_DOD_STAND_AIM_C96
SWEP.NPC_WalkAnimation = ACT_DOD_WALK_AIM_C96
SWEP.NPC_RunAnimation = ACT_DOD_RUN_AIM_C96
SWEP.NPC_FireAnimation = "2haattackloop"
SWEP.NPC_ReloadAnimation = "2hareloada"
SWEP.NPC_EquipAnimation = "2haequip"

SWEP.AdjustWorldModel = false
SWEP.WorldModelAttachmentBone = "Bip01 R Hand"
SWEP.WorldModelAdjust = {
	Pos = {Right = -10,Forward = 2,Up = -1},
	Ang = {Right = 112,Up = 180,Forward = -102}
}

SWEP.tbl_Sounds = {
	["Equip"] = {"cptbase/assaultrifle/rifleassault_equip.wav"},
	["Fire"] = {"cptbase/assaultrifle/rifleassaultg3_fire_3d.wav"},
	["ReloadA"] = {"cptbase/assaultrifle/rifleassaultg3_reload_out.wav"},
	["ReloadB"] = {"cptbase/assaultrifle/rifleassaultg3_reload_in.wav"},
	["ReloadC"] = {"cptbase/assaultrifle/rifleassaultg3_reload_chamber.wav"}
}

function SWEP:ReloadSounds()
	self:PlayWeaponSoundTimed("ReloadA",75,0.45)
	self:PlayWeaponSoundTimed("ReloadB",75,1.5)
	self:PlayWeaponSoundTimed("ReloadC",75,1.9)
end

SWEP.NPC_UseAnimation = 0
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:OnNPCThink()
	self.Owner:SetIdleAnimation(self.NPC_IdleAnimation)
	if self.Owner:GetEnemy() != nil then
		local enemy = self.Owner:GetEnemy()
		local dist = self.Owner:GetClosestPoint(enemy)
		
		// Default Behavior
		if self.Owner:CanPerformProcess() then
			if (dist > self.NPC_FireDistance_Stop) then
				self.Owner:ChaseEnemy()
			elseif (dist <= self.NPC_FireDistance_Stop) && enemy:Visible(self) then
				self.Owner:SetIdleAnimation(self.NPC_IdleAnimation)
				self.Owner:StopCompletely()
				self.Owner:FaceEnemy()
			else
				self.Owner:ChaseEnemy()
			end
		end
		
		// Determine Animations and Firing
		if dist <= self.NPC_FireDistance_Max then
			if (dist <= self.NPC_UseWalk_Distance) then
				self.NPC_UseAnimation = 1
				-- self.Owner:SetMovementAnimation(self.NPC_WalkAnimation)
				if self:Visible(enemy) && self.Owner:FindInCone(enemy,30) && self.Owner.ReloadingWeapon == false then
					self:CanFire(true)
				else
					self:CanFire(false)
				end
				if self.NPC_CanStrafe == true then
					if enemy:Visible(self.Owner) then
						local ang = self.Owner:GetAngles()
						local tgt = (enemy:GetPos() -self.Owner:GetPos()):Angle().y
						ang.y = math.ApproachAngle(ang.y,tgt,10)
						self.Owner:SetAngles(ang)
					end
				end
			elseif !self:Visible(enemy) then
				self:CanFire(false)
				self.NPC_UseAnimation = 2
				-- self.Owner:SetMovementAnimation(self.NPC_RunAnimation)
			end
		else
			self:CanFire(false)
			self.NPC_UseAnimation = 2
			-- self.Owner:SetMovementAnimation(self.NPC_RunAnimation)
		end
	else
		self.NPC_UseAnimation = 1
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:OnPrimaryAttack()
	self:NPC_FireGesture(self.NPC_FireAnimation)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:OnDeploy()
	self:NPC_FireGesture(self.NPC_EquipAnimation)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:OnReload()
	self:NPC_FireGesture(self.NPC_ReloadAnimation)
end