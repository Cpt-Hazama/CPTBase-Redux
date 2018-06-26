if !CPTBase then return end
-------------------------------------------------------------------------------------------------------------------
local ENT_Meta = FindMetaTable("Entity")
local NPC_Meta = FindMetaTable("NPC")
local PLY_Meta = FindMetaTable("Player")
local WPN_Meta = FindMetaTable("Weapon")

if (SERVER) then
	NPC_STATE_LOST = 8
	MOVETYPE_SWIM = 12
	DMG_FROST = 10
	util.AddNetworkString("cpt_ControllerView")
end

SNDDURATION_TABLE = {}

function NPC_Meta:GetNPCEnemy()
	if self.NPC_Enemy == nil then
		return nil
	elseif self.NPC_Enemy != nil && self.NPC_Enemy:IsValid() then
		return self.NPC_Enemy
	elseif self.NPC_Enemy != nil && !self.NPC_Enemy:IsValid() then
		return nil
	end
end

function NPC_Meta:SetNPCEnemy(ent)
	self.NPC_Enemy = ent
end

function util.DoFrostDamage(dmg,ent,attacker)
	local function DoDamage()
		if ent:IsValid() then
			if ent:Health() <= 0 then return end
			local dmginfo = DamageInfo()
			dmginfo:SetDamage(dmg)
			if attacker:IsValid() then
				dmginfo:SetAttacker(attacker)
				dmginfo:SetInflictor(attacker)
			end
			dmginfo:SetDamageType(DMG_GENERIC)
			if attacker:IsValid() then
				dmginfo:SetDamagePosition(ent:NearestPoint(attacker:GetPos() +attacker:OBBCenter()))
			end
			ent:TakeDamageInfo(dmginfo)
			for i = 0,ent:GetBoneCount() -1 do
				ParticleEffect("cpt_projectile_freeze_explode",ent:GetBonePosition(i),Angle(0,0,0),nil)
			end
			if ent:Health() <= 0 then
				sound.Play("physics/glass/glass_impact_bullet4.wav",ent:GetPos(),70,100)
			else
				sound.Play("ambient/materials/footsteps_glass1.wav",ent:GetPos(),40,140)
			end
		end
	end
	timer.Create("CPTBase_DoFrostDamage_" .. math.Rand(1,99999),1,5,function() DoDamage() end)
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

function ENT_Meta:DropNPCWeapon(pos,ang)
	if self:GetActiveWeapon() != NULL then
		local wep = ents.Create(self:GetActiveWeapon():GetClass())
		wep:SetPos(pos)
		wep:SetAngles(ang)
		wep:Spawn()
	end
end

function NPC_Meta:CreateRagdolledNPC(vel,caller)
	if self.CPTBase_NPC != true then return end
	local velocity = vel or Vector(-300,0,300)
	local mdl = self:GetModel()
	local phy = string.Replace(mdl,".mdl",".phy")
	if !file.Exists(phy,"GAME") then return end // Checks if the model has physics
	self.Ragdoll_CPT = ents.Create("prop_ragdoll")
	self.Ragdoll_CPT:SetModel(self:GetModel())
	self.Ragdoll_CPT:SetPos(self:GetPos())
	self.Ragdoll_CPT:SetAngles(self:GetAngles())
	self.Ragdoll_CPT:Spawn()
	self.Ragdoll_CPT:Activate()
	self.IsRagdolled = true
	self:SetPersistent(true)
	self:SetCollisionGroup(1)
	self.Ragdoll_CPT:SetSkin(self:GetSkin())
	for i = 0,18 do
		self.Ragdoll_CPT:SetBodygroup(i,self:GetBodygroup(i))
	end
	self.Ragdoll_CPT:SetColor(self:GetColor())
	self.Ragdoll_CPT:SetMaterial(self:GetMaterial())
	self.Ragdoll_CPT:SetCollisionGroup(1)
	self:SetColor(255,255,255,0)
	if self:IsOnFire() then
		self.Ragdoll_CPT:Ignite(math.random(8,10),1)
	end
	self.Ragdoll_CPT:SetVelocity(self:GetVelocity())
	for i = 1,128 do
		local bonephys = self.Ragdoll_CPT:GetPhysicsObjectNum(i)
		if IsValid(bonephys) then
			local bonepos,boneang = self:GetBonePosition(self.Ragdoll_CPT:TranslatePhysBoneToBone(i))
			if(bonepos) then
				bonephys:SetPos(bonepos)
				bonephys:SetAngles(boneang)
				-- bonephys:AddVelocity(velocity)
				bonephys:ApplyForceCenter(caller:GetPos() -self:GetForward() *velocity.x +self:GetRight() *velocity.y +self:GetUp() *velocity.z)
			end
		end
	end
	timer.Simple(self.RagdollRecoveryTime,function()
		if self:IsValid() then
			if self.Ragdoll_CPT:IsValid() then
				self:SetClearPos(self.Ragdoll_CPT:GetPos())
				self:SetColor(self.Ragdoll_CPT:GetColor())
				self.Ragdoll_CPT:Remove()
				self:SetNoDraw(false)
				self:DrawShadow(true)
				self.IsRagdolled = false
				self.bInSchedule = false
				self:OnRagdollRecover()
			else
				self:SetClearPos(self:GetPos())
				self:SetColor(255,255,255,255)
				self:SetNoDraw(false)
				self:DrawShadow(true)
				self.IsRagdolled = false
				self.bInSchedule = false
				self:OnRagdollRecover()
			end
			self:SetCollisionGroup(9)
			self:SetPersistent(false)
			self:UpdateFriends()
			self:UpdateEnemies()
		end
	end)
