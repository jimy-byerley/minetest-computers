computers.register_oscommand("help", "get help about a function", "help [COMMAND]", function(cmdline, pos, player)
	local command = string.match(cmdline, "help *(.+)")
	local message = ""
	
	if command == nil then
		for i=1,#computers.registered_command_names do
			local name = computers.registered_command_names[i]
			local short_desc = computers.registered_commands[name].short_description
			message = message..name.."     "..short_desc.."\n"
		end
		message = message.."\ntype \"help COMMAND\" to get usage"
	
	elseif command ~= nil and computers.registered_commands[command] ~= nil then
		message = command..":\t"..computers.registered_commands[command].short_description .. "\nusage:\n" .. computers.registered_commands[command].long_description
	end
	if message == "" then
		message = "no help for this command"
	end
 	
 	return message, true
end)
 
computers.register_oscommand("time", "get the time of day", "time", function(cmdline, pos, player)
	local message = "local time : "..(minetest.env:get_timeofday()*24)
	return message, true
end)


computers.register_oscommand("gps", "localize a player", "gps [-c PLAYER  get coordinates]\n    [-d PLAYER  get distance between computer and player]\n    [-r PLAYER   get relative coordinates]",
function(cmdline, pos, player)
	local message = "gps: error: unable to connect to satellite (in devel program)"
	return message, true
end)

computers.register_oscommand("mat", "get the material name of a bloc next to the computer", "mat [z+1] [z-1] [y+1] [y-1] [x+1] [x-1]", 
function(cmdline, pos, player)
	local message = "mat: error: incompatible driver (in devel program)"
	return message, true
end)

computers.register_oscommand("com", "create a connexion between two computers", "com [-c COODINATES  make a connexion between this computer and an other at coordinates]\n    [-p PLAYERNAME  make a connexion between this computer and the closest computer to the player]", function(cmdline, pos, player)
	local command, opt = string.match(cmdline, "^([^ ]+) *(%a+)")
	if opt == "-c" then
		local x, y, z
		command, opt,x,y,z = string.match(cmdline, "^([^ ]+) *(%a+) *(%d+)[, ] *(%d+)[, ] *(%d+)")
		-- ...
		return command..": unable to connect: no network available (in devel program)"
	else
		local command, opt, playername = string.match(cmdline, "^([^ ]+) *(%a+) *(%a+)")
		local player = minetest.get_player_by_name(playername)
		local p = player.getpos()
		-- ...
		return command..": unable to connect: no network available (in devel program)"
	end
end);
