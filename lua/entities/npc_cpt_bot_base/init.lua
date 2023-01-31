if !CPTBase then return end
AddCSLuaFile('shared.lua')
include('shared.lua')

ENT.UseDefaultWeaponThink = true
-- ENT.CanSeeAllEnemies = true
ENT.TurnsOnDamage = false
ENT.UsePlayermodelMovement = true
ENT.CanUseTaunts = false
ENT.CanUseChat = true
ENT.CanJump = true
ENT.HasFallingAnimation = true
ENT.CanFollowPlayer = false
ENT.ConstantlyFaceEnemy = true

ENT.Faction = "FACTION_BOT"
ENT.Team = "Team1"
ENT.ShootCone = 70
ENT.FallingHeight = 22

ENT.LeavesBlood = true -- Don't need to set this to false if the table below is empty, it'll just not make decals
ENT.BloodDecal = {"Blood"}

ENT.UseTimedSteps = true
ENT.NextFootSound_Walk = 0.4
ENT.NextFootSound_Run = 0.3

ENT.tbl_Animations = {["Walk"] = {ACT_WALK},["Run"] = {ACT_RUN}}

ENT.tbl_ChatIdle = {}

ENT.tbl_ChatCombat = {}

ENT.tbl_Names = {}

ENT.tbl_Weapons = {}

