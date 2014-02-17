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
    package.loaded[modulename] = nil
    return require(modulename)
end