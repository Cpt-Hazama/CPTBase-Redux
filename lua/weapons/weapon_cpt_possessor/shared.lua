if !CPTBase then return end

SWEP.PrintName = "Possessor"
SWEP.Author = "Cpt. Hazama"
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = ""
SWEP.Category = "CPTBase"

if (CLIENT) then
	SWEP.Slot = 5
	SWEP.SlotPos = 3
	SWEP.SwayScale = 1
	SWEP.CSMuzzleFlashes = false
	SWEP.DrawAmmo = true
	SWEP.DrawCrosshair = true
	SWEP.DrawWeaponInfoBox = true
	SWEP.BounceWeaponIcon = true
	SWEP.RenderGroup = RENDERGROUP_OPAQUE
	SWEP.ViewModelFOV = 55
	SWEP.UseHands = true
	SWEP.LuaMovementScale_Forward = 0.0800
	SWEP.LuaMovementScale_Right = 0.0084
	SWEP.LuaMovementScale_Up = 0.022
end

if (SERVER) then
	SWEP.Weight	= 30
	SWEP.AutoSwitchTo = false
	SWEP.AutoSwitchFrom	= false
end

SWEP.ViewModel					= "models/weapons/c_bugbait.mdl"
SWEP.WorldModel					= "models/weapons/w_bugbait.mdl"
SWEP.HoldType 					= "pistol"
SWEP.Spawnable					= true
SWEP.AdminSpawnable				= false

SWEP.Primary.ClipSize 			= -1
SWEP.Primary.MaximumClip		= -1
SWEP.Primary.Automatic 			= false
SWEP.Primary.Ammo 				= "none"

function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
	self.CPTBase_Weapon = true
	self.UseLuaMovement = true
	self:EmitSound(Sound("cptbase/fx_melee_claw_flesh0" .. math.random(1,2) .. ".wav"),60,100)
end

function SWEP:Deploy()
	self:EmitSound(Sound("cptbase/fx_melee_claw_flesh0" .. math.random(1,2) .. ".wav"),60,100)
	self:SendWeaponAnim(ACT_VM_IDLE)
	return true
end

function SWEP:Think()
	self:SendWeaponAnim(ACT_VM_IDLE)
end

function SWEP:PrimaryAttack()
	if (CLIENT) or self.Owner:IsNPC() then return end
	local tracedata = {}
	tracedata.start = self.Owner:GetShootPos()
	tracedata.endpos = self.Owner:GetShootPos() +self.Owner:GetAimVector() *10000
	tracedata.filter = self.Owner
	local tr = util.TraceLine(tracedata) 

	if tr.Entity && IsValid( tr.Entity ) && tr.Entity:Health() > 0 then
		if tr.Entity.IsPossessed == true then
			self.Owner:ChatPrint("This (S)NPC is already being possessed!")
			self:EmitSound(Sound("npc/antlion/distract1.wav"),40,math.random(120,150))
			return
		end
		if tr.Entity:IsNPC() && tr.Entity.CPTBase_NPC != true then
			self.Owner:ChatPrint("You are unable to possess this (S)NPC!")
			self:EmitSound(Sound("npc/antlion/distract1.wav"),40,math.random(120,150))
			return
		end
		for i = 0,self.Owner:GetBoneCount() -1 do
			ParticleEffect("vortigaunt_beam",self.Owner:GetBonePosition(i),Angle(0,0,0),nil)
		end
		for i = 0,tr.Entity:GetBoneCount() -1 do
			util.ParticleTracerEx("vortigaunt_beam",self.Owner:GetPos(),tr.Entity:GetBonePosition(i),false,self:EntIndex(),4)
			ParticleEffect("vortigaunt_glow_beam_cp0",tr.Entity:GetBonePosition(i),Angle(0,0,0),nil)
		end
		local possessor = ents.Create("ent_cpt_possessor")
		possessor.Possessor = self.Owner
		possessor:PossessedNPC(tr.Entity)
		possessor:Spawn()
		sound.Play("cptbase/fx_poison_stinger.wav",self:GetPos(),60,115 *GetConVarNumber("host_timescale"),1)
		sound.Play("beams/beamstart5.wav",self:GetPos(),60,115 *GetConVarNumber("host_timescale"),1)
		sound.Play("beams/beamstart5.wav",tr.Entity:GetPos(),60,115 *GetConVarNumber("host_timescale"),1)
		possessor:PossessTheNPC()
		if self.Owner:GetViewModel() != nil then
			self.Owner:GetViewModel():SetRenderFX(kRenderFxNone)
		end
	end
	self:SetNextPrimaryFire(CurTime() +1)
end

function SWEP:SecondaryAttack()
	return false
end

function SWEP:Think() end

function SWEP:Reload() end

function SWEP:OnRemove() end