---------------------------------------------
-- Allows for hot-swappable classes

class = require("libs.sunclass")

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