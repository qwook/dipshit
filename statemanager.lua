
local StateManager = class("StateManager")
StateManager.states = {
    menu = require("states.menustate"),
    game = require("states.gamestate"),
    pause = require("states.pausestate"),
}

function StateManager:initialize()
    self.stateStack = {}
end

function StateManager:getState()
    return self.states[#self.states]
end

function StateManager:getStateName()
    return self:getState()._name
end

function StateManager:setState(statename)
    self:clear()
    self:push(statename)
end

function StateManager:clear()
    while #self.states > 0 do
        self.states[#self.states]:exit()
        table.remove(self.states, #self.states)
    end
end

function StateManager:push(statename)
    local state = self.states[statename]:new()
    state._name = statename
    table.insert(self.states, state)

    loveframes.SetState(statename)
end

function StateManager:pop()
    self.states[#self.states]:exit()
    table.remove(self.states, #self.states)

    loveframes.SetState(self.states[#self.states])
end

function StateManager:draw()
    -- draws bleed through states
    for i, state in ipairs(self.states) do
        state:draw()
    end
end

function StateManager:update(dt)
    self.states[#self.states]:update(dt)
end

function StateManager:keypressed(key, isrepeat)
    self.states[#self.states]:keypressed(key, isrepeat)
end

function StateManager:keyreleased(key)
    self.states[#self.states]:keyreleased(key)
end

return StateManager
