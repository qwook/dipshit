
function serialize(object)
    local t = type(object)

    if t == "number" then
        return tostring(object)
    elseif t == "string" then
        return "\"" .. tostring(object) .. "\""
    elseif t == "boolean" then
        return tostring(object)
    elseif t == "table" then
        local inside = "" 
        for k, v in pairs(object) do
            inside = inside .. "[" .. k .. "] = " .. serialize(v) .. ";\n"
        end
        return "{\n" .. inside .. "}\n"
    end

    return nil
end

function deserialize(string)
    local m = string:match("^%b{}\n")
    if m then
        local tbl = {}
        local body = m:sub(3, -3)

        local key = body:match("^%[([^]]+)%] = ")
        while (key) do
            body = body:sub(key:len()+6)
            val, body = deserialize(body)
            tbl[key] = val
            body = body:sub(3)
            key = body:match("^%[([^]]+)%] = ")
        end

        if body:len() > 0 then
            error("Unexpected: " .. body)
        end

        return tbl, string:sub(m:len()+1)
    end

    local m, e = string:match("^([0-9]*%.?[0-9]+)e%+([0-9]+)")
    if m and e then
        return tonumber(m) * math.pow(10, tonumber(e)), string:sub(m:len()+e:len()+2+1)
    end

    local m, e = string:match("^([0-9]*%.?[0-9]+)e%-([0-9]+)")
    if m and e then
        return tonumber(m) / math.pow(10, tonumber(e)), string:sub(m:len()+e:len()+2+1)
    end

    local m = string:match("^[0-9]*%.?[0-9]+")
    if m then
        return tonumber(m), string:sub(m:len()+1)
    end

    local m = string:match("^\"([^\"]*)\"")
    if m then
        return m, string:sub(m:len()+3)
    end

    local m = string:match("^true")
    if m then
        return true, string:sub(5)
    end

    local m = string:match("^false")
    if m then
        return false, string:sub(5)
    end
    
end
