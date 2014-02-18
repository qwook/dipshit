
------------------------------------------------------------
-- Players and things that need key/mouse/joy input
-- derive off of this.
--
-- The menustate actually uses one of these to start
-- the game.

local Controller = class("Controller")

function Controller:initialize()
    self._inputKeys = 0
    self._inputKeys2 = 0
    self._lastInputKeys = 0
end

function Controller:inputPressed(inputKey)
    local inputValue = InputKeys[inputKey]
    if bit.band(self._inputKeys, inputValue) ~= 0 then return end
    self._inputKeys = self._inputKeys + inputValue
end

function Controller:inputReleased(inputKey)
    local inputValue = InputKeys[inputKey]
    if bit.band(self._inputKeys, inputValue) == 0 then return end
    self._inputKeys = self._inputKeys - inputValue
end

function Controller:updateKeys(dt)
    self._lastInputKeys = self._inputKeys2
    self._inputKeys2 = self._inputKeys
end

function Controller:isKeyDown(inputKey)
    local inputValue = InputKeys[inputKey]
    return bit.band(self._inputKeys, inputValue) ~= 0
end

function Controller:wasKeyPressed(inputKey)
    local inputValue = InputKeys[inputKey]
    return bit.band(self._inputKeys2, inputValue) ~= 0 and
        bit.band(self._lastInputKeys, inputValue) == 0
end

function Controller:wasKeyReleased(inputKey)
    local inputValue = InputKeys[inputKey]
    return bit.band(self._inputKeys2, inputValue) == 0 and
        bit.band(self._lastInputKeys, inputValue) ~= 0
end

return Controller
