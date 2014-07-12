ENT.Base = "base_brush"
ENT.Type = "brush"

function ENT:Initialize()
	self.ID = self.ID or 1;
	GAMEMODE.Checkpoints[self.ID] = self;
end

function ENT:StartTouch( Ent )
	if !Ent:IsValid() or !Ent:IsPlayer() then return false; end
	if !Ent:GetNetworkedBool("IsCurrentlyRacing") or GetGlobalInt("TotalNumberCheckpoints") == Ent:GetNetworkedInt("CurrentCheckpoint") or !Ent:InVehicle() then 
		if Ent:GetLevel() > 4 then
			Ent:Kill();
			return false;
		end
	end
	if !Ent:IsRacing() then return false; end
	
	if self.ID == Ent:GetNetworkedInt("CurrentCheckpoint") + 1 then
		GAMEMODE.PlayerTables[Ent].GoingWrongWay = false;
		
		if self.ID == GetGlobalInt("TotalNumberCheckpoints") then
			
			Ent:SetNetworkedInt("RaceTime", CurTime() - GAMEMODE.RaceStartTime);
			
			GAMEMODE.NumberPeopleFinished = GAMEMODE.NumberPeopleFinished + 1;
			local NumFinish = GAMEMODE.NumberPeopleFinished - GAMEMODE.NumberPeopleDestroyed;
			
		//	if NumFinish == 1 then
				tmysql.query("SELECT `WINS` FROM `gmr_wins` WHERE `STEAMID`='" .. tmysql.escape(Ent:SteamID()) .. "'",
					function ( Query )
						if #Query > 0 then
							tmysql.query("UPDATE `gmr_wins` SET `WINS`='" .. (tonumber(Query[1][1]) + 1) .. "', `NAME`='" .. tmysql.escape(Ent:Nick()) .. "' WHERE `STEAMID`='" .. tmysql.escape(Ent:SteamID()) .. "'");
						else
							tmysql.query("INSERT INTO `gmr_wins` (`WINS`, `STEAMID`, `NAME`) VALUES ('1', '" .. tmysql.escape(Ent:SteamID()) .. "', '" .. tmysql.escape(Ent:Nick()) .. "')");
						end
					end
				);
		//	end
			
			local CashToGrant = (GAMEMODE.NumRacers - NumFinish) * GAMEMODE.PerCash;
			local BeingInRaceMoney = GAMEMODE.MoneyForBeingInTheRace;
			
			Ent:PrintMessage(HUD_PRINTTALK, "You earned $" .. tostring(CashToGrant) .. " for coming in " .. tostring(GAMEMODE.PlaceNames[NumFinish]) .. " place!");
			
			if Ent:GetLevel() >= 2 then
				local Extra = math.Round(CashToGrant / 10)
				local Extra2 = math.Round(Extra * 3)
				CashToGrant = CashToGrant + Extra2;
				Ent:PrintMessage(HUD_PRINTTALK, "You earned $" .. Extra2 .. " ( 30% ) bonus cash for being an Admin!");
			elseif Ent:GetLevel() == 1 then
				local Extra = math.Round(CashToGrant / 4)
				CashToGrant = CashToGrant + Extra;
				Ent:PrintMessage(HUD_PRINTTALK, "You earned $" .. Extra .. " ( 25% ) bonus cash for being a VIP member!");
			end
			
			Ent:AddCash(CashToGrant);
			
			
			
			local function KillPart ( v )
				if v and v:IsValid() then
					v:Remove();
				end
			end
			
			local Time = 0;
			for k, v in pairs(GAMEMODE.PlayerVehicles[Ent].Children) do
				if v and v:IsValid() then
					timer.Simple(Time, KillPart, v);
					Time = Time + .5;
				end
			end
			timer.Simple(Time, function ( ) if GAMEMODE.PlayerVehicles[Ent] and GAMEMODE.PlayerVehicles[Ent]:IsValid() then GAMEMODE.PlayerVehicles[Ent]:Remove(); end end);
			Ent:KillSilent();
			
			if Ent:GetNetworkedInt("RaceTime") < Ent:GetNetworkedInt("MapRecord") then
				Ent:PrintMessage(HUD_PRINTTALK, "New Personal Record!");
				
				Ent:SetNetworkedInt("MapRecord", Ent:GetNetworkedInt("RaceTime"));
				tmysql.query("UPDATE `gmr_records` SET `Time`='" .. Ent:GetNetworkedInt("RaceTime") .. "' WHERE `SteamID`='" .. Ent:SteamID() .. "' AND `Map`='" .. game.GetMap() .. "'");
				
				tmysql.query("SELECT `Time`, `Name`, `SteamID` FROM `gmr_records` WHERE `Map`='" .. game.GetMap() .. "' ORDER BY `Time` ASC LIMIT 10",
					function ( Return )
						local TempCompareTop10 = '';
						for k, v in pairs(Return) do
							TempCompareTop10 = TempCompareTop10 .. v[1];
						end
										
						if TempCompareTop10 != GAMEMODE.CompareTop10 then
							local OurPlace = 32;
							GAMEMODE.CompareTop10 = '';
							for i, v in pairs(Return) do
								GAMEMODE.CompareTop10 = GAMEMODE.CompareTop10 .. v[1];
								
								if v[3] == Ent:SteamID() then
									OurPlace = tonumber(i);
								end
								
								
								SetGlobalString("MapRecords_" .. i .. "_Name", v[2]);
								SetGlobalInt("MapRecords_" .. i .. "_Time", v[1]);
							end
												
							if OurPlace != 32 then
								//PE_GMR_RecordBreaker(Ent);
								
								umsg.Start('NewRecord');
									umsg.String(Ent:Name());
									umsg.Short(math.floor(Ent:GetNetworkedInt("RaceTime")));
									umsg.String(GAMEMODE.PlaceNames[OurPlace]);
									umsg.Short(OurPlace);
								umsg.End();
							
								GAMEMODE.IsNewRecord = true;
								timer.Simple(GAMEMODE.NewRecordTime + 1, function ( ) GAMEMODE.IsNewRecord = false; end);
							end
						end
					end
				);
			end
			
			local FinishedMap = GAMEMODE.FinishRace();
			
			if Ent:GetUsedPart("Radio") == 1 and !GAMEMODE.IsNewRecord then
				Ent:ConCommand("stopsounds");
			end
		end
		Ent:SetNetworkedInt("CrossTime", CurTime());
		Ent:SetNetworkedInt("CurrentCheckpoint", self.ID);
		GAMEMODE.PlayerTables[Ent].GoingWrongWay = false;
	elseif self.ID == Ent:GetNetworkedInt("CurrentCheckpoint") then
		umsg.Start("WrongWay", Ent); umsg.End();
		GAMEMODE.PlayerTables[Ent].GoingWrongWay = true;
	end
end

function ENT:KeyValue ( Key, Value )
	local LoweredKey = string.lower(Key);

	if LoweredKey == "number" then
		self.ID = tonumber(Value);

		GAMEMODE:UpdateNumCheckpoints(self.ID);
	end
end

function ENT:EndTouch( Ent ) end
function ENT:Touch( Ent ) end
function ENT:PassesTriggerFilters( Ent ) return Ent:IsPlayer() end
function ENT:Think() end
function ENT:OnRemove() end
