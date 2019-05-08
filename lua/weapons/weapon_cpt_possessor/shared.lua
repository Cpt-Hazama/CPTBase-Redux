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

SWEP.ViewModelAdjust = {
	Pos = {Right = 4,Forward = 0,Up = 0},
	Ang = {Right = 0,Up = 0,Forward = 30}
}

local snd_aP = {
	"vo/npc/male01/sorrydoc01.wav",
	"vo/npc/male01/sorrydoc02.wav",
	"vo/npc/male01/sorrydoc04.wav",
}

local snd_nCN = {
	"vo/npc/male01/vanswer04.wav",
	"vo/npc/male01/vanswer07.wav",
	"vo/npc/male01/vanswer10.wav",
	"vo/npc/male01/vanswer13.wav",
	"vo/npc/male01/vanswer14.wav",
	"vo/npc/male01/vquestion03.wav",
	"vo/npc/male01/vquestion04.wav",
}

local snd_aPLY = {
	"vo/npc/male01/wetrustedyou01.wav",
	"vo/npc/male01/wetrustedyou02.wav",
	"vo/npc/male01/ow02.wav",
	"vo/npc/male01/ohno.wav",
	"vo/npc/male01/moan05.wav",
	"vo/npc/male01/imstickinghere01.wav",
	"vo/npc/male01/illstayhere01.wav",
}

local snd_cBP = {
	"vo/npc/male01/answer01.wav",
	"vo/npc/male01/answer02.wav",
	"vo/npc/male01/answer03.wav",
	"vo/npc/male01/answer04.wav",
	"vo/npc/male01/answer05.wav",
	"vo/npc/male01/answer07.wav",
	"vo/npc/male01/answer12.wav",
	"vo/npc/male01/answer13.wav",
	"vo/npc/male01/answer14.wav",
	"vo/npc/male01/answer15.wav",
	"vo/npc/male01/answer18.wav",
	"vo/npc/male01/answer19.wav",
	"vo/npc/male01/answer20.wav",
	"vo/npc/male01/answer21.wav",
}

local snd_Spawn = {
	"vo/npc/male01/hi01.wav",
	"vo/npc/male01/hi02.wav",
	"vo/npc/male01/heydoc01.wav",
	"vo/npc/male01/heydoc02.wav",
	"vo/npc/male01/abouttime01.wav",
	"vo/npc/male01/abouttime02.wav",
	"vo/npc/male01/ahgordon01.wav",
	"vo/npc/male01/ahgordon02.wav",
}

local snd_Idle = {
	"vo/npc/male01/answer09.wav",
	"vo/npc/male01/answer16.wav",
	"vo/npc/male01/answer17.wav",
	"vo/npc/male01/answer26.wav",
	"vo/npc/male01/answer28.wav",
	"vo/npc/male01/answer30.wav",
	"vo/npc/male01/answer31.wav",
	"vo/npc/male01/answer33.wav",
	"vo/npc/male01/answer37.wav",
	"vo/npc/male01/answer38.wav",
	"vo/npc/male01/answer39.wav",
	"vo/npc/male01/freeman.wav",
	"vo/npc/male01/getgoingsoon.wav",
	"vo/npc/male01/gordead_ans01.wav",
	"vo/npc/male01/gordead_ans16.wav",
	"vo/npc/male01/gordead_ans19.wav",
	"vo/npc/male01/illstayhere01.wav",
	"vo/npc/male01/imstickinghere01.wav",
	"vo/npc/male01/moan01.wav",
	"vo/npc/male01/moan02.wav",
	"vo/npc/male01/moan03.wav",
	"vo/npc/male01/moan04.wav",
	"vo/npc/male01/moan05.wav",
	"vo/npc/male01/myleg01.wav",
	"vo/npc/male01/notthemanithought02.wav",
	"vo/npc/male01/oneforme.wav",
	"vo/npc/male01/question05.wav",
	"vo/npc/male01/question06.wav",
	"vo/npc/male01/question07.wav",
	"vo/npc/male01/question08.wav",
	"vo/npc/male01/question09.wav",
	"vo/npc/male01/question12.wav",
	"vo/npc/male01/question19.wav",
	"vo/npc/male01/question23.wav",
	"vo/npc/male01/question27.wav",
	"vo/npc/male01/whoops01.wav",
	"vo/npc/male01/yeah02.wav",
	"npc/zombie_poison/pz_alert1.wav",
}

