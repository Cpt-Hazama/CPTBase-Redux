if !CPTBase then return end
-------------------------------------------------------------------------------------------------------------------
local ENT_Meta = FindMetaTable("Entity")
local NPC_Meta = FindMetaTable("NPC")
local PLY_Meta = FindMetaTable("Player")
local WPN_Meta = FindMetaTable("Weapon")

function PLY_Meta:GetWeaponAmmoName()
	local CPTBase_DefaultAmmoTypes = {
		["weapon_physcannon"] = -1,
		["weapon_physgun"] = -1,
		["gmod_tool"] = -1,
		["weapon_crowbar"] = -1,
		["weapon_pistol"] = "9MM",
		["weapon_357"] = ".357",
		["weapon_smg1"] = "4.6×30MM",
		["weapon_ar2"] = "Pulse",
		["weapon_crossbow"] = "Bolt",
		["weapon_shotgun"] = "Buckshot",
		["weapon_frag"] = -1,
		["weapon_rpg"] = "RPG",
	}
	if ply:GetActiveWeapon().Primary then
		return ply:GetActiveWeapon().Primary.Ammo
	else
		return CPTBase_DefaultAmmoTypes[ply:GetActiveWeapon():GetClass()]
	end
end