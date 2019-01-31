	-- Magic Stuff --
SWEP.MagickaCost = 0
SWEP.CheckMagicka = true
SWEP.SpellDelay = 1
SWEP.SpellEffectDelay = 0.5 -- Subtracts from SpellDelay

	-- SWEP Stuff --
SWEP.PrintName		= "Spell Base"
SWEP.HUDSlot = 5
SWEP.HUDImportance = 3
SWEP.Author 		= "Cpt. Hazama"
-- SWEP.Category		= "CPTBase - Spells"
SWEP.ViewModelFOV	= 90
SWEP.ViewModelFlip	= true
SWEP.ViewModel		= "models/cpthazama/cptbase/spell.mdl"
SWEP.WorldModel		= ""
SWEP.HoldType = "normal"
SWEP.Base = "weapon_cpt_base"
SWEP.AdminSpawnable = true
SWEP.Spawnable = true
SWEP.UseHands = true

SWEP.DrawTime = false
SWEP.ReloadTime = false
SWEP.WeaponWeight = 0

SWEP.Primary.TotalShots = 15
SWEP.Primary.Spread = 0.012
SWEP.Primary.Tracer = 1
SWEP.Primary.Force = 5000
SWEP.Primary.Damage = 5000
SWEP.Primary.Delay = 1

SWEP.Primary.ClipSize		= 1
SWEP.Primary.Automatic		= false
SWEP.WeaponCanBreak = false
SWEP.IgnoreRecoil = true

SWEP.IdleAnimation = ACT_VM_IDLE
SWEP.FireAnimation = ACT_VM_PRIMARYATTACK_1
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:PrimaryAttack(ShootPos,ShootDir)
	-- if self.IsDrawing == true then return end
	-- if (!self:CanPrimaryAttack()) then return end
	if self.CheckMagicka && self.Owner:GetNWInt("CPTBase_Magicka") < self.MagickaCost then self.Owner:ChatPrint("Not enough mana! *Required = " .. tostring(self.MagickaCost) .. " | Current: " .. tostring(self.Owner:GetNWInt("CPTBase_Magicka")) .. "/" .. tostring(self.Owner:GetNWInt("CPTBase_MaxMagicka")) .. "*") return end
	self.IsFiring = true
	self.CanUseIdle = false
	timer.Simple(self.SpellDelay -self.SpellEffectDelay,function()
		if IsValid(self) && IsValid(self.Owner) then
			self:PrimaryAttackCode(ShootPos,ShootDir)
		end
	end)
	self:PlayWeaponSound("Fire",85)
	self.Weapon:SetNextPrimaryFire(CurTime() +self.SpellDelay)
	if self.Owner:IsPlayer() then
		self:DoFireAnimation()
	end
	local oldclip = self.Owner:GetNWInt("CPTBase_Magicka")
	self.Owner:SetNWInt("CPTBase_Magicka",self.Owner:GetNWInt("CPTBase_Magicka") -self.MagickaCost)
	local newclip = self.Owner:GetNWInt("CPTBase_Magicka")
	self:OnPrimaryAttack(oldclip,newclip)
	timer.Simple(self.SpellDelay,function() if self:IsValid() then self.IsFiring = false self.CanUseIdle = true end end)
	timer.Simple(self.SpellDelay +0.001,function() if self:IsValid() then self:DoIdleAnimation() end end)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:CreateSummon(pos,ent)
	local ent = ents.Create(ent)
	ent:SetClearPos(pos)
	ent:SetAngles(Angle(0,self.Owner:GetAngles().y,self.Owner:GetAngles().r))
	ent:SetSummonedByPlayer(self.Owner)
	ent:Spawn()
	ent:Activate()
	ent:SetSummonedByPlayer(self.Owner)
	local efm = ents.Create("cpt_effect_manager")
	efm:SetEffectTime(60)
	efm:SetEffectedEntity(ent)
	efm:SetEffectType("cpthazama/effect_summon")
	efm:Spawn()
	timer.Simple(55,function()
		if IsValid(ent) then
			ent:SetColor(Color(255,255,255,10))
		end
	end)
	timer.Simple(60,function()
		if IsValid(ent) then
			ent:Remove()
		end
	end)
end