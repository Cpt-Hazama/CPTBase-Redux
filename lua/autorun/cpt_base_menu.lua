/*--------------------------------------------------
	Copyright (c) 2018 by Cpt. Hazama, All rights reserved.
	Nothing in these files or/and code may be reproduced, adapted, merged or
	modified without prior written consent of the original author, Cpt. Hazama
--------------------------------------------------*/
CPTBase.AddConVar("cpt_bot_seeenemies","0")
CPTBase.AddConVar("cpt_bot_chat","1")
-- CPTBase.AddConVar("cpt_bot_custommodel","models/player/kleiner.mdl")
CPTBase.AddConVar("cpt_usetracemovement","0")

if (CLIENT) then
	local function CPTBaseMenu_SNPC(panel)
		if !game.SinglePlayer() then
			if !LocalPlayer():IsAdmin() or !LocalPlayer():IsSuperAdmin() then
				panel:AddControl("Label",{Text = "Only Admins Can Access These Settings!"})
				return
			end
		end
		local CPTBaseMenu_SNPC = {Options = {},CVars = {},Label = "#Presets",MenuButton = "1",Folder = "CPTBase Settings"}
		CPTBaseMenu_SNPC.Options["#Default"] = {
			cpt_usetracemovement = "0",
			cpt_corpselifetime = "100",
			cpt_aidifficulty = "2",
			cpt_bot_seeenemies = "0",
			cpt_bot_chat = "1",
			-- cpt_bot_custommodel = "models/player/kleiner.mdl",
		}
		panel:AddControl("ComboBox",CPTBaseMenu_SNPC)
		panel:AddControl("CheckBox",{ Label = "CPTBase Bots can wall hack?",Command = "cpt_bot_seeenemies"})
		panel:AddControl("CheckBox",{ Label = "CPTBase Bots can use chat?",Command = "cpt_bot_chat"})
		-- panel:AddControl("TextBox", {Label = "Custom CPTBase Bot model:", Command = "cpt_bot_custommodel", WaitForEnter = "0"})
		panel:AddControl("CheckBox",{ Label = "Use Trace Movement",Command = "cpt_usetracemovement"})
		panel:ControlHelp("If enabled, your possessed SNPC will move towards your cursor instead of a set direction.")
		panel:AddControl("Slider", { Label 	= "Corpse Life Time", Command = "cpt_corpselifetime", Type = "Float", Min = "0", Max = "800"})
		panel:AddControl("Slider", { Label 	= "AI Difficulty", Command = "cpt_aidifficulty", Type = "Float", Min = "1", Max = "4"})
		panel:ControlHelp("1 = Easy, 2 = Normal, 3 = Hard, 4 = Hell (Only effects base values. Mods with custom functions will need to be updated by the mod owner)")
		panel:AddControl("Label",{Text = "Cpt. Hazama"})
	end
	function CPTBaseMenu_Add()
		spawnmenu.AddToolMenuOption("CPTBase","SNPC Settings","AI Settings","AI Settings","","",CPTBaseMenu_SNPC) -- Tab, Dropdown, Select, Title
	end
	hook.Add("PopulateToolMenu","CPTBaseMenu_Add",CPTBaseMenu_Add)
end