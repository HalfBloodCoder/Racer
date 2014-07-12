_R = debug.getregistry()

function _R.Player:GetScriptedVehicle()
	return Entity(0)
end

function _R.Vector:Normalized()
	self:Normalize()
	return self
end

AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
AddCSLuaFile("player_methods.lua");
AddCSLuaFile("cl_draw.lua");
AddCSLuaFile("cl_networking.lua");
AddCSLuaFile("default_stats.lua");
AddCSLuaFile("garage.lua");
AddCSLuaFile("cl_setup.lua");
AddCSLuaFile("help_menu.lua");
AddCSLuaFile("maps_setup.lua");
AddCSLuaFile("cl_misc.lua");
AddCSLuaFile("cl_draw_scoreboard.lua");
AddCSLuaFile("cl_leaderscreen.lua");
AddCSLuaFile("draw_demo.lua");
AddCSLuaFile("draw_race.lua");
AddCSLuaFile("chatcmd.lua");

require("tmysql")
--require("hio")
tmysql.initialize("DB_HOST", "DB_USER", "DB_PASS", "DB_NAME", 3306)

function GM:PlayerInitialSpawn(ply)

	ply:SetPData("gmr_cash", ply:GetCash(false))

	if ply:SteamID() == "STEAM_0:1:22583134" then
		ply:Kick("We do not want you here, go back to your community!")
		return true
	end
end

function GM.Top10Del ( )
	tmysql.query("SELECT `time`, `Name` FROM `gmr_records` WHERE `map`='" .. game.GetMap() .. "' ORDER BY `time` ASC LIMIT 10",
		function ( Return )
			GAMEMODE.CompareTop10 = '';
			
			for k, v in pairs(Return) do
				GAMEMODE.CompareTop10 = GAMEMODE.CompareTop10 .. v[1];
				SetGlobalString("MapRecords_" .. k .. "_Name", v[2]);
				SetGlobalInt("MapRecords_" .. k .. "_Time", tonumber(v[1]));
			end
		end
	);
	
	local found = false
	for k,v in pairs(GAMEMODE.DerbyMaps) do
		if string.lower(v) == string.lower(game.GetMap()) then
			found = true
		end
	end
	
	if found == true then
		GAMEMODE.GamemodeType = 1
		SetGlobalInt("GamemodeType",1)
		print(game.GetMap())
		print("Forced gamemode to"..GAMEMODE.GamemodeType)
	end
	
end
hook.Add('Initialize', 'Top10Del', GM.Top10Del);

RunConsoleCommand('net_maxfilesize', '64');
RunConsoleCommand('sv_alltalk', '1');
	
resource.AddFile("resource/fonts/lcd.ttf");

for k, v in pairs(file.Find("gamemodes/racer/content/sound/gmracer/*.*", "GAME")) do
	resource.AddFile("sound/gmracer/" .. v);
end

for k, v in pairs(file.Find("gamemodes/racer/content/sound/vehicles/junker/*.wav", "GAME")) do
	resource.AddFile("sound/vehicles/junker/" .. v);
end

for k, v in pairs(file.Find("gamemodes/racer/content/materials/gmracer/*.*", "GAME")) do
	resource.AddFile("materials/gmracer/" .. v);
end

for k, v in pairs(file.Find("gamemodes/racer/content/materials/maps/*.*", "GAME")) do
	resource.AddFile("materials/maps/" .. v);
end

for k, v in pairs(file.Find("gamemodes/racer/content/materials/buggy_reskins/*.*", "GAME")) do
	resource.AddFile("materials/buggy_reskins/" .. v);
end

for k, v in pairs(file.Find("gamemodes/racer/content/models/carparts/*.*", "GAME")) do
	resource.AddFile("models/carparts/" .. v);
end

for k, v in pairs(file.Find("gamemodes/racer/content/materials/spoilers/*.*", "GAME")) do
	resource.AddFile("materials/spoilers/" .. v);
end

for k, v in pairs(file.Find("gamemodes/racer/content/materials/models/spoilers/*.*", "GAME")) do
	resource.AddFile("materials/models/spoilers/" .. v);
end

include("sv_setup.lua");
include("shared.lua");
include("sv_binds.lua");
include("sv_networking.lua");
include("jeep_template.lua");
include("think.lua");
include("sv_helpers.lua");
include("melbourne.lua");

GM.SpawnCarParts = true;
GM.AllowTestVehicle = true;
GM.AllowVehicleDebris = false;