end

function NPC_Meta:SetClearPos(origin) // Credits to Silverlan
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

hook.Add("Think","CPTBase_MutationEffects",function()
	for _,v in ipairs(ents.GetAll()) do
		if v:IsNPC() && v.CPTBase_NPC == true then
			if v.HasMutated == true then
				if CurTime() > v.NextMutT then
					v:StopParticles()
					for i = 0, v:GetBoneCount() -1 do
						if v:GetBonePosition(i) != v:GetPos() then
							ParticleEffect(v.MutationEmbers,v:GetBonePosition(i),Angle(0,0,0),v)
							ParticleEffect(v.MutationGlow,v:GetBonePosition(i),Angle(0,0,0),v)
						end
					end
					v.NextMutT = CurTime() +0.4
				end
			end
		end
	end
end)

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

function util.CreateSplashDamage(pos,dmg,dmgtype,dist,attacker)
	for _,v in ipairs(ents.FindInSphere(pos,dist)) do
		if v:IsValid() && (v:IsNPC() || v:IsPlayer()) && attacker:Disposition(v) != D_LI && v != attacker then
			local dmgpos = v:NearestPoint(attacker:GetPos() +attacker:OBBCenter())
			local dmginfo = DamageInfo()
			dmginfo:SetDamage(dmg)
			dmginfo:SetAttacker(attacker)
			dmginfo:SetInflictor(attacker)
			dmginfo:SetDamageType(dmgtype)
			dmginfo:SetDamagePosition(dmgpos)
			v:TakeDamageInfo(dmginfo)
		end
	end
end

function util.CreateCustomExplosion(pos,dmg,dist,attacker,effect,snd,silent)
	local pos = pos or Vector(0,0,0)
	local dmg = dmg or 60
	local dist = dist or 300
	if effect != false then
		effect = "mininuke_explosion"
	end
	local snd = snd or "weapons/explode" .. math.random(3,5) .. ".wav"
	local silent = silent or false
	if silent != true then
		if effect != false then
			ParticleEffect(effect,pos,Angle(0,0,0),nil)
		end
		sound.Play(snd,pos,110,100)
		sound.Play("weapons/debris" .. math.random(1,3) .. ".wav",pos,95,100)
	end
	util.BlastDamage(attacker,attacker,pos,dist,dmg)
	util.ScreenShake(pos,5,dmg,math.Clamp(dmg /100,0.1,2),dist *2)
end

function ENT_Meta:GetClosestPoint(ent)
	local epos = ent:NearestPoint(self:GetPos() +ent:OBBCenter())
	local spos = self:NearestPoint(ent:GetPos() +self:OBBCenter())
	epos.z = ent:GetPos().z
	spos.z = self:GetPos().z
	return epos:Distance(spos)
	-- return self:NearestPoint(ent:GetPos() +self:OBBCenter()):Distance(ent:NearestPoint(self:GetPos() +ent:OBBCenter()))
end

function NPC_Meta:PlayNPCSentence(sentence)
	local snd = self:SelectFromTable(self.tbl_Sentences[sentence])
	self:CreateNPCSentence(snd)
end

