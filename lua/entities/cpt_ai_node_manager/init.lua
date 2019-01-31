AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self:SetCollisionGroup(COLLISION_GROUP_NONE)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_NONE)
	self.tbl_Nodegraph = {}
	self.tbl_FakeNodegraph = {}
end

function ENT:InsertNode(vec)
	table.insert(self.tbl_Nodegraph,vec)
	print(vec)
end

function ENT:GetNodes()
	return self.tbl_Nodegraph
end

function ENT:DisplayNodes()
	for _,v in ipairs(self.tbl_FakeNodegraph) do
		if IsValid(v) then
			v:Remove()
		end
	end
	for _,v in ipairs(self:GetNodes()) do
		local b = ents.Create("prop_dynamic")
		b:SetModel("models/editor/ground_node.mdl")
		b:SetPos(v)
		b:Spawn()
		table.insert(self.tbl_FakeNodegraph,b)
	end
end

function ENT:ManageNodes()
	for keys,nodes in ipairs(ents.GetAll()) do
		if nodes:GetClass() == "cpt_ai_node" then
			if !table.HasValue(self.tbl_Nodegraph,nodes:GetPos()) then
				if nodes.CanBeRemoved then
					if CurTime() > nodes.RemoveTime then
						table.insert(self.tbl_Nodegraph,nodes:GetPos())
						nodes:Remove()
					end
				else
					table.insert(self.tbl_Nodegraph,nodes:GetPos())
					nodes:Remove()
				end
			end
		end
	end
end

function ENT:Think()
	self:SetPos(Vector(0,0,0))
	self:ManageNodes()
end