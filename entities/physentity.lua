
------------------------------------------------
-- Entity with physical properties.

local BaseEntity = reload("entities.baseentity")
local Entity = class("PhysEntity", BaseEntity)

Entity.phystype = "dynamic"
Entity.density = 1
Entity.mass = 0.1
Entity.w = 40
Entity.h = 40

function Entity:initialize(...)
    self.super:initialize(...)

    self.contacts = {}
    self.shape = love.physics.newRectangleShape(Entity.w-0.1, Entity.h-0.1)
end

function Entity:initPhysics()
    if not self.shape then
        error("No shape defined for entity!")
    end

    self.body = love.physics.newBody(world:getPhysWorld(), self.x, self.y, self.phystype)
    self.fixture = love.physics.newFixture(self.body, self.shape, self.density)
    self.fixture:setUserData(self)
    self.body:setMass(self.mass)
end

function Entity:spawn()
    self.super:spawn()
    self:initPhysics()
end

function Entity:setPos(x, y)
    self.x = x
    self.y = y
    if self.body then
        return self.body:setPosition(x, y)
    end
end

function Entity:getPos()
    if not self.body then
        return self.x, self.y
    end
    return self.body:getPosition()
end

function Entity:setAngle(ang)
    self.ang = ang
    if self.body then
        return self.body:setAngle(ang)
    end
end

function Entity:getAngle()
    if not self.body then
        return self.ang
    end
    return self.body:getAngle()
end

function Entity:setMass(mass)
    self.mass = mass
    if self.body then
        self.body:setMass(mass)
    end
end

function Entity:getMass()
    if self.body then
        return self.mass
    end
    return self.body:getMass()
end

function Entity:setVelocity(vx, vy)
    if self.body then
        self.body:setLinearVelocity(vx, vy)
    end
end

function Entity:getVelocity()
    if self.body then
        return self.body:getLinearVelocity()
    end
    error("Physics used before initiated!")
end

function Entity:setTorque(ta)
    if self.body then
        self.body:setAngularVelocity(ta)
    end
end

function Entity:getTorque()
    if self.body then
        return self.body:getAngularVelocity()
    end
    error("Physics used before initiated!")
end

function Entity:setFixedRotation(bool)
    if self.body then
        self.body:setFixedRotation(bool)
    end
end

function Entity:isFixedRotation()
    if self.body then
        return self.body:isFixedRotation()
    end
    error("Physics used before initiated!")
end

function Entity:setFriction(friction)
    if self.fixture then
        self.fixture:setFriction(friction)
    end
end

function Entity:getFriction()
    if self.fixture then
        return self.fixture:getFriction()
    end
    error("Physics used before initiated!")
end

function Entity:setGravityScale(scale)
    if self.body then
        self.body:setGravityScale(scale)
    end
end

function Entity:getGravityScale()
    if self.body then
        return self.body:getGravityScale()
    end
    error("Physics used before initiated!")
end

function Entity:applyForce(fx, fy)
    if self.body then
        self.body:applyForce(fx, fy)
    end
end

function Entity:applyLinearImpulse(ix, iy)
    if self.body then
        self.body:applyLinearImpulse(ix, iy)
    end
end

function Entity:beginContact(other, contact, isother)
    self.contacts[contact] = isother
end

function Entity:endContact(other, contact, isother)
    self.contacts[contact] = nil
end

function Entity:preSolve(other, contact, isother)
end

function Entity:postSolve(other, contact, normal, tangent, isother)
end

return Entity
