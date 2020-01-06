#!/usr/bin/lua

require("dcttestlibs")
require("dct")

-- create a player group
local grp = Group(4, {
	["id"] = 12,
	["name"] = "Uzi 11",
	["coalition"] = coalition.side.BLUE,
	["exists"] = true,
})

local unit1 = Unit({
	["name"] = "pilot1",
	["exists"] = true,
	["desc"] = {
		["typeName"] = "FA-18C_hornet",
	},
}, grp, "bobplayer")

-- Since groupmenu is added by the Theater, we just get a Theater
-- instance and then cook up an event to call the theater DCS
-- event handler with.

local testcmds = {
	[1] = {
		["event"] = {
			["id"]        = world.event.S_EVENT_BIRTH,
			["initiator"] = unit1,
		},
		["assert"] = true,
		["expect"] = "theater status and mission management available"
			.." in F10 menu",
	},
}

local function main()
	local theater = dct.Theater()
	for _, data in ipairs(testcmds) do
		trigger.action.setmsgbuffer(data.expect)
		trigger.action.setassert(data.assert)
		theater:onEvent(data.event)
	end
	return 0
end

os.exit(main())
