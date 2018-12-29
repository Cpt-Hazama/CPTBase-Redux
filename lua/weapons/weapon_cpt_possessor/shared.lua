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
	if IsValid(self.Owner) && self.Owner:IsPlayer() then
		self.Owner:ChatPrint("Weapon Controls:")
		self.Owner:ChatPrint("LMB - Possess NPC at crosshair")
		self.Owner:ChatPrint("RMB - Find closest NPC to crosshair")
	end
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
		if tr.Entity:IsNPC() && tr.Entity.Possessor_CanBePossessed == false then
			self.Owner:ChatPrint("This entity can not be possessed!")
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
	self:SetNextSecondaryFire(CurTime() +1)
end

function SWEP:SecondaryAttack()
	if (CLIENT) or self.Owner:IsNPC() then return end
	local tracedata = {}
	tracedata.start = self.Owner:GetShootPos()
	tracedata.endpos = self.Owner:GetShootPos() +self.Owner:GetAimVector() *10000
	tracedata.filter = self.Owner
	local tr = util.TraceLine(tracedata) 
	local pos = tr.HitPos
	local tbl_Ents = {}
	for _,v in ipairs(ents.FindInSphere(pos,50)) do
		if IsValid(v) then
			if v:IsNPC() then
				if !table.HasValue(tbl_Ents,v) then
					table.insert(tbl_Ents,v)
				end
			end
		end
	end
	local ent = self:GetClosestEntity(tbl_Ents,pos)
	if ent && IsValid(ent) && ent:Health() > 0 then
		if ent.IsPossessed == true then
			self.Owner:ChatPrint("This (S)NPC is already being possessed!")
			self:EmitSound(Sound("npc/antlion/distract1.wav"),40,math.random(120,150))
			return
		end
		if ent:IsNPC() && ent.CPTBase_NPC != true then
			self.Owner:ChatPrint("You are unable to possess this (S)NPC!")
			self:EmitSound(Sound("npc/antlion/distract1.wav"),40,math.random(120,150))
			return
		end
		if ent:IsNPC() && ent.Possessor_CanBePossessed == false then
			self.Owner:ChatPrint("This entity can not be possessed!")
			self:EmitSound(Sound("npc/antlion/distract1.wav"),40,math.random(120,150))
			return
		end
		for i = 0,self.Owner:GetBoneCount() -1 do
			ParticleEffect("vortigaunt_beam",self.Owner:GetBonePosition(i),Angle(0,0,0),nil)
		end
		for i = 0,tr.Entity:GetBoneCount() -1 do
			util.ParticleTracerEx("vortigaunt_beam",self.Owner:GetPos(),ent:GetBonePosition(i),false,self:EntIndex(),4)
			ParticleEffect("vortigaunt_glow_beam_cp0",ent:GetBonePosition(i),Angle(0,0,0),nil)
		end
		local possessor = ents.Create("ent_cpt_possessor")
		possessor.Possessor = self.Owner
		possessor:PossessedNPC(ent)
		possessor:Spawn()
		sound.Play("cptbase/fx_poison_stinger.wav",self:GetPos(),60,115 *GetConVarNumber("host_timescale"),1)
		sound.Play("beams/beamstart5.wav",self:GetPos(),60,115 *GetConVarNumber("host_timescale"),1)
		sound.Play("beams/beamstart5.wav",ent:GetPos(),60,115 *GetConVarNumber("host_timescale"),1)
		possessor:PossessTheNPC()
		if self.Owner:GetViewModel() != nil then
			self.Owner:GetViewModel():SetRenderFX(kRenderFxNone)
		end
	end
	self:SetNextPrimaryFire(CurTime() +1)
	self:SetNextSecondaryFire(CurTime() +1)
end


function SWEP:GetClosestEntity(tbl,pos)
	local target = self:GetEntitiesByDistance(tbl,pos)[1]
	return target
end

function SWEP:GetEntitiesByDistance(tbl,pos)
	local disttbl = {}
	for _,v in ipairs(tbl) do
		if v:IsValid() then
			disttbl[v] = v:GetPos():Distance(pos)
		end
	end
	return table.SortByKey(disttbl,false)
end

function SWEP:Think() end

function SWEP:Reload() end

function SWEP:OnRemove() end

if CLIENT then
	function SWEP:GetViewModelPosition(pos,ang) // Refer to the hook for movement
		local opos = pos *1
		local duck1 = 0
		local duck2 = 0
		local jump = 0
		local move1 = 0
		local move2 =  0
		if self.Owner:IsOnGround() then
			if jump > 0 then
				jump = jump -0.5
			end
		else
			if jump < 6 then
				jump = jump +0.1
			end
		end
		ang:RotateAroundAxis(ang:Right(),jump)
		ang:RotateAroundAxis(ang:Up(),(jump *-0.3))
		ang:RotateAroundAxis(ang:Forward(),0)
		local walkspeed = self.Owner:GetVelocity():Length() 
		if walkspeed > 0 then
			if !self.Owner:KeyDown(IN_WALK) && !self.Owner:KeyDown(IN_SPEED) && !self.Owner:KeyDown(IN_DUCK) && self.Owner:IsOnGround() && (self.Owner:KeyDown(IN_FORWARD) or self.Owner:KeyDown(IN_BACK) or self.Owner:KeyDown(IN_MOVELEFT) or self.Owner:KeyDown(IN_MOVERIGHT)) then
				move1 = 17
				move2 = 3
			elseif (self.Owner:KeyDown(IN_WALK) or self.Owner:KeyDown(IN_DUCK)) && !self.Owner:KeyDown(IN_SPEED) && self.Owner:IsOnGround() && (self.Owner:KeyDown(IN_FORWARD) or self.Owner:KeyDown(IN_BACK) or self.Owner:KeyDown(IN_MOVELEFT) or self.Owner:KeyDown(IN_MOVERIGHT)) then
				move1 = 15
				move2 = 10
			elseif self.Owner:KeyDown(IN_SPEED) && self.Owner:IsOnGround() && (self.Owner:KeyDown(IN_FORWARD) or self.Owner:KeyDown(IN_BACK) or self.Owner:KeyDown(IN_MOVELEFT) or self.Owner:KeyDown(IN_MOVERIGHT)) then
				move1 = 20
				move2 = 1 +(3 /75)
			else
				move1 = 0
				move2 = 100
			end
			ang = ang +Angle(math.cos(CurTime() *move1) /move2,math.cos(CurTime() *move1 /2) /move2,0)
		end
		return pos,ang
	end
end