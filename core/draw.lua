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

    camera2_x = (p1x + p2x) / 2
    camera2_y = (p1y + p2y) / 2

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

local function MoveCamera2D(present_x, present_y, target_x, target_y, dT)
    local dist = math.sqrt(math.pow(target_x - present_x, 2) + math.pow(target_y - present_y, 2))
    local attr = Attraction / (dist + Attraction)
    local br = Break / (dist + Break)
    local alpha = Feathering * dT + attr - br -- MAGIC
    return math.lerp(present_x, present_y, target_x, target_y, alpha)
end

local function drawSplitScreen()

    -- local offsetx = love.graphics.getWidth()/2
    -- local offsety = love.graphics.getHeight()/2

    local offsetx = love.graphics.getWidth()/2 /2
    local offsety = love.graphics.getHeight()/2 /2 * 1.5

    local p1x, p1y = player:getPosition()
    local p2x, p2y = player2:getPosition()

    local goal1x, goal1y = p1x, p1y
    local goal2x, goal2y = p2x, p2y

    local timestepScale = 1

    local dT = love.timer.getDelta() * timestepScale

    camera1_x, camera1_y = MoveCamera2D(camera1_x, camera1_y, goal1x, goal1y, dT);
    camera2_x, camera2_y = MoveCamera2D(camera2_x, camera2_y, goal2x, goal2y, dT);

    -- make it so if the player goes faster the the camera
    -- we snap the camera.
    if cameraLife <= 0 then
        camera1_x = math.clamp(camera1_x, p1x - CAM_MAX_HORIZONTAL, p1x + CAM_MAX_HORIZONTAL)
        camera1_y = math.clamp(camera1_y, p1y - CAM_MAX_VERTICAL, p1y + CAM_MAX_VERTICAL)
        camera2_x = math.clamp(camera2_x, p2x - CAM_MAX_HORIZONTAL, p2x + CAM_MAX_HORIZONTAL)
        camera2_y = math.clamp(camera2_y, p2y - CAM_MAX_VERTICAL, p2y + CAM_MAX_VERTICAL)
    end

    local bg_ratio = love.graphics.getHeight()/map.background:getHeight()

    love.graphics.push()
        -- love.graphics.setStencil(function ()
        --     love.graphics.polygon("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight(), 0, love.graphics.getHeight())
        -- end)

        love.graphics.translate(math.round(-love.graphics.getWidth()/4), 0)

        love.graphics.setColor(255, 255, 255)
        love.graphics.draw(map.background, -camera1_x/50 + offsetx/2, -camera1_y/40, 0, bg_ratio, bg_ratio)

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


    -- draw player 2
    love.graphics.push()

        love.graphics.setCanvas(splitFramebuffer)

        love.graphics.setColor(255, 0, 0, 150)

        -- translate because split screen has different centers
        love.graphics.translate(math.round(love.graphics.getWidth()/4), 0)

        -- draw background
        love.graphics.setColor(255, 255, 255)
        love.graphics.draw(map.background, -camera2_x/50 - offsetx/2, -camera2_y/40, 0, bg_ratio, bg_ratio)

        -- scale up
        love.graphics.scale(2, 2)

        -- translate based on camera position
        love.graphics.translate(-camera2_x+offsetx, -camera2_y+offsety)

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
        
        love.graphics.setCanvas()

    love.graphics.pop()


    love.graphics.setStencil(function ()
        love.graphics.polygon("fill", love.graphics.getWidth()*2/5, 0, love.graphics.getWidth(), 0, love.graphics.getWidth(), love.graphics.getHeight(), love.graphics.getWidth()*3/5, love.graphics.getHeight())
    end)
        love.graphics.setColor(255, 255, 255)
        love.graphics.draw(splitFramebuffer, 0, 0)
    love.graphics.setStencil()

end

function drawFontKerned(string, x, y, xoff)
    -- go through every character and print it
    string:gsub(".", function(a)
        love.graphics.print(a, x, y)
        x = x + love.graphics.getFont():getWidth(a) + xoff
    end)
end

function love.draw()


    local p1x, p1y = player:getPosition()
    local p2x, p2y = player2:getPosition()

    if math.distance(p1x, p1y, p2x, p2y) < 500 then
        drawSingleScreen()
    else
        drawSplitScreen()
    end

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

    love.graphics.setColor(255, 255, 255)
    love.graphics.setFont(boldFont)
    drawFontKerned("0123456789", 0, 0, -8)

end
