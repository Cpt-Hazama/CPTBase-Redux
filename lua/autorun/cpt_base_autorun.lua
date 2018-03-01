/*--------------------------------------------------
	Copyright (c) 2018 by Cpt. Hazama, All rights reserved.
	Nothing in these files or/and code may be reproduced, adapted, merged or
	modified without prior written consent of the original author, Cpt. Hazama
--------------------------------------------------*/
AddCSLuaFile('server/cpt_utilities.lua')
include('server/cpt_utilities.lua')

// Combine
CPTBase.AddNPC("Combine Assasssin","npc_cpt_cassassin","CPTBase Redux")
CPTBase.AddNPC("Mortar Synth","npc_cpt_mortarsynth","CPTBase Redux")
-- CPTBase.AddNPC("Combine APC","npc_cpt_apc","CPTBase Redux")

// Zombies + Enemy Aliens
CPTBase.AddNPC("Puker Zombie","npc_cpt_pukerzombie","CPTBase Redux")
CPTBase.AddNPC("Ichthyosaur","npc_cpt_icky","CPTBase Redux")

CPTBase.AddConVar("cpt_corpselifetime",100)

CPTBase.AddParticleSystem("particles/cpt_darkmessiah.pcf",{}) -- I made these myself :)
CPTBase.AddParticleSystem("particles/cpt_mutation.pcf",{})
CPTBase.AddParticleSystem("particles/mininuke.pcf",{}) -- Credits to Silverlan
CPTBase.AddParticleSystem("particles/mortarsynth_fx.pcf",{}) -- Credits to Silverlan
CPTBase.AddParticleSystem("particles/WEAPON_FX.pcf",{})

game.AddAmmoType({name="9×19mm",dmgtype=DMG_BULLET})
game.AddAmmoType({name="5.7×28mm",dmgtype=DMG_BULLET})
game.AddAmmoType({name="darkpulseenergy",dmgtype=DMG_DISSOLVE})
game.AddAmmoType({name="defaultammo",dmgtype=DMG_BULLET})