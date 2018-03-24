if !CPTBase then return end
AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('ai_schedules.lua')
include('shared.lua')
include('tasks.lua')
include('states.lua')

ENT.ModelTable = {}
ENT.CollisionBounds = Vector(0,0,0)
ENT.StartHealth = 10
ENT.Mass = 5000 // 7670 is standard for attacking chairs and benches | Human sized NPCs
ENT.CanBeRagdolled = true
ENT.RagdolledPosSubtraction = 20
ENT.RagdollRecoveryTime = 5

ENT.Swim_CheckYawDistance = 250
ENT.Swim_CheckPitchDistance = 75
ENT.Swim_WaterLevelCheck = 0 -- The enemy's water level must be higher than this to target

ENT.ViewDistance = 7500
ENT.ViewAngle = 75
ENT.WanderChance = 60
ENT.CanChaseEnemy = true
ENT.MeleeAngle = 60
ENT.HearingDistance = 900
ENT.PhysicsDistance = 80
ENT.FlyUpOnSpawn = true
ENT.FlyUpOnSpawn_Time = 2
ENT.FlyRandomDistance = 400
ENT.Faction = "FACTION_NONE"
ENT.FriendlyToPlayers = false
ENT.Confidence = 2 -- 0 = Runs From Everything, 1 = Only Fights Weak Enemies, 2 = Normal AI, 3 = Will Fight Most Enemies, 4 = No Fear

ENT.HasAlertAnimation = false
ENT.AlertAnimationChance = 5
ENT.HasFlinchAnimation = false
ENT.FlinchChance = 10

ENT.IsEssential = false
ENT.Bleeds = true
ENT.BloodEffect = {}
ENT.LeavesBlood = true -- Don't need to change this if the table below is empty, it'll just not make decals
ENT.BloodDecal = {}
ENT.HasDeathRagdoll = true
ENT.HasDeathAnimation = false
ENT.ExtraDeathTime = 0
ENT.CanMutate = true -- This is basically fallout 4's mutation system in which the enemy becomes stronger near death

ENT.UseTimedSteps = false
ENT.NextFootSound_Walk = 0.45
ENT.NextFootSound_Run = 0.45

ENT.SoundDirectory = nil
ENT.SetupSoundTables = false -- Won't be as accurate as you setting them up yourself
ENT.CheckForLoopsInSoundDirectory = true -- Makes sure looping sounds don't get added

ENT.PossessorView = {
	Pos = {Right = 0,Forward = 0,Up = 0}
}

