if !file.IsDir("gmracer", "DATA" ) then file.CreateDir("gmracer"); end
if !file.IsDir("gmracer/map_records", "DATA" ) then file.CreateDir("gmracer/map_records"); end

if !file.IsDir("gmracer/map_records/" .. game.GetMap(), "DATA" ) then
	file.CreateDir("gmracer/map_records/" .. game.GetMap(), "DATA" );
end

if !file.IsDir("gmracer/times_played", "DATA" ) then
	file.CreateDir("gmracer/times_played", "DATA" );
end

if !file.Exists("gmracer/times_played/" .. game.GetMap() .. ".txt", "DATA" ) then
	file.Write("gmracer/times_played/" .. game.GetMap() .. ".txt", "1", "DATA" );
else
	file.Write("gmracer/times_played/" .. game.GetMap() .. ".txt", tonumber(file.Read("gmracer/times_played/" .. game.GetMap() .. ".txt")) + 1);
end


function GM.SetMapRecord ( Place, Name, Time )	
	local Place = tmysql.escape(Place);
	local Time = tmysql.escape(Time);
	local Name = tmysql.escape(Name);
	local Map = tmysql.escape(game.GetMap());

	SetGlobalString("MapRecords_" .. Place .. "_Name", Name);
	SetGlobalInt("MapRecords_" .. Place .. "_Time", Time);
end

function GM.LoadMapRecord ( Place )

end

function GM.RetrieveOffMapRecord ( Place, Map )
	--local Place = tmysql.escape(Place);
	local Map = tmysql.escape(Map);
	
	tmysql.query("SELECT `name`, `time` FROM `gmr_records` WHERE `map`='" .. Map .. "' ORDER BY `time` ASC LIMIT 1", 
		function ( Return )
			if Return[1] then
				return Return[1][1], tonumber(Return[1][2]);
			else
				return "UNKNOWN", 1337;
			end
		end
	);
end
