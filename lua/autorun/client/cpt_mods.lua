if !CPTBase then return end

CPTBase_OfficialMods = {
	[1] = {name = "Zombie Master 2 SNPCs",version = "0.2.1"},
	[2] = {name = "Zombie Panic: Source SNPCs",version = "0.1.0"},
	[3] = {name = "Dark Messiah SNPCs",version = "0.1.0"},
	[4] = {name = "TESIV: Oblivion SNPCs",version = "0.1.0"},
	[5] = {name = "TESV: Skyrim SNPCs",version = "0.1.0"},
	[6] = {name = "SCP Containment Breach SNPCs",version = "0.1.0"},
	[7] = {name = "Battalion Wars SNPCs",version = "0.1.0"},
	[8] = {name = "Vindictus SNPCs",version = "0.1.0"},
	[9] = {name = "Zombie Survival SNPCs",version = "0.1.0"},
	[10] = {name = "Zolice SNPC",version = "0.2.1"},
	[11] = {name = "Half-Life 2 Beta SNPCs",version = "0.1.0"},
	[12] = {name = "Star Wars Vehicles SNPCs",version = "0.1.0"}
}

function CPTBaseMenu_ShowMods(Panel)
	Panel:AddControl("Label", {Text = "Here are your installed CPTBase Redux mods!"})
	Panel:ControlHelp("You have " .. table.Count(tbl_cptMods) .. " CPTBase Redux mods.")
	chat.AddText(Color(0,255,0),"Total CPTBase Redux Mods: " .. table.Count(tbl_cptMods))
	if table.Count(tbl_cptMods) < 1 then
		chat.AddText(Color(0,255,0),"You need some CPTBase Redux mods! Go to the Steam Workshop and search CPTBase")
		Panel:AddControl("Label",{Text = "You have no CPTBase Redux mods."})
	else
		chat.AddText(Color(0,255,0),"List of CPTBase Redux mods:")
		Panel:ControlHelp("All CPTBase Redux Mods:")
		Panel:ControlHelp("*NAME | VERSION*")
		for _,addon in SortedPairsByMemberValue(tbl_cptMods,"name") do
			Panel:AddControl("Label",{Text = addon.name .. " | " .. addon.version})
			chat.AddText(Color(0,255,0),addon.name)
		end
		Panel:ControlHelp(" ")
		Panel:ControlHelp("Official CPTBase Redux Mods Only:")
		for _,addon in SortedPairsByMemberValue(CPTBase_OfficialMods,"name") do
			Panel:AddControl("Label",{Text = addon.name .. " | " .. addon.version})
		end
	end
end

function CPTBase_AddMenu_Mods()
	-- spawnmenu.AddToolMenuOption("CPTBase","Client","Mods","Mods","","",CPTBaseMenu_ShowMods) -- Tab, Dropdown, Select, Title
end
hook.Add("PopulateToolMenu","CPTBase_AddMenu_Mods",CPTBase_AddMenu_Mods)