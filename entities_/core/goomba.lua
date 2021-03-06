
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
    self.stopBeforeShooting = false -- stop before shooting?
    self.bulletOffsetX = 0
    self.bulletOffsetY = 0

    -- dependent variables
    self.nextAttack = 0
    self.anim = 0
    self.dir = 1
    self.nextAttack = self.attackDelay
    self.nextReload = self.reloadDelay
    self.clip = self.clipsize
    self.lastDamaged = 0
    self.ang = 1
end

function Goomba:postSpawn()
    self.nextAttack = tonumber(self:getProperty("initialdelay") or self.nextAttack)
    self.attackDelay = tonumber(self:getProperty("attackdelay") or self.attackDelay)
    self.reloadDelay = tonumber(self:getProperty("reloaddelay") or self.reloadDelay)
    self.clipsize = tonumber(self:getProperty("clipsize") or self.clipsize)
    self.cone = tonumber(self:getProperty("cone") or self.cone) -- in radians
    self.health = tonumber(self:getProperty("health") or self.health) -- health
    self.range = tonumber(self:getProperty("range") or self.range) -- range of attack
    if self:getProperty("shootfaceingplayer") then
        self.shootFacingPlayer = self:getProperty("shootfaceingplayer") == "true" -- shoot only facing player
    end
    if self:getProperty("canaim") then
        self.canAim = self:getProperty("canaim") == "true" -- shoot only facing player
    end
    if self:getProperty("stopbeforeshooting") then
        self.stopBeforeShooting = self:getProperty("stopbeforeshooting") == "true" -- shoot only facing player
    end
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

function Goomba:getAimAngle()
    local x, y = self:getPosition()
    local goal = self:getGoal()
    local aimangle
    if self.canAim and goal then
        local gx, gy = goal:getPosition()
        local ang = math.atan2(gy - y, gx - x) or -1
        aimangle = ang + math.random(-self.cone, self.cone)/180
    else
        aimangle = (math.pi/2 - self.ang * (math.pi/2)) + math.random(-self.cone, self.cone)/180
    end

    return aimangle or 0
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

    local x, y = self:getPosition()

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

            local aimangle = self:getAimAngle()

            local bullet = NPCBullet:new()
            bullet:setPosition(x + self.bulletOffsetX*self.ang, y + self.bulletOffsetY)
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

    local vel = 0
    if self.dir == -1 then
        self.ang = 1
        if vx < 20 then
            vel = 1000
        else
            vel = 300
        end
    elseif self.dir == 1 or self.dir == 0 then
        self.ang = -1
        if vx > -20 then
            vel = -1000
        else
            vel = -300
        end
    end

    if not self.stopBeforeShooting or (self.stopBeforeShooting and not (self.nextReload < 0.5)) then
        self:applyForce(vel, 0)
    elseif (self.stopBeforeShooting and (self.nextReload < 0.5)) then
        self:applyForce(-vx, 0)
    end

end

function Goomba:beginContact(other, contact, isother)
    -- this code was used to detect walls and to reverse the direction
    -- of the npc when it hits a wall

    -- local normx, normy = contact:getNormal()

    -- if isother == false then
    --     normx = -normx
    --     normy = -normy
    -- end

    -- local x, y = self:getPosition()
    -- local x1, y1, x2, y2 = contact:getPositions()

    -- local id, id2 = contact:getChildren()
    -- if isother then id = id2 end -- `isother` means we are the second object

    -- if not (((y1 or y-1) > y+10 and (y2 or y+1) > y+10)) then
    --     local _, _, z = math.crossproduct(normx, normy, 0, 0, -1, 0)
        -- self.dir = math.sign(z)
    -- end
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
