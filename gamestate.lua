local GameState = {}
GameState.__index = GameState
function GameState:new()
    local manager = setmetatable({states = {}, current = nil}, self)
    manager.states.menu = require("states.menu_state"):new(manager)
    manager.states.playing = require("states.game_state"):new(manager)
    manager:switch("menu")
    return manager
end
function GameState:switch(name)
    assert(self.states[name], "Unknown state: " .. tostring(name))
    local old = self.states[self.current]
    if old and old.leave then old:leave() end
    self.current = name
    local state = self.states[name]
    if state.enter then state:enter() end
end
function GameState:update(dt) self.states[self.current]:update(dt) end
function GameState:draw() self.states[self.current]:draw() end
function GameState:keypressed(key) self.states[self.current]:keypressed(key) end
return GameState
