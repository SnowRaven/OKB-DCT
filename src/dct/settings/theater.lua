--[[
-- SPDX-License-Identifier: LGPL-3.0
--
-- Provides config facilities.
--]]

local utils      = require("libs.utils")
local enum       = require("dct.enum")
local dctutils   = require("dct.utils")

local function validate_weapon_restrictions(cfgdata, tbl)
	local path = cfgdata.file
	local keys = {
		[1] = {
			["name"] = "cost",
			["type"] = "number",
		},
		[2] = {
			["name"] = "category",
			["type"] = "string",
			["check"] = function (keydata, t)
		if enum.weaponCategory[string.upper(t[keydata.name])] ~= nil then
			t[keydata.name] =
				enum.weaponCategory[string.upper(t[keydata.name])]
			return true
		end
		return false
	end,
		},
	}
	for _, wpndata in pairs(tbl) do
		wpndata.path = path
		utils.checkkeys(keys, wpndata)
		wpndata.path = nil
	end
	return tbl
end

local function validate_payload_limits(cfgdata, tbl)
	local newlimits = {}
	for wpncat, val in pairs(tbl) do
		local w = enum.weaponCategory[string.upper(wpncat)]
		assert(w ~= nil,
			string.format("invalid weapon category '%s'; file: %s",
				wpncat, cfgdata.file))
		newlimits[w] = val
	end
	return newlimits
end

local function validate_codenamedb(cfgdata, tbl)
	local newtbl = {}
	for key, list in pairs(tbl) do
		local newkey
		assert(type(key) == "string",
			string.format("invalid codename category '%s'; file: %s",
			key, cfgdata.file))

		local k = enum.assetType[string.upper(key)]
		if k ~= nil then
			newkey = k
		elseif key == "default" then
			newkey = key
		else
			assert(nil,
				string.format("invalid codename category '%s'; file: %s",
				key, cfgdata.file))
		end
		assert(type(list) == "table",
			string.format("invalid codename value for category "..
				"'%s', must be a table; file: %s", key, cfgdata.file))
		newtbl[newkey] = list
	end
	return newtbl
end

local function ato_transform(tbl)
	local ntbl = {}
	for ac, mlist in pairs(tbl) do
		ntbl[ac] = {}
		for _, v in pairs(mlist) do
			local mtype = string.upper(v)
			local mval  = enum.missionType[mtype]
			assert(mval ~= nil,
				string.format("invalid mission type: %s for ac: '%s'",
					v, ac))
			ntbl[ac][mtype] = mval
		end
	end
	return ntbl
end

local function gridfmt_transform(tbl)
	local ntbl = {}
	for k, v in pairs(tbl) do
		if type(v) == "number" then
			ntbl[k] = v
		else
			ntbl[k] = dctutils.posfmt[string.upper(v)]
			assert(ntbl[k] ~= nil,
				"invalid grid format "..tostring(v).." for '"..k.."'")
		end
	end
	return ntbl
end

local player_transforms = {
	["ato"]     = ato_transform,
	["gridfmt"] = gridfmt_transform,
}

local function validate_players(cfgdata, tbl)
	local newtbl = {}
	utils.mergetables(newtbl, cfgdata.default)
	for k, v in pairs(tbl) do
		if newtbl[k] == nil then
			newtbl[k] = {}
		end
		utils.mergetables(newtbl[k], v)
		if player_transforms[k] then
			newtbl[k] = player_transforms[k](newtbl[k], cfgdata)
		end
	end
	return newtbl
end

local function validate_ui(cfgdata, tbl)
	-- env.warning("DCT|Theater: ui.cfg is deprecated; please use players.cfg")
	return validate_players(cfgdata, tbl)
end

local function validate_blast_effects(cfgdata, tbl)
	local newtbl = {}
	newtbl = utils.mergetables(newtbl, cfgdata.default)
	newtbl = utils.mergetables(newtbl, tbl)
	return newtbl
end

--[[
-- We have a few levels of configuration:
-- 	* server defined config file; <dcs-saved-games>/Config/dct.cfg
-- 	* theater defined configuration; <theater-path>/settings/<config-files>
-- 	* default config values
-- simple algorithm; assign the defaults, then apply the server and
-- theater configs
--]]
local function theatercfgs(config)
	local settings = config.server.theaterpath..utils.sep.."settings"..utils.sep

	local defaultpayload = {}
	for _,v in pairs(enum.weaponCategory) do
		defaultpayload[v] = enum.WPNINFCOST - 1
	end

	local cfgs = {
		{
			["name"] = "restrictedweapons",
			["file"] = settings.."restrictedweapons.cfg",
			["cfgtblname"] = "restrictedweapons",
			["validate"] = validate_weapon_restrictions,
			["default"] = {
				["RN-24"] = {
					["cost"]     = enum.WPNINFCOST,
					["category"] = enum.weaponCategory.AG,
					["nuclear"]  = true,
				},
				["RN-28"] = {
					["cost"]     = enum.WPNINFCOST,
					["category"] = enum.weaponCategory.AG,
					["nuclear"]  = true,
				},
			},
			["env"] = {
				["INFCOST"] = enum.WPNINFCOST,
			},
		}, {
			["name"] = "payloadlimits",
			["file"] = settings.."payloadlimits.cfg",
			["validate"] = validate_payload_limits,
			["default"] = defaultpayload,
		}, {
			["name"] = "codenamedb",
			["file"] = settings.."codenamedb.cfg",
			["validate"] = validate_codenamedb,
			["default"] = require("dct.data.codenamedb"),
		}, {
			["name"] = "ui",
			["file"] = settings.."ui.cfg",
			["validate"] = validate_ui,
			["default"] = {},
		}, {
			["name"] = "players",
			["file"] = settings.."players.cfg",
			["validate"] = validate_players,
			["default"] = require("dct.data.playerdefaults"),
		}, {
			["name"] = "blasteffects",
			["file"] = settings.."blasteffects.cfg",
			["validate"] = validate_blast_effects,
			["default"] = require("dct.data.blasteffects"),
		},
	}

	utils.readconfigs(cfgs, config)

	-- migrate ui.cfg to players.cfg
	for k, _ in pairs(config.players) do
		if config.ui[k] ~= nil then
			utils.mergetables(config.players[k], config.ui[k])
		end
	end

	return config
end

return theatercfgs
