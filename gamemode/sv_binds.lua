function GM:PlayerLoadout ( Player ) end

function GM:KeyPress ( Player, Key ) 
	GAMEMODE.RaceStartTime = GAMEMODE.RaceStartTime or 0;
	
	local HornDelay = 5;
	
	if Player:GetUsedPart("Horn") == 5 then
		HornDelay = 20;
	end
	
	self.RaceStartTime = self.RaceStartTime or 0;
	
	if Key == IN_SPEED and Player:InVehicle() then
		local JeepData = Player:CompileJeepData();
		
		if self.PlayerTables[Player].LastNOSTime + JeepData.BoostDelay + JeepData.BoostDuration <= CurTime() then
			self.PlayerTables[Player].LastNOSTime = CurTime();
			Player:SetNetworkedBool("IsTurboing", true);
			timer.Simple(JeepData.BoostDuration, function() GAMEMODE.SetFalse(Player) end)
		end
	elseif Key == IN_WALK and Player:InVehicle() and Player:GetUsedPart("Horn") != 0 and self.PlayerTables[Player].LastHornBlast + HornDelay <= CurTime() then
		self.PlayerTables[Player].LastHornBlast = CurTime();
		
		if Player:GetUsedPart("Horn") == 1 then
			Player:GetVehicle():EmitSound(Sound("gmracer/short_horn_v2.mp3"));
		elseif Player:GetUsedPart("Horn") == 2 then
			Player:GetVehicle():EmitSound(Sound("gmracer/dixiehorn_v3.mp3"));
		elseif Player:GetUsedPart("Horn") == 3 then
			Player:GetVehicle():EmitSound(Sound("gmracer/siren_v3.mp3"));
		elseif Player:GetUsedPart("Horn") == 4 then
			Player:GetVehicle():EmitSound(Sound("gmracer/getoutmyface.mp3"));
		elseif Player:GetUsedPart("Horn") == 5 then
			Player:GetVehicle():EmitSound(Sound("gmracer/rick_v2.mp3"));
		elseif Player:GetUsedPart("Horn") == 6 then
			Player:GetVehicle():EmitSound(Sound("gmracer/awesome_songv2.mp3"));
		end
	elseif CurTime() >= self.RaceStartTime + 5 and Key == IN_RELOAD and Player:InVehicle() and Player:GetVehicle().RocketsRemaining != nil and Player:IsRacing() and Player:GetLevel() >= 1  then
		if Player:GetVehicle().RocketsRemaining > 0 then
			if Player:GetVehicle().Rockets[Player:GetVehicle().RocketsRemaining] then
				local OldMissile = Player:GetVehicle().Rockets[Player:GetVehicle().RocketsRemaining];
			
				local Jeep = Player:GetVehicle();
				local Missile = ents.Create("vip_missile");
				
				if Missile and Missile:IsValid() then
					Missile:SetPos(OldMissile:GetPos());
					Missile:SetAngles(OldMissile:GetAngles());
					Missile:SetLauncher(Jeep);
					Missile:Spawn()
					
					if Player:IsRacing() then
						Player:GetVehicle().RocketsRemaining = Player:GetVehicle().RocketsRemaining - 1;
						OldMissile:Remove();
					end
				end
			end
		else
			Player:SendLua("surface.PlaySound(Sound('weapons/ar2/ar2_empty.wav'))");
		end
	elseif CurTime() >= self.RaceStartTime + 5 and Key == IN_SCORE and Player:InVehicle() and Player:GetVehicle().MinesRemaining != nil and Player:IsRacing()then
		if Player:GetVehicle().MinesRemaining > 0 then
			if Player:GetVehicle().Mines[Player:GetVehicle().MinesRemaining] then
				local OldMissile = Player:GetVehicle().Mines[Player:GetVehicle().MinesRemaining];
			
				local Jeep = Player:GetVehicle();
				local Missile = ents.Create("gay_people's_mines");
				
				if Missile and Missile:IsValid() then
					Missile:SetPos(OldMissile:GetPos());
					Missile:SetAngles(OldMissile:GetAngles());
					Missile:SetLauncher(Jeep);
					Missile:Spawn()
					
					if Player:IsRacing() then
						Player:GetVehicle().MinesRemaining = Player:GetVehicle().MinesRemaining - 1;
						OldMissile:Remove();
					end
				end
			end
		else
			Player:SendLua("surface.PlaySound(Sound('weapons/ar2/ar2_empty.wav'))");
		end
	elseif CurTime() >= self.RaceStartTime + 5 and Key == IN_ATTACK2 and Player:InVehicle() and (Player:GetVehicle().Cannon != nil or Player:GetVehicle().EMPCannon != nil) and Player:IsRacing() and Player:GetLevel() >= 1 then
		if Player:GetVehicle().LastCannonFire + 15 < CurTime() then
			local Mag = 1;
			local Ent;
			if Player:GetVehicle().Cannon != nil then
				Ent = Player:GetVehicle().Cannon;
				timer.Simple(2.3, function() self.FireLaser(Player:GetVehicle().Cannon, Player) end)
				Player:GetVehicle().Cannon:EmitSound(Sound('gmracer/laser_reload.wav'), 500);
			else
				Ent = Player:GetVehicle().EMPCannon;
				timer.Simple(2.3, function() self.FireEMP(Player:GetVehicle().EMPCannon, Player) end)
				Player:GetVehicle().EMPCannon:EmitSound(Sound('gmracer/laser_reload.wav'), 500);
				Mag = 2;
			end
			
			local effectdata = EffectData()
			effectdata:SetEntity(Ent)
			effectdata:SetMagnitude(Mag);
			util.Effect("cannon_charging", effectdata)
			
			Player:GetVehicle().LastCannonFire = CurTime();
		end
	end
