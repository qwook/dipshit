
InputKeys = {
    ["attack"]    = bit.lshift(1, 1);
    ["left"]      = bit.lshift(1, 2);
    ["right"]     = bit.lshift(1, 3);
    ["lookup"]    = bit.lshift(1, 4);
    ["lookdown"]  = bit.lshift(1, 5);
    ["jump"]      = bit.lshift(1, 6);
}

-------------------------------------------------------

local inputKeyMap = {}
local function addInputKey(playerId, command, inputkey)
    console:addConCommand("+" .. command, function()
        print( "down", playerId, inputkey )
    end)
    console:addConCommand("-" .. command, function()
        print( "up", playerId, inputkey )
    end)
end

-------------------------------------------------------

-- do this for 2 players.. or more??? heheheHEHehEHHEh
for playerId = 1, 2 do
    -- add input key as console command
    addInputKey(playerId, "attack" .. playerId,     "attack")
    addInputKey(playerId, "left" .. playerId,       "left")
    addInputKey(playerId, "right" .. playerId,      "right")
    addInputKey(playerId, "lookup" .. playerId,     "lookup")
    addInputKey(playerId, "lookdown" .. playerId,   "lookdown")
    addInputKey(playerId, "jump" .. playerId,       "jump")
end

-------------------------------------------------------

local Input = class("Input")
local bindsMap = {}

-- bind a key to a console command
function Input:bind(key, command)
    bindsMap[key] = command
end

function Input:inputPressed(input)
    if isrepeat or not bindsMap[input] then return end

    console:runCommand(bindsMap[input])
end

function Input:inputReleased(input)
    if not bindsMap[input] then return end

    -- if the binded input was prefixed with a "+"
    -- then the "-" command will be activated on release
    if bindsMap[input]:sub(1, 1) == "+" then
        console:runCommand("-" .. bindsMap[input]:sub(2))
    end
end

function Input:keypressed(key, isrepeat)
    self:inputPressed("key_" .. key)
end

function Input:keyreleased(key)
    self:inputReleased("key_" .. key)
end

function Input:mousepressed(x, y, button)
    self:inputPressed("mouse_" .. button)
end

function Input:mousereleased(x, y, button)
    self:inputReleased("mouse_" .. button)
end

local input = Input:new()

console:addConCommand("bind", function(cmd, args)
    input:bind(args[1], args[2])
end)

return input
