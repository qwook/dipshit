
local Entity = class("BaseEntity")
Entity.x = 0
Entity.y = 0
Entity.w = 20
Entity.h = 20
Entity.ang = 0

-- the initialize function needs to follow a strict rule
-- of only initializing instance variables
-- calling functions inside here will possibily break it
function Entity:initialize(...)
end

function Entity:spawn(context)
    context = context or world
    context:spawnEntity(self)
end

function Entity:setPos(x, y)
    self.x = x
    self.y = y
end

function Entity:getPos()
    return self.x, self.y
end

function Entity:setSize(w, h)
    self.w = w
    self.h = h
end

function Entity:getSize()
    return self.w, self.h
end

function Entity:setAngle(ang)
    self.ang = a
end

function Entity:getAngle()
    return self.ang
end

function Entity:draw()
    love.graphics.setColor(0, 255, 0)
    love.graphics.rectangle("fill",
        -self.w/2, -self.h/2,
        self.w, self.h)
end

function Entity:update(dt)
end

-- this adds a bit of overhead
-- but checks for newly created instance variables
-- and deleted variables
-- if arguments["watch"] then
--     function Entity:__index(index)
--         local class = getmetatable(self)

--         local obj = {}
--         local o = setmetatable(obj, class)
--         class.initialize(o)

--         for k, v in pairs(obj) do
--             if not rawget(self, k) then
--                 rawset(self, k, v)
--             end
--         end

--         for k, v in pairs(self) do
--             if not rawget(obj, k) then
--                 rawset(self, k, nil)
--             end
--         end

--         local ret = rawget(self, index) or class[index]
--         if not ret and class.super then
--             return class.super[index]
--         end
--         return ret
--     end
-- end

return Entity