ENT.tbl_Animations = {}
ENT.tbl_Sounds = {}
ENT.tbl_Sentences = {}
ENT.tbl_ImmuneTypes = {}
ENT.tbl_Capabilities = {}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:AfterInit() end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThink_Disabled() end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnCondition(cond,state) end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:HandleSchedules(enemy,dist,nearest,disp)
	if(disp == D_HT) then
		self:ChaseEnemy()
	elseif(disp == D_FR) then
		self:Hide()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:HandleFlying(enemy,dist,nearest)
	local pos = self:GetPos() +self:OBBCenter()
	local tr = util.TraceHull({
		start = pos,
		endpos = enemy:GetPos() +enemy:OBBCenter() +enemy:GetUp() *20,
		filter = self,
		mins = self:OBBMins(),
		maxs = self:OBBMaxs()
	})
	if (tr.Hit) then
		local fly = (util.RandomVectorAroundPos(tr.HitPos,self.FlyRandomDistance) -self:GetPos() +self:GetVelocity() *30):GetNormal() *self:GetFlySpeed()
		self:SetAngles(Angle(0,(self:FindCenter(self:GetEnemy()) -self:FindCenter(self)):Angle().y,0))
		self:SetLocalVelocity(fly)
	end
	if nearest < self.BackAwayDistance then
		local fly = (util.RandomVectorAroundPos(tr.HitPos,self.FlyRandomDistance) +self:GetPos() +self:GetVelocity() *15):GetNormal() *self:GetFlySpeed()
		self:SetAngles(Angle(0,(self:FindCenter(self:GetEnemy()) -self:FindCenter(self)):Angle().y,0))
		self:SetLocalVelocity(-fly)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:HandleSchedules_Fly(enemy,dist,nearest,disp)
	if self.IsStartingUp == true then
		self.IsStartingUp = false
		self:SetLocalVelocity(Vector(0,0,0))
	end
	if(disp == D_HT) then
		self:HandleFlying(enemy,dist,nearest)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnHearSound(ent)
	if ent:Visible(self) then
		self:SetTarget(ent)
		self:SetSchedule(SCHED_TARGET_FACE)
	elseif !ent:Visible(self) then
		local NoisePos = util.RandomVectorAroundPos(self:FindCenter(ent),150,true)
		self:SetLastPosition(NoisePos)
		self:TASKFUNC_LASTPOSITION()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThink() end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnEnemyChanged(ent) end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnFoundEnemy(count,oldcount,ent) end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnKilledEnemy(ent) end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnAreaCleared() end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnRagdollRecover() end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CheckRagdollSettings() end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnDeath(dmg,dmginfo,hitbox) end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetUpRangeAttackTarget()
	if self.IsPossessed then
		return (self:Possess_AimTarget() -self:LocalToWorld(Vector(0,0,0)))
	else
		if self:GetEnemy() != nil then
			if self:GetEnemy():IsPlayer() then
				return ((self:GetEnemy():GetPos() -self:LocalToWorld(Vector(0,0,0))) +self:CheckPlayerMoveDirection(self:GetEnemy()))
			else
				return (self:GetEnemy():GetPos() -self:LocalToWorld(Vector(0,0,0)))
			end
		else
			return ((self:GetPos() +self:GetForward() *900) -self:LocalToWorld(Vector(0,0,0)))
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CheckPlayerMoveDirection(ent)
	local addvel
	local extravel
	if ent:KeyDown(IN_RUN) then
		extravel = ent:GetRunSpeed()
	else
		extravel = ent:GetWalkSpeed()
	end
	if ent:KeyDown(IN_MOVELEFT) then
		addvel = ent:GetRight() *-extravel
	elseif ent:KeyDown(IN_MOVERIGHT) then
		addvel = ent:GetRight() *extravel
	elseif ent:KeyDown(IN_FORWARD) && self:GetClosestPoint(ent) > extravel *1.65 then
		addvel = ent:GetForward() *extravel
	elseif ent:KeyDown(IN_BACK) then
		addvel = ent:GetForward() *-extravel
	else
		addvel = ent:GetForward() *0
	end
	return addvel
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Possess_FaceAimPosition()
	self:SetAngles(Angle(0,(self:Possess_AimTarget() -self:FindCenter(self)):Angle().y,0))
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Possess_AimTarget()
	return self:Possess_EyeTrace(self.Possessor).HitPos
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Possess_EyeTrace(possessor)
	local tracedata = {}
	tracedata.start = possessor:GetEyeTrace().HitPos
	tracedata.endpos = tracedata.start +possessor:GetAimVector() *32768
	tracedata.filter = {possessor,self}
	return util.TraceLine(tracedata)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Possess_Commands(possessor)
	if possessor:KeyDown(IN_ATTACK) then
		return self:Possess_Primary(possessor)
	elseif possessor:KeyDown(IN_ATTACK2) then
		return self:Possess_Secondary(possessor)
	elseif possessor:KeyDown(IN_DUCK) then
		return self:Possess_Duck(possessor)
	elseif possessor:KeyDown(IN_JUMP) then
		return self:Possess_Jump(possessor)
	elseif possessor:KeyDown(IN_RELOAD) then
		return self:Possess_Reload(possessor)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Possess_Move(possessor)
	local posMove = self:GetPos()
	local posMoveTrace = possessor:GetEyeTrace().HitPos
	local posTraceTest = self:DoCustomTrace(self:GetPos() +Vector(0,0,20),posMoveTrace,{self},true)
	local posTestOutput = math.Clamp((self:GetPos():Distance(posTraceTest.HitPos)),0,350)
	local posAim = possessor:GetAimVector()
	if self:GetMoveType() != MOVETYPE_FLY then
		if !self:CanPerformProcess() then return end
		if (possessor:KeyDown(IN_FORWARD)) then
			self:SetAngles(Angle(0,math.ApproachAngle(self:GetAngles().y,((self:Possess_AimTarget() -self:Possess_EyeTrace(self.Possessor).Normal) -self:GetPos()):Angle().y,20),0))
			-- self:PlayerChat("hit "..tostring(posTraceTest.HitPos.z))
			-- self:PlayerChat("self "..tostring(self:GetPos().z -20))
			-- if posTraceTest.HitPos.z < self:GetPos().z && self:GetPos():Distance(posTraceTest.HitPos) <= posTestOutput then
				-- self:PlayerChat("Yaes")
				-- posMove = posTraceTest.HitPos
			-- else
				-- posMove = self:GetPos() +self:GetForward() *200
			-- end
			if GetConVarNumber("cpt_usetracemovement") == 1 then
				posMove = posTraceTest.HitPos +Vector(0,0,10)
			else
				posMove = self:GetPos() +self:GetForward() *200
			end
			if (possessor:KeyDown(IN_MOVELEFT)) then
				posMove = self:GetPos() +self:GetForward() *200 +self:GetRight() *-200
			elseif (possessor:KeyDown(IN_MOVERIGHT)) then
				posMove = self:GetPos() +self:GetForward() *200 +self:GetRight() *200
			end
			self:SetLastPosition(posMove)
			if (possessor:KeyDown(IN_SPEED)) then
				self:TASKFUNC_RUNTOPOS()
			else
				self:TASKFUNC_WALKTOPOS()
			end
		elseif (possessor:KeyDown(IN_BACK)) then
			self:SetAngles(Angle(0,math.ApproachAngle(self:GetAngles().y,possessor:GetAimVector():Angle().y,4),0))
			local PlayersVectorBack = possessor:GetAimVector() *-1
			PlayersVectorBack.z = 0
			posMove = self:GetPos() +(PlayersVectorBack *200)
			if (possessor:KeyDown(IN_MOVELEFT)) then
				posMove = self:GetPos() +(PlayersVectorBack *200) +self:GetRight() *-200
			elseif (possessor:KeyDown(IN_MOVERIGHT)) then
				posMove = self:GetPos() +(PlayersVectorBack *200) +self:GetRight() *200
			end
			self:SetLastPosition(posMove)
			if (possessor:KeyDown(IN_SPEED)) then
				self:TASKFUNC_RUNTOPOS()
			else
				self:TASKFUNC_WALKTOPOS()
			end
		elseif (possessor:KeyDown(IN_MOVELEFT)) then
			self:SetAngles(Angle(0,math.ApproachAngle(self:GetAngles().y,possessor:GetAimVector():Angle().y,4),0))
			posMove = self:GetPos() +(possessor:GetRight() *-200)
			self:SetLastPosition(posMove)
			if (possessor:KeyDown(IN_SPEED)) then
				self:TASKFUNC_RUNTOPOS()
			else
				self:TASKFUNC_WALKTOPOS()
			end
		elseif (possessor:KeyDown(IN_MOVERIGHT)) then
			self:SetAngles(Angle(0,math.ApproachAngle(self:GetAngles().y,possessor:GetAimVector():Angle().y,4),0))
			posMove = self:GetPos() +(possessor:GetRight() *200)
			self:SetLastPosition(posMove)
			if (possessor:KeyDown(IN_SPEED)) then
				self:TASKFUNC_RUNTOPOS()
			else
				self:TASKFUNC_WALKTOPOS()
			end
		elseif (!possessor:KeyDown(IN_SPEED) && !possessor:KeyDown(IN_MOVERIGHT) && !possessor:KeyDown(IN_MOVELEFT) && !possessor:KeyDown(IN_BACK) && !possessor:KeyDown(IN_FORWARD)) then
			self:StopCompletely()
		end
	elseif self:GetMoveType() == MOVETYPE_FLY then
		if self.bInSchedule then
			if self.IsSwimType == false then
				self:TurnToDegree(posAim:Angle())
			else
				self:TurnToDegree(self:GetMaxYawSpeed(),possessor:GetEyeTrace().HitPos,true,42)
			end
		end
		local IsMoving_Fly
		local MovementAmount = Vector(0,0,0)
		if possessor:KeyDown(IN_FORWARD) then
			MovementAmount = posAim
			IsMoving_Fly = true
		end
		if self.IsSwimType == false then
			if possessor:KeyDown(IN_BACK) then
				MovementAmount = MovementAmount +posAim *-1
				IsMoving_Fly = true
			end
			if possessor:KeyDown(IN_MOVERIGHT) then
				MovementAmount = MovementAmount +posAim:Angle():Right()
				IsMoving_Fly = true
			end
			if possessor:KeyDown(IN_MOVELEFT) then
				MovementAmount = MovementAmount +posAim:Angle():Right() *-1
				IsMoving_Fly = true
			end
		end
		local velocity = self:GetVelocity()
		if IsMoving_Fly && velocity:Length() <= 10 then
			velocity = Vector(0,0,0)
		end
		local speedtype
		if self.IsSwimType == false then
			speedtype = (MovementAmount +velocity:GetNormal()) *self:GetFlySpeed()
		else
			speedtype = (MovementAmount +velocity:GetNormal()) *self:GetSwimSpeed()
		end
		self:SetLocalVelocity(speedtype)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Possess_Think(possessor) end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Possess_Primary(possessor)
	if self.DoAttack then
		self:DoAttack()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Possess_Secondary(possessor)
	if self.DoRangeAttack then
		-- if self:GetEnemy() == nil then possessor:ChatPrint("No Valid Enemy To Target") return end
		self:DoRangeAttack()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Possess_Jump(possessor)
	if self.DoLeapAttack then
		if self:GetEnemy() == nil then possessor:ChatPrint("No Valid Enemy To Target") return end
		self:DoLeapAttack()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Possess_Duck(possessor) end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Possess_Reload(possessor) end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnAttackFinish() end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomChecksForProcesses()
	return false
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CanPerformProcess()
	if self.IsAttacking == true or self.IsPlayingActivity == true or self.IsRangeAttacking == true or self.IsRagdolled == true or self.bInSchedule == true or self.IsPlayingSequence == true or self:CustomChecksForProcesses() then
		return false
	else
		return true
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnSpawn_Fly()
	if self:GetEnemy() == nil && self.FlyUpOnSpawn == true then
		local time = self.FlyUpOnSpawn_Time
		self.IsStartingUp = true
		self:SetLocalVelocity(self:GetVelocity() *0.9 +self:GetUp() *self.FlySpeed /4)
		timer.Simple(time,function()
			if (self:IsValid() && self:GetEnemy() == nil && self.IsStartingUp == true) then
				self.IsStartingUp = false
				self:SetLocalVelocity(Vector(0,0,0))
			end
		end)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:WhileFalling() end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnLand() end
