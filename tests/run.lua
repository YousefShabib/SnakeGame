package.path = './?.lua;./?/init.lua;' .. package.path
local V, Game = require('vector2'), require('snake_game')
local Events, HighScore = require('events'), require('highscore')
local count = 0
local function test(name, callback)
    callback(); count = count + 1; print('PASS ' .. name)
end
local function game() return Game:new(Events:new(), function(n) return n end) end
local function body(g, coordinates)
    g.snake = {}
    for _, p in ipairs(coordinates) do table.insert(g.snake, V:new(p[1], p[2])) end
end
test('vector operators', function()
    assert(V:new(1,2) + V:new(3,4) == V:new(4,6))
    assert(V:new(1,2) ~= V:new(2,1) and tostring(V:new(1,2)) == '(1, 2)')
end)
test('components and input commands', function()
    local e = require('entity'):new():addComponent('Position', V:new(1,2))
    assert(e:hasComponent('Position') and not e:hasComponent('Movement'))
    assert(e:getComponent('Position').y == 2)
    local input, n = require('input'):new(), 0
    input:bind('w', function() n = n + 1 end)
    input:handleKey('w'); input:handleKey('unknown'); assert(n == 1)
end)
test('timed movement', function()
    local g = game(); g:update(0.06); assert(g.snake[1].x == 10)
    g:update(0.06); assert(g.snake[1] == V:new(11,10))
    assert(g.entity:getComponent('Position') == g.snake[1])
end)
test('reverse and rapid double-turn prevention', function()
    local g = game(); g:changeDirection(-1,0); assert(not g.turnPending)
    g:changeDirection(0,-1); g:changeDirection(-1,0); g:move()
    assert(g.snake[1] == V:new(10,9))
end)
test('eating, growth, observer and free food', function()
    local g, score = game(), 0
    g.events:subscribe('food_eaten', function(data) score = data.score end)
    g.food = V:new(11,10); g:move()
    assert(#g.snake == 4 and g.score == 1 and score == 1)
    for _, p in ipairs(g.snake) do assert(p ~= g.food) end
end)
test('wall and self collisions', function()
    local g = game(); body(g, {{19,10},{18,10}}); g:move(); assert(g.gameOver)
    g = game(); body(g, {{2,2},{2,3},{3,3},{3,2},{3,1}})
    g.food = V:new(0,0); g:move(); assert(g.gameOver)
end)
test('vacating tail is legal', function()
    local g = game(); body(g, {{2,2},{2,3},{3,3},{3,2}})
    g.food = V:new(0,0); g:move(); assert(not g.gameOver)
end)
test('full board win', function()
    local g = game(); g.grid = 2; body(g, {{0,0},{0,1},{1,1}})
    g.food = V:new(1,0); g:move(); assert(g.won and g.gameOver and not g.food)
end)
test('pause', function()
    local g = game(); g.paused = true; g:update(1); g:changeDirection(0,1)
    assert(g.snake[1] == V:new(10,10) and not g.turnPending)
end)
test('persistent score and Lua 5.4 close support', function()
    local path = 'tests/.highscore-test-' .. tostring(os.time()) .. '.txt'
    local h = HighScore:new(path); assert(h:load() == 0)
    assert(h:save(42)); assert(h:load() == 42)
    local f = assert(io.open(path,'w')); f:write('invalid'); f:close()
    assert(h:load() == 0); os.remove(path)
    if _VERSION == 'Lua 5.4' then assert(HighScore.usesToBeClosed) end
end)
test('complete state flow with headless graphics adapter', function()
    local saved = {}
    _G.love = {graphics = setmetatable({}, {__index = function() return function() end end}),
        math = {random = function(n) return n end}, event = {quit = function() end},
        filesystem = {read = function(p) return saved[p] end,
            write = function(p,v) saved[p] = v; return true end}}
    _G.UI = {title = {}, body = {}, small = {}}
    local m = require('gamestate'):new(); assert(m.current == 'menu'); m:draw()
    m:keypressed('return'); assert(m.current == 'playing'); m:draw()
    m:keypressed('p'); assert(m.states.playing.game.paused); m:draw(); m:keypressed('p')
    local g = m.states.playing.game; g.food = V:new(11,10); m:update(0.12)
    assert(saved['highscore.txt'] == '1')
    g:finish(); m:draw(); m:keypressed('space')
    assert(m.states.playing.game.score == 0 and m.states.playing.best == 1)
    m:keypressed('escape'); assert(m.current == 'menu'); m:draw()
    _G.love = nil
end)
print(count .. ' tests passed (' .. _VERSION .. ')')
