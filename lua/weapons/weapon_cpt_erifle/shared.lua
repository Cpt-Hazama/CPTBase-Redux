SWEP.PrintName		= "Electricity Cannon"
SWEP.HUDSlot		= 3
SWEP.HUDImportance 	= 3
SWEP.Author 		= "Cpt. Hazama"
SWEP.Category		= "CPTBase"
SWEP.ViewModelFOV	= 55
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/weapons/c_physcannon.mdl"
SWEP.WorldModel		= "models/weapons/w_physcannon.mdl"
SWEP.HoldType = "physgun"
SWEP.Base = "weapon_cpt_base"
SWEP.Spawnable = false
SWEP.AdminSpawnable = false
SWEP.UseHands = true

SWEP.DrawTime = false
SWEP.ReloadTime = false
SWEP.WeaponWeight = 18
SWEP.HasShells = false

SWEP.Primary.TotalShots = 1
SWEP.Primary.Spread = 5
SWEP.Primary.Tracer = 1
SWEP.Primary.Force = 8
SWEP.Primary.Damage = 9
SWEP.Primary.Delay = 6

SWEP.Primary.ClipSize		= 1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "defaultammo"
SWEP.NPCFireRate = 1

SWEP.MuzzleEffect = "cpt_muzzle_energy"
SWEP.MuzzleFlash_Color = Color(0,115,255)

SWEP.DrawAnimation = ACT_VM_DRAW
SWEP.IdleAnimation = ACT_VM_IDLE
SWEP.FireAnimation = ACT_VM_PRIMARYATTACK
SWEP.ReloadAnimation = ACT_VM_HOLSTER

SWEP.tbl_Sounds = {
	["DryFire"] = {"weapons/ar2/ar2_empty.wav"},
	["Charge"] = {"weapons/physcannon/physcannon_charge.wav"},
	["Fire"] = {"weapons/physcannon/superphys_launch3.wav"},
}
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:PrimaryAttack(ShootPos,ShootDir)
	if !self.Owner:IsNPC() then
		if self.IsReloading == true then return end
		if self.IsDrawing == true then return end
		if (self.Owner:WaterLevel() >= 3) then return end
		if (!self:CanPrimaryAttack()) then return end
		if self:Clip1() <= 0 && self.IsReloading == false then
			self:PlayWeaponSound("DryFire",75)
		end
	elseif self.Owner:IsNPC() then
		-- if CurTime() < self.NPC_NextFireT then return end
		if self.IsReloading == true then return end
	end
	if self.Owner:IsNPC() && self.Weapon:Clip1() <= 0 && self.Owner.ReloadingWeapon == false then
		self:NPC_Reload()
		return
	end
	self.IsFiring = true
	self.CanUseIdle = false
	timer.Simple(2.8,function()
		if IsValid(self) && self:OwnerUsingWeapon() then
			timer.Simple(0,function()
				if IsValid(self) && self:OwnerUsingWeapon() then
					self:PrimaryAttackCode(ShootPos,ShootDir)
				end
			end)
			timer.Simple(0.3,function()
				if IsValid(self) && self:OwnerUsingWeapon() then
					self:PrimaryAttackCode(ShootPos,ShootDir)
				end
			end)
			timer.Simple(0.6,function()
				if IsValid(self) && self:OwnerUsingWeapon() then
					self:PrimaryAttackCode(ShootPos,ShootDir)
				end
			end)
			timer.Simple(0.9,function()
				if IsValid(self) && self:OwnerUsingWeapon() then
					self:PrimaryAttackCode(ShootPos,ShootDir)
				end
			end)
			timer.Simple(1.2,function()
				if IsValid(self) && self:OwnerUsingWeapon() then
					self:PrimaryAttackCode(ShootPos,ShootDir)
				end
			end)
		end
	end)
	local oldclip = self:Clip1()
	self:AddClip1(-self.RemoveAmmoAmount)
	local newclip = self:Clip1()
	self:PlayWeaponSound("Charge",100)
	self.Weapon:SetNextPrimaryFire(CurTime() +self.Primary.Delay)
	if SERVER then
		self.NPC_NextFireT = CurTime() +self:GetNPCFireRate()
	end
	timer.Simple(self.Primary.Delay,function() if self:IsValid() then self.IsFiring = false self.CanUseIdle = true end end)
	timer.Simple(self.Primary.Delay +0.001,function() if self:IsValid() then self:DoIdleAnimation() end end)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:PrimaryAttackCode(ShootPos,ShootDir)
	if SERVER then
		local ang = self.Owner:GetAimVector():Angle()
		local ent = ents.Create("obj_cpt_shockfield")
		ent:SetPos(ShootPos || self:GetBulletPos())
		ent:SetAngles(self.Owner:GetAimVector():Angle())
		ent:SetOwner(self.Weapon:GetOwner())
		ent:Spawn()
		ent:SetDamage(38)
		ent:Activate()
		if self.Owner:IsPlayer() then
			ent:GetPhysicsObject():ApplyForceCenter(self.Owner:GetAimVector() *5000 +self.Owner:GetVelocity() +self.Owner:GetUp() *math.Rand(-self.Primary.Spread,self.Primary.Spread) +self.Owner:GetRight() *math.Rand(-self.Primary.Spread,self.Primary.Spread))
		else
			ent:GetPhysicsObject():ApplyForceCenter((self.Owner:GetEnemy():GetPos() -self.Owner:GetPos()) *5000 +self.Owner:GetUp() *math.Rand(-self.Primary.Spread,self.Primary.Spread) +self.Owner:GetRight() *math.Rand(-self.Primary.Spread,self.Primary.Spread))
		end
	end
	self:PlayWeaponSound("Fire",100)
	if self.Owner:IsPlayer() then
		if self.IgnoreRecoil != true then
			self.Owner:ViewPunch(Angle(-self.Primary.Force,math.random(-self.Primary.Force /2,self.Primary.Force /2),0))
		end
		self.Owner:SetAnimation(PLAYER_ATTACK1)
		local cnddmg = math.Round(self.Primary.Force/6)
		if cnddmg < 1 then
			cnddmg = 0.15
		end
		if self.WeaponCanBreak == true then
			self:DamageWeaponCondition(cnddmg)
		end
	end
	if self.Owner:IsPlayer() then
		self:DoFireAnimation()
	end
	self.Owner:MuzzleFlash()
	self:CreateMuzzleFlash()
	self:CreateShellCasings()
	self:OnPrimaryAttack(oldclip,newclip)
end