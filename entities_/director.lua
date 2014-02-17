
BaseEntity = require("entities.core.baseentity")

Director = class("Director", BaseEntity)

function Director:initialize(x, y, w, h)
    BaseEntity.initialize(self)
    self.width = w
    self.height = h
    self.solid = false
    self.touching = {}
end

function Director:initPhysics()
    local shape = love.physics.newRectangleShape(self.width, self.height)
    self:makeSolid("static", shape)
    self:setSensor(true)

    self.hasPressedLastUpdate = false
    self.TriggerDelay = 0
end

function Director:update(dt)
    for _, other in ipairs(self.touching) do
        local filter = self:getProperty("filter")
        if (filter and filter == other.name) or (not filter and other.type == "PLAYER") then
            self:trigger("ontouching", other)
        end
    end
end

function Director:draw()
    if not DEBUG then return end
    love.graphics.setColor(0, 255, 0, 100)
    love.graphics.rectangle('fill', -self.width/2, -self.height/2, self.width, self.height)
    love.graphics.rectangle('line', -self.width/2, -self.height/2, self.width, self.height)
end

function Director:beginContact(other, contact, isother)
    local filter = self:getProperty("filter")

    if filter and other.name ~= filter then
        return
    end

    if other.type == "NPC" then
        if self:getProperty("direction") == "left" then
            other.dir = 1
        elseif self:getProperty("direction") == "right" then
            other.dir = -1
        end
    end
end

function Director:endContact(other, contact, isother)
end

return Director
