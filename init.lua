-- This code is distributed under GN GPL v2 license. Copyright© Jimy-Byerley

local welcome_message = "/* welcome to cybertronic OS v2.0 */"
local default_laptop = "computers:laptop_open"

computers = {}

local computer_action = function(pos, formname, fields, sender)
	local node = minetest.env:get_node(pos)
	--use shell
	computers.execute_oscommand(fields.text, pos, sender)
end

computers.registered_oscommands = {}
computers.computer_help = {}

computers.register_oscommand = function(name, exe, help)
	computers.registered_oscommands[name] = exe
	computers.computer_help[name] = help
end

computers.execute_oscommand = function(cmdline, pos, player)
	if cmdline == nil then return end
	local command = string.match(cmdline, "([^ ]+) *")
	if command == nil then return end
	local message = "["..command.." : command not found]"
	local continue = false
	
	print("pass command to computer : "..command)
	local func = computers.registered_oscommands[command]
	if func then
		continue = true
		message, continue = func(cmdline, pos, player)
	end
	
	--minetest.chat_send_player(player:get_player_name(), message)
	--display message
	local meta = minetest.env:get_meta(pos)
	meta:set_string("infotext", message)
	
	return continue
end

dofile(minetest.get_modpath("computers").."/os.lua")

-- crafting


minetest.register_craft({
	output = 'computers:keyboard',
	recipe = {
		{'technology:button', 'technology:button', 'technology:button'},
		{'technology:button', 'technology:button', 'technology:button'},
		{'technology:button', 'technology:button', 'technology:button'},
	}
})

minetest.register_craft({
	output = 'computers:laptop_close',
	recipe = {
		{'technology:flat_screen_off', "technology:wire"},
		{'technology:electronic_card', "technology:wire"},
		{'technology:keyboard', "technology:wire"},
	}
})

-- node defs

minetest.register_node("computers:keyboard", {
    description = "keyboard",
    stack_max = 1,
    node_placement_prediction = "",
    paramtype = "light",
	light_source = 3,
    paramtype2 = "facedir",
    drawtype = "nodebox",
    node_box = {type = "fixed", fixed = {-0.44, -0.5, -0.44,   0.44, -0.45, -0.02}},
    selection_box = {type = "fixed", fixed = {-0.44, -0.5, -0.44,   0.44, -0.45, -0.02}},
    tiles = {"keyboard_top.png", "keyboard_bottom.png", "keyboard_side.png", "keyboard_side.png", "keyboard_side.png", "keyboard_side.png"},
    walkable = true,
    groups = {choppy=2, dig_immediate=2},
})

minetest.register_node("computers:laptop_open", {
    description = "Laptop from computers mod",
    stack_max = 1,
    node_placement_prediction = "",
    paramtype = "light",
	light_source = 4,
    paramtype2 = "facedir",
    drawtype = "nodebox",
    node_box = {type = "fixed", fixed = {
    	--{-0.45, -0.40, 0.30,   0.45, 0.30, 0.25},
    	--{-0.45, -0.5,  -0.45, 0.45, -0.425, 0.25},
    	
    	-- top part
    	{-0.3, -0.45, 0.05,   0.3, 0.05, 0.1},
    	-- bottom part
    	{-0.3, -0.5, -0.45,     0.3, -0.45, 0.075},
    }},
    selection_box = {type = "fixed", fixed = {
    	-- top part
    	{-0.3, -0.45, 0.05,   0.3, 0.05, 0.1},
    	-- bottom part
    	{-0.3, -0.5, -0.45,     0.3, -0.45, 0.075},
    }},
    tiles = {"laptop_top.png", "laptop_bottom.png", "laptop_left.png", "laptop_right.png", "laptop_back.png", {
			image="laptop_front_general.png",
			backface_culling=false,
			animation={type="vertical_frames", aspect_w=128, aspect_h=128, length=4.5}
		}
	},
    walkable = true,
    groups = {choppy=2, dig_immediate=2},
	drop = default_laptop,
    on_punch = function(pos, node, puncher)
    	node.name = "computers:laptop_close"
    	minetest.env:set_node(pos, node)
    end,
    on_construct = function(pos)
    	--set metadata
		local meta = minetest.env:get_meta(pos)
		meta:set_string("formspec", "field[text;;${text}]")
		meta:set_string("infotext", welcome_message)
	end,
    on_receive_fields = computer_action,
})

laptop_open_action = function(pos, node, puncher)
    	--set opened computer
    	node.name = "computers:laptop_open"
    	minetest.env:set_node(pos, node)
    	--set metadata
		local meta = minetest.env:get_meta(pos)
		meta:set_string("formspec", "field[text;;${text}]")
		meta:set_string("infotext", welcome_message)
    end

