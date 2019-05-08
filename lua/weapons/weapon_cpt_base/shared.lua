if !CPTBase then return end
-------------------------------------------------------------------------------------------------------------------
AddCSLuaFile("ai_translations.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("viewmodel.lua")
include("ai_translations.lua")
-- include("viewmodel.lua")
include("sh_anim.lua")

-- if SERVER then
	-- util.AddNetworkString("cpt_CModelshootpos")
	-- util.AddNetworkString("cpt_CModel")
-- end

SWEP.Author = "Cpt. Hazama"
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = ""
SWEP.HUDSlot = 1 -- The slot that it appears in the weapon select
SWEP.HUDImportance = 3 -- How far down it will be, leaving it at 3 is recommended
SWEP.Category		= "CPTBase"
SWEP.ViewModelFOV	= 70
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/error.mdl"
SWEP.WorldModel		= "models/error.mdl"
SWEP.AnimPrefix		= "python"
SWEP.Spawnable = false
SWEP.AdminSpawnable = false
-- SWEP.AdminOnly = true -- Enable to make it admin only
SWEP.UseLuaMovement = true -- Enables the Lua made idle/move animations
SWEP.IdleFPS = 0.7 -- The frame rate of the Lua idle animation
SWEP.LuaMovementScale_Forward = 0.0400
SWEP.LuaMovementScale_Right = 0.0084
SWEP.LuaMovementScale_Up = 0.022

SWEP.CanBeEnchanted = true
SWEP.EnchantmentCost = 10
SWEP.Enchantments = {
	dmg=true,
	recoil=true,
	ammo=true,
	spread=true,
	delay=true,
	cond=true
}

SWEP.StartingClips = 2
SWEP.AmmoNameTypes = "clips" -- clips, rounds, etc.
SWEP.DrawTime = false -- Leaving to false will auto-select the time
SWEP.ReloadTime = false -- Leaving to false will auto-select the time
SWEP.UseSingleReload = false -- If true, the weapon will be reloaded like a shotgun
SWEP.WeaponWeight = 0 -- The weight of the weapon. The heavier it is, the slower the player is
SWEP.WeaponCanBreak = true -- If set to true, the weapon quality will degrade over the course of action
SWEP.HasMuzzleFlash = true
SWEP.MuzzleEffect = "cpt_muzzle"
SWEP.Muzzle = "muzzle" -- The attachment name
SWEP.MuzzleFlash_Color = Color(255,93,0)
SWEP.MuzzleFlash_Brightness = 2
SWEP.MuzzleFlash_Distance = 150

SWEP.UsePhysicalBullets = false -- Use bullet entities instead of default bullets? (Note that this feature was discontinued a long time ago)
SWEP.PhysicalBulletSpawnRight = 2
SWEP.PhysicalBulletSpawnUp = -5
SWEP.PhyscialBulletDamageType = DMG_BULLET
SWEP.PhyscialBulletDamageForce = Vector(0,0,0)
SWEP.PhyscialBulletMass = 1
SWEP.PhyscialBulletGravity = false
SWEP.PhysicalBulletSpeed = 50000000

SWEP.HasShells = false
SWEP.ShellModel = "models/shells/shell_large.mdl"
SWEP.ShellTable = {
	Pos = {Right = 3,Forward = 0,Up = -0.8},
	Velocity = {Right = math.Rand(140,180),Up = math.Rand(40,60),Forward = 0}
}

SWEP.Primary.Volume = 78 -- Volume of the primary sound
SWEP.Primary.TotalShots = 1 -- Number of bullets that are fired
SWEP.Primary.Spread = 7 -- Spead of the bullets
SWEP.Primary.Tracer = 1 -- Basically, this is a math.random; the bullets have a X chance to be visible
SWEP.Primary.Force = 1 -- Physics force of the bullet (is ampliefied by the damage of the bullet)
SWEP.Primary.Damage = 5 -- Bullet damage amount
SWEP.Primary.Delay = 0.5 -- Delay between shots
SWEP.Primary.TracerEffect = "cpt_tracer"
SWEP.Primary.ClipSize		= 8 -- Starting clip
SWEP.Primary.DefaultClip	= 8 -- Amount you get when reloading
SWEP.Primary.Automatic		= false -- If true, holding down LMB will allow the user to fire non-stop
SWEP.Primary.Ammo			= "9×19mm" // Default CPTBase Ammo
SWEP.RemoveAmmoAmount = 1 -- Amount of ammo that is removed from the weapon's ammo type per shot
SWEP.IgnoreRecoil = false
SWEP.OverrideBulletPos = false -- Used to manually set the bullet spawn position
SWEP.NPCFireRate = 0.1 -- Rate at which NPCs can fire the weapon
SWEP.tbl_NPCFireTimes = {0} -- Timers for firing the weapon for NPCs
SWEP.NPC_EnemyFarDistance = 1350 -- NPC's enemy is too far, chase them down
SWEP.NPC_FireDistance = 2500 -- Distance that NPCs can fire
SWEP.NPC_FireDistanceStop = 500 -- Distance that the NPC can't move forward anymore
SWEP.NPC_FireDistanceMoveAway = 200 -- Distance until the NPC needs to move away from their enemy
SWEP.NPC_Spread = 7 -- NPC spread is different from the player
SWEP.NPC_CurrentReloadTime = 2 -- Reload time for NPCs
SWEP.NPC_AttackGestureSpeedOverride = false -- Set to a number to enable (Default is 1)
// These 2 variables are obsolete
-- SWEP.NPC_FireTime = 0 -- Shoot timer
-- SWEP.NPC_FireRateAmount = 1 -- How many times it runs the shoot code

SWEP.AdjustViewModel = false
SWEP.ViewModelAdjust = {
	Pos = {Right = 0,Forward = 0,Up = 0},
	Ang = {Right = 0,Up = 0,Forward = 0}
}

SWEP.AdjustWorldModel = false
SWEP.WorldModelAttachmentBone = "ValveBiped.Bip01_R_Hand"
SWEP.WorldModelAdjust = {
	Pos = {Right = 0,Forward = 0,Up = 0},
	Ang = {Right = 0,Up = 0,Forward = 0}
}

SWEP.HasIronsights = false
SWEP.Ironsights = {
	Pos = {Right = 0,Forward = 0,Up = 0},
	Ang = {Right = 0,Up = 0,Forward = 0}
}


SWEP.tbl_Animations = {}
SWEP.tbl_Sounds = {}

SWEP.Weight				= 5	-- Decides whether we should switch from/to this
SWEP.AutoSwitchTo		= false -- Auto switch to if we pick it up
SWEP.AutoSwitchFrom		= false -- Auto switch from if you pick up a better weapon
SWEP.CSMuzzleFlashes 	= false
SWEP.NextFireTime_NPC = 0
---------------------------------------------------------------------------------------------------------------------------------------------
-- net.Receive("cpt_CModelshootpos",function(len,pl)
	-- vec = net.ReadVector()
	-- ent = net.ReadEntity()
	-- ent:SetNWVector("cpt_CModel_MuzzlePos",vec)
-- end)
---------------------------------------------------------------------------------------------------------------------------------------------
-- net.Receive("cpt_CModel",function(len,pl)
	-- ent = net.ReadEntity()
	-- owner = net.ReadEntity()
	-- owner:SetNWEntity("cpt_CModel",ent)
-- end)
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:SetNPCIdleAnimation(anim)
	self.NPC_IdleAnimation = anim
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:SetNPCWalkAnimation(anim)
	self.NPC_WalkAnimation = anim
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:SetNPCRunAnimation(anim)
	self.NPC_RunAnimation = anim
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:SetNPCFireAnimation(anim)
	self.NPC_FireAnimation = anim
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:SetNPCReloadAnimation(anim)
	self.NPC_ReloadAnimation = anim
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:GetNPCIdleAnimation()
	return self.NPC_IdleAnimation
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:GetNPCWalkAnimation()
	return self.NPC_WalkAnimation
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:GetNPCRunAnimation()
	return self.NPC_RunAnimation
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:GetNPCFireAnimation()
	return self.NPC_FireAnimation
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:GetNPCReloadAnimation()
	return self.NPC_ReloadAnimation
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:AddClip1(amount)
	self.Weapon:SetClip1(self:Clip1() +amount)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:OnPrimaryAttack(oldclip,newclip) end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:SelectFromTable(tbl)
	if tbl == nil then return tbl end
	return tbl[math.random(1,#tbl)]
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:SoundCreate(snd,vol,pitch)
	-- return sound.Play(snd,self:GetPos(),vol,pitch,1)
	return self:EmitSound(snd,vol,pitch)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:AnimationLength(activity)
	return self:SequenceDuration(self:SelectWeightedSequence(activity))
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:NPC_FireGesture(gesture)
	if !self.Owner:IsNPC() then return end
	if !gesture then return end
	local gest = self.Owner:AddGestureSequence(self.Owner:LookupSequence(gesture))
	self.Owner:SetLayerPriority(gest,2)
	self.Owner:SetLayerPlaybackRate(gest,0.5)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:PlayWeaponSound(tbl,vol,pitch,usedot)
	if self.tbl_Sounds[tbl] == nil then return end
	local pitch = pitch or 100
	-- self.Weapon:EmitSound(Sound(self:SelectFromTable(self.tbl_Sounds[tbl])),vol,100 *GetConVarNumber("host_timescale"))
	-- if usedot == true then
		self.CurrentSound = self:SoundCreate(self:SelectFromTable(self.tbl_Sounds[tbl]),vol,pitch *GetConVarNumber("host_timescale"))
	-- else
		-- return self:CreatePlaySound(self:SelectFromTable(self.tbl_Sounds[tbl]),vol,pitch *GetConVarNumber("host_timescale"))
	-- end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:PlayWeaponSoundTimed(tbl,vol,time,usedot)
	if self.tbl_Sounds[tbl] == nil then return end
	timer.Simple(time,function()
		if self:IsValid() && self.Owner:IsValid() && self.Owner:GetActiveWeapon() == self then
			-- self.Weapon:EmitSound(Sound(self:SelectFromTable(self.tbl_Sounds[tbl])),vol,100 *GetConVarNumber("host_timescale"))
			-- if usedot == true then
				return self:SoundCreate(self:SelectFromTable(self.tbl_Sounds[tbl]),vol)
			-- else
				-- return self:CreatePlaySound(self:SelectFromTable(self.tbl_Sounds[tbl]),vol,pitch *GetConVarNumber("host_timescale"))
			-- end
		end
	end)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:GetViewModelPosition(pos,ang)
	local opos = pos *1
	if self.AdjustViewModel == true then
		if self:GetNWBool("cptbase_UseIronsights") == false then
			opos:Add(ang:Right() *(self.ViewModelAdjust.Pos.Right))
			opos:Add(ang:Forward() *(self.ViewModelAdjust.Pos.Forward))
			opos:Add(ang:Up() *(self.ViewModelAdjust.Pos.Up))
			pos:Add(ang:Right() *(self.ViewModelAdjust.Pos.Right))
			pos:Add(ang:Forward() *(self.ViewModelAdjust.Pos.Forward))
			pos:Add(ang:Up() *(self.ViewModelAdjust.Pos.Up))
			ang:RotateAroundAxis(ang:Right(),self.ViewModelAdjust.Ang.Right)
			ang:RotateAroundAxis(ang:Up(),self.ViewModelAdjust.Ang.Up)
			ang:RotateAroundAxis(ang:Forward(),self.ViewModelAdjust.Ang.Forward)
		elseif self:GetNWBool("cptbase_UseIronsights") == true then
			opos:Add(ang:Right() *(self.ViewModelAdjust.Pos.Right))
			opos:Add(ang:Forward() *(self.ViewModelAdjust.Pos.Forward))
			opos:Add(ang:Up() *(self.ViewModelAdjust.Pos.Up))
			pos:Add(ang:Right() *(self.ViewModelAdjust.Pos.Right))
			pos:Add(ang:Forward() *(self.ViewModelAdjust.Pos.Forward))
			pos:Add(ang:Up() *(self.ViewModelAdjust.Pos.Up))
			ang:RotateAroundAxis(ang:Right(),self.ViewModelAdjust.Ang.Right)
			ang:RotateAroundAxis(ang:Up(),self.ViewModelAdjust.Ang.Up)
			ang:RotateAroundAxis(ang:Forward(),self.ViewModelAdjust.Ang.Forward)
		end
	else
		if self:GetNWBool("cptbase_UseIronsights") == false then
			opos:Add(ang:Right() *0)
			opos:Add(ang:Forward() *0)
			opos:Add(ang:Up() *0)
			pos:Add(ang:Right() *0)
			pos:Add(ang:Forward() *0)
			pos:Add(ang:Up() *0)
			ang:RotateAroundAxis(ang:Right(),0)
			ang:RotateAroundAxis(ang:Up(),0)
			ang:RotateAroundAxis(ang:Forward(),0)
		elseif self:GetNWBool("cptbase_UseIronsights") == true then
			opos:Add(ang:Right() *(self.Ironsights.Pos.Right))
			opos:Add(ang:Forward() *(self.Ironsights.Pos.Forward))
			opos:Add(ang:Up() *(self.Ironsights.Pos.Up))
			pos:Add(ang:Right() *(self.Ironsights.Pos.Right))
			pos:Add(ang:Forward() *(self.Ironsights.Pos.Forward))
			pos:Add(ang:Up() *(self.Ironsights.Pos.Up))
			ang:RotateAroundAxis(ang:Right(),self.Ironsights.Ang.Right)
			ang:RotateAroundAxis(ang:Up(),self.Ironsights.Ang.Up)
			ang:RotateAroundAxis(ang:Forward(),self.Ironsights.Ang.Forward)
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:GetWorldModelPosition()
	if CLIENT then
		if self.Weapon:IsValid() && self.Owner:IsValid() then
			pos,ang = self.Owner:GetBonePosition(self.Owner:LookupBone(self.WorldModelAttachmentBone))
			ang:RotateAroundAxis(ang:Right(),self.WorldModelAdjust.Ang.Right)
			ang:RotateAroundAxis(ang:Up(),self.WorldModelAdjust.Ang.Up)
			ang:RotateAroundAxis(ang:Forward(),self.WorldModelAdjust.Ang.Forward)
			pos = pos +self.WorldModelAdjust.Pos.Right *ang:Right()
			pos = pos +self.WorldModelAdjust.Pos.Forward *ang:Forward()
			pos = pos +self.WorldModelAdjust.Pos.Up *ang:Up()
			return {pos=pos,ang=ang}
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:AcceptInput(name,entActivator,entCaller,data)
	return false
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:PlayWeaponSequence(seq,speed,loop)
	local anim = self.Owner:GetViewModel():LookupSequence(seq)
	self.Owner:GetViewModel():ResetSequence(anim)
	self.Owner:GetViewModel():ResetSequenceInfo()
	self.Owner:GetViewModel():SetPlaybackRate(speed)
	self.Owner:GetViewModel():SetCycle(loop)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:PlayThirdPersonAnim(anim)
	anim = anim || PLAYER_ATTACK1
	if !game.SinglePlayer() || self.Owner:IsNPC() then self.Owner:SetAnimation(anim); return end
	GAMEMODE:DoAnimationEvent(self.Owner,PLAYERANIMEVENT_ATTACK_PRIMARY)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:UseDefinedSequence(seq)
	return self.Weapon:SendWeaponAnim(self:GetSequenceInfo(self:GetSequenceID(seq)).activity)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:GetSequenceID(sequence)
	local tb = self:GetSequenceList()
	local i = 0
	for k,v in ipairs(tb) do
		if v == sequence then
			i = k; break
		end
	end
	return i
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:Equip(wepowner)
	if self.Owner:IsPlayer() then
		self.OriginalSpeed = self.Owner:GetWalkSpeed()
		self.OriginalRunSpeed = self.Owner:GetRunSpeed()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:OnDrop()
	return false
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:ShouldDropOnDie()
	return false
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:NPCShoot_Primary(ShootPos,ShootDir)
	-- if CurTime() > self.NextFireTime_NPC then
		-- for i = 1, self.NPC_FireRateAmount do
			-- timer.Simple(self.NPC_FireTime,function()
				-- if self:IsValid() && self.Owner:IsValid() then
					-- self:PrimaryAttack(ShootPos,ShootDir)
				-- end
			-- end)
		-- end
		-- self.NextFireTime_NPC = CurTime() +self.NPCFireRate
	-- end
	if CurTime() > self.NextFireTime_NPC then
		if table.Count(self.tbl_NPCFireTimes) > 0 then
			for _, v in ipairs(self.tbl_NPCFireTimes) do
				timer.Simple(v,function()
					if IsValid(self) && IsValid(self.Owner) then
						if self:Clip1() <= 0 then
							if !self.IsReloading then
								self:Reload()
								return
							end
						end
						self:PrimaryAttack(ShootPos,ShootDir)
					end
				end)
			end
		end
		self.NextFireTime_NPC = CurTime() +self.NPCFireRate
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:CanFire(canfire)
	if canfire == true then
		self.CanNPCFire = true
		self:NPCShoot_Primary(ShootPos,ShootDir)
	else
		self.CanNPCFire = false
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:SetWeaponSlot(hud_slot,hud_importance)
	self.Slot = hud_slot -1 // We'll look at it this way, slot 1 is physgun and slot 6 is toolgun, instead of 0 being physgun
	self.SlotPos = hud_importance
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:Initialize()
	-- self:SetNWVector("cpt_CModel_MuzzlePos",self:GetPos())
	-- self:SetNWEntity("cpt_CModel",self)
	self:SetNWBool("cptbase_UseIronsights",false)
	self:SetNWInt("CPTBase_WeaponCondition",100)
	self.Weapon:SetClip1(self.Primary.ClipSize)
	self.Primary.DefaultClip = self.Primary.ClipSize
	self.FixClip = self.Primary.DefaultClip
	if self.Owner:IsPlayer() then
		self.OriginalSpeed = self.Owner:GetWalkSpeed()
		self.OriginalRunSpeed = self.Owner:GetRunSpeed()
	end
	if self.Owner:IsNPC() then
		self.Owner.ReloadingWeapon = false
		hook.Add("Think",self,self.NPC_Think)
	end
	self:SetWeaponHoldType(self.HoldType)
	self:SetWeaponSlot(self.HUDSlot,self.HUDImportance)
	self.DefaultHoldType = self.HoldType
	self.CPTBase_Weapon = true
	self.IsFiring = false
	self.IsReloading = false
	self.IsDrawing = false
	self.CanUseIdle = true
	self.NextReloadHintT = 0
	self.NextFixWeaponT = 0
	self.NPC_NextFireT = 0
	self:SetWeaponCondition(100)
	self.WeaponConditionDamage = self.Primary.Force
	self.CanNPCFire = false
	self.LoopedSounds = {}
	self.CurrentSound = nil
	if SERVER then
		self:SetNPCMinBurst(30)
		self:SetNPCMaxBurst(30)
		self:SetNPCFireRate(self.NPCFireRate)
	end
	timer.Simple(0.01,function()
		if self:IsValid() && self.Owner:IsValid() && self.Owner:IsPlayer() then
			if SERVER then
				self.Owner:AddToAmmoCount(self.Primary.DefaultClip *self.StartingClips,self.Primary.Ammo)
			end
		end
	end)
	if self.Owner:IsPlayer() then
		local rClip = self.Owner:GetAmmoCount(self:GetPrimaryAmmoType())
		local clips = math.Round(rClip /self.Primary.DefaultClip)
		self.Owner:ChatPrint("You have " .. tostring(clips) .. " holstered " .. self.AmmoNameTypes .. " for this weapon")
	end
	-- if SERVER then
		if self.OnInit then self:OnInit() end
	-- end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:NPC_Think()
	if (CLIENT) then
		return
	end
	if !IsValid(self) then
		return
	end
	if !IsValid(self.Owner) then
		return
	end
	if !self.Owner.UseDefaultWeaponThink then
		return
	end
	self:OnThink_NPC()
	hook.Remove("Think",self)
	hook.Add("Think",self,self.NPC_Think)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:SetWeaponCondition(cnd)
	self.WeaponCondition = cnd
	if self.WeaponCondition > 100 then
		self.WeaponCondition = 100
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:DamageWeaponCondition(dmg)
	self:SetWeaponCondition(self.WeaponCondition -dmg)
	self:SetNWInt("CPTBase_WeaponCondition",self.WeaponCondition)
end
---------------------------------------------------------------------------------------------------------------------------------------------
-- function SWEP:OnInit() end
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
	self:PrimaryAttackCode(ShootPos,ShootDir)
	local oldclip = self:Clip1()
	self:AddClip1(-self.RemoveAmmoAmount)
	local newclip = self:Clip1()
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
	self:PlayWeaponSound("Fire",self.Primary.Volume)
	self.Weapon:SetNextPrimaryFire(CurTime() +self.Primary.Delay)
	if SERVER then
		self.NPC_NextFireT = CurTime() +self:GetNPCFireRate()
	end
	if self.Owner:IsPlayer() then
		self:DoFireAnimation()
	end
	self.Owner:MuzzleFlash()
	self:CreateMuzzleFlash()
	self:CreateShellCasings()
	self:OnPrimaryAttack(oldclip,newclip)
	if self.Owner:IsNPC() then
		self:OnPrimaryAttack_NPC()
	end
	timer.Simple(self.Primary.Delay,function() if self:IsValid() then self.IsFiring = false self.CanUseIdle = true end end)
	timer.Simple(self.Primary.Delay +0.001,function() if self:IsValid() then self:DoIdleAnimation() end end)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:DoFireAnimation()
	local anim = self.FireAnimation
	self:PlayWeaponAnimation(anim,1,0)
	self:PlayThirdPersonAnim(PLAYER_ATTACK1)
	if type(anim) == "number" then
		self.Weapon:SendWeaponAnim(anim)
	elseif type(anim) == "string" then
		self:PlayWeaponSequence(anim,1,0)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:PlayWeaponAnimation(anim,speed,loop)
	if type(anim) == "number" then
		return self.Weapon:SendWeaponAnim(anim)
	elseif type(anim) == "string" then
		return self:PlayWeaponSequence(anim,speed,loop)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:CreateShellCasings()
	if self.HasShells == false then return end
	if SERVER then
		local clip = ents.Create("prop_physics")
		clip:SetModel(Model(self.ShellModel))
		clip:SetPos(self:GetPos() +self:GetForward() *self.ShellTable.Pos.Forward +self:GetRight() *self.ShellTable.Pos.Right +self:GetUp() *self.ShellTable.Pos.Up)
		clip:SetAngles(self:GetAngles())
		clip:SetCollisionGroup(1)
		clip:Spawn()
		clip:SetCollisionGroup(1)
		clip:Activate()
		if clip:GetPhysicsObject():IsValid() then
			clip:GetPhysicsObject():SetVelocity((self:GetPos() -self:LocalToWorld(Vector(0,0,0))) +self:GetForward() *self.ShellTable.Velocity.Forward +self:GetRight() *self.ShellTable.Velocity.Right +self:GetUp() *self.ShellTable.Velocity.Up)
		end
		timer.Simple(math.Rand(5,8),function()
			if IsValid(clip) then
				clip:Remove()
			end
		end)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:CreateMuzzleFlash()
	if self.HasMuzzleFlash == false then return end
	local fx = EffectData()
	fx:SetEntity(self.Weapon)
	fx:SetOrigin(self:GetBulletPos())
	fx:SetNormal(self.Owner:GetAimVector())
	fx:SetAttachment(self.Weapon:LookupAttachment(self.Muzzle))
	util.Effect(self.MuzzleEffect,fx)
	if SERVER then
		local fx_light = ents.Create("light_dynamic")
		fx_light:SetKeyValue("brightness",self.MuzzleFlash_Brightness)
		fx_light:SetKeyValue("distance",self.MuzzleFlash_Distance)
		if self.Weapon:GetAttachment(1) != nil then
			fx_light:SetLocalPos(self.Weapon:GetAttachment(1).Pos)
		else
			fx_light:SetLocalPos(self:GetBulletPos())
		end
		fx_light:Fire("Color",self.MuzzleFlash_Color.r .. " " .. self.MuzzleFlash_Color.g .. " " .. self.MuzzleFlash_Color.b)
		fx_light:SetParent(self)
		fx_light:Spawn()
		fx_light:Activate()
		fx_light:Fire("TurnOn","",0)
		fx_light:Fire("Kill","",0.1)
		self:DeleteOnRemove(fx_light)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:OverrideBulletPosition()
	return self:GetAttachment(1).Pos
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:GetBulletPos()
	if self.OverrideBulletPos == true && self.Owner:IsNPC() then
		return self:OverrideBulletPosition()
	end
	if self.ExtraViewModel == nil then
		return self.Owner:GetShootPos()
	else
		if self:GetNWVector("cpt_CModelshootpos") == nil then
			return self.Owner:GetShootPos()
		else
			return self:GetNWVector("cpt_CModelshootpos")
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:PrimaryAttackCode(ShootPos,ShootDir)
	if self.UsePhysicalBullets == false then
		local bullet = {}
		bullet.Num = self.Primary.TotalShots
		bullet.Src = self:GetBulletPos()
		if self.Owner:IsNPC() then
			local aimPos = self.Owner:FindHeadPosition(self.Owner:GetEnemy())
			if math.random(1,math.random(2,3)) == 1 then
				aimPos = self.Owner:FindCenter(self.Owner:GetEnemy())
				-- self:PlayerChat("body")
			-- else
				-- self:PlayerChat("head")
			end
			local npcspread = self.Primary.Spread
			if self.NPC_Spread != nil then
				npcspread = self.NPC_Spread
			end
			for i = 1,self.Primary.TotalShots do
				if self.Owner.IsPossessed then
					bullet.Dir = (((self.Owner:Possess_AimTarget()) -self:GetBulletPos()) +self:GetUp() *math.Rand(-npcspread,npcspread) +self:GetRight() *math.Rand(-npcspread,npcspread))
				else
					if IsValid(self.Owner:GetEnemy()) then
						bullet.Dir = (((aimPos) -self:GetBulletPos()) +self:GetUp() *math.Rand(-npcspread,npcspread) +self:GetRight() *math.Rand(-npcspread,npcspread))
					end
				end
			end
		else
			bullet.Dir = self.Owner:GetAimVector()
		end
		if self.Owner:IsNPC() then
			local npcspread = self.Primary.Spread
			if self.NPC_Spread != nil then
				npcspread = self.NPC_Spread
			end
			bullet.Spread = Vector(npcspread,npcspread,0)
		else
			bullet.Spread = Vector(self.Primary.Spread,self.Primary.Spread,0)
		end
		bullet.Tracer = self.Primary.Tracer
		if self.Owner:IsPlayer() && self.Primary.TracerEffect != false then
			bullet.TracerName = self.Primary.TracerEffect
		end
		bullet.Force = self.Primary.Force
		local dif = GetConVarNumber("cpt_aidifficulty")
		local dmg = math.Round(self.Primary.Damage *(self.WeaponCondition /100))
		local finaldmg
		if self.Owner:IsNPC() then
			finaldmg = AdaptCPTBaseDamage(dmg)
		else
			finaldmg = dmg
		end
		bullet.Damage = finaldmg
		bullet.Callback = function(attacker,tr,dmginfo)
			self:FiredBullet(attacker,tr,dmginfo)
			self:ChangeNPCDamage(attacker,tr,dmginfo)
		end
		bullet.AmmoType = self.Primary.Ammo
		self.Owner:FireBullets(bullet)
	else
		if SERVER then
			for i = 1, self.Primary.TotalShots do
				local ang = self.Owner:GetAimVector():Angle()
				local ent = ents.Create("obj_cpt_bullet")
				ent:SetPos(ShootPos || self:GetBulletPos() +ang:Right() *self.PhysicalBulletSpawnRight +ang:Up() *self.PhysicalBulletSpawnUp)
				ent:SetAngles(self.Owner:GetAimVector():Angle())
				ent:SetOwner(self.Weapon:GetOwner())
				ent:SetBulletMass(self.PhyscialBulletMass,self.PhyscialBulletGravity)
				ent:SetDamage(self.Primary.Damage,self.PhyscialBulletDamageType,self.PhyscialBulletDamageForce)
				ent:Spawn()
				ent:SetDamage(self.Primary.Damage,self.PhyscialBulletDamageType,self.PhyscialBulletDamageForce)
				ent:SetBulletMass(self.PhyscialBulletMass,self.PhyscialBulletGravity)
				ent:Activate()
				if self.Owner:IsPlayer() then
					ent:GetPhysicsObject():ApplyForceCenter(self.Owner:GetAimVector() *self.PhysicalBulletSpeed +self.Owner:GetVelocity() +self.Owner:GetUp() *math.Rand(-self.Primary.Spread,self.Primary.Spread) +self.Owner:GetRight() *math.Rand(-self.Primary.Spread,self.Primary.Spread))
				else
					ent:GetPhysicsObject():ApplyForceCenter((self.Owner:GetEnemy():GetPos() -self.Owner:GetPos()) *self.PhysicalBulletSpeed +self.Owner:GetUp() *math.Rand(-self.Primary.Spread,self.Primary.Spread) +self.Owner:GetRight() *math.Rand(-self.Primary.Spread,self.Primary.Spread))
				end
				ent.InitialVelocity = self.Owner:GetAimVector() *self.PhysicalBulletSpeed +self.Owner:GetVelocity() +self.Owner:GetUp() *math.Rand(-self.Primary.Spread,self.Primary.Spread) +self.Owner:GetRight() *math.Rand(-self.Primary.Spread,self.Primary.Spread)
			end
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:FiredBullet(attacker,tr,dmginfo) end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:ChangeNPCDamage(attacker,tr,dmginfo)
	if IsValid(self.Owner) && self.Owner:IsNPC() && IsValid(tr.Entity) then
		if self.Owner:Disposition(tr.Entity) == D_LI || self.Owner:Disposition(tr.Entity) == D_NU then
			dmginfo:SetDamage(0)
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:SecondaryAttack()
	if self.HasIronsights == false then return false end
	if self.IsFiring == false && self:GetNWBool("cptbase_UseIronsights") == false then
		self:SetNWBool("cptbase_UseIronsights",true)
	else
		self:SetNWBool("cptbase_UseIronsights",false)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:OnThink_NPC()
	self.Owner.OverrideWalkAnimation = self.NPC_WalkAnimation
	self.Owner.OverrideRunAnimation = self.NPC_RunAnimation
	self.Owner:SetIdleAnimation(self.NPC_IdleAnimation)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:OnPrimaryAttack_NPC()
	if self.Owner:IsNPC() && self.NPC_FireAnimation != nil then
		self:BeforePrimaryAttack_NPC()
		local speed = 1
		if self.DefaultHoldType == "pistol" then
			speed = 0.5
		end
		if self.NPC_AttackGestureSpeedOverride != false then
			speed = self.NPC_AttackGestureSpeedOverride
		end
		self.Owner:PlayNPCGesture(self.NPC_FireAnimation,2,speed)
		self:AfterPrimaryAttack_NPC()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:OnReload_NPC()
	if self.Owner:IsNPC() && self.NPC_ReloadAnimation != nil then
		self.Owner:PlayNPCGesture(self.NPC_ReloadAnimation,2,self.ReloadSpeed)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:BeforePrimaryAttack_NPC() end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:AfterPrimaryAttack_NPC() end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:Think()
	-- print(self:GetNWEntity("cpt_CModel"))
	-- print(self:GetNWEntity("cpt_CModel"):LookupAttachment("muzzle"))
	self:WeaponConditionThink()
	self:OnThink()
	-- if self.Owner:IsNPC() then
		-- self:OnThink_NPC()
	-- end
	if CLIENT then
		if self.AdjustWorldModel == true then
			if self.Weapon:IsValid() && self.Owner:IsValid() then
				self:SetPos(self:GetWorldModelPosition().pos)
				self:SetAngles(self:GetWorldModelPosition().ang)
			end
		end
	end
	if self.HoldType != self.DefaultHoldType then
		self:SetWeaponHoldType(self.HoldType)
	end
	if self.Primary.DefaultClip != self.FixClip then
		self.Primary.DefaultClip = self.FixClip
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:DoAFTMChat(text)
	if file.Exists("lua/autorun/aftm_playerhud.lua","GAME") then
		self.Owner:aftmSendDisplayMessage(text)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:WeaponConditionThink()
	if self.WeaponCondition <= 50 && self.WeaponCondition > 25 then
		if CurTime() > self.NextFixWeaponT then
			self.Owner:ChatPrint("Hint: This weapon's condition is low, you should repair it soon.")
			self:DoAFTMChat("checkweapon")
			self.NextFixWeaponT = CurTime() +math.random(24,50)
		end
	elseif self.WeaponCondition <= 24 && self.WeaponCondition > 0 then
		if CurTime() > self.NextFixWeaponT then
			self.Owner:ChatPrint("Hint: This weapon is about to break, you need to repair it.")
			self:DoAFTMChat("checklowweapon")
			self.NextFixWeaponT = CurTime() +math.random(24,50)
		end
	end
	if self.WeaponCondition <= 0 then
		self.Owner:ChatPrint("Hint: This weapon has broken.")
		self:DoAFTMChat("brokeweapon")
		self:PlayerSpeeds("reset")
		self:EmitSound(Sound("cptbase/wpn_break0" .. math.random(1,2) .. ".wav"),70,100)
		self.Owner:DropWeapon(self)
		self:Remove()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:EnhanceWeapon()
	if self.CanBeEnhanced then return end
	local enhanceChance = 0
	for _,v in pairs(self.Enchantments) do
		if v == true then
			enhanceChance = enhanceChance +1
		end
	end
	local enhancement = self.Enchantments[math.random(1,enhanceChance)]
/*
	dmg=true,
	recoil=true,
	ammo=true,
	spread=true,
	delay=true,
	cond=true
*/
	print(enhancement)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:OnThink() end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:DoIdleAnimation()
	if self.IsFiring == false && self.IsReloading == false && self.CanUseIdle == true then
		-- self.Weapon:SendWeaponAnim(self.IdleAnimation)
		local anim = self.IdleAnimation
		if type(anim) == "number" then
			self.Weapon:SendWeaponAnim(anim)
		elseif type(anim) == "string" then
			self:PlayWeaponSequence(anim,1,1)
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:NPC_Reload()
	if self.Owner.ReloadingWeapon == false then
		self.Owner.ReloadingWeapon = true
		self:ReloadSounds()
		self:OnReload()
		if self.Owner:IsNPC() then
			self:OnReload_NPC()
		end
		-- self.Owner:StopCompletely()
		if self.Owner.ForceReloadAnimation == true && self.Owner.tbl_Animations["Reload"] != nil then
			self.Owner:PlayAnimation("Reload")
		end
		local reloadtime = self.NPC_CurrentReloadTime
		timer.Simple(reloadtime,function()
			if self:IsValid() && self.Owner:IsValid() then
				self.Owner.ReloadingWeapon = false
				self:SetClip1(self.Primary.DefaultClip)
			end
		end)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:BeforeReload() end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:OnReload() end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:FinishedReload() end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:Reload()
	if self.Owner:IsNPC() then self:NPC_Reload() return end
	if self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0 then return end
	-- if !self.Owner:KeyDown(IN_RELOAD) then return end
	if self.Owner:KeyDown(IN_USE) then return end
	if self:Clip1() == self.Primary.DefaultClip then return end
	if self.IsFiring == false && self.IsReloading == false then
		self:BeforeReload()
		self.IsReloading = true
		self.CanUseIdle = false
		self:ReloadSounds()
		self:OnReload()
		local reloadtime = self:DoReloadAnimation() // Deal with it
		if self.UseSingleReload == true then
			if CurTime() > self.NextReloadHintT then
				self.Owner:ChatPrint("Hint: This weapon uses a pump action reload. Hold down your reload key to cycle reloading. Let go at any point to stop.")
				self.NextReloadHintT = CurTime() +math.random(50,100)
			end
			timer.Simple(reloadtime,function()
				if self:IsValid() then
					self.Owner:RemoveAmmo(1,self.Primary.Ammo)
					self:SetClip1(self:Clip1() +1)
					self.CanUseIdle = true
					self.IsReloading = false
					self:FinishedReload()
				end
			end)
		else
			timer.Simple(reloadtime,function()
				if self:IsValid() then
					local rClip = self.Owner:GetAmmoCount(self:GetPrimaryAmmoType())
					if rClip < self.Primary.DefaultClip then
						self:SetClip1(rClip)
					else
						self:SetClip1(self.Primary.DefaultClip)
					end
					self.Owner:RemoveAmmo(self.Primary.DefaultClip,self.Primary.Ammo)
					self.CanUseIdle = true
					self.IsReloading = false
					self:FinishedReload()
				end
			end)
		end
		timer.Simple(reloadtime +0.001,function() if self:IsValid() then self:DoIdleAnimation() end end)
		self.Weapon:SetNextPrimaryFire(reloadtime)
	end
	return true
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:DoReloadAnimation()
	local reloadtime = self.ReloadTime
	local anim = self.ReloadAnimation
	if type(anim) == "number" then
		self.Weapon:SendWeaponAnim(anim)
	elseif type(anim) == "string" then
		self:PlayWeaponSequence(anim,1,0)
	end
	if reloadtime == false then
		if type(anim) == "number" then
			reloadtime = self.Weapon:AnimationLength(anim)
		end
	end
	self.Owner:SetAnimation(PLAYER_RELOAD)
	return reloadtime
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:ReloadSounds()
	self:PlayWeaponSound("Reload",75)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:FireAnimationEvent(pos,ang,event,options)
	if self:CustomEvents(pos,ang,event,options) then
		return true
	end
	if event == 21 || event == 22 || event == 5001 || event == 5003 then -- Disable event muzzle flashes
		return true
	end
	if event == 20 || event == 6001 then -- Disable bullet shells
		return true
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:CustomEvents(pos,ang,event,options) end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:PlayerSpeeds(set)
	if set == "setup" then
		if self.Owner:IsPlayer() then
			self.Owner:SetWalkSpeed(self.OriginalSpeed -self.WeaponWeight)
			self.Owner:SetRunSpeed(self.OriginalRunSpeed -self.WeaponWeight)
		end
	elseif set == "reset" then
		if self.Owner:IsPlayer() then
			self.Owner:SetWalkSpeed(self.OriginalSpeed)
			self.Owner:SetRunSpeed(self.OriginalRunSpeed)
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:Deploy()
	if SERVER then self:PlayWeaponSound("Equip",70) end
	self.CanUseIdle = false
	self.IsDrawing = true
	if self.Owner:IsPlayer() then
		self.OriginalSpeed = self.Owner:GetWalkSpeed()
		self.OriginalRunSpeed = self.Owner:GetRunSpeed()
	end
	self:PlayerSpeeds("setup")
	-- self.Weapon:SendWeaponAnim(self.DrawAnimation)
	local anim = self.DrawAnimation
	if anim != nil then
		if type(anim) == "number" then
			self.Weapon:SendWeaponAnim(anim)
		elseif type(anim) == "string" then
			self:PlayWeaponSequence(anim,1,0)
		end
		self:OnDeploy()
		local drawtime = self.DrawTime
		if drawtime == false then
			drawtime = self.Weapon:AnimationLength(anim)
		end
		timer.Simple(drawtime,function() if self:IsValid() then self.CanUseIdle = true self.IsDrawing = false end end)
		timer.Simple(drawtime +0.001,function() if self:IsValid() then self:DoIdleAnimation() end end)
		self.Weapon:SetNextPrimaryFire(drawtime)
	else
		self:DoIdleAnimation()
		self.Weapon:SetNextPrimaryFire(CurTime())
	end
	return true
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:GetCapabilities()
	return bit.bor(CAP_WEAPON_RANGE_ATTACK1,CAP_INNATE_RANGE_ATTACK1,CAP_WEAPON_RANGE_ATTACK2,CAP_INNATE_RANGE_ATTACK2)
end

function SWEP:Holster(wep)
	if IsValid(self._CModel) then self._CModel:Remove() end
	self:PlayerSpeeds("reset")
	self:StopParticles()
	if self.CurrentSound != nil then
		self.CurrentSound:Stop()
	end
	if self.LoopedSounds != nil then
		for k,v in pairs(self.LoopedSounds) do
			v:Stop()
		end
	end
	self:OnHolster()
	return true
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:OnHolster() end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:OnDeploy() end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:OnRemovedSelf() end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:OnRemove()
	self:PlayerSpeeds("reset")
	self:StopParticles()
	if self.CurrentSound != nil then
		self.CurrentSound:Stop()
	end
	if self.LoopedSounds != nil then
		for k,v in pairs(self.LoopedSounds) do
			v:Stop()
		end
	end
	self:OnRemovedSelf()
end