end

function GM.LaserReadyBeam ( )
	if !GAMEMODE.RaceStartTime or CurTime() < GAMEMODE.RaceStartTime + 5 then return false; end
	
	for k, v in pairs(player.GetAll()) do
		if v:InVehicle() and (v:GetVehicle().Cannon != nil or v:GetVehicle().EMPCannon != nil) and v:GetVehicle().LastCannonFire + 15 < CurTime() and v:IsRacing() and v:GetLevel() >= 1 then
			local effectdata = EffectData()
						
			local LaunchPos
			local Magnitude = 1
			if v:GetVehicle().EMPCannon != nil then
				LaunchPos = v:GetVehicle().EMPCannon:GetPos() + Vector(0, 0, -5);
				effectdata:SetEntity(v:GetVehicle().EMPCannon)
				Magnitude = 2
			else
				LaunchPos = v:GetVehicle().Cannon:GetPos() + Vector(0, 0, -5);
				effectdata:SetEntity(v:GetVehicle().Cannon)
			end
			
			local effectdata = EffectData()
			effectdata:SetOrigin(LaunchPos)
			effectdata:SetMagnitude(Magnitude);
			util.Effect("cannon_ready", effectdata)
		end
	end
end
timer.Create('LaserReadyBeam',.5, 0, GM.LaserReadyBeam);

