
local BaseGM = reload("gamemodes.basegm")
local GameMode = class("MapEditor", BaseGM)

tilemanager = reload("tilemanager")

function GameMode:initialize()
    self.super:initialize()

    self.player = entityfactory:create("player")
    self.player:setPos(16*100, 16*100)
    self.player:spawn()
    self.player:setNoClip(true)

    self.tilemap = entityfactory:create("tilemap")
    self.tilemap:setPos(0, 0)
    self.tilemap:spawn()

    self.scale = 1
    self.currentTile = nil
    self.currentTool = nil
    self.draggingLeft = false
    self.draggingRight = false

    -- loveframes is shit, should replace soon.
    self.canvas = loveframes.Create("button")
    self.canvas:SetState("game")
    self.canvas:SetSize(love.graphics.getWidth(), love.graphics.getHeight())
    self.canvas:SetPos(0, 0)
    self.canvas.mousepressed = function(self, x, y, button)
        local state = loveframes.state
        local selfstate = self.state
        
        if state ~= selfstate or not self.hover then
            return
        end

        gamemode:onCanvasPressed(x, y, button)
    end
    self.canvas.mousereleased = function(self, x, y, button)
        local state = loveframes.state
        local selfstate = self.state
        
        if state ~= selfstate or not self.hover then
            return
        end
        
        gamemode:onCanvasReleased(x, y, button)
    end
    self.canvas.Draw = function(self)
    end

    self.toolset = loveframes.Create("frame", self.canvas)
    self.toolset:SetName("Tools")
    self.toolset:SetState("game")
    self.toolset:SetPos(love.graphics.getWidth() - 135 - 10, 10)
    self.toolset:SetSize(135, 94)
    self.toolset:ShowCloseButton(false)

    self:populateToolset()

    self.tilesets = loveframes.Create("frame", self.canvas)
    self.tilesets:SetName("Tiles")
    self.tilesets:SetState("game")
    self.tilesets:SetPos(love.graphics.getWidth() - 200 - 10, 94+10)
    self.tilesets:SetSize(200, 200)
    self.tilesets:ShowCloseButton(false)

    self.tilesetsList = loveframes.Create("list", self.tilesets)
    self.tilesetsList:SetPos(5, 30)
    self.tilesetsList:SetSize(200-10, 200-10-26)
    self.tilesetsList:SetPadding(0)
    self.tilesetsList:SetSpacing(1)
    self.tilesetsList.row = nil

    self:populateTilesets()

end

function GameMode:exit()
    self.canvas:Remove()
    self.toolset:Remove()
    self.tilesets:Remove()
end

function GameMode:addTileButton(image, data)

    local row = self.tilesetsList.row

    if not row then
        row = loveframes.Create("panel")
        row:SetHeight(32)
        row.Draw = function(self)
        end
        row.childcount = 0
        self.tilesetsList.row = row
        self.tilesetsList:AddItem(row)
    end


    local button = loveframes.Create("button", row)
    button:SetPos((32+1)*(row.childcount), 0)
    button:SetSize(32, 32)
    button:SetText("")
    button.Draw = function(self)
        love.graphics.setColor(255, 255, 255)
        love.graphics.rectangle("fill", self:GetX(), self:GetY(), self:GetWidth(), self:GetHeight())
        love.graphics.draw(data.image, data.quad, self:GetX(), self:GetY(), 0, 2, 2)
        if self.hover then
            love.graphics.setColor(255, 255, 255, 100)
            love.graphics.rectangle("fill", self:GetX(), self:GetY(), self:GetWidth(), self:GetHeight())
        end
    end
    button.data = data
    button.OnClick = function(button)
        self.currentTile = button.data
    end


    row.childcount = row.childcount + 1

    if row.childcount == 5 then
        self.tilesetsList.row = nil
    end

end

function GameMode:populateTilesets()
    local tilesets = tilemanager:getTileSets()

    for name, tileset in pairs(tilesets) do
        local image = tileset.image
        for i, tile in pairs(tileset.tiles) do
            self:addTileButton(image, tile)
        end
    end
end

