include('shared.lua')
/*
	This system isn't meant to be used by new Garry's Mod coders. It is definitely not user friendly
	and should only be used if you know what you're doing.
	
	Use your SMD animation files as reference when creating animation data tables. I have no idea
	how Silverlan knew what to read from .ANI (compiled animation SMD file(s)) but this way also
	works out pretty well. This system is also WIP so don't expect it to work 100% of the time.
	It's also annoying to work with but, it's still fun to use. You can quite literally copy
	your own Lua animation data over into other models on the same Biped as your model without
	having to decompile and recompile.
	
	Here is how you read SMD animation files while creating your tables:
	
		time 0 < This is the frame number
			0    0.000000    0.000000    0.000000    0.000000   -0.000000    0.000000
			^ bone, ^ pos X  ^ pos Y     ^ Pos Z     ^ Ang P    ^ Ang Y      ^ Ang R
			1    9.119514   -3.038719   75.300491    0.583951   -0.123947   -0.446396
			2    0.000000    1.735138   10.959610    1.233591   -1.490998    2.010384

	You can probably create an executible or even run a Lua executible in-game to generate a
	Lua animation data table if you want to. I might make in the future but not right now.
	
	Create a data.lua file inside of your NPC (data.lua, init.lua, shared.lua). Inside of it
	you should have something like this:
	
		ENT.ANIMDATA_ANIMATIONNAME = {
			[0] = {
				Bone = 26, Pos = Vector(2.283876,-1.669766,12.314743), Ang = Angle(-2.835737,1.143795,-2.862701),
				Bone = 27, Pos = Vector(-0.000008,0.000000,6.809689), Ang = Angle(-0.449734,0.691273,0.045466),
				Bone = 28, Pos = Vector(-0.000004,0.000000,15.344440), Ang = Angle(-0.477111,0.000003,0.000011),
				Bone = 29, Pos = Vector(0.000000,-0.000011,13.409319), Ang = Angle(0.204183,0.224986,1.220735)
			},
			[1] = {
				Bone = 26, Pos = Vector(2.283876,-1.669766,12.314743), Ang = Angle(-2.835737,1.143795,-2.862701),
				Bone = 27, Pos = Vector(-0.000008,0.000000,6.809689), Ang = Angle(-0.449734,0.691273,0.045466),
				Bone = 28, Pos = Vector(-0.000004,0.000000,15.344440), Ang = Angle(-0.477111,0.000003,0.000011),
				Bone = 29, Pos = Vector(0.000000,-0.000011,13.409319), Ang = Angle(0.204183,0.224986,1.220735)
			},
		}
	
	Now inside of your init.lua at the top, add an include for data.lua like this:
	
		if !CPTBase then return end
		AddCSLuaFile('shared.lua')
		include('shared.lua')
		include('data.lua')
	
	Whenever you call the Lua animation function, you would call it like this inside of your init.lua:
	
		function ENT:DoAttack()
			if self:CanPerformProcess() == false then return end
			self:PlayLuaAnimation(self.ANIMDATA_ANIMATIONNAME,0.1,1)
		end
	
	Congratulations, you did it! Again, this is very WIP and is really annoying to work with.
*/

