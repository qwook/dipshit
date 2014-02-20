
local PhysEntity = reload("entities.physentity")
local Controller = reload("controller")
local Entity = class("Player", PhysEntity, Controller)
Entity.spritesheet = SpriteSheet:new("sprites/dude.png", 32, 32)

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

    self.noclip = false
    self.facing = 1
end

function Entity:isPlayer()
    return true
end

function Entity:setNoClip(bool)
    self.noclip = bool

    if bool == true then
        self:setGravityScale(0)
    else
        self:setGravityScale(1)
    end
end

function Entity:isNoClipped()
    return self.noclip
end

function Entity:draw()
    love.graphics.scale(2)
    love.graphics.setColor(255, 255, 255)
    self.spritesheet:draw(8, 0, -self.facing*12, -19, 0, self.facing, 1)
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
            self.facing = 1
        elseif self:isKeyDown("left") then
            if velx > -200 then
                self:applyForce(-500, 0)
            end
            self.facing = -1
        elseif self.noclip then
            self:applyForce(-velx, -vely)
        end

        if self:isKeyDown("jump") and self.jumpTimer <= 0 then
            -- when you jump, push us back a bit
            -- and apply the vertical impulse
            self:applyLinearImpulse(-velx*0.05, -40)
            self.jumpTimer = 0.5
            self.shortJumpTimer = 0.075
        end
    else
        -- we go slower in the air
        if self:isKeyDown("right") then
            if velx < 200 then
                self:applyForce(250, 0)
            end
            self.facing = 1
        elseif self:isKeyDown("left") then
            if velx > -200 then
                self:applyForce(-250, 0)
            end
            self.facing = -1
        elseif self.noclip then
            self:applyForce(-velx, -vely)
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

    if self.noclip then
        if self:isKeyDown("lookup") then
            if vely > -200 then
                self:applyForce(0, -250)
            end
        elseif self:isKeyDown("lookdown") then
            if vely < 200 then
                self:applyForce(0, 250)
            end
        end
    end

end

function Entity:beginContact(other, contact, isother)
    self.super:beginContact(other, contact, isother)

    -- detect if we hit the wall, if we did set the friction to 0
    local nx, ny = contact:getNormal()
    if not isother then
        nx = -nx
        ny = -ny
    end

    -- find the angle between the hit normal and the up vector
    local ang = math.angle(0, -1, nx, ny)
    if ang >= math.pi/2 then
        contact:setFriction(0)
    end
end

console:addConCommand("noclip", function()
    for k, pl in pairs(world:getPlayers()) do
        pl:setNoClip(not pl.noclip)
    end
end)

return Entity

