local record Classy
	metamethod __call: function(Classy, string, ...: table): table
	
	of: function(table): table|nil
	name: function(table): string|nil
	is_a: function(table, table): integer|nil
	cast: function(table, table): table
	delegate: function(table, string, ...: table|string): table
	multimethod: function(...: integer): function
	overload: function(function, ...: string|table|function)
end

return Classy
