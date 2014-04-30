
local EntityFactory = class("EntityFactory")

function EntityFactory:initialize()
    self.entityMap = {}
end

function EntityFactory:reloadEntities()
    local ents = love.filesystem.getDirectoryItems("entities")
    for k, v in pairs(ents) do
        local basename = v:match("(.+)%.lua")
        if basename then
            self.entityMap[basename] = reload("entities." .. basename)
            print("Loaded: " .. basename)
        end
    end
end

function EntityFactory:reloadEntity(entname)
    self.entityMap[basename] = reload("entities." .. entname)
end

function EntityFactory:create(entname)
    local newEnt = self.entityMap[entname:lower()]:new()
    if (type(newEnt) == "boolean") then
        error("Forgot to return entity in it's class definition!", -1);
    end
    return newEnt
end

local entityfactory = EntityFactory:new()

console:addConCommand("reload_ents", function()
    entityfactory:reloadEntities()
end)

entityfactory:reloadEntities()

return entityfactory
