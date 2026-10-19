local SnakeGame = require("snake_game")
local Events = require("events")
local Input = require("input")
local HighScore = require("highscore")
local State = {}
State.__index = State
function State:new(manager)
    return setmetatable({manager = manager, highscore = HighScore:new()}, self)
end
function State:saveBest(score)
    if score > self.best then
        self.best = score
        local ok, err = self.highscore:save(score)
        self.saveError = not ok and tostring(err) or nil
    end
end
function State:enter()
    self.best, self.saveError = self.highscore:load(), nil
    self.events, self.input = Events:new(), Input:new()
    self.events:subscribe("food_eaten", function(data) self:saveBest(data.score) end)
    self.events:subscribe("game_over", function(data) self:saveBest(data.score) end)
    self.game = SnakeGame:new(self.events, love.math.random)
    local directions = {up = {0,-1}, w = {0,-1}, down = {0,1}, s = {0,1},
        left = {-1,0}, a = {-1,0}, right = {1,0}, d = {1,0}}
    for key, direction in pairs(directions) do
        local dx, dy = direction[1], direction[2]
        self.input:bind(key, function() self:changeDirection(dx, dy) end)
    end
    self.input:bind("escape", function() self.manager:switch("menu") end)
    self.input:bind("p", function()
        if not self.game.gameOver then self.game.paused = not self.game.paused end
    end)
    local restart = function() if self.game.gameOver then self:enter() end end
    self.input:bind("space", restart); self.input:bind("return", restart)
end
function State:changeDirection(dx, dy) self.game:changeDirection(dx, dy) end
function State:update(dt) self.game:update(dt) end
function State:keypressed(key) self.input:handleKey(key) end
function State:draw()
    local g = love.graphics
    g.setFont(UI.title); g.setColor(0.3, 0.95, 0.68); g.print("SNAKE", 40, 24)
    g.setFont(UI.body); g.setColor(0.87, 0.93, 0.98)
    g.printf("SCORE  " .. self.game.score .. "     BEST  " .. self.best, 40, 84, 560, "right")
    self.game:draw()
    g.setFont(UI.small); g.setColor(0.57, 0.67, 0.76)
    g.printf(self.saveError and "Could not save best score" or "ARROWS / WASD  Move     P  Pause     ESC  Menu", 0, 708, 640, "center")
    if self.game.gameOver or self.game.paused then
        g.setColor(0.025, 0.04, 0.07, 0.9); g.rectangle("fill", 40, 130, 560, 560, 8)
        g.setColor(0.7, 1, 0.82); g.setFont(UI.title)
        g.printf(self.game.paused and "PAUSED" or (self.game.won and "YOU WIN!" or "GAME OVER"), 40, 330, 560, "center")
        g.setColor(0.87, 0.93, 0.98); g.setFont(UI.body)
        g.printf(self.game.paused and "Press P to continue" or ("Score: " .. self.game.score .. "\nENTER / SPACE to restart"), 40, 395, 560, "center")
    end
end
return State
