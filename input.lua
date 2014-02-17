
-------------------------------------------------------
-- Define input keys
-- This is the only place you need to define them.
-- The console command bindings will append the player number

InputKeys = {
    ["attack"]    = bit.lshift(1, 1);
    ["left"]      = bit.lshift(1, 2);
    ["right"]     = bit.lshift(1, 3);
    ["lookup"]    = bit.lshift(1, 4);
    ["lookdown"]  = bit.lshift(1, 5);
    ["jump"]      = bit.lshift(1, 6);
}

-------------------------------------------------------
-- Internal function so that input keys can be
-- invoked by the console.

local inputKeyMap = {}
local function addInputKey(playerId, command, inputkey)
    console:addConCommand("+" .. command, function()
        local controllers = statemanager:getState():getControllers()
        local controller = controllers[playerId] or controllers[1]
        if controller then
            controller:inputPressed(inputkey)
        end
    end)
    console:addConCommand("-" .. command, function()
        local controllers = statemanager:getState():getControllers()
        local controller = controllers[playerId] or controllers[1]
        if controller then
            controller:inputReleased(inputkey)
        end
    end)
end

-------------------------------------------------------
-- Bind input keys

-- do this for 2 players.. or more??? heheheHEHehEHHEh
for playerId = 1, 2 do
    -- add input key as console command
    for inputKey, val in pairs(InputKeys) do
        -- we do da loop da loop through the InputKeys
        -- then we append the player number to the InputKey
        -- a boom bam bip boom bop
        addInputKey(playerId, inputKey .. playerId, inputKey)
    end
end

-------------------------------------------------------
-- CAN YOU FEEL THE SUNSHINE
-- DOES IT BRIGHTEN UP YOUR DAY?
-- DO YOU FEEL THAT SOME TIMES
-- YOU JUST HAVE TO GET AWAYYYY??

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

-- lets you bind keys through the console
console:addConCommand("bind", function(cmd, args)
    input:bind(args[1], args[2])
end)

return input
