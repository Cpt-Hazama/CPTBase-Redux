if !CPTBase then return end
-------------------------------------------------------------------------------------------------------------------
local ENT_Meta = FindMetaTable("Entity")
local NPC_Meta = FindMetaTable("NPC")
local PLY_Meta = FindMetaTable("Player")
local WPN_Meta = FindMetaTable("Weapon")
local NBT_Meta = FindMetaTable("NextBot")
local PHYS_Meta = FindMetaTable("PhysObj")

local table_insert = table.insert
local table_remove = table.remove
local string_find = string.find

if (SERVER) then
	NPC_STATE_LOST = 8

	MOVETYPE_SWIM = 12

	DMG_FROST = 10
	DMG_RAD = 11
	DMG_POI = 12
	DMG_AFTERBURN = 13
	DMG_DARKENERGY = 14
	DMG_ELEC = 15

	AITYPE_NUETRAL = 1
	AITYPE_NORMAL = 2
	AITYPE_AGGRESSIVE = 3

	TASK_NONE = 0
	TASK_IDLE_GUARD = 800
	TASK_PATROL_TO_POSIITON = 801
	TASK_MOVE_TO_POSITION = 802
	TASK_SPEAK_TO_ENTITY = 803

	util.AddNetworkString("cpt_ControllerView")
	util.AddNetworkString("cpt_SpriteEvent")
	util.AddNetworkString("cpt_SpriteEnd")

	net.Receive("cpt_SpriteEvent", function(len, ply)
		local ent = net.ReadEntity()
		local event = net.ReadString()
		if IsValid(ent) && ent.AcceptInput then
			ent:AcceptInput(event,self,self)
		end
	end)

	net.Receive("cpt_SpriteEnd", function(len, ply)
		local ent = net.ReadEntity()
		local parentName = net.ReadString()
		local seqName = net.ReadString()
		local dir = net.ReadString()

		if IsValid(ent) && ent.OnSpriteAnimEnd then
			ent:OnSpriteAnimEnd(parentName,seqName,dir)
		end
	end)

	function CPT_ParticleEffect(particle,pos,ang,parent)
		if isnumber(parent) then
			ParticleEffectAttach(particle,parent,pos,ang) -- Particle, PATTACH, entity, attachmentID
			return
		end

		if isbool(parent) then
			parent = nil
		end
		ParticleEffect(particle,pos,ang,parent)
	end
end

function HasValue(tbl, val)
	for k, v in pairs(tbl) do
		if (v == val) then
			return true
		end
	end
	return false
end

