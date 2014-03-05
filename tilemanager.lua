
local TileManager = class("TileManager")

TILESIZE = 16

function TileManager:initialize()
    self.tilesets = {}

    local files = love.filesystem.getDirectoryItems("assets/tilesets")
    for k, file in pairs(files) do
        local fn, ext = file:match("(.+)%.(.+)$")
        if ext == "lua" then
            local chunk = love.filesystem.load("assets/tilesets/" .. fn .. "." .. ext)
            local success, data = pcall(chunk)
            if success then
                -- awesome, iterate through the tileset data
                if not data.image then
                    return print("No image defined!")
                end

                local image = loadImage("tilesets/" .. data.image)

                for k, v in pairs(data.tiles) do
                    v.name = k

                    local x = v.x
                    local y = v.y
                    v.tileset = fn
                    v.image = image
                    v.quad = love.graphics.newQuad(x*TILESIZE, y*TILESIZE, TILESIZE, TILESIZE, image:getWidth(), image:getHeight())
                end

                self.tilesets[fn] = data
            else
                -- print out the error
                print(data)
            end
        end
    end
end

function TileManager:getTile(tileset, name)
    return self.tilesets[tileset].tiles[name]
end

function TileManager:getTileSets()
    return self.tilesets
end

return TileManager:new()
