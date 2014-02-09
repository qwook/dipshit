
Particle = require("entities.core.particle")

Blood = class("Particle", Particle)
Blood.spritesheet = SpriteSheet:new("sprites/blood.png", 32, 32)

function Blood:initialize()
    Particle.initialize(self)

    self.scale = 1
    self.velx = 0
    self.vely = 0
    self.flashtime = 0.15
    self.lifetime = 0.5
end

function Blood:setVelocity(velx, vely)
    self.velx = velx
    self.vely = vely
end

function Blood:setScale(scale)
    self.scale = scale
end

function Blood:update(dt)
    Particle.update(self, dt)

    self.flashtime = self.flashtime - dt
    self.x = self.x + self.velx * dt
    self.y = self.y + self.vely * dt
end

function Blood:draw()
    love.graphics.scale(2)
    love.graphics.setColor(255, 0, 0)
    if self.flashtime > 0 then
        love.graphics.setColor(255, 255, 255)
    end
    self.spritesheet:draw(math.floor((0.5 - self.lifetime)/0.5*6)%6, 0, -16, -16)
end

return Blood