function GM.FireEMP ( Cannon, Player )
	if !Cannon then return false; end
	if !Player or !Player:IsValid() or !Player:IsPlayer() then return false; end
	local LaunchPos = Cannon:GetPos();
	Cannon:EmitSound(Sound('gmracer/laser' .. math.random(1, 3) .. '.wav'), 500);
	
	local trace = {}
	trace.start = LaunchPos
	trace.endpos = LaunchPos + (Cannon:GetUp() * 20048)
	trace.filter = Cannon
	local tr = util.TraceLine( trace ) 
	
	local HitPos = tr.HitPos;
	
	local gaussStart = ents.Create( "info_target" )
	gaussStart:SetPos(LaunchPos)
	gaussStart:SetKeyValue("targetname", "gaussStart")
	gaussStart:Spawn()
	gaussStart:Fire("kill", "", 0.11)
		  
	local gaussEnd = ents.Create( "info_target" )
	gaussEnd:SetPos(HitPos)
	gaussEnd:SetKeyValue("targetname", "gaussEnd")
	gaussEnd:Spawn()
	gaussEnd:Fire("kill", "", 0.11)
	
	for i = 1, 5 do
		local Size = math.random(4, 25);
		local Amp = math.random(1, 5);
		 
		local gaussBeam = ents.Create( "env_beam" )
		gaussBeam:SetKeyValue("targetname", "gaussBeam")
		gaussBeam:SetKeyValue("texture", "sprites/physcannon_bluelight1b.vtf" )
		gaussBeam:SetKeyValue("renderamt", 255 )
		gaussBeam:SetKeyValue("rendercolor", "0 0 255" )
		gaussBeam:SetKeyValue("life", 0.1 )
		gaussBeam:SetKeyValue("LightningStart", "gaussStart" )
		gaussBeam:SetKeyValue("LightningEnd", "gaussEnd" )
		gaussBeam:SetKeyValue("TouchType", 0 )
		gaussBeam:SetKeyValue("framestart", 0 )
		gaussBeam:SetKeyValue("framerate", 0 )
		gaussBeam:SetKeyValue("NoiseAmplitude", Amp)
		gaussBeam:SetKeyValue("TextureScroll", 35 )
		gaussBeam:SetKeyValue("BoltWidth", Size)
		gaussBeam:SetKeyValue("Radius", 256 )
		gaussBeam:SetKeyValue("StrikeTime", 1 )
		gaussBeam:SetPos(LaunchPos)
		gaussBeam:Spawn()
		gaussBeam:Fire("TurnOn", "", 0.01)
	end
	
	local effectdata = EffectData()
	effectdata:SetOrigin(HitPos)
	effectdata:SetEntity(tr.Entity)
	effectdata:SetMagnitude(1);
	util.Effect("emp_wave", effectdata)
	
	for k, v in pairs(ents.GetAll()) do
		if v:IsVehicle() then
			local Distance = HitPos:Distance(v:GetPos());
			
			if Distance < 750 then
				local PerPower = 30000000 / 750; 
				local Power = 20000000 + (PerPower * 750)
				
				v:GetPhysicsObject():ApplyForceCenter((v:GetPos() - HitPos):Normalized() * Power);
			end
		end
	end
	
	/*
	for i = 1, 30 do
		local gaussexp = ents.Create("env_physexplosion")
		gaussexp:SetKeyValue("magnitude", "100")
		gaussexp:SetKeyValue("radius", "1000")
		gaussexp:Spawn()
		gaussexp:Fire("Explode", "", .1)
		gaussexp:SetOwner(Player)
		gaussexp:SetPos(HitPos)
	end
	*/
	
	util.ScreenShake(HitPos, 2000, 80, 3, 1000)
end

