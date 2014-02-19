
local PhysEntity = reload("entities.physentity")
local Entity = class("TileMap", PhysEntity)

Entity.phystype = "static"
Entity.density = 1
Entity.mass = 32
Entity.w = 1000
Entity.h = 40

function Entity:initialize(...)
    self.super:initialize(...)
    self.shape = love.physics.newRectangleShape(Entity.w, Entity.h)
    self.loops = {}

    self:findTileChunks()

    for chunkid, _ in pairs(self.chunks) do
        self:findChunkVertices(chunkid)
    end
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
    return #tempMap[1], #tempMap
end

function Entity:getCollisionTileAt(x, y)
    if not tempMap[y] then return 0 end
    return tempMap[y][x] or 0
end

-------------------------------------------------------
-- so this will split the tilemap into different chunks
-- so that floating tiles get their own shape

function Entity:findTileChunks()
    self:initFindTileChunks()

    local w, h = self:getCollisionTilesetSize()
    for x = 1, w do
        for y = 1, h do
            if not self:isTileMarked(x, y) and self:getCollisionTileAt(x, y) ~= 0 then
                local block = self:getCollisionTileAt(x, y)
                self:traverseTile(x, y)
                self.currentChunkId = self.currentChunkId + 1
            end
        end
    end
end

function Entity:initFindTileChunks()
    self.markedTiles = {} -- 2d array of marked tiles
    self.chunks = {}
    self.currentChunkId = 1
end

-- mark tile as checked
function Entity:markTile(x, y, id)
    self.markedTiles[y] = self.markedTiles[y] or {}
    self.markedTiles[y][x] = id

    -- also add tile to a list of tile chunks
    self.chunks[id] = self.chunks[id] or {}
    table.insert(self.chunks[id], {x = x, y = y})
end

-- get the tile marking
function Entity:getTileMarkAt(x, y)
    if not self.markedTiles[y] then return 0 end
    return self.markedTiles[y][x] or 0
end

-- see if the tile has already been traversed
function Entity:isTileMarked(x, y)
    if not self.markedTiles[y] then return false end
    return self.markedTiles[y][x] or false
end

function Entity:traverseTile(x, y, offx, offy)
    if not self:isTileMarked(x, y) and self:getCollisionTileAt(x, y) ~= 0 then
        -- assuming this is a square
        if self:getCollisionTileAt(x, y) == 1 then
            self:markTile(x, y, self.currentChunkId)
            self:traverseTile(x+1, y, -1, 0)
            self:traverseTile(x-1, y, 1, 0)
            self:traverseTile(x, y+1, 0, -1)
            self:traverseTile(x, y-1, 0, 1)
        -- bottom right triangle
        elseif self:getCollisionTileAt(x, y) == 2 then
            if offx > 0 or offy > 0 then
                self:markTile(x, y, self.currentChunkId)
                self:traverseTile(x+1, y, 1, 0)
                self:traverseTile(x, y+1, 0, 1)
            end
        -- bottom left triangle
        elseif self:getCollisionTileAt(x, y) == 3 then
            if offx < 0 or offy > 0 then
                self:markTile(x, y, self.currentChunkId)
                self:traverseTile(x-1, y, 1, 0)
                self:traverseTile(x, y+1, 0, 1)
            end
        -- top left triangle
        elseif self:getCollisionTileAt(x, y) == 4 then
            if offx < 0 or offy < 0 then
                self:markTile(x, y, self.currentChunkId)
                self:traverseTile(x-1, y, 1, 0)
                self:traverseTile(x, y-1, 0, 1)
            end
        -- bottom left triangle
        elseif self:getCollisionTileAt(x, y) == 5 then
            if offx < 0 or offy < 0 then
                self:markTile(x, y, self.currentChunkId)
                self:traverseTile(x+1, y, 1, 0)
                self:traverseTile(x, y-1, 0, 1)
            end
        end
    end
end

-------------------------------------------------------
-- Find all the edges and vertices in the chunk,
-- merge them, then delete redundant vertices

-- checks if the left edge of this block is connected
function Entity:isLeftEdgeOpen(x, y)
    local block = self:getChunkTileAt(x, y)
    return block == 0 or block == 2 or block == 5
end

function Entity:isRightEdgeOpen(x, y)
    local block = self:getChunkTileAt(x, y)
    return block == 0 or block == 3 or block == 4
end

function Entity:isTopEdgeOpen(x, y)
    local block = self:getChunkTileAt(x, y)
    return block == 0 or block == 2 or block == 3
end

function Entity:isBottomEdgeOpen(x, y)
    local block = self:getChunkTileAt(x, y)
    return block == 0 or block == 4 or block == 5
end

