if !CPTBase then return end
AddCSLuaFile('shared.lua')
include('shared.lua')

BACK = ACT_HL2MP_JUMP_SMG1
FORWARD = ACT_HL2MP_JUMP_AR2
LEFT = ACT_HL2MP_JUMP
RIGHT = ACT_HL2MP_JUMP_PISTOL

ENT.ModelTable = {"models/cpthazama/fassassin.mdl"}
ENT.StartHealth = 70
ENT.WanderChance = 0

ENT.Faction = "FACTION_COMBINE"

ENT.MeleeAttackDistance = 60
ENT.MeleeAttackDamageDistance = 70
ENT.MeleeAttackType = DMG_CLUB
ENT.MeleeAttackDamage = 15

ENT.RangeAttackDistance = 1000
ENT.RangeAttackStopDistance = 120

ENT.BloodEffect = {"blood_impact_red_01"}

ENT.tbl_Animations = {
	["Walk"] = {ACT_RUN},
	["Run"] = {ACT_RUN},
	["Attack"] = {ACT_MELEE_ATTACK1,ACT_MELEE_ATTACK2},
	["RangeAttack"] = {ACT_RANGE_ATTACK1}
}

ENT.tbl_Sounds = {
	["FootStep"] = {
		"npc/footsteps/hardboot_generic2.wav",
		-- "npc/footsteps/hardboot_generic6.wav",
		-- "npc/footsteps/hardboot_generic8.wav"
	},
	["Click"] = {
		"npc/stalker/stalker_footstep_left1.wav",
		"npc/stalker/stalker_footstep_left2.wav",
		"npc/stalker/stalker_footstep_right1.wav",
		"npc/stalker/stalker_footstep_right2.wav"
	},
	-- ["Fire"] = {"cptbase/cassassin/fire_pistol01.wav","cptbase/cassassin/fire_pistol02.wav"},
	["Fire"] = {"weapons/pistol/pistol_fire2.wav"},
	["Pain"] = {"npc/combine_soldier/pain1.wav","npc/combine_soldier/pain2.wav","npc/combine_soldier/pain3.wav"},
	["Death"] = {"npc/combine_soldier/die1.wav","npc/combine_soldier/die2.wav","npc/combine_soldier/die3.wav"},
	["Spot"] = {"npc/turret_floor/ping.wav"},
}
ENT.WalkSoundVolume = 72
ENT.RunSoundVolume = 72
ENT.PainSoundPitch = 120
ENT.DeathSoundPitch = 120
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetInit()
	self:SetHullType(HULL_HUMAN)
	self:SetCollisionBounds(Vector(10,10,55),Vector(-10,-10,0))
	self:CapabilitiesAdd(bit.bor(CAP_MOVE_GROUND,CAP_OPEN_DOORS,CAP_USE))
	self.IsAttacking = false
	self.IsRangeAttacking = false
	self.IsDodging = false
	self.NextJumpT = 0
	self.eye = ents.Create("env_sprite")
	self.eye:SetKeyValue("model","cptbase/sprites/glow01.spr")
	self.eye:SetKeyValue("rendermode","5")
	self.eye:SetKeyValue("rendercolor","232 85 50")
	self.eye:SetKeyValue("scale","0.1")
	self.eye:SetKeyValue("spawnflags","1")
	self.eye:SetParent(self)
	self.eye:Fire("SetParentAttachment","Eye",0)
	self.eye:Spawn()
	self.eye:Activate()
	self:DeleteOnRemove(self.eye)
	self.light = ents.Create("light_dynamic")
	self.light:SetKeyValue("_light","232 85 50")
	self.light:SetKeyValue("brightness","1")
	self.light:SetKeyValue("distance","25")
	self.light:SetKeyValue("style","0")
	self.light:SetParent(self)
	self.light:Fire("SetParentAttachment","Eye")
	self.light:Spawn()
	self.light:Activate()
	self.light:Fire("TurnOn","",0)
	self.light:DeleteOnRemove(self)
	util.SpriteTrail(self,self:LookupAttachment("Eye"),Color(232,85,50),true,8,8,0.8,0.125,"models/combine_fassassin/eyetrail.vmt")
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnPlaySound(sound,tbl)
	if tbl == "Spot" then
		self:EmitSound("npc/combine_soldier/vo/on2.wav",60,110)
		timer.Simple(SoundDuration(sound),function() if self:IsValid() then self:EmitSound("npc/combine_soldier/vo/off3.wav",60,110) end end)
	elseif tbl == "FootStep" then
		self:EmitSound(self:SelectFromTable(self.tbl_Sounds["Click"]),70,130)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnFoundEnemy(count,oldcount,ent)
	self:PlaySound("Spot",70,90,108)
	if self.eye then
		self.eye:SetKeyValue("rendercolor","127 0 0")
		timer.Simple(0.5,function() if self:IsValid() then self.eye:SetKeyValue("rendercolor","232 85 50") end end)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:HandleEvents(...)
	local event = select(1,...)
	local arg1 = select(2,...)
	local spread = 20
	if(event == "emit") then
		if(arg1 == "Foot") then
			self:PlaySound("FootStep",self.RunSoundVolume,90,self.StepSoundPitch,true)
		end
		return true
	end
	if(event == "mattack") then
		self:DoDamage(self.MeleeAttackDamageDistance,self.MeleeAttackDamage,self.MeleeAttackType)
		return true
	end
	if(event == "rattack") then
		if self:GetEnemy() == nil && self.IsPossessed == false then return true end
		local muzzle = self:GetAttachment(self:LookupAttachment(arg1 == "right" && "RightMuzzle" || "LeftMuzzle"))
		-- if(arg1 == "left") then
			-- muzzle = self:GetAttachment(self:LookupAttachment("LeftMuzzle"))
		-- elseif(arg2 == "right") then
			-- muzzle = self:GetAttachment(self:LookupAttachment("RightMuzzle"))
			-- return true
		-- else
		-- end
		local bullet = {}
		bullet.Num = 1
		bullet.Src = muzzle.Pos
		if self.IsPossessed then
			bullet.Dir = self:Possess_AimTarget() -muzzle.Pos +Vector(math.Rand(-spread,spread),math.Rand(-spread,spread),math.Rand(-spread,spread))
		else
			if self:GetEnemy() == nil then return true end
			bullet.Dir = (self:GetEnemy():GetPos() +self:GetEnemy():OBBCenter()) -muzzle.Pos +Vector(math.Rand(-spread,spread),math.Rand(-spread,spread),math.Rand(-spread,spread))
		end
		bullet.Spread = spread
		bullet.Tracer = 1
		bullet.Force = 5
		bullet.Damage = 6
		bullet.AmmoType = "Pistol"
		self:FireBullets(bullet)
		self:SoundCreate(self:SelectFromTable(self.tbl_Sounds["Fire"]),95)
		local effectdata = EffectData()
		effectdata:SetStart(muzzle.Pos)
		effectdata:SetOrigin(muzzle.Pos)
		effectdata:SetScale(1)
		effectdata:SetAngles(muzzle.Ang)
		util.Effect("MuzzleEffect",effectdata)
		return true
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:DoAttack()
	if self:CanPerformProcess() == false then return end
	if self.IsDodging then return end
	if !self.IsPossessed && (self:GetEnemy() != nil && !self:GetEnemy():Visible(self)) then return end
	self:StopCompletely()
	self:PlayAnimation("Attack",2)
	self:PlaySound("Attack")
	self.IsAttacking = true
	self:AttackFinish()
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:DoRangeAttack()
	if self:CanPerformProcess() == false then return end
	if self.IsDodging then return end
	if !self.IsPossessed && (self:GetEnemy() != nil && !self:GetEnemy():Visible(self)) then return end
	self:StopCompletely()
	self:PlayAnimation("RangeAttack",2)
	self.IsRangeAttacking = true
	self:AttackFinish()
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:DoDodge(forceanim)
	if self.IsDodging then return end
	local act = {BACK,LEFT,RIGHT}
	local trypos
	local tryact = self:SelectFromTable(act)
	if forceanim != nil then
		if tryact == BACK then trypos = self:GetForward() *-400 elseif tryact == LEFT then trypos = self:GetRight() *-400 elseif tryact == RIGHT then trypos = self:GetRight() *400 end
			if !self:DoCustomTrace(self:GetPos(),self:GetPos() +trypos,{self},true).Hit then
				self:StopCompletely()
				self:PlayActivity(tryact,0)
				self.IsDodging = true
				timer.Simple(self:AnimationLength(tryact),function() if self:IsValid() then self.IsDodging = false end end)
				self.NextJumpT = CurTime() +math.random(1,3)
			end
		return
	end
	local act = {BACK,FORWARD,LEFT,RIGHT}
	local trypos
	local tryact = self:SelectFromTable(act)
	if tryact == BACK then trypos = self:GetForward() *-400 elseif tryact == FORWARD then trypos = self:GetForward() *400 elseif tryact == LEFT then trypos = self:GetRight() *-400 elseif tryact == RIGHT then trypos = self:GetRight() *400 end
	if !self:DoCustomTrace(self:GetPos(),self:GetPos() +trypos,{self},true).Hit then
		self:StopCompletely()
		self:PlayActivity(tryact,0)
		self.IsDodging = true
		timer.Simple(self:AnimationLength(tryact),function() if self:IsValid() then self.IsDodging = false end end)
		self.NextJumpT = CurTime() +math.random(1,3)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Possess_Jump(possessor)
	if CurTime() > self.NextJumpT && self.IsDodging == false then
		self:StopCompletely()
		if possessor:KeyDown(IN_MOVELEFT) then
			self:PlayActivity(LEFT,0)
			animtime = self:AnimationLength(LEFT)
		elseif possessor:KeyDown(IN_MOVERIGHT) then
			self:PlayActivity(RIGHT,0)
			animtime = self:AnimationLength(RIGHT)
		elseif possessor:KeyDown(IN_FORWARD) then
			self:PlayActivity(FORWARD,0)
			animtime = self:AnimationLength(FORWARD)
		elseif possessor:KeyDown(IN_BACK) then
			self:PlayActivity(BACK,0)
			animtime = self:AnimationLength(BACK)
		else
			self:PlayActivity(BACK,0)
			animtime = self:AnimationLength(BACK)
		end
		self.IsDodging = true
		self.IsRangeAttacking = true
		timer.Simple(animtime,function() if self:IsValid() then self.IsRangeAttacking = false self.IsDodging = false end end)
		self.NextJumpT = CurTime() +math.random(1,3)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnTakePain(dmg,dmginfo,hitbox)
	if !self.IsPossessed && CurTime() > self.NextJumpT && self.IsDodging == false then
		self:DoDodge()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:HandleSchedules(enemy,dist,nearest,disp)
	if self.IsPossessed then return end
	if(disp == D_HT) then
		if nearest <= self.MeleeAttackDistance && self:FindInCone(enemy,self.MeleeAngle) then
			self:DoAttack()
		end
		if nearest < self.RangeAttackStopDistance && nearest > self.MeleeAttackDistance && CurTime() > self.NextJumpT && self.IsDodging == false then
			self:DoDodge(true)
		end
		if nearest <= self.RangeAttackDistance && nearest >= self.RangeAttackStopDistance && self:FindInCone(enemy,40) then
			self:DoRangeAttack()
			if math.random(1,18) == 1 && CurTime() > self.NextJumpT && self.IsDodging == false then
				self:DoDodge()
			end
		end
		if self:CanPerformProcess() && self.IsDodging == false then
			self:ChaseEnemy()
		end
	elseif(disp == D_FR) then
		self:Hide()
	end
end