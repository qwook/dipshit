
class = require("libs.middleclass")

require("libs.mathext") -- this extends the math library
require("libs.tableext") -- this extends the table library
require("libs.print2") -- this adds "print2"
require("libs.loveframes")

local arguments = {}
for k, v in pairs(arg) do
    if v:sub(1, 1) == "-" then
        arguments[v:sub(2):lower()] = true
    end
end

local StateManager = require("statemanager")
statemanager = StateManager:new()

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.graphics.setBackgroundColor(134, 200, 255)

    if arguments["game"] then
        statemanager:setState("game")
    else
        statemanager:setState("menu")
    end
end

function love.update(dt)
    statemanager:update(dt)
    loveframes.update(dt)
end

function love.draw()
    statemanager:draw()
    loveframes.draw()
end

function love.keypressed(key, isrepeat)
    statemanager:keypressed(key, isrepeat)
    loveframes.keypressed(key, isrepeat)
end

function love.keyreleased(key)
    statemanager:keyreleased(key)
    loveframes.keyreleased(key, isrepeat)
end

function love.textinput(unicode)
    loveframes.textinput(unicode)
end

function love.mousepressed(x, y, button)
    loveframes.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
    loveframes.mousereleased(x, y, button)
end