minetest.register_node("computers:laptop_close", {
    description = "Laptop from computers mod",
    stack_max = 1,
    node_placement_prediction = "",
    paramtype = "light",
    paramtype2 = "facedir",
    drawtype = "nodebox",
    node_box = {type = "fixed", fixed = {
    	-- bottom part
    	{-0.3, -0.5, -0.45,     0.3, -0.4, 0.075},
    }},
    selection_box = {type = "fixed", fixed = {-0.3, -0.5, -0.45,     0.3, -0.4, 0.075},},
    tiles = {"laptop_cover.png", "laptop_bottom.png", "laptop_left.png", "laptop_right.png", "laptop_back.png", {
			image="laptop_front_general.png",
			backface_culling=false,
			animation={type="vertical_frames", aspect_w=128, aspect_h=128, length=4.5}
		}
	},
    walkable = true,
    groups = {choppy=2, dig_immediate=2, not_in_creative_inventory=1},
	drop = default_laptop,
    
    on_punch = laptop_open_action,
    on_rightclick = laptop_open_action,
})

minetest.register_node("computers:laptop_connect", {
    inventory_image = "laptop_wielded.png",
    wield_image = "laptop_wielded.png",
    stack_max = 1,
    node_placement_prediction = "",
    paramtype = "light",
	light_source = 6,
    paramtype2 = "facedir",
    drawtype = "nodebox",
    node_box = {type = "fixed", fixed = {
    	{-0.45, -0.40, 0.30,   0.45, 0.30, 0.25},
    	{-0.45, -0.5,  -0.45, 0.45, -0.425, 0.25},
    }},
    selection_box = {type = "fixed", fixed = {-0.45, -0.40, 0.30,   0.45, 0.30, 0.25}},
    tiles = {"laptop_top.png", "laptop_bottom.png", "laptop_left.png", "laptop_right.png", "laptop_back.png", "laptop_front_connect.png"},
    walkable = true,
    groups = {choppy=2, dig_immediate=2, not_in_creative_inventory=1},
	drop = default_laptop,
    
    on_punch = function(pos, node, puncher)
    	node.name = "computers:laptop_close"
    	minetest.env:set_node(pos, node)
    end,
    on_receive_fields = function(pos, formname, fields, sender)
		--get remote coordinates
		local meta = minetest.env:get_meta(pos)
		local remote_pos = {}
		remote_pos.x, remote_pos.y, remote_pos.z = string.match(meta:get_string("destination"), "^([%d.-]+)[, ] *([%d.-]+)[, ] *([%d.-]+)$")
		
		local self = minetest.env:get_node(pos)
		local node = minetest.env:get_node(remote_pos)
		
    	if fields.text == "disconnect" then
			--change local
			if math.random(1,2) == 1 then
				self.name = "computers:laptop_smalltext"
			else
				self.name = "computers:laptop_bigtext"
			end
			minetest.env:set_node(pos, self)
			--set local metadata
			meta:set_string("formspec", "field[text;;${text}]")
			meta:set_string("infotext", "")
			
			--change remote text
			if math.random(1,2) == 1 then
				node.name = "computers:laptop_smalltext"
			else
				node.name = "computers:laptop_bigtext"
			end
			minetest.env:set_node(remote_pos, node)
			--set remote metadata
			local meta = minetest.env:get_meta(remote_pos)
			meta:set_string("formspec", "field[text;;${text}]")
			meta:set_string("infotext", "")
		else
			
			--verify host activity
			if node.name ~= "computers:laptop_connect" then
				minetest.chat_send_player(sender:get_player_name(), "[connection failed]")
				--change text
				if math.random(1,2) == 1 then
					self.name = "computers:laptop_smalltext"
				else
					self.name = "computers:laptop_bigtext"
				end
				minetest.env:set_node(pos, self)
				--set metadata
				meta:set_string("formspec", "field[text;;${text}]")
				meta:set_string("infotext", "")
			end
			
			if remote_pos.x and remote_pos.y and remote_pos.z then
				print(sender:get_player_name().." send packet to "..remote_pos.x..","..remote_pos.y..","..remote_pos.z)
				--transfer message
				local recievers = minetest.env:get_objects_inside_radius(remote_pos, 3)
				local i=1
				while recievers[i] ~= nil do
					local name = recievers[i]:get_player_name()
					minetest.chat_send_player(name, "["..fields.text.."]")
					i = i+1
				end
			else
				minetest.chat_send_player(sender:get_player_name(), "[bad address]")
			end
		end
   	end,
})

minetest.register_alias("computers:laptop", "computers:laptop_close")
