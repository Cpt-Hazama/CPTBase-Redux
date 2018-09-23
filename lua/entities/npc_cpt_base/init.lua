if !CPTBase then return end
AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('ai_schedules.lua')
include('animator.lua')
include('shared.lua')
include('tasks.lua')
include('states.lua')

	-- Adds base_ai data to base_entity --
AccessorFunc(ENT,"m_iClass","NPCClass",FORCE_NUMBER)
AccessorFunc(ENT,"m_fMaxYawSpeed","MaxYawSpeed",FORCE_NUMBER)

if SERVER then
	util.AddNetworkString("cpt_SpeakingPlayer")
end

	-- Initialize Variables --
ENT.ModelTable = {}
ENT.CollisionBounds = Vector(0,0,0) -- Change from Vector(0,0,0) to apply. If set to Vector(0,0,0), it will use HULL type bounds
ENT.StartHealth = 10 -- How much health the NPC starts out with
ENT.Mass = 5000 // 7670 is standard for attacking chairs and benches | Human sized NPCs
ENT.CanBeRagdolled = true -- Can the NPC be ragdolled by enemies if the damage is critical?
ENT.RagdolledPosSubtraction = 20 -- How far "down" the NPC is while ragdolled (the NPC becomes invisible when ragdolled and follows the ragdoll entity around)
ENT.RagdollRecoveryTime = 5 -- How long until the NPC gets up
ENT.MaxTurnSpeed = 50 -- How fast the NPC can turn

	-- AI Variables --
