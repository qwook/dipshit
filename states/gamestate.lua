
local BaseState = require("states.basestate")
local GameState = class("GameState", BaseState)

local ent = nil

function GameState:initialize()
    ent = entityfactory:create("baseentity")
    self.gamemode = nil

    self:loadGamemode("basegm")
end

function GameState:update(dt)
    local success, err = pcall(self.gamemode.update, self.gamemode, dt)
    if not success then
        print(err)
    end
end

function GameState:loadGamemode(gamemode)
    if self.gamemode then
        self.gamemode:exit()
    end

    local gm = reload("gamemodes." .. gamemode)
    self.gamemode = gm:new()
end

function GameState:draw(dt)
    love.graphics.setColor(255, 0, 0)
    love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(255, 255, 255)
    love.graphics.print("Game.", 0, 0)

    ent:draw()

    local success, err = pcall(self.gamemode.draw, self.gamemode)
    if not success then
        print(err)
    end

    local success, err = pcall(self.gamemode.postDraw, self.gamemode)
    if not success then
        print(err)
    end
end

function GameState:keypressed(key, isrepeat)
    if key == "escape" then
        statemanager:push("pause")
    end

    if not isrepeat then
        local success, err = pcall(self.gamemode.onKeyPressed, self.gamemode, key)
        if not success then
            print(err)
        end
    end
end

function GameState:keyreleased(key)
    local success, err = pcall(self.gamemode.onKeyReleased, self.gamemode, key)
    if not success then
        print(err)
    end
end

function GameState:getControllers(key)
    local success, err = pcall(self.gamemode.getControllers, self.gamemode, key)
    if not success then
        print(err)
        return {}
    else
        return err
    end
end

return GameState
