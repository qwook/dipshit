
-- extend the entity definition
local Entity = class("TileMap", BaseEntity)

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
            if offx == nil or offx > 0 or offy > 0 then
                self:markTile(x, y, self.currentChunkId)
                self:traverseTile(x+1, y, -1, 0)
                self:traverseTile(x, y+1, 0, -1)
            end
        -- bottom left triangle
        elseif self:getCollisionTileAt(x, y) == 3 then
            if offx == nil or offx < 0 or offy > 0 then
                self:markTile(x, y, self.currentChunkId)
                self:traverseTile(x-1, y, 1, 0)
                self:traverseTile(x, y+1, 0, -1)
            end
        -- top left triangle
        elseif self:getCollisionTileAt(x, y) == 4 then
            if offx == nil or offx < 0 or offy < 0 then
                self:markTile(x, y, self.currentChunkId)
                self:traverseTile(x-1, y, 1, 0)
                self:traverseTile(x, y-1, 0, 1)
            end
        -- top right triangle
        elseif self:getCollisionTileAt(x, y) == 5 then
            if offx == nil or offx < 0 or offy < 0 then
                self:markTile(x, y, self.currentChunkId)
                self:traverseTile(x+1, y, -1, 0)
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
                    table.insert(self.edges, {x = (x+1)*TILESIZE, y = (y)*TILESIZE, x2 = (x+1)*TILESIZE, y2 = (y+1)*TILESIZE})
                end

                -- left edge
                if self:isRightEdgeOpen(x-1, y) then
                    table.insert(self.edges, {x = (x)*TILESIZE, y = (y+1)*TILESIZE, x2 = (x)*TILESIZE, y2 = (y)*TILESIZE})
                end

                -- bottom edge
                if self:isTopEdgeOpen(x, y+1) then
                    table.insert(self.edges, {x = (x+1)*TILESIZE, y = (y+1)*TILESIZE, x2 = (x)*TILESIZE, y2 = (y+1)*TILESIZE})
                end

                -- top edge
                if self:isBottomEdgeOpen(x, y-1) then
                    table.insert(self.edges, {x = (x)*TILESIZE, y = (y)*TILESIZE, x2 = (x+1)*TILESIZE, y2 = (y)*TILESIZE})
                end
            -- bottom right triangle
            elseif block == 2 then
                table.insert(self.edges, {x = (x)*TILESIZE, y = (y+1)*TILESIZE, x2 = (x+1)*TILESIZE, y2 = (y)*TILESIZE})

                -- right edge
                if self:isLeftEdgeOpen(x+1, y) then
                    table.insert(self.edges, {x = (x+1)*TILESIZE, y = (y)*TILESIZE, x2 = (x+1)*TILESIZE, y2 = (y+1)*TILESIZE})
                end

                -- bottom edge
                if self:isTopEdgeOpen(x, y+1) then
                    table.insert(self.edges, {x = (x+1)*TILESIZE, y = (y+1)*TILESIZE, x2 = (x)*TILESIZE, y2 = (y+1)*TILESIZE})
                end
            -- bottom left triangle
            elseif block == 3 then
                table.insert(self.edges, {x = (x)*TILESIZE, y = (y)*TILESIZE, x2 = (x+1)*TILESIZE, y2 = (y+1)*TILESIZE})

                -- left edge
                if self:isRightEdgeOpen(x-1, y) then
                    table.insert(self.edges, {x = (x)*TILESIZE, y = (y+1)*TILESIZE, x2 = (x)*TILESIZE, y2 = (y)*TILESIZE})
                end

                -- bottom edge
                if self:isTopEdgeOpen(x, y+1) then
                    table.insert(self.edges, {x = (x+1)*TILESIZE, y = (y+1)*TILESIZE, x2 = (x)*TILESIZE, y2 = (y+1)*TILESIZE})
                end
            -- top left triangle
            elseif block == 4 then
                table.insert(self.edges, {x = (x+1)*TILESIZE, y = (y)*TILESIZE, x2 = (x)*TILESIZE, y2 = (y+1)*TILESIZE})

                -- left edge
                if self:isRightEdgeOpen(x-1, y) then
                    table.insert(self.edges, {x = (x)*TILESIZE, y = (y+1)*TILESIZE, x2 = (x)*TILESIZE, y2 = (y)*TILESIZE})
                end

                -- top edge
                if self:isBottomEdgeOpen(x, y-1) then
                    table.insert(self.edges, {x = (x)*TILESIZE, y = (y)*TILESIZE, x2 = (x+1)*TILESIZE, y2 = (y)*TILESIZE})
                end
            -- top right triangle
            elseif block == 5 then
                table.insert(self.edges, {x = (x+1)*TILESIZE, y = (y+1)*TILESIZE, x2 = (x)*TILESIZE, y2 = (y)*TILESIZE})

                -- right edge
                if self:isLeftEdgeOpen(x+1, y) then
                    table.insert(self.edges, {x = (x+1)*TILESIZE, y = (y)*TILESIZE, x2 = (x+1)*TILESIZE, y2 = (y+1)*TILESIZE})
                end

                -- top edge
                if self:isBottomEdgeOpen(x, y-1) then
                    table.insert(self.edges, {x = (x)*TILESIZE, y = (y)*TILESIZE, x2 = (x+1)*TILESIZE, y2 = (y)*TILESIZE})
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
        -- table.insert(loop, first.x)
        -- table.insert(loop, first.y)
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
