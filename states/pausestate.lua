
local BaseState = require("states.basestate")
local PauseState = class("PauseState", BaseState)

consoleframe = loveframes.Create("frame")
consoleframe:SetName("Console")
consoleframe:SetState("pause")
consoleframe:SetPos(10, 10)
consoleframe:SetSize(400, 400)
consoleframe:ShowCloseButton(false)

local textbox = loveframes.Create("textinput", consoleframe)
textbox:SetPos(5, 5 + 24)
textbox:SetSize(400-10, 400-24-5-5-5-26)
textbox:SetEditable(false)
textbox:SetMultiline(true)

local inputQueue = {}
local inputQueueCursor = -1

local textinput = loveframes.Create("textinput", consoleframe)
textinput:SetPos(5, 400-26-5)
textinput:SetSize(400-10, 26)
textinput.OnEnter = function(self, text)
    inputQueueCursor = -1
    self:SetText("")
    textbox:SetText(textbox:GetText() .. "\n> " .. text)
    console:runString(text)
    if (inputQueue[#inputQueue] ~= text) then
        table.insert(inputQueue, text)
    end
    if (#inputQueue > 100) then
        table.remove(inputQueue, 1)
    end
end
local keypressed = textinput.keypressed
textinput.keypressed = function(self, key, unicode)
    if (#inputQueue > 0) then
        if (key == "up") then
            inputQueueCursor = inputQueueCursor + 1
            if (inputQueueCursor >= #inputQueue-1) then
                inputQueueCursor = #inputQueue-1
            end
            self:SetText(inputQueue[#inputQueue - inputQueueCursor])
        elseif (key == "down") then
            inputQueueCursor = inputQueueCursor - 1
            if (inputQueueCursor <= 0) then
                inputQueueCursor = 0
            end
            self:SetText(inputQueue[#inputQueue - inputQueueCursor])
        elseif (self:GetText():len() ~= 0) then
            inputQueueCursor = 0
        end
    end

    return getmetatable(textinput).keypressed(self, key, unicode)
end

-- overwrite the print function
-- capture all prints inside the ingame console box

local oprint = print
function print(...)
    textbox:SetText(textbox:GetText() .. "\n\n")
    for k, v in pairs({...}) do
        textbox:SetText(textbox:GetText() .. tostring(v) .. "\t")
    end
    oprint(...)
end

function PauseState:initialize()
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
    end
end

return PauseState