---------------------------------------------------------------------------------------------------------------------------------------------
/*
	Can be called like this:
	function ENT:Initialize() self:SetModel(self:LoadObjectData("sky","draugr").["Models"][1]) end
	function ENT:CreateParticleOnAttack() ParticleEffect(self:LoadObjectData("sky","draugr").["Particles"][1],blah,blah,blah) end
*/
function ENT:LoadObjectData(datamod,dataname) // Similar to PredatorCZ's system, except in my own way :)
	local cache = "models/cpthazama/" .. datamod .. "/" .. dataname .. ".cod"
	local files = file.Find(cache .. "/" .. "*","GAME")
	local objectcache = {
		["Models"] = {},
		["Particles"] = {},
		["Sounds"] = {},
	}
	for _,data in ipairs(files) do
		if string.find(data,".mdl") then
			table.insert(objectcache["Models"],data)
		end
		if string.find(data,".pcf") then
			table.insert(objectcache["Particles"],data)
		end
		if string.find(data,".wav") then
			table.insert(objectcache["Sounds"],data)
		end
	end
	return objectcache
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Initialize()
	self:SetSpawnEffect(false)
	self.CPTBase_NPC = true
	self:SetModel(self:SelectFromTable(self.ModelTable))
	self:DrawShadow(true)
	self:SetHullSizeNormal()
	if self.CollisionBounds != Vector(0,0,0) then
		self:SetCollisionBounds(Vector(self.CollisionBounds.x,self.CollisionBounds.y,self.CollisionBounds.z),-(Vector(self.CollisionBounds.x,self.CollisionBounds.y,0)))
	end
	self:SetSolid(SOLID_BBOX)
	self:SetMaxYawSpeed(50)
	self:SetHealth(self.StartHealth)
	self:SetMaxHealth(self.StartHealth)
	-- self:SetMovementType(MOVETYPE_STEP)
	self:SetCollisionGroup(COLLISION_GROUP_NPC)
	self:SetEnemy(NULL)
	self.HasSetTypeOnSpawn = false
	self.IsPossessed = false
	self.Possessor = nil
	self.tbl_EnemyMemory = {}
	self.EnemyMemoryCount = 0
	self:ClearMemory()
	self.IsDead = false
	self.HasStoppedMovingToAttack = false
	self.NextAnimT = 0
	self.IdleAnimation = ACT_IDLE
	self.NextIdleAnimationT = 0
	self.IsRagdolled = false
	self.LoopedSounds = {}
	self.tblBlackList = {}
	self.bInSchedule = false
	self.IsStartingUp = false
	self.CurrentHeardEnemy = nil
	self.NextHearSoundT = 0
	self.IsPlayingSequence = false
	self.IsPlayingActivity = false
	self.NextMutT = 0
	self.HasMutated = false
	self.MutationHealth = math.Round(self.StartHealth /3.8)
	local color
	local colorchance = math.random(1,3)
	if colorchance == 1 then
		color = "green"
		self.MutationType = "health"
	elseif colorchance == 2 then
		color = "red"
		self.MutationType = "damage"
	elseif colorchance == 3 then
		color = "yellow"
		self.MutationType = "both"
	end
	self.MutationEmbers = "cpt_mutationembers_" .. color
	self.MutationGlow = "cpt_mutationglow_" .. color
	self.LostWeapon = false
	self.LastUsedWeapon = nil
	self.IsSwimType = false
	self.NextSwimDirection_YawT = 0
	self.NextSwimDirection_PitchT = 0
	self.TimeSinceLastTimeFalling = 0

	if table.Count(self.tbl_Capabilities) > 0 then
		for _,cap in ipairs(self.tbl_Capabilities) do
			if type(cap) == "number" then
				self:CapabilitiesAdd(bit.bor(cap))
			end
		end
	end

	self:UpdateFriends()
	self:UpdateEnemies()
	self:UpdateRelations()

	if self.SetupSoundTables == true then
		if self.SoundDirectory == nil then MsgN("CPTBase warning: " .. self .. " has no sound directory. Please add a sound directory.") return end
		self:FindSounds()
	end

	self:SetInit()
	self:AfterInit()
	if self.HasSetTypeOnSpawn == false then self:SetMovementType(MOVETYPE_STEP) end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetInit()
	self:SetHullType(HULL_HUMAN)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnInputAccepted(event,activator) end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:AcceptInput(input,activator,caller,data)
	self:OnInputAccepted(input,activator)
	if(activator == self && string.Left(input,6) == "event_") then
		self:RunEvents(string.sub(input,7))
		return true
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
local arguements = {}
function ENT:RunEvents(inputevent)
	local stringpercent = string.find(inputevent,"%s")
	local eventend = stringpercent or string.find(inputevent,"$")
	local event = string.Left(inputevent,eventend -1)
	local args
	if(stringpercent) then
		args = string.sub(inputevent,stringpercent +1)
		args = string.Explode(",",args)
	else
		args = arguements
	end
	if(!self:HandleEvents(event,unpack(args))) then
		MsgN("Unhandled animation event '" .. event .. "'" .. (args && ("('" .. table.concat(args,"','") .. "')") or "") .. " for " .. tostring(self) .. ".")
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:HandleEvents(...)
	//local event = select(1,...)
	//local arg1 = select(2,...)
	//local arg2 = select(3,...)
	//if(event == "mattack") then
		//if(arg1 == "left") then
			//self:DoDamage(self.MeleeAttackDamageDistance,self.MeleeAttackDamage,self.MeleeAttackType)
		//end
		//return true
	//end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CheckMeleeDistance(ExtraDist)
	if self.MeleeAttackDistance != nil && self:GetEnemy() != nil then
		if self:GetEnemy():GetPos():Distance(self:GetPos()) <= self.MeleeAttackDistance +ExtraDist && self.HasStoppedMovingToAttack == false then
			self:StopCompletely()
			self.HasStoppedMovingToAttack = true
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.NextRelationshipCheckT = 0
function ENT:UpdateRelations()
	if CurTime() > self.NextRelationshipCheckT then
		for _,v in ipairs(ents.GetAll()) do
			if v:IsNPC() && v.Faction != nil && v != self then
				-- self:PlayerChat("ent has proper setup")
				if self.Faction != v.Faction && self:Disposition(v) != D_HT then
					-- self:PlayerChat("i hate")
					if self:CheckConfidence(v) == "attack!" then
						self:SetRelationship(v,D_HT)
					elseif self:CheckConfidence(v) == "run!" then
						self:SetRelationship(v,D_FR)
					end
				elseif self.Faction == v.Faction && self:Disposition(v) != D_LI then
					-- self:PlayerChat("i like")
					self:SetRelationship(v,D_LI)
				end
			end
		end
		self.NextRelationshipCheckT = CurTime() +0.1
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
local alreadyreset = false
function ENT:CheckPoseParameters()
	if self:CheckForValidMemory() <= 0 && alreadyreset == false then
		alreadyreset = true
		self:ClearPoseParameters()
		self:ClearMemory()
	else
		alreadyreset = false
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Think()
	-- self:NextThink(CurTime() +0.1)
	-- print(self.CurrentSchedule,self.CurrentTask,self.IsPlayingSequence)
	if self.IsDead == true then return end
	self:OnThink_Disabled()
	local idleanim = self:GetIdleAnimation()
	if idleanim == nil then idleanim = ACT_IDLE end
	if self:IsMoving() then self:SetArrivalActivity(idleanim) end
	if self.IsRagdolled == true then
		self:SetPos(self:FindCenter(self.Ragdoll_CPT) -Vector(0,0,self.RagdolledPosSubtraction))
		self:SetAngles(self.Ragdoll_CPT:GetAngles())
		self:SetNoDraw(true)
		self:DrawShadow(false)
		self.bInSchedule = true
		self:CheckRagdollSettings()
	end
	-- if self.HasMutated == true then
		-- self:SetMutationEffects()
	-- end
	if GetConVarNumber("ai_disabled") == 1 then return end
	if self.IsPlayingSequence == true then
		self.CurrentSchedule = nil
		self.CurrentTask = nil
	end
	-- print(self.cpt_Schedule_Walking,self.cpt_Schedule_Running)
	if self:GetMoveType() == MOVETYPE_STEP then
		if self.cpt_Schedule_Walking == true then
			self:SetMovementAnimation("Walk")
		elseif self.cpt_Schedule_Running == true then
			self:SetMovementAnimation("Run")
		end
	end
	if self.IsPossessed then
		if self.IsLeapAttacking then self:Possess_FaceAimPosition() end
		if self.IsRangeAttacking then self:Possess_FaceAimPosition() end
		if self.IsAttacking then self:Possess_FaceAimPosition() end
	end
	self:UpdateFriends() // Should these be ran in think?
	self:UpdateEnemies()
	self:UpdateRelations()
	self:UpdateMemory()
	-- self:CheckPoseParameters()
	-- self:UpdateRelations()
	-- if self.CurrentHeardEnemy != nil then
		-- if self.CurrentSchedule == nil then
			-- self:TASKFUNC_FACEPOSITION(self.CurrentHeardEnemy:GetPos())
		-- end
	-- end
	self:PoseParameters()
	if self.IsSwimType == false then
		if self:IsFalling() then
			self:WhileFalling()
			self.TimeSinceLastTimeFalling = CurTime() +0.2
		elseif !self:IsFalling() && self.TimeSinceLastTimeFalling > 0 && self.TimeSinceLastTimeFalling <= CurTime() then
			self:OnLand()
			self.TimeSinceLastTimeFalling = 0
		end
	end
	if self.IsSwimType == true then
		self:SwimAI()
		if self.IsPossessed then
			self.Possessor:ChatPrint("Swim AI is not possessable yet. Press E to exit the SNPC.")
		end
	end
	if self:GetEnemy() != nil && !self.IsPossessed then
		if self.MeleeAttackDistance != nil then
			for _,v in ipairs(ents.FindInSphere(self:GetPos(),self.MeleeAttackDistance)) do
				if self:FindInCone(v,self.MeleeAngle) && (self:FindDistance(v) <= self.PhysicsDistance) then
					self:DetectDoors(v,true)
					self:DetectProps(v,true)
				end
			end
		end
		local enemy = self:GetEnemy()
		local dist = self:FindCenterDistance(enemy)
		local nearest = self:GetClosestPoint(enemy)
		local disp = self:Disposition(enemy)
		if self:MovementType() != MOVETYPE_FLY then
			if self.bInSchedule != true && !self.IsPossessed then
				self:HandleSchedules(enemy,dist,nearest,disp)
			end
		else
			if self.IsSwimType != true then
				self:HandleSchedules_Fly(enemy,dist,nearest,disp)
			else
				self:HandleSchedules(enemy,dist,nearest,disp)
			end
		end
	end
	self:FootStepCode()
	self:OnThink()
	for _,v in pairs(ents.FindInSphere(self:GetPos(),self.HearingDistance)) do
		if self:GetEnemy() != nil then return end
		if v:IsPlayer() && GetConVarNumber("ai_ignoreplayers") == 0 then
			if (!v:Crouching() && (v:KeyDown(IN_FORWARD) or v:KeyDown(IN_BACK) or v:KeyDown(IN_MOVELEFT) or v:KeyDown(IN_MOVERIGHT) or v:KeyDown(IN_JUMP))) then
				if self:GetDistanceToVector(v:GetPos(),1) <= self.HearingDistance then
					self:OnHearSound(v)
				end
			end
		elseif v:IsNPC() && v != self && (v:GetFaction() != nil && v.Faction != self:GetFaction()) then
			if v:IsMoving() && v:Disposition(self) != D_LI then
				if self:GetDistanceToVector(v:GetPos(),1) <= self.HearingDistance then
					self:OnHearSound(v)
				end
			end
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Swim_TurnAngle(turn)
	local ang = self:GetAngles()
	if turn == "right" then
		-- self:PlayerChat("GO RIGHT")
		ang.y = ang.y -self:GetMaxYawSpeed()
	elseif turn == "left" then
		-- self:PlayerChat("GO LEFT")
		ang.y = ang.y +self:GetMaxYawSpeed()
	elseif turn == "down" then
		if ang.p < 50 then
			-- self:PlayerChat("GO DOWN")
			ang.p = ang.p +self:GetMaxYawSpeed()
		end
	elseif turn == "up" then
		if ang.p > -42 then
			-- self:PlayerChat("GO UP")
			ang.p = ang.p -self:GetMaxYawSpeed()
		end
	end
	self:SetAngles(ang)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnOutsideWater()
	self:SetLocalVelocity(Vector(0,0,0))
	self:SetIdleAnimation(ACT_IDLE)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SwimAI()
	if self:WaterLevel() == 0 then self:OnOutsideWater() return end
	if self.IsPossessed then
		if self.tbl_Animations["Swim"] == nil then
			self:SetIdleAnimation(ACT_SWIM)
		else
			self:SetIdleAnimation(self:SelectFromTable(self.tbl_Animations["Swim"]))
		end
		return
	end
	if self:GetEnemy() != nil && self:GetEnemy():WaterLevel() < self.Swim_WaterLevelCheck then
		self:RemoveFromMemory(self:GetEnemy())
		self:SetEnemy(NULL)
	end
	local ang = self:GetAngles()
	local trace_forward = self:DoCustomTrace_Mask(self:GetPos(),self:GetPos() +self:GetForward() *self.Swim_CheckYawDistance,nil,{self})
	local trace_left = self:DoCustomTrace_Mask(self:GetPos(),self:GetPos() +self:GetRight() *-self.Swim_CheckYawDistance,nil,{self})
	local trace_right = self:DoCustomTrace_Mask(self:GetPos(),self:GetPos() +self:GetRight() *self.Swim_CheckYawDistance,nil,{self})
	local trace_up = self:DoCustomTrace_Mask(self:GetPos(),self:GetPos() +Vector(0,0,self.Swim_CheckPitchDistance),nil,{self})
	local trace_down = self:DoCustomTrace_Mask(self:GetPos(),self:GetPos() -Vector(0,0,self.Swim_CheckPitchDistance),nil,{self})
	local dist_right = self:GetPos():Distance(trace_right.HitPos)
	local dist_left = self:GetPos():Distance(trace_left.HitPos)
	local dist_up = self:GetPos():Distance(trace_up.HitPos)
	local dist_down = self:GetPos():Distance(trace_down.HitPos)
	if self:GetEnemy() == nil then
		if trace_forward.HitWorld then
			if trace_left.HitWorld then
				self:Swim_TurnAngle("right")
			elseif trace_right.HitWorld then
				self:Swim_TurnAngle("left")
			else
				self:Swim_TurnAngle("right")
			end
			if trace_down.HitWorld then
				self:Swim_TurnAngle("up")
			end
			if trace_up.HitWorld then
				self:Swim_TurnAngle("down")
			end
		elseif trace_down.HitWorld then
			if dist_down < self.Swim_CheckPitchDistance then
				self:Swim_TurnAngle("up")
			else
				ang.p = 0
				self:SetAngles(ang)
			end
		elseif trace_up.HitWorld then
			if dist_up < self.Swim_CheckPitchDistance then
				self:Swim_TurnAngle("down")
			else
				ang.p = 0
				self:SetAngles(ang)
			end
		else
			if CurTime() > self.NextSwimDirection_YawT then
				if math.random(1,2) == 1 then
					self:Swim_TurnAngle("left")
				else
					self:Swim_TurnAngle("right")
				end
				self.NextSwimDirection_YawT = CurTime() +0.5
			end
			if CurTime() > self.NextSwimDirection_PitchT then
				if math.random(1,4) == 1 or math.random(1,4) == 2 or math.random(1,4) == 3 then
					self:Swim_TurnAngle("down")
				else
					self:Swim_TurnAngle("up")
				end
				self.NextSwimDirection_PitchT = CurTime() +0.5
			end
		end
		local swimvelocity = self:GetForward() *self:GetSwimSpeed()
		if self:WaterLevel() < 3 && swimvelocity.z > 0 then
			swimvelocity.z = 0
		end
		self:SetLocalVelocity(swimvelocity)
		if self.tbl_Animations["SwimFast"] == nil then
			self:SetIdleAnimation(ACT_GLIDE)
		else
			self:SetIdleAnimation(self:SelectFromTable(self.tbl_Animations["Swim"]))
		end
	else
		local enemypos = self:GetEnemy():GetPos() +self:GetEnemy():OBBCenter()
		local enemyang = self:GetEnemy():GetAngles()
		self:TurnToDegree(self:GetMaxYawSpeed(),enemypos,true,42)
		-- self:PlayerChat(tostring("me "..self:GetPos().z.." npc "..self:GetEnemy():GetPos().z))
		-- if (self:GetPos().z < self:GetEnemy():GetPos().z) then
			-- self:Swim_TurnAngle("up")
		-- elseif (self:GetPos().z > self:GetEnemy():GetPos().z) then
			-- self:Swim_TurnAngle("down")
		-- end
		local swimvelocity = self:GetForward() *self.SwimSpeedEnhanced
		if self:WaterLevel() < 3 && swimvelocity.z > 0 then
			swimvelocity.z = 0
		end
		self:SetLocalVelocity(swimvelocity)
		if self.tbl_Animations["Swim"] == nil then
			self:SetIdleAnimation(ACT_SWIM)
		else
			self:SetIdleAnimation(self:SelectFromTable(self.tbl_Animations["Swim"]))
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:GetSwimSpeed() return self.SwimSpeed end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetSwimSpeed(speed)
	self.SwimSpeed = speed
	self.DefaultSwimSpeed = speed
	self.SwimSpeedEnhanced = self.DefaultSwimSpeed +80
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:GetFlySpeed() return self.FlySpeed end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetFlySpeed(speed)
	self.FlySpeed = speed
	self.DefaultFlySpeed = speed
	self.FlySpeedEnhanced = self.DefaultFlySpeed +80
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetMovementType(move,onspawn)
	local types = {MOVETYPE_STEP,MOVETYPE_NONE,MOVETYPE_FLY,MOVETYPE_SWIM}
	if table.HasValue(types,move) then
		self.MoveType = move
		if move == MOVETYPE_FLY then
			self:CapabilitiesAdd(bit.bor(CAP_MOVE_SWIM,CAP_SKIP_NAV_GROUND_CHECK))
			self:CapabilitiesRemove(CAP_MOVE_GROUND)
			self:CapabilitiesRemove(CAP_MOVE_JUMP)
			self:CapabilitiesRemove(CAP_MOVE_CLIMB)
			self:CapabilitiesRemove(CAP_MOVE_SHOOT)
			self:CapabilitiesRemove(CAP_MOVE_FLY)
			self.IsSwimType = false
			if onspawn != false then
				self:OnSpawn_Fly()
			end
			self:SetMoveType(move)
		elseif move == MOVETYPE_SWIM then
			self:CapabilitiesAdd(bit.bor(CAP_MOVE_FLY,CAP_SKIP_NAV_GROUND_CHECK))
			self:CapabilitiesRemove(CAP_MOVE_GROUND)
			self:CapabilitiesRemove(CAP_MOVE_JUMP)
			self:CapabilitiesRemove(CAP_MOVE_CLIMB)
			self:CapabilitiesRemove(CAP_MOVE_SHOOT)
			self.IsSwimType = true
			self:SetMoveType(MOVETYPE_FLY)
		elseif move == MOVETYPE_STEP then
			self:CapabilitiesAdd(bit.bor(CAP_MOVE_GROUND,CAP_SKIP_NAV_GROUND_CHECK))
			self:CapabilitiesRemove(CAP_MOVE_FLY)
			self.IsSwimType = false
			self:SetMoveType(move)
		elseif move == MOVETYPE_NONE then
			self:CapabilitiesRemove(CAP_MOVE_GROUND)
			self:CapabilitiesRemove(CAP_MOVE_JUMP)
			self:CapabilitiesRemove(CAP_MOVE_CLIMB)
			self:CapabilitiesRemove(CAP_MOVE_SHOOT)
			self:CapabilitiesRemove(CAP_MOVE_FLY)
			self:CapabilitiesRemove(CAP_SKIP_NAV_GROUND_CHECK)
			self.IsSwimType = false
			self:SetMoveType(move)
		end
	end
	if self.HasSetTypeOnSpawn == false then
		self.HasSetTypeOnSpawn = true
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:MovementType()
	return self.MoveType
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:DetectDoors(v,attack)
	if v:IsValid() && v:GetClass() == "prop_door_rotating" then
		if (v:IsValid()) then
			if attack == true then
				self:DoAttack()
			end
			if self.MeleeAttackHitTime != nil then
				timer.Simple(self.MeleeAttackHitTime,function()
					if v:IsValid() && self:IsValid() && self.IsAttacking == true && v:GetClass() == "prop_door_rotating" && (v:GetPos():Distance(self:GetPos()) <= self.MeleeAttackDamageDistance) then
						if math.random(1,3) == 1 then
							local finddoors = ents.Create("prop_physics")
							finddoors:SetPos(v:GetPos())
							finddoors:SetAngles(v:GetAngles())
							finddoors:SetModel(v:GetModel())
							finddoors:Spawn()
							finddoors:Activate()
							if v:GetSkin() != nil then
								finddoors:SetSkin(v:GetSkin())
							end
							finddoors:SetMaterial(v:GetMaterial())
							v:Remove()
							timer.Simple(3,function()
								if IsValid(finddoors) then
									finddoors:SetCollisionGroup(1)
								end
							end)
							local finddoors_phys = finddoors:GetPhysicsObject()
							finddoors_phys:ApplyForceCenter((self:GetEnemy():GetPos() -self:LocalToWorld(Vector(0,-8,20))) *150 +(self:GetEnemy():GetPos() +self:GetEnemy():GetUp() *50 -self:GetPos()) *140)
						end
					end
				end)
			end
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:DetectProps(v,attack)
	if v:IsValid() && (v:GetClass() == "prop_physics" /*or v:GetClass() == "func_breakable" or v:GetClass() == "prop_physics_multiplayer"*/) then
		local findprops = v:GetPhysicsObject()
		if (findprops:IsValid() && self:GetPhysicsObject():IsValid() && findprops:GetMass() > 4 && findprops:GetSurfaceArea() > 750 && (self.Mass >= findprops:GetSurfaceArea())) then
			if attack == true then
				self:DoAttack()
			end
			if self.MeleeAttackHitTime != nil then
				timer.Simple(self.MeleeAttackHitTime,function()
					if v:IsValid() && self:IsValid() && self.IsAttacking == true && findprops:IsValid() && (findprops:GetPos():Distance(self:GetPos()) <= self.MeleeAttackDamageDistance) then
						local findprops = v:GetPhysicsObject()
						if (findprops:IsValid() && self:GetPhysicsObject():IsValid() && findprops:GetMass() > 4 && findprops:GetSurfaceArea() > 750 && (self.Mass >= findprops:GetSurfaceArea())) then
							if self:GetEnemy() != nil then
								findprops:EnableMotion(true)
								findprops:Wake()
								findprops:EnableGravity(true)
								if self:GetEnemy():IsValid() then
									findprops:ApplyForceCenter((self:GetEnemy():GetPos() -self:LocalToWorld(Vector(0,-8,20))) *150 +(self:GetEnemy():GetPos() +self:GetEnemy():GetUp() *50 -self:GetPos()) *140)
								end
							end
						end
					end
				end)
			end
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.NextFootSoundT_Walk = 0
ENT.NextFootSoundT_Run = 0
ENT.WalkSoundVolume = 70
ENT.RunSoundVolume = 75
ENT.StepSoundPitch = 100
function ENT:FootStepCode()
	if self.IsRagdolled == true then return end
	if self:IsOnGround() && self:IsMoving() && self.UseTimedSteps == true then
		if table.HasValue(self.tbl_Animations["Walk"],self:GetMovementAnimation()) && CurTime() > self.NextFootSoundT_Walk then
			self:PlaySound("FootStep",self.WalkSoundVolume,90,self.StepSoundPitch,true)
			self:DoPlaySound("FootStep")
			self.NextFootSoundT_Walk = CurTime() + self.NextFootSound_Walk
		end
		if table.HasValue(self.tbl_Animations["Run"],self:GetMovementAnimation()) && CurTime() > self.NextFootSoundT_Run then
			self:PlaySound("FootStep",self.RunSoundVolume,90,self.StepSoundPitch,true)
			self:DoPlaySound("FootStep")
			self.NextFootSoundT_Run = CurTime() + self.NextFootSound_Run
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:DoPlaySound(tbl) end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnPlaySound(sound,tbl) end
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.NextIdleSoundT = 0
ENT.IdleSoundVolume = 80
ENT.IdleSoundPitch = 100
function ENT:SelectSchedule(bSchedule)
	if self.IsDead == true then return end
	if self.bInSchedule == true then return end
	if self.IsPlayingSequence == true then return end
	if self.IsPossessed == false then
		if self:GetEnemy() == nil then
			if CurTime() > self.NextIdleSoundT && math.random(1,3) == 1 then
				if self.tbl_Sentences["Idle"] == nil then
					self:PlaySound("Idle",self.IdleSoundVolume,90,self.IdleSoundPitch)
					self:DoPlaySound("Idle")
				else
					self:PlayNPCSentence("Idle")
				end
				self.NextIdleSoundT = CurTime() +math.random(7,14)
			end
			if self.WanderChance != 0 && math.random(1,self.WanderChance) == 1 then
				self:TASKFUNC_WANDER()
				self:SetMovementAnimation("Walk")
			-- else
				-- self:SetSchedule(SCHED_IDLE_STAND) // Causes animation problems
			end
		end
	else
		if self:GetEnemy() == nil && CurTime() > self.NextIdleSoundT && math.random(1,3) == 1 then
			if self.tbl_Sentences["Idle"] == nil then
				self:PlaySound("Idle",self.IdleSoundVolume,90,self.IdleSoundPitch)
				self:DoPlaySound("Idle")
			else
				self:PlayNPCSentence("Idle")
			end
			self.NextIdleSoundT = CurTime() +math.random(7,14)
		end
	end
	-- self:PlayerChat(tostring(self.EnemyMemoryCount))
	if(self.EnemyMemoryCount == 0) then
		if(self:GetState() == NPC_STATE_ALERT) then
			self:OnAreaCleared()
			self:SetState(NPC_STATE_IDLE)
		end
	end
	self:StartIdleAnimation()
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:ChaseEnemy() // Only run this if you don't care what it's target is
	if self:Disposition(self:GetEnemy()) != D_LI && self:CheckConfidence(self:GetEnemy()) == "attack!" && self.CanChaseEnemy == true then
		self:ChaseTarget(self:GetEnemy(),false)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnChaseEnemy() self:SetMovementAnimation("Run") end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:ChaseTarget(ent,uselastpos)
	if self.bInSchedule == true then return end
	if self.IsPossessed == true then return end
	self:OnChaseEnemy()
	if uselastpos == false then
		self:SetTarget(ent)
		self:TASKFUNC_GETPATHANDGO()
	else
		self:SetLastPosition(ent:GetPos())
		self:TASKFUNC_CHASE()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:StartIdleAnimation()
	local idleanim = self:GetIdleAnimation()
	if self:IsMoving() then self:SetArrivalActivity(idleanim) end
	-- if CurTime() > self.NextIdleAnimationT then
		if self:CanPerformProcess() == false then return end
		if self.IsPlayingSequence == true then return end
		if self.IsPlayingActivity == true then return end
		if self:IsMoving() then return end
		if self.CurrentSchedule == nil && self.CurrentTask == nil then
			if self.bInSchedule == true then return end
			if self.IsPlayingSequence == true then return end
			if self.IsPlayingActivity == true then return end
			if self:GetActivity() != idleanim then
				self:StartEngineTask(GetTaskID("TASK_SET_ACTIVITY"),idleanim)
				self:MaintainActivity()
			end
			-- self.NextIdleAnimationT = CurTime() +self:AnimationLength(idleanim)
		end
	-- end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetIdleAnimation(act)
	if type(act) == "string" then
		act = self:TranslateStringToNumber(act)
	end
	self.IdleAnimation = act
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:GetIdleAnimation()
	if self.IdleAnimation == nil then
		return ACT_IDLE
	else
		return self.IdleAnimation
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:PoseParameters()
	if self.IsPossessed then
		self:LookAtPosition(self:Possess_EyeTrace(self.Possessor).HitPos,{"aim_pitch","aim_yaw","head_pitch","head_yaw"},10)
	else
		if self:GetEnemy() != nil then
			-- self:LookAtPosition(self:FindHeadPosition(self:GetEnemy()),{"aim_pitch","aim_yaw","head_pitch","head_yaw"},10)
			self:LookAtPosition(self:FindCenter(self:GetEnemy()),{"aim_pitch","aim_yaw","head_pitch","head_yaw"},10)
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.NextAlertSoundT = 0
ENT.AlertSoundVolume = 85
ENT.AlertSoundPitch = 100
function ENT:OnCondition(iCondition)
	local cond = self:ConditionName(iCondition)
	-- print(cond)
	if self.bInSchedule == true then return end
	if self.bDead == true then return end
	local state = self:GetState()
	self:CustomOnCondition(cond,state)
	if state == NPC_STATE_DEAD then return end
	if state != NPC_STATE_COMBAT then
		self:UpdateEnemies()
		if state != NPC_STATE_LOST && IsValid(self:GetEnemy()) then
			if self.HasAlertAnimation == false then
				if CurTime() > self.NextAlertSoundT then
					if self.tbl_Sentences["Alert"] == nil then
						self:PlaySound("Alert",self.AlertSoundVolume,90,self.AlertSoundPitch)
						self:DoPlaySound("Alert")
					else
						self:PlayNPCSentence("Alert")
					end
					self.NextAlertSoundT = CurTime() +math.random(4,12)
				end
			else
				if math.random(1,self.AlertAnimationChance) == 1 then
					self:PlaySound("Alert",self.AlertSoundVolume,90,self.AlertSoundPitch)
					self:DoPlaySound("Alert")
					self:PlayAnimation("Alert",2)
				end
			end
			self:SetState(NPC_STATE_COMBAT)
		end
		return
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:UpdateFriends()
	for k,v in ipairs(ents.FindInSphere(self:GetPos(),self.ViewDistance)) do
		if v:IsNPC() && v != self && v:Health() > 0 then
			if self:Visible(v) && self:FindDistance(v) <= self.ViewDistance && self:FindInCone(v,self.ViewAngle) then
				if (v:GetFaction() != nil && v.Faction == self:GetFaction()) then
					self:SetRelationship(v,D_LI)
				end
			end
		elseif GetConVarNumber("ai_ignoreplayers") == 0 && v:IsPlayer() && v:Alive() && !v.IsPossessing then
			if self:Visible(v) && self:FindDistance(v) <= self.ViewDistance && self:FindInCone(v,self.ViewAngle) then
				if self:GetFaction() == "FACTION_PLAYER" or self.FriendlyToPlayers == true then
					self:SetRelationship(v,D_LI,true)
				end
			end
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:LocateEnemies()
	for k,v in ipairs(ents.FindInSphere(self:GetPos(),self.ViewDistance)) do
		if v:IsNPC() && v != self && v:GetClass() != self:GetClass() && v:Health() > 0 then
			if (self:Visible(v) && self:FindDistance(v) <= self.ViewDistance && self:FindInCone(v,self.ViewAngle)) then
				if (v:GetFaction() == nil or v:GetFaction() != nil && v.Faction != self:GetFaction()) && self:Disposition(v) != D_LI && !table.HasValue(self.tblBlackList,v) then
					return v
				end
			end
		elseif GetConVarNumber("ai_ignoreplayers") == 0 && v:IsPlayer() && v:Alive() && !v.IsPossessing then
			if (self:Visible(v) && self:FindDistance(v) <= self.ViewDistance && self:FindInCone(v,self.ViewAngle)) then
				if self:GetFaction() != "FACTION_PLAYER" or self:Disposition(v) != D_LI or !table.HasValue(self.tblBlackList,v) then
					return v
				end
			end
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:UpdateEnemies()
	if GetConVarNumber("ai_disabled") == 1 then return end
	local totalenemies = self.EnemyMemoryCount
	if self:GetEnemy() != nil then
		if self:GetEnemy():IsPlayer() && (GetConVarNumber("ai_ignoreplayers") == 1 or self:GetEnemy().IsPossessing) then
			self:RemoveFromMemory(self:GetEnemy())
		end
		if !IsValid(self:GetEnemy()) or self:GetEnemy():Health() <= 0 then
			self:RemoveFromMemory(self:GetEnemy())
		end
	end
	local lastenemy = self:GetEnemy()
	self:UpdateMemory()
	local newenemy = self:LocateEnemies()
	if newenemy == nil then return end
	if newenemy:IsPlayer() then
		if GetConVarNumber("ai_ignoreplayers") == 1 then self:RemoveFromMemory(newenemy) end
		if self:CheckConfidence(newenemy) == "attack!" then
			self:SetRelationship(newenemy,D_HT,true)
		elseif self:CheckConfidence(newenemy) == "run!" then
			self:SetRelationship(newenemy,D_FR,true)
		end
	else
		if self:CheckConfidence(newenemy) == "attack!" then
			self:SetRelationship(newenemy,D_HT)
		elseif self:CheckConfidence(newenemy) == "run!" then
			self:SetRelationship(newenemy,D_FR)
		end
	end
	local findenemy = self:GetClosestEntity(self.tbl_EnemyMemory)
	if lastenemy != findenemy then
		self:SetEnemy(findenemy)
		self:OnEnemyChanged(findenemy)
	end
	if !table.HasValue(self.tbl_EnemyMemory,newenemy) then
		table.insert(self.tbl_EnemyMemory,newenemy)
		local oldcount = self.EnemyMemoryCount
		self.EnemyMemoryCount = self.EnemyMemoryCount +1
		if self.EnemyMemoryCount > 0 && lastenemy != newenemy then
			self:OnFoundEnemy(self.EnemyMemoryCount,oldcount,newenemy)
			return
		end
	end
	return enemymemory
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:UpdateMemory()
	local enemymemory = self.tbl_EnemyMemory
	for _,v in ipairs(enemymemory) do
		if !v:IsValid() or v == NULL or v:Health() <= 0 or (v:IsPlayer() && (!v:Alive() or GetConVarNumber("ai_ignoreplayers") == 1 or v.IsPossessing)) or ((v:IsValid() && self:Disposition(v)) != 1 && (v:IsValid() && self:Disposition(v)) != 2) then
			self:RemoveFromMemory(v)
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:RemoveFromMemory(foundent)
	local enemymemory = self.tbl_EnemyMemory
	if foundent == nil then return false end
	if self.EnemyMemoryCount == 0 then return false end
	enemymemory[foundent] = nil
	self.EnemyMemoryCount = self.EnemyMemoryCount -1
	if self.EnemyMemoryCount < 0 then
		self.EnemyMemoryCount = 0
	end
	-- print(self.EnemyMemoryCount .. "blah")
	if(foundent == self:GetEnemy()) then
		self:SetEnemy(nil)
		self:SetEnemy(NULL)
	end
	return true
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CheckForValidMemory()
	local memory = self.tbl_EnemyMemory
	local nocheck_count = table.Count(memory)
	local checked_memory = {}
	if nocheck_count <= 0 then
		-- self:PlayerChat("Nothing")
		return 0
	elseif nocheck_count > 0 then
		for _,ent in ipairs(memory) do
			-- print(ent == NULL)
			if ent != nil then
				// wut
			else
				table.insert(checked_memory,ent)
			end
		end
		if table.Count(checked_memory) > 0 then
			-- self:PlayerChat("Found " .. tostring(table.Count(checked_memory)))
			return table.Count(checked_memory)
		else
			-- self:PlayerChat("Nothing in Checked")
			return 0
		end
	end
	-- self:PlayerChat("nil")
	return nil
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:ClearMemory()
	self:SetEnemy(nil)
	self.tbl_EnemyMemory = {}
	self.EnemyMemoryCount = 0
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CreateBloodEffects(dmg,hitgroup,dmginfo,doignore)
	if dmg:GetDamagePosition() != Vector(0,0,0) or (self:IsOnFire() && dmginfo:IsDamageType(DMG_BURN) && (DoIgnore == false)) then
		ParticleEffect(self:SelectFromTable(self.BloodEffect),dmg:GetDamagePosition(),Angle(math.random(0,360),math.random(0,360),math.random(0,360)),false)
	else
		ParticleEffect(self:SelectFromTable(self.BloodEffect),self:FindCenter(self),Angle(math.random(0,360),math.random(0,360),math.random(0,360)),false)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CreateBloodDecals(dmg,dmginfo,hitbox)
	if table.Count(self.BloodDecal) <= 0 then return end
	local min,max = 50,500
	local tr = util.TraceLine({
		start = dmginfo:GetDamagePosition(),
		endpos = dmginfo:GetDamagePosition() +dmginfo:GetDamageForce():GetNormal() *math.Clamp(dmginfo:GetDamageForce():Length() *10,min,max),
		filter = self
	})
	util.Decal(self:SelectFromTable(self.BloodDecal),tr.HitPos +tr.HitNormal,tr.HitPos -tr.HitNormal)
	for i = 1,2 do
		if math.random(1,2) == 1 then
			util.Decal(self:SelectFromTable(self.BloodDecal),tr.HitPos +tr.HitNormal +Vector(math.random(-70,70),math.random(-70,70),0),tr.HitPos -tr.HitNormal)
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.NextPainSoundT = 0
ENT.NextShoutForHelpT = 0
function ENT:OnTakeDamage(dmg,hitgroup,dmginfo)
	local dmginfo = DamageInfo()
	-- local dmginfo = self.tblDamageInfo
	local DoIgnore = false
	local _Damage = dmg:GetDamage()
	local _Attacker = dmginfo:GetAttacker()
	local _Type = dmg:GetDamageType()
	local _Pos = dmg:GetDamagePosition()
	local _Force = dmg:GetDamageForce()
	local _Force = dmg:GetInflictor()
	local _Inflictor = dmg:GetInflictor()
	local _Hitbox = self.Hitbox
	for _,v in ipairs(self.tbl_ImmuneTypes) do
		if dmginfo:IsDamageType(v) then
			DoIgnore = true
		end
	end
	if DoIgnore == false && self.IsDead == false /*&& self.IsRagdolled == false*/ && self.IsEssential == false && self:BeforeTakeDamage(dmg,_Hitbox) then
		self:SetHealth(self:Health() -dmg:GetDamage())
	end
	if DoIgnore == false then
		if self:BeforeTakeDamage(dmg,_Hitbox) == false then
			DoIgnore = true
		end
	end
	if self.Bleeds == true && DoIgnore == false then
		self:CreateBloodEffects(dmg,_Hitbox,dmginfo,DoIgnore)
		if self.LeavesBlood == true then
			self:CreateBloodDecals(dmg,dmginfo,_Hitbox)
		end
	end
	if self.IsDead == false then
		if CurTime() > self.NextShoutForHelpT then
			for _,v in ipairs(ents.FindInSphere(self:GetPos(),4000)) do
				if v:IsNPC() && v != self && (v:Disposition(self) == D_NU || v:Disposition(self) == D_LI) && v:GetEnemy() == nil then
					v:SetLastPosition(self:GetPos() +Vector(math.random(-200,200),math.random(-200,200),0))
					if v.CPTBase_NPC then
						v:StopCompletely()
						v:TASKFUNC_GETPATHANDGO()
					else
						v:SetSchedule(SCHED_FORCED_GO_RUN)
					end
					self.NextShoutForHelpT = CurTime() +math.random(7,10)
				end
			end
		end
		if self:GetEnemy() == nil then
			if self:GetState() == NPC_STATE_IDLE then
				self:SetState(NPC_STATE_ALERT)
			end
			self:StopCompletely()
			self:TASKFUNC_FACEPOSITION(_Pos)
		end
		if DoIgnore == false then
			self:OnDamage_Pain(dmg,dmginfo,_Hitbox)
		end
	end
	if self.CanMutate == true then
		if math.random(1,20) == 1 && self:Health() <= self.MutationHealth && self.IsDead == false && self.HasMutated == false then
			self.HasMutated = true
			if (self.MutationType == "health" or self.MutationType == "both") then
				self:SetHealth(self.StartHealth +100)
				self:SetMaxHealth(self.StartHealth +100)
			end
		end
	end
	if self:Health() <= 0 && self.IsDead == false then
		self:DoDeath(dmg,dmginfo,_Attacker,_Type,_Pos,_Force,_Inflictor,_Hitbox)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.PainSoundVolume = 82
