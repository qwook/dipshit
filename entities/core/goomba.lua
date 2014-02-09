
shaders = require("core.shaders")
BaseEntity = require("entities.core.baseentity")
NPCBullet = require("entities.npcbullet")

Goomba = class("Goomba", BaseEntity)
Goomba.spritesheet = SpriteSheet:new("sprites/misterf.png", 64, 32)

function Goomba:initialize()
    BaseEntity.initialize(self)

    -- control variables
    self.type = "NPC"
    self.collisiongroup = "shared"
    self.attackDelay = 0.05
    self.reloadDelay = 0.5
    self.clipsize = 5
    self.cone = 60 -- in radians
    self.health = 20 -- health
    self.range = 250 -- range of attack
    self.shootFacingPlayer = false -- shoot only facing player
    self.canAim = true -- can it aim at the player?

    -- dependent variables
    self.nextAttack = 0
    self.anim = 0
    self.dir = 1
    self.nextAttack = self.attackDelay
    self.nextReload = self.reloadDelay
    self.clip = self.clipsize
    self.lastDamaged = 0
end

function Goomba:postSpawn()
    self.nextAttack = tonumber(self:getProperty("initialdelay") or 0.05)
    self.attackDelay = tonumber(self:getProperty("attackdelay") or 0.05)
    self.reloadDelay = tonumber(self:getProperty("reloaddelay") or 0.5)
    self.clipsize = tonumber(self:getProperty("clipsize") or 5)
    self.cone = tonumber(self:getProperty("cone") or 60) -- in radians
    self.health = tonumber(self:getProperty("health") or 20) -- health
    self.range = tonumber(self:getProperty("range") or 250) -- range of attack
    self.shootFacingPlayer = self:getProperty("shootfaceingplayer") == "true" -- shoot only facing player
    self.canAim = self:getProperty("canaim") == "true" -- shoot only facing player
end

function Goomba:inflictDamage(dmg)
    self.lastDamaged = 0.05
    self.health = self.health - dmg
    if self.health < 0 then
        self:destroy()
    end
end

function Goomba:shouldCollide(other)
    if other.type == "NPC" then
        return false
    end
end

function Goomba:initPhysics()
    local shape = love.physics.newRectangleShape(32, 32)
    self:makeSolid("dynamic", shape)
    self:setFixedRotation(true)
    self:setFriction(0.1)
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

function Goomba:canAttack()
    local goal
    local x, y = self:getPosition()

    local p1x, p1y = player:getPosition()
    local p2x, p2y = player2:getPosition()

    local distancePlayer1 = math.distance(x, y, p1x, p1y)
    local distancePlayer2 = math.distance(x, y, p2x, p2y)

    if self.nextReload >= 0 then return false end

    if self.shootFacingPlayer then

        if self.ang == 1 then
            if p1x < x and p2x < x then return false end
        elseif self.ang == -1 then
            if p1x > x and p2x > x then return false end
        end

    end

    if distancePlayer1 < self.range or distancePlayer2 < self.range then
        return true
    end

    return false
end

function Goomba:update(dt)

    -- this is for the flashing effect
    if self.lastDamaged >= 0 then
        self.lastDamaged = self.lastDamaged - dt
    end

    if self.nextReload >= 0 then
        self.nextReload = self.nextReload - dt
    end

    if self:canAttack() then
        if self.nextAttack >= 0 then
            self.nextAttack = self.nextAttack - dt
        else
            self.nextAttack = self.attackDelay

            local aimangle
            local goal = self:getGoal()
            if self.canAim and goal then
                local x, y = self:getPosition()
                local gx, gy = goal:getPosition()
                local ang = math.atan2(gy - y, gx - x)
                aimangle = ang + math.random(-self.cone, self.cone)/180
            else
                aimangle = (math.pi/2 - self.ang * (math.pi/2)) + math.random(-self.cone, self.cone)/180
            end

            local bullet = NPCBullet:new()
            bullet:setPosition(self:getPosition())
            bullet:initPhysics()
            bullet:setVelocity(250*math.cos(aimangle), 250*math.sin(aimangle))
            bullet:spawn()
            self.clip = self.clip - 1
            if self.clip <= 0 then
                self.clip = self.clipsize
                self.nextReload = self.reloadDelay
            end
        end
    end

    local vx, vy = self:getVelocity()

    if self.dir == -1 then
        self.ang = 1
        if vx < 20 then
            self:applyForce(1000, 0)
        else
            self:applyForce(300, 0)
        end
    elseif self.dir == 1 or self.dir == 0 then
        self.ang = -1
        if vx > -20 then
            self:applyForce(-1000, 0)
        else
            self:applyForce(-300, 0)
        end
    end

    -- if we seem to be stuck, try going a different direction.
    if math.length(self:getVelocity()) == 0 then
        if self.dir == -1 then
            -- self.dir = 1
            -- self:applyForce(-300, 0)
        elseif self.dir == 1 then
            -- self.dir = -1
            -- self:applyForce(100, 0)
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
        -- self.dir = math.sign(z)
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

        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.rectangle("fill", -32, -16, 64, 32)

        love.graphics.setStencil()

    end
end

return Goomba
