
local PhysEntity = reload("entities.physentity")
local Entity = class("TileMap", PhysEntity)

Entity.phystype = "static"
Entity.density = 1
Entity.mass = 32
Entity.w = 1000
Entity.h = 40

function Entity:initialize(...)
    self.super:initialize(...)
    
    self.shape = love.physics.newRectangleShape(Entity.w, Entity.h)
end

function Entity:draw()
    love.graphics.setColor(255, 255, 0)
    love.graphics.rectangle("fill", -self.w/2, -self.h/2, self.w, self.h)
end

return Entity
