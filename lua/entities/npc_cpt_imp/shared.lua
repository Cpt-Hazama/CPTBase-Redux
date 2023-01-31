ENT.Base = "npc_cpt_base"
ENT.Type = "ai"
ENT.PrintName = "NPC"
ENT.Author = "Cpt. Hazama"
ENT.Category = "Category"

if CLIENT then
    local scale = 1.45
    local offset = Vector(0,-40,51)
    function ENT:Initialize()
        local collData = self:GetCollisionBounds()
	    self:SetRenderBounds(Vector(collData.x *2.5,collData.y *2.5,collData.z *2.5),Vector(-collData.x *2.5,-collData.y *2.5,0))
    end

    function ENT:Draw()
        CPTBase.RenderSprite(self,"imp",self:GetSpriteAnim(),scale,offset,offset.z /2)
    end

    CPTBase.AddSpriteAnimation("imp",{
        Sequence = "move",
        Activity = ACT_WALK,
        Dir = "sprites/models/cpthazama/doom/imp/",
        Frames = {
            ["N"] = {
                "trooa1",
                "troob1",
                "trooc1",
                "trood1"
            },
            ["S"] = {
                "trooa5",
                "troob5",
                "trooc5",
                "trood5"
            },
            ["SW"] = {
                "trooa4a6",
                "troob4b6",
                "trooc4c6",
                "trood4d6"
            },
            ["W"] = {
                "trooa3a7",
                "troob3b7",
                "trooc3c7",
                "trood3d7"
            },
            ["NW"] = {
                "trooa2a8",
                "troob2b8",
                "trooc2c8",
                "trood2d8"
            },
            ["NE"] = {
                "trooa2a8",
                "troob2b8",
                "trooc2c8",
                "trood2d8"
            },
            ["E"] = {
                "trooa3a7",
                "troob3b7",
                "trooc3c7",
                "trood3d7"
            },
            ["SE"] = {
                "trooa4a6",
                "troob4b6",
                "trooc4c6",
                "trood4d6"
            },
        },
        FPS = 5,
        MultiDirection = true,
        FlipSet = {
            ["SE"] = true,
            ["E"] = true,
            ["NE"] = true,
        },
        Loop = true
    })

    CPTBase.AddSpriteAnimation("imp",{
        Sequence = "attack",
        Activity = ACT_RANGE_ATTACK1,
        Dir = "sprites/models/cpthazama/doom/imp/",
        Frames = {
            ["N"] = {
                "trooe1",
                "troof1",
                "troog1",
            },
            ["NW"] = {
                "trooe2e8",
                "troof2f8",
                "troog2g8",
            },
            ["W"] = {
                "trooe3e7",
                "troof3f7",
                "troog3g7",
            },
            ["SW"] = {
                "trooe4e6",
                "troof4f6",
                "troog4g6",
            },
            ["S"] = {
                "trooe5",
                "troof5",
                "troog5",
            },
            ["SE"] = {
                "trooe4e6",
                "troof4f6",
                "troog4g6",
            },
            ["E"] = {
                "trooe3e7",
                "troof3f7",
                "troog3g7",
            },
            ["NE"] = {
                "trooe2e8",
                "troof2f8",
                "troog2g8",
            },
        },
        FPS = 5,
        MultiDirection = true,
        FlipSet = {
            ["SE"] = true,
            ["E"] = true,
            ["NE"] = true,
        },
        Events = {
            {Frame = 3, Event = "attack"}
        }
    })
end