function GameMode:populateToolset()
    local cursor = loveframes.Create("button", self.toolset)
    cursor:SetText("Cursor")
    cursor:SetPos(5, 5 + 24)
    cursor:SetSize(60, 60)
    cursor.OnClick = function()
        self.currentTool = "cursor"
    end

    local draw = loveframes.Create("button", self.toolset)
    draw:SetText("Draw")
    draw:SetPos(5*2 + 60, 5 + 24)
    draw:SetSize(60, 60)
    draw.OnClick = function()
        self.currentTool = "draw"
    end

    -- todo: fill, line, rectangle, custom brush

    -- local fill = loveframes.Create("button", self.toolset)
    -- fill:SetText("Fill")
    -- fill:SetPos(5, 5*2 + 60 + 24)
    -- fill:SetSize(60, 60)
end

function GameMode:transformPoint(x, y)
    local cx, cy, cs = self:calcView()
    return x/cs + cx - (love.graphics.getWidth()/cs/2), y/cs + cy - (love.graphics.getHeight()/cs/2)
end

function GameMode:getTilePosOnMouse()
    local x, y = self:transformPoint(love.mouse.getX(), love.mouse.getY())
    return math.floor(x/TILESIZE), math.floor(y/TILESIZE)
end

function GameMode:postDraw()
    love.graphics.setColor(255, 255, 0)
    local x, y = self:getTilePosOnMouse()

    if self.currentTile then
        local data = self.currentTile
        love.graphics.setColor(255, 255, 255)
        love.graphics.draw(data.image, data.quad, x*TILESIZE, y*TILESIZE, 0, 1, 1)
    end

    love.graphics.rectangle("line", x*TILESIZE, y*TILESIZE, TILESIZE, TILESIZE)
end

function GameMode:drawHUD()
    love.graphics.setColor(255, 255, 255)

    local x, y = self:getTilePosOnMouse()
    love.graphics.print(x .. ", " .. y, 5, love.graphics.getHeight()-20)
end

function GameMode:calcView()
    local x, y, scale = self.super:calcView()
    return x, y, self.scale
end

function GameMode:onCanvasPressed(x, y, button)

    if button == "wu" then
        self.scale = self.scale * (5/4)
    elseif button == "wd" then
        self.scale = self.scale * (4/5)
    elseif button == "l" then
        if self.currentTile then
            local x, y = self:getTilePosOnMouse()
            -- self.tilemap:setTileAt(x, y, self.currentTile)
            self.tilemap:setTileAt(x, y, self.currentTile.tileset, self.currentTile.name)
            self.tilemap:reloadPhysics()
            -- print2(tilemanager:getTile(self.currentTile.tileset, self.currentTile.name))
            self.draggingLeft = true
        end
    elseif button == "r" then
        if self.currentTile then
            local x, y = self:getTilePosOnMouse()
            self.tilemap:setTileAt(x, y, nil)
            self.tilemap:reloadPhysics()
            self.draggingRight = true
        end
    end
end

function GameMode:onCanvasReleased(x, y, button)
end

function GameMode:onMouseReleased(x, y, button)
    if button == "l" then
        self.draggingLeft = false
    elseif button == "r" then
        self.draggingRight = false
    end
end

function GameMode:update(dt)
    -- only update the player
    for k, v in pairs(world:getPlayers()) do
        v:update(dt)
    end

    if self.currentTile then
        if self.draggingLeft then
            local x, y = self:getTilePosOnMouse()
            self.tilemap:setTileAt(x, y, self.currentTile.tileset, self.currentTile.name)
            self.tilemap:reloadPhysics()
        end

        if self.draggingRight then
            local x, y = self:getTilePosOnMouse()
            self.tilemap:setTileAt(x, y, nil)
            self.tilemap:reloadPhysics()
        end
    end
end

require("serialize")

console:addConCommand("save", function()
    local data = {}
    for y, row in pairs(gamemode.tilemap.tiles) do
        data[y] = {}
        for x, tile in pairs(row) do
            data[y][x] = {name=tile.name, tileset=tile.tileset}
        end
    end

    local file = io.open(path .. "/assets/maps/test.map", "w")
    file:write(serialize(data))
    file:close()
end)

console:addConCommand("load", function()
    local file = io.open(path .. "/assets/maps/test.map", "r")
    local data = deserialize(file:read("*a"))
    file:close()
    -- gamemode.tilemap.tiles = {}
    for y, row in pairs(data) do
        for x, tile in pairs(row) do
            gamemode.tilemap:setTileAt(tonumber(x), tonumber(y), tile.tileset, tile.name)
        end
    end
    gamemode.tilemap:reloadPhysics()
end)

return GameMode
