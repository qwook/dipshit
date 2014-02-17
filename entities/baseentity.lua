
local BaseEntity = class("BaseEntity")

function BaseEntity:initialize()
    self.x = 0
    self.y = 0
end

function BaseEntity:setPos(x, y)
    self.x = x
    self.y = y
end

function BaseEntity:getPos()
    return self.x, self.y
end

function BaseEntity:draw()
    love.graphics.setColor(0, 255, 0)
    love.graphics.rectangle("fill",
        math.cos(self.x*10)*10 + 10, math.sin(self.x*10)*10 + 10,
        50, 50)

    love.graphics.setColor(0, 0, 0)
    love.graphics.print(self.x, math.cos(self.x*10)*10 + 10, math.sin(self.x*10)*10 + 10)
end

return BaseEntity












