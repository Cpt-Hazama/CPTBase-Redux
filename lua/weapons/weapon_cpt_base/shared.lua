AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("viewmodel.lua")
include("ai_translations.lua")
include("sh_anim.lua")

SWEP.Author = "Cpt. Hazama"
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = ""
SWEP.Category		= "CPTBase"
SWEP.ViewModelFOV	= 70
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/error.mdl"
SWEP.WorldModel		= "models/error.mdl"
SWEP.AnimPrefix		= "python"
SWEP.Spawnable = false
SWEP.AdminSpawnable = false
SWEP.UseLuaMovement = true
SWEP.LuaIdleScale = 1

SWEP.DrawTime = 0.4
SWEP.ReloadTime = 1
SWEP.UseSingleReload = false
SWEP.WeaponWeight = 0
SWEP.MuzzleEffect = "cpt_muzzle"
SWEP.Muzzle = "muzzle"
SWEP.WeaponCanBreak = true

SWEP.Primary.TotalShots = 1
SWEP.Primary.Spread = 7
SWEP.Primary.Tracer = 1
SWEP.Primary.Force = 5
SWEP.Primary.Damage = 5
SWEP.Primary.Delay = 0.5
SWEP.Primary.TracerEffect = "cpt_tracer"
SWEP.RemoveAmmoAmount = 1

SWEP.Primary.ClipSize		= 8
SWEP.Primary.DefaultClip	= 8
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "9×19mm" // Default CPTBase Ammo
SWEP.NPCFireRate = 0.1

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

SWEP.tbl_Animations = {}
SWEP.tbl_Sounds = {}

SWEP.Weight				= 5			// Decides whether we should switch from/to this
SWEP.AutoSwitchTo		= false		// Auto switch to if we pick it up
SWEP.AutoSwitchFrom		= false		// Auto switch from if you pick up a better weapon

net.Receive("cpt_CModelshootpos",function(len,pl)
	vec = net.ReadVector()
	ent = net.ReadEntity()
	ent:SetNWVector("cpt_CModel_MuzzlePos",vec)
end)

net.Receive("cpt_CModel",function(len,pl)
	ent = net.ReadEntity()
	ent:SetNWEntity("cpt_CModel",vec)
end)

function SWEP:AddClip1(amount)
	self.Weapon:SetClip1(self:Clip1() +amount)
end

function SWEP:OnPrimaryAttack() end

