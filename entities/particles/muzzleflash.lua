
Particle = require("entities.core.particle")

MuzzleFlash = class("Particle", Particle)
MuzzleFlash.spritesheet = SpriteSheet:new("sprites/muzzleflash.png", 32, 32)

function MuzzleFlash:initialize()
    Particle.initialize(self)

    self.scale = 1
    self.velx = 0
    self.vely = 0
    self.lifetime = 0.5
end

function MuzzleFlash:setVelocity(velx, vely)
    self.velx = velx
    self.vely = vely
end

function MuzzleFlash:setScale(scale)
    self.scale = scale
end

function MuzzleFlash:update(dt)
    Particle.update(self, dt)

    self.x = self.x + self.velx * dt
    self.y = self.y + self.vely * dt
end

function MuzzleFlash:draw()
    love.graphics.scale(2)
    self.spritesheet:draw(math.floor((0.5 - self.lifetime)/0.5*8)%8, 0, -16, -16)
end

return MuzzleFlash
