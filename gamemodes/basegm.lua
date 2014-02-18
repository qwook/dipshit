
local GameMode = class("BaseGM")

-- the initialize function needs to follow a strict rule
-- of only initializing instance variables
-- calling functions inside here will possibily break it
function GameMode:initialize()
    world:setGravity(0, 400)

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

function GameMode:exit()
end

function GameMode:update(dt)
end

function GameMode:draw()
    love.graphics.setColor(255, 0, 0)
    love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(255, 255, 255)
    love.graphics.print("Game!", 0, 0)
end

function GameMode:postDraw()
    -- draw health and shit here
end

function GameMode:onKeyPressed(key)
end

function GameMode:onKeyReleased(key)
end

-- function GameMode:getControllers()
--     return {}
-- end

-- todo:

function GameMode:calcView()
    -- returns x, y, scale of camera position
    return 0, 0, 1
end

function GameMode:onPlayerSpawn(player)
end

function GameMode:onPlayerDeath(player)
end

function GameMode:onPlayerKeyPressed(player, key)
end

function GameMode:onPlayerKeyReleased(player, key)
end

function GameMode:onMousePressed(x, y, button)
end

function GameMode:onMouseReleased(x, y, button)
end

-- this adds a bit of overhead
-- but checks for newly created instance variables
-- and deleted variables
-- if arguments["watch"] then
--     function GameMode:__index(index)
--         local class = getmetatable(self)

--         local obj = {}
--         local o = setmetatable(obj, class)
--         class.initialize(o)

--         for k, v in pairs(obj) do
--             if not rawget(self, k) then
--                 rawset(self, k, v)
--             end
--         end

--         for k, v in pairs(self) do
--             if not rawget(obj, k) then
--                 rawset(self, k, nil)
--             end
--         end

--         local ret = rawget(self, index) or class[index]
--         if not ret and class.super then
--             return class.super[index]
--         end
--         return ret
--     end
-- end

return GameMode