function GM.FireLaser ( Cannon, Player )
	if !Cannon then return false; end
	if !Player or !Player:IsValid() or !Player:IsPlayer() then return false; end
	local LaunchPos = Cannon:GetPos();
	Cannon:EmitSound(Sound('gmracer/laser' .. math.random(1, 3) .. '.wav'), 500);

	local trace = {}
	trace.start = LaunchPos
	trace.endpos = LaunchPos + (Cannon:GetUp() * 20048)
	trace.filter = Cannon
	local tr = util.TraceLine( trace ) 
	
	local HitPos = tr.HitPos;
	
	local gaussStart = ents.Create( "info_target" )
	gaussStart:SetPos(LaunchPos)
	gaussStart:SetKeyValue("targetname", "gaussStart")
	gaussStart:Spawn()
	gaussStart:Fire("kill", "", 0.11)
		  
	local gaussEnd = ents.Create( "info_target" )
	gaussEnd:SetPos(HitPos)
	gaussEnd:SetKeyValue("targetname", "gaussEnd")
	gaussEnd:Spawn()
	gaussEnd:Fire("kill", "", 0.11)
	
	for i = 1, 5 do
		local Size = math.random(4, 25);
		local Amp = math.random(1, 5);
		 
		local gaussBeam = ents.Create( "env_beam" )
		gaussBeam:SetKeyValue("targetname", "gaussBeam")
		gaussBeam:SetKeyValue("texture", "sprites/physcannon_bluelight1b.vtf" )
		gaussBeam:SetKeyValue("renderamt", 255 )
		gaussBeam:SetKeyValue("rendercolor", "0 255 0" )
		gaussBeam:SetKeyValue("life", 0.1 )
		gaussBeam:SetKeyValue("LightningStart", "gaussStart" )
		gaussBeam:SetKeyValue("LightningEnd", "gaussEnd" )
		gaussBeam:SetKeyValue("TouchType", 0 )
		gaussBeam:SetKeyValue("framestart", 0 )
		gaussBeam:SetKeyValue("framerate", 0 )
		gaussBeam:SetKeyValue("NoiseAmplitude", Amp)
		gaussBeam:SetKeyValue("TextureScroll", 35 )
		gaussBeam:SetKeyValue("BoltWidth", Size)
		gaussBeam:SetKeyValue("Radius", 256 )
		gaussBeam:SetKeyValue("StrikeTime", 1 )
		gaussBeam:SetPos(LaunchPos)
		gaussBeam:Spawn()
		gaussBeam:Fire("TurnOn", "", 0.01)
	end
	
	local gaussexp = ents.Create("env_physexplosion")
	gaussexp:SetKeyValue("magnitude", "100")
	gaussexp:SetKeyValue("radius", "500")
	gaussexp:Spawn()
	gaussexp:Fire("Explode", "", 0)
	gaussexp:SetOwner(Player)
	gaussexp:SetPos(HitPos)
	
	for i = 1, 5 do
		local BlowPos = HitPos + Vector(math.random(-150, 150), math.random(-150, 150), 0);
		util.Decal("Scorch", BlowPos + tr.HitNormal, BlowPos - tr.HitNormal)  
		
		local react = ents.Create("env_explosion")
		react:SetKeyValue("iMagnitude", 250)
		react:SetPos(BlowPos)
		react:Spawn()
		react:SetOwner(Player);
		react:Fire("Explode", "", 0)
	end
	
	for i = 1, 10 do
		local zap = ents.Create("point_tesla")
		zap:SetKeyValue("targetname", "zap")
		zap:SetKeyValue("texture" ,"sprites/laserbeam.spr")
		zap:SetKeyValue("m_Color" ,"0 255 0")
		zap:SetKeyValue("m_flRadius" ,"150")
		zap:SetKeyValue("beamcount_min" ,"5")
		zap:SetKeyValue("beamcount_max", "10")
		zap:SetKeyValue("thick_min", "2")
		zap:SetKeyValue("thick_max", "10")
		zap:SetKeyValue("lifetime_min" ,"1")
		zap:SetKeyValue("lifetime_max", "1.5")
		zap:SetKeyValue("interval_min", "0.1")
		zap:SetKeyValue("interval_max" ,"0.5")
		zap:SetPos(HitPos + Vector(math.random(-50,50),math.random(-50,50),math.random(0,250)))
		zap:Spawn()
		
		zap:Fire("DoSpark","",0)
		zap:Fire("DoSpark","",.1)
		zap:Fire("kill","", .25)
	end
	
	local effectdata = EffectData()
	effectdata:SetOrigin(HitPos)
	effectdata:SetEntity(tr.Entity)
	util.Effect("cannon_explosion", effectdata)

	util.ScreenShake(HitPos, 4000, 80, 5, 500)
	
	for k, v in pairs(ents.FindInSphere(HitPos, 350)) do
		if v:IsPlayer() then
			local Damage = math.Clamp(((350 - HitPos:Distance(v:GetPos())) * .5) / math.Clamp(v:GetUsedPart('Chasis') * .5, 1, 2), 0, 100);
			v:GiveDamage(Damage, v);
		end
	end
end

function GM.SetFalse ( Player )
Player:SetNetworkedBool("IsTurboing", false);
end

function GM:ShowHelp ( Player )
	if GetGlobalBool("VotingForMap") then return false; end
	if Player:GetNetworkedBool("IsCurrentlyRacing") and Player:GetNetworkedInt("CurrentCheckpoint") != GetGlobalInt("TotalNumberCheckpoints") then return false; end
	if self.PlayerTables[Player].InGarage then return false; end
	
	if self.PlayerTables[Player].InMenu then
		Player:Freeze(false);
		self.PlayerTables[Player].InMenu = false;
	else
		Player:Freeze(true);
		self.PlayerTables[Player].InMenu = true;
	end

	umsg.Start("ShowTrackMenu", Player); umsg.End();
end