function NPC_Meta:PlayTimedSound(snd,time,sndlvl,pitch)
	sndlvl = sndlvl or 75
	pitch = pitch or 100
	timer.Simple(time,function()
		if self:IsValid() then
			sound.Play(snd,self:GetPos(),sndlvl,pitch *GetConVarNumber("host_timescale"))
		end
	end)
end

function WPN_Meta:CreateLoopSound(sound,lvl,pitch,volume)
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

function ENT_Meta:CreateLoopSound(sound,lvl,pitch,volume)
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

function NPC_Meta:CheckConfidence(ent)
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

function WPN_Meta:PlayWeaponAnimation(anim,speed,loop)
	if type(anim) == "number" then
		return self.Weapon:SendWeaponAnim(anim)
	elseif type(anim) == "string" then
		return self:PlayWeaponSequence(anim,speed,loop)
	end
end

function NPC_Meta:SoundCreate(snd,vol,pitch)
	local pitch = pitch or 100
	if self.tbl_Sounds[snd] != nil then
		snd = self:SelectFromTable(self.tbl_Sounds[snd])
	end
	return sound.Play(snd,self:GetPos(),vol,pitch *GetConVarNumber("host_timescale"),1)
end

function WPN_Meta:SoundCreate(snd,vol,pitch)
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

