
local BaseGM = reload("gamemodes.basegm")
local GameMode = class("MapEditor", BaseGM)

function GameMode:initialize()
    self.super:initialize()

    local player = entityfactory:create("player")
    player:setPos(0, 0)
    player:spawn()
    player:setNoClip(true)

    self.scale = 1
end

function GameMode:exit()
    print("yo")
end

function GameMode:transformPoint(x, y)
    local cx, cy, cs = self:calcView()
    return x/cs + cx - (love.graphics.getWidth()/cs/2), y/cs + cy - (love.graphics.getHeight()/cs/2)
end

function GameMode:postDraw()
    love.graphics.setColor(255, 255, 0)
    local x, y = self:transformPoint(love.mouse.getX(), love.mouse.getY())
    -- love.graphics.circle("fill", x, y, 20, 20)
    love.graphics.rectangle("line", math.floor(x/32)*32, math.floor(y/32)*32, 32, 32)
end

function GameMode:calcView()
    local x, y, scale = self.super:calcView()
    return x, y, self.scale
end

function GameMode:onMousePressed(x, y, button)
    if button == "wu" then
        self.scale = self.scale * (5/4)
    elseif button == "wd" then
        self.scale = self.scale * (4/5)
    end
end

return GameMode
