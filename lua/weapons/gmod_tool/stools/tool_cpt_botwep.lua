TOOL.Category = "CPTBase Redux"
TOOL.Name = "Set Bot Weapon"
TOOL.Command = nil
TOOL.ConfigName = ""
TOOL.ClientConVar["cpt_tool_bot_weapon"] = "weapon_cpt_pipe"
---------------------------------------------------------------------------------------------------------------------------------------------
if (CLIENT) then
	language.Add("tool.tool_cpt_botwep.name","Set Bot Weapon")
	language.Add("tool.tool_cpt_botwep.desc","Set bot weapon")
	language.Add("tool.tool_cpt_botwep.0","+attack to set weapon | +attack2 to get bot's weapon")
end
---------------------------------------------------------------------------------------------------------------------------------------------
function TOOL:LeftClick(tr)
	-- if CLIENT then return end
	if tr.Entity && tr.Entity:IsValid() && IsValid(tr.Entity) then
		local ent = tr.Entity
		if !ent:IsNPC() then return end
		if !ent.IsCPTBaseBot then return end
		local newWeapon = self.ClientConVar["cpt_tool_bot_weapon"]
		if IsValid(ent:GetActiveWeapon()) then
			ent:GetActiveWeapon():Remove()
		end
		ent:CPT_GiveNPCWeapon(newWeapon)
		local wep = ent:GetActiveWeapon()
		local ht = ent:GetActiveWeapon().DefaultHoldType
		ent:SetupHoldtypes(wep,ht)
		ent:StopMoving()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function TOOL:RightClick(tr)
	-- if CLIENT then return end
	if tr.Entity && tr.Entity:IsValid() && IsValid(tr.Entity) && tr.Entity:IsNPC() then
		local ent = tr.Entity
		if !ent:IsNPC() then return end
		if IsValid(ent:GetActiveWeapon()) then
			self.ClientConVar["cpt_tool_bot_weapon"] = ent:GetActiveWeapon():GetClass()
		else
			self.ClientConVar["cpt_tool_bot_weapon"] = "weapon_cpt_pipe"
		end
		-- print(self.ClientConVar["cpt_tool_bot_weapon"])
	end
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
	panel:AddControl("Label", {Text = "You can manually type a weapon in:"})
	
	local txtFaction = vgui.Create("DTextEntry")
	txtFaction:SetConVar("cpt_tool_bot_weapon")
	txtFaction:SetMultiline(false)
	panel:AddPanel(txtFaction)

	panel:AddControl("Label", {Text = "If the weapon isn't a CPTBase weapon then your game will error"})
end