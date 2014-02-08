
BaseEntity = require("entities.core.baseentity")

Goomba = class("Goomba", BaseEntity)
Goomba.spritesheet = SpriteSheet:new("sprites/misterf.png", 64, 32)

function Goomba:initialize()
    BaseEntity.initialize(self)
    self.collisiongroup = "shared"
    self.nextAttack = 0
    self.coconut = nil
    self.anim = 0
    self.ang = 1
end

function Goomba:shouldCollide(other)
    if other.isCoconut then
        return false
    end
end

function Goomba:initPhysics()
    local shape = love.physics.newRectangleShape(32, 32)
    self:makeSolid("dynamic", shape)
end

function Goomba:getGoal()
    local goal
    local x, y = self:getPosition()

    local distancePlayer1 = math.distance(x, y, player:getPosition())
    local distancePlayer2 = math.distance(x, y, player2:getPosition())

    if (distancePlayer1 < distancePlayer2) then
        goal = player
    end

    if (distancePlayer2 < distancePlayer1) then
        goal = player2
    end

    return goal
end

function Goomba:update(dt)
end

function Goomba:draw()
    love.graphics.scale(self.ang, 1)
    self.spritesheet:draw(self.anim, 0, -32, -16)
end

return Goomba
