
class = require("libs.middleclass")

require("libs.mathext") -- this extends the math library
require("libs.tableext") -- this extends the table library
require("libs.print2") -- this adds "print2"
require("libs.loveframes")

local arguments = {}
local last = nil
for k, v in pairs(arg) do
    if v:sub(1, 1) == "-" then
        arguments[v:sub(2):lower()] = true
        last = v:sub(2):lower()
    elseif last then
        arguments[last] = v
        last = nil
    end
end

statemanager = require("statemanager")
console = require("console")
input = require("input")

input:bind("key_g", "+attack1")
input:bind("key_h", "+jump1")
input:bind("key_a", "+left1")
input:bind("key_d", "+right1")
input:bind("key_w", "+lookup1")
input:bind("key_s", "+lookdown1")

input:bind("key_.", "+attack2")
input:bind("key_/", "+jump2")
input:bind("key_left", "+left2")
input:bind("key_right", "+right2")
input:bind("key_up", "+lookup2")
input:bind("key_down", "+lookdown2")

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.graphics.setBackgroundColor(134, 200, 255)

    if arguments["state"] then
        statemanager:setState(arguments["state"])
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
    input:keypressed(key, isrepeat)
    statemanager:keypressed(key, isrepeat)
    loveframes.keypressed(key, isrepeat)
end

function love.keyreleased(key)
    input:keyreleased(key)
    statemanager:keyreleased(key)
    loveframes.keyreleased(key, isrepeat)
end

function love.textinput(unicode)
    loveframes.textinput(unicode)
end

function love.mousepressed(x, y, button)
    input:mousepressed(x, y, button)
    loveframes.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
    input:mousereleased(x, y, button)
    loveframes.mousereleased(x, y, button)
end
