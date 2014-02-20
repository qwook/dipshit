
local BaseGM = reload("gamemodes.basegm")
local GameMode = class("ArcadeMode", BaseGM)

function GameMode:initialize()
    self.super:initialize()

    local player = entityfactory:create("player")
    player:setPos(50, 50)
    player:spawn()

    local player2 = entityfactory:create("player")
    player2:setPos(50, 50)
    player2:spawn()

    for i = 1, 15 do
        local ent = entityfactory:create("physentity")
        ent:setPos(0+20*i, 20)
        ent:spawn()

        ent:setVelocity(100, 0)
        ent:setTorque(math.random(-1, 1))
    end

    local tilemap = entityfactory:create("tilemap")
    tilemap:setPos(300, 400)
    tilemap:spawn()
end

function GameMode:postDraw()
end

return GameMode
