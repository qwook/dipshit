
shaders =       require("core.shaders")
BaseEntity =    require("entities.core.baseentity")
NPCBullet =     require("entities.npcbullet")
Goomba =        require("entities.core.goomba")

SlimeGirl = class("SlimeGirl", Goomba)
SlimeGirl.spritesheet = SpriteSheet:new("sprites/slimegirlwalk.png", 32, 32)
SlimeGirl.spritesheet2 = SpriteSheet:new("sprites/slimegirlattack.png", 32, 32)

function SlimeGirl:initialize()
    Goomba.initialize(self)

    -- control variables
    self.type = "NPC"
    self.collisiongroup = "shared"
    self.attackDelay = 0.1
    self.reloadDelay = 1
    self.clipsize = 5
    self.cone = 5 -- in radians
    self.health = 100 -- health
    self.range = 250 -- range of attack
    self.shootFacingPlayer = false -- shoot only facing player
    self.canAim = false -- can it aim at the player?
    self.stopBeforeShooting = true
    self.bulletOffsetX = 5
    self.bulletOffsetY = -20
    self.blood = {r = 0, g = 255, b = 0}

    -- no touchy
    self.attackAnim = 0

    self.aimangle = math.pi/2
    self.aimangleGoal = -math.pi/2
end

function SlimeGirl:getAimAngle()
    self.aimangle = math.lerpAngle(self.aimangle, self.aimangleGoal, love.timer.getDelta()*10)
    return self.aimangle
end

function SlimeGirl:update(dt)
    Goomba.update(self, dt)

    if self.nextReload <= 0.2 and self.attackAnim <= 0 then
        self.attackAnim = 0.25
    end

    if self.nextReload > 0 then
        self.aimangle = (1 - self.ang) * math.pi/2
    end

    self.attackAnim = self.attackAnim - dt
end

function SlimeGirl:drawNPC()
    self.anim = math.floor(love.timer.getTime() * 10)%10

    if self.attackAnim > 0 then
        local a = math.floor((1 - (self.attackAnim / 0.25)) * 3) % 3
        self.anim = a
        self.spritesheet2:draw(self.anim, 0, -16,- 21)
    else
        self.spritesheet:draw(self.anim, 0, -16, -21)
    end

end

function SlimeGirl:draw()

    love.graphics.scale(2, 2)
    love.graphics.scale(-self.ang, 1)

    self:drawNPC()

    if self.lastDamaged > 0 then

        love.graphics.setStencil(function ()
            love.graphics.setShader(shaders.mask_effect)
            self:drawNPC()
            love.graphics.setShader()
        end)

        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.rectangle("fill", -16, -21, 32, 32)

        love.graphics.setStencil()

    end
end

return SlimeGirl