function GM:ShowTeam ( Player )
	if GetGlobalBool("VotingForMap") then return false; end
	if Player:GetNetworkedBool("IsCurrentlyRacing") and Player:GetNetworkedInt("CurrentCheckpoint") != GetGlobalInt("TotalNumberCheckpoints") then return false; end
	if self.PlayerTables[Player].InMenu then return false; end

	if self.PlayerTables[Player].InGarage then
		Player:Freeze(false);
		self.PlayerTables[Player].InGarage = false;
	else
		Player:Freeze(true);
		self.PlayerTables[Player].InGarage = true;
	end
	
	umsg.Start("ShowGarageMenu", Player);
		--umsg.Vector(self.GarageViewLocationEntity:GetPos());
		--umsg.Vector(self.GarageLocationEntity:GetPos());
	umsg.End();
end

function GM:ShowSpare1 ( Player )
	if GetGlobalBool("VotingForMap") then return false; end
	
	self.PlayerTables[Player].NextSpawn = self.PlayerTables[Player].NextSpawn or 0;
	
	if self.PlayerTables[Player].InPGarage and !Player:InVehicle() then
		if self.PlayerTables[Player].NextSpawn >= CurTime() then
			Player:PrintMessage(HUD_PRINTTALK, "Please wait another " .. math.abs(math.Round(CurTime() - self.PlayerTables[Player].NextSpawn)) .. " second(s) before spawning your car again.");
		elseif GAMEMODE.AllowTestVehicle then
			Player:SpawnJeep(Player:GetPos(), Player:GetAngles() + Angle(0, 90, 0));
			self.PlayerTables[Player].NextSpawn = CurTime() + 10;
		elseif Player and Player:IsValid() and Player:IsPlayer() then 
			Player:PrintMessage(HUD_PRINTTALK, "The admin has disabled test vehicles. This may be temporary to improve server performance.");
		end
	else
		if Player:GetNetworkedBool("IsCurrentlyRacing") and Player:GetNetworkedInt("CurrentCheckpoint") != GetGlobalInt("TotalNumberCheckpoints") then return false; end
		Player:SetNetworkedBool("IsQueued", !Player:GetNetworkedBool("IsQueued"));
		
		if Player:GetNetworkedBool("IsQueued") then
			if Player:GetLevel() >= 1 then
				local OldQueue = self.QueuedPlayers;
				
				self.QueuedPlayers = {};
				table.insert(self.QueuedPlayers, Player);
				
				for k, v in pairs(OldQueue) do
					table.insert(self.QueuedPlayers, v);
				end
			else
				table.insert(self.QueuedPlayers, Player);
			end
		else
			for k, v in pairs(self.QueuedPlayers) do
				if v == Player then self.QueuedPlayers[k] = nil; end
			end
		end
	end
end

function GM:ShowSpare2 ( Player ) Player:ConCommand("pe_achievements"); end

function GM.ExtraPlayerSpawn ( Player )
if Player and Player:IsValid() and Player:IsPlayer() then
Player:Freeze(false);
end
end
hook.Add("PlayerSpawn", "GM.ExtraPlayerSpawn", GM.ExtraPlayerSpawn);

