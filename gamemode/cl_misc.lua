function GM.HUDShouldDraw ( Name )
	if Name == "CHudHealth" or Name == "CHudBattery" or Name == "CHudAmmo" or Name == "CHudSecondaryAmmo" then
		return false;
	else
		return true;
	end
end 
hook.Add("HUDShouldDraw", "GMR_HUDShouldDraw", GM.HUDShouldDraw)  ;

function GM:PlayerBindPress ( Player, Bind, Pressed )
	if Bind == "+use" or Bind == "-use" or string.find(Bind, "slot") then
		return true;
	elseif Bind == "+speed" then
		if LocalPlayer():GetUsedPart("Engine Supercharging") != 0 or LocalPlayer():GetUsedPart("Cooling System") != 0 or LocalPlayer():GetUsedPart("Nitrous System") != 0 or LocalPlayer():GetUsedPart("Exhaust") != 0 then
			local JeepData = Player:CompileJeepData()
			
			if Player:InVehicle() and self.LastNOSTime + JeepData.BoostDelay + JeepData.BoostDuration <= CurTime() then
				self.LastNOSTime = CurTime();
			end
		else
			return true;
		end
	elseif Bind == "+jump" and Player:GetUsedPart("Hand Brake") == 0 and IsValid(Player:GetVehicle()) then
		return true;
	elseif Bind == "impulse 100" then
		SetGlobalBool("LightsOn", GetGlobalBool("LightsOn"));
		RunConsoleCommand("GMRacer_ToggleLights", "");
	end
end

function GM.NewRecord ( Name, Time, Place, Numeric )
	GAMEMODE.NewRecordNum = Numeric;
	
	GAMEMODE.NewRecord_Text = Name .. " beat the " .. Place .." place record with a time of " .. Time .. " seconds!";
	
	SetGlobalString("MapRecords_" .. Numeric .. "_Name", Name);
	SetGlobalInt("MapRecords_" .. Numeric .. "_Time", Time);
	
	timer.Simple(1, function ( ) GAMEMODE.IsNewRecord = true; end)
	timer.Simple(GAMEMODE.NewRecordTime + 1, GAMEMODE.StopNewRecord);
	RunConsoleCommand("stopsound");
	timer.Simple(1, function() surface.PlaySound("gmracer/new_record.mp3") end);
end

function GM.StopNewRecord ( ) GAMEMODE.IsNewRecord = false; end
GM.GlobalEmitter = ParticleEmitter(Vector(0, 0, 0));