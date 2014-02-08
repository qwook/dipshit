
shaders = require("core.shaders")
BaseEntity = require("entities.core.baseentity")

Goomba = class("Goomba", BaseEntity)
Goomba.spritesheet = SpriteSheet:new("sprites/misterf.png", 64, 32)

function Goomba:initialize()
    BaseEntity.initialize(self)
    self.collisiongroup = "shared"
    self.nextAttack = 0
    self.coconut = nil
    self.anim = 0
    self.dir = 1

    self.lastDamaged = 0
end

function Goomba:inflictDamage(dmg)
    self.lastDamaged = 0.05
end

function Goomba:shouldCollide(other)
end

function Goomba:initPhysics()
    local shape = love.physics.newRectangleShape(32, 32)
    self:makeSolid("dynamic", shape)
    self:setFixedRotation(true)
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

    -- this is for the flashing effect
    if self.lastDamaged >= 0 then
        self.lastDamaged = self.lastDamaged - dt
    end

    if self.dir == -1 then
        self:applyForce(250, 0)
    elseif self.dir == 1 or self.dir == 0 then
        self:applyForce(-250, 0)
    end

    -- if we seem to be stuck, try going a different direction.
    if math.length(self:getVelocity()) == 0 then
        if self.dir == -1 then
            self.dir = 1
        elseif self.dir == 1 then
            self.dir = -1
        end
    end
end

function Goomba:beginContact(other, contact, isother)
    local normx, normy = contact:getNormal()

    if isother == false then
        normx = -normx
        normy = -normy
    end

    -- detect a floor
    local x, y = self:getPosition()
    local x1, y1, x2, y2 = contact:getPositions()

    local id, id2 = contact:getChildren()
    if isother then id = id2 end -- `isother` means we are the second object

    if not (((y1 or y-1) > y+10 and (y2 or y+1) > y+10)) then
        local _, _, z = math.crossproduct(normx, normy, 0, 0, -1, 0)
        self.dir = math.sign(z)
    end
end

function Goomba:draw()
    love.graphics.scale(self.ang, 1)
    self.spritesheet:draw(0, 0, -32, -16)

    if self.lastDamaged > 0 then

        love.graphics.setStencil(function ()
            love.graphics.setShader(shaders.mask_effect)
            self.spritesheet:draw(0, 0, -32, -16)
            love.graphics.setShader()
        end)

        love.graphics.setColor(255, 255, 255, 150)
        love.graphics.rectangle("fill", -32, -16, 64, 32)

        love.graphics.setStencil()

    end
end

return Goomba
