AddCSLuaFile()
-------------------------------------------------------------------------------------------------------------------
local ENT_Meta = FindMetaTable("Entity")
local NPC_Meta = FindMetaTable("NPC")
local PLY_Meta = FindMetaTable("Player")
local WPN_Meta = FindMetaTable("Weapon")

CPTBase = CPTBase or {}

CPT_SPRITE_ANIMATIONS = CPT_SPRITE_ANIMATIONS or {}

CPTBase.AddSpriteAnimation = function(parentName,options)
	CPT_SPRITE_ANIMATIONS[parentName] = CPT_SPRITE_ANIMATIONS[parentName] or {}
	
	local seq = {
		name = options.Sequence,
		activity = options.Activity or -1,
		dir = options.Dir,
		multiDirection = options.MultiDirection or false,
		frames = options.Frames,
		fps = options.FPS or 15,
		loop = options.Loop or false,
		events = options.Events or nil,
		flipSet = options.FlipSet or nil
	}
	
	CPT_SPRITE_ANIMATIONS[parentName][options.Sequence] = seq

	print("CPTBase: Added sprite animation " .. options.Sequence .. " to " .. parentName)
end

local cptMat = Material
CPTBase.PlaySpriteAnimation = function(self,parentName,seqName)
	local currentAnim = nil
	if isnumber(seqName) then
		for _,v in pairs(CPT_SPRITE_ANIMATIONS[parentName]) do
			if v.activity == seqName then
				currentAnim = v
				break
			end
		end
	else
		currentAnim = CPT_SPRITE_ANIMATIONS[parentName][seqName]
	end

	if !currentAnim then
		print("Animation not found!")
		return false
	end

	local animFrames = currentAnim.frames
	local numFrames = #animFrames
	local multiDir = currentAnim.multiDirection
	local dir = nil
	if multiDir then
		dir = self:GetDirectionToPos(EyePos(),table.Count(currentAnim.frames) > 4)
		animFrames = currentAnim.frames[dir]
		numFrames = #animFrames
	end
	self.SpriteAnimData = self.SpriteAnimData or {lastAnim = nil, curFrame = 1,curFrameT = 0}
	local curData = self.SpriteAnimData or {}

	if curData.lastAnim != currentAnim then
		curData.lastAnim = currentAnim
		curData.curFrame = 1
		curData.curFrameT = 0
	end

	if curData.curFrame <= numFrames && CurTime() > curData.curFrameT then
		self.SpriteAnimData.curFrame = self.SpriteAnimData.curFrame +1
		self.SpriteAnimData.curFrameT = CurTime() +(1 /currentAnim.fps)

		if currentAnim.events then
			for _,v in pairs(currentAnim.events) do
				if v.Frame == curData.curFrame then
					net.Start("cpt_SpriteEvent")
						net.WriteEntity(self)
						net.WriteString(v.Event)
					net.SendToServer()
				end
			end
		end
	end
	if currentAnim.loop && self.SpriteAnimData.curFrame > numFrames then
		self.SpriteAnimData.curFrame = 1
		net.Start("cpt_SpriteEnd")
			net.WriteEntity(self)
			net.WriteString(parentName)
			net.WriteString(seqName)
			net.WriteString(dir or "N")
		net.SendToServer()
	elseif currentAnim.loop != true && self.SpriteAnimData.curFrame > numFrames then
		net.Start("cpt_SpriteEnd")
			net.WriteEntity(self)
			net.WriteString(parentName)
			net.WriteString(seqName)
			net.WriteString(dir or "N")
		net.SendToServer()
		return cptMat(currentAnim.dir .. "/" .. animFrames[numFrames] .. ".png"), currentAnim, multiDir && dir or nil
	end

	return cptMat(currentAnim.dir .. "/" .. animFrames[self.SpriteAnimData.curFrame] .. ".png"), currentAnim, multiDir && dir or nil
end

CPTBase.RenderSprite = function(self,parentName,animName,scale,offset,height,defSize)
	local size = scale *(defSize or 512)
	local frame,animData,dir = CPTBase.PlaySpriteAnimation(self,parentName,animName)
	local ang = EyeAngles()
	ang.p = 0
	ang = ang +Angle(0,270,90)
	cam.Start3D2D(self:GetPos() +ang:Right() *offset.x +ang:Forward() *offset.y +self:GetUp() *offset.z +Vector(0,0,height or 0),ang,0.1)
		surface.SetMaterial(frame)
		surface.SetDrawColor(color_white)
		if animData.flipSet && dir && animData.flipSet[dir] == true then
			surface.DrawTexturedRectUV(0,0,size,size,1,0,0,1)
		else
			surface.DrawTexturedRect(0,0,size,size)
		end
	cam.End3D2D()
end

-- local Draw = ENT_Meta.Draw
-- function ENT_Meta:Draw(f)
--     self.LastDrawT = FrameNumber()

-- 	return Draw(self,f)
-- end

-- function ENT_Meta:IsVisible()
--     return self.LastDrawT == FrameNumber()
-- end

function ENT_Meta:GetDirectionToPos(pos, allDir) -- Credits to Dragoteryx
	local direction = "N"
	local compare = (pos -self:GetPos())
	if allDir then
		local angle = math.AngleDifference(self:GetAngles().y +202.5,compare:Angle().y) +180
		if angle > 45 && angle <= 90 then
			direction = "NE"
		elseif angle > 90 && angle <= 135 then
			direction = "E"
		elseif angle > 135 && angle <= 180 then
			direction = "SE"
		elseif angle > 180 && angle <= 225 then
			direction = "S"
		elseif angle > 225 && angle <= 270 then
			direction = "SW"
		elseif angle > 270 && angle <= 315 then
			direction = "W"
		elseif angle > 315 && angle <= 360 then
			direction = "NW"
		end

		return direction, angle
	else
		local angle = math.AngleDifference(self:GetAngles().y +225,compare:Angle().y) +180
		if angle > 90 && angle <= 180 then
			direction = "E"
		elseif angle > 180 && angle <= 270 then
			direction = "S"
		elseif angle > 270 && angle <= 360 then
			direction = "W"
		end

		return direction, angle
	end
end

function ENT_Meta:CPT_GetCenter()
	return self:GetPos() + self:OBBCenter()
end

function PLY_Meta:GetWeaponAmmoName()
	local CPTBase_DefaultAmmoTypes = {
		["weapon_physcannon"] = -1,
		["weapon_physgun"] = -1,
		["gmod_tool"] = -1,
		["weapon_crowbar"] = -1,
		["weapon_pistol"] = "9MM",
		["weapon_357"] = ".357",
		["weapon_smg1"] = "4.6×30MM",
		["weapon_ar2"] = "Pulse",
		["weapon_crossbow"] = "Bolt",
		["weapon_shotgun"] = "Buckshot",
		["weapon_frag"] = -1,
		["weapon_rpg"] = "RPG",
	}
	if ply:GetActiveWeapon().Primary then
		return ply:GetActiveWeapon().Primary.Ammo
	else
		return CPTBase_DefaultAmmoTypes[ply:GetActiveWeapon():GetClass()]
	end
end