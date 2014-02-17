
local Console = class("Console")

local concommandMap = {}
function Console:addConCommand(command, fn)
    concommandMap[command] = fn
end

function Console:runCommand(command, args)
    if not command or not concommandMap[command] then
        print("No such command: " .. tostring(command))
        return
    end

    concommandMap[command](command, args)
end

function Console:runString(command)
    local args = {}
    command:gsub("[^ ]+", function(word) table.insert(args, word) end)

    local cmd = args[1]
    table.remove(args, 1)

    self:runCommand(cmd, args)
end

local convarMap = {}
function Console:addConVar(convar, default, type)
    convarMap[convar] = {value = default, default = default, type = type}
    self:addConCommand(convar, function(cmd, args)
        -- if type(args[1]) ~= convarMap[cmd].type then
        if args[1] == nil then
            print(cmd .. ": " .. convarMap[cmd].value .. " default: " .. convarMap[cmd].default)
        end
        convarMap[cmd].value = args[1]
    end)
end

function Console:getConVar(convar)
    if convarMap[convar].type == "boolean" then
        return convarMap[convar].value == "true" or convarMap[convar].value == "1"
    elseif convarMap[convar].type == "number" then
        return tonumber(convarMap[convar].value)
    end
    return convarMap[convar].value
end

return Console:new()
