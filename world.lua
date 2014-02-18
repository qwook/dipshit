
----------------------------------------------------------------------
-- Box2d callbacks

local function beginContact(fixture1, fixture2, contact)
    local physical1 = fixture1:getUserData()
    local physical2 = fixture2:getUserData()

    physical1:beginContact(physical2, contact, false)
    physical2:beginContact(physical1, contact, true)
end

local function endContact(fixture1, fixture2, contact)
    local physical1 = fixture1:getUserData()
    local physical2 = fixture2:getUserData()

    physical1:endContact(physical2, contact, false)
    physical2:endContact(physical1, contact, true)
end

local function preSolve(fixture1, fixture2, contact)
    local physical1 = fixture1:getUserData()
    local physical2 = fixture2:getUserData()

    physical1:preSolve(physical2, contact, false)
    physical2:preSolve(physical1, contact, true)
end

local function postSolve(fixture1, fixture2, contact, normal, tangent)
    local physical1 = fixture1:getUserData()
    local physical2 = fixture2:getUserData()

    physical1:postSolve(physical2, contact, normal, tangent, false)
    physical2:postSolve(physical1, contact, normal, tangent, true)
end

----------------------------------------------------------------------
-- Actual world class
-- Handles physics and all the entities spawned

local World = class("World")

function World:initialize()
    self.children = {} -- list
    self.players = {} -- list
    self.chunks = {} -- queue

    love.physics.setMeter(64) -- 2 meter = 64 pixels
    self.physWorld = love.physics.newWorld(0, 9.8*4)
    self.physWorld:setCallbacks(beginContact, endContact, preSolve, postSolve)

    self.removalQueue = {}
end

function World:setGravity(gx, gy)
    self.physWorld:setGravity(gx, gy)
end

function World:destroy()
    self.physWorld:destroy()
end

function World:getPhysWorld()
    return self.physWorld
end

function World:pollChunk()
    return self.chunks[#self.chunks]
end

function World:pushChunk(chunk)
    table.insert(self.chunks, chunk)
end

function World:popChunk()
    table.remove(self.chunks, 1)
end

function World:addPlayer(player)
    if not table.hasvalue(player) then
        table.insert(self.players, player)
    end
end

function World:removePlayer(player)
    if table.hasvalue(player) then
        table.removevalue(self.players, player)
    end
end

function World:spawnEntity(entity)
    table.insert(self.children, entity)
end

function World:removeEntity(entity)
    table.insert(self.removalQueue, entity)
end

function World:getPlayers()
    return self.players
end

function World:update(dt)
    -- remove the entities in the removal queue
    for k, ent in pairs(self.removalQueue) do
        table.removevalue(self.children, ent)
    end
    -- clear the removal queue
    table.clear(self.removalQueue)

    -- update global entities
    for k, ent in pairs(self.children) do
        ent:update(dt)
    end

    -- update entities belonging to chunks
    for _, chunks in pairs(self.chunks) do
        for _, ent in pairs(chunks.children) do
            ent:update(dt)
        end
    end

    self.physWorld:update(dt)
end

function World:drawEntity(ent)
    love.graphics.push()
    love.graphics.translate(ent:getPos())
    love.graphics.rotate(ent:getAngle())
    ent:draw()
    love.graphics.pop()
end

function World:postDrawEntity(ent)
    love.graphics.push()
    love.graphics.translate(ent:getPos())
    love.graphics.rotate(ent:getAngle())
    ent:postDraw()
    love.graphics.pop()
end

function World:draw()
    for k, ent in pairs(self.children) do
        self:drawEntity(ent)
    end

    for k, ent in pairs(self.children) do
        self:postDrawEntity(ent)
    end
end

return World
