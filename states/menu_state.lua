local Input = require("input")
local HighScore = require("highscore")
local Menu = {}
Menu.__index = Menu
function Menu:new(manager)
    local state = setmetatable({manager = manager, input = Input:new()}, self)
    local start = function() manager:switch("playing") end
    state.input:bind("return", start)
    state.input:bind("space", start)
    state.input:bind("escape", function() love.event.quit() end)
    return state
end
function Menu:enter() self.best = HighScore:new():load() end
function Menu:update(dt) end
function Menu:keypressed(key) self.input:handleKey(key) end
function Menu:draw()
    local g = love.graphics
    g.setColor(0.3, 0.95, 0.68)
    g.setFont(UI.title); g.printf("S N A K E", 0, 205, 640, "center")
    g.setColor(0.87, 0.93, 0.98)
    g.setFont(UI.body); g.printf("A little game. One more bite.", 0, 275, 640, "center")
    g.printf("BEST  " .. self.best, 0, 335, 640, "center")
    g.setColor(0.3, 0.95, 0.68)
    g.printf("Press ENTER to play", 0, 415, 640, "center")
    g.setColor(0.57, 0.67, 0.76); g.setFont(UI.small)
    g.printf("ARROWS / WASD  Move     P  Pause\nESC  Exit", 0, 495, 640, "center")
end
return Menu