function PICK(tbl)
	if tbl == nil then
		return tbl
	end
	if !istable(tbl) then
		return tbl
	end

	return tbl[math.random(1,#tbl)]
end

function DebugBlock(pos,time)
	local b = ents.Create("prop_dynamic")
	b:SetModel("models/hunter/blocks/cube025x025x025.mdl")
	b:SetPos(pos)
	b:Spawn()
	b:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
	SafeRemoveEntityDelayed(b,time)
end

function ENT_Meta:CPT_GetCenter()
	return self:GetPos() + self:OBBCenter()
end

function ENT_Meta:CPT_GetAnimationData(seq)
	if type(seq) == "number" then
		seq = self:GetSequenceName(self:SelectWeightedSequence(seq))
	end
	local info = nil
	local done = self:GetAnimInfo(0).label
	local i = 1
	while i < 1600 do
		info = self:GetAnimInfo(i)
		if string_find(info.label,"@" .. seq) or string_find(info.label,"a_" .. seq) then
			return info
		end
		if(info.label == done) then break end
		i = i + 1
	end
	return nil
end

function ENT_Meta:CPT_GetAnimationFrameRate(seq)
	if type(seq) == "number" then
		seq = self:GetSequenceName(self:SelectWeightedSequence(seq))
	end
	return self:CPT_GetAnimationData(seq).fps
end

function ENT_Meta:CPT_GetAnimationFrameCount(seq)
	if type(seq) == "number" then
		seq = self:GetSequenceName(self:SelectWeightedSequence(seq))
	end
	return self:CPT_GetAnimationData(seq).numframes
end

function ENT_Meta:CPT_GetDistance(iDistType,vVec,vEntVec,optional)
	local vVec = vVec or self
	local vEntVec = vEntVec or self:GetEnemy()
	if !IsValid(vVec) then return end
	if !IsValid(vEntVec) then return end
	local num = 0
	if iDistType == 1 then
		num = vVec:Distance(vEntVec)
	elseif iDistType == 2 then
		num = (vEntVec -vVec):Length()
	elseif iDistType == 3 then
		num = vVec:DistToSqr(vEntVec) < (optional *optional)
	elseif iDistType == 4 then
		local epos = optional:NearestPoint(self:GetPos() +optional:OBBCenter())
		local spos = self:NearestPoint(optional:GetPos() +self:OBBCenter())
		epos.z = optional:GetPos().z
		spos.z = self:GetPos().z
		num = epos:Distance(spos)
	end
	return num
end

function ENT_Meta:CPT_GetDisp(ent)
	if self.GetRelationship then
		return self:GetRelationship(ent)
	else
		return self.Disposition && self:Disposition(ent) or D_ER
	end
end

function NPC_Meta:CPT_FindDispositions(tbDisp)
	local tbl = {}
	local function checkDisp(disp)
		for _,v in pairs(ents.GetAll()) do
			if self:CPT_GetDisp(v) == disp then
				tbl[#tbl +1] = ent
			end
		end
	end
	for _,disp in pairs(tbDisp) do
		checkDisp(disp)
	end
	return tbl
end

function LerpValue(clampedFraction,startValue,endValue)
	return (1 -clampedFraction) *startValue +clampedFraction *endValue
end

function RankTable(tbl)
	table.SortByKey(tbl,true)
end

function UpdateTableList(tb,v)
	if !tb[v] then
		table.insert(tb,v)
	end
end

function NPC_Meta:CPT_IsAlly(ent)
	if self:Disposition(ent) == D_LI || self:Disposition(ent) == D_NU then
		return true
	end
	return false
end

function NPC_Meta:CPT_GetSpaceTexture(range)
	local tr = util.TraceLine({
		start = self:GetPos(),
		endpos = self:GetPos() +self:GetUp() *-range,
		filter = self,
	})
	local mat = util.GetSurfacePropName(tr.SurfaceProps)
	return mat
end

function NPC_Meta:CPT_Freeze(t)
	local function DoFreeze()
		if IsValid(self) then
			self:StopMoving()
		end
	end
	timer.Create("CPTBase_FreezeNPCMovement_RandomInterval_"..math.Rand(1,99999) .. self:EntIndex(),0.1,t,function() DoFreeze() end)
end

function util.SaveCPTBaseNodegraph()
	local writable
	local dir = "cptbase/graphs/"
	local map = game.GetMap()
	local toWrite = dir .. map .. ".txt"
	for _,v in ipairs(ents.GetAll()) do
		if v:GetClass() == "cpt_ai_node_manager" then
			writable = v:GetNodes()
		end
	end
	file.CreateDir("cptbase/graphs")
	-- if file.Exists(toWrite,"DATA") then
		-- file.Delete(toWrite)
	-- end
	local inputTbl = {}
	for i = 1, #writable do
		inputTbl[i] = writable
	end
	file.Write(toWrite,util.TableToJSON(inputTbl))
end

function util.GetCPTBaseNodegraph()
	local map = game.GetMap()
	local mapData = file.Read("cptbase/graphs/" .. map .. ".txt","DATA")
	if mapData == nil then
		return "noData"
	end
	return util.JSONToTable(mapData)
end

function NPC_Meta:CPT_GetNodeManager()
	for _,v in ipairs(ents.GetAll()) do
		if v:GetClass() == "cpt_ai_node_manager" then
			return v
		end
	end
end

function PrintEntityPlacement(ent)
	print("-----------------------")
	print("Vector("..ent:GetPos().x..","..ent:GetPos().y..","..ent:GetPos().z..")")
	print("Angle("..ent:GetAngles().p..","..ent:GetAngles().y..","..ent:GetAngles().r..")")
	print("-----------------------")
end

function util.FindInSphere(pos,dist)
	local tb = {}
	for _,v in ipairs(ents.GetAll()) do
		if v:GetPos():Distance(pos) <= dist then
			table.insert(tb,v)
		end
	end
	return tb
end

function RandValue(v,vb,d)
	if d then
		return math.Rand(v,vb)
	else
		return math.random(v,vb)
	end
end

function FindLuaFile(luadir)
	return file.Exists(luadir,"LUA")
end

function FindGameFile(filedir)
	return file.Exists(filedir,"GAME")
end

function NPC_Meta:GetCPTBaseRagdoll()
	return self.CPTBase_Ragdoll
end

function PLY_Meta:GetCPTBaseRagdoll()
	return self.CPTBase_Ragdoll
end

function PLY_Meta:SetCPTBaseRagdoll(ent)
	self.CPTBase_Ragdoll = ent
end

function NPC_Meta:CPT_SetNoTarget(nt)
	self.UseNotarget = nt
	if nt then
		self:AddFlags(FL_NOTARGET)
	else
		self:RemoveFlags(FL_NOTARGET)
	end
end

function PLY_Meta:CPT_SetNoTarget(nt)
	if nt then
		self:AddFlags(FL_NOTARGET)
	else
		self:RemoveFlags(FL_NOTARGET)
	end
end

function PLY_Meta:SpawnCPTBaseRagdoll(ent,velocity,caller)
	if SERVER then
		local rag = ents.Create("prop_ragdoll")
		rag:SetModel(ent:GetModel())
		rag:SetPos(ent:GetPos())
		rag:SetAngles(ent:GetAngles())
		rag:Spawn()
		rag:SetCollisionGroup(1)
		if self:IsOnFire() then
			rag:Ignite(math.random(8,10),1)
		end
		rag:SetVelocity(self:GetVelocity())
		for i = 1,128 do
			local bonephys = rag:GetPhysicsObjectNum(i)
			if IsValid(bonephys) then
				local bonepos,boneang = self:GetBonePosition(rag:TranslatePhysBoneToBone(i))
				if(bonepos) then
					bonephys:SetPos(bonepos)
					bonephys:SetAngles(boneang)
					if IsValid(caller) then
						-- bonephys:ApplyForceCenter(caller:GetPos() -rag:GetForward() *velocity.x +rag:GetRight() *velocity.y +rag:GetUp() *velocity.z)
						bonephys:SetVelocity(rag:GetVelocity() +caller:GetForward() *velocity.x +caller:GetRight() *velocity.y +caller:GetUp() *velocity.z)
					end
				end
			end
		end
		ent.LastRagdollMoveT = CurTime() +3
		ent:SetCPTBaseRagdoll(rag)
		ent.RagdollHealthCPTBase = self:Health()
		ent.RagdollArmorCPTBase = self:Armor()
		ent.CPTBase_RagdollWeapons = {}
		for k,v in pairs(self:GetWeapons()) do
			table.insert(self.CPTBase_RagdollWeapons,v:GetClass())
		end
		ent.CPTBase_HasBeenRagdolled = true
		ent:ChatPrint("Hint: Spam your 'W' key to get up faster!")
	end
end

function PLY_Meta:CPTBaseUnRagdoll()
	if IsValid(self:GetCPTBaseRagdoll()) then
		local pos = self:GetCPTBaseRagdoll():GetPos()
		local ang = self:GetCPTBaseRagdoll():GetAngles()
		self:SetPos(pos)
		self:SetAngles(ang)
		self:GetCPTBaseRagdoll():Remove()
		self:UnSpectate()
		self:KillSilent()
		self:Spawn()
		self:SetPos(pos)
		self:SetAngles(ang)
		self:SetHealth(self.RagdollHealthCPTBase)
		self:SetArmor(self.RagdollArmorCPTBase)
		for k,v in pairs(self.CPTBase_RagdollWeapons) do
			self:Give(v)
		end
	end
end

function PLY_Meta:CPT_CreateRagdolledPlayer(vel,caller)
	local velocity = vel or Vector(-300,0,300)
	self:SpawnCPTBaseRagdoll(self,velocity,caller)
end

function ENT_Meta:CPT_GetCurrentFrame(fps)
	return self:GetCycle() *fps
end

function NPC_Meta:CPT_SetInvisible(inv)
	self:SetNoDraw(inv)
	self:DrawShadow(not inv)
end

function NPC_Meta:SpawnEntityAtSelf(class,useclearpos)
	if SERVER then
		local ent = ents.Create(class)
		if useclearpos then
			ent:CPT_SetClearPos(self:GetPos())
		else
			ent:SetPos(self:GetPos())
		end
		ent:SetAngles(self:GetAngles())
		ent:Spawn()
	end
end

function ENT_Meta:CPT_GetAllEnts()
	for _,v in ipairs(player.GetAll()) do
		return v
	end
end

function ENT_Meta:CPT_GetAllPlayers()
	for _,v in ipairs(player.GetAll()) do
		return v
	end
end

SNDDURATION_TABLE = {}

function NPC_Meta:CPT_GetNPCEnemy()
	if self.NPC_Enemy == nil then
		return nil
	elseif self.NPC_Enemy != nil && IsValid(self.NPC_Enemy) then
		return self.NPC_Enemy
	elseif self.NPC_Enemy != nil && IsValid(self.NPC_Enemy) then
		return nil
	end
end

function NPC_Meta:Deaths()
	return 0
end

function NPC_Meta:CPT_SetNPCEnemy(ent)
	self.NPC_Enemy = ent
end

function NPC_Meta:CPT_SetSummonedByPlayer(ent)
	self.Faction = ent.Faction
	local faction = self.Faction
	if type(faction) == "string" then -- Backwards capability for old factions
		self.Faction = {faction}
	end
	self.VJ_NPC_Class = {}
	for _,v in pairs(self.Faction) do
		table.insert(self.VJ_NPC_Class,string.Replace(v,"FACTION_","CLASS_"))
	end
	self.FriendlyToPlayers = true
	self.AllowedToFollowPlayer = false
	self.CanWander = false
	self.IsFollowingAPlayer = true
	self.TheFollowedPlayer = ent
	self.MinimumFollowDistance = math.random(120,150)
end

function IsAIDisabled()
	if GetConVarNumber("ai_disabled") == 1 then
		return true
	end
	return false
end

// util.AddAttackEffect(self,enemy,8,DMG_POI,1.5,10)
function util.AddAttackEffect(attacker,ent,dmg,ef,delay,lp)
	if GetConVarNumber("cpt_allowspecialdmg") == 0 then return end
	if (!ent:IsNPC() && !ent:IsPlayer()) then return end
	local finaldmg = AdaptCPTBaseDamage(dmg)
	local deaths = ent:Deaths()
	local EFDeath = delay *lp
	local fTime = true
	local function SpawnEFM(ent,mat)
		if SERVER then
			local efm = ents.Create("cpt_effect_manager")
			efm:SetEffectTime(EFDeath)
			efm:SetEffectedEntity(ent)
			efm:SetEffectType(mat)
			efm:Spawn()
			timer.Simple(0.02,function()
				if IsValid(ent) then
					if ent:IsPlayer() && IsValid(ent:GetCPTBaseRagdoll()) then
						local efm = ents.Create("cpt_effect_manager")
						efm:SetEffectTime(EFDeath)
						efm:SetEffectedEntity(ent:GetCPTBaseRagdoll())
						efm:SetEffectType(mat)
						efm:Spawn()
					elseif ent:IsNPC() && IsValid(ent.CPTBase_Ragdoll) then
						local efm = ents.Create("cpt_effect_manager")
						efm:SetEffectTime(EFDeath)
						efm:SetEffectedEntity(ent.CPTBase_Ragdoll)
						efm:SetEffectType(mat)
						efm:Spawn()
					end
				end
			end)
		end
	end
	if ef == DMG_RAD then
		if ent.CPTBase_ExperiencingEFDamage_RAD == nil then
			ent.CPTBase_ExperiencingEFDamage_RAD = false
		end
		if ent.CPTBase_EF_RAD == nil then
			ent.CPTBase_EF_RAD = 0
		end
		if ent.CPTBase_EF_RAD >= 400 then ent:Kill() return end
		if ent.CPTBase_ExperiencingEFDamage_RAD then return end
		ent.CPTBase_ExperiencingEFDamage_RAD = true
		SpawnEFM(ent,"cpthazama/effect_rad")
		timer.Simple(EFDeath,function()
			if IsValid(ent) then
				if ent:Deaths() > deaths then return end
				ent.CPTBase_ExperiencingEFDamage_RAD = false
			end
		end)
		local function DoDamage()
			if IsValid(ent) then
				if ent:Deaths() > deaths then return end
				if ent.CPTBase_EF_RAD >= 400 then ent:Kill() return end
				local dmginfo = DamageInfo()
				dmginfo:SetDamage(finaldmg)
				if attacker:IsValid() then
					dmginfo:SetAttacker(attacker)
					dmginfo:SetInflictor(attacker)
				end
				dmginfo:SetDamageType(DMG_RADIATION)
				if attacker:IsValid() then
					dmginfo:SetDamagePosition(ent:NearestPoint(attacker:GetPos() +attacker:OBBCenter()))
				else
					dmginfo:SetDamagePosition(ent:GetPos() +ent:OBBCenter())
				end
				if IsValid(ent) then
					ent:TakeDamageInfo(dmginfo)
				end
				ent:EmitSound("player/geiger3.wav",60,100)
				if ent:IsPlayer() then ent:ChatPrint("RADS +" .. tostring(math.Round(lp *1.5))) end
				ent.CPTBase_EF_RAD = ent.CPTBase_EF_RAD +math.Round(lp *1.5)
			end
		end
		timer.Create("CPTBase_DoEffectDamage_" .. math.Rand(1,99999),delay,lp,function() DoDamage() end)
	elseif ef == DMG_POI then
		if ent.CPTBase_ExperiencingEFDamage_POI == nil then
			ent.CPTBase_ExperiencingEFDamage_POI = false
		end
		if ent.CPTBase_ExperiencingEFDamage_POI then return end
		ent.CPTBase_ExperiencingEFDamage_POI = true
		SpawnEFM(ent,"cpthazama/effect_poison")
		if fTime then
			ent:EmitSound("cpthazama/fallout4/fx/FX_Effect_Damage_Poison_01.mp3",60,100)
			fTime = false
		end
		timer.Simple(EFDeath,function()
			if IsValid(ent) then
				if ent:Deaths() > deaths then return end
				ent.CPTBase_ExperiencingEFDamage_POI = false
			end
		end)
		local function DoDamage()
			if IsValid(ent) then
				if ent:Deaths() > deaths then return end
				local dmginfo = DamageInfo()
				dmginfo:SetDamage(finaldmg)
				if attacker:IsValid() then
					dmginfo:SetAttacker(attacker)
					dmginfo:SetInflictor(attacker)
				end
				dmginfo:SetDamageType(DMG_POISON)
				if attacker:IsValid() then
					dmginfo:SetDamagePosition(ent:NearestPoint(attacker:GetPos() +attacker:OBBCenter()))
				else
					dmginfo:SetDamagePosition(ent:GetPos() +ent:OBBCenter())
				end
				if IsValid(ent) then
					ent:TakeDamageInfo(dmginfo)
				end
			end
		end
		timer.Create("CPTBase_DoEffectDamage_" .. math.Rand(1,99999),delay,lp,function() DoDamage() end)
	elseif ef == DMG_DARKENERGY then
		if ent.CPTBase_ExperiencingEFDamage_DE == nil then
			ent.CPTBase_ExperiencingEFDamage_DE = false
		end
		if ent.CPTBase_ExperiencingEFDamage_DE then return end
		ent.CPTBase_ExperiencingEFDamage_DE = true
		SpawnEFM(ent,"cpthazama/effect_darkenergy")
		if fTime then
			-- ent:EmitSound("weapons/physcannon/energy_disintegrate4.wav",60,100)
			ent:EmitSound("ambient/energy/whiteflash.wav",60,100)
			fTime = false
		end
		timer.Simple(EFDeath,function()
			if IsValid(ent) then
				if ent:Deaths() > deaths then return end
				ent.CPTBase_ExperiencingEFDamage_DE = false
			end
		end)
		local function DoDamage()
			if IsValid(ent) then
				if ent:Deaths() > deaths then return end
				local dmginfo = DamageInfo()
				dmginfo:SetDamage(finaldmg)
				if attacker:IsValid() then
					dmginfo:SetAttacker(attacker)
					dmginfo:SetInflictor(attacker)
				end
				dmginfo:SetDamageType(DMG_DROWN)
				if attacker:IsValid() then
					dmginfo:SetDamagePosition(ent:NearestPoint(attacker:GetPos() +attacker:OBBCenter()))
				else
					dmginfo:SetDamagePosition(ent:GetPos() +ent:OBBCenter())
				end
				if IsValid(ent) then
					ent:TakeDamageInfo(dmginfo)
				end
			end
		end
		timer.Create("CPTBase_DoEffectDamage_" .. math.Rand(1,99999),delay,lp,function() DoDamage() end)
	elseif ef == DMG_ELEC then
		if ent.CPTBase_ExperiencingEFDamage_ELEC == nil then
			ent.CPTBase_ExperiencingEFDamage_ELEC = false
		end
		if ent.CPTBase_ExperiencingEFDamage_ELEC then return end
		ent.CPTBase_ExperiencingEFDamage_ELEC = true
		SpawnEFM(ent,"cpthazama/effect_tesla")
		timer.Simple(EFDeath,function()
			if IsValid(ent) then
				if ent:Deaths() > deaths then return end
				ent.CPTBase_ExperiencingEFDamage_ELEC = false
			end
		end)
		local function DoDamage()
			if IsValid(ent) then
				if ent:Deaths() > deaths then return end
				local dmginfo = DamageInfo()
				dmginfo:SetDamage(finaldmg)
				if attacker:IsValid() then
					dmginfo:SetAttacker(attacker)
					dmginfo:SetInflictor(attacker)
				end
				dmginfo:SetDamageType(DMG_SHOCK)
				if attacker:IsValid() then
					dmginfo:SetDamagePosition(ent:NearestPoint(attacker:GetPos() +attacker:OBBCenter()))
				else
					dmginfo:SetDamagePosition(ent:GetPos() +ent:OBBCenter())
				end
				if IsValid(ent) then
					ent:EmitSound("ambient/energy/spark" .. math.random(1,6) .. ".wav",70,100)
					ent:TakeDamageInfo(dmginfo)
				end
			end
		end
		timer.Create("CPTBase_DoEffectDamage_" .. math.Rand(1,99999),delay,lp,function() DoDamage() end)
	elseif ef == DMG_AFTERBURN then
		if ent.CPTBase_ExperiencingEFDamage_AFTERBURN == nil then
			ent.CPTBase_ExperiencingEFDamage_AFTERBURN = false
		end
		if ent.CPTBase_ExperiencingEFDamage_AFTERBURN then return end
		ent.CPTBase_ExperiencingEFDamage_AFTERBURN = true
		SpawnEFM(ent,"cpthazama/effect_fire")
		timer.Simple(EFDeath,function()
			if IsValid(ent) then
				if ent:Deaths() > deaths then return end
				ent.CPTBase_ExperiencingEFDamage_AFTERBURN = false
			end
		end)
		local function DoDamage()
			if IsValid(ent) then
				if ent:Deaths() > deaths then return end
				local dmginfo = DamageInfo()
				dmginfo:SetDamage(finaldmg)
				if attacker:IsValid() then
					dmginfo:SetAttacker(attacker)
					dmginfo:SetInflictor(attacker)
				end
				dmginfo:SetDamageType(DMG_BURN)
				if attacker:IsValid() then
					dmginfo:SetDamagePosition(ent:NearestPoint(attacker:GetPos() +attacker:OBBCenter()))
				else
					dmginfo:SetDamagePosition(ent:GetPos() +ent:OBBCenter())
				end
				if IsValid(ent) then
					ent:TakeDamageInfo(dmginfo)
				end
			end
		end
		timer.Create("CPTBase_DoEffectDamage_" .. math.Rand(1,99999),delay,lp,function() DoDamage() end)
	elseif ef == DMG_FROST then
		if ent.CPTBase_ExperiencingEFDamage_FROST == nil then
			ent.CPTBase_ExperiencingEFDamage_FROST = false
		end
		if ent.CPTBase_ExperiencingEFDamage_FROST then return end
		ent.CPTBase_ExperiencingEFDamage_FROST = true
		SpawnEFM(ent,"cpthazama/effect_frozen")
		timer.Simple(EFDeath,function()
			if IsValid(ent) then
				if ent:Deaths() > deaths then return end
				ent.CPTBase_ExperiencingEFDamage_FROST = false
			end
		end)
		local function DoDamage()
			if IsValid(ent) then
				if ent:Deaths() > deaths then return end
				local dmginfo = DamageInfo()
				dmginfo:SetDamage(finaldmg)
				if attacker:IsValid() then
					dmginfo:SetAttacker(attacker)
					dmginfo:SetInflictor(attacker)
				end
				dmginfo:SetDamageType(DMG_GENERIC)
				if attacker:IsValid() then
					dmginfo:SetDamagePosition(ent:NearestPoint(attacker:GetPos() +attacker:OBBCenter()))
				else
					dmginfo:SetDamagePosition(ent:GetPos() +ent:OBBCenter())
				end
				if IsValid(ent) then
					ent:TakeDamageInfo(dmginfo)
				end
				-- for i = 0,ent:GetBoneCount() -1 do
					-- CPT_ParticleEffect("cpt_projectile_freeze_explode",ent:GetBonePosition(i),Angle(0,0,0),nil)
				-- end
				if ent:Health() <= 0 then
					ent:EmitSound("physics/glass/glass_impact_bullet4.wav",70,100)
				else
					ent:EmitSound("ambient/materials/footsteps_glass1.wav",50,math.random(125,150))
				end
			end
		end
		timer.Create("CPTBase_DoEffectDamage_" .. math.Rand(1,99999),delay,lp,function() DoDamage() end)
	end
end

function AdaptCPTBaseDamage(dmg)
	local dif = math.Round(GetConVarNumber("cpt_aidifficulty"))
	local finaldmg
	if dif == 1 then
		finaldmg = dmg *0.5
	elseif dif == 2 then
		finaldmg = dmg
	elseif dif == 3 then
		finaldmg = dmg *2
	elseif dif == 4 then
		finaldmg = dmg *4
	else
		finaldmg = dmg
	end
	return finaldmg
end

function NPC_Meta:SetArmor(amount)
	if self:IsPlayer() then self:SetArmor(amount) return end
	self.Armor = amount
end

function NPC_Meta:Armor()
	if self.Armor == nil then return 0 end
	return self.Armor
end

if CLIENT then
	function NPC_Meta:Nick()
		return language.GetPhrase(self:GetClass())
	end
end

function ENT_Meta:GetSLVBase_HitBox(name)
	if name == "head" then
		return 102
	elseif name == "chest" then
		return 103
	elseif name == "leftarm" then
		return 104
	elseif name == "rightarm" then
		return 105
	elseif name == "leftleg" then
		return 106
	elseif name == "rightleg" then
		return 107
	elseif name == "stomach" then
		return 108
	elseif name == "gear" then
		return 109
	end
end

function ENT_Meta:CPT_DropNPCWeapon(pos,ang)
	if self:GetActiveWeapon() != NULL then
		local wep = ents.Create(self:GetActiveWeapon():GetClass())
		wep:SetPos(pos)
		wep:SetAngles(ang)
		wep:Spawn()
	end
end

function NPC_Meta:CPT_CreateRagdolledNPC(vel,caller,ovtype)
	if self.CPTBase_NPC != true then return end
	local velocity = vel or Vector(-300,0,300)
	local mdl = self:GetModel()
	local phy = string.Replace(mdl,".mdl",".phy")
	local mtype = ovtype or "prop_ragdoll"
	if !file.Exists(phy,"GAME") then return end // Checks if the model has physics
	self.CPTBase_Ragdoll = ents.Create("prop_ragdoll")
	self.CPTBase_Ragdoll:SetModel(self:GetModel())
	self.CPTBase_Ragdoll:SetPos(self:GetPos())
	self.CPTBase_Ragdoll:SetAngles(self:GetAngles())
	self.CPTBase_Ragdoll:Spawn()
	self.CPTBase_Ragdoll:Activate()
	self.CPTBase_Ragdoll:SetModelScale(self:GetModelScale())
	self.IsRagdolled = true
	self:SetPersistent(true)
	self:SetCollisionGroup(1)
	self.CPTBase_Ragdoll:SetSkin(self:GetSkin())
	for i = 0,18 do
		self.CPTBase_Ragdoll:SetBodygroup(i,self:GetBodygroup(i))
	end
	self.CPTBase_Ragdoll:SetColor(self:GetColor())
	self.CPTBase_Ragdoll:SetMaterial(self:GetMaterial())
	self.CPTBase_Ragdoll:SetCollisionGroup(1)
	self:SetColor(Color(255,255,255,0))
	if self:IsOnFire() then
		self.CPTBase_Ragdoll:Ignite(math.random(8,10),1)
	end
	self.CPTBase_Ragdoll:SetVelocity(self:GetVelocity())
	for i = 1,128 do
		local bonephys = self.CPTBase_Ragdoll:GetPhysicsObjectNum(i)
		if IsValid(bonephys) then
			local bonepos,boneang = self:GetBonePosition(self.CPTBase_Ragdoll:TranslatePhysBoneToBone(i))
			if(bonepos) then
				bonephys:SetPos(bonepos)
				bonephys:SetAngles(boneang)
				bonephys:SetVelocity(self.CPTBase_Ragdoll:GetVelocity() +caller:GetForward() *velocity.x +caller:GetRight() *velocity.y +caller:GetUp() *velocity.z)
				-- bonephys:ApplyForceCenter(caller:GetPos() -self.CPTBase_Ragdoll:GetForward() *velocity.x +self.CPTBase_Ragdoll:GetRight() *velocity.y +self.CPTBase_Ragdoll:GetUp() *velocity.z)
			end
		end
	end
	self:SetRagdollEntity(self.CPTBase_Ragdoll)
	self:SetRagdolled(true)
	-- timer.Simple(self.RagdollRecoveryTime,function()
		-- if IsValid(self) then
			-- if self.CPTBase_Ragdoll:IsValid() then
				-- self:CPT_SetClearPos(self.CPTBase_Ragdoll:GetPos())
				-- self:SetColor(self.CPTBase_Ragdoll:GetColor())
				-- self.CPTBase_Ragdoll:Remove()
				-- self:SetNoDraw(false)
				-- self:DrawShadow(true)
				-- self.IsRagdolled = false
				-- self.bInSchedule = false
				-- self:OnRagdollRecover()
			-- else
				-- self:CPT_SetClearPos(self:GetPos())
				-- self:SetColor(255,255,255,255)
				-- self:SetNoDraw(false)
				-- self:DrawShadow(true)
				-- self.IsRagdolled = false
				-- self.bInSchedule = false
				-- self:OnRagdollRecover()
			-- end
			-- self:SetCollisionGroup(9)
			-- self:SetPersistent(false)
			-- self:UpdateFriends()
			-- self:UpdateEnemies()
		-- end
	-- end)
end

function NPC_Meta:CPT_SetClearPos(origin) // Credits to Silverlan
	local mins = self:OBBMins()
	local maxs = self:OBBMaxs()
	local pos = origin || self:GetPos()
	local nearents = ents.FindInBox(pos +mins,pos +maxs)
	maxs.x = maxs.x *2
	maxs.y = maxs.y *2
	local zMax = 0
	local entTgt
	for _,ent in ipairs(nearents) do
		if(ent != self && ent:GetSolid() != SOLID_NONE && ent:GetSolid() != SOLID_BSP && gamemode.Call("ShouldCollide",self,ent) != false) then
			local obbMaxs = ent:OBBMaxs()
			if(obbMaxs.z > zMax) then
				zMax = obbMaxs.z
				entTgt = ent
			end
		end
	end
	local tbl_filter = {self,entTgt}
	local stayaway = zMax > 0
	if(!stayaway) then
		pos.z = pos.z +10
	else
		zMax = zMax +10
	end
	local left = Vector(0,1,0)
	local right = left *-1
	local forward = Vector(1,0,0)
	local back = forward *-1
	local trace_left = util.TraceLine({
		start = pos,
		endpos = pos +left *maxs.y,
		filter = tbl_filter
	})
	local trace_right = util.TraceLine({
		start = pos,
		endpos = pos +right *maxs.y,
		filter = tbl_filter
	})
	if(trace_left.Hit || trace_right.Hit) then
		if(trace_left.Fraction < trace_right.Fraction) then
			pos = pos +right *((trace_right.Fraction -trace_left.Fraction) *maxs.y)
		elseif(trace_right.Fraction < trace_left.Fraction) then
			pos = pos +left *((trace_left.Fraction -trace_right.Fraction) *maxs.y)
		end
	elseif(stayaway) then
		pos = pos +(math.random(1,2) == 1 && left || right) *maxs.y *1.8
		stayaway = false
	end
	local trace_forward = util.TraceLine({
		start = pos,
		endpos = pos +forward *maxs.x,
		filter = tbl_filter
	})
	local trace_backward = util.TraceLine({
		start = pos,
		endpos = pos +back *maxs.x,
		filter = tbl_filter
	})
	if(trace_forward.Hit || trace_backward.Hit) then
		if(trace_forward.Fraction < trace_backward.Fraction) then
			pos = pos +back *((trace_backward.Fraction -trace_forward.Fraction) *maxs.x)
		elseif(trace_backward.Fraction < trace_forward.Fraction) then
			pos = pos +forward *((trace_forward.Fraction -trace_backward.Fraction) *maxs.x)
		end
	elseif(stayaway) then
		pos = pos +(math.random(1,2) == 1 && forward || back) *maxs.x *1.8
		stayaway = false
	end
	if(stayaway) then -- We can't avoid whatever it is we're stuck in, let's try to spawn on top of it
		local start = entTgt:GetPos()
		start.z = start.z +zMax
		local endpos = start
		endpos.z = endpos.z +maxs.z
		local tr = util.TraceLine({
			start = start,
			endpos = endpos,
			filter = tbl_filter
		})
		if(!tr.Hit || (!tr.HitWorld && gamemode.Call("ShouldCollide",self,tr.Entity) == false)) then
			pos.z = start.z
			stayaway = false
		else -- Just try to move to whatever direction seems best
			local trTgt = trace_left
			if(trace_right.Fraction < trTgt.Fraction) then trTgt = trace_right end
			if(trace_forward.Fraction < trTgt.Fraction) then trTgt = trace_forward end
			if(trace_backward.Fraction < trTgt.Fraction) then trTgt = trace_backward end
			pos = pos +trTgt.Normal *maxs.x
		end
	end
	self:SetPos(pos)
end

-- hook.Add("Think","CPTBase_MutationEffects",function()
	-- for _,v in ipairs(ents.GetAll()) do
	-- 	if v:IsNPC() && v.CPTBase_NPC == true then
	-- 		if v.HasMutated == true then
	-- 			if CurTime() > v.NextMutT then
	-- 				v:StopParticles()
	-- 				for i = 0, v:GetBoneCount() -1 do
	-- 					if v:GetBonePosition(i) != v:GetPos() then
	-- 						CPT_ParticleEffect(v.MutationEmbers,v:GetBonePosition(i),Angle(0,0,0),v)
	-- 						CPT_ParticleEffect(v.MutationGlow,v:GetBonePosition(i),Angle(0,0,0),v)
	-- 					end
	-- 				end
	-- 				v.NextMutT = CurTime() +0.4
	-- 			end
	-- 		end
	-- 	end
	-- end
-- end)

function RunTrace(start,endpos,filter,options)
	local tr = {}
	tr.start = start
	tr.endpos = endpos
	tr.filter = filter

	if options then
		for k,v in pairs(options) do
			tr[k] = v
		end
	end

	return util.TraceLine(tr)
end

function RunHullTrace(start,endpos,filter,mins,maxs,options)
	local tr = {}
	tr.start = start
	tr.endpos = endpos
	tr.filter = filter
	tr.mins = mins
	tr.maxs = maxs

	if options then
		for k,v in pairs(options) do
			tr[k] = v
		end
	end

	return util.TraceHull(tr)
end

function NPC_Meta:DoCustomTrace_Mask(enter,exit,mask,filt)
	local tracedata = {}
	tracedata.start = enter
	tracedata.endpos = exit
	tracedata.mask = mask
	tracedata.filter = filt
	local tr = util.TraceLine(tracedata)
	return tr
end

function NPC_Meta:DoCustomTrace(enter,exit,filt,sendfulldata) -- :/
	local tracedata = {}
	tracedata.start = enter
	tracedata.endpos = exit
	tracedata.filter = filt
	local tr = util.TraceLine(tracedata)
	if sendfulldata then
		return tr
	else
		return tr.HitPos
	end
end

/*
	local function callBack(t)
		return math.sin(t *math.pi *2 /44100 *2000) *π
	end
	util.GenSound("genSound01",3,callBack)
*/
function util.GenerateSound(sndName,sndLen,callBack)
	local generatedID = sndName .. tostring(math.Rand(0,999999))
	sound.Generate(generatedID,44100,sndLen,callBack)
	surface.PlaySound(generatedID)
end

function util.CreateSplashDamage(pos,dmg,dmgtype,dist,attacker)
	for _,v in ipairs(ents.FindInSphere(pos,dist)) do
		if v:IsValid() && (v:IsNPC() || v:IsPlayer()) && attacker:Disposition(v) != D_LI && v != attacker then
			local dmgpos = v:NearestPoint(attacker:GetPos() +attacker:OBBCenter())
			local dmginfo = DamageInfo()
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
			dmginfo:SetAttacker(attacker)
			dmginfo:SetInflictor(attacker)
			dmginfo:SetDamageType(dmgtype)
			dmginfo:SetDamagePosition(dmgpos)
			v:TakeDamageInfo(dmginfo)
		end
	end
end

function util.CreateCustomExplosion(pos,dmg,dist,attacker,effect,snd,silent,sndvol)
	local pos = pos or Vector(0,0,0)
	local dmg = dmg or 60
	local dist = dist or 300
	local vol
	if sndvol == nil then
		vol = 120
	else
		vol = sndvol
	end
	local exploeffect
	if effect != false && effect == nil then
		exploeffect = "mininuke_explosion"
	else
		exploeffect = effect
	end
	local explosnd
	if snd == nil then
		explosnd = "weapons/explode" .. math.random(3,5) .. ".wav"
	else
		explosnd = snd
	end
	local silent = silent or false
	if silent != true then
		if effect != false then
			CPT_ParticleEffect(exploeffect,pos,Angle(0,0,0),nil)
		end
		sound.Play(explosnd,pos,vol,100)
		sound.Play("weapons/debris" .. math.random(1,3) .. ".wav",pos,95,100)
	end
	local dif = GetConVarNumber("cpt_aidifficulty")
	local finaldmg
	-- if attacker:IsNPC() || (IsValid(attacker:GetOwner()) && attacker:GetOwner():IsNPC()) then
		if dif == 1 then
			finaldmg = dmg *0.5
		elseif dif == 2 then
			finaldmg = dmg
		elseif dif == 3 then
			finaldmg = dmg *2
		elseif dif == 4 then
			finaldmg = dmg *4
		end
	-- else
		-- finaldmg = dmg
	-- end
	util.BlastDamage(attacker,attacker,pos,dist,finaldmg)
	util.ScreenShake(pos,5,finaldmg,math.Clamp(finaldmg /100,0.1,2),dist *2)
end

function ENT_Meta:GetClosestPoint(ent)
	local epos = ent:NearestPoint(self:GetPos() +ent:OBBCenter())
	local spos = self:NearestPoint(ent:GetPos() +self:OBBCenter())
	epos.z = ent:GetPos().z
	spos.z = self:GetPos().z
	return epos:Distance(spos)
	-- return self:NearestPoint(ent:GetPos() +self:OBBCenter()):Distance(ent:NearestPoint(self:GetPos() +ent:OBBCenter()))
end

function NPC_Meta:CPT_PlayNPCSentence(sentence)
	local snd = self:SelectFromTable(self.tbl_Sentences[sentence])
	self:CreateNPCSentence(snd)
end

function NPC_Meta:CPT_PlayTimedSound(snd,time,sndlvl,pitch)
	sndlvl = sndlvl or 75
	pitch = pitch or 100
	timer.Simple(time,function()
		if IsValid(self) then
			sound.Play(snd,self:GetPos(),sndlvl,pitch *GetConVarNumber("host_timescale"))
		end
	end)
end

function NPC_Meta:CPT_FindAngleOfPosition(pos,ang)
	local angle = ang -(pos -self:GetPos()):Angle()
	return angle
end

function WPN_Meta:CPT_CreateLoopSound(sound,lvl,pitch,volume)
	local lvl = lvl or 70
	local pitch = pitch or 100
	local volume = volume or 75
	_csp = CreateSound(self,sound)
	_csp:SetSoundLevel(lvl)
	_csp:Play()
	_csp:ChangePitch(pitch *GetConVarNumber("host_timescale"),0)
	_csp:ChangeVolume(volume,0)
	table.insert(self.LoopedSounds,_csp)
	if (!_csp:IsPlaying()) then
		_csp:Play()
	end
end

function ENT_Meta:CPT_CreateLoopSound(sound,lvl,pitch,volume)
	local lvl = lvl or 70
	local pitch = pitch or 100
	local volume = volume or 75
	_csp = CreateSound(self,sound)
	_csp:SetSoundLevel(lvl)
	_csp:Play()
	_csp:ChangePitch(pitch *GetConVarNumber("host_timescale"),0)
	_csp:ChangeVolume(volume,0)
	if !self:IsPlayer() then
		table.insert(self.LoopedSounds,_csp)
	end
	if (!_csp:IsPlaying()) then
		_csp:Play()
	end
end

function NPC_Meta:CPT_CheckConfidence(ent)
	local entconf
	if ent:IsPlayer() then
		ent.Confidence = 2
	end
	if ent.Confidence == nil then
		ent.Confidence = 0
	end
	if ent.Confidence > self.Confidence then
		entconf = "run!"
	elseif ent.Confidence <= self.Confidence then
		entconf = "attack!"
	end
	return entconf
end

function util.RandomVectorAroundPos(pos,max,ignorez)
	if !ignorez then
		_pos = (pos +Vector(math.random(-max,max),math.random(-max,max),math.random(-max,max)))
	else
		_pos = (pos +Vector(math.random(-max,max),math.random(-max,max),0))
	end
	return _pos
end

function util.CreateWorldLight(ent,pos,color,brightness,distance,on,off)
	local color = color or "0 169 255 200"
	local brightness = brightness or "2"
	local distance = distance or "150"
	local on = on or "0"
	local nooff = false
	if off == false then
		nooff = true
	end
	ent._worldlight = ents.Create("light_dynamic")
	ent._worldlight:SetKeyValue("_light",color)
	ent._worldlight:SetKeyValue("brightness",brightness)
	ent._worldlight:SetKeyValue("distance",distance)
	ent._worldlight:SetKeyValue("style","0")
	ent._worldlight:SetPos(pos)
	ent._worldlight:SetParent(self)
	ent._worldlight:Spawn()
	ent._worldlight:Activate()
	ent._worldlight:Fire("TurnOn","",on)
	if nooff == false then
		ent._worldlight:Fire("TurnOff","",off)
	end
	ent._worldlight:DeleteOnRemove(ent)
end

function WPN_Meta:CPT_PlayWeaponAnimation(anim,speed,loop)
	if type(anim) == "number" then
		return self.Weapon:SendWeaponAnim(anim)
	elseif type(anim) == "string" then
		return self:PlayWeaponSequence(anim,speed,loop)
	end
end

function NPC_Meta:CPT_SoundCreate(snd,vol,pitch)
	local pitch = pitch or 100
	if self.tbl_Sounds[snd] != nil then
		snd = self:SelectFromTable(self.tbl_Sounds[snd])
	end
	return sound.Play(snd,self:GetPos(),vol,pitch *GetConVarNumber("host_timescale"),1)
end

function WPN_Meta:CPT_SoundCreate(snd,vol,pitch)
	local pitch = pitch or 100
	if self.tbl_Sounds[snd] != nil then
		snd = self:SelectFromTable(self.tbl_Sounds[snd])
	end
	return sound.Play(snd,self:GetPos(),vol,pitch *GetConVarNumber("host_timescale"),1)
end

function PLY_Meta:GetWeaponAmmoName()
	local CPTBase_DefaultAmmoTypes = {
		["weapon_crowbar"] = -1,
		["weapon_physcannon"] = -1,
		["weapon_physgun"] = -1,
		["weapon_pistol"] = "9MM",
		["gmod_tool"] = -1,
		["weapon_357"] = ".357",
		["weapon_smg1"] = "4.6×30MM",
		["weapon_ar2"] = "Pulse",
		["weapon_crossbow"] = "Bolt",
		["weapon_frag"] = -1,
		["weapon_rpg"] = "RPG",
		["weapon_shotgun"] = "Buckshot",
	}
	if ply:GetActiveWeapon().Primary then
		return ply:GetActiveWeapon().Primary.Ammo
	else
		return CPTBase_DefaultAmmoTypes[ply:GetActiveWeapon():GetClass()]
	end
end

function PLY_Meta:AddToAmmoCount(amount,ammo)
	if (self:GetAmmoCount(ammo) +amount) > 9999 then
		self:RemoveAmmo(self:GetAmmoCount(ammo) -amount,ammo)
		return
	end
	self:GiveAmmo(amount,ammo,false)
end

if CLIENT then
	function GetRealName(ent)
		if ent:IsPlayer() then
			return ent:Nick()
		else
			if language.GetPhrase(ent:GetClass()) != nil then
				return language.GetPhrase(ent:GetClass())
			else
				return "Invalid Name"
			end
		end
	end
end

function NPC_Meta:KeyDown(key)
	return true
end

function Unregistered_SelectFromTable(tbl)
	if tbl == nil then return tbl end
	return tbl[math.random(1,#tbl)]
end

function ENT_Meta:SelectFromTable(tbl)
	if tbl == nil then return tbl end
	return tbl[math.random(1,#tbl)]
end

function NPC_Meta:SelectFromTable(tbl)
	if tbl == nil then return tbl end
	return tbl[math.random(1,#tbl)]
end

function PLY_Meta:SelectFromTable(tbl)
	if tbl == nil then return tbl end
	return tbl[math.random(1,#tbl)]
end

function WPN_Meta:SelectFromTable(tbl)
	if tbl == nil then return tbl end
	return tbl[math.random(1,#tbl)]
end

function WPN_Meta:CPT_PlayWeaponAnimation(tbl)
	if self.tbl_Animations[tbl] == nil then return end
	self.Weapon:SendWeaponAnim(self.tbl_Animations[tbl][math.random(1,#self.tbl_Animations[tbl])])
end

function NPC_Meta:CPT_UpdateNPCFaction()
	if self.Faction != self:GetNW2String("CPTBase_NPCFaction") then
		self.Faction = self:GetNW2String("CPTBase_NPCFaction")
	end
end

function PLY_Meta:CPT_UpdateNPCFaction()
	if self.Faction != self:GetNW2String("CPTBase_NPCFaction") then
		self.Faction = self:GetNW2String("CPTBase_NPCFaction")
	end
end

function ENT_Meta:CPT_TranslateNumberToString(anim)
	return self:GetSequenceName(anim)
end

function NPC_Meta:CPT_GetCurrentAnimation()
	return self:GetSequenceName(self:GetSequence())
end

function NPC_Meta:CPT_GetPlayedAnimation()
	-- return self.CurrentAnimation
	return self:GetSequenceName(self.CurrentAnimation)
end

function ENT_Meta:CPT_GetFaction()
	if self.Faction == nil then
		return "NO_FACTION"
	else
		return self.Faction
	end
end

function NPC_Meta:FindXenFaction()
	return {"monster_alien_slave","monster_alien_grunt","monster_alien_controller","monster_nihilanth","monster_bullchicken","monster_barnacle","monster_bloater","monster_flyer","monster_gargantua","monster_houndeye","monster_ichthyosaur","monster_snark","monster_tentacle"}
end

function NPC_Meta:FindAntlionFaction()
	return {"npc_antlion","npc_antlionguard","npc_antlion_worker"}
end

function NPC_Meta:FindMilitaryFaction()
	return {"monster_human_grunt","monster_grunt_repel","monster_human_grunt_dead","monster_apache","monster_osprey","monster_human_grunt_ally","monster_human_grunt_ally_dead","monster_human_medic_ally","monster_human_torch_ally","monster_recruit","monster_drillsergeant","monster_sentry","monster_human_sergent"}
end

function NPC_Meta:FindCombineFaction()
	return {"npc_combine_camera","npc_combine_s","npc_combinedropship","npc_combinegunship","npc_cscanner","npc_clawscanner","npc_helicopter","npc_strider","npc_metropolice","npc_hunter","npc_breen","npc_manhack","npc_stalker","npc_rollermine","npc_turret_ground","npc_turret_floor","npc_turret_ceiling"}
end

function NPC_Meta:FindRebelFaction()
	return {"monster_barney","monster_scientist","npc_citizen","npc_alyx","npc_barney","npc_kleiner","npc_eli","npc_magnusson","npc_mossman","npc_vortigaunt","npc_monk","npc_dog"}
end

function NPC_Meta:FindZombieFaction()
	return {"monster_headcrab","monster_babycrab","monster_zombie","npc_zombie","npc_poisonzombie","npc_fastzombie","npc_zombie_torso","npc_fastzombie_torso","npc_zombine","npc_headcrab_fast","npc_headcrab_black","npc_headcrab"}
end

function ENT_Meta:CPT_LookAtPosition(pos,parameters,speed,reverse)
	local pos = pos or Vector(0,0,0)
	local reverse = reverse or false
	local parameters = parameters or {"aim_pitch","aim_yaw"}
	if parameters == nil then
		parameters = {"aim_pitch","aim_yaw"}
	end
	local speed = speed or 10
	local selfpos = self:GetPos() +self:OBBCenter()
	local selfang = self:GetAngles()
	local targetang
	if reverse == false then
		targetang = (pos -selfpos):Angle()
	else
		targetang = (pos +selfpos):Angle()
	end
	local pitch = math.AngleDifference(targetang.p,selfang.p)
	local yaw = math.AngleDifference(targetang.y,selfang.y)
	for _,v in ipairs(parameters) do
		if string_find(v,"pitch") then
			self:SetPoseParameter(v,math.ApproachAngle(self:GetPoseParameter(v),pitch,speed))
		end
		if string_find(v,"yaw") then
			self:SetPoseParameter(v,math.ApproachAngle(self:GetPoseParameter(v),yaw,speed))
		end
	end
end

function ENT_Meta:CPT_FindHeadPosition(ent,bonenames)
	if ent == nil then return self:GetPos() end
	local bone
	local foundbone = false
	local bonenames = bonenames or {"ValveBiped.Bip01_Head1","Bip01 Head","ValveBiped.Bip01_Spine4"}
	if !IsValid(ent) then return self:GetPos() end
	for _,v in pairs(bonenames) do
		local bone = ent:LookupBone(v)
		if bone && ent:GetBoneName(bone) && foundbone == false then
			bone = bone
			foundbone = true
			local pos,ang = ent:GetBonePosition(bone)
			return pos
		else
			return self:CPT_FindCenter(ent)
		end
	end
	if foundbone == false || bone == nil then
		return self:CPT_FindCenter(ent)
	end
end

function ENT_Meta:CPT_FindNearest(ent)
	return self:NearestPoint(ent:GetPos())
end

function ENT_Meta:CPT_FindDistance(ent)
	return self:GetPos():Distance(ent:GetPos())
end

function ENT_Meta:CPT_FindDistanceToPos(startpos,endpos)
	return startpos:Distance(endpos)
end

function ENT_Meta:CPT_FindCenterDistance(ent)
	return self:GetPos():Distance(self:CPT_FindCenter(ent))
end

function WPN_Meta:OwnerUsingWeapon()
	if IsValid(self) && IsValid(self.Owner) && IsValid(self.Owner:GetActiveWeapon()) && self.Owner:GetActiveWeapon() == self then
		return true
	end
	return false
end

function PLY_Meta:CPT_FindCenterDistance(ent)
	return self:GetPos():Distance(ent:GetPos() +ent:OBBCenter())
end

function ENT_Meta:CPT_FindCenter(ent)
	if ent == nil then
		ent = self
	end
	if !IsValid(ent) then return self:GetPos() end
	return ent:GetPos() +ent:OBBCenter()
end

function NPC_Meta:CPT_PlaySound(_Sound,_SoundLevel,_SoundVolume,_SoundPitch,_UseDotPlay)
	if self.IsSLVBaseNPC == true then return self:slvPlaySound(_Sound) end
	if !self.CanPlaySounds then return end
	-- if self.tbl_Sentences[_Sound] then
	-- 	self:PlaySoundName(_Sound,_SoundLevel,_SoundPitch)
	-- 	return
	-- end
	if !self.tbl_Sounds[_Sound] then return end
	local _SelectSound,__Sound = self:CPT_CreatePlaySound(_Sound,_SoundLevel,_SoundPitch,_UseDotPlay)
	if _UseDotPlay then self:OnPlaySound(__Sound,_Sound) return end
	_SoundLevel = _SoundLevel or 80
	_SoundPitch = _SoundPitch or 100
	_SoundVolume = _SoundVolume or 90
	_SelectSound:SetSoundLevel(_SoundLevel)
	if self.CurrentSound != nil then
		self.CurrentSound:Stop()
	end
	_SelectSound:Play()
	self.CurrentSound = _SelectSound
	_SelectSound:ChangePitch(_SoundPitch *GetConVarNumber("host_timescale"),0)
	_SelectSound:ChangeVolume(_SoundVolume,0)
	self.CurrentPlayingSound = __Sound
	self:OnPlaySound(__Sound,_Sound)
	return __Sound
end

function WPN_Meta:CPT_CreatePlaySound(_Sound,_SoundLevel,_SoundPitch,_UseDotPlay)
	local __Sound
	local _SoundLevel = _SoundLevel or 80
	local _SoundPitch = _SoundPitch or 100
	local sndtype = type(_Sound)
	if sndtype == "string" then
		__Sound = _Sound
	elseif sndtype == "table" then
		__Sound = self.tbl_Sounds[_Sound][math.random(1,#self.tbl_Sounds[_Sound])]
	end
	local final_snd
	if _UseDotPlay then
		final_snd = sound.Play(__Sound,self:GetPos(),_SoundLevel,_SoundPitch *GetConVarNumber("host_timescale"))
	else
		final_snd = CreateSound(self,__Sound)
		final_snd:SetSoundLevel(_SoundLevel)
		final_snd:Play()
		final_snd:ChangePitch(_SoundPitch *GetConVarNumber("host_timescale"),0)
		final_snd:ChangeVolume(90,0)
	end
	return __Sound
end

function NPC_Meta:CPT_SimplePlaySound(_Sound,_SoundLevel,_SoundPitch,_UseDotPlay)
	local _SoundLevel = _SoundLevel or 80
	local _SoundPitch = _SoundPitch or 100
	if _UseDotPlay then
		sound.Play(_Sound,self:GetPos(),_SoundLevel,_SoundPitch *GetConVarNumber("host_timescale"))
	else
		playsound = CreateSound(self,_Sound)
		playsound:SetSoundLevel(_SoundLevel)
		if self.CurrentSound != nil then
			self.CurrentSound:Stop()
		end
		playsound:Play()
		playsound:ChangePitch(_SoundPitch *GetConVarNumber("host_timescale"),0)
		playsound:ChangeVolume(90,0)
	end
	self:OnPlaySound(_Sound,nil)
end

function NPC_Meta:CPT_CreatePlaySound(_Sound,_SoundLevel,_SoundPitch,_UseDotPlay)
	local sndtype = type(self.tbl_Sounds[_Sound])
	local __Sound
	if sndtype == "string" then
		__Sound = self.tbl_Sounds[_Sound]
	else
		__Sound = self.tbl_Sounds[_Sound][math.random(1,#self.tbl_Sounds[_Sound])]
	end
	if self.SoundDirectory != nil then
		__Sound = self.SoundDirectory .. __Sound
	end
	local final_snd
	if _UseDotPlay then
		final_snd = sound.Play(__Sound,self:GetPos(),_SoundLevel,_SoundPitch *GetConVarNumber("host_timescale"))
	else
		final_snd = CreateSound(self,__Sound)
	end
	return final_snd,__Sound
end

function NPC_Meta:Kill()
	self:SetHealth(0)
	self:TakeDamage(999999999,self,self)
end

function NPC_Meta:CPT_CreateDamage(ent,dmg,attacker,dmgtype)
	local dmginfo = DamageInfo()
	dmginfo:SetDamage(dmg)
	dmginfo:SetAttacker(attacker)
	dmginfo:SetInflictor(attacker)
	dmginfo:SetDamageType(dmgtype)
	dmginfo:SetDamagePosition(ent:NearestPoint(attacker:GetPos() +attacker:OBBCenter()))
	ent:TakeDamageInfo(dmginfo)
end

function NPC_Meta:CPT_MoveToPosition(pos,type)
	local tr = util.TraceLine({
		start = pos +Vector(0,0,100),
		endpos = pos -Vector(0,0,100),
		filter = self
	})
	pos = tr.HitPos
	local dist = self:GetPos():Distance(pos)
	tr = util.TraceLine({
		start = self:GetPos() +Vector(0,0,10),
		endpos = pos +Vector(0,0,10),
		filter = self
	})
	if tr.Hit then
		dist = self:GetPos():Distance(tr.HitPos) -self:OBBMaxs().y
	end
	-- self:SetLastPosition(self:GetPos() +(pos -self:GetPos()):GetNormal() *dist)
	self:TASKFUNC_LASTPOSITION(self:GetPos() +(pos -self:GetPos()):GetNormal() *dist,type)
end

-- if SERVER then
	-- hook.Add("Think","tempthink",function()
		-- for _,v in ipairs(ents.GetAll()) do
			-- if v:GetClass() == "npc_cscanner" then
				-- v:Remove()
			-- end
		-- end
	-- end)
-- end

function util.ShakeWorld(pos,intensity,time,dist,usesound) -- I just find this easier to remember on my part
	if usesound != nil && usesound == true then
		sound.Play("ambient/machines/thumper_hit.wav",pos,95,100)
	end
	util.ScreenShake(pos,intensity,100,time,dist)
end

function WPN_Meta:PlayerChat(text)
	for _,v in ipairs(player.GetAll()) do
		v:ChatPrint(tostring(text))
	end
end

function NPC_Meta:PlayerChat(text)
	for _,v in ipairs(player.GetAll()) do
		v:ChatPrint(tostring(text))
	end
end

function ENT_Meta:PlayerChat(text)
	for _,v in ipairs(player.GetAll()) do
		v:ChatPrint(tostring(text))
	end
end

function ENT_Meta:CreateTestingBlock(pos,time,invis)
	if !IsValid(self.testBlock) then
		self.testBlock = ents.Create("prop_dynamic")
		self.testBlock:SetModel("models/hunter/blocks/cube025x025x025.mdl")
		self.testBlock:SetPos(pos)
		self.testBlock:SetColor(Color(0,255,89,255))
		self.testBlock:Spawn()
		if !invis then
			local glow = ents.Create("light_dynamic")
			glow:SetKeyValue("_light","0 255 89 200")
			glow:SetKeyValue("brightness","2")
			glow:SetKeyValue("distance","150")
			glow:SetKeyValue("style","0")
			glow:SetPos(self.testBlock:GetPos() +self.testBlock:OBBCenter())
			glow:SetParent(self.testBlock)
			glow:Spawn()
			glow:Activate()
			glow:Fire("TurnOn","",0)
			glow:DeleteOnRemove(self.testBlock)
		else
			self.testBlock:SetNoDraw(true)
		end
		local block = self.testBlock
		if time == nil then
			self.testBlock:DeleteOnRemove(self)
		end
		if time != nil then
			timer.Simple(time,function()
				if block:IsValid() then
					block:Remove()
				end
			end)
		end
		return block
	end
	-- return self
end

function NPC_Meta:StripWeapons()
	if IsValid(self:GetActiveWeapon()) then
		self:GetActiveWeapon():Remove()
	end
end

function NPC_Meta:CPT_IsFalling(max)
	local dist
	if max == nil then
		dist = 12
	else
		dist = max
	end
	-- if self:GetVelocity().z < 0 then
		-- return true
	-- else
		-- return false
	-- end
	local tracedata = {}
	tracedata.start = self:GetPos()
	tracedata.endpos = self:GetPos() -Vector(0,0,dist)
	tracedata.filter = {self}
	local tr = util.TraceLine(tracedata)
	if tr.Hit then
		return false
	else
		return true
	end
end

-- function ENT_Meta:GetClosestEntity(tbl)
	-- return self:GetEntitiesByDistance(tbl)[1]
-- end

-- function ENT_Meta:GetEntitiesByDistance(tbl)
	-- local disttbl = {}
	-- for _,v in ipairs(tbl) do
		-- if v:IsValid() then
			-- disttbl[v] = self:CPT_FindCenterDistance(v)
		-- elseif !v:IsValid() && table.HasValue(disttbl,v) then
			-- disttbl[v] = nil
			-- table.remove(disttbl,v)
		-- end
	-- end
	-- return table.SortByKey(disttbl,true)
-- end

function NPC_Meta:CPT_PlayAnimation(_Animation,facetarget,timed)
	if !self.tbl_Animations[_Animation] then return end
	local tbl = self:SelectFromTable(self.tbl_Animations[_Animation])
	if string_find(tbl,"cptseq_") then
		tbl = string.Replace(tbl,"cptseq_","")
		if facetarget == nil then facetarget = 1 end
		self:CPT_PlaySequence(tbl,facetarget)
		return
	end
	if self.IsPossessed && _Animation == "Attack" then
		facetarget = 0
	end
	self:PlayActivity(tbl,facetarget,_Animation,timed)
end

function ENT_Meta:CPT_GetSequenceID(anim)
	local tb = self:GetSequenceList()
	local i = 0
	for k,v in ipairs(tb) do
		if v == anim then
			i = k; break
		end
	end
	return i
end

-- function NPC_Meta:Alive()
-- 	return self:Health() < 0
-- end

function ENT_Meta:CPT_CreateSpriteTrail(call,ent,mat,color,att,sWid,eWid,trans)
	call = util.SpriteTrail(ent,att,color,false,sWid,eWid,trans,1 /(sWid +eWid) *0.5,mat)
	return call
end

function ENT_Meta:CPT_TranslateStringToNumber(seq)
	return self:GetSequenceInfo(self:CPT_GetSequenceID(seq)).activity
end

function GetDefaultNPCWeapon()
	return GetConVarString("gmod_npcweapon")
end

function NPC_Meta:CPT_TurnToDegree(degree,posAng,bPitch,iPitchMax) // Borrowing this from Silverlan
	if posAng then
		local sType = type(posAng)
		local angTgt
		if sType == "Vector" then angTgt = (posAng -self:GetPos()):Angle()
		else angTgt = posAng end
		local ang = self:GetAngles()
		if !degree then ang.y = angTgt.y; if bPitch then ang.p = angTgt.p end
		else
			while angTgt.y < 0 do angTgt.y = angTgt.y +360 end
			while angTgt.y > 360 do angTgt.y = angTgt.y -360 end
			local _ang = ang -angTgt
			_ang.y = math.floor(_ang.y)
			while _ang.y < 0 do _ang.y = _ang.y +360 end
			while _ang.y > 360 do _ang.y = _ang.y -360 end
			local _iDeg = degree
			if _ang.y > 0 && _ang.y <= 180 then
				if _ang.y < _iDeg then _iDeg = _ang.y end
				ang.y = ang.y -_iDeg
			elseif _ang.y > 180 then
				if 360 -_ang.y < _iDeg then _iDeg = 360 -_ang.y end
				ang.y = ang.y +_iDeg
			end
			
			if bPitch then
				iPitchMax = iPitchMax || 360
				_ang.p = math.floor(_ang.p)
				while _ang.p < 0 do _ang.p = _ang.p +360 end
				while _ang.p > 360 do _ang.p = _ang.p -360 end
				if _ang.p > 0 then
					local _iDeg = degree
					if _ang.p < 180 then
						if ang.p > -iPitchMax then
							if _ang.p < _iDeg then _iDeg = _ang.p end
							ang.p = ang.p -_iDeg
						end
					else
						if ang.p < iPitchMax then
							if 360 -_ang.p < _iDeg then _iDeg = 360 -_ang.p end
							ang.p = ang.p +_iDeg
						end
					end
				end
			end
			self:SetAngles(ang)
		end
		return
	end
	local ang = self:GetAngles()
	ang.y = ang.y +degree
	self:SetAngles(ang)
end

function NPC_Meta:CPT_GiveNPCWeapon(weapon,ismelee)
	local default = GetDefaultNPCWeapon()
	if weapon == nil then
		if default == "" then
			return
		else
			self:Give(default)
		end
	else
		self:Give(weapon)
	end
	if self.tbl_Inventory != nil then
		if ismelee then
			if self.tbl_Inventory["Melee"] != nil then
				table.insert(self.tbl_Inventory["Melee"],weapon)
			end
		else
			if self.tbl_Inventory["Primary"] != nil then
				table.insert(self.tbl_Inventory["Primary"],weapon)
			end
		end
	end
end

function ENT_Meta:CPT_StopEntityProcessing()
	self.CurrentSchedule = nil
	self.CurrentTask = nil
	self:ClearSchedule()
	self:StopMoving()
end

function NPC_Meta:CPT_StopProcessing()
	self.CurrentSchedule = nil
	self.CurrentTask = nil
	self:CPT_StopCompletely()
	self:ClearSchedule()
	self:StopMoving()
end

function NPC_Meta:CPT_PlaySequence(sequence,animrate)
	if not sequence then return end
	if self.bInSchedule then return end
	if self.IsPlayingSequence then return end
	self:CPT_StopCompletely()
	self.bInSchedule = true
	self.IsPlayingSequence = true
	self.CanChaseEnemy = false
	self:SetNPCState(NPC_STATE_SCRIPT)
	if istable(sequence) then
		if #sequence < 1 then return end
		sequence = tostring(table.Random(sequence))
	end
	if type(sequence) == "number" then
		sequence = self:CPT_TranslateNumberToString(sequence)
	end
	if animrate == nil then
		animrate = 1
	end
	self:SetPlaybackRate(animrate)
	local animid = self:LookupSequence(sequence)
	self:ResetSequence(animid)
	self:ResetSequenceInfo()
	self:SetCycle(0)
	self:SetNPCState(NPC_STATE_SCRIPT)
	self:SetPlaybackRate(animrate)
	self.NextAnimT = CurTime() +self:CPT_AnimationLength(sequence,true) /animrate
	self.CurrentSequence = animid
	timer.Simple(self:CPT_AnimationLength(sequence,true) /animrate,function()
		if IsValid(self) then
			self.bInSchedule = false
			self.IsPlayingSequence = false
			self.CanChaseEnemy = true
			self:SetNPCState(NPC_STATE_NONE)
		end
	end)
end

function NPC_Meta:CPT_PlayActivity_Fly(activity,usetime)
	if usetime then
		if CurTime() < self.NextAnimT then return end
	end
	if type(activity) == "number" then
		activity = activity
	else
		activity = self:CPT_TranslateStringToNumber(activity)
	end
	if activity == nil then return end
	self:ClearSchedule()
	self:RestartGesture(activity)
	self.CurrentAnimation = activity
	self:MaintainActivity()
	self.NextAnimT = CurTime() +self:CPT_AnimationLength(activity)
	return activity
end

function NPC_Meta:CPT_StopMovement()
	self:ClearSchedule()
	self:StopMoving()
	self:StopMoving()
	if self:GetMoveType() == MOVETYPE_FLY then
		self:SetLocalVelocity(Vector(0,0,0))
	end
end

function NPC_Meta:CPT_StopCompletely()
	self:StartEngineTask(GetTaskID("TASK_RESET_ACTIVITY"),0)
	self:ClearSchedule()
	self:StopMoving()
	self:StopMoving()
	self.bInSchedule = false
	self.IsAttacking = false
	self.IsRangeAttacking = false
	self.IsLeapingAttacking = false
	self.IsPlayingActivity = false
	self.IsPlayingSequence = false
	self.CurrentAnimation = nil
	self.CurrentSchedule = nil
	if self:GetMoveType() == MOVETYPE_FLY then
		self:SetLocalVelocity(Vector(0,0,0))
	end
end

function NPC_Meta:CPT_AnimationLength(activity,seq)
	if activity == nil then return end
	if type(activity) == "string" && seq != true then
		activity = self:CPT_TranslateStringToNumber(activity)
	end
	if seq then
		return self:SequenceDuration(activity) /self:GetPlaybackRate()
	end
	return self:SequenceDuration(self:SelectWeightedSequence(activity))
end

function PLY_Meta:CPT_ViewModel_AnimationLength(activity,seq)
	if type(activity) == "string" && seq != true then
		activity = self:CPT_TranslateStringToNumber(activity)
	end
	if seq then
		return self:SequenceDuration(activity)
	end
	return self:GetViewModel():SequenceDuration(self:GetViewModel():SelectWeightedSequence(activity))
end

function WPN_Meta:CPT_AnimationLength(activity,seq)
	if type(activity) == "string" && seq != true then
		activity = self:CPT_TranslateStringToNumber(activity)
	end
	if seq then
		return self:SequenceDuration(activity)
	end
	return self:SequenceDuration(self:SelectWeightedSequence(activity))
end

function ENT_Meta:CPT_CheckCanSee(ent,cone)
	if ent == nil then return end
	return self:Visible(ent) && (self:GetForward():Dot(((ent:GetPos() +ent:OBBCenter()) -self:GetPos() +self:GetForward() *15):GetNormalized()) > math.cos(math.rad(cone)))
end

function ENT_Meta:CPT_FindInCone(ent,cone,slvbasebackwardscompatibility)
	if ent == nil then return end
	if type(ent) == "Vector" then
		return (self:GetForward():Dot(((ent) -self:GetPos() +self:GetForward() *15):GetNormalized()) > math.cos(math.rad(cone)))
	else	
		return (self:GetForward():Dot(((ent:GetPos() +ent:OBBCenter()) -self:GetPos() +self:GetForward() *15):GetNormalized()) > math.cos(math.rad(cone)))
	end
end

function PLY_Meta:CPT_FindInCone(ent,cone)
	return (self:GetForward():Dot(((ent:GetPos() +ent:OBBCenter()) -self:GetPos() +self:GetForward() *15):GetNormalized()) > math.cos(math.rad(cone)))
end

function ENT_Meta:CPT_IsFriendlyToMe(ent)
	if self:Disposition(ent) == D_LI || self:Disposition(ent) == D_NU then
		return true
	end
	return false
end

function ENT_Meta:CPT_ApplyParticle(pS,pA)
	ParticleEffectAttach(pS,PATTACH_POINT_FOLLOW,self,pA)
end

function NPC_Meta:GetHealth()
	return self:Health()
end

function PlayGlobalSound(snd)
	for _,v in ipairs(player.GetAll()) do
		-- local playsnd = CreateSound(v,snd)
		-- playsnd:SetSoundLevel(0.2)
		-- playsnd:Play()
		v:EmitSound(snd,0.2,100)
	end
end

function PlaySentenceSoundTable(tb,isglobal,ent,vol)
	/*
		Example:
		tb = {
			[1] = {snd="vo/your.wav",t=0},
			[2] = {snd="vo/mom.wav",t=0.7},
			[3] = {snd="vo/is.wav",t=1.2},
			[4] = {snd="vo/gay.wav",t=1.6},
		}
	*/
	local function PlaySentenceSound(i)
		if isglobal then
			PlayGlobalSound(tb[i].snd)
		else
			if IsValid(ent) then
				ent:EmitSound(tb[i].snd,vol,100)
			end
		end
	end
	for i = 1, #tb do
		timer.Simple(tb[i].t,function() PlaySentenceSound(i) end)
	end
end

function Color2Byte(color)
	return bit.lshift(math.floor(color.r *7 /255),5) +bit.lshift(math.floor(color.g *7 /255),2) +math.floor(color.b *3 /255)
end

function Color8Bit2Color(inputbit)
	return Color(bit.rshift(inputbit,5) *255 /7,bit.band(bit.rshift(inputbit,2),0x07) *255 /7,bit.band(inputbit,0x03) *255 /3)
end

function NPC_Meta:CPT_PlayNPCGesture(seq,layer,playbackrate) // You should always set layer to '2' or below. I recommend only '2' though
	if seq == nil then return end
	if layer == nil then layer = 2 end
	if playbackrate == nil then playbackrate = 1 end
	local gest = self:AddGestureSequence(self:LookupSequence(seq))
	self:SetLayerPriority(gest,layer)
	self:SetLayerPlaybackRate(gest,playbackrate)
end

function NPC_Meta:CPT_AttackFinish(seq,time)
	if !seq then
		local anim = self.CurrentAnimation
		local animtime
		if anim == nil then
			animtime = 0
		else
			animtime = self:CPT_AnimationLength(anim)  /self:GetPlaybackRate()
		end
		if time != nil then
			animtime = time
		end
		-- print(animtime)
		timer.Simple(animtime +0.02,function()
			if IsValid(self) then
				self.IsAttacking = false
				self.IsRangeAttacking = false
				-- self.IsLeapAttacking = false
				self.HasStoppedMovingToAttack = false
				self:CustomOnAttackFinish(anim)
			end
		end)
	elseif seq then
		local anim = self.CurrentSequence
		local animtime
		if anim == nil then
			animtime = 0
		else
			animtime = self:SequenceDuration(anim)  /self:GetPlaybackRate()
		end
		if time != nil then
			animtime = time
		end
		timer.Simple(animtime +0.02,function()
			if IsValid(self) then
				self.IsAttacking = false
				self.IsRangeAttacking = false
				-- self.IsLeapAttacking = false
				self.HasStoppedMovingToAttack = false
				self:CustomOnAttackFinish(anim)
			end
		end)
	end
end

function ENT_Meta:HasSWEP()
	if self:GetActiveWeapon() != nil then return true else return false end
end

function CreateUndo(ent,entname,theplayer)
	undo.Create(entname)
		undo.AddEntity(ent)
		if theplayer != nil then
			undo.SetPlayer(theplayer)
		end
		undo.SetCustomUndoText("Undone " .. entname)
	undo.Finish()
end

function NPC_Meta:DebugChat(text)
	for _,v in ipairs(player.GetAll()) do
		v:ChatPrint(text)
	end
end

function ENT_Meta:IsNextbot() -- Backwards compatibility
	return self:IsNextBot()
end

function ENT_Meta:IsProp()
	return string_find(self:GetClass(),"prop")
end

function NPC_Meta:GetSoundScriptLength(scriptName,scriptFile,scriptUseGAMEPath) // ("!HG_ALERT1","scripts/vj_hlr_sentences.txt",true) = finds the script file in /scripts/ | ("!HG_ALERT1","vjbase/hlr/vj_hlr_sentences.txt",false) = finds the script file in your /data/ folder
	scriptName = string.Replace(scriptName,"!","")
	if scriptFile == nil then
		scriptFile = "scripts/sentences.txt"
	end
	if scriptUseGAMEPath == nil then
		scriptUseGAMEPath = true
	end
	local scriptFile = file.Read(scriptFile,scriptUseGAMEPath) // "scripts/vj_hlr_sentences.txt"
	local scriptSenStart = string_find(scriptFile,scriptName)
	if !scriptSenStart then return 0 end
	local scriptLenStart = string_find(scriptFile,"Len ",scriptSenStart) +4
	local scriptLenEnd = string_find(scriptFile,"}",scriptLenStart) -1
	local scriptLenEndB = string_find(scriptFile,"%s",scriptLenStart)
	if scriptLenEndB && scriptLenEndB < scriptLenEnd then
		scriptLenEnd = scriptLenEndB -1
	end
	return tonumber(string.sub(scriptFile,scriptLenStart,scriptLenEnd))
end

function NPC_Meta:PlaySoundScript(scriptName,scriptListener,onScriptEnd,scriptSpeaker,scriptRadius,scriptVolume,scriptAttenuation,scriptDoRepeat,scriptStopOthers,scriptConcurrent,scriptToActivator,scriptFile,scriptUseGAMEPath) // Credits to Silverlan. Nobody would've figured this out without him imo
	scriptSpeaker = scriptSpeaker || self
	scriptListener = scriptListener || self

	local HLScript = ents.Create("scripted_sentence")
	HLScript:SetPos(self:GetPos())
	HLScript:SetKeyValue("sentence",scriptName)
	local sSpeaker
	if scriptSpeaker:GetName() == "" then
		sSpeaker = scriptSpeaker:GetClass()
	else
		sSpeaker = scriptSpeaker:GetName()
	end
	HLScript:SetKeyValue("entity",sSpeaker)
	local sListener
	if scriptListener:GetName() != "" && !scriptListener:IsPlayer() then
		sListener = scriptListener:GetName()
	else
		sListener = scriptListener:GetClass()
	end
	HLScript:SetKeyValue("listener",sListener)
	HLScript:SetKeyValue("radius",scriptRadius || 2)
	HLScript:SetKeyValue("volume",scriptVolume || 10)
	HLScript:SetKeyValue("attenuation",scriptAttenuation || 1)
	local sFlags = 0
	if !scriptDoRepeat then
		sFlags = sFlags +1
	end
	if scriptStopOthers then
		sFlags = sFlags +4
	end
	if scriptConcurrent then
		sFlags = sFlags +8
	end
	if scriptToActivator then
		sFlags = sFlags +16
	end
	HLScript:SetKeyValue("spawnflags",sFlags)
	if onScriptEnd then
		timer.Simple(self:GetSoundScriptLength(scriptName),function()
			if IsValid(self) then
				onScriptEnd()
			end
		end)
	end
	HLScript:Spawn()
	HLScript:Activate()
	HLScript:Fire("BeginSentence","",0)
	HLScript:Fire("kill","",0.1)
	self:PlayerChat("Created sentence " .. scriptName)
end

function PHYS_Meta:SetAngleVelocity(ang)
	self:AddAngleVelocity(self:GetAngleVelocity() *-1 +ang)
end