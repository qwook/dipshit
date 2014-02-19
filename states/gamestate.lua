
local BaseState = require("states.basestate")
local GameState = class("GameState", BaseState)

local World = require("world")

function GameState:initialize()
    self.gamemode = nil

    -- global world
    world = World:new()

    self:loadGamemode("basegm")
end

function GameState:exit()
    gamemode:exit()
    gamemode = nil

    world:destroy()
    world = nil
end

function GameState:update(dt)
    local success, err = pcall(world.update, world, dt)
    if not success then
        print(err)
    end

    local success, err = pcall(gamemode.update, gamemode, dt)
    if not success then
        print(err)
    end
end

function GameState:loadGamemode(name)
    if world then
        world:destroy()
    end

    world = World:new()

    if gamemode then
        gamemode:exit()
    end

    local gm = reload("gamemodes." .. name)
    gamemode = gm:new()

    self.gamemode = name
end

function GameState:reloadGamemode()
    self:loadGamemode(self:getGamemode())
end

function GameState:getGamemode()
    return self.gamemode
end

function GameState:draw(dt)
    love.graphics.origin()

    -- draw whatever the gamemode wants to draw
    local success, err = pcall(gamemode.draw, gamemode)
    if not success then
        print(err)
    end

    love.graphics.push()

    -- camera calculation
    local success, x, y, scale = pcall(gamemode.calcView, gamemode)
    if not success then
        print(x)
    else
        -- center the camera and scale the coordinates
        x = -x
        y = -y
        x = x*scale + love.graphics.getWidth()/2
        y = y*scale + love.graphics.getHeight()/2
        love.graphics.translate(x, y)
        love.graphics.scale(scale)
    end

    -- draw the world and all the entities
    local success, err = pcall(world.draw, world)
    if not success then
        print(err)
    end

    love.graphics.pop()
    
    -- draw gamemode hud or whatever
    local success, err = pcall(gamemode.postDraw, gamemode)
    if not success then
        print(err)
    end
end

function GameState:keypressed(key, isrepeat)
    if key == "escape" then
        statemanager:push("pause")
    end

    if not isrepeat then
        local success, err = pcall(gamemode.onKeyPressed, gamemode, key)
        if not success then
            print(err)
        end
    end
end

function GameState:keyreleased(key)
    local success, err = pcall(gamemode.onKeyReleased, gamemode, key)
    if not success then
        print(err)
    end
end

function GameState:getControllers()
    return world:getPlayers()
end

console:addConCommand("gamemode", function(cmd, args)
    if args[1] then
        statemanager:setState("game")
        statemanager:getState():loadGamemode(args[1])
    end
end)

console:addConCommand("reload", function(cmd, args)
    if statemanager:getStateName() == "game" then
        statemanager:getState():reloadGamemode()
    end
end)

return GameState