function SWEP:SelectFromTable(tbl)
	if tbl == nil then return tbl end
	return tbl[math.random(1,#tbl)]
end

function SWEP:SoundCreate(snd,vol,pitch)
	return sound.Play(snd,self:GetPos(),vol,pitch,1)
end

function SWEP:AnimationLength(activity)
	return self:SequenceDuration(self:SelectWeightedSequence(activity))
end

function SWEP:NPC_FireGesture(gesture)
	local gest = self.Owner:AddGestureSequence(self.Owner:LookupSequence(gesture))
	self.Owner:SetLayerPriority(gest,2)
	self.Owner:SetLayerPlaybackRate(gest,0.5)
end

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

function SWEP:GetViewModelPosition(pos,ang)
	local opos = pos *1
	if self.AdjustViewModel == true then
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
end

function SWEP:GetWorldModelPosition()
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

function SWEP:AcceptInput(name,entActivator,entCaller,data)
	return false
end

function SWEP:PlayWeaponSequence(seq,speed,loop)
	local anim = self.Owner:GetViewModel():LookupSequence(seq)
	self.Owner:GetViewModel():ResetSequence(anim)
	self.Owner:GetViewModel():ResetSequenceInfo()
	self.Owner:GetViewModel():SetPlaybackRate(speed)
	self.Owner:GetViewModel():SetCycle(loop)
end

function SWEP:PlayThirdPersonAnim(anim)
	anim = anim || PLAYER_ATTACK1
	if !game.SinglePlayer() || self.Owner:IsNPC() then self.Owner:SetAnimation(anim); return end
	GAMEMODE:DoAnimationEvent(self.Owner,PLAYERANIMEVENT_ATTACK_PRIMARY)
end

function SWEP:UseDefinedSequence(seq)
	return self.Weapon:SendWeaponAnim(self:GetSequenceInfo(self:GetSequenceID(seq)).activity)
end

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

function SWEP:Equip(wepowner)
	if self.Owner:IsPlayer() then
		self.OriginalSpeed = self.Owner:GetWalkSpeed()
		self.OriginalRunSpeed = self.Owner:GetRunSpeed()
	end
end

function SWEP:OnDrop()
	return false
end

function SWEP:ShouldDropOnDie()
	return false
end

function SWEP:NPCShoot_Primary(ShootPos,ShootDir)
	self:PrimaryAttack(ShootPos,ShootDir)
end

function SWEP:CanFire(canfire)
	if canfire == true then
		self.CanNPCFire = true
		self:NPCShoot_Primary(ShootPos,ShootDir)
	else
		self.CanNPCFire = false
	end
end

function SWEP:Initialize()
	self:SetNWVector("cpt_CModel_MuzzlePos",self:GetPos())
	self:SetNWEntity("cpt_CModel",self)
	self.Weapon:SetClip1(self.Primary.ClipSize)
	self.Primary.DefaultClip = self.Primary.ClipSize
	self.FixClip = self.Primary.DefaultClip
	if self.Owner:IsPlayer() then
		self.OriginalSpeed = self.Owner:GetWalkSpeed()
		self.OriginalRunSpeed = self.Owner:GetRunSpeed()
	end
	if self.Owner:IsNPC() then
		self.Owner.ReloadingWeapon = false
	end
	self:SetWeaponHoldType(self.HoldType)
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
				self.Owner:AddToAmmoCount(self.Primary.DefaultClip,self.Primary.Ammo)
			end
		end
	end)
	self:OnInit()
end

function SWEP:SetWeaponCondition(cnd)
	self.WeaponCondition = cnd
	if self.WeaponCondition > 100 then
		self.WeaponCondition = 100
	end
end

function SWEP:DamageWeaponCondition(dmg)
	self:SetWeaponCondition(self.WeaponCondition -dmg)
end

function SWEP:OnInit() end

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
		if CurTime() < self.NPC_NextFireT then return end
	end
	if self.Owner:IsNPC() && self.Weapon:Clip1() <= 0 && self.Owner.ReloadingWeapon == false then
		self:NPC_Reload()
		return
	end
	self.IsFiring = true
	self.CanUseIdle = false
	self:PrimaryAttackCode(ShootPos,ShootDir)
	self:AddClip1(-self.RemoveAmmoAmount)
	if self.Owner:IsPlayer() then
		self.Owner:ViewPunch(Angle(-self.Primary.Force,math.random(-self.Primary.Force /2,self.Primary.Force /2),0))
		self.Owner:SetAnimation(PLAYER_ATTACK1)
		local cnddmg = math.Round(self.Primary.Force/6)
		if cnddmg < 1 then
			cnddmg = 0.15
		end
		if self.WeaponCanBreak == true then
			self:DamageWeaponCondition(cnddmg)
		end
	end
	self:PlayWeaponSound("Fire",100)
	self.Weapon:SetNextPrimaryFire(CurTime() +self.Primary.Delay)
	if SERVER then
		self.NPC_NextFireT = CurTime() +self:GetNPCFireRate()
	end
	if self.Owner:IsPlayer() then
		local anim = self.FireAnimation
		self:PlayWeaponAnimation(self.FireAnimation,1,0)
		self:PlayThirdPersonAnim(PLAYER_ATTACK1)
		if type(anim) == "number" then
			self.Weapon:SendWeaponAnim(anim)
		elseif type(anim) == "string" then
			self:PlayWeaponSequence(anim,1,0)
		end
	end
	self.Owner:MuzzleFlash()
	self:CreateMuzzleFlash()
	self:OnPrimaryAttack()
	timer.Simple(self.Primary.Delay,function() if self:IsValid() then self.IsFiring = false self.CanUseIdle = true end end)
	timer.Simple(self.Primary.Delay +0.001,function() if self:IsValid() then self:DoIdleAnimation() end end)
end

function SWEP:CreateMuzzleFlash()
	local fx = EffectData()
	fx:SetEntity(self.Weapon)
	fx:SetOrigin(self:GetBulletPos())
	fx:SetNormal(self.Owner:GetAimVector())
	fx:SetAttachment(self.Weapon:LookupAttachment(self.Muzzle))
	util.Effect(self.MuzzleEffect,fx)
end

function SWEP:GetBulletPos()
	if self.ExtraViewModel == nil then
		return self.Owner:GetShootPos()
	else
		if self:GetNWVector("cpt_CModel_MuzzlePos") == nil then
			return self.Owner:GetShootPos()
		else
			return self:GetNWVector("cpt_CModel_MuzzlePos")
		end
	end
end

function SWEP:PrimaryAttackCode(ShootPos,ShootDir)
	-- if CLIENT then return end
	-- if SERVER then
		local bullet = {}
		bullet.Num = self.Primary.TotalShots
		bullet.Src = self:GetBulletPos()
		bullet.Dir = self.Owner:GetAimVector()
		bullet.Spread = Vector(self.Primary.Spread,self.Primary.Spread,0)
		bullet.Tracer = self.Primary.Tracer
		bullet.TracerName = self.Primary.TracerEffect
		bullet.Force = self.Primary.Force
		bullet.Damage = math.Round(self.Primary.Damage *(self.WeaponCondition /100))
		bullet.Callback = function(attacker,tr,dmginfo)
			self:FiredBullet(attacker,tr,dmginfo)
		end
		bullet.AmmoType = self.Primary.Ammo
		self.Owner:FireBullets(bullet)
	-- end
end

function SWEP:FiredBullet(attacker,tr,dmginfo) end

function SWEP:SecondaryAttack()
	return false
end

function SWEP:Think()
	self:WeaponConditionThink()
	self:OnThink()
	if self.AdjustWorldModel == true then
		if self.Weapon:IsValid() && self.Owner:IsValid() then
			self:SetPos(self:GetWorldModelPosition().pos)
			self:SetAngles(self:GetWorldModelPosition().ang)
		end
	end
	if self.HoldType != self.DefaultHoldType then
		self:SetWeaponHoldType(self.HoldType)
	end
	if self.Primary.DefaultClip != self.FixClip then
		self.Primary.DefaultClip = self.FixClip
	end
end

function SWEP:DoAFTMChat(text)
	if file.Exists("lua/autorun/aftm_playerhud.lua","GAME") then
		self.Owner:aftmSendDisplayMessage(text)
	end
end

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

function SWEP:OnThink() end

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

function SWEP:NPC_Reload()
	if self.Owner.ReloadingWeapon == false then
		self.Owner.ReloadingWeapon = true
		self:ReloadSounds()
		self:OnReload()
		-- self.Owner:StopCompletely()
		self.Owner:PlayAnimation("Reload")
		local reloadtime = self.NPC_CurrentReloadTime
		timer.Simple(reloadtime,function()
			if self:IsValid() && self.Owner:IsValid() then
				self.Owner.ReloadingWeapon = false
				self:SetClip1(self.Primary.DefaultClip)
			end
		end)
	end
end

function SWEP:OnReload() end

function SWEP:Reload()
	local reloadtime = self.ReloadTime
	if self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0 then return end
	if !self.Owner:KeyDown(IN_RELOAD) then return end
	if self:Clip1() == self.Primary.DefaultClip then return end
	if self.IsFiring == false && self.IsReloading == false then
		self.IsReloading = true
		self.CanUseIdle = false
		self:ReloadSounds()
		self:OnReload()
		-- self.Weapon:SendWeaponAnim(self.ReloadAnimation)
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
		if self.UseSingleReload == true then
			if CurTime() > self.NextReloadHintT then
				self.Owner:ChatPrint("Hint: This weapon uses a pump action reload. Hold down your reload key to cycle reloading. Let go at any point to stop.")
				self.NextReloadHintT = CurTime() +math.random(50,100)
			end
			timer.Simple(reloadtime,function() if self:IsValid() then self.Owner:RemoveAmmo(1,self.Primary.Ammo) self:SetClip1(self:Clip1() +1) self.CanUseIdle = true self.IsReloading = false end end)
		else
			timer.Simple(reloadtime,function() if self:IsValid() then self.Owner:RemoveAmmo(self.Primary.ClipSize -self:Clip1(),self.Primary.Ammo) self:SetClip1(self.Primary.DefaultClip) self.CanUseIdle = true self.IsReloading = false end end)
		end
		timer.Simple(reloadtime +0.001,function() if self:IsValid() then self:DoIdleAnimation() end end)
		self.Weapon:SetNextPrimaryFire(reloadtime)
	end
	return true
end

function SWEP:ReloadSounds()
	self:PlayWeaponSound("Reload",75)
end

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
	return true
end

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
	for k,v in pairs(self.LoopedSounds) do
		v:Stop()
	end
	self:OnHolster()
	return true
end

function SWEP:OnHolster() end

function SWEP:OnDeploy() end

function SWEP:OnRemovedSelf() end

function SWEP:OnRemove()
	self:PlayerSpeeds("reset")
	self:StopParticles()
	if self.CurrentSound != nil then
		self.CurrentSound:Stop()
	end
	for k,v in pairs(self.LoopedSounds) do
		v:Stop()
	end
	self:OnRemovedSelf()
end