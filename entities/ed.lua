
local PhysEntity = reload("entities.physentity")
local Entity = class("Ed", PhysEntity)
Entity.spritesheet =
    SpriteSheet:new("sprites/keepedup_ed.gif", 64, 64)

function Entity:initialize(...)
    PhysEntity.initialize(self, ...)
    self.shape = love.physics.newCircleShape(32);
end

function Entity:update(dt)
end

function Entity:draw()
    self.spritesheet:draw(0, 0, 0, 0, 0, 1, 1);
end

return Entity
