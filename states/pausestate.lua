
local BaseState = require("states.basestate")
local PauseState = class("PauseState", BaseState)

console = loveframes.Create("frame")
console:SetName("Console")
console:SetState("pause")
console:SetPos(10, 10)
console:SetSize(400, 400)
console:ShowCloseButton(false)

local textbox = loveframes.Create("textinput", console)
textbox:SetPos(5, 5 + 24)
textbox:SetSize(400-10, 400-24-5-5-5-26)
textbox:SetEditable(false)
textbox:SetMultiline(true)

local textinput = loveframes.Create("textinput", console)
textinput:SetPos(5, 400-26-5)
textinput:SetSize(400-10, 26)
textinput.OnEnter = function(self, text)
    self:SetText("")
    textbox:SetText(textbox:GetText() .. "\n> " .. text)
end

function PauseState:initialize()
    console:SetVisible(true)
    textinput:SetFocus(true)
end

function PauseState:exit()
end

function PauseState:update(dt)
end

function PauseState:draw(dt)
    love.graphics.setColor(0, 0, 0, 50)
    love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(255, 255, 255)
    love.graphics.print("Paused.", 0, 0)
end

function PauseState:keypressed(key, isrepeat)
    if key == "escape" then
        statemanager:pop()
    elseif key == "q" then
        -- statemanager:setState("menu")
    end
end

return PauseState
