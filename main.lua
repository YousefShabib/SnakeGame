-- LÖVE supplies rendering, keyboard callbacks and the frame timer.
if not love then
    print("Run this graphical game with LÖVE: love .")
    print("For plain Lua 5.4 validation: lua tests/run.lua")
    return
end
local GameState = require("gamestate")
local manager
function love.load()
    love.graphics.setBackgroundColor(0.035, 0.055, 0.085)
    UI = {title = love.graphics.newFont(42), body = love.graphics.newFont(21), small = love.graphics.newFont(14)}
    manager = GameState:new()
end
function love.update(dt) manager:update(dt) end
function love.draw() manager:draw() end
function love.keypressed(key) manager:keypressed(key) end