function WPN_Meta:PlayWeaponAnimation(tbl)
	if self.tbl_Animations[tbl] == nil then return end
	self.Weapon:SendWeaponAnim(self.tbl_Animations[tbl][math.random(1,#self.tbl_Animations[tbl])])
end

function NPC_Meta:GetCurrentAnimation()
	return self:GetSequenceName(self:GetSequence())
end

function NPC_Meta:GetPlayedAnimation()
	-- return self.CurrentAnimation
	return self:GetSequenceName(self.CurrentAnimation)
end

function ENT_Meta:GetFaction()
	if self.Faction == nil then
		return "NO_FACTION"
	else
		return self.Faction
	end
end

hook.Add("OnEntityCreated","cpt_CreateVanillaRelationships",function(ent)
	local canrun = false
	if ent:IsNPC() then
		if table.HasValue(ent:FindAntlionFaction(),ent:GetClass()) then
			ent.Faction = "FACTION_ANTLION"
			canrun = true
		elseif table.HasValue(ent:FindMilitaryFaction(),ent:GetClass()) then
			ent.Faction = "FACTION_MILITARY"
			canrun = true
		elseif table.HasValue(ent:FindCombineFaction(),ent:GetClass()) then
			ent.Faction = "FACTION_COMBINE"
			canrun = true
		elseif table.HasValue(ent:FindRebelFaction(),ent:GetClass()) then
			ent.Faction = "FACTION_PLAYER"
			canrun = true
		elseif table.HasValue(ent:FindXenFaction(),ent:GetClass()) then
			ent.Faction = "FACTION_XEN"
			canrun = true
		elseif table.HasValue(ent:FindZombieFaction(),ent:GetClass()) then
			ent.Faction = "FACTION_ZOMBIE"
			canrun = true
		end
		if canrun == true then
			for _,v in ipairs(ents.GetAll()) do
				if v:IsNPC() /*&& v:Disposition(self) == D_NU*/ && v.Faction != nil then
					if ent.Faction != v.Faction && v:Disposition(ent) != D_HT then
						v:SetRelationship(ent,D_HT)
					elseif ent.Faction == v.Faction && v:Disposition(ent) != D_LI then
						v:SetRelationship(ent,D_LI)
					end
				end
			end
		end
	end
end)

function ENT_Meta:SetRelationship(ent,value,isplayer)
	self:AddEntityRelationship(ent,value,99)
	if !ent:IsPlayer() then
		ent:AddEntityRelationship(self,value,99)
	end
	if (value == D_HT) && self.tbl_EnemyMemory != nil && !table.HasValue(self.tbl_EnemyMemory,ent) then
		table.insert(self.tbl_EnemyMemory,ent)
		-- local oldcount = self.EnemyMemoryCount
		-- local lastenemy = self:GetEnemy()
		-- local newenemy = ent
		-- self.EnemyMemoryCount = self.EnemyMemoryCount +1
		-- if self.EnemyMemoryCount > 0 && lastenemy != newenemy then
			-- self:OnFoundEnemy(self.EnemyMemoryCount,oldcount,newenemy)
			-- return
		-- end
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

function NPC_Meta:SetMovementAnimation(_Animation)
	local anim
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

function NPC_Meta:GetMovementAnimation()
	return self:GetMovementActivity()
end

function ENT_Meta:LookAtPosition(pos,parameters,speed)
	local pos = pos or Vector(0,0,0)
	local parameters = parameters or {"aim_pitch","aim_yaw"}
	if parameters == nil then
		parameters = {"aim_pitch","aim_yaw"}
	end
	local speed = speed or 10
	local selfpos = self:GetPos() +self:OBBCenter()
	local selfang = self:GetAngles()
	local targetang = (pos - selfpos):Angle()
	local pitch = math.AngleDifference(targetang.p,selfang.p)
	local yaw = math.AngleDifference(targetang.y,selfang.y)
	for _,v in ipairs(parameters) do
		if string.find(v,"pitch") then
			self:SetPoseParameter(v,math.ApproachAngle(self:GetPoseParameter(v),pitch,speed))
		end
		if string.find(v,"yaw") then
			self:SetPoseParameter(v,math.ApproachAngle(self:GetPoseParameter(v),yaw,speed))
		end
	end
end

function ENT_Meta:FindHeadPosition(ent,bonenames)
	local bone
	local foundbone = false
	local bonenames = bonenames or {"ValveBiped.Bip01_Head1","Bip01 Head","ValveBiped.Bip01_Spine4"}
	if !self:IsValid() then return end
	if !ent:IsValid() then return end
	for _,v in pairs(bonenames) do
		local bone = ent:LookupBone(v)
		if bone && ent:GetBoneName(bone) && foundbone == false then
			bone = bone
			foundbone = true
			local pos,ang = ent:GetBonePosition(bone)
			return pos
		else
			return self:FindCenter(ent)
		end
	end
	if foundbone == false || bone == nil then
		return self:FindCenter(ent)
	end
end

function ENT_Meta:FindNearest(ent)
	return self:NearestPoint(ent:GetPos())
end

function ENT_Meta:FindDistance(ent)
	return self:GetPos():Distance(ent:GetPos())
end

function ENT_Meta:FindDistanceToPos(startpos,endpos)
	return startpos:Distance(endpos)
end

function ENT_Meta:FindCenterDistance(ent)
	return self:GetPos():Distance(self:FindCenter(ent))
end

function ENT_Meta:FindCenter(ent)
	return ent:GetPos() +ent:OBBCenter()
end

function NPC_Meta:PlaySound(_Sound,_SoundLevel,_SoundVolume,_SoundPitch,_UseDotPlay)
	if self.IsSLVBaseNPC == true then return self:slvPlaySound(_Sound) end
	if !self.tbl_Sounds[_Sound] then return end
	local _SelectSound,__Sound = self:CreatePlaySound(_Sound,_SoundLevel,_SoundPitch,_UseDotPlay)
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

function WPN_Meta:CreatePlaySound(_Sound,_SoundLevel,_SoundPitch,_UseDotPlay)
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

function NPC_Meta:SimplePlaySound(_Sound,_SoundLevel,_SoundPitch,_UseDotPlay)
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

function NPC_Meta:CreatePlaySound(_Sound,_SoundLevel,_SoundPitch,_UseDotPlay)
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
	self:TakeDamage(99999999999999999,self)
end

function NPC_Meta:CreateDamage(ent,dmg,attacker,dmgtype)
	local dmginfo = DamageInfo()
	dmginfo:SetDamage(dmg)
	dmginfo:SetAttacker(attacker)
	dmginfo:SetInflictor(attacker)
	dmginfo:SetDamageType(dmgtype)
	dmginfo:SetDamagePosition(ent:NearestPoint(attacker:GetPos() +attacker:OBBCenter()))
	ent:TakeDamageInfo(dmginfo)
end

function NPC_Meta:MoveToPosition(pos)
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
	self:SetLastPosition(self:GetPos() +(pos -self:GetPos()):GetNormal() *dist)
	self:TASKFUNC_LASTPOSITION()
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
		v:ChatPrint(text)
	end
end

function NPC_Meta:PlayerChat(text)
	for _,v in ipairs(player.GetAll()) do
		v:ChatPrint(text)
	end
end

function NPC_Meta:IsFalling()
	if self:GetVelocity().z < 0 then
		return true
	else
		return false
	end
end

function ENT_Meta:GetClosestEntity(tbl)
	return self:GetEntitiesByDistance(tbl)[1]
end

function ENT_Meta:GetEntitiesByDistance(tbl)
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

function NPC_Meta:PlayAnimation(_Animation,facetarget,timed)
	if !self.tbl_Animations[_Animation] then return end
	local tbl = self:SelectFromTable(self.tbl_Animations[_Animation])
	if string.find(tbl,"cptseq_") then
		tbl = string.Replace(tbl,"cptseq_","")
		if facetarget == nil then facetarget = 1 end
		self:PlaySequence(tbl,facetarget)
		return
	end
	if self.IsPossessed && _Animation == "Attack" then
		facetarget = 0
	end
	self:PlayActivity(tbl,facetarget,_Animation,timed)
end

function ENT_Meta:GetSequenceID(anim)
	local tb = self:GetSequenceList()
	local i = 0
	for k,v in ipairs(tb) do
		if v == anim then
			i = k; break
		end
	end
	return i
end

function NPC_Meta:Alive()
	if self:Health() < 0 then
		return false
	else
		return true
	end
end

function ENT_Meta:TranslateStringToNumber(seq)
	return self:GetSequenceInfo(self:GetSequenceID(seq)).activity
end

function NPC_Meta:GetDefaultNPCWeapon()
	return GetConVarString("gmod_npcweapon")
end

function NPC_Meta:TurnToDegree(degree,posAng,bPitch,iPitchMax) // Borrowing this from Silverlan
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

function NPC_Meta:GiveNPCWeapon(weapon,ismelee)
	local default = self:GetDefaultNPCWeapon()
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

function NPC_Meta:FaceEnemy()
	if !IsValid(self:GetEnemy()) then return end
	self:SetTarget(self:GetEnemy())
	local _faceenemy = ai_sched_cpt.New("_faceenemy")
	_faceenemy:EngTask("TASK_FACE_TARGET",0)
	self:StartSchedule(_faceenemy)
end

function NPC_Meta:FaceTarget(ent)
	self:SetTarget(ent)
	local _faceselectedtarget = ai_sched_cpt.New("_faceselectedtarget")
	_faceselectedtarget:EngTask("TASK_FACE_TARGET",0)
	self:StartSchedule(_faceselectedtarget)
end

function ENT_Meta:StopEntityProcessing()
	self.CurrentSchedule = nil
	self.CurrentTask = nil
	self:ClearSchedule()
	self:StopMoving()
end

function NPC_Meta:StopProcessing()
	self.CurrentSchedule = nil
	self.CurrentTask = nil
	self:StopCompletely()
	self:ClearSchedule()
	self:StopMoving()
end

function NPC_Meta:PlaySequence(sequence,animrate)
	if not sequence then return end
	if self.bInSchedule then return end
	if self.IsPlayingSequence then return end
	self:StopCompletely()
	self.bInSchedule = true
	self.IsPlayingSequence = true
	self.CanChaseEnemy = false
	self:SetNPCState(NPC_STATE_SCRIPT)
	if istable(sequence) then
		if #sequence < 1 then return end
		sequence = tostring(table.Random(sequence))
	end
	local animid = self:LookupSequence(sequence)
	self:ResetSequence(animid)
	self:ResetSequenceInfo()
	self:SetCycle(0)
	self:SetNPCState(NPC_STATE_SCRIPT)
	if animrate == nil then
		animrate = 1
	end
	self:SetPlaybackRate(animrate)
	self.NextAnimT = CurTime() +self:AnimationLength(sequence,true) /animrate
	self.CurrentSequence = animid
	timer.Simple(self:AnimationLength(sequence,true) /animrate,function()
		if IsValid(self) then
			self.bInSchedule = false
			self.IsPlayingSequence = false
			self.CanChaseEnemy = true
			self:SetNPCState(NPC_STATE_NONE)
		end
	end)
end

function NPC_Meta:PlayActivity(activity,facetarget,usetime,addtime)
	local fly = false
	local usegesture = false
	local usesequence = false
	local extratime = nil
	-- if self.IsPlayingActivity then return end
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
	if usegesture == true then self:PlayNPCGesture(string.Replace(activity,"cptges_",""),2,1) return end
	if usesequence == true then self:PlaySequence(string.Replace(activity,"cptseq_",""),1) return end
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

function NPC_Meta:OnFinishedAnimation(activity) end

function NPC_Meta:PlayActivity_Fly(activity,usetime)
	if usetime then
		if CurTime() < self.NextAnimT then return end
	end
	if type(activity) == "number" then
		activity = activity
	else
		activity = self:TranslateStringToNumber(activity)
	end
	if activity == nil then return end
	self:ClearSchedule()
	self:RestartGesture(activity)
	self.CurrentAnimation = activity
	self:MaintainActivity()
	self.NextAnimT = CurTime() +self:AnimationLength(activity)
	return activity
end

function NPC_Meta:StopCompletely()
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
end

function NPC_Meta:AnimationLength(activity,seq)
	if activity == nil then return end
	if type(activity) == "string" && seq != true then
		activity = self:TranslateStringToNumber(activity)
	end
	if seq then
		return self:SequenceDuration(activity) /self:GetPlaybackRate()
	end
	return self:SequenceDuration(self:SelectWeightedSequence(activity))
end

function PLY_Meta:ViewModel_AnimationLength(activity,seq)
	if type(activity) == "string" && seq != true then
		activity = self:TranslateStringToNumber(activity)
	end
	if seq then
		return self:SequenceDuration(activity)
	end
	return self:GetViewModel():SequenceDuration(self:GetViewModel():SelectWeightedSequence(activity))
end

function WPN_Meta:AnimationLength(activity,seq)
	if type(activity) == "string" && seq != true then
		activity = self:TranslateStringToNumber(activity)
	end
	if seq then
		return self:SequenceDuration(activity)
	end
	return self:SequenceDuration(self:SelectWeightedSequence(activity))
end

function ENT_Meta:CheckCanSee(ent,cone)
	if ent == nil then return end
	if self:Visible(ent) && (self:GetForward():Dot(((ent:GetPos() +ent:OBBCenter()) -self:GetPos() +self:GetForward() *15):GetNormalized()) > math.cos(math.rad(cone))) then
		return true
	else
		return false
	end
end

function ENT_Meta:FindInCone(ent,cone)
	if ent == nil then return end
	return (self:GetForward():Dot(((ent:GetPos() +ent:OBBCenter()) -self:GetPos() +self:GetForward() *15):GetNormalized()) > math.cos(math.rad(cone)))
end

function PLY_Meta:FindInCone(ent,cone)
	return (self:GetForward():Dot(((ent:GetPos() +ent:OBBCenter()) -self:GetPos() +self:GetForward() *15):GetNormalized()) > math.cos(math.rad(cone)))
end

function NPC_Meta:GetHealth()
	return self:Health()
end

function Color2Byte(color)
	return bit.lshift(math.floor(color.r *7 /255),5) +bit.lshift(math.floor(color.g *7 /255),2) +math.floor(color.b *3 /255)
end

function Color8Bit2Color(inputbit)
	return Color(bit.rshift(inputbit,5) *255 /7,bit.band(bit.rshift(inputbit,2),0x07) *255 /7,bit.band(inputbit,0x03) *255 /3)
end

function NPC_Meta:PlayNPCGesture(seq,layer,playbackrate) // You should always set layer to '2' or below. I recommend only '2' though
	if seq == nil then return end
	if layer == nil then layer = 2 end
	if playbackrate == nil then playbackrate = 1 end
	local gest = self:AddGestureSequence(self:LookupSequence(seq))
	self:SetLayerPriority(gest,layer)
	self:SetLayerPlaybackRate(gest,playbackrate)
end

function NPC_Meta:AttackFinish(seq,time)
	if !seq then
		local anim = self.CurrentAnimation
		local animtime
		if anim == nil then
			animtime = 0
		else
			animtime = self:AnimationLength(anim)
		end
		if time != nil then
			animtime = time
		end
		-- print(animtime)
		timer.Simple(animtime +0.02,function()
			if self:IsValid() then
				self.IsAttacking = false
				self.IsRangeAttacking = false
				-- self.IsLeapAttacking = false
				self.HasStoppedMovingToAttack = false
				self:CustomOnAttackFinish()
			end
		end)
	elseif seq then
		local anim = self.CurrentSequence
		local animtime
		if anim == nil then
			animtime = 0
		else
			animtime = self:SequenceDuration(anim)
		end
		if time != nil then
			animtime = time
		end
		timer.Simple(animtime +0.02,function()
			if self:IsValid() then
				self.IsAttacking = false
				self.IsRangeAttacking = false
				-- self.IsLeapAttacking = false
				self.HasStoppedMovingToAttack = false
				self:CustomOnAttackFinish()
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

function ENT_Meta:IsNextbot()
	if self.Type == "nextbot" then return true else return false end
end

function ENT_Meta:IsProp()
	if string.find(self:GetClass(),"prop") then return true else return false end
end