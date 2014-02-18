
local Timer = class("Timer")

function Timer:initialize()
    self.updateList = {}
    self.timeouts = {}
end

function Timer:onNextUpdate(cb)
    table.insert(self.updateList, cb)
end

function Timer:setTimeout(cb, delay)
    table.insert(self.timeouts, {cb = cb, delay = love.timer.getTime() + delay})
end

function Timer:clearUpdates()
    table.clear(self.timeouts)
    table.clear(self.updateList)
end

function Timer:update(dt)

    while (#self.updateList > 0) do
        self.updateList[1]()
        table.remove(self.updateList, 1)
    end

    local tmp = {}
    for k,v in pairs(self.timeouts) do
        if (love.timer.getTime() > v.delay) then
            v.cb()
        else
            table.insert(tmp, v)
        end
    end
    table.clear(self.timeouts)
    table.copyto(tmp, self.timeouts)

end

return Timer
