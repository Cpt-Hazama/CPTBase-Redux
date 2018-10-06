AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self:SetCollisionGroup(COLLISION_GROUP_NONE)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_NONE)
	self:AddEFlags(EFL_KEEP_ON_RECREATE_ENTITIES)
	self.tbl_Links = {}
	self:DiscoverNodes(self:GetNodeRadius())
	if self:GetModel() == "models/error.mdl" then
		self:SetNodeType(1)
		self:SetNodeRadius(375)
	end
end

function ENT:SetNodeType(nodetype)
	self.NodeType = nodetype
	if nodetype == 1 then
		self:SetModel("models/editor/ground_node.mdl")
	elseif nodetype == 2 then
		self:SetModel("models/editor/air_node.mdl")
	elseif nodetype == 3 then
		self:SetModel("models/editor/climb_node.mdl")
	elseif nodetype == 4 then
		self:SetModel("models/editor/air_node_hint.mdl")
	elseif nodetype == 5 then
		self:SetModel("models/editor/node_hint.mdl")
	end
	-- self:SetNoDraw(true)
end

function ENT:GetNodeType()
	return self.NodeType
end

function ENT:SetNodeRadius(noderadius)
	self.NodeRadius = noderadius
end

function ENT:GetNodeRadius()
	return self.NodeRadius
end

function ENT:DiscoverNodes(radius)
	if radius == nil then radius = 375 end
	for keys,nodes in ipairs(ents.FindInSphere(self:GetPos(),radius)) do
		if IsValid(nodes) && nodes:GetClass() == "cpt_ai_node" && self:Visible(nodes) then
			table.insert(self.tbl_Links,nodes)
		end
	end
end

function ENT:ReadNodeLinks()
	return self.tbl_Links
end

function ENT:Think()
	if GetConVarNumber("cpt_debug_showcptnodegraph") == 1 then
		self:SetNoDraw(false)
	else
		self:SetNoDraw(true)
	end
end