function Entity:findChunkVertices(chunkid)
    self:initFindChunkVertices(chunkid)

    local width, height = self:getCollisionTilesetSize()
    for x = 1, width do
        for y = 1, height do
            local block = self:getChunkTileAt(x, y)

            -- assuming this is a rectangle block
            if block == 1 then
                -- right edge
                if self:isLeftEdgeOpen(x+1, y) then
                    table.insert(self.edges, {x = (x+1)*32, y = (y)*32, x2 = (x+1)*32, y2 = (y+1)*32})
                end

                -- left edge
                if self:isRightEdgeOpen(x-1, y) then
                    table.insert(self.edges, {x = (x)*32, y = (y+1)*32, x2 = (x)*32, y2 = (y)*32})
                end

                -- bottom edge
                if self:isTopEdgeOpen(x, y+1) then
                    table.insert(self.edges, {x = (x+1)*32, y = (y+1)*32, x2 = (x)*32, y2 = (y+1)*32})
                end

                -- top edge
                if self:isBottomEdgeOpen(x, y-1) then
                    table.insert(self.edges, {x = (x)*32, y = (y)*32, x2 = (x+1)*32, y2 = (y)*32})
                end
            -- bottom right triangle
            elseif block == 2 then
                table.insert(self.edges, {x = (x)*32, y = (y+1)*32, x2 = (x+1)*32, y2 = (y)*32})

                -- right edge
                if self:isLeftEdgeOpen(x+1, y) then
                    table.insert(self.edges, {x = (x+1)*32, y = (y)*32, x2 = (x+1)*32, y2 = (y+1)*32})
                end

                -- bottom edge
                if self:isTopEdgeOpen(x, y+1) then
                    table.insert(self.edges, {x = (x+1)*32, y = (y+1)*32, x2 = (x)*32, y2 = (y+1)*32})
                end
            -- bottom left triangle
            elseif block == 3 then
                table.insert(self.edges, {x = (x)*32, y = (y)*32, x2 = (x+1)*32, y2 = (y+1)*32})

                -- left edge
                if self:isRightEdgeOpen(x-1, y) then
                    table.insert(self.edges, {x = (x)*32, y = (y+1)*32, x2 = (x)*32, y2 = (y)*32})
                end

                -- bottom edge
                if self:isTopEdgeOpen(x, y+1) then
                    table.insert(self.edges, {x = (x+1)*32, y = (y+1)*32, x2 = (x)*32, y2 = (y+1)*32})
                end
            -- bottom left triangle
            elseif block == 4 then
                table.insert(self.edges, {x = (x+1)*32, y = (y)*32, x2 = (x)*32, y2 = (y+1)*32})

                -- left edge
                if self:isRightEdgeOpen(x-1, y) then
                    table.insert(self.edges, {x = (x)*32, y = (y+1)*32, x2 = (x)*32, y2 = (y)*32})
                end

                -- top edge
                if self:isBottomEdgeOpen(x, y-1) then
                    table.insert(self.edges, {x = (x)*32, y = (y)*32, x2 = (x+1)*32, y2 = (y)*32})
                end
            -- bottom right triangle
            elseif block == 5 then
                table.insert(self.edges, {x = (x+1)*32, y = (y+1)*32, x2 = (x)*32, y2 = (y)*32})

                -- right edge
                if self:isLeftEdgeOpen(x+1, y) then
                    table.insert(self.edges, {x = (x+1)*32, y = (y)*32, x2 = (x+1)*32, y2 = (y+1)*32})
                end

                -- top edge
                if self:isBottomEdgeOpen(x, y-1) then
                    table.insert(self.edges, {x = (x)*32, y = (y)*32, x2 = (x+1)*32, y2 = (y)*32})
                end
            end
        end
    end

    self:mergeChunkVertices()
end

function Entity:findNextEdge(point)
    for k, v in pairs(self.edges) do
        if v.x == point.x2 and v.y == point.y2 then
            return v
        end
    end
end

function Entity:mergeChunkVertices()
    while (#self.edges > 0) do
        local loop = {}
        local first = nil
        local point = nil
        while (true) do
            if point == nil then
                point = self.edges[1]
                first = point
            else
                point = self:findNextEdge(point)
                if point == nil then
                    break
                end
            end

            table.removevalue(self.edges, point)
            table.insert(loop, point.x)
            table.insert(loop, point.y)
        end
        table.insert(loop, first.x)
        table.insert(loop, first.y)
        table.insert(self.loops, loop)
    end
end

function Entity:initFindChunkVertices(chunkid)
    self.chunkMap = {}
    self.edges = {}

    local chunk = self.chunks[chunkid]
    for k, v in pairs(chunk) do
        self.chunkMap[v.y] = self.chunkMap[v.y] or {}
        self.chunkMap[v.y][v.x] = self:getCollisionTileAt(v.x, v.y)
    end
end

function Entity:getChunkTileAt(x, y)
    if not self.chunkMap[y] then return 0 end
    return self.chunkMap[y][x] or 0
end

-------------------------------------------------------

function Entity:draw()
    love.graphics.setColor(255, 255, 0)
    love.graphics.rectangle("fill", -self.w/2, -self.h/2, self.w, self.h)

    for y, row in pairs(tempMap) do
        for x, block in pairs(row) do
            if block == 1 then
                love.graphics.setColor(0, 255, 0)
                love.graphics.rectangle("fill", x*32, y*32, 32, 32)
                love.graphics.setColor(0, 100, 0)
                love.graphics.rectangle("line", x*32, y*32, 32, 32)
            elseif block == 2 then
                love.graphics.setColor(0, 255, 0)
                love.graphics.polygon("fill", (x+1)*32, (y)*32, (x)*32, (y+1)*32, (x+1)*32, (y+1)*32)
            elseif block == 3 then
                love.graphics.setColor(0, 255, 0)
                love.graphics.polygon("fill", (x)*32, (y)*32, (x)*32, (y+1)*32, (x+1)*32, (y+1)*32)
            elseif block == 4 then
                love.graphics.setColor(0, 255, 0)
                love.graphics.polygon("fill", (x)*32, (y)*32, (x+1)*32, (y)*32, (x)*32, (y+1)*32)
            elseif block == 5 then
                love.graphics.setColor(0, 255, 0)
                love.graphics.polygon("fill", (x)*32, (y)*32, (x+1)*32, (y)*32, (x+1)*32, (y+1)*32)
            end
        end
    end

    for k, loop in pairs(self.loops) do
        love.graphics.setLineWidth(4)
        love.graphics.setColor(math.cos(k*2)*100+100, math.sin(k*2)*100+100, 255)
        love.graphics.line(loop)
        love.graphics.setLineWidth(1)
    end
end

return Entity