ENT.tbl_Capabilities = {CAP_ANIMATEDFACE,CAP_USE,CAP_OPEN_DOORS,CAP_MOVE_JUMP}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnStartTask(schedule)
	
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetInit()
	self:SetHullType(HULL_HUMAN)
	self:SetCollisionBounds(Vector(14,14,77), Vector(-14,-14,0))
	if self.BeforeBotCreated then self:BeforeBotCreated() end
	self:SpawnBotWeapon()
	self.ReloadingWeapon = false
	self.IsFollowingPlayer = false
	self.FollowingPlayer = NULL
	self.MinFollowDistance = 0
	self.NextUseT = 0
	self.CanUseJump = true
	self.NextTauntT = CurTime() +math.Rand(3,10)
	self.NextChatT = CurTime() +math.Rand(3,10)
	self.IsUsingChat = false
	self.FakeName = self:SelectFromTable(self.tbl_Names)
	self.IsMovingAround = false
	self.NextMoveAroundT = 0
	if self.OnBotCreated then self:OnBotCreated() end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SpawnBotWeapon()
	local swep = self:SelectFromTable(self.tbl_Weapons)
	self:CPT_GiveNPCWeapon(swep)
	if IsValid(self:GetActiveWeapon()) then
		local wep = self:GetActiveWeapon()
		local ht = self:GetActiveWeapon().DefaultHoldType
		self:SetupHoldtypes(wep,ht)
		if ht == "dual" then
			self.EliteB = ents.Create("prop_dynamic")
			self.EliteB:SetModel(wep.SecondWeapon)
			self.EliteB:SetLocalPos(self:GetPos())
			self.EliteB:SetOwner(self)
			self.EliteB:SetParent(self)
			self.EliteB:Fire("SetParentAttachment","anim_attachment_LH")
			self.EliteB:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
			self.EliteB:Spawn()
			self.EliteB:Activate()
			self.EliteB:SetSolid(SOLID_NONE)
			self.EliteB:SetRenderMode(RENDERMODE_TRANSALPHA)
			self.EliteB:DeleteOnRemove(self)
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:FaceOwner(owner)
	self:SetTarget(owner)
	local facetarget = ai_sched_cpt.New("cptbase_bot_faceowner")
	facetarget:EngTask("TASK_FACE_TARGET",0)
	self:StartSchedule(facetarget)
	self:CPT_LookAtPosition(self:CPT_FindCenter(owner),self.DefaultPoseParameters,self.DefaultPoseParamaterSpeed)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:FollowAI()
	if self.IsFollowingPlayer && self.FollowingPlayer != NULL then
		local dist = self:GetClosestPoint(self.FollowingPlayer)
		if self:Disposition(self.FollowingPlayer) != D_LI then
			self.IsFollowingPlayer = false
			self.FollowingPlayer = NULL
		end
		if dist > self.MinFollowDistance && self:CanPerformProcess() then
			self:ChaseTarget(self.FollowingPlayer)
		end
		if !IsValid(self:GetEnemy()) then
			if dist <= self.MinFollowDistance && self.FollowingPlayer:Visible(self) then
				self:CPT_StopCompletely()
				self:FaceOwner(self.FollowingPlayer)
			end
		else
			if self:GetEnemy():Visible(self) then
				self:SetAngles(Angle(0,(self:GetEnemy():GetPos() -self:GetPos()):Angle().y,0))
			end
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnInputAccepted(event,activator)
	if self.CanFollowPlayer && CurTime() > self.NextUseT && self.FriendlyToPlayers then
		if event == "Use" && activator:IsPlayer() && activator:Alive() && GetConVarNumber("ai_ignoreplayers") == 0 then
			if self.FollowingPlayer == NULL then
				self.IsFollowingPlayer = true
				self.FollowingPlayer = activator
				if self.FakeName then
					activator:ChatPrint(self.FakeName .. " will now follow you.")
				else
					activator:ChatPrint("This bot will now follow you.")
				end
				self.MinFollowDistance = math.random(120,150)
				self.CanWander = false
			elseif self.FollowingPlayer != NULL && activator == self.FollowingPlayer then
				self.IsFollowingPlayer = false
				self.FollowingPlayer = NULL
				if self.FakeName then
					activator:ChatPrint(self.FakeName .. " will no longer follow you.")
				else
					activator:ChatPrint("This bot will no longer follow you.")
				end
				self.CanWander = true
			end
		end
		self.NextUseT = CurTime() +0.5
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetupHoldtypes(wep,ht)
	if ht == "ar2" then
		wep:SetNPCIdleAnimation(ACT_HL2MP_IDLE_AR2)
		wep:SetNPCWalkAnimation(ACT_HL2MP_WALK_AR2)
		wep:SetNPCRunAnimation(ACT_HL2MP_RUN_AR2)
		wep:SetNPCFireAnimation("range_ar2")
		wep:SetNPCReloadAnimation("reload_ar2")
		self.JumpAnimation = ACT_HL2MP_JUMP_AR2
		self.JumpSequence = "jump_ar2"
	elseif ht == "smg" then
		wep:SetNPCIdleAnimation(ACT_HL2MP_IDLE_SMG1)
		wep:SetNPCWalkAnimation(ACT_HL2MP_WALK_SMG1)
		wep:SetNPCRunAnimation(ACT_HL2MP_RUN_SMG1)
		wep:SetNPCFireAnimation("range_smg1")
		wep:SetNPCReloadAnimation("reload_smg1")
		self.JumpAnimation = ACT_HL2MP_JUMP_SMG1
		self.JumpSequence = "jump_smg1"
	elseif ht == "shotgun" then
		wep:SetNPCIdleAnimation(ACT_HL2MP_IDLE_SHOTGUN)
		wep:SetNPCWalkAnimation(ACT_HL2MP_WALK_SHOTGUN)
		wep:SetNPCRunAnimation(ACT_HL2MP_RUN_SHOTGUN)
		wep:SetNPCFireAnimation("range_shotgun")
		wep:SetNPCReloadAnimation("reload_shotgun")
		self.JumpAnimation = ACT_HL2MP_JUMP_SHOTGUN
		self.JumpSequence = "jump_shotgun"
	elseif ht == "rpg" then
		wep:SetNPCIdleAnimation(ACT_HL2MP_IDLE_RPG)
		wep:SetNPCWalkAnimation(ACT_HL2MP_WALK_RPG)
		wep:SetNPCRunAnimation(ACT_HL2MP_RUN_RPG)
		wep:SetNPCFireAnimation("range_rpg")
		wep:SetNPCReloadAnimation("reload_ar2")
		self.JumpAnimation = ACT_HL2MP_JUMP_RPG
		self.JumpSequence = "jump_rpg"
	elseif ht == "knife" then
		wep:SetNPCIdleAnimation(ACT_HL2MP_IDLE_KNIFE)
		wep:SetNPCWalkAnimation(ACT_HL2MP_WALK_KNIFE)
		wep:SetNPCRunAnimation(ACT_HL2MP_RUN_KNIFE)
		wep:SetNPCFireAnimation("range_knife")
		self.JumpAnimation = ACT_HL2MP_JUMP_KNIFE
		self.JumpSequence = "jump_knife"
	elseif ht == "melee" then
		wep:SetNPCIdleAnimation(ACT_HL2MP_IDLE_MELEE)
		wep:SetNPCWalkAnimation(ACT_HL2MP_WALK_MELEE)
		wep:SetNPCRunAnimation(ACT_HL2MP_RUN_MELEE)
		wep:SetNPCFireAnimation("range_melee")
		self.JumpAnimation = ACT_HL2MP_JUMP_MELEE
		self.JumpSequence = "jump_melee"
	elseif ht == "melee2" then
		wep:SetNPCIdleAnimation(ACT_HL2MP_IDLE_MELEE2)
		wep:SetNPCWalkAnimation(ACT_HL2MP_WALK_MELEE2)
		wep:SetNPCRunAnimation(ACT_HL2MP_RUN_MELEE2)
		wep:SetNPCFireAnimation("range_melee2_b")
		self.JumpAnimation = ACT_HL2MP_JUMP_MELEE2
		self.JumpSequence = "jump_melee2"
	elseif ht == "grenade" then
		wep:SetNPCIdleAnimation(ACT_HL2MP_IDLE_GRENADE)
		wep:SetNPCWalkAnimation(ACT_HL2MP_WALK_GRENADE)
		wep:SetNPCRunAnimation(ACT_HL2MP_RUN_GRENADE)
		wep:SetNPCFireAnimation("range_grenade")
		self.JumpAnimation = ACT_HL2MP_JUMP_GRENADE
		self.JumpSequence = "jump_grenade"
	elseif ht == "pistol" then
		wep:SetNPCIdleAnimation(ACT_HL2MP_IDLE_PISTOL)
		wep:SetNPCWalkAnimation(ACT_HL2MP_WALK_PISTOL)
		wep:SetNPCRunAnimation(ACT_HL2MP_RUN_PISTOL)
		wep:SetNPCFireAnimation("range_pistol")
		wep:SetNPCReloadAnimation("reload_pistol")
		self.JumpAnimation = ACT_HL2MP_JUMP_PISTOL
		self.JumpSequence = "jump_pistol"
	elseif ht == "revolver" then
		wep:SetNPCIdleAnimation("idle_revolver")
		wep:SetNPCWalkAnimation("walk_revolver")
		wep:SetNPCRunAnimation("run_revolver")
		wep:SetNPCFireAnimation("range_revolver")
		wep:SetNPCReloadAnimation("reload_pistol")
		self.JumpAnimation = ACT_HL2MP_JUMP_PISTOL
		self.JumpSequence = "jump_pistol"
	elseif ht == "crossbow" then
		wep:SetNPCIdleAnimation(ACT_HL2MP_IDLE_CROSSBOW)
		wep:SetNPCWalkAnimation(ACT_HL2MP_WALK_CROSSBOW)
		wep:SetNPCRunAnimation(ACT_HL2MP_RUN_CROSSBOW)
		wep:SetNPCFireAnimation("range_ar2")
		wep:SetNPCReloadAnimation("reload_ar2")
		self.JumpAnimation = ACT_HL2MP_JUMP_CROSSBOW
		self.JumpSequence = "jump_crossbow"
	elseif ht == "dual" then
		wep:SetNPCIdleAnimation("idle_dual")
		wep:SetNPCWalkAnimation("walk_dual")
		wep:SetNPCRunAnimation("run_dual")
		wep:SetNPCFireAnimation("range_dual_r")
		wep:SetNPCReloadAnimation("reload_dual")
		self.JumpAnimation = ACT_HL2MP_JUMP_SLAM
		self.JumpSequence = "jump_dual"
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:WhileFalling()
	if !self.CanJump then return end
	self:StartEngineTask(GetTaskID("TASK_SET_ACTIVITY"),self.JumpAnimation)
	self:MaintainActivity()
	self.CanUseJump = false
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnLand()
	if !self.CanJump then return end
	self:EmitSound(Sound("npc/footsteps/hardboot_generic1.wav"),75,100)
	self:EmitSound(Sound("npc/footsteps/hardboot_generic1.wav"),75,100)
	self:StartEngineTask(GetTaskID("TASK_RESET_ACTIVITY"),ACT_IDLE)
	self.CanUseJump = true
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnFoundEnemy(count,oldcount,ent)
	if self:Visible(ent) then
		self:CPT_PlaySound("Spot",80)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnKilledEnemy(ent)
	self:CPT_PlaySound("KilledEnemy",80)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnHearSound(ent)
	if self.ReactsToSound == false then return end
	if self.IsPossessed == true then return end
	local NoisePos = util.RandomVectorAroundPos(self:CPT_FindCenter(ent),150,true)
	self:SetLastPosition(NoisePos)
	self:TASKFUNC_LASTPOSITION()
	self:CPT_PlaySound("Hear",80)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:NPCPLY_Chat()
	if GetConVar("cpt_bot_chat"):GetInt() == 0 then return end
	if !self.CanUseChat then return end
	self.IsUsingChat = true
	if IsValid(self:GetEnemy()) then
		timer.Simple(3,function()
			if IsValid(self) then
				self.IsUsingChat = false
				if self.Team != "No Team" then
					self:PlayerChat(self.FakeName .. " (" .. self.Team .. "): " .. self:SelectFromTable(self.tbl_ChatIdle))
				else
					self:PlayerChat(self.FakeName .. ": " .. self:SelectFromTable(self.tbl_ChatIdle))
				end
				-- if CLIENT then
					-- chat.AddText(Color(0,255,0),self.FakeName .. " (" .. self.Team .. "): " .. self:SelectFromTable(self.tbl_ChatIdle))
				-- end
				-- self:CPT_PlayNPCGesture("gesture_voicechat",2,1)
			end
		end)
	else
		timer.Simple(3,function()
			if IsValid(self) then
				self.IsUsingChat = false
				if self.Team != "No Team" then
					self:PlayerChat(self.FakeName .. " (" .. self.Team .. "): " .. self:SelectFromTable(self.tbl_ChatCombat))
				else
					self:PlayerChat(self.FakeName .. ": " .. self:SelectFromTable(self.tbl_ChatCombat))
				end
				-- if CLIENT then
					-- chat.AddText(Color(0,255,0),self.FakeName .. " (" .. self.Team .. "): " .. self:SelectFromTable(self.tbl_ChatCombat))
				-- end
				-- self:CPT_PlayNPCGesture("gesture_voicechat",2,1)
			end
		end)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:PlayTaunt(override)
	if override != true && self.IsPossessed then return end
	local tbl = {
		[1] = {anim="taunt_cheer",snd="common/null.wav"},
		[2] = {anim="taunt_dance",snd="vo/npc/male01/likethat.wav"},
		[3] = {anim="taunt_laugh",snd="vo/citadel/br_laugh01.wav"},
		[4] = {anim="taunt_muscle",snd="vo/npc/male01/yeah02.wav"},
		[5] = {anim="taunt_persistence",snd="common/null.wav"},
		[6] = {anim="taunt_robot",snd="common/null.wav"},
	}
	local selected = self:SelectFromTable(tbl)
	self:CPT_PlaySequence(selected.anim,1)
	self:EmitSound(Sound(selected.snd),75,100)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:BotThink() end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThink()
	-- if self.IsPossessed then
	-- 	self:SetAngles(Angle(0,(self:Possess_AimTarget() -self:GetPos()):Angle().y,0))
	-- end
	if IsValid(self:GetActiveWeapon()) then
		if self.IsMovingAround then
			if !self.IsPossessed && IsValid(self:GetEnemy()) then
				self:SetAngles(Angle(0,(self:GetEnemy():GetPos() -self:GetPos()):Angle().y,0))
			end
		end
	end
	if !self.IsPossessed then
		self:FollowAI()
	end
	if self.CanUseTaunts && !IsValid(self:GetEnemy()) && CurTime() > self.NextTauntT && math.random(1,80) == 1 then
		self:PlayTaunt()
		self.NextTauntT = CurTime() +math.Rand(15,30)
	end
	if CurTime() > self.NextChatT then
		self:NPCPLY_Chat()
		self.NextChatT = CurTime() +math.Rand(5,50)
	end
	self:BotThink()
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:FootStepCode()
	if self.IsRagdolled == true then return end
	local xpp = "move_x"
	local ypp = "move_y"
	local x = self:GetPoseParameter(xpp)
	local y = self:GetPoseParameter(ypp)
	if self:IsOnGround() && self:IsMoving() && self.UseTimedSteps == true then
		if (x != 0 || y != 0) && (table.HasValue(self.tbl_Animations["Walk"],self:GetMovementAnimation()) || self.OverrideWalkAnimation == self:GetMovementAnimation()) && CurTime() > self.NextFootSoundT_Walk then
			self:CPT_PlaySound("FootStep",self.WalkSoundVolume,90,self.StepSoundPitch,true)
			self:DoPlaySound("FootStep")
			self:OnStep("Walk")
			self.NextFootSoundT_Walk = CurTime() + self.NextFootSound_Walk
		end
		if (x != 0 || y != 0) && (table.HasValue(self.tbl_Animations["Run"],self:GetMovementAnimation()) || self.OverrideRunAnimation == self:GetMovementAnimation()) && CurTime() > self.NextFootSoundT_Run then
			self:CPT_PlaySound("FootStep",self.RunSoundVolume,90,self.StepSoundPitch,true)
			self:DoPlaySound("FootStep")
			self:OnStep("Run")
			self.NextFootSoundT_Run = CurTime() + self.NextFootSound_Run
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:MoveAway(force)
	if self.IsPossessed then return end
	local trypos
	local trynum
	if self.IsMovingAround == false && CurTime() > self.NextMoveAroundT then
		if force == true then
			trynum = 1
		else
			trynum = math.random(1,3)
			if self.CurrentSchedule != nil && self.CurrentSchedule.Name == "getpathandchasetask" then return end
		end
		if trynum == 1 then trypos = self:GetForward() *-400 elseif trynum == 2 then trypos = self:GetRight() *-400 elseif trynum == 3 then trypos = self:GetRight() *400 end
		if !self:DoCustomTrace(self:GetPos() +self:OBBCenter(),self:GetPos() +self:OBBCenter() +trypos,{self},true).Hit then
			self:SetLastPosition(self:GetPos() +trypos)
			self:TASKFUNC_RUNLASTPOSITION()
			self.IsMovingAround = true
			self.NextMoveAroundT = CurTime() +2
			timer.Simple(2,function()
				if IsValid(self) then
					self.IsMovingAround = false
				end
			end)
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnDamage_Pain(dmg,dmginfo,hitbox)
	self:MoveAway(false)
	if hitbox == 1 then
		self:CPT_PlayNPCGesture("flinch_head_0" .. math.random(1,2),2,1)
	elseif (hitbox == 2 || hitbox == 3) then
		self:CPT_PlayNPCGesture("flinch_stomach_0" .. math.random(1,2),2,1)
	elseif hitbox == 4 then
		self:CPT_PlayNPCGesture("flinch_shoulder_l",2,1)
	elseif hitbox == 5 then
		self:CPT_PlayNPCGesture("flinch_shoulder_r",2,1)
	end
	if self.CanUseJump == true && math.random(1,4) == 1 then
		if self.IsPossessed then return end
		if !self.CanJump then return end
		self:JumpRandomly()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnJump() end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:JumpRandomly()
	if !self.CanUseJump then return end
	if !self.CanJump then return end
	if self.CanJumpAround == false then return end
	self:SetGroundEntity(NULL)
	self:OnJump()
	self:CPT_PlaySequence(self.JumpSequence,3)
	self:SetLocalVelocity(Vector(math.Rand(-150,150),math.Rand(-150,150),270))
	self:EmitSound(Sound("npc/footsteps/hardboot_generic1.wav"),75,100)
	self:EmitSound(Sound("npc/footsteps/hardboot_generic1.wav"),75,100)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Possess_Primary(possessor)
	if IsValid(self:GetActiveWeapon()) then
		if self.ReloadingWeapon == false then
			self:GetActiveWeapon():CanFire(true)
		else
			self:GetActiveWeapon():CanFire(false)
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Possess_Jump(possessor)
	if self.CanJumpAround == false then return end
	if self.CanUseJump == false then return end
	self:SetGroundEntity(NULL)
	self:CPT_PlaySequence(self.JumpSequence,3)
	self:SetLocalVelocity(Vector(math.Rand(-150,150),math.Rand(-150,150),270))
	self:EmitSound(Sound("npc/footsteps/hardboot_generic1.wav"),75,100)
	self:EmitSound(Sound("npc/footsteps/hardboot_generic1.wav"),75,100)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:DoWeaponTrace()
	if !IsValid(self:GetActiveWeapon()) then return end
	local wep = self:GetActiveWeapon()
	if (wep.DefaultHoldType == "knife" || wep.DefaultHoldType == "fist" || wep.DefaultHoldType == "melee" || wep.DefaultHoldType == "melee2") then return true end
	local at
	if wep:GetAttachment(1) == nil then
		at = wep:GetPos()
	else
		at = wep:GetAttachment(1).Pos
	end
	local tracedata = {}
	tracedata.start = at
	tracedata.endpos = self:GetEnemy():GetPos() -- For whatever reason, this allows them to shoot small enemies :/
	-- tracedata.endpos = self:GetEnemy():GetPos() +self:GetEnemy():OBBCenter()
	tracedata.filter = {self}
	local tr = util.TraceLine(tracedata)
	return tr.Hit
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:HandleSchedules(enemy,nearest,nearest,disp)
	if self.IsPossessed == true then return end
	if(disp == D_HT) then
		if IsValid(self:GetActiveWeapon()) then
			local wep = self:GetActiveWeapon()
			-- print(self:DoWeaponTrace())
			if nearest > wep.NPC_EnemyFarDistance then
				if !self.IsFollowingPlayer && self:CanPerformProcess() then
					self:ChaseEnemy()
				end
			end
			if !!self.IsFollowingPlayer && self.CanUseJump == true && math.random(1,70) == 1 && enemy:Visible(self) then
				self:JumpRandomly()
			end
			if nearest <= wep.NPC_FireDistance then
				if self.ReloadingWeapon == false && enemy:Visible(self) && self:DoWeaponTrace() /*&& self:CPT_FindInCone(enemy,self.ShootCone)*/ then
					wep:CanFire(true)
					if math.random(1,math.random(12,25)) == 1 then
						self:MoveAway(false)
					end
				elseif !self:CPT_FindInCone(enemy,self.ShootCone) && !self.IsFollowingPlayer && enemy:Visible(self) && !self.IsMovingAround then
					self:FaceEnemy()
					if self:IsMoving() then self:CPT_StopCompletely() end
				elseif !enemy:Visible(self) && !self.IsFollowingPlayer then
					wep:CanFire(false)
					self:ChaseEnemy()
				end
				if nearest <= wep.NPC_FireDistanceStop && !self.IsFollowingPlayer && !self.IsMovingAround then
					self:SetAngles(Angle(0,(enemy:GetPos() -self:GetPos()):Angle().y,0))
					if nearest <= wep.NPC_FireDistanceMoveAway then
						self:MoveAway(false)
					end
				end
			elseif enemy:Visible(self) && !self.IsFollowingPlayer && !self.IsMovingAround then
				wep:CanFire(false)
				self:ChaseEnemy()
			else
				wep:CanFire(false)
			end
		end
	elseif(disp == D_FR) then
		self:Hide()
	end
end