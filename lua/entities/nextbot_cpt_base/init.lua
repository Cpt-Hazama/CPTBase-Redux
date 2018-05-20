if !CPTBase then return end
AddCSLuaFile('shared.lua')
include('shared.lua')

ENT.ModelTable = {}
ENT.CollisionBounds = Vector(0,0,0)
ENT.StartHealth = 0

ENT.ViewDistance = 7500
ENT.ViewAngle = 75
ENT.HearingDistance = 900

ENT.Faction = "FACTION_NONE"
ENT.Confidence = 2

ENT.tbl_Animations = {}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Initialize()
	self:SetSpawnEffect(false)
	self:SetModel(self:SelectFromTable(self.ModelTable))
	if self.CollisionBounds != Vector(0,0,0) then
		self:SetCollisionBounds(Vector(self.CollisionBounds.x,self.CollisionBounds.y,self.CollisionBounds.z),-(Vector(self.CollisionBounds.x,self.CollisionBounds.y,0)))
	end
	self:SetHealth(self.StartHealth)
	self:SetMaxHealth(self.StartHealth)
	self:SetEnemy(NULL)
	self.CPTBase_Nextbot = true
	self.IsDead = false

	self:OnInit()
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnInit()
	self:SetRunSpeed(300)
	self:SetWalkSpeed(100)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetEnemy(ent)
	self.Enemy = ent
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:GetEnemy()
	return self.Enemy
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Think() end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:HaveEnemy()
	if IsValid(self:GetEnemy()) && self:GetEnemy():IsValid() then
		if (self:FindDistance(self:GetEnemy()) > self.ViewDistance) then
			return self:FindEnemy()
		elseif (self:GetEnemy():IsPlayer() && !self:GetEnemy():Alive()) then
			return self:FindEnemy()
		end
		return true
	else
		return self:FindEnemy()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:FindEnemy()
	if GetConVarNumber("ai_disabled") == 1 then return end
	for k,v in ipairs(ents.FindInSphere(self:GetPos(),self.ViewDistance)) do
		-- if !v:IsValid() then return end
		if v:IsNPC() && v != self && v:GetClass() != self:GetClass() && v:Health() > 0 then
			if (self:Visible(v) && self:FindDistance(v) <= self.ViewDistance && self:FindInCone(v,self.ViewAngle)) then
				if (v:GetFaction() == nil or v:GetFaction() != nil && v.Faction != self:GetFaction()) or self:Disposition(v) != D_LI then
					self:SetEnemy(v)
					return true
				end
			end
		elseif GetConVarNumber("ai_ignoreplayers") == 0 && v:IsPlayer() && v:Alive() then
			if (self:Visible(v) && self:FindDistance(v) <= self.ViewDistance && self:FindInCone(v,self.ViewAngle)) then
				if self:GetFaction() != "FACTION_PLAYER" or self:Disposition(v) != D_LI then
					self:SetEnemy(v)
					return true
				end
			end
		end
	end
	self:SetEnemy(nil)
	return false
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnHearSound(ent)
	if ent:Visible(self) then
		self.loco:FaceTowards(ent:GetPos())
	elseif !ent:Visible(self) then
		local NoisePos = util.RandomVectorAroundPos(self:FindCenter(ent),150,true)
		self:GoToPosition(NoisePos,"Walk",self:GetWalkSpeed())
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:ChaseEntity(ent,anim,speed,acceleration)
	local anim = anim or ACT_RUN
	local speed = speed or self:GetRunSpeed()
	local acceleration = acceleration or 1000

	self.loco:FaceTowards(ent:GetPos())
	self:StartActivity(anim)
	self.loco:SetDesiredSpeed(speed)
	self.loco:SetAcceleration(acceleration)
	self:ChaseEnemy()
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:HandleSchedules(enemy,dist,nearest,disp)
	if(disp == D_HT) then
		// Input AI details here
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:GoToPosition(pos,anim,speed)
	self:StartActivity(self:SelectFromTable(self.tbl_Animations[anim]))
	self.loco:SetDesiredSpeed(speed)
	self:MoveToPos(pos)
	self:StartActivity(self:SelectFromTable(self.tbl_Animations["Idle"]))
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnIdle()
	self:StartActivity(self:SelectFromTable(self.tbl_Animations["Walk"]))
	self.loco:SetDesiredSpeed(self:GetWalkSpeed())
	self:MoveToPos(self:GetPos() +Vector(math.Rand(-1,1),math.Rand(-1,1),0) *400)
	self:StartActivity(self:SelectFromTable(self.tbl_Animations["Idle"]))
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CanPerformProcess()
	if self.IsAttacking == true or self.IsRangeAttacking == true or self.IsRagdolled == true or self.bInSchedule == true or self.IsPlayingSequence == true then
		return false
	else
		return true
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Disposition(target)
	if target:GetClass() != self:GetClass() or target:GetFaction() != self.Faction then
		return D_HT
	else
		return D_LI
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:RunBehaviour()
	if GetConVarNumber("ai_disabled") == 1 then return end
	while (true) do
		if (self:HaveEnemy()) then
			self:ChaseEntity(self:GetEnemy(),self:SelectFromTable(self.tbl_Animations["Run"]),self:GetRunSpeed(),1000)
		else
			self:OnIdle()
		end
		coroutine.wait(3)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetRunSpeed(speed) self.RunSpeed = speed end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:GetRunSpeed() return self.RunSpeed end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetWalkSpeed(speed) self.WalkSpeed = speed end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:GetWalkSpeed() return self.WalkSpeed end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:ChaseEnemy(options)
	if GetConVarNumber("ai_disabled") == 1 then coroutine.yield() return end
	local options = options or {}
	local path = Path("Follow")
	path:SetMinLookAheadDistance(options.lookahead or 300)
	path:SetGoalTolerance(options.tolerance or 20)
	path:Compute(self,self:GetEnemy():GetPos())
	if (!path:IsValid()) then return "failed" end
	while (path:IsValid() && self:HaveEnemy()) do
		if (path:GetAge() > 0.1) then
			path:Compute(self,self:GetEnemy():GetPos())
		end
		path:Update(self)
		if (options.draw) then path:Draw() end
		self:HandleSchedules(self:GetEnemy(),self:FindCenterDistance(self:GetEnemy()),self:GetClosestPoint(self:GetEnemy()),self:Disposition(self:GetEnemy()))
		if (self.loco:IsStuck()) then
			self:HandleStuck()
			return "stuck"
		end
		coroutine.yield()
	end
	return "ok"
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:PlayNextbotAnimation(act,animtype)
	local act = self:SelectFromTable(self.tbl_Animations[act])
	if animtype == "seq" then
		self:PlayNextbotSequence(act,0,1)
	elseif animtype == "ges" then
		local gest = self:AddGestureSequence(self:LookupSequence(act))
		self:SetLayerPriority(gest,2)
		self:SetLayerPlaybackRate(gest,0.5)
	elseif animtype == "act" then
		local lastact = self:GetActivity()
		local lastspeed = self:GetRunSpeed()
		if type(act) == "string" then
			self:TranslateStringToNumber(act)
			self.loco:SetDesiredSpeed(0)
		else
			self:StartActivity(act)
			self.loco:SetDesiredSpeed(0)
		end
		timer.Simple((self:SequenceDuration(self:SelectWeightedSequence(act)) *self:GetPlaybackRate()),function()
			if self:IsValid() then
				self:StartActivity(lastact)
				self.loco:SetDesiredSpeed(lastspeed)
			end
		end)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:DoDamage(dist,dmg,dmgtype,force,viewPunch,fcOnHit)
	local pos = self:GetPos() +self:OBBCenter() +self:GetForward()*20
	local posSelf = self:GetPos()
	local center = posSelf +self:OBBCenter()
	local didhit
	for _,ent in ipairs(ents.FindInSphere(pos,dist)) do
		if ent:IsValid() && self:IsValid() && self:Visible(ent) && ent:Health() > 0 then
			if (ent:IsNPC() && ent != self && self:Disposition(ent) != D_LI && ent:GetModel() != self:GetModel()) or (ent:IsPlayer() && ent:Alive()) && (self:GetForward():Dot(((ent:GetPos() +ent:OBBCenter()) -pos):GetNormalized()) > math.cos(math.rad(self.ViewAngle))) then
				if force then
					local forward,right,up = self:GetForward(),self:GetRight(),self:GetUp()
					force = forward *force.x +right *force.y +up *force.z
				end
				didhit = true
				local dmgpos = ent:NearestPoint(center)
				local dmginfo = DamageInfo()
				dmginfo:SetDamage(dmg)
				dmginfo:SetAttacker(self)
				dmginfo:SetInflictor(self)
				dmginfo:SetDamageType(dmgtype)
				dmginfo:SetDamagePosition(dmgpos)
				if force then
					dmginfo:SetDamageForce(force)
				end
				if(fcOnHit) then
					fcOnHit(ent,dmginfo)
				end
				ent:TakeDamageInfo(dmginfo)
				if ent:IsPlayer() then
					if viewPunch then
						ent:ViewPunch(viewPunch)
					else
						ent:ViewPunch(Angle(math.random(-1,1)*dmg,math.random(-1,1)*dmg,math.random(-1,1)*dmg))
					end
				elseif ent:GetClass() == "npc_turret_floor" then
					ent:Fire("selfdestruct","",0)
					ent:GetPhysicsObject():ApplyForceCenter(self:GetForward() *10000) 
				end
			end
		end
	end
	if didhit == true then
		if self.tbl_Sounds["Strike"] == nil then
			self:EmitSound("npc/zombie/claw_strike" .. math.random(1,3) .. ".wav")
		else
			self:EmitSound(self:SelectFromTable(self.tbl_Sounds["Strike"]))
		end
	else
		if self.tbl_Sounds["Miss"] == nil then
			self:EmitSound("npc/zombie/claw_miss" .. math.random(1,2) .. ".wav",75,100)
		else
			self:EmitSound(self:SelectFromTable(self.tbl_Sounds["Miss"]))
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:PlayNextbotSequence(seq,cycle,rate)
	local cycle = cycle or 0
	local rate = rate or 1
	if cycle > 1 then
		ErrorNoHalt("error: cycle must be less than 1.")
		cycle = 0
	end
	self:ResetSequence(seq)
	self:SetCycle(cycle)
	self:SetPlaybackRate(rate)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:GetDistanceToVector(pos,type)
	if type == 1 then
		return self:GetPos():Distance(pos)
	elseif type == 2 then
		return self:NearestPoint(pos)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:FindDistance(ent)
	return self:GetPos():Distance(ent:GetPos())
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:FindCenterDistance(ent)
	return self:GetPos():Distance(self:FindCenter(ent))
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:FindCenter(ent)
	return ent:GetPos() +ent:OBBCenter()
end