ENT.CanSeeAllEnemies = false -- If set to true, it can see every enemy on the map
ENT.IsBlind = false -- Is the NPC blind? (Experimental)
ENT.FindEntitiesDistance = 7500 -- Same as ViewDistance
ENT.ViewDistance = 7500 -- How far the NPC can see (In WU. Increasing may impact performance)
ENT.ViewAngle = 75 -- How far the NPC can see (Based on a cone system)
ENT.CanWander = true
ENT.WanderChance = 60 -- The change that the NPC will wander while idle
ENT.CanSetEnemy = true -- Can the NPC set its' enemy? (Can be changed at anytime in the code)
ENT.CanChaseEnemy = true -- Can the NPC chase its' enemy? (Can be changed at anytime in the code)
ENT.MeleeAngle = 45 -- How far the melee attack reaches (Based on a cone system) Example: NPC <) Enemy
ENT.ReactsToSound = true -- Will the NPC react to hearing noises?
ENT.HearingDistance = 900 -- How far the NPC can hear noises
ENT.Faction = "FACTION_NONE" -- Required for every NPC. Use the same one amongst your NPCs to make them allies (Only supports one faction per NPC as a way to reduce in-game lag)
ENT.FriendlyToPlayers = false -- Is the NPC friendly to players?
ENT.Confidence = 2 -- Obsolete
ENT.UseDefaultPoseParameters = true -- Can the NPC use pose parameters? (turn head, body, etc.)
ENT.DefaultPoseParameters = {"aim_pitch","aim_yaw","head_pitch","head_yaw"}
ENT.DefaultPoseParamaterSpeed = 20 -- The rate at which the pose parameter will adjust (similar to turning speed)
ENT.ReversePoseParameters = false -- Reverse pose parameters if they were not properly made
ENT.ForceReloadAnimation = false -- Obsolete
ENT.GlobalAnimationSpeed = 1 -- Determines *most* animation speeds (doesn't effect walkframes)
ENT.HasAlertAnimation = false -- Does the NPC play an alerted animation when spotting an enemy?
ENT.AlertAnimationChance = 5 -- Chance the animation will play
ENT.AllowPropDamage = true -- If set to true, the NPC will damage/effect props when it melee attacks
ENT.AttackablePropNames = {"prop_physics","func_breakable","prop_physics_multiplayer","func_physbox"}
ENT.UnfreezeProps = false -- Unfreeze props when they're hit?
ENT.PropAttackForce = Vector(0,0,0) -- Forward, Right, Up
ENT.UseDefaultWeaponThink = true -- True = use the default think code in the weapon, False = use your own
ENT.OverrideWalkAnimation = false -- Replace with an animation name to use
ENT.OverrideRunAnimation = false -- Replace with an animation name to use
ENT.UsePlayermodelMovement = false -- If set to true, it will utilize player animations properly (GMod, CSS, L4D, etc.)
ENT.PlayermodelMovementSpeed_Forward = 1 -- Ranges between -1 and 1 (0 being no movement at all)
ENT.PlayermodelMovementSpeed_Backward = -1 -- Ranges between -1 and 1 (0 being no movement at all)
ENT.PlayermodelMovementSpeed_Left = -1 -- Ranges between -1 and 1 (0 being no movement at all)
ENT.PlayermodelMovementSpeed_Right = 1 -- Ranges between -1 and 1 (0 being no movement at all)
ENT.FallingHeight = 15 -- Determines how many WU until the NPC thinks it is falling

	-- Air AI Variables --
ENT.FlyUpOnSpawn = true -- Will the NPC hover upward to gain some ground when first spawned without any enemies?
ENT.FlyUpOnSpawn_Time = 2 -- Time until the NPC stops hovering upward
ENT.FlyRandomDistance = 400 -- Maximum distance to hover upward

	-- Swim AI Variables --
ENT.Swim_CheckYawDistance = 250 -- Max yaw change
ENT.Swim_CheckPitchDistance = 75 -- Max pitch change
ENT.Swim_WaterLevelCheck = 0 -- The enemy's water level must be higher than this to target

	-- Damage Variables --
ENT.IsEssential = false -- Can the NPC die?
ENT.Bleeds = true -- Does the NPC create blood particles?
ENT.BloodEffect = {}
ENT.LeavesBlood = false -- Don't need to set this to false if the table below is empty, it'll just not make decals
ENT.AutomaticallySetsUpDecals = false -- Not finished yet
ENT.BloodDecal = {}
ENT.HasFlinchAnimation = false -- Does the NPC flinch when attacked?
ENT.FlinchChance = 10 -- Chance the NPC will flinch
ENT.TurnsOnDamage = true -- Does the NPC turn when damaged (No present enemy)
ENT.CanMutate = false -- This is basically fallout 4's mutation system in which the enemy becomes stronger near death
ENT.HasDeathRagdoll = true -- Does the NPC leave a ragdoll when killed?
ENT.DeathRagdollType = "prop_ragdoll"
ENT.DeathRagdollKeepOverrides = true -- Does the ragdoll keep changes on the NPC? (Material, color, etc.)
ENT.HasDeathAnimation = false -- Does the NPC play a death animation when killed?
ENT.ExtraDeathTime = 0 -- Extra added time after the NPC dies (Useful for death animations)

	-- Possessor Variables --
ENT.Possessor_CanBePossessed = true -- Can the NPC be possessed?
ENT.Possessor_UseBoneCamera = false -- Does the possessor camera follow a bone?
ENT.Possessor_BoneCameraName = 1 -- Bone ID
ENT.Possessor_BoneCameraForward = 0
ENT.Possessor_BoneCameraRight = 0
ENT.Possessor_BoneCameraUp = 0
ENT.Possessor_MaxMoveDistanceForward = 300 -- These four variables determine how far the posessor checks to move the NPC. Lowering the numbers may cause problems
ENT.Possessor_MaxMoveDistanceLeft = 125
ENT.Possessor_MaxMoveDistanceRight = 125
ENT.Possessor_MaxMoveDistanceBackward = 150
ENT.Possessor_MinMoveDistance = 55
ENT.Possessor_CanTurnWhileAttacking = true
ENT.Possessor_CanMove = true -- Can the possessed NPC move?
ENT.Possessor_CanSprint = true -- Can the possessed NPC sprint?
ENT.Possessor_CanFaceTrace_Walking = false
ENT.Possessor_CanFaceTrace_Running = false
ENT.PossessorView = {
	Pos = {Right = 0,Forward = 0,Up = 0}
}

	-- Tables --
ENT.tbl_Animations = {}
ENT.tbl_Sounds = {}
ENT.tbl_Sentences = {} -- Basically the Half-Life 1 sentence system
ENT.tbl_ImmuneTypes = {} -- DMG_ types the NPC won't take damage from
ENT.tbl_Capabilities = {} -- CAP_ types for the NPC

	-- Sound Variables --
ENT.SoundDirectory = nil -- The sound directory of the NPC. Not necessary unless you use SetupSoundTables
ENT.SetupSoundTables = false -- Won't be as accurate as you setting them up yourself | there's also a weird issue where SNPCs can sometimes "share" sounds
ENT.CheckForLoopsInSoundDirectory = true -- Makes sure looping sounds don't get added
ENT.UseTimedSteps = false -- Will the NPC's footstep sounds be based on the below sound timers?
ENT.NextFootSound_Walk = 0.45
ENT.NextFootSound_Run = 0.45
ENT.WalkSoundVolume = 70
ENT.RunSoundVolume = 75
ENT.StepSoundPitch = 100
ENT.IdleSoundVolume = 80
ENT.IdleSoundPitch = 100
ENT.IdleSoundChanceA = 10
ENT.IdleSoundChanceB = 16
ENT.AlertSoundVolume = 85
ENT.AlertSoundPitch = 100
ENT.AlertSoundChanceA = 4
ENT.AlertSoundChanceB = 12
ENT.PainSoundVolume = 82
ENT.PainSoundPitch = 100
ENT.PainSoundChanceA = 2
ENT.PainSoundChanceB = 4
ENT.DeathSoundVolume = 80
ENT.DeathSoundPitch = 100

	-- Misc Variables (Don't touch) --
ENT.NextFootSoundT_Walk = 0
ENT.NextFootSoundT_Run = 0
ENT.NextIdleSoundT = 0
ENT.NextAlertSoundT = 0
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:AfterInit() end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThink_Disabled() end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnCondition(cond,state) end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:HandleSchedules(enemy,dist,nearest,disp,time)
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
	if self.ReactsToSound == false then return end
	if self.IsPossessed == true then return end
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
function ENT:OnDeathAnimationFinished(dmg,dmginfo,hitbox) end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetUpRangeAttackTarget(subtractdist)
	if self.IsPossessed then
		return (self:Possess_AimTarget() -self:LocalToWorld(Vector(0,0,0)))
	else
		if IsValid(self:GetEnemy()) then
			if self:GetEnemy():IsPlayer() then
				return ((self:GetEnemy():GetPos() -self:LocalToWorld(Vector(0,0,0))) +self:CheckPlayerMoveDirection(self:GetEnemy(),subtractdist))
			else
				return (self:GetEnemy():GetPos() -self:LocalToWorld(Vector(0,0,0)))
			end
		else
			return ((self:GetPos() +self:GetForward() *900) -self:LocalToWorld(Vector(0,0,0)))
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CheckPlayerMoveDirection(ent,extradist)
	local addvel
	local addto = 0
	if extradist != nil then addto = extradist end
	local extravel
	if ent:KeyDown(IN_RUN) then
		extravel = ent:GetRunSpeed() -50 +addto
	else
		extravel = ent:GetWalkSpeed() -50 +addto
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
function ENT:ChooseBetterPath(ent)
	local adddist
	local extradist
	if !ent:IsPlayer() then return ent:GetForward() *0 end
	if ent:KeyDown(IN_RUN) then
		extradist = ent:GetRunSpeed() -50
	else
		extradist = ent:GetWalkSpeed() -50
	end
	local tr_left = util.TraceHull({
		start = ent:GetPos(),
		endpos = ent:GetPos() +ent:OBBCenter() +ent:GetRight() *-extradist,
		filter = {ent},
		mins = self:OBBMins(),
		maxs = self:OBBMaxs()
	})
	local tr_right = util.TraceHull({
		start = ent:GetPos(),
		endpos = ent:GetPos() +ent:OBBCenter() +ent:GetRight() *extradist,
		filter = {ent},
		mins = self:OBBMins(),
		maxs = self:OBBMaxs()
	})
	local tr_back = util.TraceHull({
		start = ent:GetPos(),
		endpos = ent:GetPos() +ent:OBBCenter() +ent:GetForward() *-extradist,
		filter = {ent},
		mins = self:OBBMins(),
		maxs = self:OBBMaxs()
	})
	if ent:KeyDown(IN_MOVELEFT) && !tr_left.Hit then
		adddist = ent:GetRight() *-extradist
	elseif ent:KeyDown(IN_MOVERIGHT) && !tr_right.Hit then
		adddist = ent:GetRight() *extradist
	elseif ent:KeyDown(IN_FORWARD) then
		adddist = ent:GetForward() *0
	elseif ent:KeyDown(IN_BACK) && !tr_back.Hit then
		adddist = ent:GetForward() *-extradist
	else
		adddist = ent:GetForward() *0
	end
	return adddist
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Possess_FaceAimPosition()
	if self.Possessor_CanMove == true then
		self:SetAngles(Angle(0,(self:Possess_AimTarget() -self:FindCenter(self)):Angle().y,0))
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
-- function ENT:Possess_CustomHUDInterface(possessor)
	-- net.Start("cpt_ControllerView_Custom")
	-- net.Send(possessor)
-- end
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
	elseif possessor:KeyDown(IN_WALK) then
		return self:Possess_Walk(possessor)
	end
	return self:Possess_CustomCommands(possessor)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Possess_CustomCommands(possessor)
	local w = possessor:KeyDown(IN_FORWARD)
	local e = possessor:KeyDown(IN_USE)
	local r = possessor:KeyDown(IN_RELOAD)
	local a = possessor:KeyDown(IN_MOVELEFT)
	local s = possessor:KeyDown(IN_BACK)
	local d = possessor:KeyDown(IN_MOVERIGHT)
	local lmb = possessor:KeyDown(IN_ATTACK)
	local rmb = possessor:KeyDown(IN_ATTACK2)
	local alt = possessor:KeyDown(IN_WALK)
	local shift = possessor:KeyDown(IN_RUN)
	local zoom = possessor:KeyDown(IN_ZOOM)
	/* Example:
		if zoom then
			return self:Possess_Zoom(possessor)
		end
	*/
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Possess_Move(possessor)
	local posMove = self:GetPos()
	local posMoveTrace = possessor:GetEyeTrace().HitPos
	local posTraceTest = self:DoCustomTrace(self:GetPos() +Vector(0,0,20),posMoveTrace,{self},true)
	local posTestOutput = math.Clamp((self:GetPos():Distance(posTraceTest.HitPos)),0,350)
	local posAim = possessor:GetAimVector()
	if self.Possessor_CanMove == false then return end
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
			local trace = util.TraceLine({
				start = self:GetPos() +self:OBBCenter(),
				endpos = self:GetPos() +self:OBBCenter() +posAim *self.Possessor_MaxMoveDistanceForward,
				filter = {self,possessor}
			})
			if GetConVarNumber("cpt_usetracemovement") == 1 then
				posMove = posTraceTest.HitPos +Vector(0,0,10)
			else
				-- posMove = self:GetPos() +self:GetForward() *self.Possessor_MaxMoveDistance
				if trace.HitPos:Distance(self:GetPos()) <= self.Possessor_MinMoveDistance then
					posMove = trace.HitPos +self:GetForward() *self.Possessor_MinMoveDistance +self:GetForward() *(-self:GetCollisionBounds().y)
				else
					posMove = trace.HitPos +self:GetForward() *(-self:GetCollisionBounds().y)
				end
			end
			-- if self.blockA == NULL || self.blockA == nil then
				-- self.blockA = ents.Create("prop_dynamic")
				-- self.blockA:SetModel("models/hunter/blocks/cube025x025x025.mdl")
				-- self.blockA:SetPos(posMove)
				-- self.blockA:SetColor(0,255,89,255)
				-- self.blockA:Spawn()
				-- local glow = ents.Create("light_dynamic")
				-- glow:SetKeyValue("_light","0 255 89 200")
				-- glow:SetKeyValue("brightness","2")
				-- glow:SetKeyValue("distance","150")
				-- glow:SetKeyValue("style","0")
				-- glow:SetPos(self.blockA:GetPos() +self.blockA:OBBCenter())
				-- glow:SetParent(self.blockA)
				-- glow:Spawn()
				-- glow:Activate()
				-- glow:Fire("TurnOn","",0)
				-- glow:DeleteOnRemove(self.blockA)
				-- timer.Simple(0.3,function()
					-- if self.blockA:IsValid() then
						-- self.blockA:Remove()
					-- end
				-- end)
			-- end
			self:SetLastPosition(posMove)
			if possessor:KeyDown(IN_SPEED) && self.Possessor_CanSprint then
				self:TASKFUNC_RUNLASTPOSITION()
				-- self:SetSchedule(SCHED_FORCED_GO_RUN)
			else
				self:TASKFUNC_WALKLASTPOSITION()
				-- self:SetSchedule(SCHED_FORCED_GO)
			end
			if self.UsePlayermodelMovement then
				self:SetPoseParameter("move_x",self.PlayermodelMovementSpeed_Forward)
				self:SetPoseParameter("move_y",0)
			end
		elseif (possessor:KeyDown(IN_BACK)) then
			self:SetAngles(Angle(0,math.ApproachAngle(self:GetAngles().y,possessor:GetAimVector():Angle().y,4),0))
			local PlayersVectorBack = possessor:GetAimVector() *-1
			PlayersVectorBack.z = 0
			local trace = util.TraceLine({
				start = self:GetPos() +self:OBBCenter(),
				endpos = self:GetPos() +self:OBBCenter() +possessor:GetForward() *-self.Possessor_MaxMoveDistanceBackward,
				filter = {self,possessor}
			})
			if trace.HitPos:Distance(self:GetPos()) <= self.Possessor_MinMoveDistance then
				posMove = trace.HitPos +self:GetForward() *-self.Possessor_MinMoveDistance
			else
				posMove = trace.HitPos
			end
			-- if self.blockB == NULL || self.blockB == nil then
				-- self.blockB = ents.Create("prop_dynamic")
				-- self.blockB:SetModel("models/hunter/blocks/cube025x025x025.mdl")
				-- self.blockB:SetPos(posMove)
				-- self.blockB:SetColor(0,255,89,255)
				-- self.blockB:Spawn()
				-- local glow = ents.Create("light_dynamic")
				-- glow:SetKeyValue("_light","0 255 89 200")
				-- glow:SetKeyValue("brightness","2")
				-- glow:SetKeyValue("distance","150")
				-- glow:SetKeyValue("style","0")
				-- glow:SetPos(self.blockB:GetPos() +self.blockB:OBBCenter())
				-- glow:SetParent(self.blockB)
				-- glow:Spawn()
				-- glow:Activate()
				-- glow:Fire("TurnOn","",0)
				-- glow:DeleteOnRemove(self.blockB)
				-- timer.Simple(0.3,function()
					-- if self.blockB:IsValid() then
						-- self.blockB:Remove()
					-- end
				-- end)
			-- end
			-- posMove = self:GetPos() +(PlayersVectorBack *self.Possessor_MaxMoveDistanceBackward)
			self:SetLastPosition(posMove)
			if possessor:KeyDown(IN_SPEED) && self.Possessor_CanSprint then
				self:TASKFUNC_RUNLASTPOSITION()
			else
				self:TASKFUNC_WALKLASTPOSITION()
			end
			if self.UsePlayermodelMovement then
				self:SetPoseParameter("move_x",self.PlayermodelMovementSpeed_Backward) -- -1
				self:SetPoseParameter("move_y",0)
			end
		elseif (possessor:KeyDown(IN_MOVELEFT)) then
			self:SetAngles(Angle(0,math.ApproachAngle(self:GetAngles().y,possessor:GetAimVector():Angle().y,4),0))
			local trace = util.TraceLine({
				start = self:GetPos() +self:OBBCenter(),
				endpos = self:GetPos() +self:OBBCenter() +possessor:GetRight() *-self.Possessor_MaxMoveDistanceLeft,
				filter = {self,possessor}
			})
			if trace.HitPos:Distance(self:GetPos()) <= self.Possessor_MinMoveDistance then
				posMove = trace.HitPos +self:GetRight() *-self.Possessor_MinMoveDistance
			else
				posMove = trace.HitPos
			end
			-- if self.blockC == NULL || self.blockC == nil then
				-- self.blockC = ents.Create("prop_dynamic")
				-- self.blockC:SetModel("models/hunter/blocks/cube025x025x025.mdl")
				-- self.blockC:SetPos(posMove)
				-- self.blockC:SetColor(0,255,89,255)
				-- self.blockC:Spawn()
				-- local glow = ents.Create("light_dynamic")
				-- glow:SetKeyValue("_light","0 255 89 200")
				-- glow:SetKeyValue("brightness","2")
				-- glow:SetKeyValue("distance","150")
				-- glow:SetKeyValue("style","0")
				-- glow:SetPos(self.blockC:GetPos() +self.blockC:OBBCenter())
				-- glow:SetParent(self.blockC)
				-- glow:Spawn()
				-- glow:Activate()
				-- glow:Fire("TurnOn","",0)
				-- glow:DeleteOnRemove(self.blockC)
				-- timer.Simple(0.3,function()
					-- if self.blockC:IsValid() then
						-- self.blockC:Remove()
					-- end
				-- end)
			-- end
			-- posMove = self:GetPos() +(possessor:GetRight() *-self.Possessor_MaxMoveDistanceLeft)
			self:SetLastPosition(posMove)
			if possessor:KeyDown(IN_SPEED) && self.Possessor_CanSprint then
				self:TASKFUNC_RUNLASTPOSITION()
			else
				self:TASKFUNC_WALKLASTPOSITION()
			end
			if self.UsePlayermodelMovement then
				self:SetPoseParameter("move_x",0)
				self:SetPoseParameter("move_y",self.PlayermodelMovementSpeed_Left) -- -1
			end
		elseif (possessor:KeyDown(IN_MOVERIGHT)) then
			self:SetAngles(Angle(0,math.ApproachAngle(self:GetAngles().y,possessor:GetAimVector():Angle().y,4),0))
			local trace = util.TraceLine({
				start = self:GetPos() +self:OBBCenter(),
				endpos = self:GetPos() +self:OBBCenter() +possessor:GetRight() *self.Possessor_MaxMoveDistanceRight,
				filter = {self,possessor}
			})
			if trace.HitPos:Distance(self:GetPos()) <= self.Possessor_MinMoveDistance then
				posMove = trace.HitPos +self:GetRight() *self.Possessor_MinMoveDistance
			else
				posMove = trace.HitPos
			end
			-- if self.blockD == NULL || self.blockD == nil then
				-- self.blockD = ents.Create("prop_dynamic")
				-- self.blockD:SetModel("models/hunter/blocks/cube025x025x025.mdl")
				-- self.blockD:SetPos(posMove)
				-- self.blockD:SetColor(0,255,89,255)
				-- self.blockD:Spawn()
				-- local glow = ents.Create("light_dynamic")
				-- glow:SetKeyValue("_light","0 255 89 200")
				-- glow:SetKeyValue("brightness","2")
				-- glow:SetKeyValue("distance","150")
				-- glow:SetKeyValue("style","0")
				-- glow:SetPos(self.blockD:GetPos() +self.blockD:OBBCenter())
				-- glow:SetParent(self.blockD)
				-- glow:Spawn()
				-- glow:Activate()
				-- glow:Fire("TurnOn","",0)
				-- glow:DeleteOnRemove(self.blockD)
				-- timer.Simple(0.3,function()
					-- if self.blockD:IsValid() then
						-- self.blockD:Remove()
					-- end
				-- end)
			-- end
			-- posMove = self:GetPos() +(possessor:GetRight() *self.Possessor_MaxMoveDistanceRight)
			self:SetLastPosition(posMove)
			if possessor:KeyDown(IN_SPEED) && self.Possessor_CanSprint then
				self:TASKFUNC_RUNLASTPOSITION()
			else
				self:TASKFUNC_WALKLASTPOSITION()
			end
			if self.UsePlayermodelMovement then
				self:SetPoseParameter("move_x",0)
				self:SetPoseParameter("move_y",self.PlayermodelMovementSpeed_Right) -- 1
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
function ENT:Possess_Think(possessor,object) end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Possess_OnPossessed(possessor) end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Possess_OnStopPossessing(possessor) end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Possess_Primary(possessor)
	if self.DoAttack then
		self:DoAttack()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Possess_Secondary(possessor)
	if self.DoRangeAttack then
		-- if !IsValid(self:GetEnemy()) then possessor:ChatPrint("No Valid Enemy To Target") return end
		self:DoRangeAttack()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Possess_Jump(possessor)
	if self.DoLeapAttack then
		if !IsValid(self:GetEnemy()) then possessor:ChatPrint("No Valid Enemy To Target") return end
		self:DoLeapAttack()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Possess_Duck(possessor) end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Possess_Reload(possessor) end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Possess_Walk(possessor) end -- Alt key
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnAttackFinish(anim) end
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
	if !IsValid(self:GetEnemy()) && self.FlyUpOnSpawn == true then
		local time = self.FlyUpOnSpawn_Time
		self.IsStartingUp = true
		self:SetLocalVelocity(self:GetVelocity() *0.9 +self:GetUp() *self.FlySpeed /4)
		timer.Simple(time,function()
			if (self:IsValid() && !IsValid(self:GetEnemy()) && self.IsStartingUp == true) then
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
function ENT:SetNPCModel(mdl)
	if mdl == nil then
		if table.Count(self.ModelTable) > 0 then
			self:SetModel(self:SelectFromTable(self.ModelTable))
		end
	else
		self:SetModel(mdl)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Initialize()
	self:SetSpawnEffect(false)
	self.CPTBase_NPC = true
	self:SetNWBool("IsCPTBase_NPC",true)
	self:SetNWEntity("cpt_SpokenPlayer",NULL)
	self:SetNWString("cpt_Faction",self.Faction)
	self:SetNPCModel()
	self:DrawShadow(true)
	self:SetHullSizeNormal()
	if self.CollisionBounds != Vector(0,0,0) then
		self:SetCollisionBounds(Vector(self.CollisionBounds.x,self.CollisionBounds.y,self.CollisionBounds.z),-(Vector(self.CollisionBounds.x,self.CollisionBounds.y,0)))
	end
	self:SetSolid(SOLID_BBOX)
	self:SetMaxYawSpeed(self.MaxTurnSpeed)
	local dif = GetConVarNumber("cpt_aidifficulty")
	local start = self.StartHealth
	local hp
	if dif == 1 then
		hp = start *0.5
	elseif dif == 2 then
		hp = start
	elseif dif == 3 then
		hp = start *2
	elseif dif == 4 then
		hp = start *4
	end
	self:SetHealth(self.StartHealth)
	self:SetMaxHealth(self.StartHealth)
	-- self:SetMovementType(MOVETYPE_STEP)
	self:SetCollisionGroup(COLLISION_GROUP_NPC)
	self:SetEnemy(NULL)
	self.RenderMode = RENDERMODE_NORMAL
	self:SetNPCRenderMode(RENDERMODE_NORMAL)
	self.HasSetTypeOnSpawn = false
	self.IsPossessed = false
	self.Possessor = nil
	self.DidGetHit = false
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
	self.tbl_AddToEnemies = {}
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
	self.tbl_Speakers = {}
	self.NPC_Enemy = nil
	self.tbl_Inventory = {
		["Primary"] = nil,
		["Melee"] = nil,
	}
	
	if self.LeavesBlood == true then
		-- if self.AutomaticallySetsUpDecals then
			-- self:SetupBloodDecals()
		-- end
	end

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

	local idleanim = self:GetIdleAnimation()
	if idleanim == nil then self:SetIdleAnimation(ACT_IDLE) end

	self:SetInit()
	self:AfterInit()
	if self.HasSetTypeOnSpawn == false then self:SetMovementType(MOVETYPE_STEP) end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetupBloodDecals()
	if table.Count(self.BloodEffect) > 0 && table.Count(self.BloodDecal) <= 0 then
		if table.HasValue(self.BloodEffect,"blood_impact_red") then
			table.insert(self.BloodDecal,"CPTBase_RedBlood")
		end
		if table.HasValue(self.BloodEffect,"blood_impact_yellow") then
			table.insert(self.BloodDecal,"CPTBase_YellowBlood")
		end
		if table.HasValue(self.BloodEffect,"blood_impact_blue") then
			table.insert(self.BloodDecal,"CPTBase_BlueBlood")
		end
		if table.HasValue(self.BloodEffect,"blood_impact_green") then
			table.insert(self.BloodDecal,"CPTBase_GreenBlood")
		end
		if table.HasValue(self.BloodEffect,"blood_impact_purple") then
			table.insert(self.BloodDecal,"CPTBase_PurpleBlood")
		end
		if table.HasValue(self.BloodEffect,"blood_impact_orange") then
			table.insert(self.BloodDecal,"CPTBase_OrangeBlood")
		end
		if table.HasValue(self.BloodEffect,"blood_impact_white") then
			table.insert(self.BloodDecal,"CPTBase_WhiteBlood")
		end
		if table.HasValue(self.BloodEffect,"blood_impact_black") then
			table.insert(self.BloodDecal,"CPTBase_BlackBlood")
		end
		if table.HasValue(self.BloodEffect,"blood_impact_pink") then
			table.insert(self.BloodDecal,"CPTBase_PinkBlood")
		end
		if table.HasValue(self.BloodEffect,"blood_impact_infection") then
			table.insert(self.BloodDecal,"CPTBase_ZombieBlood")
		end
	end
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
	if self.MeleeAttackDistance != nil && IsValid(self:GetEnemy()) then
		if self:GetEnemy():GetPos():Distance(self:GetPos()) <= self.MeleeAttackDistance +ExtraDist && self.HasStoppedMovingToAttack == false then
			self:StopCompletely()
			self.HasStoppedMovingToAttack = true
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.NextRelationshipCheckT = 0
function ENT:UpdateRelations() // Obsolete
	if self.Faction == "FACTION_NONE" || self.CanSetEnemy == false then return end
	if CurTime() > self.NextRelationshipCheckT then
		for _,v in ipairs(ents.GetAll()) do
			if v:IsNPC() && v.Faction != nil && v != self then
				if v.Faction == "FACTION_NONE" then return end
				if self.Faction != v.Faction && self:Disposition(v) != D_HT then
						self:SetRelationship(v,D_HT)
				elseif self.Faction == v.Faction && self:Disposition(v) != D_LI then
					self:SetRelationship(v,D_LI)
				end
			elseif v:IsPlayer() && v:Alive() && v.IsPossessing == false then
				if v.Faction == "FACTION_NOTARGET" then return end
				if (self:GetFaction() == "FACTION_PLAYER" || self.FriendlyToPlayers == true) && !table.HasValue(self.tbl_AddToEnemies,v) then
					if v.IsPossessing == true then return end
					if GetConVarNumber("ai_ignoreplayers") == 1 then return end
					self:SetRelationship(v,D_LI)
				else
					if self.FriendlyToPlayers == true then return end
					if v.IsPossessing == true then return end
					if GetConVarNumber("ai_ignoreplayers") == 1 then return end
					if self:CheckConfidence(v) == "attack!" then
						self:SetRelationship(v,D_HT)
					elseif self:CheckConfidence(v) == "run!" then
						self:SetRelationship(v,D_FR)
					end
				end
			end
		end
		self.NextRelationshipCheckT = CurTime() +1
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
local AlreadyResetPoseParamaters = false
function ENT:CheckPoseParameters()
	if self:CheckForValidMemory() <= 0 then
		if AlreadyResetPoseParamaters == false then
			AlreadyResetPoseParamaters = true
			self:ClearPoseParameters()
			self:ClearMemory()
		end
	else
		AlreadyResetPoseParamaters = false
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:IdleSounds()
	if self.IsPossessed == false then
		if !IsValid(self:GetEnemy()) then
			if CurTime() > self.NextIdleSoundT && math.random(1,3) == 1 then
				if self.tbl_Sentences["Idle"] == nil then
					self:PlaySound("Idle",self.IdleSoundVolume,90,self.IdleSoundPitch)
					self:DoPlaySound("Idle")
				else
					self:PlayNPCSentence("Idle")
				end
				if self.CurrentSound != nil then
					self.NextIdleSoundT = CurTime() +SoundDuration(self.CurrentPlayingSound) +math.random(self.IdleSoundChanceA,self.IdleSoundChanceB)
				end
			end
		end
	else
		if !IsValid(self:GetEnemy()) && CurTime() > self.NextIdleSoundT && math.random(1,3) == 1 then
			if self.tbl_Sentences["Idle"] == nil then
				self:PlaySound("Idle",self.IdleSoundVolume,90,self.IdleSoundPitch)
				self:DoPlaySound("Idle")
			else
				self:PlayNPCSentence("Idle")
			end
			if self.CurrentSound != nil then
				self.NextIdleSoundT = CurTime() +SoundDuration(self.CurrentPlayingSound) +math.random(self.IdleSoundChanceA,self.IdleSoundChanceB)
			end
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:IsWalking()
	if self.CurrentSchedule != nil && (self.CurrentSchedule.Name == "_lastpositiontask_walk" || self.CurrentSchedule.Name == "_wandertaskfunc") then
		return true
	end
	return false
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:IsRunning()
	if self.CurrentSchedule != nil && (self.CurrentSchedule.Name == "_lastpositiontask_run" || self.CurrentSchedule.Name == "_lastpositiontask" || self.CurrentSchedule.Name == "_chasetaskfunc" || self.CurrentSchedule.Name == "getpathandchasetask" || self.CurrentSchedule.Name == "_hidetask" || self.CurrentSchedule.Name == "_followplayer") then
		return true
	end
	return false
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Think()
	if self.IsDead == true then return end
	-- print(self:GetEnemy())
	-- print(self,self:GetSequenceName(self:GetSequence()),self:GetSequenceName(self.tbl_Animations["Run"][1]))
	self:OnThink_Disabled()
	if self:IsMoving() then
		self:SetArrivalActivity(self:GetIdleAnimation())
	end
	if self.IsRagdolled == true then
		self:SetPos(self:FindCenter(self.Ragdoll_CPT) -Vector(0,0,self.RagdolledPosSubtraction))
		self:SetAngles(self.Ragdoll_CPT:GetAngles())
		self:SetNoDraw(true)
		self:DrawShadow(false)
		self.bInSchedule = true
		self:CheckRagdollSettings()
	end
	if GetConVarNumber("ai_disabled") == 1 then return end
	if self.IsPlayingSequence == true then
		self.CurrentSchedule = nil
		self.CurrentTask = nil
	end
	if !self:IsMoving() then
		self:SetPoseParameter("move_x",0)
		self:SetPoseParameter("move_y",0)
	end
	if self:IsWalking() then
		self:SetMovementAnimation("Walk")
	end
	if self:IsRunning() then
		self:SetMovementAnimation("Run")
	end
	self:IdleSounds()
	self:UpdateFriends()
	self:UpdateEnemies()
	-- self:UpdateRelations()
	-- self:UpdateMemory()
	-- print(self:GetEnemy(),self.IsPossessed)
	if IsValid(self:GetEnemy()) && !self.IsPossessed then
		local enemy = self:GetEnemy()
		local dist = self:FindCenterDistance(enemy)
		local nearest = self:GetClosestPoint(enemy)
		local disp = self:Disposition(enemy)
		local time = self:GetPathTimeToGoal()
		if self:MovementType() != MOVETYPE_FLY then
			if self.bInSchedule != true && !self.IsPossessed then
				self:HandleSchedules(enemy,dist,nearest,disp,time)
			end
		else
			if self.IsSwimType != true then
				self:HandleSchedules_Fly(enemy,dist,nearest,disp)
			else
				self:HandleSchedules(enemy,dist,nearest,disp,time)
			end
		end
	end
	self:PoseParameters()
	self:FootStepCode()
	if self.IsSwimType == false then
		if self:IsFalling(self.FallingHeight) then
			self:SetGroundEntity(NULL)
			self:WhileFalling()
			self.TimeSinceLastTimeFalling = CurTime() +0.2
		elseif !self:IsFalling(self.FallingHeight) && self.TimeSinceLastTimeFalling > 0 && self.TimeSinceLastTimeFalling <= CurTime() then
			self:OnLand()
			self.TimeSinceLastTimeFalling = 0
		end
	elseif self.IsSwimType == true then
		self:SwimAI()
		if self.IsPossessed then
			self.Possessor:ChatPrint("Swim AI is not possessable yet. Removing SNPC to prevent errors.")
			self:Remove()
		end
	end
	self:OnThink()
	if !IsValid(self:GetEnemy()) && self.Faction != "FACTION_NONE" then
		self:HearingCode()
	end
	self:NextThink(CurTime() +0.1)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnStartedAnimation(activity) end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:HearingCode()
	for _,v in pairs(ents.FindInSphere(self:GetPos(),self.HearingDistance)) do
		if v:IsPlayer() && (v:GetMoveType() == MOVETYPE_WALK || v:GetMoveType() == MOVETYPE_LADDER) && v:GetNWBool("CPTBase_IsPossessing") == false && self.FriendlyToPlayers == false && GetConVarNumber("ai_ignoreplayers") == 0 && v.Faction != "FACTION_NOTARGET" && self:GetFaction() != "FACTION_PLAYER" && self.Faction != v.Faction then
			if (IsValid(self:GetNWEntity("cpt_SpokenPlayer")) && self:GetNWEntity("cpt_SpokenPlayer") == v) || (!v:Crouching() && (v:KeyDown(IN_FORWARD) or v:KeyDown(IN_BACK) or v:KeyDown(IN_MOVELEFT) or v:KeyDown(IN_MOVERIGHT) or v:KeyDown(IN_JUMP))) then
				if self:GetDistanceToVector(v:GetPos(),1) <= self.HearingDistance then
					self:OnHearSound(v)
				end
			end
		elseif v:IsNPC() && v != self && self.Faction != v:GetFaction() && v.Faction != "FACTION_NONE" && v:IsMoving() && v:Disposition(self) != D_LI then
			if self:GetDistanceToVector(v:GetPos(),1) <= self.HearingDistance then
				self:OnHearSound(v)
			end
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
net.Receive("cpt_SpeakingPlayer",function(len,pl)
	v = net.ReadEntity()
	ent = net.ReadEntity()
	v:SetNWEntity("cpt_SpokenPlayer",ent)
end)
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Swim_TurnAngle(turn)
	local ang = self:GetAngles()
	if turn == "right" then
		ang.y = ang.y -self:GetMaxYawSpeed()
	elseif turn == "left" then
		ang.y = ang.y +self:GetMaxYawSpeed()
	elseif turn == "down" then
		if ang.p < 50 then
			ang.p = ang.p +self:GetMaxYawSpeed()
		end
	elseif turn == "up" then
		if ang.p > -42 then
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
	if IsValid(self:GetEnemy()) && self:GetEnemy():WaterLevel() < self.Swim_WaterLevelCheck then
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
	if !IsValid(self:GetEnemy()) then
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
function ENT:FootStepCode()
	if self.IsRagdolled == true then return end
	if self:IsOnGround() && self:IsMoving() && self.UseTimedSteps == true then
		if (table.HasValue(self.tbl_Animations["Walk"],self:GetMovementAnimation()) || self.OverrideWalkAnimation == self:GetMovementAnimation()) && CurTime() > self.NextFootSoundT_Walk then
			self:PlaySound("FootStep",self.WalkSoundVolume,90,self.StepSoundPitch,true)
			self:DoPlaySound("FootStep")
			self:OnStep("Walk")
			self.NextFootSoundT_Walk = CurTime() + self.NextFootSound_Walk
		end
		if (table.HasValue(self.tbl_Animations["Run"],self:GetMovementAnimation()) || self.OverrideRunAnimation == self:GetMovementAnimation()) && CurTime() > self.NextFootSoundT_Run then
			self:PlaySound("FootStep",self.RunSoundVolume,90,self.StepSoundPitch,true)
			self:DoPlaySound("FootStep")
			self:OnStep("Run")
			self.NextFootSoundT_Run = CurTime() + self.NextFootSound_Run
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnStep(steptype) end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:DoPlaySound(tbl) end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnPlaySound(sound,tbl) end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnDoIdle() end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SelectSchedule(bSchedule)
	if self.IsDead == true then return end
	if self.bInSchedule == true then return end
	if self.IsPlayingSequence == true then return end
	if self.IsPossessed == false && !self.IsPlayingSequence && self.CanWander then
		if !IsValid(self:GetEnemy()) then
			if self.WanderChance != 0 && math.random(1,self.WanderChance) == 1 then
				self:TASKFUNC_WANDER()
				self:SetMovementAnimation("Walk")
				self:OnDoIdle()
			end
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
function ENT:ChaseEnemy(uselastpos,pos) // Only run this if you don't care what it's target is
	if self.IsPossessed then return end
	if IsValid(self:GetEnemy()) && self:Disposition(self:GetEnemy()) != D_LI && self:CheckConfidence(self:GetEnemy()) == "attack!" && self.CanChaseEnemy == true then
		if self:GetEnemy():IsPlayer() && GetConVarNumber("ai_ignoreplayers") == 1 then
			self.tbl_EnemyMemory[self:GetEnemy()] = NULL
			self:SetEnemy(NULL)
			return
		end
		if uselastpos == nil then
			uselastpos = false
		end
		self:ChaseTarget(self:GetEnemy(),uselastpos,pos)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnChaseEnemy(ent) self:SetMovementAnimation("Run") end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:ChaseTarget(ent,uselastpos,pos)
	if self.bInSchedule == true then return end
	if self.CanChaseEnemy == false then return end
	if self.IsPossessed == true then return end
	if IsValid(ent) then
		self:OnChaseEnemy(ent)
		if uselastpos == false then
			self:SetTarget(ent)
			self:TASKFUNC_GETPATHANDGO()
		else
			if pos == nil then
				pos = ent:GetPos()
			end
			self:SetLastPosition(pos)
			self:TASKFUNC_LASTPOSITION()
		end
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
	self:CheckPoseParameters()
	if !self.UseDefaultPoseParameters then return end
	local pp = self.DefaultPoseParameters
	local pp_speed = self.DefaultPoseParamaterSpeed
	if self.IsPossessed then
		self:LookAtPosition(self:Possess_EyeTrace(self.Possessor).HitPos,self.DefaultPoseParameters,pp_speed,self.ReversePoseParameters)
	else
		if IsValid(self:GetEnemy()) then
			-- self:LookAtPosition(self:FindHeadPosition(self:GetEnemy()),{"aim_pitch","aim_yaw","head_pitch","head_yaw"},10)
			self:LookAtPosition(self:FindCenter(self:GetEnemy()),pp,pp_speed,self.ReversePoseParameters)
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
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
						-- print('ok')
						self:DoPlaySound("Alert")
					else
						self:PlayNPCSentence("Alert")
					end
					if self.CurrentSound != nil then
						self.NextAlertSoundT = CurTime() +SoundDuration(self.CurrentPlayingSound) +math.random(self.AlertSoundChanceA,self.AlertSoundChanceB)
						-- print(self.NextAlertSoundT)
					end
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
function ENT:CanSetAsEnemy(ent)
	return true
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CanSeeEntities(ent)
	if self:FindDistance(ent) <= self.ViewDistance then
		if self.IsBlind then
			return false
		else
			return true
		end
		return true
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnSpottedFriendly(ent) end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:UpdateFriends()
	if self.Faction == "FACTION_NONE" then return end
	for k,v in ipairs(ents.FindInSphere(self:GetPos(),self.FindEntitiesDistance)) do
		if v:IsNPC() && v != self && v:Health() > 0 then
			if self:Visible(v) && self:CanSeeEntities(v) && self:FindInCone(v,self.ViewAngle) then
				if (v:GetFaction() != nil && v.Faction == self:GetFaction()) then
					self:SetRelationship(v,D_LI)
					self:OnSpottedFriendly(v)
				end
			end
		elseif GetConVarNumber("ai_ignoreplayers") == 0 && v:IsPlayer() && v:Alive() then
			if self:Visible(v) && self:CanSeeEntities(v) && self:FindInCone(v,self.ViewAngle) && !v.IsPossessing then
				if v.Faction != "FACTION_NOTARGET" && (self:GetFaction() == "FACTION_PLAYER" || v.Faction == self.Faction || self.FriendlyToPlayers == true) && !table.HasValue(self.tbl_AddToEnemies,v) then
					self:SetRelationship(v,D_LI,true)
					self:OnSpottedFriendly(v)
				end
			end
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:FindAllEnemies()
	if self.Faction == "FACTION_NONE" || self.CanSetEnemy == false then return end
	for _,v in ipairs(ents.GetAll()) do
		if IsValid(v) && (v:IsNPC() && v != self || v:IsPlayer() && GetConVarNumber("ai_ignoreplayers") == 0 && self.FriendlyToPlayers == false && v.IsPossessing == false && self:GetFaction() != "FACTION_PLAYER") then
			if v.Faction == "FACTION_NOTARGET" then return end
			if v:Health() > 0 && self.Faction != v.Faction && self:Disposition(v) != D_LI then
				return v
			end
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:LocateEnemies()
	if self.Faction == "FACTION_NONE" || self.CanSetEnemy == false then return end
	for _,v in ipairs(ents.FindInSphere(self:GetPos(),self.FindEntitiesDistance)) do
		if v:IsNPC() && v != self && v:Health() > 0 then
			if (self:Visible(v) && self:CanSeeEntities(v) && self:FindInCone(v,self.ViewAngle)) && v.Faction != "FACTION_NONE" && self:CanSetAsEnemy(v) then
				if ((v:GetFaction() == nil or v:GetFaction() != nil) && v.Faction != self:GetFaction()) && self:Disposition(v) != D_LI && !table.HasValue(self.tblBlackList,v) then
					return v
				end
			end
		elseif self.FriendlyToPlayers == false && GetConVarNumber("ai_ignoreplayers") == 0 && v:IsPlayer() && v:Alive() && !v.IsPossessing && v != self.Possessor then
			if (self:Visible(v) && self:CanSeeEntities(v) && self:FindInCone(v,self.ViewAngle)) && v.IsPossessing != true && v.Faction != "FACTION_NONE" then
				if v.Faction == "FACTION_NOTARGET" then return end
				if self:GetFaction() != "FACTION_PLAYER" && self.Faction != v.Faction && self:Disposition(v) != D_LI && !table.HasValue(self.tblBlackList,v) then
					return v
				end
			end
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:UpdateEnemies()
	if GetConVarNumber("ai_disabled") == 1 then return end
	if self.Faction == "FACTION_NONE" || self.CanSetEnemy == false then return end
	local totalenemies = self.EnemyMemoryCount
	if IsValid(self:GetEnemy()) then
		if (!IsValid(self:GetEnemy()) || self:GetEnemy():Health() <= 0) || (self.FriendlyToPlayers && (self:GetEnemy():IsPlayer() && (GetConVarNumber("ai_ignoreplayers") == 1 || self:GetEnemy():GetNWBool("CPTBase_IsPossessing") || self:GetEnemy().Faction == "FACTION_NOTARGET"))) then
			self:RemoveFromMemory(self:GetEnemy())
		end
	end
	local lastenemy = self:GetEnemy()
	local newenemy
	self:UpdateMemory()
	if self.CanSeeAllEnemies == true then
		newenemy = self:FindAllEnemies()
	else
		newenemy = self:LocateEnemies()
	end
	if newenemy == nil then return end
	if newenemy:IsPlayer() then
		if self.FriendlyToPlayers || GetConVarNumber("ai_ignoreplayers") == 1 || newenemy:GetNWBool("CPTBase_IsPossessing") then self:RemoveFromMemory(newenemy) end
		self:SetRelationship(newenemy,D_HT,true)
	else
		self:SetRelationship(newenemy,D_HT)
	end
	local findenemy = self:GetClosestEntity(self.tbl_EnemyMemory)
	self:SetEnemy(findenemy)
	if lastenemy != findenemy then
		self:OnEnemyChanged(findenemy)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:UpdateMemory()
	local enemymemory = self.tbl_EnemyMemory
	for _,v in ipairs(enemymemory) do
		if v:IsPlayer() && v.IsPossessing then
			self:RemoveFromMemory(v)
		end
		if !v:IsValid() || v:Health() <= 0 || ((v:IsPlayer() && (!v:Alive() || v.IsPossessing || GetConVarNumber("ai_ignoreplayers") == 1 || v.Faction == "FACTION_NOTARGET")) or ((v:IsValid() && self:Disposition(v)) != 1 && (v:IsValid() && self:Disposition(v)) != 2)) then
			self:RemoveFromMemory(v)
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:RemoveFromMemory(foundent)
	local enemymemory = self.tbl_EnemyMemory
	if foundent == nil then return false end
	if foundent == self:GetEnemy() then
		self:SetEnemy(nil)
		self:SetEnemy(NULL)
	end
	enemymemory[foundent] = nil
	self.EnemyMemoryCount = self.EnemyMemoryCount -1
	if self.EnemyMemoryCount < 0 then
		self.EnemyMemoryCount = 0
	end
	-- self:PlayerChat("Removed")
	return true
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CheckForValidMemory()
	local memory = self.tbl_EnemyMemory
	local nocheck_count = table.Count(memory)
	local checked_memory = {}
	if nocheck_count <= 0 then
		return 0
	elseif nocheck_count > 0 then
		for _,ent in ipairs(memory) do
			if ent != nil then
				// wut
			else
				table.insert(checked_memory,ent)
			end
		end
		if table.Count(checked_memory) > 0 then
			return table.Count(checked_memory)
		else
			return 0
		end
	end
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
	if dmg:GetDamagePosition() != Vector(0,0,0) or (self:IsOnFire() && (IsValid(dmg:GetAttacker()) && dmg:GetAttacker():GetClass() != "entityflame") && (DoIgnore == false)) then
		ParticleEffect(self:SelectFromTable(self.BloodEffect),dmg:GetDamagePosition(),Angle(math.random(0,360),math.random(0,360),math.random(0,360)),false)
	else
		if (self:IsOnFire() && (IsValid(dmg:GetAttacker()) && dmg:GetAttacker():GetClass() == "entityflame")) then return end
		ParticleEffect(self:SelectFromTable(self.BloodEffect),self:FindCenter(self),Angle(math.random(0,360),math.random(0,360),math.random(0,360)),false)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CreateBloodDecals(dmg,dmginfo,hitbox)
	if table.Count(self.BloodDecal) <= 0 then return end
	local min = 80
	local max = 500
	local tr = util.TraceLine({
		start = dmg:GetDamagePosition(),
		endpos = dmg:GetDamagePosition() +dmg:GetDamageForce():GetNormal() *math.Clamp(dmg:GetDamageForce():Length() *10,min,max),
		filter = self
	})
	util.Decal(self:SelectFromTable(self.BloodDecal),tr.HitPos +tr.HitNormal,tr.HitPos -tr.HitNormal)
	for i = 1,2 do
		if math.random(1,2) == 1 then
			util.Decal(self:SelectFromTable(self.BloodDecal),tr.HitPos +tr.HitNormal +Vector(math.random(-30,30),math.random(-30,30),0),tr.HitPos -tr.HitNormal)
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
	local _Inflictor = dmg:GetInflictor()
	local _Hitbox = self.Hitbox
	for _,v in ipairs(self.tbl_ImmuneTypes) do
		if dmginfo:IsDamageType(v) then
			DoIgnore = true
		end
	end
	if DoIgnore == false && self.IsDead == false /*&& self.IsRagdolled == false*/ && self.IsEssential == false && self:BeforeTakeDamage(dmg,_Hitbox) then
		local change = self:ChangeDamageOnHit(dmg,_Hitbox,dmginfo)
		-- print(change)
		self:SetHealth(self:Health() -change)
		self.DidGetHit = true
		timer.Simple(0.01,function() if self:IsValid() && self.DidGetHit == true then self.DidGetHit = false end end)
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
				if v:IsNPC() && v != self && (v:Disposition(self) == D_NU || v:Disposition(self) == D_LI) && !IsValid(v:GetEnemy()) then
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
		if !IsValid(self:GetEnemy()) then
			if self:GetState() == NPC_STATE_IDLE then
				self:SetState(NPC_STATE_ALERT)
			end
			-- print(self:CanPerformProcess(),self.IsPlayingSequence)
			if self.TurnsOnDamage && self:CanPerformProcess() && DoIgnore != true then
				self:StopCompletely()
				if _Inflictor != NULL then
					self:TASKFUNC_FACEPOSITION(_Inflictor:GetPos())
				else
					self:TASKFUNC_FACEPOSITION(_Pos)
				end
			end
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
	if IsValid(_Inflictor) && (self.FriendlyToPlayers && _Inflictor:IsPlayer() && self:Disposition(_Inflictor) == D_LI) then
		self.FriendlyToPlayers = false
		if self.Faction == "FACTION_PLAYER" then
			self.Faction = "FACTION_PLAYER_ENEMY"
		end
		self:SetRelationship(_Inflictor,D_HT)
	end
	if self:Health() <= 0 && self.IsDead == false then
		self:DoDeath(dmg,dmginfo,_Attacker,_Type,_Pos,_Force,_Inflictor,_Hitbox)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
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
			if self.CurrentSound != nil then
				self.NextPainSoundT = CurTime() +SoundDuration(self.CurrentPlayingSound) +math.random(self.PainSoundChanceA,self.PainSoundChanceB)
			end
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
function ENT:ChangeDamageOnHit(dmg,hitbox) return dmg:GetDamage() end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:BeforeTakeDamage(dmg,hitbox) return true end
---------------------------------------------------------------------------------------------------------------------------------------------
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
		self:SetNPCState(NPC_STATE_SCRIPT)
		self:PlayAnimation("Death")
		local deathtime
		if self.IsPlayingSequence then
			deathtime = self:AnimationLength(self.CurrentSequence,true)
		else
			deathtime = self:AnimationLength(self.CurrentAnimation)
		end
		if deathtime == nil then
			deathtime = 0
		end
		timer.Simple(deathtime +self.ExtraDeathTime,function()
			if self:IsValid() then
				if self.HasDeathRagdoll == true then
					self:CreateNPCRagdoll(dmg,dmginfo)
					self:OnDeathAnimationFinished(dmg,dmginfo,_Hitbox)
				end
				self:Remove()
			end
		end)
	else
		if self.HasDeathRagdoll == true then
			self:CreateNPCRagdoll(dmg,dmginfo)
		end
		self:Remove()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetNPCRenderMode(rend)
	self:SetRenderMode(rend)
	self.RenderMode = rend
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:GetNPCRenderMode()
	return self.RenderMode
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetRagdollEntity(ent)
	self.RagdollEntity = ent
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:GetRagdollEntity()
	return self.RagdollEntity
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CreateNPCRagdoll(dmg,dmginfo)
	local mdl = self:GetModel()
	local pos = self:GetPos()
	local ang = self:GetAngles()
	local skin = self:GetSkin()
	local rend = self:GetNPCRenderMode()
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
	local phy = string.Replace(mdl,".mdl",".phy")
	if !file.Exists(phy,"GAME") then return end // Checks if the model has physics
	local ragdoll = ents.Create(self.DeathRagdollType)
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
	if self.DeathRagdollKeepOverrides == true then
		ragdoll:SetRenderMode(rend)
		ragdoll:SetColor(rbg)
		ragdoll:SetMaterial(mat)
	end
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
				ragdoll:SetColor(Color(20,20,20,255))
			end
		end)
	end
	local dmgforce = dmg:GetDamageForce()
	for i = 1,128 do -- Credits to Dan
		local bonephys = ragdoll:GetPhysicsObjectNum(i)
		if IsValid(bonephys) then
			local bonepos,boneang = self:GetBonePosition(ragdoll:TranslatePhysBoneToBone(i))
			if(bonepos) then
				bonephys:SetPos(bonepos)
				bonephys:SetAngles(boneang)
				if dmg:IsBulletDamage() then
					bonephys:SetVelocity(dmgforce /20)
				else
					bonephys:SetVelocity(dmgforce /37)
				end
			end
		end
	end
	for i = 0,ragdoll:GetBoneCount() -1 do
		if i > 0 then
			ragdoll:ManipulateBonePosition(i,self:GetManipulateBonePosition(i))
			ragdoll:ManipulateBoneAngles(i,self:GetManipulateBoneAngles(i))
		end
	end
	ragdoll:SetVelocity(dmgforce /20)
	local the_ragdoll = ragdoll
	timer.Simple(GetConVarNumber("cpt_corpselifetime"),function()
		if IsValid(the_ragdoll) then
			the_ragdoll:Fire("FadeAndRemove","",0)
		end
	end)
	self:SetRagdollEntity(the_ragdoll)
	self:OnDeath_CreatedCorpse(the_ragdoll)
	return the_ragdoll
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnDeath_CreatedCorpse(the_ragdoll) end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CheckBeforeRagdollEnemy(ent) return true end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:RagdollEnemy(dist,vel)
	for _,ent in ipairs(ents.FindInSphere(self:GetPos(),dist)) do
		if ent:IsValid() && self:IsValid() && self:Visible(ent) && ent:Health() > 0 then
			if (ent:IsNPC() && ent != self && self:Disposition(ent) != D_LI && ent:GetModel() != self:GetModel()) && self:FindInCone(ent,self.MeleeAngle) then
				if ent.CanBeRagdolled == false then return end
				if ent.IsRagdolled == true then return end
				if self:GetClosestPoint(ent) <= dist then
					if self:CheckBeforeRagdollEnemy(ent) then
						ent:CreateRagdolledNPC(vel,self)
					end
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
	for _,v in pairs(self.LoopedSounds) do
		if v then
			v:Stop()
		end
	end
	if self.CurrentSound != nil then
		if self.CurrentPlayingSound != nil && (self.tbl_Sounds["Death"] != nil && table.HasValue(self.tbl_Sounds["Death"],self.CurrentPlayingSound)) then
			return
		end
		self.CurrentSound:Stop()
	end
	self:WhenRemoved()
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:WhenRemoved() end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomChecksBeforeDamage(ent)
	return true
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:AttackProps(props,dmg,dmgtype,force,OnHit)
	local center = self:GetPos() +self:OBBCenter()
	local didhit = false
	for _,v in ipairs(props) do
		if IsValid(v) then
			local phys = v:GetPhysicsObject()
			local force = self.PropAttackForce
			local forward,right,up = self:GetForward(),self:GetRight(),self:GetUp()
			force = forward *force.x +right *force.y +up *force.z
			didhit = true
			local dmgpos = v:NearestPoint(center)
			local dmginfo = DamageInfo()
			if self.HasMutated == true && (self.MutationType == "damage" or self.MutationType == "both") then
				dmg = math.Round(dmg *1.65)
			end
			local dif = GetConVarNumber("cpt_aidifficulty")
			local finaldmg
			if dif == 1 then
				finaldmg = dmg *0.5
			elseif dif == 2 then
				finaldmg = dmg
			elseif dif == 3 then
				finaldmg = dmg *2
			elseif dif == 4 then
				finaldmg = dmg *4
			end
			dmginfo:SetDamage(finaldmg)
			dmginfo:SetAttacker(self)
			dmginfo:SetInflictor(self)
			dmginfo:SetDamageType(dmgtype)
			dmginfo:SetDamagePosition(dmgpos)
			if force then
				dmginfo:SetDamageForce(force)
			end
			if(OnHit) then
				OnHit(v,dmginfo)
			end
			v:TakeDamageInfo(dmginfo)
			if phys:IsValid() then
				if self.UnfreezeProps == true then
					phys:EnableMotion(true)
				end
				phys:ApplyForceCenter(force)
			end
		end
	end
	if didhit then
		self:EmitSound("npc/zombie/zombie_pound_door.wav",55,100)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
// self:DoDamage(150,23,DMG_SLASH,Vector(0,0,0),Angle(0,0,0),OnHit)
// self:DoDamage(150,23,DMG_SLASH,Vector(0,0,0),Angle(0,0,0),function(ent,dmginfo)
//		print(ent)
//		return
// end)
function ENT:DoDamage(dist,dmg,dmgtype,force,viewPunch,OnHit)
	local pos = self:GetPos() +self:OBBCenter() +self:GetForward() *20
	local posSelf = self:GetPos()
	local center = posSelf +self:OBBCenter()
	local didhit
	local tblhit = {}
	local tblprops = {}
	local hitpos = Vector(0,0,0)
	for _,ent in ipairs(ents.FindInSphere(pos,dist)) do
		if ent:IsValid() && self:Visible(ent) then
			if self.AllowPropDamage then
				if table.HasValue(self.AttackablePropNames,ent:GetClass()) then
					table.insert(tblprops,ent)
				end
				self:AttackProps(tblprops,dmg,dmgtype,force,OnHit)
			end
			if ((ent:IsNPC() && ent != self && self:Disposition(ent) != D_LI && ent:GetModel() != self:GetModel()) || (ent:IsPlayer() && ent:Alive())) && (self:GetForward():Dot(((ent:GetPos() +ent:OBBCenter()) -pos):GetNormalized()) > math.cos(math.rad(self.ViewAngle))) then
				if self:CustomChecksBeforeDamage(ent) then
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
					if dmgtype != DMG_FROST then
						local dif = GetConVarNumber("cpt_aidifficulty")
						local finaldmg
						if dif == 1 then
							finaldmg = dmg *0.5
						elseif dif == 2 then
							finaldmg = dmg
						elseif dif == 3 then
							finaldmg = dmg *2
						elseif dif == 4 then
							finaldmg = dmg *4
						end
						dmginfo:SetDamage(finaldmg)
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
					else
						util.DoFrostDamage(dmg,ent,self)
					end
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
function ENT:DoTraceAttack(dist,dmg,dmgtype,dmgdist,trace,extradist)
	if IsValid(self) then
		local use
		trace = trace or util.QuickTrace(self:GetPos(),self:SetUpRangeAttackTarget(extradist),{self})
		if IsValid(self:GetEnemy()) then
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
function ENT:AutoSetupSoundTable(tbl,needles)
	local foundfiles = file.Find("sound/" .. self.SoundDirectory .. "*","GAME")
	for _,sndfile in ipairs(foundfiles) do
		for _,needle in ipairs(needles) do
			if string.find(sndfile,needle) /*&& (!self.CheckForLoopsInSoundDirectory && string.find(sndfile,"lp"))*/ then
				if !self.tbl_Sounds[tbl] then
					self.tbl_Sounds[tbl] = {}
				end
				table.insert(self.tbl_Sounds[tbl],sndfile)
			end
		end
	end
	for _,chksnd in ipairs(self.tbl_Sounds[tbl]) do
		if !string.find(self.SoundDirectory .. chksnd,string.Replace(chksnd,self.SoundDirectory,"")) then
			table.remove(self.tbl_Sounds[tbl],chksnd)
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:GetClosestEntity(tbl)
	-- local target = self:GetEntitiesByDistance(tbl)[1]
	-- if target:IsPlayer() && (GetConVarNumber("ai_ignoreplayers") == 1 || v.IsPossessing) then return NULL end
	-- print(self:GetEntitiesByDistance(tbl)[1])
	return self:GetEntitiesByDistance(tbl)[1]
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:GetEntitiesByDistance(tbl)
	local close = {}
	local result = NULL
	for _,v in pairs(tbl) do
		if IsValid(v) && (v:Health() <= 0 || !v:Alive() || (v:IsPlayer() && GetConVarNumber("ai_ignoreplayers") == 1)) then
			close[v] = -69
		else
			if IsValid(v) then
				close[v] = self:GetPos():Distance(v:GetPos())
			end
		end
		if close[v] == -69 then
			table.remove(close,close[v])
		end
	end
	return table.SortByKey(close,false)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetMovementAnimation(_Animation)
	local anim
	if _Animation == "Walk" && self.OverrideWalkAnimation != false then
		_Animation = self.OverrideWalkAnimation
	end
	if _Animation == "Run" && self.OverrideRunAnimation != false then
		_Animation = self.OverrideRunAnimation
	end
	if type(_Animation) == "string" then
		if self.tbl_Animations[_Animation] != nil then
			anim = self:SelectFromTable(self.tbl_Animations[_Animation])
		else
			anim = self:TranslateStringToNumber(_Animation)
		end
	elseif type(_Animation) == "number" then
		anim = _Animation
	end
	if type(anim) == "string" then
		anim = self:TranslateStringToNumber(anim)
	end
	if self:GetMovementAnimation() != anim then
		self:SetMovementActivity(anim)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:PlayActivity(activity,facetarget,usetime,addtime,slvbackwardscompatibility)
	-- if self.IsSLVBaseNPC then
		-- local TAct
		-- local bFaceEnemy
		-- local fcDone
		-- local bDontResetAct
		-- local bDontStopMoving
		-- if activity then
			-- TAct = activity
		-- end
		-- if facetarget then
			-- bFaceEnemy = facetarget
		-- end
		-- if usetime then
			-- fcDone = usetime
		-- end
		-- if addtime then
			-- bDontResetAct = addtime
		-- end
		-- if slvbackwardscompatibility then
			-- bDontStopMoving = slvbackwardscompatibility
		-- end
		-- self:SLVPlayActivity(TAct,bFaceEnemy,fcDone,bDontResetAct,bDontStopMoving)
		-- return
	-- end
	local fly = false
	local usegesture = false
	local usesequence = false
	local extratime = nil
	if usetime then
		if CurTime() < self.NextAnimT then return end
	end
	if addtime == nil then
		extratime = 0
	else
		extratime = addtime
	end
	if type(activity) == "number" then
		activity = activity
	else
		if string.find(activity,"cptges_") then
			usegesture = true
		elseif string.find(activity,"cptseq_") then
			usesequence = true
		else
			activity = self:TranslateStringToNumber(activity)
		end
	end
	if usegesture == true then self:PlayNPCGesture(string.Replace(activity,"cptges_",""),2,self.GlobalAnimationSpeed) return end
	if usesequence == true then self:PlaySequence(string.Replace(activity,"cptseq_",""),self.GlobalAnimationSpeed) return end
	if activity == nil then return end
	if self:AnimationLength(activity) == 0 then return end
	if self:GetMoveType() == MOVETYPE_FLY then fly = true end
	if fly == true then self:PlayActivity_Fly(activity) return end
	self:StopProcessing()
	self.CanChaseEnemy = false
	local sched = ai_sched_cpt.New(activity)
	local task = "TASK_PLAY_SEQUENCE"
	if (self:IsMoving() or self.CurrentSchedule) then
		self:StopMoving()
		self:StopMoving()
		self:StartEngineTask(GetTaskID("TASK_RESET_ACTIVITY"),0)
	end
	if facetarget then
		if(facetarget == 1) then
			task = "TASK_PLAY_SEQUENCE_FACE_TARGET"
		elseif(facetarget == 2) then
			task = "TASK_PLAY_SEQUENCE_FACE_ENEMY"
		else
			task = "TASK_PLAY_SEQUENCE"
		end
	end
	self:ClearSchedule()
	sched:EngTask(task,activity)
	self:StartSchedule(sched)
	self.CurrentAnimation = activity
	self.IsPlayingActivity = true
	self:MaintainActivity()
	self:OnStartedAnimation(activity)
	self.NextAnimT = CurTime() +self:AnimationLength(activity)
	timer.Simple(self:AnimationLength(activity) +extratime,function()
		if self:IsValid() then
			self:SetNPCState(NPC_STATE_NONE)
			self.IsPlayingActivity = false
			self.CanChaseEnemy = true
			self:OnFinishedAnimation(activity)
		end
	end)
	return activity
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:GetMovementAnimation()
	return self:GetMovementActivity()
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:GetDistanceToVector(pos,type)
	if type == 1 then
		return self:GetPos():Distance(pos)
	elseif type == 2 then
		return self:NearestPoint(pos)
	end
end