/*
ENT.tbExample_Animation = {
	[iFrame] = {
		Bone = 5, Pos = Vector(x,y,z), Ang = Angle(p,y,r)
	},
}
*/
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:PlayLuaAnimation(dataTable,fTime,lRate) -- This code is very messy at the moment. It's currently in debugging mode!
	local posData = "LUADATA_POS_ANIMATIONID_"
	local angData = "LUADATA_ANG_ANIMATIONID_"
	self.LuaAnimationData = dataTable
	print("Calculating Animation Data {")
	local lPos = Vector(0,0,0)
	local lAng = Angle(0,0,0)
	local oPos = self:GetPos()
	local oAng = self:GetAngles()
	local frameTime = fTime or 0.1
	local lerpRate = lRate or 1
	local totalFrames = table.Count(dataTable) -1
	local currentFrame = 0
	local nextFrame = 1
	print("Lerp Pos: " .. tostring(lPos))
	print("Lerp Ang: " .. tostring(lAng))
	print("Original Pos: " .. tostring(oPos))
	print("Original Ang: " .. tostring(oAng))
	print("Frame Time: " .. tostring(frameTime))
	print("Lerp Rate: " .. tostring(lerpRate))
	print("Total Frames: " .. tostring(totalFrames))
	print("Current Frame: " .. tostring(currentFrame))
	print("Next Frame: " .. tostring(nextFrame))
	self.IsPlayingLuaAnimation = true
	self:SetNWBool("LUADATA_PLAYINGANIMATION",true)
	self.LuaAnimationLength = totalFrames *frameTime
	print("} Calculated Animation Data")
	print("Started Animation...")
	for i = 0,totalFrames -1 do
		timer.Simple(i *frameTime,function()
			if IsValid(self) then
				currentFrame = i
				self.CurrentLuaAnimationFrame = currentFrame
				self:SetNWInt("LUADATA_ANIMATION_FRAME",currentFrame)
				nextFrame = currentFrame +1
				if dataTable[currentFrame] == nil then MsgN("Unable to continue Lua Animation Data ERROR: NO DATA FOUND IN INDEX " .. i .. "!") return end
				print("Started Timer Data #" .. tostring(i))
				for i = 0,self:GetBoneCount() -1 do
					if dataTable[currentFrame].Bone == i then
						if dataTable[currentFrame].Bone == nil then MsgN("Unable to locate bone ID indexed in Lua Animation Data") return end
						if dataTable[currentFrame].Pos == nil then MsgN("Unable to locate bone position indexed in Lua Animation Data") return end
						if dataTable[currentFrame].Ang == nil then MsgN("Unable to locate bone angle indexed in Lua Animation Data") return end
						print("Calculating Bone Data: " .. tostring(dataTable[currentFrame].Bone))
						self:SetNWInt("LUADATA_ANIMATION_BONEID_" .. i,i)
						lPos = dataTable[currentFrame].Pos
						lPos = lPos +LerpVector(lerpRate,dataTable[currentFrame].Pos,dataTable[nextFrame].Pos)
						lAng = dataTable[currentFrame].Ang
						lAng = lAng +LerpAngle(lerpRate,dataTable[currentFrame].Ang,dataTable[nextFrame].Ang)
						self:SetNWVector(posData .. i,lPos)
						self:SetNWAngle(angData .. i,lAng)
						-- if CLIENT then
							-- print("Beginning Bone Translation...")
							-- self:SetBonePosition(i,self:GetNWVector(posData),self:GetNWAngle(angData))
						-- end
						-- self:ManipulateBonePosition(i,lPos)
						-- self:ManipulateBoneAngles(i,lAng)
						print("Setting Position: " .. tostring(lPos))
						print("Setting Angles: " .. tostring(lAng))
						print("Completed Frame #" .. tostring(currentFrame))
					end
				end
			end
		end)
	end
	timer.Simple(self.LuaAnimationLength +frameTime,function()
		if IsValid(self) then
			self.IsPlayingLuaAnimation = false
			self.LuaAnimationData = {}
			self.CurrentLuaAnimationPosName = nil
			self.CurrentLuaAnimationAngName = nil
			self.CurrentLuaAnimationFrame = nil
			self.LuaAnimationLength = 0
			self:SetNWBool("LUADATA_PLAYINGANIMATION",false)
			self:SetNWInt("LUADATA_ANIMATION_FRAME",nil)
			print("Completed Animation")
		end
	end)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:AdjustBones(tbl,alter)
	local ang = false
	if type(alter) == "Angle" then
		ang = true
	end
	for _,v in pairs(tbl) do
		local boneid = self:LookupBone(v)
		if boneid && boneid > 0 then
			if ang == false then
				self:ManipulateBonePosition(boneid,alter)
			else
				self:ManipulateBoneAngles(boneid,alter)
			end
		end
	end
end