ENT.PainSoundPitch = 100
ENT.PainSoundChanceA = 2
ENT.PainSoundChanceB = 4
function ENT:OnDamage_Pain(dmg,dmginfo,hitbox)
	if self.HasFlinchAnimation == true then
		self:DoFlinch(dmg,dmginfo,hitbox)
	else
		if math.random(1,2) == 1 && CurTime() > self.NextPainSoundT then
			if self.tbl_Sentences["Pain"] == nil then
				self:PlaySound("Pain",self.PainSoundVolume,90,self.PainSoundPitch)
				self:DoPlaySound("Pain")
			else
				self:PlayNPCSentence("Pain")
			end
			self.NextPainSoundT = CurTime() +math.random(self.PainSoundChanceA,self.PainSoundChanceB)
		end
	end
	self:OnTakePain(dmg,dmginfo,hitbox)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:DoFlinch(dmg,dmginfo,hitbox)
	if math.random(1,self.FlinchChance) == 1 then
		if self.tbl_Sentences["Pain"] == nil then
			self:PlaySound("Pain",self.PainSoundVolume,90,self.PainSoundPitch)
			self:DoPlaySound("Pain")
		else
			self:PlayNPCSentence("Pain")
		end
		self:PlayAnimation("Pain")
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnTakePain(dmg,dmginfo,hitbox) end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:BeforeTakeDamage(dmg,hitbox) return true end
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.DeathSoundVolume = 80
ENT.DeathSoundPitch = 100
function ENT:DoDeath(dmg,dmginfo,_Attacker,_Type,_Pos,_Force,_Inflictor,_Hitbox)
	gamemode.Call("OnNPCKilled",self,dmg:GetAttacker(),dmg:GetInflictor())
	self.IsDead = true
	if self.tbl_Sentences["Death"] == nil then
		self:PlaySound("Death",self.DeathSoundVolume,90,self.DeathSoundPitch)
		self:DoPlaySound("Death")
	else
		self:PlayNPCSentence("Death")
	end
	self:SetNPCState(NPC_STATE_DEAD)
	self:OnDeath(dmg,dmginfo,_Hitbox)
	if self.HasDeathAnimation == true then
		self:SetLocalVelocity(Vector(0,0,0))
		self:PlayAnimation("Death")
		timer.Simple(self:AnimationLength(self.CurrentAnimation) +self.ExtraDeathTime,function()
			if self:IsValid() then
				if self.HasDeathRagdoll == true then
					self:CreateNPCRagdoll()
				end
				self:Remove()
			end
		end)
	else
		if self.HasDeathRagdoll == true then
			self:CreateNPCRagdoll()
		end
		self:Remove()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CreateNPCRagdoll()
	local mdl = self:GetModel()
	local pos = self:GetPos()
	local ang = self:GetAngles()
	local skin = self:GetSkin()
	local rbg = self:GetColor()
	local mat = self:GetMaterial()
	if self.IsRagdolled == true then
		if self.Ragdoll_CPT != nil && self.Ragdoll_CPT:IsValid() then
			mdl = self.Ragdoll_CPT:GetModel()
			pos = self.Ragdoll_CPT:GetPos()
			ang = self.Ragdoll_CPT:GetAngles()
			skin = self.Ragdoll_CPT:GetSkin()
			rbg = self.Ragdoll_CPT:GetColor()
			mat = self.Ragdoll_CPT:GetMaterial()
		end
	end
	local ragdoll = ents.Create("prop_ragdoll")
	ragdoll:SetModel(mdl)
	ragdoll:SetPos(pos)
	ragdoll:SetAngles(ang)
	ragdoll:Spawn()
	ragdoll:Activate()
	ragdoll:SetSkin(skin)
	if self.IsRagdolled == true then
		if self.Ragdoll_CPT != nil && self.Ragdoll_CPT:IsValid() then
			for i = 0,18 do
				ragdoll:SetBodygroup(i,self.Ragdoll_CPT:GetBodygroup(i))
			end
		else
			for i = 0,18 do
				ragdoll:SetBodygroup(i,self:GetBodygroup(i))
			end
		end
	else
		for i = 0,18 do
			ragdoll:SetBodygroup(i,self:GetBodygroup(i))
		end
	end
	ragdoll:SetColor(rbg)
	ragdoll:SetMaterial(mat)
	ragdoll:SetCollisionGroup(1)
	ragdoll.cpt_Corpse = true
	if self:IsOnFire() then
		ragdoll:Ignite(math.random(8,10),1)
		ragdoll:SetColor(Color(182,182,182,255))
		timer.Simple(1,function()
			if ragdoll:IsValid() then
				ragdoll:SetColor(Color(90,90,90,255))
			end
		end)
		timer.Simple(4.5,function()
			if ragdoll:IsValid() then
				ragdoll:SetColor(Color(60,60,60,255))
			end
		end)
		timer.Simple(8,function()
			if ragdoll:IsValid() then
				ragdoll:SetColor(Color(0,0,0,255))
			end
		end)
	end
	ragdoll:SetVelocity(self:GetVelocity())
	for i = 1,128 do -- Credits to Dan
		local dmginfo = DamageInfo()
		local dmgforce = dmginfo:GetDamageForce()
		local bonephys = ragdoll:GetPhysicsObjectNum(i)
		if IsValid(bonephys) then
			local bonepos,boneang = self:GetBonePosition(ragdoll:TranslatePhysBoneToBone(i))
			if(bonepos) then
				bonephys:SetPos(bonepos)
				bonephys:SetAngles(boneang)
				bonephys:SetVelocity(dmgforce/40)
			end
		end
	end
	local the_ragdoll = ragdoll
	timer.Simple(GetConVarNumber("cpt_corpselifetime"),function()
		if IsValid(the_ragdoll) then
			the_ragdoll:Fire("FadeAndRemove","",0)
		end
	end)
	self:OnDeath_CreatedCorpse(the_ragdoll)
	return the_ragdoll
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnDeath_CreatedCorpse(the_ragdoll) end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:RagdollEnemy(dist,vel)
	for _,ent in ipairs(ents.FindInSphere(self:GetPos(),dist)) do
		if ent:IsValid() && self:IsValid() && self:Visible(ent) && ent:Health() > 0 then
			if (ent:IsNPC() && ent != self && self:Disposition(ent) != D_LI && ent:GetModel() != self:GetModel()) && self:FindInCone(ent,self.MeleeAngle) then
				if ent.CanBeRagdolled == false then return end
				if ent.IsRagdolled == true then return end
				if self:GetClosestPoint(ent) <= dist then
					ent:CreateRagdolledNPC(vel,self)
				end
			end
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnRemove()
	if self.Ragdoll_CPT != nil && self.Ragdoll_CPT:IsValid() then
		self.Ragdoll_CPT:Remove()
	end
	self:StopParticles()
	for k,v in pairs(self.LoopedSounds) do
		v:Stop()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
