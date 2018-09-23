include('shared.lua')

BASE_ANIMATIONS = {}
BASE_DATA = {}
BASE_SEQUENCE = "ragdoll"
BASE_FPS = 30
BASE_LOOP = false
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
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:AutoDefineLUABones()
	for i = 0,self:GetBoneCount() do
		if self:GetBonePosition(i) == self:GetPos() then return end
		self:DefineLUABone(self:GetBoneName(i),i)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:DefineLUABone(boneName,luaID)
	if self.tbl_DefinedLuaBones == nil then self.tbl_DefinedLuaBones = {} end
	if table.HasValue(self.tbl_DefinedLuaBones,boneName) then
		MsgN("Could not define bone " .. boneName .. " as lua ID " .. luaID .. ". Bone is already defined in NPC.")
	else
		MsgN("Defined bone " .. boneName .. " as lua ID " .. luaID .. ".")
		table.insert(self.tbl_DefinedLuaBones,boneName)
		self.tbl_DefinedLuaBones[luaID] = boneName
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
/*
	Concept:
	ENT:OnInit()
		local tblSequence = {
			["Name"] = "$CZOMBIE",
			["Sequence"] = "attackSwing",
			["FPS"] = 30,
			["Loop"] = false,
			["Events"] = {[1] = "event_emit Attack",[2] = "event_mattack"}
		}
		local tblFrameData = {
			[1] = {
					"Valve.Biped_Pelvis" = {pos=Vector(0,0,0),ang=Angle(0,0,0)},
					"Valve.Biped_Head1" = {pos=Vector(0,0,0),ang=Angle(0,0,0)},
					"Valve.Biped_ForearmR" = {pos=Vector(0,0,0),ang=Angle(0,0,0)}
				},
			[2] = {
					"Valve.Biped_Pelvis" = {pos=Vector(0,0,0),ang=Angle(0,0,0)},
					"Valve.Biped_Head1" = {pos=Vector(0,0,0),ang=Angle(0,0,0)},
					"Valve.Biped_ForearmR" = {pos=Vector(0,0,0),ang=Angle(0,0,0)}
				},
			[3] = {
					"Valve.Biped_Pelvis" = {pos=Vector(0,0,0),ang=Angle(0,0,0)},
					"Valve.Biped_Head1" = {pos=Vector(0,0,0),ang=Angle(0,0,0)},
					"Valve.Biped_ForearmR" = {pos=Vector(0,0,0),ang=Angle(0,0,0)}
				},
		}
		self:CreateLUAAnimation(tblSequence,tblFrameData)
	end
*/
function ENT:CreateLUAAnimation(tblSequence,tblFrameData)
	table.insert(BASE_ANIMATIONS,tblSequence["Name"])
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:UseLUABasedAnimation(sequenceName)
	local fps = 30
	local nextFrame = CurTime()
	local frames = table.Count(BASE_ANIMATIONS[sequenceName]["Frames"])
end