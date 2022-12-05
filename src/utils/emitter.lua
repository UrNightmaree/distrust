local clsy = require "classy"

local Emitter = clsy "Emitter"

function Emitter:missingHandlerType(name, ...)
  if name == "error" then
    --error(tostring(args[1]))
    -- we define catchall error handler
    if self ~= process then
      -- if process has an error handler
      local handlers = rawget(process, "handlers")
      if handlers and handlers["error"] then
        -- delegate to process error handler
        process:emit("error", ..., self)
      end
    end
  end
end

local onceMeta = {}
function onceMeta:__call(...)
  self.emitter:removeListener(self.name, self)
  return self.callback(...)
end

function Emitter:once(name, callback)
  return self:on(name, setmetatable({
    emitter = self,
    name = name,
    callback = callback
  }, onceMeta))
end

function Emitter:on(name, callback)
  local handlers = rawget(self, "handlers")
  if not handlers then
    handlers = {}
    rawset(self, "handlers", handlers)
  end
  local handlers_for_type = rawget(handlers, name)
  if not handlers_for_type then
    if self.addHandlerType then
      self:addHandlerType(name)
    end
    handlers_for_type = {}
    rawset(handlers, name, handlers_for_type)
  end
  table.insert(handlers_for_type, callback)
  return self
end

function Emitter:listenerCount(name)
  local handlers = rawget(self, "handlers")
  if not handlers then
    return 0
  end
  local handlers_for_type = rawget(handlers, name)
  if not handlers_for_type then
    return 0
  else
    local count = 0
    for i = 1, #handlers_for_type do
      if handlers_for_type[i] then
        count = count + 1
      end
    end
    return count
  end
end

function Emitter:emit(name, ...)
  local handlers = rawget(self, "handlers")
  if not handlers then
    self:missingHandlerType(name, ...)
    return
  end
  local handlers_for_type = rawget(handlers, name)
  if not handlers_for_type then
    self:missingHandlerType(name, ...)
    return
  end
  for i = 1, #handlers_for_type do
    local handler = handlers_for_type[i]
    if handler then handler(...) end
  end
  for i = #handlers_for_type, 1, -1 do
    if not handlers_for_type[i] then
      table.remove(handlers_for_type, i)
    end
  end
  return self
end

function Emitter:removeListener(name, callback)
  local num_removed = 0
  local handlers = rawget(self, "handlers")
  if not handlers then return end
  local handlers_for_type = rawget(handlers, name)
  if not handlers_for_type then return end
  if callback then
    for i = #handlers_for_type, 1, -1 do
      local h = handlers_for_type[i]
      if type(h) == "function" then
        h = h == callback
      elseif type(h) == "table" then
        h = h == callback or h.callback == callback
      end
      if h then
        handlers_for_type[i] = false
        num_removed = num_removed + 1
      end
    end
  else
    for i = #handlers_for_type, 1, -1 do
      handlers_for_type[i] = false
      num_removed = num_removed + 1
    end
  end
  return num_removed > 0 and num_removed or nil
end

function Emitter:removeAllListeners(name)
  local handlers = rawget(self, "handlers")
  if not handlers then return end
  if name then
    local handlers_for_type = rawget(handlers, name)
    if handlers_for_type then
      for i = #handlers_for_type, 1, -1 do
          handlers_for_type[i] = false
      end
    end
  else
    rawset(self, "handlers", {})
  end
end

function Emitter:listeners(name)
  local handlers = rawget(self, "handlers")
  return handlers and (rawget(handlers, name) or {}) or {}
end

function Emitter:wrap(name)
  local fn = self[name]
  self[name] = function (err, ...)
    if (err) then return self:emit("error", err) end
    return fn(self, ...)
  end
end

function Emitter:propagate(eventName, target)
  if (target and target.emit) then
    self:on(eventName, function (...) target:emit(eventName, ...) end)
    return target
  end

  return self
end

return Emitter