// self:DoDamage(150,23,DMG_SLASH,Vector(0,0,0),Angle(0,0,0),OnHit)
// self:DoDamage(150,23,DMG_SLASH,Vector(0,0,0),Angle(0,0,0),function(ent,dmginfo)
//		print(ent)
//		return
// end)
function ENT:DoDamage(dist,dmg,dmgtype,force,viewPunch,OnHit)
	local pos = self:GetPos() +self:OBBCenter() +self:GetForward()*20
	local posSelf = self:GetPos()
	local center = posSelf +self:OBBCenter()
	local didhit
	local tblhit = {}
	local hitpos = Vector(0,0,0)
	for _,ent in ipairs(ents.FindInSphere(pos,dist)) do
		if ent:IsValid() && self:IsValid() && self:Visible(ent) && ent:Health() > 0 then
			self:DetectDoors(ent)
			self:DetectProps(ent)
			if (ent:IsNPC() && ent != self && self:Disposition(ent) != D_LI && ent:GetModel() != self:GetModel()) or (ent:IsPlayer() && ent:Alive()) && (self:GetForward():Dot(((ent:GetPos() +ent:OBBCenter()) -pos):GetNormalized()) > math.cos(math.rad(self.ViewAngle))) then
				if force then
					local forward,right,up = self:GetForward(),self:GetRight(),self:GetUp()
					force = forward *force.x +right *force.y +up *force.z
				end
				didhit = true
				local dmgpos = ent:NearestPoint(center)
				local dmginfo = DamageInfo()
				if self.HasMutated == true && (self.MutationType == "damage" or self.MutationType == "both") then
					dmg = math.Round(dmg *1.65)
				end
				dmginfo:SetDamage(dmg)
				dmginfo:SetAttacker(self)
				dmginfo:SetInflictor(self)
				dmginfo:SetDamageType(dmgtype)
				dmginfo:SetDamagePosition(dmgpos)
				hitpos = dmgpos
				if force then
					dmginfo:SetDamageForce(force)
				end
				if(OnHit) then
					OnHit(ent,dmginfo)
				end
				table.insert(tblhit,ent)
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
		self:OnHitEntity(tblhit,hitpos)
	else
		self:OnMissEntity()
	end
	table.Empty(tblhit)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnHitEntity(hitents,hitpos)
	if self.tbl_Sounds["Strike"] == nil then
		self:EmitSound("npc/zombie/claw_strike" .. math.random(1,3) .. ".wav",55,100)
	else
		self:EmitSound(self:SelectFromTable(self.tbl_Sounds["Strike"]),55,100)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnMissEntity()
	if self.tbl_Sounds["Miss"] == nil then
		self:EmitSound("npc/zombie/claw_miss" .. math.random(1,2) .. ".wav",55,100)
	else
		self:EmitSound(self:SelectFromTable(self.tbl_Sounds["Miss"]),55,100)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:DoTraceAttack(dist,dmg,dmgtype,dmgdist,trace)
	if IsValid(self) then
		local use
		trace = trace or util.QuickTrace(self:GetPos(),self:SetUpRangeAttackTarget(),{self})
		if self:GetEnemy() != nil then
			use = self:FindDistance(self:GetEnemy())
		else
			use = 9999999
		end
		if !self.IsPossessed then
			if use > dist then return end
		end
		local traceHit = trace
		local dodmg = DamageInfo()
		dodmg:SetDamageType(dmgtype)
		dodmg:SetDamage(dmg)
		dodmg:SetAttacker(self)
		dodmg:SetInflictor(self)
		dodmg:SetDamagePosition(traceHit.HitPos)
		self:OnTraceRun(traceHit)
		for _,ent in ipairs(ents.FindInSphere(traceHit.HitPos,dmgdist)) do
			if (ent:IsNPC() && ent != self && self:Disposition(ent) != D_LI && ent:GetModel() != self:GetModel()) or (ent:IsPlayer() && ent:Alive()) then
				ent:TakeDamageInfo(dodmg)
				self:OnTraceHit(ent,traceHit)
			end
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnTraceRun(traceHit) end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnTraceHit(ent,traceHit) end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:DoRangeAttack_Spawn(ent,pos,force)
	local projectile = ents.Create(ent)
	projectile:SetPos(pos)
	projectile:SetOwner(self)
	projectile:Spawn()
	projectile:Activate()
	local phys = projectile:GetPhysicsObject()
	if IsValid(phys) then
		local vel = self:ProjectileForce(pos,force)
	end
	phys:ApplyForceCenter(vel)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:ProjectileForce(pos,force)
	return ((self:GetEnemy():GetPos() +self:GetEnemy():OBBCenter()) -pos +self:GetEnemy():GetVelocity() *0.35):GetNormal() *force +VectorRand() *math.Rand(0,160)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CheckRelationship(ent)
	if self:Disposition(ent) == D_LI then
		return "like"
	elseif self:Disposition(ent) == D_HT then
		return "hate"
	elseif self:Disposition(ent) == D_NU then
		return "none"
	elseif self:Disposition(ent) == D_FR then
		return "fear"
	else
		return "error"
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:FindSounds()
	self:AutoSetupSoundTable("Idle",{"idle"})
	self:AutoSetupSoundTable("Alert",{"alert","aware","sight","warning","combat","scream","spot"})
	self:AutoSetupSoundTable("Attack",{"attack","swing","charge"})
	self:AutoSetupSoundTable("Pain",{"pain","injured","hurt","hit"})
	self:AutoSetupSoundTable("Death",{"death","die"})
	self:AutoSetupSoundTable("FootStep",{"step","foot","gear","slide"})
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:GetClosestEntity(tbl)
	return self:GetEntitiesByDistance(tbl)[1]
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:GetEntitiesByDistance(tbl)
	local disttbl = {}
	for _,v in ipairs(tbl) do
		if v:IsValid() then
			disttbl[v] = self:FindCenterDistance(v)
		elseif !v:IsValid() && table.HasValue(disttbl,v) then
			disttbl[v] = nil
			table.remove(disttbl,v)
		end
	end
	return table.SortByKey(disttbl,true)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:GetDistanceToVector(pos,type)
	if type == 1 then
		return self:GetPos():Distance(pos)
	elseif type == 2 then
		return self:NearestPoint(pos)
	end
end
