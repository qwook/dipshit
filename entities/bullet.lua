
BaseEntity = require("entities.core.baseentity")
Blood = require("entities.particles.blood")

Bullet = class("Bullet", BaseEntity)
Bullet.image = loadImage("sprites/bullet.gif")

function Bullet:initialize()
    BaseEntity.initialize(self)
    self.type = "BULLET"
    self.nextDie = 0.5
end

function Bullet:shouldCollide(other)
    if other.type == "PLAYER" or other.type == "TILE" or other.type == "BULLET" then
        return false
    end
end

function Bullet:initPhysics()
    local shape = love.physics.newCircleShape(8)
    self:makeSolid("dynamic", shape)
    self:setMass(0.01)
    self:setFriction(0)
    self:setGravityScale(0)
end

function Bullet:update(dt)
    self.nextDie = self.nextDie - dt
    if self.nextDie <= 0 then
        self:destroy()
    end
end

function Bullet:draw()
    local vx, vy = self:getVelocity()
    love.graphics.rotate(math.atan2(vy, vx))
    love.graphics.draw(self.image, -16-8, -16-16, 0, 2, 2)
end

function Bullet:beginContact(other, contact, isother)
    if other.isSensor and other:isSensor() then return end

    local nx, ny = contact:getNormal()
    local x, y = contact:getPositions()

    timer:onNextUpdate(function()
        if other.inflictDamage then

            local blood = Blood:new(other.blood)
            blood:setPosition(x - nx*5, y - ny*5)
            blood:setAngle(math.atan2(ny, nx))
            blood:spawn()

            other:inflictDamage(10)
     
                player2:addScore(5)
            
        end
    end)
    
    self:destroy()
end

return Bullet