function GM:PlayerInitialSpawn( Player )
	self.PlayerTables[Player] = self.PlayerTables[self] or {};
	self.PlayerTables[Player].InGarage = false;
	self.PlayerTables[Player].LastHornBlast = 0;
	
	local Name = tmysql.escape(Player:Name());
	
	--[[
	timer.Simple(5, function ( )
		if !Player or !Player:IsValid() then return false; end
		
		--local DonationResults, Success, Error = MySQLQuery(SiteDatabaseConnection, "SELECT `AMMOUNT` FROM `gmr_donations` WHERE `ID` = '" .. StripForHTTP(Player:SteamID()) .. "' AND `CLAIMED` = '0'", mysql.QUERY_FIELDS);
		--local DonationResults, Success, Error = MySQLQuery(SiteDatabaseConnection, "SELECT `AMMOUNT` FROM `gmr_donations` WHERE `ID` = '" .. Player:SteamID() .. "' AND `CLAIMED` = '0'", mysql.QUERY_FIELDS);
		--local DonationResults, Success, Error = MySQLQuery(SiteDatabaseConnection, "SELECT `AMMOUNT` FROM `gmr_donations` WHERE `ID` = '" .. Player:SteamID() .. "' AND `CLAIMED` = '0'");
		local DonationResults, Success, Error = tmysql.query("SELECT `AMMOUNT` FROM `gmr_donations` WHERE `ID` = '" .. Player:SteamID() .. "' AND `CLAIMED` = '0'", tmysql.QUERY_FIELDS);
		
		if Success and #DonationResults > 0 then
			local DonationAmmount = 0;
			
			for k, v in pairs(DonationResults) do
				if v['AMMOUNT'] then
					DonationAmmount = DonationAmmount + tonumber(v['AMMOUNT']);
				end
			end
			
			if Player and Player:IsValid() and Player:IsPlayer() and DonationAmmount > 0 then
				Player:AddCash(DonationAmmount);
				Player:PrintMessage(HUD_PRINTTALK, "You have received $" .. DonationAmmount .. " for your online donation. Thanks for donating!");
				--MySQLQuery(SiteDatabaseConnection, "UPDATE `gmr_donations` SET `CLAIMED`='1', `NAME`='" .. StripForHTTP(Player:Name()) .. "' WHERE `ID` = '" .. StripForHTTP(Player:SteamID()) .. "' AND `CLAIMED` = '0'");
				MySQLQuery(SiteDatabaseConnection, "UPDATE `gmr_donations` SET `CLAIMED`='1', `NAME`='" .. Player:Name() .. "' WHERE `ID` = '" .. Player:SteamID() .. "' AND `CLAIMED` = '0'");
			end
		end
	end);
	--]]
	
	function PassInfo ( Player, String, Short )
		if Player and Player:IsValid() and Player:IsPlayer() then
			umsg.Start("GMRPlayerStat", Player);
				umsg.String(String);
				umsg.Short(Short);
			umsg.End();
		end
	end
		
	function SendCash ( Player )
		if Player and Player:IsValid() and Player:IsPlayer() then
			Player:SendLua("LocalPlayer():SetNetworkedString('GMRacer_Money', " .. Player:GetNetworkedString("GMRacer_Money") .. ")")
		end
	end
	
	self.PlayerStats[Player] = {};
	local Num = 1;
	for k, v in pairs(self.PartsTable) do	
		Player:GetPData("GMRacer_PartUsing_" .. k, "0", 
			function ( Ret )
				self.PlayerStats[Player][k] = Ret;
				
				Num = Num + .05
				if self.PlayerStats[Player][k] != "0" then
					timer.Simple(Num, function() PassInfo(Player, k, self.PlayerStats[Player][k]) end);
				end
			end
		);
	end
	
	timer.Simple(1, function() SendCash(Player) end);
	
	Player:SetNetworkedInt("GMRacer_Level", 0);
	
	tmysql.query("SELECT `gmr_level` FROM `rp_users` WHERE `steamid`='" .. tmysql.escape(Player:SteamID()) .. "'",
		function ( Results )
			if #Results > 0 then
				Player:SetNetworkedInt("GMRacer_Level", Results[1][1]);
				Msg("Loaded player with Level: " .. Results[1][1] .. "\n");
			else
				Player:GetPData("GMRacer_Level", "0", 
					function ( Level )
						tmysql.query("INSERT INTO `rp_users` (`steamid`, `name`, `gmr_level`) VALUES ('" .. tmysql.escape(Player:SteamID()) .. "', '" ..  tmysql.escape(Player:Nick()) .. "', '0')");
					end
				);
				Msg("Created level table to player " .. Player:Nick() .. "\n");
			end
		end
	);
	
	tmysql.query("SELECT `gmr_cash` FROM `rp_users` WHERE `steamid`='" .. tmysql.escape(Player:SteamID()) .. "'",
		function ( Results )

			if #Results > 0 then
				Player:AddCash(Results[1][1])
				Msg("Loaded player with Cash: " .. Results[1][1] .. "\n");
			else
				Player:GetPData("GMRacer_Money", "0", 
					function ( Money )
						tmysql.query("INSERT INTO `rp_users` (`steamid`, `name`, `gmr_cash`) VALUES ('" .. tmysql.escape(Player:SteamID()) .. "', '" ..  tmysql.escape(Player:Nick()) .. "', '7500')");
					end
				);
				Msg("Created player " .. Player:Nick() .. "\n");
				Player:AddCash(7500)
				Msg("Gave player " .. Player:Nick() .. " His Cash.\n");
			end
		end
	);
			
	Player:SetNetworkedBool("IsQueued", false);
	Player:SetNetworkedBool("IsCurrentlyRacing", false);
	Player:SetNetworkedInt("CurrentCheckpoint", 0);
	//Player:SetNetworkedBool("LightsOn", false);
	
	tmysql.query("SELECT `time` FROM `gmr_records` WHERE `steamid`='" .. Player:SteamID() .. "' AND `map`='" .. game.GetMap() .. "'", 
		function ( Results )
			if Results[1] then
				Player:SetNetworkedInt("MapRecord", tonumber(Results[1][1]));
			else
				tmysql.query("INSERT INTO `gmr_records` (`steamid`, `time`, `name`, `map`) VALUES ('" .. Player:SteamID() .. "', 1337, '" .. Player:Name() .. "', '" .. game.GetMap() .. "')");
				Player:SetNetworkedInt("MapRecord", 1337);
			end
		end
	);
	
	timer.Simple(5, 
		function ( )
			if Player and Player:IsValid() and Player:IsPlayer() then
				umsg.Start("cameralocs", Player);
					umsg.Float(table.Count(self.CameraLocations));
					
					for k, v in pairs(self.CameraLocations) do
						umsg.Vector(v:GetPos());
					end
				umsg.End();
			end
		end
	);
