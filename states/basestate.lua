
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

function BaseState:textinput(unicode)
end

return BaseState
