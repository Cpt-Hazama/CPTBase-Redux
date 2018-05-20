TOOL.Category = "CPTBase Redux"
TOOL.Name = "Set Faction"
TOOL.Command = nil
TOOL.ConfigName = ""
TOOL.ClientConVar["cpt_tool_faction"] = "FACTION_NONE"
---------------------------------------------------------------------------------------------------------------------------------------------
if (CLIENT) then
	local hudNAME = "Set Faction"
	local hudDescription = "Set NPC and Player (CPTBase) factions"
	local hudDirections = "+attack to set entity faction | +attack2 to get entity's faction | +reload to apply faction to yourself"
	language.Add("tool.tool_cpt_faction.name",hudName)
	language.Add("tool.tool_cpt_faction.desc",hudDescription)
	language.Add("tool.tool_cpt_faction.0",hudDirections)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function TOOL:LeftClick(tr)
	-- if CLIENT then return end
	if tr.Entity && tr.Entity:IsValid() && tr.Entity != NULL && tr.Entity:IsNPC() then
		local ent = tr.Entity
		local oldFaction = ent.Faction
		local newFaction = GetConVarString("cpt_tool_faction")
		ent.Faction = newFaction
		if CLIENT then
			self:DisplayNotification("Set " .. language.GetPhrase(ent:GetClass()) .. "'s faction to " .. newFaction .. ". It used to be " .. oldFaction .. ".")
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function TOOL:RightClick(tr)
	-- if CLIENT then return end
	if tr.Entity && tr.Entity:IsValid() && tr.Entity != NULL && tr.Entity:IsNPC() then
		local ent = tr.Entity
		if ent.Faction != nil then
			self.ClientConVar["cpt_tool_faction"] = ent.Faction
		else
			self.ClientConVar["cpt_tool_faction"] = "FACTION_NONE"
		end
		self:DisplayNotification("Your default selected faction is " .. GetConVarString("cpt_tool_faction") .. ".")
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function TOOL:Reload(tr)
	-- if CLIENT then return end
	self:DisplayNotification("You've set your current faction to " .. GetConVarString("cpt_tool_faction"))
end
---------------------------------------------------------------------------------------------------------------------------------------------
function TOOL:DisplayNotification(text)
	if CLIENT then return end
	self:GetOwner():SendLua("GAMEMODE:AddNotify('" .. text .. "',NOTIFY_GENERIC,3)")
	self:GetOwner():SendLua("surface.PlaySound('ambient/water/drip" .. math.random(1,4) .. ".wav')")
end
---------------------------------------------------------------------------------------------------------------------------------------------
function TOOL.BuildCPanel(panel) // This will set stuff in the Spawn Menu
	-- if CLIENT then return end
	local txtFaction = vgui.Create("DTextEntry")
	txtFaction:SetConVar("cpt_tool_faction")
	txtFaction:SetMultiline(false)
	panel:AddPanel(txtFaction)
end