end
for k, v in pairs(player.GetAll()) do GM:PlayerInitialSpawn(v); end

function GM:PlayerDisconnected ( Player )
	if !Player:IsRacing() and Player:GetTable().PlayerVehicleBak and Player:GetTable().PlayerVehicleBak:IsValid() then
		Player:GetTable().PlayerVehicleBak:Remove();
	end

	GAMEMODE:PlayerDeath(Player); 
end

function GM:PlayerDeath ( Player )
	if !Player or !Player:IsValid() then return false; end
	
	self.PlayerTables[Player].InPGarage = false;
	self.PlayerTables[Player].GoingWrongWay = false;

	if Player:InVehicle() then
		local Vehicle = Player:GetVehicle();
		
		local Position = Vehicle:GetPos();
		local Angles = Vehicle:GetAngles();
		local Children = Vehicle.Children;
		Vehicle:Remove();
		
		Vehicle:EmitSound("ambient/explosions/explode_"..math.random(1,4)..".wav", 85, math.random( 93, 102 ));
		local effectdata = EffectData();
		effectdata:SetOrigin(Vehicle:GetPos());
		effectdata:SetStart(Vehicle:GetPos());
		effectdata:SetScale(50);
		util.Effect("explosion", effectdata);
		
		if self.AllowVehicleDebris then
			for k, v in pairs(Children) do
				if v and v:IsValid() then
					local ent = ents.Create("car_debris");
					if ent and ent:IsValid() then
						ent:SetPos(v:GetPos());
						ent:SetModel(v:GetModel());
						ent:SetAngles(v:GetAngles());
						ent:Spawn();
						ent:Activate();
						
						local phys = ent:GetPhysicsObject();
						if phys and phys:IsValid() then
							phys:ApplyForceCenter(VectorRand() * 20000);
						end
					end
				end
			end
			
			for i = 1, 4 do
				local ent = ents.Create("car_debris");
				if ent then
					ent:SetPos(Position);
					ent:SetModel("models/props_vehicles/tire001c_car.mdl");
					ent:SetAngles(Angles);
					ent:Spawn();
					ent:Activate();
					
					local phys = ent:GetPhysicsObject();
					if phys and phys:IsValid() then
						phys:ApplyForceCenter(VectorRand() * 20000);
					end
				end
			end
			
			/*
			for i = 1, 3 do
				local ent = ents.Create("car_debris");
				if ent then
					ent:SetPos(Position);
					ent:SetModel("models/Gibs/metal_gib" .. math.random(1, 5) .. ".mdl");
					ent:SetAngles(Angles);
					ent:Spawn();
					ent:Activate();
					
					local phys = ent:GetPhysicsObject();
					if phys and phys:IsValid() then
						phys:ApplyForceCenter(VectorRand() * 2000);
					end
				end
			end
			*/
		end
	end

	if Player:IsRacing() then
	
		if GetGlobalInt('GamemodeType') == 2 then
			local CashToGrant = GAMEMODE.NumberPeopleFinished * 200;
			local Place = GAMEMODE.NumberPeopleFinished + 1;
			local BeingInRaceMoney = GAMEMODE.MoneyForBeingInTheRace;
			
			Player:PrintMessage(HUD_PRINTTALK, "You earned $" .. tostring(CashToGrant) .. " for coming in " .. tostring(GAMEMODE.PlaceNames[GAMEMODE.NumRacers - GAMEMODE.NumberPeopleFinished]) .. " place!");
			
			local KillsCash = Player:GetNetworkedInt("RoundKills") * 150;
			
			Player:PrintMessage(HUD_PRINTTALK, "You earned $" .. tostring(KillsCash) .. " for killing " .. Player:GetNetworkedInt("RoundKills") .. " players!");
			
			if Player:GetLevel() >= 2 then
				local Extra = math.Round(CashToGrant / 10)
				local Extra2 = math.Round(Extra * 3)
				CashToGrant = CashToGrant + Extra2;
				Player:PrintMessage(HUD_PRINTTALK, "You earned $" .. Extra2 .. " ( 30% ) bonus cash for being an Admin!");
			elseif Player:GetLevel() == 1 then
				local Extra = math.Round(CashToGrant / 4)
				CashToGrant = CashToGrant + Extra;
				Player:PrintMessage(HUD_PRINTTALK, "You earned $" .. Extra .. " ( 25% ) bonus cash for being a VIP member!");

			end
			
			Player:AddCash(CashToGrant);
		end
		
		GAMEMODE.NumberPeopleFinished = GAMEMODE.NumberPeopleFinished + 1;
		GAMEMODE.NumberPeopleDestroyed = GAMEMODE.NumberPeopleDestroyed + 1;
		Player:SetNetworkedInt("RaceTime", CurTime() - GAMEMODE.RaceStartTime);
		Player:SetNetworkedBool("IsDestroyed", true);

		if Player:GetUsedPart("Radio") == 1 and !GAMEMODE.IsNewRecord then
			Player:ConCommand("stopsound");
		end		
		
		local Killer;
		local KillerDamage = 0;
			
		for k, v in pairs(GAMEMODE.PlayerDamageTables[Player]) do
			if k and k:IsValid() and v > KillerDamage and k != Player and k:Alive() then
				Killer = k;
				KillerDamage = v;
			end
		end
			
		if Killer then
			Killer:SetNetworkedInt("RoundKills", Killer:GetNetworkedInt("RoundKills") + 1);
			
			//GivePlayerKill_RoadRage(Killer);
		end
		
		//GivePlayerKill_DestructionDerby(Player);

		Player:SetNetworkedInt("CurrentCheckpoint", GetGlobalInt("TotalNumberCheckpoints"));
		
		local NumAlive = 0;
		for k, v in pairs(player.GetAll()) do
			if v:IsRacing() then
				NumAlive = NumAlive + 1;
			end
		end
		
		if NumAlive == 1 and GetGlobalInt("GamemodeType") != 1 then
			for k, v in pairs(player.GetAll()) do
				if v:IsRacing() then
					v:Kill();
				end
			end
		end
		
		self.FinishRace();
	end
end

function GM:CanPlayerEnterVehicle ( Player, Vehicle )
	if Vehicle != self.PlayerVehicles[Player] then return false; else return true; end
end

function GM:PlayerSpawn( pl )

	if ( self.TeamBased and ( pl:Team() == TEAM_SPECTATOR || pl:Team() == TEAM_UNASSIGNED ) ) then

		self:PlayerSpawnAsSpectator( pl )
		return
	
	end

	// Stop observer mode
	pl:UnSpectate()
	
	if !GAMEMODE.SpawningRace then
		pl:GodEnable();
	else
		pl:GodDisable();
	end

	// Call item loadout function
	hook.Call( "PlayerLoadout", GAMEMODE, pl )
	
	// Set player model
	hook.Call( "PlayerSetModel", GAMEMODE, pl )
	
	tmysql.query("SELECT wins FROM gmr_wins WHERE steamid = '"..pl:SteamID().."'",function(Res)
	local wins = 0
	if #Res > 0 then
		wins = tonumber(Res[1][1])
	end
	pl:SetNetworkedString("gmr_wins",wins)
	end)
	
end