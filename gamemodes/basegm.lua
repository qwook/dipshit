
local GameMode = class("BaseGM")

-- the initialize function needs to follow a strict rule
-- of only initializing instance variables
-- calling functions inside here will possibily break it
function GameMode:initialize()
    world:setGravity(0, 400)

    local player = entityfactory:create("player")
    player:setPos(50, 50)
    player:spawn()

    local player2 = entityfactory:create("player")
    player2:setPos(50, 50)
    player2:spawn()

    for i = 1, 15 do
        local ent = entityfactory:create("physentity")
        ent:setPos(0+20*i, 20)
        ent:spawn()

        ent:setVelocity(100, 0)
        ent:setTorque(math.random(-1, 1))
    end

    local tilemap = entityfactory:create("tilemap")
    tilemap:setPos(300, 400)
    tilemap:spawn()

    self.xCam = nil
    self.yCam = nil
    self.scaleCam = nil

    self.magShake = 10
    self.rShake = 0
    self.sShake = 0
end

function GameMode:exit()
end

function GameMode:update(dt)
end

function GameMode:draw()
    love.graphics.setColor(255, 0, 0)
    love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(255, 255, 255)
    love.graphics.print("Game!", 0, 0)
end

function GameMode:postDraw()
    -- draw health and shit here
end

function GameMode:onKeyPressed(key)
end

function GameMode:onKeyReleased(key)
end

function GameMode:applyShake(magnitude)
    self.magShake = magnitude
end

function GameMode:calcShake()
    if self.magShake > 0 then
        self.rShake = math.random(0, 2*math.pi)
        self.sShake = self.magShake

        self.magShake = self.magShake - love.timer.getDelta()*10

        return math.cos(self.rShake)*self.sShake, math.sin(self.rShake)*self.sShake
    else
        return 0, 0
    end
end

function GameMode:calcView()
    local players = world:getPlayers()

    local xMax = nil
    local yMax = nil

    local xMin = nil
    local yMin = nil

    local x = 0
    local y = 0
    for k, v in pairs(players) do
        local xPlayer, yPlayer = v:getPos()
        x = x + xPlayer
        y = y + yPlayer

        -- find the max coordinates
        if xMax == nil or xPlayer > xMax then
            xMax = xPlayer
        end
        if yMax == nil or yPlayer > yMax then
            yMax = yPlayer
        end
        -- find the min coordinates
        if xMin == nil or xPlayer < xMin then
            xMin = xPlayer
        end
        if yMin == nil or yPlayer > yMin then
            yMin = yPlayer
        end
    end

    x = x / #players
    y = y / #players - love.graphics.getHeight()/8

    -- scale the camera by the distance of the player
    -- in perspective to the width of the screen
    local scale = love.graphics.getWidth()/(math.distance(xMin, yMin, xMax, yMax) + 500)
    scale = math.clamp(scale, 0.25, 2)

    -- make sure these are all set to something
    self.xCam = self.xCam or x
    self.yCam = self.yCam or y
    self.scaleCam = self.scaleCam or scale

    -- now interpolate them, so they ease into their positions
    -- instead of snapping
    self.xCam, self.yCam = math.lerpVector(self.xCam, self.yCam, x, y, 0.1)
    self.scaleCam = math.lerp(self.scaleCam, scale, 0.1)

    -- shaking is more sudden and doesn't need interpolation
    local xShake, yShake = self:calcShake()
    self.xCam = self.xCam + xShake
    self.yCam = self.yCam + yShake

    -- returns x, y, scale of camera position
    return self.xCam, self.yCam, self.scaleCam
end

-- todo: these functions are not implemented yet

function GameMode:onPlayerSpawn(player)
end

function GameMode:onPlayerDeath(player)
end

function GameMode:onPlayerKeyPressed(player, key)
end

function GameMode:onPlayerKeyReleased(player, key)
end

function GameMode:onMousePressed(x, y, button)
end

function GameMode:onMouseReleased(x, y, button)
end

console:addConCommand("shake", function(cmd, arg)
    gamemode:applyShake(tonumber(arg[1]) or 10)
end)

-- this adds a bit of overhead
-- but checks for newly created instance variables
-- and deleted variables
-- if arguments["watch"] then
--     function GameMode:__index(index)
--         local class = getmetatable(self)

--         local obj = {}
--         local o = setmetatable(obj, class)
--         class.initialize(o)

--         for k, v in pairs(obj) do
--             if not rawget(self, k) then
--                 rawset(self, k, v)
--             end
--         end

--         for k, v in pairs(self) do
--             if not rawget(obj, k) then
--                 rawset(self, k, nil)
--             end
--         end

--         local ret = rawget(self, index) or class[index]
--         if not ret and class.super then
--             return class.super[index]
--         end
--         return ret
--     end
-- end

return GameMode
