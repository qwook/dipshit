
local BaseState = require("states.basestate")
local MenuState = class("MenuState", BaseState)

function MenuState:initialize()
end

function MenuState:update(dt)
end

function MenuState:draw(dt)
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(255, 255, 255)
    love.graphics.print("Menu. Press enter to start the game.", 0, 0)
end

function MenuState:keypressed(key, isrepeat)
    if key == "enter" or key == "return" then
        statemanager:setState("game")
    end
end

return MenuState
