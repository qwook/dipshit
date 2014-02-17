
local Controller = require("controller")
local MenuController = class("MenuController", Controller)

local BaseState = require("states.basestate")
local MenuState = class("MenuState", BaseState)

function MenuState:initialize()
    self.controller = MenuController:new()
    self.controllers = {self.controller}
end

function MenuState:update(dt)
    if self.controller:wasKeyPressed("attack") then
        statemanager:setState("game")
    end
end

function MenuState:draw(dt)
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(255, 255, 255)
    love.graphics.print("Menu. Press fire to start the game.", 0, 0)
end

function MenuState:keypressed(key, isrepeat)
end

return MenuState
