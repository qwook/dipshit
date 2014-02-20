
local BaseState = require("states.basestate")
local GameState = class("GameState", BaseState)

local World = require("world")

-- Everything here is protected in pcalls.
-- Errors should not crash the game, but instead print out!
-- If the game crashes, blame Henry!

function GameState:initialize()
    self.gamemode = nil

    -- global world
    world = World:new()

    self:loadGamemode(arguments["gamemode"] or "basegm")
end

function GameState:exit()
    gamemode:exit()
    gamemode = nil

    world:destroy()
    world = nil
end

function GameState:update(dt)
    -- try { world:update(dt) } catch { print(error) }
    local success, err = pcall(world.update, world, dt)
    if not success then
        print(err)
    end

    -- try { gamemode:update(dt) } catch { print(error) }
    local success, err = pcall(gamemode.update, gamemode, dt)
    if not success then
        print(err)
    end
end

function GameState:loadGamemode(name)


    local gm = reload("gamemodes." .. name)
    if not gm then
        print("Did not return a gamemode class!")
        return
    end

    if world then
        world:destroy()
    end

    world = World:new()

    if gamemode then
        gamemode:exit()
    end

    gamemode = gm:new()

    self.gamemode = name


    if true then return end

    local gm = reload("gamemodes." .. name)
    if not gm then
        print("Did not return a gamemode class!")
        return
    end

    if world then
        world:destroy()
    end

    world = World:new()

    if gamemode then
        gamemode:exit()
    end

    -- try { gm:new() } catch { print(error) }
    local success, newgamemode = pcall(gm.new, gm)
    if success and newgamemode then
        gamemode = newgamemode
        self.gamemode = name
    else
        print(newgamemode)
        self:loadGamemode("basegm")
    end
end

function GameState:reloadGamemode()
    self:loadGamemode(self:getGamemode())
end

function GameState:getGamemode()
    return self.gamemode
end

function GameState:draw(dt)
    love.graphics.origin()
    love.graphics.push()

    -- draw whatever the gamemode wants to draw
    -- try { gamemode:preDraw() } catch { print(error) }
    local success, err = pcall(gamemode.preDraw, gamemode)
    if not success then
        print(err)
    end

    -- camera calculation
    -- try { gamemode:calcView() } catch { print(error) }
    local success, x, y, scale = pcall(gamemode.calcView, gamemode)
    if not success then
        print(x)
    else
        -- in case we don't get any returns
        x = x or 0
        y = y or 0
        scale = scale or 1

        -- center the camera and scale the coordinates
        x = -x
        y = -y
        x = x*scale + love.graphics.getWidth()/2
        y = y*scale + love.graphics.getHeight()/2
        love.graphics.translate(x, y)
        love.graphics.scale(scale)
    end

    -- draw the world and all the entities
    -- try { world:draw() } catch { print(error) }
    local success, err = pcall(world.draw, world)
    if not success then
        print(err)
    end

    -- try { gamemode:postDraw() } catch { print(error) }
    local success, err = pcall(gamemode.postDraw, gamemode)
    if not success then
        print(err)
    end

    love.graphics.pop()
    
    -- draw gamemode hud or whatever
    -- try { gamemode:drawHUD() } catch { print(error) }
    local success, err = pcall(gamemode.drawHUD, gamemode)
    if not success then
        print(err)
    end

    love.graphics.origin()
end

function GameState:keypressed(key, isrepeat)
    if key == "escape" then
        statemanager:push("pause")
    end

    if not isrepeat then
        -- try { gamemode:onKeyPressed(key) } catch { print(error) }
        local success, err = pcall(gamemode.onKeyPressed, gamemode, key)
        if not success then
            print(err)
        end
    end
end

function GameState:keyreleased(key)
    -- try { gamemode:onKeyReleased(key) } catch { print(error) }
    local success, err = pcall(gamemode.onKeyReleased, gamemode, key)
    if not success then
        print(err)
    end
end

function GameState:mousepressed(x, y, button)
    -- try { gamemode:onMousePressed(x, y, button) } catch { print(error) }
    local success, err = pcall(gamemode.onMousePressed, gamemode, x, y, button)
    if not success then
        print(err)
    end
end

function GameState:mousereleased(x, y, button)
    -- try { gamemode:onMouseReleased(x, y, button) } catch { print(error) }
    local success, err = pcall(gamemode.onMouseReleased, gamemode, x, y, button)
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
