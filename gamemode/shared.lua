GM.Name 	= "Garrysmod Racer"
GM.Author 	= "-[Insert Gaming Community]-"
GM.Email 	= ""
GM.Website 	= "Not Available"

GM.PartsTable = {};
PartsList = {"engine_v64c", "engine_v84c", "engine_v120c", "abs", "stack_tailpipe", "air_cooling", "air_filter", "air_intake", "battery_1", "battery_2", "battery_3", "body_1", "body_2", "body_3", "body_4", "body_5", "dry_nos", "dual_tailpipe", "ebs", "electric_steering", "energy_cannon", "energy_gravity", "engine_v86c", "engine_v44c", "engine_v106c", "forward_brake", "handbrake", "headlights", "horn", "horn_vip1", "horn_vip2", "horn_vip3", "horn_vip4", "horn_vip5", "hydro_steering", "wet_nos_2", "wet_nos_1", "water_cooling", "vip_skin1", "vip_skin2", "vip_skin3", "vip_skin4", "vip_skin5", "vip_skin6", "vip_skin7", "turbocharger", "tailpipe", "spoiler", "spikes_2", "spikes_1", "seq_turbocharger", "rspikes_2", "rspikes_1", "rear_brake", "radiator", "perf_cam", "para_turbocharger", "missile_2", "missile_1", "mines_1", "mines_2", "mines_3", "hydroelectric_steering"};
GM.RaceTimeLimit = 300;
GM.Maps = {}
GM.NewRecordTime = 23;
GM.PlayerStats = {};
GM.DerbyMaps = {
"gmr_oct_v2",
"gmr_pandafaggot",
"gmr_robotwars_v2",
"gmr_robotwars_xl_r3"
}

include("player_methods.lua");
include("default_stats.lua");
include("maps_setup.lua");

team.SetUp(1337, "Owners", Color(255, 255, 255, 255));
team.SetUp(5, "Developer", Color(255, 255, 0, 255));
team.SetUp(4, "Super Administrator", Color(0, 0, 255, 255));
team.SetUp(3, "Administrator", Color(0, 255, 0, 255));
team.SetUp(2, "Temp Administrator", Color(255, 0, 255, 255));
team.SetUp(1, "VIP", Color(255, 0, 0, 255));
team.SetUp(0, "Guest", Color(255, 255, 0, 255));

util.PrecacheModel("models/props_vehicles/tire001c_car.mdl");
util.PrecacheModel("models/buggy.mdl");
for i = 1, 5 do
	util.PrecacheModel("models/Gibs/metal_gib" .. i .. ".mdl");
end

function GM:Initialize() self.BaseClass.Initialize( self ); end

function GM:RegisterPart ( PartTable ) 
	print("Loaded " .. PartTable.Name .. " successfully.\n");

	if CLIENT then
		PartTable.Material = surface.GetTextureID("gmracer/" .. PartTable.Icon);
	end
	
	for k, v in pairs(PartTable.RequiredModels) do
		util.PrecacheModel(v);
	end
	
	if !PartTable.RequiresAccess then
		PartTable.RequiresAccess = 255;
	end
	
	self.PartsTable[PartTable.Class] = self.PartsTable[PartTable.Class] or {};
	self.PartsTable[PartTable.Class][PartTable.ClassLevel] = PartTable;
end

if SERVER then
	for k, v in pairs(file.Find("gamemodes/gmodracer/gamemode/parts/*.lua", "data")) do
		Part = {};
				
		if SERVER then
		AddCSLuaFile("parts/" .. v);
		end
		include("parts/" .. v);
		print("Value: ".. v);
		GM:RegisterPart(Part);
	end
elseif CLIENT then
	for k, v in pairs(file.Find("lua_temp/gmodracer/gamemode/parts/*.lua", "data")) do
		Part = {};
		
		include("parts/" .. v);
		print("Value: ".. v);
		GM:RegisterPart(Part);
	end
else	
	end


function GM:PartRegistering()
	if SERVER then
		for k, v in pairs(PartsList) do
			Part = {};
					
			if SERVER then
			AddCSLuaFile("parts/".. v ..".lua");
			end
			include("parts/".. v ..".lua");
			GM:RegisterPart(Part);
		end
	elseif CLIENT then
		for k, v in pairs(PartsList) do
			Part = {};
			
			include("parts/".. v ..".lua");
			GM:RegisterPart(Part);
		end
	end
end
GM:PartRegistering()

function string.ToMinutesSecondsMilliseconds(time)//string.ToMinutesSecondsMilliseconds(time)
	local time = tonumber(time)
	if time != nil then
		
		local tbl = string.FormattedTime(time)
		local minutes = tostring(math.floor(tbl.m))
		local seconds = tostring(math.floor(tbl.s))
		local milliseconds = tostring(math.floor(tbl.ms))
		
		if #minutes == 1 then
			minutes = "0"..minutes
		end
		if #seconds == 1 then
			seconds = "0"..seconds
		end
		if #milliseconds == 1 then
			milliseconds = "0"..milliseconds
		end
		
		return minutes..":"..seconds..":"..milliseconds

	end
end

-- Chat Tags (Made by Skye/Totoro)
function GM:OnPlayerChat( ply, msg, team, isliving )
	if ply:GetLevel() == 0 and ply:IsValid() then
		chat.AddText(Color(0, 0, 255, 255), ply, Color(255, 255, 255, 255),": ", msg)
		return true
	elseif ply:GetLevel() == 1 and ply:IsValid() then
		chat.AddText(Color(0, 0, 200, 255), "[VIP] ", ply, Color(255, 255, 255, 255),": ", msg)
		return true
	elseif ply:GetLevel() >= 2 and ply:GetLevel() <= 4 and ply:IsValid() then
		chat.AddText(Color(0, 255, 0, 255), "[ADMIN] ", ply, Color(255, 255, 255, 255),": ", msg)
		return true
	elseif ply:GetLevel() == 5  and ply:IsValid() then
		chat.AddText(Color(255, 165, 0, 255), "[DEV] ", ply, Color(255, 255, 255, 255),": ", msg)
		return true
	elseif ply:GetLevel() == 1337  and ply:IsValid() then
		if ply:SteamID() == "STEAM_0:1:14299044" then
			chat.AddText(Color(255, 0, 0, 255), "[OWNER] ", ply, Color(255, 255, 255, 255),": ", msg)
			return true
		else
			chat.AddText(Color(255, 0, 0, 255), "[CO-OWNER] ", ply, Color(255, 255, 255, 255),": ", msg)
			return true
		end
	end
end