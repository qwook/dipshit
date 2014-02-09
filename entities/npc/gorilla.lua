
shaders =       require("core.shaders")
BaseEntity =    require("entities.core.baseentity")
NPCBullet =     require("entities.npcbullet")
Goomba =        require("entities.core.goomba")

Gorilla = class("Gorilla", Goomba)
Gorilla.spritesheet = SpriteSheet:new("sprites/gorilla.png", 32, 32)

function Gorilla:initialize()
    Goomba.initialize(self)

    -- control variables
    self.type = "NPC"
    self.collisiongroup = "shared"
    self.attackDelay = 0
    self.reloadDelay = 1.5
    self.clipsize = 3
    self.cone = 40 -- in radians
    self.health = 500 -- health
    self.range = 250 -- range of attack
    self.shootFacingPlayer = false -- shoot only facing player
    self.canAim = false -- can it aim at the player?
    self.stopBeforeShooting = true
    self.bulletOffsetX = 20
    self.bulletOffsetY = -12

    -- no touchy
    self.attackAnim = 0
end

function Gorilla:update(dt)
    Goomba.update(self, dt)

    if self.nextReload <= 0.3 and self.attackAnim <= 0 then
        self.attackAnim = 0.75
    end

    self.attackAnim = self.attackAnim - dt
end

function Gorilla:draw()

    self.anim = 7 + math.floor(love.timer.getTime() * 10)%6

    if self.attackAnim > 0 then
        local a = math.floor((1 - (self.attackAnim / 0.75)) * 7) % 7
        self.anim = a
    end

    love.graphics.scale(2, 2)
    love.graphics.scale(-self.ang, 1)
    self.spritesheet:draw(self.anim, 0, -16, -21)

    if self.lastDamaged > 0 then

        love.graphics.setStencil(function ()
            love.graphics.setShader(shaders.mask_effect)
            self.spritesheet:draw(self.anim, 0, -16, -21)
            love.graphics.setShader()
        end)

        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.rectangle("fill", -16, -21, 32, 32)

        love.graphics.setStencil()

    end
end

return Gorilla
