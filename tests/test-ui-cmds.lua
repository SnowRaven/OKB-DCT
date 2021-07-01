#!/usr/bin/lua

require("math")
math.randomseed(50)
require("dcttestlibs")
require("dct")
local enum   = require("dct.enum")
local uicmds = require("dct.ui.cmds")

-- create a player group
local grp = Group(4, {
	["id"] = 9,
	["name"] = "VMFA251 - Enfield 1-1",
	["coalition"] = coalition.side.BLUE,
	["exists"] = true,
})

local unit1 = Unit({
	["name"] = "pilot1",
	["exists"] = true,
	["desc"] = {
		["typeName"] = "FA-18C_hornet",
		["displayName"] = "F/A-18C Hornet",
		["attributes"] = {},
	},
}, grp, "bobplayer")

local briefingtxt = "Package: #5720\n"..
			"IFF Codes: M1(05), M3(5720)\n"..
			"Target AO: 88°07.38'N 063°27.36'W (CAIRO)\n"..
			"Briefing:\n"..
			"A recon flight earlier today discovered"..
			" a fuel storage facility at 88°07.38'N 063°27.36'W,"..
			" East of Krasnodar-Center.\n\n"..
			"Primary Objectives: Destroy the fuel tanks embedded in "..
			"the ground at the facility.\n\n"..
			"Secondary Objectives: Destroy the white storage hangars.\n\n"..
			"Recommended Pilots: 2\n\n"..
			"Recommended Ordnance: Pilot discretion."

local assignedPilots = "Assigned Pilots:\nbobplayer (F/A-18C Hornet)"

