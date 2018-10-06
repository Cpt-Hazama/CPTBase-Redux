include('shared.lua')

ENT.tbl_ClientLinks = {}

function ENT:Initialize() self:ClientDiscoverNodes(375) end

function ENT:Draw()
	self:DrawModel()
end

function ENT:Visible(ent)
	local tracedata = {}
	tracedata.start = self:GetPos() +Vector(0,0,3)
	tracedata.endpos = ent:GetPos() +Vector(0,0,3)
	tracedata.filter = {self}
	local tr = util.TraceLine(tracedata)
	return tr.Hit
end

function ENT:ClientDiscoverNodes(radius)
	for keys,nodes in ipairs(ents.FindInSphere(self:GetPos(),radius)) do
		if IsValid(nodes) && nodes:GetClass() == "cpt_ai_node" && self:Visible(nodes) then
			table.insert(self.tbl_ClientLinks,nodes)
		end
	end
end

function ENT:ReadClientNodeLinks()
	return self.tbl_ClientLinks
end

function ENT:Think()
	-- if GetConVarNumber("cpt_debug_showcptnodegraph") == 1 then
		-- self:SetNoDraw(false)
		-- render.SetMaterial(Material("trails/laser"))
		-- for _,nodes in ipairs(self:ReadClientNodeLinks()) do
			-- render.DrawBeam(self:GetPos() +Vector(0,0,3),nodes:GetPos() +Vector(0,0,3),10,0,0,Color(0,255,0,255))
		-- end
		-- return
	-- end
	-- self:SetNoDraw(true)
end