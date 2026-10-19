local unpack = table.unpack or unpack
local Vector2 = require("vector2")
local Entity = require("entity")
local SnakeGame = {}
SnakeGame.__index = SnakeGame
function SnakeGame:new(events, random, grid)
    local game = setmetatable({events = events, random = random or math.random,
        grid = grid or 20, cell = 28, timer = 0, step = 0.12, score = 0,
        gameOver = false, won = false, paused = false, turnPending = false}, self)
    game.snake = {Vector2:new(10, 10), Vector2:new(9, 10), Vector2:new(8, 10)}
    game.direction = Vector2:new(1, 0)
    game.entity = Entity:new()
    game.entity:addComponent("Position", game.snake[1])
        :addComponent("Movement", {dx = 1, dy = 0})
        :addComponent("Renderer", {color = {0.24, 0.85, 0.62}, size = game.cell - 2})
    game:spawnFood()
    return game
end
function SnakeGame:emit(name, data)
    if self.events then self.events:emit(name, data) end
end
function SnakeGame:spawnFood()
    local free, occupied = {}, {}
    for _, segment in ipairs(self.snake) do occupied[segment.y * self.grid + segment.x] = true end
    for y = 0, self.grid - 1 do
        for x = 0, self.grid - 1 do
            if not occupied[y * self.grid + x] then table.insert(free, Vector2:new(x, y)) end
        end
    end
    if #free == 0 then self.food = nil; self:finish(true); return end
    self.food = free[self.random(#free)]
end
function SnakeGame:finish(won)
    self.gameOver, self.won = true, won or false
    self:emit("game_over", {score = self.score, won = self.won})
end
function SnakeGame:changeDirection(dx, dy)
    if self.gameOver or self.paused or self.turnPending or math.abs(dx) + math.abs(dy) ~= 1 then return end
    if dx == -self.direction.x and dy == -self.direction.y then return end
    if dx == self.direction.x and dy == self.direction.y then return end
    self.nextDirection, self.turnPending = Vector2:new(dx, dy), true
end
function SnakeGame:move()
    if self.nextDirection then self.direction = self.nextDirection end
    self.nextDirection, self.turnPending = nil, false
    local movement = self.entity:getComponent("Movement")
    movement.dx, movement.dy = self.direction.x, self.direction.y
    local head = self.snake[1] + Vector2:new(movement.dx, movement.dy)
    if head.x < 0 or head.y < 0 or head.x >= self.grid or head.y >= self.grid then self:finish(); return end
    local eating = self.food and head == self.food
    -- The tail vacates its cell on a non-eating move, so entering it is legal.
    local last = #self.snake - (eating and 0 or 1)
    for i = 1, last do if head == self.snake[i] then self:finish(); return end end
    table.insert(self.snake, 1, head)
    self.entity:addComponent("Position", head)
    if eating then
        self.score = self.score + 1
        self:emit("food_eaten", {score = self.score})
        self:spawnFood()
    else table.remove(self.snake) end
end
function SnakeGame:update(dt)
    if self.gameOver or self.paused then return end
    self.timer = self.timer + math.min(dt, 0.25)
    while self.timer >= self.step and not self.gameOver do
        self.timer = self.timer - self.step
        self:move()
    end
end
function SnakeGame:draw()
    local g, ox, oy = love.graphics, 40, 130
    g.setColor(0.055, 0.09, 0.13)
    g.rectangle("fill", ox, oy, self.grid * self.cell, self.grid * self.cell, 8)
    if self.food then
        g.setColor(1, 0.43, 0.39)
        g.circle("fill", ox + (self.food.x + 0.5) * self.cell, oy + (self.food.y + 0.5) * self.cell, 9)
    end
    local renderer = self.entity:getComponent("Renderer")
    for i, segment in ipairs(self.snake) do
        if i == 1 then g.setColor(0.7, 1, 0.82) else g.setColor(unpack(renderer.color)) end
        g.rectangle("fill", ox + segment.x * self.cell + 1, oy + segment.y * self.cell + 1,
            renderer.size, renderer.size, 5)
    end
end
return SnakeGame
