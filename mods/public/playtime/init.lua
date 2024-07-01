playtime = {}

local current = {}
local total = {}

local storage = minetest.get_mod_storage()

function playtime.get_current_playtime(name)
	return os.time() - current[name]
end

-- Function to get playtime
function playtime.get_total_playtime(name)
	return total[name] + playtime.get_current_playtime(name)
end

function playtime.remove_playtime(name)
	storage:set_string(name, "")
end

local function save_playtime(player)
	local name = player:get_player_name()
	storage:set_int("playtime:" .. name, total[name] + playtime.get_current_playtime(name))
	current[name] = nil
	total[name] = nil
end

minetest.register_on_leaveplayer(function(player)
	save_playtime(player)
end)

minetest.register_on_shutdown(function(player)
	for _, p in ipairs(minetest.get_connected_players()) do
		save_playtime(p)
	end
end)

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	current[name] = os.time()
	total[name] = storage:get_int("playtime:" .. name)
end)

function playtime.seconds_to_clock(seconds)
	local seconds = tonumber(seconds)

	if seconds <= 0 then
		return "00:00:00";
	else
		local hours = string.format("%02.f", math.floor(seconds/3600));
		local mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
		local secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
		return hours..":"..mins..":"..secs
	end
end

-- Registration time functions
minetest.register_on_newplayer(function(ObjectRef)
    local name = ObjectRef:get_player_name()
    storage:set_int("regtime:" .. name, os.time())
end)

function playtime.get_registration_time(name)
	local key = "regtime:" .. name
    if storage:contains(key) then
        return storage:get_int(key)
    end
end

minetest.register_chatcommand("regtime", {
	description = "Get registration time",
	params = "<name>",
    privs = {server = true},
	func = function(name, param)
        if param ~= "" then
            local rtime = playtime.get_registration_time(param)
            if rtime then
                return true, os.date("%Y-%m-%d %H:%M:%S", rtime)
            else
                return true, "No entry"
            end
        else
            return false, "No player name provided"
        end
    end
})

minetest.register_chatcommand("playtime", {
	params = "",
	description = "Use it to get your own playtime!",
	func = function(name)
		minetest.chat_send_player(name, "Total: " .. playtime.seconds_to_clock(playtime.get_total_playtime(name))
			.. " Current: " .. playtime.seconds_to_clock(playtime.get_current_playtime(name)))
	end,
})
