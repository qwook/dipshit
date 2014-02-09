
shaders =       require("core.shaders")
BaseEntity =    require("entities.core.baseentity")
NPCBullet =     require("entities.npcbullet")
Goomba =        require("entities.core.goomba")

Gorilla = class("Gorilla", Goomba)
Gorilla.spritesheet = SpriteSheet:new("sprites/gorilla.png", 32, 32)

function Gorilla:initialize()
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

function Gorilla:draw()
    love.graphics.scale(2, 2)
    love.graphics.scale(-self.ang, 1)
    self.spritesheet:draw(0, 0, -16, -21)

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

return Gorilla