local testcmds = {
	{
		["data"] = {
			["name"]   = grp:getName(),
			["type"]   = enum.uiRequestType.THEATERSTATUS,
		},
		["assert"]     = true,
		["expected"]   = "== Theater Threat Status ==\n"..
			"  Force Str: Nominal\n  Sea:    medium\n"..
			"  Air:    parity\n  ELINT:  medium\n  SAM:    medium\n\n"..
			"== Friendly Force Info ==\n  Force Str: Nominal\n\n"..
			"== Current Active Air Missions ==\n  No Active Missions\n\n"..
			"Recommended Mission Type: SEAD\n",
	}, {
		["data"] = {
			["name"]   = grp:getName(),
			["type"]   = enum.uiRequestType.MISSIONREQUEST,
			["value"]  = enum.missionType.STRIKE,
		},
		["assert"]     = true,
		["expected"]   = "Mission 5720 assigned, use F10 menu to "..
			"see this briefing again\n"..
			briefingtxt.."\n\n"..
			assignedPilots
	}, {
		["data"] = {
			["name"]   = grp:getName(),
			["type"]   = enum.uiRequestType.THEATERSTATUS,
		},
		["assert"]     = true,
		["expected"]   = "== Theater Threat Status ==\n"..
			"  Force Str: Nominal\n  Sea:    medium\n"..
			"  Air:    parity\n  ELINT:  medium\n  SAM:    medium\n\n"..
			"== Friendly Force Info ==\n  Force Str: Nominal\n\n"..
			"== Current Active Air Missions ==\n  STRIKE:  1\n\n"..
			"Recommended Mission Type: SEAD\n",
	}, {
		["data"] = {
			["name"]   = grp:getName(),
			["type"]   = enum.uiRequestType.MISSIONBRIEF,
		},
		["assert"]     = true,
		["expected"]   = briefingtxt,
	}, {
		["data"] = {
			["name"]   = grp:getName(),
			["type"]   = enum.uiRequestType.MISSIONSTATUS,
		},
		["assert"]     = true,
		["expected"]   = "Mission State: Active\n"..
			"Package: 5720\n"..
			"Timeout: 2016-06-21 14:00z (in 180 mins)\n"..
			"BDA: 0% complete\n\n"..
			assignedPilots
	}, {
		["data"] = {
			["name"]   = grp:getName(),
			["type"]   = enum.uiRequestType.MISSIONROLEX,
			["value"]  = 120,
		},
		["assert"]     = true,
		["expected"]   = "+2 mins added to mission timeout",
		--[[
	}, {
		["data"] = {
			["name"]   = grp:getName(),
			["type"]   = enum.uiRequestType.MISSIONCHECKIN,
		},
		["assert"]     = true,
		["expected"]   = "on-station received",
	}, {
		["data"] = {
			["name"]   = grp:getName(),
			["type"]   = enum.uiRequestType.MISSIONCHECKOUT,
		},
		["assert"]     = true,
		["expected"]   = "off-station received, vul time: 0",
		--]]
	}, {
		-- Test 2 min rolex and 5 min delay
		["data"] = {
			["name"]   = grp:getName(),
			["type"]   = enum.uiRequestType.MISSIONSTATUS,
		},
		["modelTime"]  = 300,
		["assert"]     = true,
		["expected"]   = "Mission State: Active\n"..
			"Package: 5720\n"..
			"Timeout: 2016-06-21 14:02z (in 177 mins)\n"..
			"BDA: 0% complete\n\n"..
			assignedPilots
	}, {
		["data"] = {
			["name"]   = grp:getName(),
			["type"]   = enum.uiRequestType.MISSIONABORT,
			["value"]  = enum.missionAbortType.ABORT,
		},
		["assert"]     = true,
		["expected"]   = "Mission 5720 aborted",
	}, {
		-- Allowed payload
		["data"] = {
			["name"]   = grp:getName(),
			["type"]   = enum.uiRequestType.CHECKPAYLOAD,
		},
		["ammo"] = {
			{
				["desc"] = {
					["displayName"] = "Cannon Shells",
					["category"] = 0,
				},
				["count"] = 600,
			}, {
				["desc"] = {
					["displayName"] = "AIM-120B",
					["typeName"] = "AIM_120",
					["category"] = 1,
				},
				["count"] = 4,
			}, {
				["desc"] = {
					["displayName"] = "AIM-9M",
					["typeName"] = "AIM_9",
					["category"] = 1,
				},
				["count"] = 2,
			}
		},
		["assert"]     = true,
		["expected"]   = "Valid loadout, you may depart. Good luck!\n\n"..
			"== Loadout Summary:\n"..
			"  AA cost: 20 / 20\n"..
			"  AG cost: 0 / 60\n"..
			"\n"..
			"== UNRESTRICTED Weapons:\n"..
			"  AIM-9M        2 * 0 pts = 0 pts\n"..
			"\n"..
			"== AA Weapons:\n"..
			"  AIM-120B        4 * 5 pts = 20 pts",
	}, {
		-- Over limit with forbidden weapon
		["data"] = {
			["name"]   = grp:getName(),
			["type"]   = enum.uiRequestType.CHECKPAYLOAD,
		},
		["ammo"] = {
			{
				["desc"] = {
					["displayName"] = "RN-28",
					["typeName"] = "RN-28",
					["category"] = 3,
				},
				["count"] = 1,
			}
		},
		["assert"]     = true,
		["expected"]   = "You are over budget! Re-arm before departing, or "..
			"you will be punished!\n\n"..
			"== Loadout Summary:\n"..
			"  AA cost: 0 / 20\n"..
			"  AG cost: ∞ / 60\n"..
			"\n"..
			"== AG Weapons:\n"..
			"  RN-28        1 * ∞ pts = ∞ pts (FORBIDDEN)",
	},
}

local function main()
	local theater = dct.Theater()
	_G.dct.theater = theater
	theater:exec(50)
	theater:onEvent({
		["id"]        = world.event.S_EVENT_BIRTH,
		["initiator"] = unit1,
	})

	for _, v in ipairs(testcmds) do
		if v.modelTime ~= nil then
			timer.stub_setTime(v.modelTime)
		end
		if v.ammo ~= nil then
			unit1.ammo = v.ammo
		end
		trigger.action.setassert(v.assert)
		trigger.action.setmsgbuffer(v.expected)
		local cmd = uicmds[v.data.type](theater, v.data)
		cmd:execute(400)
	end
	trigger.action.setassert(false)

	local data = {
		["name"]   = grp:getName(),
		["type"]   = enum.uiRequestType.MISSIONREQUEST,
		["value"]  = enum.missionType.STRIKE,
	}

	for _, v in pairs(enum.missionType) do
		data.value = v
		for _, s in pairs(coalition.side) do
			data.side = s
			local cmd = uicmds[data.type](theater, data)
			cmd:execute(500)
		end
	end
	return 0
end

os.exit(main())
