SWEP.PrintName		= "Admin Abuse 9000"
SWEP.HUDSlot = 3
SWEP.HUDImportance = 3
SWEP.Author 		= "Cpt. Hazama"
SWEP.Category		= "CPTBase"
SWEP.ViewModelFOV	= 55
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/weapons/cstrike/c_smg_p90.mdl"
SWEP.WorldModel		= "models/weapons/w_smg_p90.mdl"
SWEP.HoldType = "ar2"
SWEP.Base = "weapon_cpt_base"
SWEP.AdminSpawnable = true
SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.UseHands = true

SWEP.DrawTime = false
SWEP.ReloadTime = false
SWEP.WeaponWeight = 0
SWEP.Muzzle = "1"

SWEP.Primary.TotalShots = 15
SWEP.Primary.Spread = 0.012
SWEP.Primary.Tracer = 1
SWEP.Primary.Force = 5000
SWEP.Primary.Damage = 5000
SWEP.Primary.Delay = 0.08

SWEP.Primary.ClipSize		= 5000
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "defaultammo"
SWEP.WeaponCanBreak = false
SWEP.IgnoreRecoil = true
SWEP.NPCFireRate = 0.35
SWEP.tbl_NPCFireTimes = {0,0.1,0.2,0.3}

SWEP.DrawAnimation = ACT_VM_DRAW
SWEP.IdleAnimation = ACT_VM_IDLE
SWEP.FireAnimation = ACT_VM_PRIMARYATTACK
SWEP.ReloadAnimation = ACT_VM_RELOAD

SWEP.AdjustWorldModel = false
SWEP.WorldModelAdjust = {
	Pos = {Right = -4.3,Forward = -6.2,Up = 5},
	Ang = {Right = -10,Up = 180,Forward = 0}
}

SWEP.tbl_Sounds = {
	["DryFire"] = {"weapons/ar2/ar2_empty.wav"},
	["Fire"] = {"weapons/flaregun/fire.wav"},
}
---------------------------------------------------------------------------------------------------------------------------------------------
-- function SWEP:BeforeReload() self:SetWeaponHoldType("ar2") end
---------------------------------------------------------------------------------------------------------------------------------------------
-- function SWEP:FinishedReload() self:SetWeaponHoldType("crossbow") end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:OnInit()
	timer.Simple(0.02,function()
		self.Owner:SetHealth(self.Owner:Health() +9000)
		self.Owner:EmitSound("cptbase/9000.mp3")
	end)
	self.NextAdminRegenT = 0
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:OnThink()
	if CurTime() > self.NextAdminRegenT then
		self.Owner:SetHealth(self.Owner:Health() +150)
		self.NextAdminRegenT = CurTime() +5
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:FiredBullet(attacker,tr,dmginfo)
	local vel = self.Owner:GetVelocity()
	local velZ = vel.z
	vel = vel +self.Owner:GetForward() *-15
	vel.z = velZ
	self.Owner:SetLocalVelocity(vel)
	if tr.Hit then
		if IsValid(tr.Entity) then
			tr.Entity:Ignite(10,1)
			if tr.Entity:IsNPC() && (tr.Entity:GetClass() == "npc_helicopter") then
				tr.Entity:Remove()
			end
		end
		if math.random(1,50) == 1 then
			local explosion = ents.Create("env_explosion")
			explosion:SetPos(tr.HitPos)
			explosion:SetOwner(self.Owner)
			explosion:Spawn()
			explosion:SetKeyValue("iMagnitude","220")
			explosion:Fire("Explode",0,0)
		end
	end
end