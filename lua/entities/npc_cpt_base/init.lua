if !CPTBase then return end
AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('ai_schedules.lua')
include('controller.lua')
include('shared.lua')
include('tasks.lua')
include('states.lua')

local table_HasValue = table.HasValue
local table_insert = table.insert
local table_Count = table.Count
local string_Replace = string.Replace

AccessorFunc(ENT,"m_iClass","NPCClass",FORCE_NUMBER)
AccessorFunc(ENT,"m_fMaxYawSpeed","MaxYawSpeed",FORCE_NUMBER)

if SERVER then
	util.AddNetworkString("cpt_SpeakingPlayer")
end

	-- Initialize Variables --
ENT.ModelTable = nil
ENT.CollisionBounds = Vector(0,0,0) -- Change from Vector(0,0,0) to apply. If set to Vector(0,0,0), it will use HULL type bounds
ENT.StartHealth = 10 -- How much health the NPC starts out with
ENT.Mass = 5000 // 7670 is standard for attacking chairs and benches | Human sized NPCs
ENT.CanBeRagdolled = true -- Can the NPC be ragdolled by enemies if the damage is critical?
ENT.RagdolledPosSubtraction = 20 -- How far "down" the NPC is while ragdolled (the NPC becomes invisible when ragdolled and follows the ragdoll entity around)
ENT.RagdollRecoveryTime = 5 -- How long until the NPC gets up
ENT.MaxTurnSpeed = 50 -- How fast the NPC can turn

	-- AI Variables --
