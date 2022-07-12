ENT.Base = "base_entity"
ENT.Type = "ai"
ENT.PrintName = "CPTBase"
ENT.Author = "Cpt. Hazama"
ENT.Contact = "http://steamcommunity.com/id/cpthazama/" 
ENT.Purpose = "A base used to easily created SNPCs."
ENT.Instructions = "Code an SNPC."
ENT.Information	= "Include this in your SNPC."  
ENT.Category = "CPTBase"
ENT.AutomaticFrameAdvance = true

ENT.Spawnable = false
ENT.AdminSpawnable = false

ENT.IsCPTBase_NPC = true

function ENT:SetAutomaticFrameAdvance(bUsingAnim)
	self.AutomaticFrameAdvance = bUsingAnim
end

function ENT:PhysicsCollide(data,phys) end

function ENT:PhysicsUpdate(phys) end

function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"HP")

	self:NetworkVar("Entity",0,"Possessor")
	self:NetworkVar("Entity",1,"CurrentEnemy")
end

if SERVER then
	util.AddNetworkString("CPTBase_Possessor_HitPos")

	net.Receive("CPTBase_Possessor_HitPos", function(len, ply)
		local pos = net.ReadVector()
		local ent = net.ReadEntity()

		if !IsValid(ent) then return end
		ent:SetPossessorAimPos(pos)
	end)
end

if CLIENT then
	local C_LerpVec = Vector(0,0,0)
	local C_LerpAng = Angle(0,0,0)
	local C_Vec0 = Vector(0,0,0)
	local C_Vec1 = Vector(1,1,1)

	function ENT:ControllerInitialize()
		hook.Add("CalcView",self,function(self,ply,origin,angles,fov,znear,zfar)
			local possessor = self:GetPossessor()
			if possessor != ply then return end

			if IsValid(ply:GetViewEntity()) && ply:GetViewEntity():GetClass() == "gmod_cameraprop" then
				return
			end
			if ply:GetObserverTarget() != self then
				return
			end
			local view = {}
			local targetPos = self:GetCenter() + self:GetUp() * self:OBBMaxs().z * 0.5
			local tr = util.TraceHull({
				start = targetPos,
				endpos = targetPos +ply:EyeAngles():Forward() *-math.max(ply.CPTBase_Possessor_Zoom or 100,self:BoundingRadius()),
				mask = MASK_SHOT,
				filter = {self,ply},
				mins = Vector(-8,-8,-8),
				maxs = Vector(8,8,8)
			})
			targetPos = tr.HitPos +tr.HitNormal *5
			C_LerpVec = LerpVector(FrameTime() *10,C_LerpVec,targetPos)
			C_LerpAng = LerpAngle(FrameTime() *10,C_LerpAng,ply:EyeAngles())

			local tr = util.TraceLine({start = C_LerpVec, endpos = C_LerpVec +C_LerpAng:Forward() *32768, filter = {ply,self}})
			net.Start("CPTBase_Possessor_HitPos")
				net.WriteVector(tr.HitPos)
				net.WriteEntity(self)
			net.SendToServer()

			view.origin = C_LerpVec
			view.angles = C_LerpAng
			view.fov = fov
		
			return view
		end)

		hook.Add("PlayerBindPress",self,function(self,ply,bind,pressed)
			local possessor = self:GetPossessor()
			if possessor != ply then return end
	
			if (bind == "invprev" or bind == "invnext") then
				ply.CPTBase_Possessor_Zoom = ply.CPTBase_Possessor_Zoom or 100
				if bind == "invprev" then
					ply.CPTBase_Possessor_Zoom = math.Clamp(ply.CPTBase_Possessor_Zoom -5,0,500)
				else
					ply.CPTBase_Possessor_Zoom = math.Clamp(ply.CPTBase_Possessor_Zoom +5,0,500)
				end
			end
		end)
	end
end