function SWEP:PickSound(tbl)
	if tbl == nil then return tbl end
	return tbl[math.random(1,#tbl)]
end

function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
	self.CPTBase_Weapon = true
	self.UseLuaMovement = true
	if CLIENT && IsValid(self.Owner) && self.Owner:IsPlayer() then
		self.Owner:ChatPrint("Weapon Controls:")
		self.Owner:ChatPrint("LMB - Possess the NPC at your crosshair")
		self.Owner:ChatPrint("RMB - Find the closest NPC to your crosshair")
	end
end

function SWEP:Deploy()
	self:EmitSound(self:PickSound(snd_Spawn),40,100)
	self.NextIdleT = CurTime() +5
	self:SendWeaponAnim(ACT_VM_IDLE)
	return true
end

function SWEP:PrimaryAttack()
	if (CLIENT) or self.Owner:IsNPC() then return end
	local tracedata = {}
	tracedata.start = self.Owner:GetShootPos()
	tracedata.endpos = self.Owner:GetShootPos() +self.Owner:GetAimVector() *10000
	tracedata.filter = self.Owner
	local tr = util.TraceLine(tracedata) 
	if tr.Entity && IsValid(tr.Entity) && tr.Entity:Health() > 0 then
		if tr.Entity:IsPlayer() then
			self.Owner:ChatPrint("......that's a player...")
			self:EmitSound(self:PickSound(snd_aPLY),40,100)
			return
		end
		if tr.Entity.IsPossessed == true then
			self.Owner:ChatPrint("This (S)NPC is already being possessed!")
			self:EmitSound(self:PickSound(snd_aP),40,100)
			return
		end
		if tr.Entity:IsNPC() && tr.Entity.CPTBase_NPC != true then
			self.Owner:ChatPrint("You are unable to possess this (S)NPC!")
			self:EmitSound(self:PickSound(snd_nCN),40,100)
			return
		end
		if tr.Entity:IsNPC() && tr.Entity.Possessor_CanBePossessed == false then
			self.Owner:ChatPrint("This entity can not be possessed!")
			self:EmitSound(self:PickSound(snd_cBP),40,100)
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
			self:EmitSound(self:PickSound(snd_aP),40,100)
			return
		end
		if ent:IsNPC() && ent.CPTBase_NPC != true then
			self.Owner:ChatPrint("You are unable to possess this (S)NPC!")
			self:EmitSound(self:PickSound(snd_nCN),40,100)
			return
		end
		if ent:IsNPC() && ent.Possessor_CanBePossessed == false then
			self.Owner:ChatPrint("This entity can not be possessed!")
			self:EmitSound(self:PickSound(snd_cBP),40,100)
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

if SERVER then
	function SWEP:Think()
		if CurTime() > self.NextIdleT && math.random(1,40) == 1 then
			local selectSound = self:PickSound(snd_Idle)
			self:EmitSound(selectSound,40,100)
			self.NextIdleT = CurTime() +math.Rand(8,22)
		end
	end
end

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
		opos:Add(ang:Right() *(self.ViewModelAdjust.Pos.Right))
		opos:Add(ang:Forward() *(self.ViewModelAdjust.Pos.Forward))
		opos:Add(ang:Up() *(self.ViewModelAdjust.Pos.Up))
		pos:Add(ang:Right() *(self.ViewModelAdjust.Pos.Right))
		pos:Add(ang:Forward() *(self.ViewModelAdjust.Pos.Forward))
		pos:Add(ang:Up() *(self.ViewModelAdjust.Pos.Up))
		ang:RotateAroundAxis(ang:Right(),self.ViewModelAdjust.Ang.Right)
		ang:RotateAroundAxis(ang:Up(),self.ViewModelAdjust.Ang.Up)
		ang:RotateAroundAxis(ang:Forward(),self.ViewModelAdjust.Ang.Forward)
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