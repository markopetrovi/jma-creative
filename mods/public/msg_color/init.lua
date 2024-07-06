minetest.log("Loading msg_color...")

local storage = minetest.get_mod_storage()

local roles = {"[Admin]", "[Moderator]", "[Guardian]"}
local colors = {"#E4FF00", "#17FF00", "#06E5CE", "#0617E5", "#005A28"}
local i = 0

for _, role in ipairs(roles) do
	if not storage:get_string(role.."_color") then
		storage:set_string(role.."_color", "#FFFFFF")
	end
	if not storage:get_string(role.."_color") then
		storage:set_string(role.."_namecolor", "#FFFFFF")
	end
end

local function has_value(tab, val)
    for _, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

player_colors = {}

minetest.register_chatcommand("msg_color", {
	description = "Manage chat tags and name colors",
	params = "<command> <command_args>",
	privs = { server=true },
	func = function(name, param)
		local iter = param:gmatch("%S+")
		local command = iter()

		if command == "help" then
			minetest.chat_send_player(name, "List of possible commands:")
			minetest.chat_send_player(name, "listtag: Lists the available tags")
			minetest.chat_send_player(name, "settag <name> <tag>: Sets the user's tag")
			minetest.chat_send_player(name, "tagcolor <tag> <color>: Sets the tag's color")
			minetest.chat_send_player(name, "namecolor <tag> <color>: Sets the name color for users with the tag")
			return true
		elseif command == "listtag" then
			minetest.chat_send_player(name, "List of available tags:")
			for _, role in ipairs(roles) do
				minetest.chat_send_player(name, role..": "..minetest.colorize(storage:get_string(role.."_color"), role).." "..minetest.colorize(storage:get_string(role.."_namecolor"), "<Username>"))
			end
			return true
		elseif command == "settag" then
			local pname = iter()
			if pname == "" then
				return false, "Please provide a player name"
			else
				local cmdname = iter()
				if has_value(roles, cmdname) then
					storage:set_string(pname.."_role", cmdname)
					return true, "Added tag "..cmdname.." to "..pname
				else
					return false, "Tag not found"
				end
			end
		elseif command == "tagcolor" then
			local tag = iter()
			if tag == "" then
				return false, "Please provide a tag"
			else
				if has_value(roles, tag) then
					local color = iter()
					if color == "" then
						return false, "Please provide a color"
					else
						storage:set_string(tag.."_color", color)
						return true, "Set tag "..tag.." color to "..minetest.colorize(color, color)
					end
				else
					return false, "Tag not found"
				end
			end
		elseif command == "namecolor" then
			local tag = iter()
			if tag == "" then
				return false, "Please provide a tag"
			else
				if has_value(roles, tag) then
					local color = iter()
					if color == "" then
						return false, "Please provide a color"
					else
						storage:set_string(tag.."_namecolor", color)
						return true, "Set tag "..tag.." name color to "..minetest.colorize(color, color)
					end
				else
					return false, "Tag not found"
				end
			end
		else
			return false, "Please provide an argument. View all arguments with /msg_color help"
		end
	end
})

local function get_color(name)
	local role = storage:get_string(name.."_role")
	if role then
		return storage:get_string(role.."_namecolor")
	else
		return player_colors[name]
	end
end

local function isStringInList(target, stringList)
	for _, str in ipairs(stringList) do
		if str == target then
			return true
		end
	end
	return false
end

minetest.register_on_joinplayer(
	function(player)
		local name = player:get_player_name()
		local role = storage:get_string(name.."_role")
		if storage:get_string(name.."_role") then
			player_colors[name] = storage:get_string(role.."_namecolor")
			return true
		end

		-- Continue for normal players
		i = i + 1
		if i > 5 then
			i = 1
		end
		
		player_colors[player:get_player_name()] = colors[i]
	end
)

minetest.register_on_chat_message(
	function(name, msg)		
		local color = get_color(name)
		local tag = ""
		local role = storage:get_string(name.."_role")
		if role then
			tag = minetest.colorize(storage:get_string(role.."_color"), role).." "
		end
				
		minetest.chat_send_all(tag .. minetest.colorize(color, '<' .. name .. '> ') .. msg)
		return true -- we return true to mark this chat message as handled
	end
)

for _, role in ipairs(roles) do
	minetest.log("Loaded role "..role)
end
minetest.log("Finished loading msg_color")