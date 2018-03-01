	-- World Settings --
TRACER_FLAG_USEATTACHMENT	= 0x0002;
SOUND_FROM_WORLD			= 0;
CHAN_STATIC					= 6;

	-- Main Settings --
EFFECT.Speed				= 7000;
EFFECT.Length				= 200;
-- EFFECT.WhizSound			= Sound("cpt_base/cpt_fx/nearmiss.wav"); // Makes a sound by default so this isn't neccessary
EFFECT.WhizDistance			= 72;

	-- Texture Settings --
local cpt_MainTexture		= Material("cptbase/muzzles/pulse_flutter"); // mat_texture_list 1
local cpt_FrontTexture		= Material("cptbase/muzzles/vortex"..math.random(1,2));
local cpt_MainTextureSize 	= 2;
local cpt_FrontTextureSize 	= 2;
local cpt_MainTextureColor 	= Color(255,255,255);
local cpt_FrontTextureColor = Color(255,255,255);

function EFFECT:GetTracerOrigin( data )

	local start = data:GetStart();

	if(bit.band(data:GetFlags(),TRACER_FLAG_USEATTACHMENT) == TRACER_FLAG_USEATTACHMENT) then
		local entity = data:GetEntity();
		if(not IsValid(entity)) then return start; end
		if(not game.SinglePlayer() && entity:IsEFlagSet(EFL_DORMANT)) then return start; end
		if(entity:IsWeapon() && entity:IsCarriedByLocalPlayer()) then
			local ply = entity:GetOwner();
			if(IsValid(ply)) then
				local vm = ply:GetViewModel();
				if(IsValid(vm) && not LocalPlayer():ShouldDrawLocalPlayer()) then
					entity = vm;
				else
					if(entity.WorldModel) then
						entity:SetModel(entity.WorldModel);
					end
				end
			end
		end

		local attachment = entity:GetAttachment(data:GetAttachment());
		if(attachment) then
			start = attachment.Pos;
		end

	end

	return start;

end


function EFFECT:Init( data )

	self.StartPos = self:GetTracerOrigin(data);
	self.EndPos = data:GetOrigin();

	self.Entity:SetRenderBoundsWS(self.StartPos,self.EndPos);

	local diff = (self.EndPos -self.StartPos);

	self.Normal = diff:GetNormal();
	self.StartTime = 0;
	self.LifeTime = (diff:Length() +self.Length)/self.Speed;

	local weapon = data:GetEntity();
	if(IsValid(weapon) && (not weapon:IsWeapon() or not weapon:IsCarriedByLocalPlayer())) then
		local dist, pos, time = util.DistanceToLine(self.StartPos,self.EndPos,EyePos());
	end

end


function EFFECT:Think()

	self.LifeTime = self.LifeTime -FrameTime();
	self.StartTime = self.StartTime +FrameTime(); 

	return self.LifeTime > 0;

end


function EFFECT:Render()

	local endDistance = self.Speed *self.StartTime;
	local startDistance = endDistance -self.Length;
	
	startDistance = math.max(0,startDistance);
	endDistance = math.max(0,endDistance);

	local startPos = self.StartPos +self.Normal *startDistance;
	local endPos = self.StartPos +self.Normal *endDistance;
	
	render.SetMaterial(cpt_FrontTexture);
	render.DrawBeam(startPos,endPos,cpt_FrontTextureSize,0,1,cpt_FrontTextureColor);

	render.SetMaterial(cpt_MainTexture);
	render.DrawBeam(startPos,endPos,cpt_MainTextureSize,0,1,cpt_MainTextureColor);

end
