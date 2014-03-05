
local BaseEntity = reload("entities.baseentity")
local Entity = class("TileMap", BaseEntity)

reload("entities.tilemap.edgefinder")

console:addConVar("showshapes", 0, "number")

function Entity:initialize(...)
    self.super:initialize(...)

    self.children = {} -- list of fixtures
    self.loops = {}

    self.tiles = {}

    self:findTileChunks()

    for chunkid, _ in pairs(self.chunks) do
        self:findChunkVertices(chunkid)
    end
end

-----------------------------------------

function Entity:draw()
    love.graphics.setColor(255, 255, 255)
    for y, row in pairs(self.tiles) do
        for x, tile in pairs(row) do
            love.graphics.draw(tile.image, tile.quad, x*TILESIZE, y*TILESIZE, 0, 1, 1)
        end
    end

    if console:getConVar("showshapes") == 1 then
        for k, loop in pairs(self.loops) do
            if #loop > 1 then
                love.graphics.setColor(255, 0, 0)
                love.graphics.line(loop)
                love.graphics.line(loop[#loop-1], loop[#loop], loop[1], loop[2])
                -- local x = nil
                -- for k, v in pairs(loop) do
                --     if x == nil then
                --         x = v
                --     else
                --         local y = v
                --         love.graphics.setColor(255, 0, 0, 50)
                --         love.graphics.circle('fill', x, y, 10, 10)
                --         x = nil
                --     end
                -- end
            end
        end
    end
end

function Entity:initPhysics()
    for k, fixture in pairs(self.children) do
        fixture:destroy()
    end

    self.children = {}

    for k, loop in pairs(self.loops) do
        local shape = love.physics.newChainShape(true, unpack(loop))
        local body = love.physics.newBody(world:getPhysWorld(), self.x, self.y, "static")
        local fixture = love.physics.newFixture(body, shape, 1)
        fixture:setUserData(self)
        table.insert(self.children, fixture)
    end

end

function Entity:setTileAt(x, y, tileset, tilename)
    if tileset == nil then
        if self.tiles[y] then
            self.tiles[y][x] = nil
            -- if #self.tiles[y] == 0 then
            --     self.tiles[y] = nil
            -- end
        end
    else
        local tile = tilemanager:getTile(tileset, tilename)
        self.tiles[y] = self.tiles[y] or {}
        self.tiles[y][x] = tile
    end
end

function Entity:reloadPhysics()
    self:generateLoops()
    self:initPhysics()
end

-----------------------------------------
-- Tileset collision shape calculation

local tempMap = {
    {0, 1, 1, 0, 0, 0, 1, 1, 0, 0};
    {0, 0, 2, 1, 1, 3, 0, 1, 1, 1};
    {0, 1, 1, 2, 1, 1, 0, 1, 0, 1};
    {0, 1, 5, 2, 1, 4, 0, 1, 1, 1};
}

function Entity:getCollisionTilesetSize()
    local w = 0
    local h = 0
    for y, row in pairs(self.tiles) do
        for x, data in pairs(row) do
            w = math.max(w, x)
            h = math.max(h, y)
        end
    end
    return w, h
    -- return #tempMap[1], #tempMap
end

function Entity:getCollisionTileAt(x, y)
    -- if not tempMap[y] then return 0 end
    -- return tempMap[y][x] or 0
    if not self.tiles[y] then return 0 end
    if self.tiles[y][x] then
        return self.tiles[y][x].colshape
    else
        return 0
    end
end

-------------------------------------------------------

function Entity:beginContact(other, contact, isother)
    -- self.contacts[contact] = isother
end

function Entity:endContact(other, contact, isother)
    -- self.contacts[contact] = nil
end

function Entity:preSolve(other, contact, isother)
end

function Entity:postSolve(other, contact, normal, tangent, isother)
end

-------------------------------------------------------
-- so this will split the tilemap into different chunks
-- so that floating tiles get their own shape

function Entity:generateLoops()

    self:findTileChunks()
    self.loops = {}

    for chunkid, _ in pairs(self.chunks) do
        self:findChunkVertices(chunkid)
    end

end
-------------------------------------------------------

return Entity
