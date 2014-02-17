
local BaseState = require("states.basestate")
local GameState = class("GameState", BaseState)

local ent = nil

function GameState:initialize()
    ent = entityMap["baseentity"]:new()
end

function GameState:update(dt)
    local x, y = ent:getPos()
    ent:setPos(x + dt, y)
end

function GameState:draw(dt)
    love.graphics.setColor(255, 0, 0)
    love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(255, 255, 255)
    love.graphics.print("Game.", 0, 0)

    ent:draw()
end

function GameState:keypressed(key, isrepeat)
    if key == "escape" then
        statemanager:push("pause")
    end
end

return GameState
