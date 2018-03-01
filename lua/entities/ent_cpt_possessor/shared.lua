ENT.Base 			= "base_gmodentity"
ENT.Type 			= "anim"
ENT.PrintName 		= "Possessor Entity"
ENT.Author 			= "Cpt. Hazama"
ENT.Contact 		= ""
ENT.Purpose 		= ""
ENT.Instructions 	= ""
ENT.Category		= "CPTBase"

ENT.Spawnable 		= false
ENT.AdminSpawnable 	= false

if (CLIENT) then
	function ENT:Draw() end
	net.Receive("cpt_ControllerView",function(len,pl)
		local delete = net.ReadBool()
		local maxhp = net.ReadFloat()
		local hp = net.ReadFloat()
		local class = net.ReadString()
		local name = language.GetPhrase(class)
		local mutated = net.ReadString()
		local healthcolor = Color(33,255,0)
		local mutatecolor = Color(255,0,191,math.abs(math.sin(CurTime() *2) *255))
		hook.Add("HUDPaint","cpt_DrawNPCHealth",function()
			if delete == true then
				hook.Remove("HUDPaint","cpt_DrawNPCHealth")
			end
			surface.SetFont("TargetID")
			local DisplayNameSize = surface.GetTextSize(name)
			if DisplayNameSize < ScrW() *0.05 then
				DisplayNameSize = ScrW() *0.05
			end
			local DisplayHealthSize = ((DisplayNameSize /maxhp) *hp)
			DisplayHealthSize = DisplayHealthSize +ScrW() *0.00375
			DisplayNameSize = DisplayNameSize +ScrW() *0.00375
			local DisplaySizeBox = DisplayNameSize +ScrW() *0.015
			
			draw.RoundedBox(8,ScrW() *0.5 -DisplaySizeBox *0.5,ScrH() *0.025,DisplaySizeBox,ScrH() *0.05,Color(10,10,10,150)) // Box
			draw.SimpleText(name,"TargetID",ScrW() *0.5,ScrH() *0.037,Color(255,255,255,255),1,1) // NPC Name
			if hp <= 0 then return end
			if mutated == "false" then
				if hp <= (maxhp * 1) && hp > (maxhp *0.66) then
					healthcolor = Color(33,255,0)
				elseif hp <= (maxhp * 0.66) && hp > (maxhp *0.33) then
					healthcolor = Color(255,255,0)
				elseif hp <= (maxhp * 0.33) then
					healthcolor = Color(255,0,0)
				end
			else
				healthcolor = mutatecolor
				surface.SetMaterial(Material("cptbase/mutation"))
				surface.SetDrawColor(mutatecolor)
				surface.DrawTexturedRect(ScrW() *0.4628,ScrH() *0.051,24,24)
			end
			draw.SimpleText("HP: " .. hp,"TargetID",ScrW() *0.5,ScrH() *0.051,Color(255,255,255,255),1,1) // NPC Health Amount
			draw.RoundedBox(4,ScrW() *0.5 -DisplayNameSize *0.5,ScrH() *0.06,DisplayNameSize,ScrH() *0.008333,Color(10,10,10,200)) // NPC Health Box Background
			draw.RoundedBox(4,ScrW() *0.5 -DisplayNameSize *0.5,ScrH() *0.06,DisplayHealthSize,ScrH() *0.008333,healthcolor) // NPC Health Box
		end)
	end)
end