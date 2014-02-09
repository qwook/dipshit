
BaseEntity = require("entities.core.baseentity")

NPCBullet = class("NPCBullet", BaseEntity)
NPCBullet.image = loadImage("sprites/bullet.gif")

function NPCBullet:initialize()
    BaseEntity.initialize(self)
    self.type = "BULLET"
    self.nextDie = 5
    playSound("smash.wav") -- fuck yo sound 
end

function NPCBullet:shouldCollide(other)
    if other.type == "NPC" or other.type == "TILE" or other.type == "BULLET" then
        return false
    end
end

function NPCBullet:initPhysics()
    local shape = love.physics.newCircleShape(4)
    self:makeSolid("dynamic", shape)
    self:setMass(0.01)
    self:setFriction(0)
    self:setGravityScale(0)
end

function NPCBullet:update(dt)
    self.nextDie = self.nextDie - dt
    if self.nextDie <= 0 then
        self:destroy()
    end
end

function NPCBullet:draw()
    local vx, vy = self:getVelocity()
    love.graphics.rotate(math.atan2(vy, vx))
    love.graphics.draw(self.image, -16-8, -16-16, 0, 2, 2)
end

function NPCBullet:beginContact(other, contact, isother)
    if other.isSensor and other:isSensor() then return end

    local nx, ny = contact:getNormal()
    local x, y = contact:getPositions()

    onNextUpdate(function()
        if other.inflictDamage then
            local blood = Blood:new()
            blood:setPosition(x - nx*5, y - ny*5)
            blood:setAngle(math.atan2(ny, nx))
            blood:spawn()

            other:inflictDamage(5)
        end
    end)

    self:destroy()
end

return NPCBullet
