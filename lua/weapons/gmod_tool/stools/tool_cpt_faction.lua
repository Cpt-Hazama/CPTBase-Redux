TOOL.Category = "CPTBase Redux"
TOOL.Name = "Set Faction"
TOOL.Command = nil
TOOL.ConfigName = ""
TOOL.ClientConVar["cpt_tool_faction"] = "FACTION_NONE"
TOOL.Faction = "FACTION_NONE"
---------------------------------------------------------------------------------------------------------------------------------------------
if (CLIENT) then
	language.Add("tool.tool_cpt_faction.name","Set Faction")
	language.Add("tool.tool_cpt_faction.desc","Set NPC and Player (CPTBase) factions")
	language.Add("tool.tool_cpt_faction.0","+attack to set entity faction | +attack2 to get entity's faction | +reload to apply faction to yourself")
end
---------------------------------------------------------------------------------------------------------------------------------------------
function TOOL:LeftClick(tr)
	-- if CLIENT then return end
	if tr.Entity && tr.Entity:IsValid() && IsValid(tr.Entity) then
		local ent = tr.Entity
		if !ent:IsNPC() || !ent:IsPlayer() then return end
		if ent:GetNW2String("CPTBase_NPCFaction") == nil then
			if ent:IsNPC() then
				ent:SetNW2String("CPTBase_NPCFaction","FACTION_NONE")
			else
				ent:SetNW2String("CPTBase_NPCFaction","FACTION_PLAYER")
			end
		end
		local oldFaction = ent:GetNW2String("CPTBase_NPCFaction")
		-- local newFaction = self.Faction
		local newFaction = self.ClientConVar["cpt_tool_faction"]
		ent:SetNW2String("CPTBase_NPCFaction",newFaction)
		if ent.UpdateNPCFaction then
			ent:UpdateNPCFaction()
		end
		if CLIENT then
			self:DisplayNotification("Set " .. language.GetPhrase(ent:GetClass()) .. "'s faction to " .. newFaction .. ". It used to be " .. oldFaction .. ".")
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function TOOL:RightClick(tr)
	-- if CLIENT then return end
	if tr.Entity && tr.Entity:IsValid() && IsValid(tr.Entity) && tr.Entity:IsNPC() then
		local ent = tr.Entity
		print(ent:GetNW2String("CPTBase_NPCFaction"))
		if ent:GetNW2String("CPTBase_NPCFaction") != nil then
			self.ClientConVar["cpt_tool_faction"] = ent:GetNW2String("CPTBase_NPCFaction")
			-- self.Faction = ent:GetNW2String("CPTBase_NPCFaction")
		else
			self.ClientConVar["cpt_tool_faction"] = "FACTION_NONE"
			-- self.Faction = "FACTION_NONE"
		end
		-- self:DisplayNotification("Your default selected faction is now " .. self.Faction .. ".")
		self:DisplayNotification("Your default selected faction is now " .. self.ClientConVar["cpt_tool_faction"] .. ".")
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function TOOL:Reload(tr)
	-- if SERVER then return end
	-- self:GetOwner():SetNW2String("CPTBase_NPCFaction",self.Faction)
	self:GetOwner():SetNW2String("CPTBase_NPCFaction",self.ClientConVar["cpt_tool_faction"])
	-- self:GetOwner():ChatPrint("You've set your current faction to " .. self.Faction)
	self:GetOwner():ChatPrint("You've set your current faction to " .. self.ClientConVar["cpt_tool_faction"])
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
	panel:AddControl("Label", {Text = "You can manually type a faction in:"})
	
	local txtFaction = vgui.Create("DTextEntry")
	txtFaction:SetConVar("cpt_tool_faction")
	txtFaction:SetMultiline(false)
	panel:AddPanel(txtFaction)

	panel:AddControl("Label", {Text = "List of default factions:"})
	panel:ControlHelp("FACTION_ANTLION")
	panel:ControlHelp("FACTION_COMBINE")
	panel:ControlHelp("FACTION_MILITARY")
	panel:ControlHelp("FACTION_NONE")
	panel:ControlHelp("FACTION_PLAYER")
	panel:ControlHelp("FACTION_PLAYER_ENEMY")
	panel:ControlHelp("FACTION_XEN")
	panel:ControlHelp("FACTION_ZOMBIE")
end