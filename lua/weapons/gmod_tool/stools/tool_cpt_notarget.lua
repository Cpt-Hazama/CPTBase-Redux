TOOL.Category = "CPTBase Redux"
TOOL.Name = "Set Notarget"
TOOL.Command = nil
TOOL.ConfigName = ""
---------------------------------------------------------------------------------------------------------------------------------------------
if (CLIENT) then
	language.Add("tool.tool_cpt_notarget.name","Set Notarget")
	language.Add("tool.tool_cpt_notarget.desc","Set Notarget")
	language.Add("tool.tool_cpt_notarget.0","+attack to apply notarget | +reload to apply to yourself")
end
---------------------------------------------------------------------------------------------------------------------------------------------
local function NoTarget(ent,nt)
	ent:SetNoTarget(nt)
	ent.UseNotarget = nt
end
---------------------------------------------------------------------------------------------------------------------------------------------
function TOOL:LeftClick(tr)
	if CLIENT then return end
	if tr.Entity && tr.Entity:IsValid() && IsValid(tr.Entity) then
		local ent = tr.Entity
		if ent:IsPlayer() then
			if ent:IsFlagSet(FL_NOTARGET) != true then
				NoTarget(ent,true)
				self:GetOwner():ChatPrint("Applied notarget to " .. v:Nick())
				return true
			else
				NoTarget(ent,false)
				self:GetOwner():ChatPrint("Removed notarget on " .. v:Nick())
				return true
			end
		elseif ent:IsNPC() then
			if ent.UseNotarget != true then
				NoTarget(ent,true)
				self:GetOwner():ChatPrint("Applied notarget to " .. ent:GetClass())
				return true
			else
				NoTarget(ent,false)
				self:GetOwner():ChatPrint("Removed notarget on " .. ent:GetClass())
				return true
			end
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function TOOL:Reload(tr)
	local ent = self:GetOwner()
	if ent:IsFlagSet(FL_NOTARGET) != true then
		NoTarget(ent,true)
		self:GetOwner():ChatPrint("Applied notarget to " .. ent:Nick())
		return true
	else
		NoTarget(ent,false)
		self:GetOwner():ChatPrint("Removed notarget on " .. ent:Nick())
		return true
	end
end