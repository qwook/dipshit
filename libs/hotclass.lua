---------------------------------------------
-- Allows for hot-swappable classes

local middleclass = require("libs.middleclass")

-- store all classes in _R table
_R = {}
function class(name, ...)
    -- load class from _R if it exists
    -- otherwise create a new class
    if not _R[name] then _R[name] = middleclass(name, ...) end
    return _R[name]
end

---------------------------------------------

-- reloads modules
function reload(modulename)
    local oldPackage = package.loaded[modulename]
    package.loaded[modulename] = nil
    local ret = {pcall(require, modulename)}
    -- error
    if not ret[1] then
        print(ret[2])
        package.loaded[modulename] = oldPackage
        return oldPackage
    end
    -- remove the boolean then return the values
    table.remove(ret, 1)
    return unpack(ret)
end