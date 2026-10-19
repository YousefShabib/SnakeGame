local Events = {}
Events.__index = Events
function Events:new() return setmetatable({listeners = {}}, self) end
function Events:subscribe(event, callback)
    self.listeners[event] = self.listeners[event] or {}
    table.insert(self.listeners[event], callback)
end
function Events:emit(event, data)
    for _, callback in ipairs(self.listeners[event] or {}) do callback(data) end
end
return Events
