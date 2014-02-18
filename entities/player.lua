

local PhysEntity = reload("entities.physentity")
local Controller = reload("controller")
local Entity = class("Player", PhysEntity, Controller)

Entity.phystype = "dynamic"
Entity.density = 1
Entity.mass = 1
Entity.w = 32
Entity.h = 32

function Entity:initialize(...)
    Controller.initialize(self, ...)
    PhysEntity.initialize(self, ...)

    self.shape = love.physics.newPolygonShape(-10, -30,
                                              -10, 10,
                                              10*math.cos(math.pi*(3/4)), 10 + 10*math.sin(math.pi*(3/4)),
                                              0, 10,
                                              10*math.cos(math.pi/4), 10 + 10*math.sin(math.pi/4),
                                              10, 10,
                                              10, -30)
end

function Entity:spawn(context)
    self.super:spawn(context)
    world:addPlayer(self)

    self:setFixedRotation(true)
    self:setFriction(0.75)

    self.jumpTimer = 0
    self.shortJumpTimer = 0
end

function Entity:draw()
    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle("fill", -self.w/2, -self.h/2, self.w, self.h)
end

function Entity:update(dt)
    self:handleMovement(dt)
end

function Entity:calculateFloor()
    for contact, isother in pairs(self.contacts) do
        if contact:isTouching() then
            local nx, ny = contact:getNormal()
            if not isother then
                nx = -nx
                ny = -ny
            end

            -- find the angle between the hit normal and the up vector
            local ang = math.angle(0, -1, nx, ny)
            if ang < math.pi/2 then
                return contact
            end
        end
    end
end

function Entity:handleMovement(dt)
    local velx, vely = self:getVelocity()

    if self.jumpTimer > 0 then
        self.jumpTimer = self.jumpTimer - dt
    end

    local floor = self:calculateFloor()

    if floor ~= nil then
        if self:isKeyDown("right") then
            if velx < 200 then
                self:applyForce(500, 0)
            end
        elseif self:isKeyDown("left") then
            if velx > -200 then
                self:applyForce(-500, 0)
            end
        end

        if self:isKeyDown("jump") and self.jumpTimer <= 0 then
            self:applyLinearImpulse(0, -40)
            self.jumpTimer = 0.5
            self.shortJumpTimer = 0.075
        end
    else
        -- we go slower in the air
        if self:isKeyDown("right") then
            if velx < 200 then
                self:applyForce(250, 0)
            end
        elseif self:isKeyDown("left") then
            if velx > -200 then
                self:applyForce(-250, 0)
            end
        end


        -- we just jumped, allow for a longer jump
        if self.shortJumpTimer > 0 and self:isKeyDown("jump") then
            self:applyForce(0, -350)
            self.shortJumpTimer = self.shortJumpTimer - dt
        else
            -- OCD.. constantly make sure we can't short jump
            self.shortJumpTimer = 0
        end
    end
end

return Entity

