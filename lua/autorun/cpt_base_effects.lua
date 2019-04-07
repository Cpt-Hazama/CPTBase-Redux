/*--------------------------------------------------
	Copyright (c) 2019 by Cpt. Hazama, All rights reserved.
	Nothing in these files or/and code may be reproduced, adapted, merged or
	modified without prior written consent of the original author, Cpt. Hazama
--------------------------------------------------*/
AddCSLuaFile('server/cpt_utilities.lua')
include('server/cpt_utilities.lua')

CPTBase.AddParticleSystem("particles/cpt_magic.pcf",{
	"cpt_conjuration_idle",
	"cpt_poisonspell_idle",
	"cpt_souldrain_idle",
	"cpt_warp_idle",
	"skyr_vlord_spell_resu",
})
CPTBase.AddParticleSystem("particles/cpt_blood.pcf",{
	-- "blood_impact_red",
	-- "blood_impact_yellow",
	-- "blood_impact_blue",
	-- "blood_impact_green",
	-- "blood_impact_purple",
	-- "blood_impact_orange",
	-- "blood_impact_white",
	-- "blood_impact_black",
	-- "blood_impact_pink",
	-- "blood_impact_infection",
	-- "blood_impact_random"
}) -- I made these myself :)
CPTBase.AddParticleSystem("particles/cpt_darkmessiah.pcf",{}) -- I made these myself :)
CPTBase.AddParticleSystem("particles/cpt_mutation.pcf",{}) -- Credits to Darken
CPTBase.AddParticleSystem("particles/cpt_explosions.pcf",{"hefg_explosion","mininuke_explosion"}) -- Credits to Silverlan
CPTBase.AddParticleSystem("particles/cpt_flamethrower.pcf",{}) -- Credits to Silverlan
CPTBase.AddParticleSystem("particles/mortarsynth_fx.pcf",{}) -- Credits to Silverlan
CPTBase.AddParticleSystem("particles/electrical_fx.pcf",{"electrical_arc_01_system"})
CPTBase.AddParticleSystem("particles/WEAPON_FX.pcf",{})
if IsMounted("ep2") then -- If you don't own this game..shame on you
	CPTBase.AddParticleSystem("particles/antlion_worker.pcf",{"antlion_spit"})
	CPTBase.AddParticleSystem("particles/antlion_gib_01.pcf",{"antlion_gib_01"})
	CPTBase.AddParticleSystem("particles/antlion_gib_02.pcf",{"antlion_gib_02"})
end

CPTBase.DefineDecal("CPTBase_RedBlood",{
	"cptbase/decals/red1",
	"cptbase/decals/red2",
	"cptbase/decals/red3",
	"cptbase/decals/red4"
})

CPTBase.DefineDecal("CPTBase_YellowBlood",{
	"cptbase/decals/yellow1",
	"cptbase/decals/yellow2",
	"cptbase/decals/yellow3",
	"cptbase/decals/yellow4"
})

CPTBase.DefineDecal("CPTBase_BlueBlood",{
	"cptbase/decals/blue1",
	"cptbase/decals/blue2",
	"cptbase/decals/blue3",
	"cptbase/decals/blue4"
})

CPTBase.DefineDecal("CPTBase_GreenBlood",{
	"cptbase/decals/green1",
	"cptbase/decals/green2",
	"cptbase/decals/green3",
	"cptbase/decals/green4"
})

CPTBase.DefineDecal("CPTBase_PurpleBlood",{
	"cptbase/decals/purple1",
	"cptbase/decals/purple2",
	"cptbase/decals/purple3",
	"cptbase/decals/purple4"
})

CPTBase.DefineDecal("CPTBase_OrangeBlood",{
	"cptbase/decals/orange1",
	"cptbase/decals/orange2",
	"cptbase/decals/orange3",
	"cptbase/decals/orange4"
})

CPTBase.DefineDecal("CPTBase_PinkBlood",{
	"cptbase/decals/pink1",
	"cptbase/decals/pink2",
	"cptbase/decals/pink3",
	"cptbase/decals/pink4"
})

CPTBase.DefineDecal("CPTBase_BlackBlood",{
	"cptbase/decals/black1",
	"cptbase/decals/black2",
	"cptbase/decals/black3",
	"cptbase/decals/black4"
})

CPTBase.DefineDecal("CPTBase_WhiteBlood",{
	"cptbase/decals/white1",
	"cptbase/decals/white2",
	"cptbase/decals/white3",
	"cptbase/decals/white4"
})

CPTBase.DefineDecal("CPTBase_ZombieBlood",{
	"cptbase/decals/zombie1",
	"cptbase/decals/zombie2",
	"cptbase/decals/zombie3",
	"cptbase/decals/zombie4"
})