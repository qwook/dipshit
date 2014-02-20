
local BaseGM = reload("gamemodes.basegm")
local GameMode = class("MapEditor", BaseGM)

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
        
        if state ~= selfstate then
            return
        end

        gamemode:onCanvasPressed(x, y, button)
    end
    self.canvas.mousereleased = function(self, x, y, button)
        local state = loveframes.state
        local selfstate = self.state
        
        if state ~= selfstate then
            return
        end
        
        gamemode:onCanvasReleased(x, y, button)
    end
    self.canvas.draw = function(self)
    end

    self.toolset = loveframes.Create("frame", self.canvas)
    self.toolset:SetName("Tools")
    self.toolset:SetState("game")
    self.toolset:SetPos(love.graphics.getWidth() - 135 - 10, 10)
    self.toolset:SetSize(135, 400)
    self.toolset:ShowCloseButton(false)

    self:populateToolset()

end

function GameMode:exit()
    self.canvas:Remove()
    self.toolset:Remove()
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
        local x, y = self:getTilePosOnMouse()
        self.tilemap:setTileAt(x, y, 1)
        self.draggingLeft = true
    elseif button == "r" then
        local x, y = self:getTilePosOnMouse()
        self.tilemap:setTileAt(x, y, nil)
        self.draggingRight = true
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

    if self.draggingLeft then
        local x, y = self:getTilePosOnMouse()
        self.tilemap:setTileAt(x, y, 1)
    end

    if self.draggingRight then
        local x, y = self:getTilePosOnMouse()
        self.tilemap:setTileAt(x, y, nil)
    end
end

return GameMode
