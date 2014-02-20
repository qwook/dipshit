
local BaseState = class("BaseState")

function BaseState:initialize()
end

function BaseState:exit()
end

function BaseState:update(dt)
end

function BaseState:draw(dt)
end

function BaseState:keypressed(key, isrepeat)
end

function BaseState:keyreleased(key)
end

function BaseState:mousepressed(x, y, button)
end

function BaseState:mousereleased(x, y, button)
end

function BaseState:textinput(unicode)
end

function BaseState:getControllers()
    return self.controllers or {}
end

return BaseState
