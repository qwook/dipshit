local Feathering = 4.0
local Attraction = 4.0
local Break = 2.0

local camera1_x, camera1_y = 0, 0
local camera2_x, camera2_y = 0, 0

local CAM_MAX_HORIZONTAL = 100
local CAM_MAX_VERTICAL = 100

cameraLife = 0

local function drawSingleScreen()

    local p1x, p1y = player:getPosition()
    local p2x, p2y = player2:getPosition()

    camera1_x = (p1x + p2x) / 2
    camera1_y = (p1y + p2y) / 2

    local bg_ratio = love.graphics.getHeight()/map.background:getHeight()

    local offsetx = love.graphics.getWidth()/2 /2
    local offsety = love.graphics.getHeight()/2 /2 * 1.5

    love.graphics.push()
        love.graphics.setColor(255, 255, 255)
        love.graphics.draw(map.background, 0, 0, 0, bg_ratio, bg_ratio)

        love.graphics.scale(2, 2)
        love.graphics.translate(math.round(-camera1_x+offsetx), math.round(-camera1_y+offsety))

        map:draw("player1")

        for k, map in pairs(maps) do
            map:draw("player1")
        end

        player2:draw()
        player:draw()
        
        for k, map in pairs(maps) do
            for i, object in pairs(map.objects) do
                object:preDraw()
                object:draw()
                object:postDraw()
            end
        end

        for i, object in pairs(map.objects) do
            object:preDraw()
            object:draw()
            object:postDraw()
        end
        
    love.graphics.pop()

end

function love.draw()

    -- if singleCamera then
        drawSingleScreen()
    -- else
        -- drawSplitScreen()
    -- end

    if changeMapTime > 0 then
        love.graphics.setColor(255, 255, 255, (1 - changeMapTime)*255)
        love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    end

    if changeMapTimeOut > 0 then
        love.graphics.setColor(255, 255, 255, changeMapTimeOut*255)
        love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    end

    if pausing then
        love.graphics.setColor(0, 0, 0, 100)
        love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

        local timer = 9 - math.floor((afkTimer - timeToPause) / timeToReset * 10)
        love.graphics.setColor(255, 255, 255)
        love.graphics.printf("Continue?\n" .. timer, 0, love.graphics.getHeight()/2-50, love.graphics.getWidth()/4, "center", 0, 4, 4)
    end

end