ENT.DefaultAIType = AITYPE_NORMAL
ENT.ProcessingTime = 0.3 -- AI Processing will run every X seconds (lower numbers = more lag)
ENT.LoseEnemiesTime = 20 -- Time until the NPC loses its' targets and becomes idle
ENT.UseCPTBaseAINavigation = false -- Can this NPC use the generated nodegraph instead of the default?
ENT.UseNavMesh = false -- Can this NPC use nav mesh instead of nodes?
ENT.CanSeeAllEnemies = false -- If set to true, it can see every enemy on the map
-- ENT.UseNotarget = false -- Place this in the OnInit function
ENT.IsBlind = false -- Is the NPC blind? (Experimental)
ENT.FindEntitiesDistance = 7500 -- Same as ViewDistance
ENT.ViewDistance = 7500 -- How far the NPC can see (In WU. Increasing may impact performance)
ENT.ViewAngle = 75 -- How far the NPC can see (Based on a cone system)
ENT.CanMove = true -- Can the NPC move AT ALL?
ENT.CanWander = true
ENT.WanderChance = 60 -- The change that the NPC will wander while idle
ENT.CanSetEnemy = true -- Can the NPC set its' enemy? (Can be changed at anytime in the code)
ENT.CanChaseEnemy = true -- Can the NPC chase its' enemy? (Can be changed at anytime in the code)
ENT.MeleeAngle = 45 -- How far the melee attack reaches (Based on a cone system) Example: NPC <) Enemy
ENT.ReactsToSound = true -- Will the NPC react to hearing noises?
ENT.UseAdvancedHearing = false -- Will the NPC use the advanced hearing system? Note that this can be VERY LAGGY
ENT.HearingDistance = 900 -- How far the NPC can hear noises
ENT.Faction = nil -- Required for every NPC. Use the same one amongst your NPCs to make them allies
ENT.FriendlyToPlayers = false -- Is the NPC friendly to players?
ENT.Confidence = 2 -- Obsolete
ENT.UseDefaultPoseParameters = true -- Can the NPC use pose parameters? (turn head, body, etc.)
ENT.DefaultPoseParameters = {"aim_pitch","aim_yaw","head_pitch","head_yaw","body_pitch","body_yaw"}
ENT.DefaultPoseParamaterSpeed = 20 -- The rate at which the pose parameter will adjust (similar to turning speed)
ENT.ReversePoseParameters = false -- Reverse pose parameters if they were not properly made
ENT.ForceReloadAnimation = false -- Obsolete
ENT.GlobalAnimationSpeed = 1 -- Determines *most* animation speeds (doesn't effect walkframes)
ENT.HasAlertAnimation = false -- Does the NPC play an alerted animation when spotting an enemy?
ENT.AlertAnimationChance = 5 -- Chance the animation will play
ENT.AllowPropDamage = true -- If set to true, the NPC will damage/effect props when it melee attacks
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
ENT.FallingHeight = 32 -- Determines how many WU until the NPC thinks it is falling
ENT.HasFallingAnimation = false -- Set to true for them to play an idle while falling
ENT.CanRagdollEnemies = false -- Can the NPC ragdoll players/NPCs?
ENT.RagdollEnemyChance = 5 -- Chance the enemy will be ragdolled upon being hit
ENT.RagdollEnemyVelocity = Vector(0,0,0) -- Forward/Backward, Left/Right, Up/Down | 100 = forward/ -100 = backward, 100 = right/ -100 = left, 100 = up/ -100 = down
ENT.CanFollowFriendlyPlayers = true -- Can the NPC follow players if "Used"
ENT.HateFollowedPlayerThreshold = 15 -- Chance that the following NPC will hate you upon being hit
ENT.CheckDispositionOnAttackEntity = true -- Set to false to allow team damage

	-- Air AI Variables --
ENT.FlyUpOnSpawn = true -- Will the NPC hover upward to gain some ground when first spawned without any enemies?
ENT.FlyUpOnSpawn_Time = 2 -- Time until the NPC stops hovering upward
ENT.FlyRandomDistance = 400 -- Maximum distance to hover upward

	-- Swim AI Variables --
ENT.Swim_CheckYawDistance = 700 -- Max yaw check
ENT.Swim_CheckPitchDistance = 100 -- Max pitch check
ENT.Swim_WaterLevelCheck = 0 -- The enemy's water level must be higher than this to target

	-- Damage Variables --
ENT.IsEssential = false -- Can the NPC die?
ENT.Bleeds = true -- Does the NPC create blood particles?
ENT.BloodEffect = nil
ENT.LeavesBlood = true -- Don't need to set this to false if the table below is empty, it'll just not make decals
ENT.AutomaticallySetsUpDecals = true -- Not finished yet
ENT.BloodDecal = {}
ENT.HasFlinchAnimation = false -- Does the NPC flinch when attacked?
ENT.FlinchChance = 10 -- Chance the NPC will flinch
ENT.TurnsOnDamage = true -- Does the NPC turn when damaged (No present enemy)
ENT.HateFriendlyPlayerThreshold = 4 -- Chance that the NPC will hate you upon being hit
ENT.ShoutForHelpTime = 0.3 -- Time until the NPC shouts for allies after being hurt
ENT.ShoutForHelpDistance = 1500 -- How far can it call for allies to come aid it when damaged?
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
ENT.Possessor_CanTurnWhileAttacking = true
ENT.Possessor_CanMove = true
ENT.Possessor_CanSprint = true
ENT.Possessor_CanFaceTrace = false
ENT.Possessor_CanFaceTrace_Walking = false
ENT.Possessor_CanFaceTrace_Running = false
ENT.Possessor_UsePossessorViewTable = false
ENT.PossessorView = {
	Pos = {Right = 0,Forward = 0,Up = 0}
}

	-- Tables --
ENT.tbl_Animations = nil
ENT.tbl_Sounds = nil
ENT.tbl_Sentences = nil -- Basically the Half-Life 1 sentence system
ENT.tbl_ImmuneTypes = nil -- DMG_ types the NPC won't take damage from
ENT.tbl_Capabilities = nil -- CAP_ types for the NPC
ENT.tbl_AttackablePropNames = {"prop_physics","func_breakable","prop_physics_multiplayer","func_physbox"}
ENT.tbl_IgnoreEntities = {
	bullseye_strider_focus = true,
} -- Entities to be ignored

	-- Sound Variables --
ENT.CanPlaySounds = true
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
function ENT:HandleSchedules(enemy,dist,nearest,disp,time)
	if disp == D_HT then
		self:ChaseEnemy()
	elseif disp == D_FR then
		self:Hide()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:UpdateSight(sight,find)
	self.SightDistance = sight
	self.FindEntitiesDistance = find
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:UpdateCollision(collData)
	self:SetCollisionBounds(Vector(collData.x,collData.y,collData.z),Vector(-collData.x,-collData.y,0))
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
function ENT:OnInputAccepted(event,activator) end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnFollowAI(owner,dist) end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnFollowPlayer(ply)
	ply:ChatPrint("This NPC will now follow you")
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnUnFollowPlayer(ply)
	ply:ChatPrint("This NPC will no longer follow you")
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnDenyFollowPlayer(ply)
	ply:ChatPrint("This NPC is already following someone")
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThink() end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThink_Disabled() end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThink_NotPossessed() end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CanSetAsEnemy(ent)
	return true
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CanSeeEntities(ent)
	if self:CPT_FindDistance(ent) <= self.ViewDistance then
		if self.IsBlind then
			return false
		else
			return true
		end
		return true
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CheckRelationship(ent)
	if self:CPT_GetDisp(ent) == D_LI then
		return "like"
	elseif self:CPT_GetDisp(ent) == D_HT then
		return "hate"
	elseif self:CPT_GetDisp(ent) == D_NU then
		return "none"
	elseif self:CPT_GetDisp(ent) == D_FR then
		return "fear"
	else
		return "error"
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetEntityPriority(ent,relationship) -- Override this to change the priority of an entity
	if ent:IsPlayer() then
		return 75
	else
		return 50
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:GetRelationship(entity)
	local LI = self.MemoryTable[D_LI][entity]
	local HT = self.MemoryTable[D_HT][entity]
	local NU = self.MemoryTable[D_NU][entity]
	local FR = self.MemoryTable[D_FR][entity]

	return LI && D_LI or HT && D_HT or NU && D_NU or FR && D_FR or 0
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnFoundNewEntity(ent,relationship,priority)
	if relationship == D_LI then
		self:OnSpottedFriendly(ent,priority)
	elseif relationship == D_HT then
		self:OnSpottedEnemy(ent,priority)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnSpottedFriendly(ent) end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnSpottedEnemy(ent) end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnEntityRemovedFromMemory(ent,disp)
	if ent == self:GetEnemy() then
		self:SetEnemy(NULL)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnFoundEnemy(count,oldcount,ent) end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnEnemyChanged(ent) end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnAreaCleared() print("AREA CLEARED") end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnLostEnemy(ent) print("LOST " .. ent) end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnKilledEnemy(ent) end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnCondition(cond,state) end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnStartTask(schedule) end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnChaseEnemy(ent) self:SetMovementAnimation("Run") end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnStartedAnimation(activity) end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnFinishedAnimation(activity) end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnLand() end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomChecksForProcesses()
	return false
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnTraceRun(traceHit) end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnTraceHit(ent,traceHit) end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnDoDamage(didhitsomething,hitents,hitpos) end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomChecksBeforeDamage(ent)
	return true
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetUpRangeAttackTarget(subtractdist,proj)
	local ent = proj or self
	if self.IsPossessed then
		return (self:Possess_AimTarget() -ent:GetPos())
	else
		if IsValid(self:GetEnemy()) then
			if self:GetEnemy():IsPlayer() then
				return ((self:GetEnemy():GetPos() -self:LocalToWorld(Vector(0,0,0))) +self:CheckPlayerMoveDirection(self:GetEnemy(),subtractdist))
			else
				return (self:GetEnemy():GetPos() -self:LocalToWorld(Vector(0,0,0)))
			end
		else
			return ((ent:GetPos() +self:GetForward() *900) -self:LocalToWorld(Vector(0,0,0)))
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnAttackFinish(anim) end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CheckBeforeRagdollEnemy(ent) return true end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:GetRagdollEntity()
	return self.RagdollEntity
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CheckRagdollSettings() end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnRagdollRecover() end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:BeforeTakeDamage(dmg,hitbox,dmginfo) return true end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnFlinch(dmg,dmginfo,hitbox) end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnTakePain(dmg,dmginfo,hitbox) end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:ChangeDamageOnHit(dmg,hitbox) return dmg:GetDamage() end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:BeforeDoDeath(dmg,dmginfo,_Attacker,_Type,_Pos,_Force,_Inflictor,_Hitbox) return true end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnShoutForHelp(allies) end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnRepondToHelp(ally) end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnDeathAnimationFinished(dmg,dmginfo,hitbox) end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnDeath(dmg,dmginfo,hitbox) end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnDeath_CreatedCorpse(the_ragdoll) end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:WhenRemoved() end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:GetAIType()
	return self.AIType
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:GetNPCRenderMode()
	return self.RenderMode
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
function ENT:OnDoIdle() end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnStep(steptype) end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:DoPlaySound(tbl) end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnPlaySound(sound,tbl) end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:GetIdleAnimation()
	if self.IdleAnimation == nil then
		return ACT_IDLE
	else
		return self.IdleAnimation
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:GetMovementAnimation()
	return self:GetMovementActivity()
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:MovementType()
	return self.MoveType
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:GetSwimSpeed() return self.SwimSpeed end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:GetFastSwimSpeed() return self.SwimSpeedEnhanced end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:GetFlySpeed() return self.FlySpeed end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:GetFastFlySpeed() return self.FlySpeedEnhanced end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Initialize()
	self:SetSpawnEffect(false)
	self.CPTBase_NPC = true
	self.UseNotarget = false
	self:SetAIType(self.DefaultAIType)
	if !IsValid(self:GetOwner()) then
		self:SetOwner(self:GetCreator())
	end
	self:SetNW2Bool("IsCPTBase_NPC",true)
	self:SetNW2Entity("cpt_SpokenPlayer",NULL)
	-- self:SetNW2String("cpt_Faction",self.Faction)
	self:SetNPCModel()
	self:DrawShadow(true)
	self:SetHullSizeNormal()
	self:SetCollisionGroup(COLLISION_GROUP_NPC)
	if self.CollisionBounds != Vector(0,0,0) then
		self:UpdateCollision(self.CollisionBounds)
	end
	self:SetSolid(SOLID_BBOX)
	self:SetMaxYawSpeed(self.MaxTurnSpeed)
	local dif = math.Round(GetConVarNumber("cpt_aidifficulty"))
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
	self:SetEnemy(NULL)
	self.RenderMode = RENDERMODE_NORMAL
	self:SetNPCRenderMode(RENDERMODE_NORMAL)
	self.HasSetTypeOnSpawn = false
	self.IsPossessed = false
	self.DidGetHit = false
	self.tbl_EnemyMemory = {}
	self.tbl_FriendMemory = {}
	self.MemoryTable = {
		[D_HT] = {},
		[D_FR] = {},
		[D_LI] = {},
		[D_NU] = {}
	}
	self.EnemyMemoryCount = 0
	self:ClearMemory()
	self.IsDead = false
	self.HasStoppedMovingToAttack = false
	self.NextAnimT = CurTime()
	self.IdleAnimation = ACT_IDLE
	self.NextIdleAnimationT = 0
	self.IsRagdolled = false
	self.AlreadyResetPoseParamaters = false
	self.LoopedSounds = {}
	self.tbl_BlackList = {}
	self.tbl_AddToEnemies = {}
	self.bInSchedule = false
	self.IsStartingUp = false
	self.CurrentHeardEnemy = nil
	self.NextHearSoundT = 0
	self.IsPlayingSequence = false
	self.IsPlayingActivity = false
	self.IsPlayingLuaAnimation = false
	self.LuaAnimationData = {}
	self.CurrentLuaAnimationFrame = nil
	self.LuaAnimationLength = 0
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
	self.LastRagdollMoveT = CurTime() +1
	self.LostWeapon = false
	self.LastUsedWeapon = nil
	self.IsSwimType = false
	self.Swim_TargetAngle = self:GetAngles()
	self.Swim_Direction_Yaw = 0
	self.Swim_Direction_Pitch = 0
	self.NextSwimDirection_YawT = 0
	self.NextSwimDirection_PitchT = 0
	self.Swim_NextRandomDirectionT = 0
	self.NextAcceptT = 0
	self.TimeSinceLastTimeFalling = 0
	self.tbl_Speakers = {}
	self.tbl_RegisteredNodes = {}
	self.tbl_CreatedAttacks = {}
	self.NPC_Enemy = nil
	self.Enemy = NULL
	self.LastSpottedEnemyT = 0
	self.HasAutoResetEnemy = false
	-- self:SetNW2String("CPTBase_NPCFaction",self.Faction)
	-- if GetConVarNumber("cpt_aiusecustomnodes") == 1 then
	-- 	self.UseCPTBaseAINavigation = true
	-- end
	-- if GetConVarNumber("cpt_aiusenavmesh") == 1 then
	-- 	self.UseNavMesh = true
	-- end
	-- if self.UseNavMesh == true then
	-- 	self.UseCPTBeaseAINavigation = false
	-- 	self:SpawnNavMeshEntity()
	-- end
	self.tbl_Inventory = {
		["Primary"] = nil,
		["Melee"] = nil,
	}
	local faction = self.Faction
	if type(faction) == "string" then -- Backwards capability for old factions
		self.Faction = {faction}
	end
	self.VJ_NPC_Class = {}
	for _,v in ipairs(self.Faction) do
		table_insert(self.VJ_NPC_Class,string_Replace(v,"FACTION_","CLASS_"))
	end
	
	self:UpdateSight(self.SightDistance,self.FindEntitiesDistance)
	
	if GetConVarNumber("cpt_decals") == 0 then
		self.LeavesBlood = false
	end
	if self.LeavesBlood == true then
		if self.AutomaticallySetsUpDecals && table_Count(self.BloodDecal or {}) <= 0 then
			self:SetupBloodDecals()
		end
	end

	if self.SetInit then
		self:SetInit()
	end
	if self.AfterInit then
		self:AfterInit()
	end

	if self.HasSetTypeOnSpawn == false then
		self:SetMovementType(MOVETYPE_STEP)
	end

	if GetConVarNumber("cpt_npchearing_advanced") == 1 then
		self.UseAdvancedHearing = true
	end

	self.tbl_Animations = self.tbl_Animations or {}
	self.tbl_Sounds = self.tbl_Sounds or {}
	self.tbl_Sentences = self.tbl_Sentences or {}
	self.tbl_ImmuneTypes = self.tbl_ImmuneTypes or {}
	self.tbl_Capabilities = self.tbl_Capabilities or {}
	self.BloodEffect = self.BloodEffect or {}

	if table_Count(self.tbl_Capabilities or {}) > 0 then
		for _,cap in ipairs(self.tbl_Capabilities) do
			if type(cap) == "number" then
				self:CapabilitiesAdd(bit.bor(cap))
				if cap == CAP_MOVE_JUMP then self.HasFallingAnimation = true end
			end
		end
	end

	if self.SetupSoundTables == true then
		if self.SoundDirectory == nil then
			MsgN("CPTBase warning: " .. self .. " has no sound directory. Please add a sound directory.")
			return
		end
		self:FindSounds()
	end

	local idleanim = self:GetIdleAnimation()
	if idleanim == nil then self:SetIdleAnimation(ACT_IDLE) end

	hook.Add("OnEntityCreated",self,function(self,ent)
		if ent:IsNPC() then
			if !ent.IsCPTBase_NPC then
				if ent:FindAntlionFaction()[ent:GetClass()] then
					ent.Faction = {"FACTION_ANTLION"}
				elseif ent:FindMilitaryFaction()[ent:GetClass()] then
					ent.Faction = {"FACTION_MILITARY"}
				elseif ent:FindCombineFaction()[ent:GetClass()] then
					ent.Faction = {"FACTION_COMBINE"}
				elseif ent:FindRebelFaction()[ent:GetClass()] then
					ent.Faction = {"FACTION_PLAYER"}
				elseif ent:FindXenFaction()[ent:GetClass()] then
					ent.Faction = {"FACTION_XEN"}
				elseif ent:FindZombieFaction()[ent:GetClass()] then
					ent.Faction = {"FACTION_ZOMBIE"}
				end
			end
			self:ApplyRelationships(ent)
		end
	end)

	self:SetSurroundingBoundsType(BOUNDS_HITBOXES)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SpawnNavMeshEntity()
	self.NavMeshEntity = ents.Create("cpt_ai_pathfinding")
	self.NavMeshEntity:SetPos(self:GetPos() +self:GetForward() *50)
	self.NavMeshEntity:SetOwner(self)
	self.NavMeshEntity:Spawn()
	self:DeleteOnRemove(self.NavMeshEntity)
	self:SetCustomCollisionCheck(true)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:PlaySpriteAnim(anim)
	self:SetSpriteAnim(anim)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CalculateSpriteAnimTime(totalFrames,fps)
	return (1 /fps) *totalFrames
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnSpriteAnimEnd(parentName,seqName,dir) end
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
		self:SetAngles(Angle(0,(self:CPT_FindCenter(enemy) -self:CPT_FindCenter(self)):Angle().y,0))
		self:SetLocalVelocity(fly)
	end
	if self.BackAwayDistance == nil then return end
	if nearest < self.BackAwayDistance then
		local fly = (util.RandomVectorAroundPos(tr.HitPos,self.FlyRandomDistance) +self:GetPos() +self:GetVelocity() *15):GetNormal() *self:GetFlySpeed()
		self:SetAngles(Angle(0,(self:CPT_FindCenter(enemy) -self:CPT_FindCenter(self)):Angle().y,0))
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
function ENT:CanPerformProcess()
	if self.IsAttacking == true or self.IsPlayingActivity == true or self.IsPlayingLuaAnimation == true or self.IsRangeAttacking == true or self.IsRagdolled == true or self.bInSchedule == true or self.IsPlayingSequence == true or self:CustomChecksForProcesses() then
		return false
	end
	return true
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnSpawn_Fly()
	if !IsValid(self:GetEnemy()) && self.FlyUpOnSpawn == true then
		local time = self.FlyUpOnSpawn_Time
		self.IsStartingUp = true
		self:SetLocalVelocity(self:GetVelocity() *0.9 +self:GetUp() *self.FlySpeed /4)
		timer.Simple(time,function()
			if (IsValid(self) && !IsValid(self:GetEnemy()) && self.IsStartingUp == true) then
				self.IsStartingUp = false
				self:SetLocalVelocity(Vector(0,0,0))
			end
		end)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:WhileFalling()
	if self.HasFallingAnimation then
		local fall = self:GetIdleAnimation()
		if type(fall) == "string" then
			fall = self:CPT_TranslateStringToNumber(fall)
		end
		self:StartEngineTask(GetTaskID("TASK_SET_ACTIVITY"),fall)
		self:MaintainActivity()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
/*
	Can be called like this:
	function ENT:Initialize() self:SetModel(self:LoadObjectData("sky","draugr").["Models"][1]) end
	function ENT:CreateParticleOnAttack() CPT_ParticleEffect(self:LoadObjectData("sky","draugr").["Particles"][1],blah,blah,blah) end
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
			table_insert(objectcache["Models"],data)
		end
		if string.find(data,".pcf") then
			table_insert(objectcache["Particles"],data)
		end
		if string.find(data,".wav") then
			table_insert(objectcache["Sounds"],data)
		end
	end
	return objectcache
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:ErrorOccured(data)
	self:SetModel("models/Kleiner.mdl")
	self:CapabilitiesAdd(bit.bor(CAP_ANIMATEDFACE,CAP_TURN_HEAD))
	if math.random(1,2) == 1 then
		self:EmitSound("vo/k_lab/kl_fiddlesticks.wav",110,100)
	else
		self:EmitSound("vo/k_lab/kl_dearme.wav",110,100)
	end
	self:PlayerChat(tostring(self) .. " has errored out!")
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetNPCModel(mdl)
	if mdl == nil then
		if table_Count(self.ModelTable) > 0 then
			self:SetModel(self:SelectFromTable(self.ModelTable))
		-- else
			-- self:ErrorOccured()
		end
	else
		self:SetModel(mdl)
	end
	self:SetSurroundingBoundsType(BOUNDS_HITBOXES)
end
---------------------------------------------------------------------------------------------------------------------------------------------
local ang0 = Angle(0,0,0)
--
function ENT:ApplyAngles(ang,speed,y)
	local target = (type(ang) == "Vector" && Angle(0,(ang -self:GetPos()):Angle().y,0)) or ang
	local speed = speed or self:GetMaxYawSpeed()
	if y then
		self:SetIdealYawAndUpdate(target.y,speed)
		self:SetAngles(Angle(target.p,self:GetAngles().y,target.r))
		return
	end
	self:SetAngles(LerpAngle(FrameTime() *speed,self:GetAngles(),target))
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:TurnToPosition(pos,speed)
	local speed = speed or self:GetMaxYawSpeed()
	local ang = Angle(0,(pos -self:GetPos()):Angle().y,0)
	self:SetIdealYawAndUpdate(ang.y,speed or self:GetMaxYawSpeed())
	self:SetAngles(Angle(ang.p,self:GetAngles().y,ang.r))
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:GetLastPosition()
	return self:GetInternalVariable("m_vecLastPosition")
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:FacePosition(pos)
	self:SetLastPosition(pos)
	self:RunTaskArray({"TASK_FACE_LASTPOSITION"},{0})
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetupBloodDecals()
	if table_Count(self.BloodEffect or {}) > 0 && table_Count(self.BloodDecal or {}) <= 0 then
		if table_HasValue(self.BloodEffect,"blood_impact_red") then
			table_insert(self.BloodDecal,"CPTBase_RedBlood")
		end
		if table_HasValue(self.BloodEffect,"blood_impact_yellow") then
			table_insert(self.BloodDecal,"CPTBase_YellowBlood")
		end
		if table_HasValue(self.BloodEffect,"blood_impact_red_01") then
			table_insert(self.BloodDecal,"Blood")
		end
		if table_HasValue(self.BloodEffect,"blood_impact_yellow_01") or table_HasValue(self.BloodEffect,"blood_impact_green_01") then
			table_insert(self.BloodDecal,"YellowBlood")
		end
		if table_HasValue(self.BloodEffect,"blood_impact_blue") then
			table_insert(self.BloodDecal,"CPTBase_BlueBlood")
		end
		if table_HasValue(self.BloodEffect,"blood_impact_green") then
			table_insert(self.BloodDecal,"CPTBase_GreenBlood")
		end
		if table_HasValue(self.BloodEffect,"blood_impact_purple") then
			table_insert(self.BloodDecal,"CPTBase_PurpleBlood")
		end
		if table_HasValue(self.BloodEffect,"blood_impact_orange") then
			table_insert(self.BloodDecal,"CPTBase_OrangeBlood")
		end
		if table_HasValue(self.BloodEffect,"blood_impact_white") then
			table_insert(self.BloodDecal,"CPTBase_WhiteBlood")
		end
		if table_HasValue(self.BloodEffect,"blood_impact_black") then
			table_insert(self.BloodDecal,"CPTBase_BlackBlood")
		end
		if table_HasValue(self.BloodEffect,"blood_impact_pink") then
			table_insert(self.BloodDecal,"CPTBase_PinkBlood")
		end
		if table_HasValue(self.BloodEffect,"blood_impact_infection") then
			table_insert(self.BloodDecal,"CPTBase_ZombieBlood")
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetInit()
	self:SetHullType(HULL_HUMAN)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:AcceptInput(input,activator,caller,data)
	if IsValid(activator) && activator:IsPlayer() && CurTime() > self.NextAcceptT then
		if self.CanFollowFriendlyPlayers && self:CPT_GetDisp(activator) == D_LI then
			if !self.IsFollowingAPlayer then
				self.IsFollowingAPlayer = true
				self.TheFollowedPlayer = activator
				self.CanWander = false
				self.MinimumFollowDistance = math.random(120,150)
				self:OnFollowPlayer(activator)
			else
				if activator == self.TheFollowedPlayer then
					self.IsFollowingAPlayer = false
					self.TheFollowedPlayer = NULL
					self.CanWander = true
					self:OnUnFollowPlayer(activator)
				else
					self:OnDenyFollowPlayer(activator)
				end
			end
		end
		self.NextAcceptT = CurTime() +0.75
	end
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
function ENT:CheckMeleeDistance(ExtraDist)
	if self.MeleeAttackDistance != nil && IsValid(self:GetEnemy()) then
		if self:GetEnemy():GetPos():Distance(self:GetPos()) <= self.MeleeAttackDistance +ExtraDist && self.HasStoppedMovingToAttack == false then
			self:CPT_StopCompletely()
			self.HasStoppedMovingToAttack = true
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.NextRelationshipCheckT = 0
function ENT:UpdateRelations() // Obsolete
	if self.Faction == "FACTION_NONE" or self.CanSetEnemy == false then return end
	if CurTime() > self.NextRelationshipCheckT then
		for _,v in ipairs(ents.GetAll()) do
			if v:IsNPC() && v.Faction != nil && v != self then
				if v.Faction == "FACTION_NONE" then return end
				if v.UseNotarget then return end
				if self.Faction != v.Faction && self:CPT_GetDisp(v) != D_HT then
					self:SetRelationship(v,D_HT)
				elseif self.Faction == v.Faction && self:CPT_GetDisp(v) != D_LI then
					self:SetRelationship(v,D_LI)
				end
			elseif v:IsPlayer() && v:Alive() && v.IsPossessing == false then
				if v.Faction == "FACTION_NOTARGET" then return end
				if (self:CPT_GetFaction() == "FACTION_PLAYER" or self.FriendlyToPlayers == true) && !table_HasValue(self.tbl_AddToEnemies,v) then
					if v.IsPossessing == true then return end
					if GetConVarNumber("ai_ignoreplayers") == 1 then return end
					self:SetRelationship(v,D_LI)
				else
					if self.FriendlyToPlayers == true then return end
					if v.IsPossessing == true then return end
					if GetConVarNumber("ai_ignoreplayers") == 1 then return end
					if self:CPT_CheckConfidence(v) == "attack!" then
						self:SetRelationship(v,D_HT)
					elseif self:CPT_CheckConfidence(v) == "run!" then
						self:SetRelationship(v,D_FR)
					end
				end
			end
		end
		self.NextRelationshipCheckT = CurTime() +1
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CheckPoseParameters()
	-- if self:CheckForValidMemory() == 0 then
	if !IsValid(self:GetEnemy()) then
		if self.AlreadyResetPoseParamaters == false then
			self.AlreadyResetPoseParamaters = true
			self:ClearPoseParameters()
		end
	else
		self.AlreadyResetPoseParamaters = false
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:IdleSounds()
	if self.IsPossessed == false then
		if !IsValid(self:GetEnemy()) then
			if CurTime() > self.NextIdleSoundT && math.random(1,3) == 1 then
				self:PlayIdleSound()
				if self.CurrentSound != nil then
					self.NextIdleSoundT = CurTime() +SoundDuration(self.CurrentPlayingSound) +math.random(self.IdleSoundChanceA,self.IdleSoundChanceB)
				end
			end
		end
	else
		if !IsValid(self:GetEnemy()) && CurTime() > self.NextIdleSoundT && math.random(1,3) == 1 then
			self:PlayIdleSound()
			if self.CurrentSound != nil then
				self.NextIdleSoundT = CurTime() +SoundDuration(self.CurrentPlayingSound) +math.random(self.IdleSoundChanceA,self.IdleSoundChanceB)
			end
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:IsClimbing()
	if self:GetActivity() == ACT_CLIMB_UP or self:GetActivity() == ACT_CLIMB_DOWN or self:GetActivity() == ACT_CLIMB_DISMOUNT then
		return true
	end
	return false
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:IsJumping()
	if self:GetActivity() == ACT_JUMP or self:GetActivity() == ACT_GLIDE or self:GetActivity() == ACT_LAND then
		return true
	end
	return false
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:IsWalking()
	if self.CurrentSchedule != nil && (self.CurrentSchedule.Name == "_lastpositiontask_walk" or self.CurrentSchedule.Name == "_wandertaskfunc") then
		return true
	end
	return false
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:IsRunning()
	if self.CurrentSchedule != nil && (self.CurrentSchedule.Name == "_lastpositiontask_run" or self.CurrentSchedule.Name == "_lastpositiontask" or self.CurrentSchedule.Name == "_chasetaskfunc" or self.CurrentSchedule.Name == "getpathandchasetask" or self.CurrentSchedule.Name == "_hidetask" or self.CurrentSchedule.Name == "_followplayer") then
		return true
	end
	return false
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Summon_FaceOwner(owner)
	self:SetTarget(owner)
	local facetarget = ai_sched_cpt.New("cptbase_bot_faceowner")
	facetarget:EngTask("TASK_FACE_TARGET",0)
	self:StartSchedule(facetarget)
	self:CPT_LookAtPosition(self:CPT_FindCenter(owner),self.DefaultPoseParameters,self.DefaultPoseParamaterSpeed)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Summon_FollowAI()
	local ply = self.TheFollowedPlayer
	if self.IsFollowingAPlayer && IsValid(ply) then
		local dist = self:GetClosestPoint(ply)
		if self:CPT_GetDisp(ply) != D_LI then
			self.IsFollowingAPlayer = false
			self.TheFollowedPlayer = NULL
		end
		if !IsValid(self:GetEnemy()) && dist > self.MinimumFollowDistance && self:CanPerformProcess() then
			if self:MovementType() == MOVETYPE_FLY then
				self:HandleFlying(ply,dist,dist)
			else
				self:ChaseTarget(ply)
			end
		end
		if !IsValid(self:GetEnemy()) then
			if dist <= self.MinimumFollowDistance && ply:Visible(self) then
				if self:IsMoving() then
					self:CPT_StopCompletely()
					self:Summon_FaceOwner(ply)
				end
			end
		-- else
			-- if self:GetEnemy():Visible(self) then
				-- self:SetAngles(Angle(0,(self:GetEnemy():GetPos() -self:GetPos()):Angle().y,0))
			-- end
		end
		self:OnFollowAI(ply,dist)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:UnRagdoll()
	if IsValid(self.CPTBase_Ragdoll) then
		self:CPT_SetClearPos(self.CPTBase_Ragdoll:GetPos())
		self:SetColor(self.CPTBase_Ragdoll:GetColor())
		self.CPTBase_Ragdoll:Remove()
		self:SetNoDraw(false)
		self:DrawShadow(true)
		self.IsRagdolled = false
		self.bInSchedule = false
		self:OnRagdollRecover()
	else
		self:CPT_SetClearPos(self:GetPos())
		self:SetColor(Color(255,255,255,255))
		self:SetNoDraw(false)
		self:DrawShadow(true)
		self.IsRagdolled = false
		self.bInSchedule = false
		self:OnRagdollRecover()
	end
	self:SetRagdolled(false)
	self:SetCollisionGroup(9)
	self:SetPersistent(false)
	-- self:UpdateFriends()
	-- self:UpdateEnemies()
end
---------------------------------------------------------------------------------------------------------------------------------------------
local defPos = Vector(0,0,0)
--
function ENT:Think()
	if self.IsDead == true then return end
	local curTime = CurTime()
	self:NextThink(curTime + (0.069696968793869 + FrameTime()))
	self:SetArrivalSpeed(9999)
	if self:IsMoving() then
		self:SetArrivalActivity(self:GetIdleAnimation())
	end
	if self.Func_Think then
		self:Func_Think()
	end
	if self.IsRagdolled == true then
		local ragdoll = self.CPTBase_Ragdoll
		self:SetPos(self:CPT_FindCenter(ragdoll) -Vector(0,0,self.RagdolledPosSubtraction))
		self:SetAngles(ragdoll:GetAngles())
		self:SetNoDraw(true)
		self:DrawShadow(false)
		self.bInSchedule = true
		if self:GetCPTBaseRagdoll():GetVelocity():Length() > 10 then
			self.LastRagdollMoveT = curTime +self.RagdollRecoveryTime
		end
		if curTime > self.LastRagdollMoveT then
			self:UnRagdoll()
		end
		self:CheckRagdollSettings()
	end
	self:OnThink_Disabled()

	if GetConVar("ai_disabled"):GetInt() == 1 then return end

	local curSched = self.CurrentSchedule
	local isPossessed = self.IsPossessed
	if self.IsPlayingSequence == true then
		self.CurrentSchedule = nil
		self.CurrentTask = nil
	end

	self:IdleSounds()
	self:HandleRelationships()
	if self:IsWalking() then
		self:SetMovementAnimation("Walk")
	elseif self:IsRunning() then
		self:SetMovementAnimation("Run")
	end

	local enemy = self:GetEnemy()

	if self.UsePlayermodelMovement == true then
		local curPos = self:GetCurWaypointPos()
		if !(self.ConstantlyFaceEnemy && IsValid(enemy)) && curPos != defPos then
			self:TurnToPosition(curPos)
		end
		local moveDir = self:GetMoveDirection(true)
		if moveDir != defPos then
			self:SetPoseParameter("move_x",moveDir.x)
			self:SetPoseParameter("move_y",moveDir.y)
		end
	end

	if IsValid(enemy) then
		if !isPossessed then
			local dist = self:CPT_FindCenterDistance(enemy)
			local nearest = self:GetClosestPoint(enemy)
			local disp = self:CPT_GetDisp(enemy)
			local time = self:GetPathTimeToGoal()
			if self.ConstantlyFaceEnemy then
				self:TurnToPosition(enemy:GetPos())
			end
			if self:MovementType() != MOVETYPE_FLY then
				if self.bInSchedule != true then
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
	else
		if self.Faction != false then
			self:HearingCode()
		end
	end
	self:PoseParameters()
	self:SetStatus()
	self:FootStepCode()
	self:OnThink()

	if self.IsSwimType == false then
		if self:CPT_IsFalling(self.FallingHeight) then
			self:SetGroundEntity(NULL)
			self:WhileFalling()
			self.TimeSinceLastTimeFalling = curTime +0.2
		elseif !self:CPT_IsFalling(self.FallingHeight) && self.TimeSinceLastTimeFalling > 0 && self.TimeSinceLastTimeFalling <= curTime then
			self:OnLand()
			self.TimeSinceLastTimeFalling = 0
		end
	elseif self.IsSwimType == true then
		self:SwimAI()
	end

	if !isPossessed then
		self:Summon_FollowAI()
		self:OnThink_NotPossessed()
	else
		self:ControlMovement()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:GetMoveDirection(ignoreZ)
	if !self:IsMoving() then
		return defPos
	end
	local waypoint = self:GetCurWaypointPos()
	local dir = (waypoint -self:GetPos())
	if ignoreZ then
		dir.z = 0
	end

	return (self:GetAngles() -dir:Angle()):Forward()
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnHearSound(ent)
	if self.ReactsToSound == false then return end
	if self.IsPossessed == true then return end
	if !self.CanMove then return end
	if ent:Visible(self) then
		self:SetTarget(ent)
		self:SetSchedule(SCHED_TARGET_FACE)
	elseif !ent:Visible(self) then
		local NoisePos = util.RandomVectorAroundPos(self:CPT_FindCenter(ent),150,true)
		self:SetLastPosition(NoisePos)
		self:TASKFUNC_LASTPOSITION()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:AdvancedHearingCode(ent,vol,pos,dvol)
	if !self.ReactsToSound then return end
	if IsValid(self:GetEnemy()) then return end
	if pos == nil then pos = ent:GetPos() end
	local threshold = (self.HearingDistance *dvol)
	if ent == self then return end
	local baseCheck = true
	if self:GetDistanceToVector(pos,1) <= threshold then
		if self:CPT_GetDisp(ent) != D_LI then
			if ent:IsPlayer() && GetConVarNumber("ai_ignoreplayers") == 1 then return end
			self:OnHearSound(ent)
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:HearingCode()
	if self.ReactsToSound then
		for _,v in pairs(ents.FindInSphere(self:GetPos(),self.HearingDistance)) do
			if v:IsPlayer() && !v.UseNotarget && (v:GetMoveType() == MOVETYPE_WALK or v:GetMoveType() == MOVETYPE_LADDER) && v:GetNW2Bool("CPTBase_IsPossessing") == false && self.FriendlyToPlayers == false && GetConVarNumber("ai_ignoreplayers") == 0 && v.Faction != "FACTION_NOTARGET" && self:CPT_GetFaction() != "FACTION_PLAYER" && self.Faction != v.Faction then
				if (IsValid(self:GetNW2Entity("cpt_SpokenPlayer")) && self:GetNW2Entity("cpt_SpokenPlayer") == v) or (!v:Crouching() && (v:KeyDown(IN_FORWARD) or v:KeyDown(IN_BACK) or v:KeyDown(IN_MOVELEFT) or v:KeyDown(IN_MOVERIGHT) or v:KeyDown(IN_JUMP))) then
					if self:GetDistanceToVector(v:GetPos(),1) <= self.HearingDistance then
						self:OnHearSound(v)
					end
				end
			elseif v:IsNPC() && v != self && !v.UseNotarget && self.Faction != v:CPT_GetFaction() && v.Faction != "FACTION_NONE" && v:IsMoving() && v:CPT_GetDisp(self) != D_LI then
				if self:GetDistanceToVector(v:GetPos(),1) <= self.HearingDistance then
					self:OnHearSound(v)
				end
			end
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
net.Receive("cpt_SpeakingPlayer",function(len,pl)
	v = net.ReadEntity()
	ent = net.ReadEntity()
	v:SetNW2Entity("cpt_SpokenPlayer",ent)
end)
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

	local enemy = self:GetEnemy()
	local ang = self:GetAngles()
	local mins = self:OBBMins()
	local maxs = self:OBBMaxs()
	local function IdleAI()
		if self.Swim_TargetAngle then
			self:ApplyAngles(self.Swim_TargetAngle,self:GetMaxYawSpeed() *5,false)
		end
		if CurTime() > self.Swim_NextRandomDirectionT then
			if math.random(1,2) == 1 then
				if self.Swim_Direction_Pitch == 0 then
					self.Swim_Direction_Pitch = math.random(1,2) == 1 && 1 or -1
					-- self.NextSwimDirection_PitchT = CurTime() +math.Rand(0.35,1)
				end
			else
				if self.Swim_Direction_Yaw == 0 then
					self.Swim_Direction_Yaw = math.random(1,2) == 1 && 1 or -1
					-- self.NextSwimDirection_YawT = CurTime() +math.Rand(0.5,1.5)
				end
			end
			self.Swim_NextRandomDirectionT = CurTime() +math.Rand(4,15)
		end

		if CurTime() > self.NextSwimDirection_PitchT then
			local maxPitch = self.Swim_CheckPitchDistance
			local trace_up = RunHullTrace(self:GetPos() +Vector(0,0,maxPitch),self:GetPos(),{self},mins,maxs,{mask = MASK_WATER})
			local trace_down = RunHullTrace(self:GetPos(),self:GetPos() -Vector(0,0,maxPitch *0.5),{self},mins,maxs)
			local dist_up = self:GetPos():Distance(trace_up.HitPos)
			local dist_down = self:GetPos():Distance(trace_down.HitPos)

			if dist_up < maxPitch then
				self.Swim_Direction_Pitch = 1
				self.NextSwimDirection_PitchT = CurTime() +math.Rand(0.25,1)
				return
			end
			if trace_down.HitWorld then
				self.Swim_Direction_Pitch = -1
				self.NextSwimDirection_PitchT = CurTime() +math.Rand(0.25,1)
			else
				self.Swim_Direction_Pitch = 0
				self.NextSwimDirection_PitchT = CurTime() +math.Rand(1,2)
			end
			-- print("Set pitch value to " .. self.Swim_Direction_Pitch)
		else
			if self.Swim_Direction_Pitch == 0 then
				self.Swim_TargetAngle.p = 0
			else
				self.Swim_TargetAngle.p = math.Clamp(self.Swim_TargetAngle.p +(self.Swim_Direction_Pitch *self:GetMaxYawSpeed()),-42,42)
			end
			-- print(self.Swim_TargetAngle.p)
		end

		if CurTime() > self.NextSwimDirection_YawT then
			local maxYaw = self.Swim_CheckYawDistance
			local trace_forward = RunHullTrace(self:GetPos() +self:GetForward() *maxYaw,self:GetPos(),{self},mins,maxs)
			if trace_forward.HitWorld then
				local trace_left = RunHullTrace(self:GetPos() +self:GetRight() *-maxYaw,self:GetPos(),{self},mins,maxs)
				local trace_right = RunHullTrace(self:GetPos() +self:GetRight() *maxYaw,self:GetPos(),{self},mins,maxs)
				local dist_right = self:GetPos():Distance(trace_right.HitPos)
				local dist_left = self:GetPos():Distance(trace_left.HitPos)

				if dist_right < dist_left then
					self.Swim_Direction_Yaw = -1
				elseif dist_left < dist_right then
					self.Swim_Direction_Yaw = 1
				else
					-- self.Swim_Direction_Yaw = math.random(1,2) == 1 && -1 or 1
					self.Swim_Direction_Yaw = 0
				end
				-- print("Set yaw value to " .. self.Swim_Direction_Yaw)
				self.NextSwimDirection_YawT = CurTime() +math.Rand(1.2,2.6)
				self.Swim_NextRandomDirectionT = CurTime() +math.Rand(3,6)
			end
		else
			self.Swim_TargetAngle.y = self.Swim_TargetAngle.y +(self.Swim_Direction_Yaw *self:GetMaxYawSpeed())
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
	end

	if !IsValid(enemy) then
		IdleAI()
	else
		if enemy:WaterLevel() <= 0 then
			-- self:SetRelationship(enemy,D_NU,self:SetEntityPriority(enemy,D_NU))
			-- IdleAI()
			self:ResetEnemy()
			return
		end
		local enemypos = enemy:GetPos() +enemy:OBBCenter()
		local enemyang = enemy:GetAngles()

		local swimvelocity = self:GetForward() *self.SwimSpeedEnhanced
		if self:WaterLevel() < 3 && swimvelocity.z > 0 then
			swimvelocity.z = 0
		end

		self:ApplyAngles(enemypos,self:GetMaxYawSpeed() *2,false)
		self:SetLocalVelocity(swimvelocity)

		if self.tbl_Animations["Swim"] == nil then
			self:SetIdleAnimation(ACT_SWIM)
		else
			self:SetIdleAnimation(self:SelectFromTable(self.tbl_Animations["Swim"]))
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetSwimSpeed(speed)
	self.SwimSpeed = speed
	self.DefaultSwimSpeed = speed
	self.SwimSpeedEnhanced = self.DefaultSwimSpeed +80
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetFlySpeed(speed)
	self.FlySpeed = speed
	self.DefaultFlySpeed = speed
	self.FlySpeedEnhanced = self.DefaultFlySpeed +80
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetMovementType(move,onspawn)
	local types = {MOVETYPE_STEP,MOVETYPE_NONE,MOVETYPE_FLY,MOVETYPE_SWIM}
	if table_HasValue(types,move) then
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
function ENT:FlyRandom(checkDistForward,checkDistUp,checkDistDown,checkDistLeft,checkDistRight,chanceMove)
	if checkDistForward == nil then checkDistForward = 700 end
	if checkDistUp == nil then checkDistUp = 400 end
	if checkDistDown == nil then checkDistDown = 200 end
	if checkDistLeft == nil then checkDistLeft = 200 end
	if checkDistRight == nil then checkDistRight = 200 end
	if chanceMove == nil then chanceMove = 10 end
	if self:DoCustomTrace(self:GetPos() +self:OBBCenter(),self:GetPos() +self:OBBCenter() +self:GetUp() *-checkDistDown,{self},true).Hit then
		self:SetLocalVelocity(((Vector(0,0,0) +self:GetUp() *1) +self:GetVelocity():GetNormal()) *self:GetFlySpeed())
	end
	if self:DoCustomTrace(self:GetPos() +self:OBBCenter(),self:GetPos() +self:OBBCenter() +self:GetUp() *checkDistUp,{self},true).Hit then
		self:SetLocalVelocity(((Vector(0,0,0) +self:GetUp() *-1) +self:GetVelocity():GetNormal()) *self:GetFlySpeed())
	end
	local vel = self:GetForward() *1
	if !self:DoCustomTrace(self:GetPos() +self:OBBCenter(),self:GetPos() +self:OBBCenter() +self:GetForward() *checkDistForward,{self},true).Hit then
		vel = self:GetForward() *1
		if math.random(1,chanceMove) == 1 then
			local mC = math.random(1,4)
			if mC == 1 then
				self:SetLocalVelocity(((Vector(0,0,0) +self:GetUp() *-1) +self:GetVelocity():GetNormal()) *self:GetFlySpeed())
			elseif mC == 2 then
				//vel = self:GetRight() *1
				self:ApplyAngles(self:GetPos() +self:GetRight() *checkDistRight,self:GetMaxYawSpeed(),false)
				-- self:CPT_TurnToDegree(self:GetMaxYawSpeed(),self:GetPos() +self:GetRight() *checkDistRight,true,42)
			elseif mC == 3 then
				//vel = self:GetRight() *-1
				self:ApplyAngles(self:GetPos() +self:GetRight() *checkDistLeft,self:GetMaxYawSpeed(),false)
				-- self:CPT_TurnToDegree(self:GetMaxYawSpeed(),self:GetPos() +self:GetRight() *checkDistLeft,true,42)
			else
				//vel = self:GetForward() *-1
				self:ApplyAngles(self:GetPos() +self:GetForward() *-checkDistForward,self:GetMaxYawSpeed(),false)
				-- self:CPT_TurnToDegree(self:GetMaxYawSpeed(),self:GetPos() +self:GetForward() *-checkDistForward,true,42)
			end
		end
	elseif self:DoCustomTrace(self:GetPos() +self:OBBCenter(),self:GetPos() +self:OBBCenter() +self:GetForward() *checkDistForward,{self},true).Hit then
		vel = self:GetForward() *1
		if !self:DoCustomTrace(self:GetPos() +self:OBBCenter(),self:GetPos() +self:OBBCenter() +self:GetRight() *checkDistForward,{self},true).Hit then
			-- vel = self:GetRight() *1
			self:ApplyAngles(self:GetPos() +self:GetRight() *checkDistForward,self:GetMaxYawSpeed(),false)
			-- self:CPT_TurnToDegree(self:GetMaxYawSpeed(),self:GetPos() +self:GetRight() *checkDistForward,true,42)
		else
			-- vel = self:GetRight() *-1
			self:ApplyAngles(self:GetPos() +self:GetRight() *-checkDistForward,self:GetMaxYawSpeed(),false)
			-- self:CPT_TurnToDegree(self:GetMaxYawSpeed(),self:GetPos() +self:GetRight() *-checkDistForward,true,42)
		end
	end
	self:SetLocalVelocity(((Vector(0,0,0) +vel) +self:GetVelocity():GetNormal()) *self:GetFlySpeed())
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:FootStepCode()
	if self.IsRagdolled == true then return end
	if self:IsOnGround() && self:IsMoving() && self.UseTimedSteps == true then
		self:PlayFootStepSound()
	end
end
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
	self:StartIdleAnimation()
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:ChaseEnemy(uselastpos,pos) // Only run this if you don't care what it's target is
	if self.IsPossessed then return end
	if self.CanChaseEnemy == false then return end
	if !IsValid(self:GetEnemy()) then return end
	if uselastpos == nil then
		uselastpos = false
	end
	self:ChaseTarget(self:GetEnemy(),uselastpos,pos)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:ChaseTarget(ent,uselastpos,pos)
	if self.bInSchedule == true then return end
	if self.CanChaseEnemy == false then return end
	if self.IsPossessed == true then return end
	if IsValid(ent) then
		self:OnChaseEnemy(ent)
		if self.UseCPTBaseAINavigation then
			self:TASKFUNC_CPTBASENAVIGATE(ent)
		else
			if uselastpos == false then
				self:SetTarget(ent)
				self:TASKFUNC_GETPATHANDGO()
			else
				if pos == nil then
					pos = ent:GetPos()
				end
				self:SetLastPosition(pos)
				self:TASKFUNC_RUNLASTPOSITION()
			end
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:StartIdleAnimation()
	local idleanim = self:GetIdleAnimation()
	if self:IsMoving() then
		self:SetArrivalActivity(idleanim)
	end

	if self:CanPerformProcess() == false or self.bInSchedule or self.IsPlayingSequence == true or self.IsPlayingActivity == true or self:IsMoving() or self:IsJumping() or self:IsClimbing() then return end

	if self.CurrentSchedule == nil && self.CurrentTask == nil then
		if self:GetActivity() != idleanim then
			self:StartEngineTask(GetTaskID("TASK_SET_ACTIVITY"),idleanim)
			self:MaintainActivity()
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetIdleAnimation(act)
	if type(act) == "string" then
		act = self:CPT_TranslateStringToNumber(act)
	end
	self.IdleAnimation = act
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetStatus()
	local enemy = self:GetEnemy()
	if IsValid(enemy) then
		self:SetState(NPC_STATE_COMBAT,true)
	elseif IsValid(enemy) && !enemy:Visible(self) then
		self:SetState(NPC_STATE_ALERT,true)
	elseif table_Count(self.MemoryTable[D_HT]) <= 0 && (self:GetState() == NPC_STATE_ALERT or self:GetState() == NPC_STATE_COMBAT) then
		self:SetState(NPC_STATE_IDLE,true)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:PoseParameters()
	self:CheckPoseParameters()
	if !self.UseDefaultPoseParameters then return end
	local pp = self.DefaultPoseParameters
	local pp_speed = self.DefaultPoseParamaterSpeed
	if self.IsPossessed then
		self:CPT_LookAtPosition(self:PossessorTrace(),self.DefaultPoseParameters,pp_speed,self.ReversePoseParameters)
	else
		if IsValid(self:GetEnemy()) then
			-- self:CPT_LookAtPosition(self:CPT_FindHeadPosition(self:GetEnemy()),{"aim_pitch","aim_yaw","head_pitch","head_yaw"},10)
			self:CPT_LookAtPosition(self:CPT_FindCenter(self:GetEnemy()),pp,pp_speed,self.ReversePoseParameters)
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnCondition(iCondition)
	local cond = self:ConditionName(iCondition)
	-- print(cond)
	// COND_TARGET_OCCLUDED -- Enemy can't be found
	// COND_ENEMY_UNREACHABLE -- Enemy can't be reached
	// COND_TASK_FAILED -- Enemy can't be reached
	if self.bInSchedule == true then return end
	if self.bDead == true then return end
	local state = self:GetState()
	self:CustomOnCondition(cond,state)
	if state == NPC_STATE_DEAD then return end
	-- if state != NPC_STATE_COMBAT then
		-- self:UpdateEnemies()
		if state != NPC_STATE_LOST && IsValid(self:GetEnemy()) then
			if self.HasAlertAnimation == false then
				if CurTime() > self.NextAlertSoundT then
					self:PlayAlertSound()
					if self.CurrentSound != nil then
						self.NextAlertSoundT = CurTime() +SoundDuration(self.CurrentPlayingSound) +math.random(self.AlertSoundChanceA,self.AlertSoundChanceB)
						-- print(self.NextAlertSoundT)
					end
				end
			else
				if math.random(1,self.AlertAnimationChance) == 1 then
					self:PlayAlertSound()
					self:CPT_PlayAnimation("Alert",2)
				end
			end
			-- self:SetState(NPC_STATE_COMBAT)
		end
		-- return
	-- end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetRelationship(entity,relationship,priority,dontLoop)
    priority = priority or 99
    if not self.MemoryTable[relationship][entity] then
        self.MemoryTable[relationship][entity] = {}
        self:OnFoundNewEntity(entity,relationship,priority)
	else
		self.MemoryTable[relationship][entity].ShouldForget = CurTime() +20
		return
	end
    self.MemoryTable[relationship][entity] = {
        Priority = priority,
        SetTime = CurTime(),
        ShouldForget = CurTime() +20,
    }
	self:AddEntityRelationship(entity,relationship,priority)
	if entity.AddEntityRelationship then
		entity:AddEntityRelationship(self,relationship,priority)
		if entity.MemoryTable && !dontLoop then
			entity:SetRelationship(self,relationship,priority,true)
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:HasSharedFaction(ent)
	local myTable = self.Faction
	local targetTable = false
	if ent.VJ_NPC_Class && !ent.Faction then
		myTable = self.VJ_NPC_Class
		targetTable = ent.VJ_NPC_Class
	elseif ent.Faction && istable(ent.Faction) then
		targetTable = ent.Faction
	end

	if targetTable then
		for _,v in pairs(myTable) do
			for _,v2 in pairs(targetTable) do
				if v == v2 then
					return true
				end
			end
		end
	end

	return false
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:ApplyRelationships(ent)
	if self.Faction == false or self.CanSetEnemy == false then
		return
	end

	local function defaultChecks(ent)
		return ((ent:IsNPC() && ent != self) or (ent:IsPlayer() && GetConVar("ai_ignoreplayers"):GetInt() == 0 && !ent.IsPossessing)) && ent:Health() > 0 && !ent:IsFlagSet(FL_NOTARGET) && ((self.IsSwimType && ent:WaterLevel() > 0) or !self.IsSwimType && true)
	end

	if ent then
		if defaultChecks(ent) then
			if self:HasSharedFaction(ent) or (self.FriendlyToPlayers && ent:IsPlayer()) then
				self:SetRelationship(ent,D_LI,self:SetEntityPriority(ent,D_LI))
			else
				self:SetRelationship(ent,D_HT,self:SetEntityPriority(ent,D_HT))
			end
		end
	else
		for _,v in pairs(ents.FindInSphere(self:GetPos(),self.FindEntitiesDistance)) do
			if defaultChecks(v) then
				if self:HasSharedFaction(v) or (self.FriendlyToPlayers && v:IsPlayer()) then
					self:SetRelationship(v,D_LI,self:SetEntityPriority(v,D_LI))
				else
					self:SetRelationship(v,D_HT,self:SetEntityPriority(v,D_HT))
				end
			end
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:ResetEnemy(ent)
	self:RemoveFromMemory(self:GetEnemy())
	self:SetEnemy(NULL)
	self:SetState(NPC_STATE_LOST)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:RemoveFromMemory(ent,optionalDisp)
	if optionalDisp && self.MemoryTable[optionalDisp][ent] then
		self.MemoryTable[optionalDisp][ent] = nil
		self:OnEntityRemovedFromMemory(ent,optionalDisp)
		return true
	end
	local didRemove = false
	if self.MemoryTable[D_LI][ent] then
		self.MemoryTable[D_LI][ent] = nil
		self:OnEntityRemovedFromMemory(ent,D_LI)
		didRemove = true
	end
	if self.MemoryTable[D_HT][ent] then
		self.MemoryTable[D_HT][ent] = nil
		self:OnEntityRemovedFromMemory(ent,D_HT)
		didRemove = true
	end
	if self.MemoryTable[D_NU][ent] then
		self.MemoryTable[D_NU][ent] = nil
		self:OnEntityRemovedFromMemory(ent,D_NU)
		didRemove = true
	end
	if self.MemoryTable[D_FR][ent] then
		self.MemoryTable[D_FR][ent] = nil
		self:OnEntityRemovedFromMemory(ent,D_FR)
		didRemove = true
	end

	return didRemove
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:HandleRelationships()
	if self.Faction == false or self.CanSetEnemy == false then
		return
	end

	self:ApplyRelationships()

	local lastEnemy = self:GetEnemy()
	local closestEnt = nil
	local closestDist = 999999999
	for disp,dispTbl in pairs(self.MemoryTable) do
		for ent,v in pairs(dispTbl) do
			local removed = false
			if !IsValid(ent) or IsValid(ent) && (ent:IsFlagSet(FL_NOTARGET) or ent:Health() <= 0 or (ent:IsPlayer() && ent.IsPossessing)) then
				self.MemoryTable[disp][v] = nil
				removed = true
			end
			if !removed && disp == D_HT then
				if ent:Visible(self) then
					v.ShouldForget = CurTime() +self.LoseEnemiesTime
				end
				if CurTime() > v.ShouldForget then
					if ent == lastEnemy then
						self:ResetEnemy()
					else
						self:RemoveFromMemory(ent)
					end
					self:OnLostEnemy(ent)
					self.MemoryTable[disp][v] = nil
					if #self.MemoryTable[disp] <= 0 then
						self:OnAreaCleared()
					end
					print(#self.MemoryTable[disp])
					return
				end

				local dist = self:CPT_FindDistance(ent)
				if dist <= closestDist && self:Visible(ent) && self:CanSeeEntities(ent) && self:CPT_FindInCone(ent,self.ViewAngle) then
					closestDist = dist
					closestEnt = ent
				end
			end
		end
	end

	if closestEnt then
		self.Enemy = closestEnt
		self:SetEnemy(closestEnt)
		if lastEnemy != closestEnt then
			self:SetCurrentEnemy(closestEnt)
			self:OnEnemyChanged(closestEnt)
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:ClearMemory() -- Update this
	self:SetEnemy(NULL)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CreateBloodEffects(dmg,hitgroup,dmginfo,doignore)
	if table_Count(self.BloodEffect or {}) <= 0 then return end
	if dmg:GetDamagePosition() != Vector(0,0,0) or (self:IsOnFire() && (IsValid(dmg:GetAttacker()) && dmg:GetAttacker():GetClass() != "entityflame") && (DoIgnore == false)) then
		CPT_ParticleEffect(self:SelectFromTable(self.BloodEffect),dmg:GetDamagePosition(),AngleRand(0,360))
	else
		if (self:IsOnFire() && (IsValid(dmg:GetAttacker()) && dmg:GetAttacker():GetClass() == "entityflame")) then return end
		CPT_ParticleEffect(self:SelectFromTable(self.BloodEffect),self:CPT_FindCenter(self),AngleRand(0,360))
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CreateBloodDecals(dmg,dmginfo,hitbox)
	if table_Count(self.BloodDecal or {}) <= 0 then return end
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
function ENT:CallNearbyAllies(range,moveRange)
	local tb = {}
	for _,v in ipairs(ents.FindInSphere(self:GetPos(),range)) do
		if v:IsNPC() && v != self && self:CPT_IsAlly(v) && !IsValid(v:GetEnemy()) then
			if v:Visible(self) then
				if math.random(1,2) == 1 then
					if v.CPTBase_NPC then
						v:CPT_StopCompletely()
						v:SetTarget(self)
						v:TASKFUNC_RUNLASTPOSITION(true)
						v:OnRepondToHelp(self)
					else
						v:SetSchedule(SCHED_FORCED_GO_RUN)
					end
				else
					if v.CPTBase_NPC then
						v:CPT_StopCompletely()
						v:TASKFUNC_FACEPOSITION(self:GetPos())
						v:OnRepondToHelp(self)
					else
						v:SetSchedule(SCHED_FORCED_GO_RUN)
					end
				end
			else
				v:SetLastPosition(self:GetPos() +Vector(math.random(-moveRange,moveRange),math.random(-moveRange,moveRange),0))
				if v.CPTBase_NPC then
					v:CPT_StopCompletely()
					v:SetTarget(self)
					v:TASKFUNC_RUNLASTPOSITION(true)
					v:OnRepondToHelp(self)
				else
					v:SetSchedule(SCHED_FORCED_GO_RUN)
				end
			end
			table_insert(tb,v)
		end
	end
	return tb
end
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.NextPainSoundT = 0
ENT.NextShoutForHelpT = 0
function ENT:OnTakeDamage(dmg,hitgroup,dmginfo)
	local dmginfo = DamageInfo()
	-- local dmginfo = self.tblDamageInfo
	local DoIgnore = false
	local _Damage = dmg:GetDamage()
	local _Attacker = dmg:GetAttacker()
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
	if DoIgnore == false && self.IsDead == false /*&& self.IsRagdolled == false*/ && self.IsEssential == false && self:BeforeTakeDamage(dmg,_Hitbox,dmginfo) then
		local change = self:ChangeDamageOnHit(dmg,_Hitbox,dmginfo)
		-- print(change)
		self:SetHealth(self:Health() -change)
		self.DidGetHit = true
		timer.Simple(0.01,function() if IsValid(self) && self.DidGetHit == true then self.DidGetHit = false end end)
	end
	if DoIgnore == false then
		if self:BeforeTakeDamage(dmg,_Hitbox,dmginfo) == false then
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
			timer.Simple(self.ShoutForHelpTime,function()
				if IsValid(self) then
					local allies = self:CallNearbyAllies(self.ShoutForHelpDistance,200)
					self:OnShoutForHelp(allies)
				end
			end)
			self.NextShoutForHelpT = CurTime() +math.random(7,10)
		end
		if !IsValid(self:GetEnemy()) then
			if self:GetState() == NPC_STATE_IDLE then
				self:SetState(NPC_STATE_ALERT)
			end
			-- print(self:CanPerformProcess(),self.IsPlayingSequence)
			if !self.IsPossessed && self.TurnsOnDamage && self:CanPerformProcess() && DoIgnore != true then
				self:CPT_StopCompletely()
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
	if IsValid(_Inflictor) then 
		if (self.FriendlyToPlayers && _Inflictor:IsPlayer() && self:CPT_GetDisp(_Inflictor) == D_LI) && math.random(1,self.HateFriendlyPlayerThreshold) == 1 then
			self.FriendlyToPlayers = false
			if self.Faction == "FACTION_PLAYER" then
				self.Faction = "FACTION_PLAYER_ENEMY"
			end
			self:SetRelationship(_Inflictor,D_HT)
		end
		if self.IsFollowingAPlayer && self.TheFollowedPlayer == _Inflictor && math.random(1,self.HateFollowedPlayerThreshold) == 1 then
			self.IsFollowingAPlayer = false
			self.TheFollowedPlayer:ChatPrint("This NPC now hates you")
			self:OnUnFollowPlayer(_Inflictor)
			self.TheFollowedPlayer = NULL
			if self.Faction == _Inflictor.Faction then
				self.Faction = _Inflictor.Faction .. "_ENEMY"
			end
			self:SetRelationship(_Inflictor,D_HT)
		end
	end
	if DoIgnore == true then
		return false
	end
	if self:Health() <= 0 && self.IsDead == false then
		local canDie = self:BeforeDoDeath(dmg,dmginfo,_Attacker,_Type,_Pos,_Force,_Inflictor,_Hitbox)
		if canDie then
			self:DoDeath(dmg,dmginfo,_Attacker,_Type,_Pos,_Force,_Inflictor,_Hitbox)
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnDamage_Pain(dmg,dmginfo,hitbox)
	if self.HasFlinchAnimation == true then
		self:DoFlinch(dmg,dmginfo,hitbox)
	else
		if math.random(1,2) == 1 && CurTime() > self.NextPainSoundT then
			self:PlayPainSound()
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
		self:PlayPainSound()
		self:CPT_PlayAnimation("Pain")
		self:OnFlinch(dmg,dmginfo,hitbox)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:DoDeath(dmg,dmginfo,_Attacker,_Type,_Pos,_Force,_Inflictor,_Hitbox)
	gamemode.Call("OnNPCKilled",self,dmg:GetAttacker(),dmg:GetInflictor())
	if dmg:GetAttacker():IsPlayer() then
		dmg:GetAttacker():AddFrags(1)
	end
	self.IsDead = true
	self:PlayDeathSound()
	self:SetNPCState(NPC_STATE_DEAD)
	self:OnDeath(dmg,dmginfo,_Hitbox)
	if self.HasDeathAnimation == true then
		self:SetLocalVelocity(Vector(0,0,0))
		-- self:SetNPCState(NPC_STATE_SCRIPT)
		self:CPT_PlayAnimation("Death")
		local deathtime
		if self.IsPlayingSequence then
			deathtime = self:CPT_AnimationLength(self.CurrentSequence,true)
		else
			deathtime = self:CPT_AnimationLength(self.CurrentAnimation)
		end
		if deathtime == nil then
			deathtime = 0
		end
		timer.Simple(deathtime +self.ExtraDeathTime -0.2,function()
			if IsValid(self) then
				if self.HasDeathRagdoll == true then
					self:CreateNPCRagdoll(dmg,dmginfo)
				end
				self:OnDeathAnimationFinished(dmg,dmginfo,_Hitbox)
				self:WhenRemoved()
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
function ENT:SetRagdollEntity(ent)
	self.RagdollEntity = ent
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
		if self.CPTBase_Ragdoll != nil && self.CPTBase_Ragdoll:IsValid() then
			mdl = self.CPTBase_Ragdoll:GetModel()
			pos = self.CPTBase_Ragdoll:GetPos()
			ang = self.CPTBase_Ragdoll:GetAngles()
			skin = self.CPTBase_Ragdoll:GetSkin()
			rbg = self.CPTBase_Ragdoll:GetColor()
			mat = self.CPTBase_Ragdoll:GetMaterial()
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
		if self.CPTBase_Ragdoll != nil && self.CPTBase_Ragdoll:IsValid() then
			for i = 0,18 do
				ragdoll:SetBodygroup(i,self.CPTBase_Ragdoll:GetBodygroup(i))
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
	for i = 1,ragdoll:GetBoneCount() do
		local phys = ragdoll:GetPhysicsObjectNum(i)
		if IsValid(phys) then
			local pos,ang = self:GetBonePosition(ragdoll:TranslatePhysBoneToBone(i))
			if pos then
				phys:SetPos(pos)
				phys:SetAngles(ang)
				if dmg:IsBulletDamage() then
					phys:SetVelocity(dmgforce /20)
				else
					phys:SetVelocity(dmgforce /37)
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
function ENT:RagdollEnemy(dist,vel,tblents)
	if tblents == nil then
		for _,ent in ipairs(ents.FindInSphere(self:GetPos() +self:GetForward() *1,dist)) do
			if IsValid(ent) && IsValid(self) && self:Visible(ent) then
				if (((ent:IsNPC() && ent != self) or ent:IsPlayer() && ent.CPTBase_HasBeenRagdolled != true) && self:CPT_GetDisp(ent) != D_LI) && self:CPT_FindInCone(ent,self.MeleeAngle) then
					if ent:IsNPC() && ent.CanBeRagdolled != true then return end
					if ent:IsNPC() && ent.IsRagdolled != false then return end
					if ent:Health() <= 0 then return end
					if self:GetClosestPoint(ent) <= dist then
						if self:CheckBeforeRagdollEnemy(ent) then
							if ent:IsNPC() then
								ent:CPT_CreateRagdolledNPC(vel,self)
							else
								ent:CPT_CreateRagdolledPlayer(vel,self)
							end
						end
					end
				end
			end
		end
	else
		for _,ent in ipairs(tblents) do
			if IsValid(ent) && IsValid(self) && self:Visible(ent) then
				if (((ent:IsNPC() && ent != self) or ent:IsPlayer() && ent.CPTBase_HasBeenRagdolled != true) && self:CPT_GetDisp(ent) != D_LI) && self:CPT_FindInCone(ent,self.MeleeAngle) then
					if ent:IsNPC() && ent.CanBeRagdolled != true then return end
					if ent:IsNPC() && ent.IsRagdolled != false then return end
					if ent:Health() <= 0 then return end
					if self:GetClosestPoint(ent) <= dist then
						if self:CheckBeforeRagdollEnemy(ent) then
							if ent:IsNPC() then
								ent:CPT_CreateRagdolledNPC(vel,self)
							else
								ent:CPT_CreateRagdolledPlayer(vel,self)
							end
						end
					end
				end
			end
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnRemove()
	if self.Func_Remove then self:Func_Remove() end -- Don't use this function, it's called from other functions on very special occasions
	if self.CPTBase_Ragdoll != nil && self.CPTBase_Ragdoll:IsValid() then
		self.CPTBase_Ragdoll:Remove()
	end
	self:StopParticles()
	if self.LoopedSounds then
		for _,v in pairs(self.LoopedSounds) do
			if v then
				v:Stop()
			end
		end
	end
	if self.CurrentSound != nil then
		if self.CurrentPlayingSound != nil && (self.tbl_Sounds["Death"] != nil && table_HasValue(self.tbl_Sounds["Death"],self.CurrentPlayingSound)) then
			return
		end
		if self.tbl_Sounds["Death"] && table_HasValue(self.tbl_Sounds["Death"],self.CurrentPlayingSound) then return end
		self.CurrentSound:Stop()
	end
	self:ControlNPC(false,self:GetPossessor(),true)
	self:WhenRemoved()
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
			local finaldmg = AdaptCPTBaseDamage(dmg)
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
		if IsValid(ent) && self:Visible(ent) then
			if self.AllowPropDamage then
				if table_HasValue(self.tbl_AttackablePropNames,ent:GetClass()) then
					table_insert(tblprops,ent)
				end
				self:AttackProps(tblprops,dmg,dmgtype,force,OnHit)
			end
			if ((ent:IsNPC() && ent != self) or (ent:IsPlayer() && ent:Alive())) && (self:GetForward():Dot(((ent:GetPos() +ent:OBBCenter()) -pos):GetNormalized()) > math.cos(math.rad(self.ViewAngle))) then
				if self.CheckDispositionOnAttackEntity && self:CPT_GetDisp(ent) == D_LI then return end
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
						local finaldmg = AdaptCPTBaseDamage(dmg)
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
						table_insert(tblhit,ent)
						if self.CanRagdollEnemies then
							if math.random(1,self.RagdollEnemyChance) == 1 then
								self:RagdollEnemy(dist,self.RagdollEnemyVelocity,tblhit)
							end
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
	self:OnDoDamage(didhit,tblhit,hitpos)
	table.Empty(tblhit)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnHitEntity(hitents,hitpos)
	if self.tbl_Sounds["Strike"] == nil then
		for _,v in ipairs(hitents) do
			if IsValid(v) then v:EmitSound("npc/zombie/claw_strike" .. math.random(1,3) .. ".wav",55,100) end
		end
	else
		for _,v in ipairs(hitents) do
			if IsValid(v) then v:EmitSound(self:SelectFromTable(self.tbl_Sounds["Strike"]),55,100) end
		end
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
			use = self:CPT_FindDistance(self:GetEnemy())
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
			if (ent:IsNPC() && ent != self && self:CPT_GetDisp(ent) != D_LI && ent:GetModel() != self:GetModel()) or (ent:IsPlayer() && ent:Alive()) then
				ent:TakeDamageInfo(dodmg)
				self:OnTraceHit(ent,traceHit)
			end
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:DoRangeAttack_Spawn(ent,pos,force,type)
	local projectile = ents.Create(ent)
	projectile:SetPos(pos)
	projectile:SetOwner(self)
	projectile:Spawn()
	projectile:Activate()
	local phys = projectile:GetPhysicsObject()
	if IsValid(phys) then
		local vel = self:ProjectileForce(pos,force,type)
		phys:ApplyForceCenter(vel)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:ProjectileForce(pos,force,type)
	return self:CalculateProjectileForce(type,self:GetPos(),pos,force +VectorRand() *math.Rand(0,160),self:GetEnemy())
	-- return ((self:GetEnemy():GetPos() +self:GetEnemy():OBBCenter()) -pos +self:GetEnemy():GetVelocity() *0.35):GetNormal() *force +VectorRand() *math.Rand(0,160)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CalculateProjectileForce(type,posA,posB,force,ent) -- Credits/Collaboration to/with DrVrej, Rawch, Arctic, and Dragoteryx
    if type == "normal" then
        if ent then
			return ((posB -posA +ent:GetVelocity() *0.35):GetNormal()) *force
		else
			return ((posB -posA):GetNormal()) *force
		end
    elseif type == "angle" then
        local result = Vector(posB.x -posA.x,posB.y -posA.y,0)
        local pos_x = result:Length()
        local pos_y = posB.z -posA.z
        local grav = physenv.GetGravity():Length()
        local calc1 = (force *force *force *force)
        local calc2 = - grav *(grav *(pos_x *pos_x) +2 *pos_y *(force *force))
        local calcsum = calc1 +calc2
        if calcsum < 0 then
            calcsum = math.abs(calcsum)
        end
        local angsqrt =  math.sqrt(calcsum)
        local angpos = math.atan(((force *force) +angsqrt) /(grav *pos_x))
        local angneg = math.atan(((force *force) -angsqrt) /(grav *pos_x))
        local pitch = 1
        if angpos > angneg then
            pitch = angneg
        else
            pitch = angpos
        end
        result.z = math.tan(pitch) *pos_x
        return result:GetNormal() *force
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
				table_insert(self.tbl_Sounds[tbl],sndfile)
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
function ENT:GetClosestEntity(tbl,argent)
	return self:GetEntitiesByDistance(tbl,argent)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:GetEntitiesByDistance_NEW(tbl,argent)
	local outputTable = {}
	local argent = argent or self
	for i = 1,#tbl do
		if IsValid(tbl[i]) then
			table_insert(outputTable,tbl[i]:GetPos():Distance(argent:GetPos()))
		end
	end
	return table.SortByKey(outputTable,true)[1]
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:GetEntitiesByDistance(tbl,argent)
	local close = {}
	local endtbl = {}
	local result = NULL
	local findent = argent or self
	if !IsValid(findent) then findent = self end
	for _,v in pairs(tbl) do
		if IsValid(v) then
			close[v] = v:GetPos():Distance(findent:GetPos())
		end
	end
	-- print("-------------------------------")
	-- print("I am " .. self:GetClass())
	-- PrintTable(close)
	endtbl = table.SortByKey(close,true)
	result = endtbl[1]
	return result
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:GetClosestNodes(tbl,ent)
	local close = {}
	local endtbl = {}
	local result = NULL
	for _,v in pairs(tbl) do
		if self:GetPos():Distance(v) <= 375 && self:VisibleVec(v) then
			close[v] = self:GetPos():Distance(v)
		else
			if table_HasValue(close,v) then
				table.remove(close,close[v])
			end
		end
		if close[v] != nil && !ent:VisibleVec(v) then
			table.remove(close,close[v])
		end
	end
	endtbl = table.SortByKey(close,true)

	local closeV = {}
	local endtblV = {}
	local resultV = NULL
	for _,v in pairs(endtbl) do
		closeV[v] = ent:GetPos():Distance(v)
	end
	endtblV = table.SortByKey(closeV,true)
	resultV = endtblV[1]
	return resultV
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:FindWanderNodes(tbl)
	local close = {}
	for _,v in ipairs(tbl) do
		if IsValid(v) && self:GetPos():Distance(v) <= 375 then
			table_insert(close,v)
		end
	end
	return close
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
			anim = self:CPT_TranslateStringToNumber(_Animation)
		end
	elseif type(_Animation) == "number" then
		anim = _Animation
	end
	if type(anim) == "string" then
		anim = self:CPT_TranslateStringToNumber(anim)
	end
	if self:GetMovementAnimation() != anim then
		self:SetMovementActivity(anim)
	end

	return anim
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:PlayActivity(activity,facetarget,usetime,addtime,slvbackwardscompatibility)
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
			activity = self:CPT_TranslateStringToNumber(activity)
		end
	end
	if usegesture == true then self:CPT_PlayNPCGesture(string.Replace(activity,"cptges_",""),2,self.GlobalAnimationSpeed) return end
	if usesequence == true then self:CPT_PlaySequence(string.Replace(activity,"cptseq_",""),self.GlobalAnimationSpeed) return end
	if activity == nil then return end
	if self:CPT_AnimationLength(activity) == 0 then return end
	if self:GetMoveType() == MOVETYPE_FLY then fly = true end
	if fly == true then self:CPT_PlayActivity_Fly(activity) return end
	self:CPT_StopProcessing()
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
	if self:GetActivity() == activity then
		self:ResetSequenceInfo()
		self:SetSaveValue("sequence",0)
	end
	-- self:ClearSchedule()
	sched:EngTask(task,activity)
	self:StartSchedule(sched)
	self.CurrentAnimation = activity
	self.IsPlayingActivity = true
	self:MaintainActivity()
	self:OnStartedAnimation(activity)
	self.NextAnimT = CurTime() +self:CPT_AnimationLength(activity)
	timer.Simple(self:CPT_AnimationLength(activity) +extratime,function()
		if IsValid(self) then
			self:SetNPCState(NPC_STATE_NONE)
			self.IsPlayingActivity = false
			self.CanChaseEnemy = true
			self:OnFinishedAnimation(activity)
		end
	end)
	return activity
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:ForceAnimation(act)
	if type(act) == "table" then
		act = PICK(act)
	end
	if type(act) == "string" then
		act = self:GetSequenceActivity(self:LookupSequence(act))
	end
	local sched = ai_sched_cpt.New(act)
	sched:EngTask("TASK_PLAY_SEQUENCE",act)
	self:StartSchedule(sched)
	self:MaintainActivity()
	self.CurrentAnimation = act
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetAIType(ai)
	self.AIType = ai
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:PlaySpawnAnimation(anim,face)
	self:SetNoDraw(true)
	timer.Simple(0,function()
		if IsValid(self) then
			self:SetNoDraw(false)
			self:CPT_PlayAnimation(anim,face)
		end
	end)
end
---------------------------------------------------------------------------------------------------------------------------------------------
// self:SetCurrentAITask(0,{resetai=true,resetanim=true,stopsounds=true})
// self:SetCurrentAITask(800,{pos=Vector(3402,-244,92),aggrodist=400,warndist=500,traveldist=950})
// self:SetCurrentAITask(801,{pos=Vector(3402,-244,92)})
// self:SetCurrentAITask(802,{pos=Vector(3402,-244,92),movetype="Walk"})
// self:SetCurrentAITask(803,{ent=ThePlayer,sentence="SENTENCE_INTRODUCTION",caninterrupt=false})
function ENT:SetCurrentAITask(task,parameters)
	self.CurrentAITask = task
	self.CurrentAITaskParameters = parameters
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:GetCurrentAITask()
	return self.CurrentAITask
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:GetCurrentAITaskParameters()
	return self.CurrentAITaskParameters
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CreateAttackAnimation(callName,anim,facetarget,timestbl,dmgtbl,dmgdisttbl,dmgtypetbl,tempanim)
	self.tbl_CreatedAttacks[callName] = {
		anim=nil,
		facetarget=nil,
		times={},
		dmg={},
		dmgdist={},
		dmgtype={},
		temp=nil
	}
	-- table_insert(self.tbl_CreatedAttacks[callName],{animation = anim,face = facetarget,times = timestbl,dmg = dmgtbl,dmgdist = dmgdisttbl,dmgtype = dmgtypetbl,temp = tempanim})
	self.tbl_CreatedAttacks[callName].animation = anim
	self.tbl_CreatedAttacks[callName].facetarget = facetarget
	self.tbl_CreatedAttacks[callName].times = timestbl
	self.tbl_CreatedAttacks[callName].dmg = dmgtbl
	self.tbl_CreatedAttacks[callName].dmgdist = dmgdisttbl
	self.tbl_CreatedAttacks[callName].dmgtype = dmgtypetbl
	self.tbl_CreatedAttacks[callName].temp = tempanim
	-- PrintTable(self.tbl_CreatedAttacks)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:PlayCreatedAttack(callName)
	local called = self.tbl_CreatedAttacks[callName]
	local anim = called.animation
	local face = called.facetarget
	local dmgTable = {}
	local dmgdistTable = {}
	local dmgtypeTable = {}
	local isTemporary = called.temp
	if string.find(anim,"cptseq_") then
		anim = string.Replace(anim,"cptseq_","")
		if face == nil then face = 1 end
		self:CPT_PlaySequence(anim,face)
	else
		self:PlayActivity(anim,face)
	end
	for k,v in pairs(called.dmg) do
		table_insert(dmgTable,v)
	end
	for k,v in pairs(called.dmgtype) do
		table_insert(dmgtypeTable,v)
	end
	for k,v in pairs(called.dmgdist) do
		table_insert(dmgdistTable,v)
	end
	for k,v in pairs(called.times) do
		timer.Simple(v,function()
			if IsValid(self) && self:CPT_GetCurrentAnimation() == anim then
				self:DoDamage(dmgdistTable[k],dmgTable[k],dmgtypeTable[k])
				-- print(anim,v,dmgdistTable[k],dmgTable[k],dmgtypeTable[k])
			end
		end)
	end
	if isTemporary then
		table.remove(self.tbl_CreatedAttacks,called)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CreateLoopedSound(loopEntity,loopName,loopSound,loopVolume,loopDurationName,loopDuration)
	loopName = CreateSound(self,loopSound)
	loopName:SetSoundLevel(loopVolume)
	if string.find(loopSound,".wav") then
		loopDuration = SoundDuration(loopSound)
	end
	function loopEntity:Func_Think()
		if CurTime() > loopDurationName then
			loopName:Stop()
			loopName:Play()
			loopDurationName = CurTime() +loopDuration
		end
	end
	function loopEntity:Func_Remove()
		loopName:Stop()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CreateSoundName(callName,snd)
	-- if self.tbl_Sentences[callName] != nil then
		-- MsgN("Could not create sentence [" .. callName .. "] = {" .. snd .. "}, already exists!")
		-- return
	-- end
	self.tbl_Sentences[callName] = {snd}
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:PlaySoundName(callName,sndVolume,sndPitch)
	if self.tbl_Sentences[callName] != nil then
		if self.CurrentSound then self.CurrentSound:Stop() end
		local snd = self.tbl_Sentences[callName][1]
		self.CurrentSound = CreateSound(self,snd)
		self.CurrentSound:SetSoundLevel(sndVolume)
		self.CurrentSound:Play()
		self.CurrentSound:ChangePitch(sndPitch *GetConVarNumber("host_timescale"),0)
		self.CurrentPlayingSound = snd
		timer.Simple(SoundDuration(snd),function()
			if IsValid(self) && self.CurrentPlayingSound == snd then
				self.CurrentSound = nil
				self.CurrentPlayingSound = nil
			end
		end)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:GetSoundVolume(CSound)
	return CSound:GetVolume()
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:PlayIdleSound()
	-- if self.tbl_Sentences["Idle"] == nil then
		self:CPT_PlaySound("Idle",self.IdleSoundVolume,90,self.IdleSoundPitch)
		self:DoPlaySound("Idle")
	-- else
	-- 	self:CPT_PlayNPCSentence("Idle")
	-- end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:PlayAlertSound()
	-- if self.tbl_Sentences["Alert"] == nil then
		self:CPT_PlaySound("Alert",self.AlertSoundVolume,90,self.AlertSoundPitch)
		self:DoPlaySound("Alert")
	-- else
		-- self:CPT_PlayNPCSentence("Alert")
	-- end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:PlayPainSound()
	-- if self.tbl_Sentences["Pain"] == nil then
		self:CPT_PlaySound("Pain",self.PainSoundVolume,90,self.PainSoundPitch)
		self:DoPlaySound("Pain")
	-- else
		-- self:CPT_PlayNPCSentence("Pain")
	-- end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:PlayDeathSound()
	-- if self.tbl_Sentences["Death"] == nil then
		self:CPT_PlaySound("Death",self.DeathSoundVolume,90,self.DeathSoundPitch)
		self:DoPlaySound("Death")
	-- else
		-- self:CPT_PlayNPCSentence("Death")
	-- end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:PlayFootStepSound(ev)
	if (table_HasValue(self.tbl_Animations["Walk"],self:GetMovementAnimation()) or self.OverrideWalkAnimation == self:GetMovementAnimation()) && CurTime() > (ev && 0 or self.NextFootSoundT_Walk) then
		self:CPT_PlaySound("FootStep",self.WalkSoundVolume,90,self.StepSoundPitch,true)
		self:DoPlaySound("FootStep")
		self:OnStep("Walk")
		self.NextFootSoundT_Walk = CurTime() + self.NextFootSound_Walk
	end
	if (table_HasValue(self.tbl_Animations["Run"],self:GetMovementAnimation()) or self.OverrideRunAnimation == self:GetMovementAnimation()) && CurTime() > (ev && 0 or self.NextFootSoundT_Run) then
		self:CPT_PlaySound("FootStep",self.RunSoundVolume,90,self.StepSoundPitch,true)
		self:DoPlaySound("FootStep")
		self:OnStep("Run")
		self.NextFootSoundT_Run = CurTime() + self.NextFootSound_Run
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:FaceEnemy()
	if !IsValid(self:GetEnemy()) then return end
	self:SetTarget(self:GetEnemy())
	local _faceenemy = ai_sched_cpt.New("_faceenemy")
	_faceenemy:EngTask("TASK_FACE_TARGET",0)
	self:StartSchedule(_faceenemy)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:FaceTarget(ent)
	self:SetTarget(ent)
	local _faceselectedtarget = ai_sched_cpt.New("_faceselectedtarget")
	_faceselectedtarget:EngTask("TASK_FACE_TARGET",0)
	self:StartSchedule(_faceselectedtarget)
end