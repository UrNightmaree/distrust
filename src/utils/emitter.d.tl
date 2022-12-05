local record Emitter
	metamethod __call: function(Emitter): Emitter

	missingHandlerType: function(Emitter, string, ...: any)
	once: function(Emitter, string, function): Emitter
	on: function(Emitter, string, function): Emitter
	listenerCount: function(Emitter, string): integer
	emit: function(Emitter, string, ...: any): Emitter
	removeListener: function(Emitter, string, function): integer|nil
	removeAllListeners: function(Emitter, string)
	listeners: function(Emitter, string): table
	wrap: function(Emitter, string)
	propagate: function(Emitter, string, table): table
end

return Emitter
