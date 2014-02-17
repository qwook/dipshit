
local BaseState = require("states.basestate")
local GameState = class("GameState", BaseState)

function GameState:initialize()
end

function GameState:update(dt)
end

function GameState:draw(dt)
    love.graphics.setColor(255, 0, 0)
    love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(255, 255, 255)
    love.graphics.print("Game.", 0, 0)
end

function GameState:keypressed(key, isrepeat)
    if key == "escape" then
        statemanager:push("pause")
    end
end

return GameState
