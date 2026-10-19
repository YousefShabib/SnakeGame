local HighScore = {}
HighScore.__index = HighScore
function HighScore:new(path) return setmetatable({path = path or "highscore.txt"}, self) end
-- Compile Lua 5.4 syntax only on a runtime which supports it. This keeps
-- the same module parseable by LÖVE's LuaJIT (Lua 5.1 compatible).
local compile = loadstring or load
local build = compile([=[
return function(path, mode, value)
    -- Lua 5.4 to-be-closed variables close files even if read/write raises.
    local file <close>, err = io.open(path, mode)
    if not file then return nil, err end
    if mode == "w" then
        local ok, writeError = file:write(tostring(value))
        if not ok then return nil, writeError end
        return true
    end
    return file:read("*a")
end
]=])
local modernIO = build and build()
HighScore.usesToBeClosed = modernIO ~= nil
function HighScore:save(score)
    score = math.max(0, math.floor(tonumber(score) or 0))
    if love and love.filesystem then
        return love.filesystem.write(self.path, tostring(score))
    end
    if modernIO then return modernIO(self.path, "w", score) end
    local file, err = io.open(self.path, "w")
    if not file then return nil, err end
    local ok, result = pcall(function() return assert(file:write(tostring(score))) end)
    local closed, closeError = file:close()
    if not ok then return nil, result end
    return closed, closeError
end
function HighScore:load()
    local content
    if love and love.filesystem then
        content = love.filesystem.read(self.path)
    elseif modernIO then
        content = modernIO(self.path, "r")
    else
        local file = io.open(self.path, "r")
        if file then
            local ok, value = pcall(function() return file:read("*a") end)
            file:close()
            if ok then content = value end
        end
    end
    local value = tonumber(content) or 0
    if value ~= value or value == math.huge then return 0 end
    return math.max(0, math.floor(value))
end
return HighScore
