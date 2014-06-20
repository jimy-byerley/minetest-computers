computers.register_oscommand("help", function(cmdline, pos, player)
	local command = string.match(cmdline, "help *(.+)")
	local message
	if command == nil then
		message = "available commands : exit date localisation write read login logout password mail\n\ttype help COMMAND  to have arguments of command"
	else
		message = computers.computer_help[command]
	end
	if message == nil then
		message = "no help for this command"
	end
 	return message, true
end)
 
computers.register_oscommand("date", function(cmdline, pos, player)
	local message = "[local time : "..(minetest.env:get_timeofday()*24).." ]"
	return message, true
end,
"date:    give the faction time of day")

computers.register_oscommand("localisation", function(cmdline, pos, player)
	message = "local coordinates : "..pos.x..", "..pos.y..", "..pos.z.."]"
	return message, true
end,
"localisation:   give the computer coordinates")


computers.register_oscommand("connect", function(cmdline, pos, player)
	local command = ""
	local continue = true
	local x = 0
	local y = 0
	local z = 0
	local mode = ""
	command, x, y, z, mode = string.match(cmdline, "^([^ ]+) *([%d.-]+)[, ] *([%d.-]+)[, ] *([%d.-]+) *(.+)")
	
	if x==nil or y==nil or z==nil then
		message = "bad command : connect X,Y,Z [OPTIONS]"
	else
		local remote_pos = {x=x, y=y, z=z}
		local node = minetest.env:get_node(remote_pos
		)
		if node.name == "ignore" then
			message = "no host online"
		else
			message = "connect : bad mode"
			if mode=="test" then message = "host online" end
			if mode=="enable" then
				minetest.env:punch_node({x=x, y=y, z=z})
				message = "[host enabled]"
			end
			if mode=="tunnel" then
				if node.name == "computers:laptop_close" then
					message = "disabled remote host, can't connect to it"
				else 
					if node.name == "computers:laptop_connect" then
						message = "remote host is busy"
					else
						if node.name ~= "computers:laptop_blank" and node.name ~= "computers:laptop_smalltext" and node.name ~= "computers:laptop_bigtext" then
							message = "destination is not a computer"
						else
							node.name = "computers:laptop_connect"
							minetest.env:set_node(remote_pos, node)
							local self = minetest.env:get_node(pos)
							self.name = "computers:laptop_connect"
							minetest.env:set_node(pos, self)
							--set metadata
							local meta = minetest.env:get_meta(pos)
							local remotemeta = minetest.env:get_meta(remote_pos)
							meta:set_string("formspec", "field[destination;;${destination}]field[text;;${text}]")
							meta:set_string("infotext", "")
							meta:set_string("destination", ""..remote_pos.x..","..remote_pos.y..","..remote_pos.z)
							remotemeta:set_string("formspec", "field[destination;;${destination}]field[text;;${text}]")
							remotemeta:set_string("infotext", "")
							remotemeta:set_string("destination", ""..pos.x..","..pos.y..","..pos.z)
							--connection message
							continue = false
							message = "connection etablished"
						end
					end
				end
			end
		end
	end
	return message, continue
end,
"connect X, Y, Z MODE [OPTIONS]:    connect to a node or computer")

computers.register_oscommand("write", function(cmdline, pos, player)
	local command
	local x = 0
	local y = 0
	local z = 0
	local file = nil
	local str = nil
	command, x, y, z, file, str = string.match(cmdline, "^([^ ]+) *(%d+)[, ] *(%d+)[, ] *(%d+) *(%a+) *(.+)")
	
	if x==nil or y==nil or z==nil or file==nil or str==nil then
		message = "bad command : memory-write X,Y,Z FILENAME STRING"
	else
		local node = minetest.env:get_node({x=x, y=y, z=z})
		if node.name == "air" then
			message = "no support, aborted"
		else
			local meta = minetest.env:get_meta({x=x, y=y, z=z})
			meta:set_string(file, str)
			message = "memory added to "..node.name.." "..file.."  "..str
		end
	end
	return message, true
end,
"write X, Y, Z FILENAME STR:    write a string in a node file")

computers.register_oscommand("read", function(cmdline, pos, player)
	local command
	local x = 0
	local y = 0
	local z = 0
	local file = nil
	command, x, y, z, file = string.match(cmdline, "^([^ ]+) *(%d+)[, ] *(%d+)[, ] *(%d+) *(%a+)")
	
	if x==nil or y==nil or z==nil or file==nil then
		message = "bad command : memory-read X,Y,Z FILENAME STRING"
	else
		--if node has not metadata
		--else read contain
		
		local node = minetest.env:get_node({x=x, y=y, z=z})
		if node.name == "air" then
			message = "inexistant destination, aborted"
		else
			local meta = minetest.env:get_meta({x=x, y=y, z=z})
			local contain = meta:get_string(file)
			if contain then
				message = "memory read from "..node.name.." : "..contain
			else
				message = "no data in this node"
			end
		end
	end
	return message, true
end,
"read X, Y, Z FILENAME STR      read a node file")

--[[ commande autentificate :
 autentificate user password
	autentifie la machine hote par le nom d'utilisateur si le mot de passe est correct
]]

COMPUTER_FILE = minetest.get_worldpath()..'/computer_accounts.txt'

local get_password = function(user)
	local file = io.open(COMPUTER_FILE, "r")
	local list = ""
	local u
	local p
	local i=1
	while file:lines(i)("*(.+) *(.+)") ~= nil do
		u,p = file:lines(i)("*(.+) *(.+)")
		print(u.."    "..p)
		--u,p = string.match(list, "*(.+) *(.+)")
		if u==user then
			return p
		end
		i = i+1
	end
	io.close(file)
end

local add_user = function(user, password)
	local file = io.open(COMPUTER_FILE, "r")
	local text = file:lines()
	io.close(file)
	file = io.open(COMPUTER_FILE, "w")
	text = user.." "..password.."\n"..text
	file:write(text)
	io.close(file)
end

local del_user = function(user)
	local file = io.open(COMPUTER_FILE, "r")
	local list = file:lines()
	local text = ""
	io.close(file)
	local u
	local p
	for i in 1,#list do
		u,p = string.match(list[1], "*(.+) *(.+)")
		if u~=user then
			text = text..list[1]
		end
	end
	file = io.open(COMPUTER_FILE, "w")
	file:write(text)
	io.close(file)
end

computers.register_oscommand("login", function(cmdline, pos, player)
	local command
	local user
	local password
	command, user, password = string.match(cmdline, "^([^ ]+) *(.+) *(.+)")
	
	if user==nil then
		message = "bad command : autentificate USER PASSWORD"
	else
		local pass = get_password(user)
		if pass then
			if pass==password then
				message = "correct password"
			else
				message = "incorrect password"
			end
		else
			add_user(user, password)
			message = "user created"
		end
	end
	return message, true
end,
"login USER PASSWORD:   use a username")

--[[ commande deautentificate :
 deautentificate
	desauthentifie l'utilisateur courrant
"logout:   don't use username"
]]

--[[ commande userdel :
 deluser
	supprime le compte utilisateur actuel
]]

--[[ commande password :
 password user password new
 	change useer's password to new password
"password USER PASSWORD NEW:   change user password by new"
]]

--[[ commande mail :
 mail receiver
	ajoute un mail de l'utilisateur courant au compte nomme
	la saisie du mail se fait apres cette commande
 mail
	affiche les mails recus
 mail 1
 	lis le premier mail
"mail [USER | NUM]:   send mail to user or display mail list or display mail for number"
]]

