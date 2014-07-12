GM.IsInGarage = false;
GM.IsShowingRaceMenu = false;
GM.ShowSorryMessage = false;
GM.RaceStartTime = 0;
GM.CameraLocations = {};
GM.SmoothCheckpoint = 0

GM.WrongWayText = surface.GetTextureID("gmracer/wrongway");
GM.SpeedometerMat = surface.GetTextureID("gmracer/speedometer");
GM.ThermometerMat = surface.GetTextureID("gmracer/thermometer");
GM.NeedleMat = surface.GetTextureID("gmracer/needle");

GM.DrillSound = Sound("gmracer/drill.mp3");
GM.RegisterSound = Sound("gmracer/register.mp3");
GM.CountdownSound = Sound("hl1/fvox/bell.wav");
GM.GoSound = Sound("plats/elevbell1.wav");

GM.LastNOSTime = 0;

GM.Music = {};
GM.ServerNews = {};
GM.ThanksTo = {};

local function AddDisplay ( Table, Name )
	local NewTable = {};
	NewTable.Name = Name;
	NewTable.CurPos = 0;
	
	table.insert(Table, NewTable);
end

local function AddMusic ( Name, Time )
	local NewTable = {};
	NewTable.Name = Name;
	NewTable.Time = Time;
	
	table.insert(GM.Music, NewTable);
end

AddMusic("music1", 81);
AddMusic("music2", 56);
AddMusic("music3", 304);

AddDisplay(GM.ServerNews, "www.insertgaming.com");
AddDisplay(GM.ServerNews, "Our Website / Forums:");
AddDisplay(GM.ServerNews, "");



AddDisplay(GM.ThanksTo, "Ollie - Fixing the Gamemode");
AddDisplay(GM.ThanksTo, "Metrotyranno - Hosting the server");
AddDisplay(GM.ThanksTo, "Totoro - Server Developer");
AddDisplay(GM.ThanksTo, "");
AddDisplay(GM.ThanksTo, "Garry - Fucking up the mapchanges");
AddDisplay(GM.ThanksTo, "Tyler (gmodplaygound.com) - Claiming a stolen gamemode his (this)");