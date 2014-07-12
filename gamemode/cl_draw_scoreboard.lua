
function GM:ScoreboardShow()
	GAMEMODE.ShowScoreboard = true
end

/*---------------------------------------------------------
   Name: gamemode:ScoreboardHide( )
   Desc: Hides the scoreboard
---------------------------------------------------------*/
function GM:ScoreboardHide()
	GAMEMODE.ShowScoreboard = false
end

function GM.GetTeamScoreInfo()
	local tbl = {}
	
	for k,v in pairs (player.GetAll()) do
	
		if tbl[v:Team()] == nil then
			tbl[v:Team()] = {}
		end
		
		if tbl[v:Team()].Players == nil then
			tbl[v:Team()].Players = {}
		end
		
		local temp = {}
		temp.Name = v:Nick()
		temp.PlayerObj = v
		temp.Ping = v:Ping()
		temp.Wins = v:GetNetworkedString("gmr_wins") or 0
		
		table.insert(tbl[v:Team()].Players,temp)
	
	end
	
	return tbl
end

function GM:HUDDrawScoreBoard()

	if (!GAMEMODE.ShowScoreboard) then return end
	if LocalPlayer():IsRacing() then return end
	
	if (GAMEMODE.ScoreDesign == nil) then
	
		GAMEMODE.ScoreDesign = {}
		GAMEMODE.ScoreDesign.HeaderY = 0
		GAMEMODE.ScoreDesign.Height = ScrH() / 2
	
	end
	
	local alpha = 255

	local ScoreboardInfo = self:GetTeamScoreInfo()
	
	local xOffset = ScrW() / 10
	local yOffset = 32
	local scrWidth = ScrW()
	local scrHeight = ScrH() - 64
	local boardWidth = scrWidth - (2* xOffset)
	local boardHeight = scrHeight
	local colWidth = 75
	
	boardWidth = math.Clamp( boardWidth, 400, 600 )
	boardHeight = GAMEMODE.ScoreDesign.Height
	
	xOffset = (ScrW() - boardWidth) / 2.0
	yOffset = (ScrH() - boardHeight) / 2.0
	yOffset = yOffset - ScrH() / 4.0
	yOffset = math.Clamp( yOffset, 32, ScrH() )
	
	// Background
	//surface.SetDrawColor( GreyColor )
	//surface.DrawRect( xOffset, yOffset, boardWidth, GAMEMODE.ScoreDesign.HeaderY)
	
	//surface.SetDrawColor( 150, 150, 150, 200 )
	draw.RoundedBox(10, xOffset-1, yOffset-1, boardWidth+2, boardHeight+2, GreyColor);
	draw.RoundedBox(10, xOffset, yOffset, boardWidth, boardHeight, Color(255, 255, 255, 255));
	//surface.DrawRect( xOffset, yOffset+GAMEMODE.ScoreDesign.HeaderY, boardWidth, boardHeight-GAMEMODE.ScoreDesign.HeaderY)
	
	// Outline
	/*
	surface.SetDrawColor( 0, 0, 0, 150 )
	surface.DrawOutlinedRect( xOffset, yOffset, boardWidth, boardHeight )
	surface.SetDrawColor( 0, 0, 0, 50 )
	surface.DrawOutlinedRect( xOffset-1, yOffset-1, boardWidth+2, boardHeight+2 )
	*/
	
	local hostname = GetGlobalString( "ServerName", "" )
	local gamemodeName = GAMEMODE.Name .. " - " .. GAMEMODE.Author
	
	surface.SetTextColor(GreyColor.r, GreyColor.g, GreyColor.b, GreyColor.a)
	
	if ( string.len(hostname) > 32 ) then
		surface.SetFont( "ScoreboardSub" )
	else
		surface.SetFont( "ScoreboardHead" )
	end
	
	local txWidth, txHeight = surface.GetTextSize( GetHostName() )
	local y = yOffset + 15
	surface.SetTextPos(xOffset + (boardWidth / 2) - (txWidth/2), y)
	surface.DrawText( GetHostName() )
	
	y = y + txHeight + 2
	
	surface.SetFont( "ScoreboardSub" )
	local txWidth, txHeight = surface.GetTextSize( gamemodeName )
	surface.SetTextPos(xOffset + (boardWidth / 2) - (txWidth/2), y)
	surface.DrawText( gamemodeName )
	
	y = y + txHeight + 4
	GAMEMODE.ScoreDesign.HeaderY = y - yOffset
	
	surface.SetDrawColor(0, 0, 0, 20)
	surface.DrawRect( xOffset + boardWidth - (colWidth*1), y, colWidth, boardHeight-y+yOffset )
	
	surface.SetDrawColor(0, 0, 0, 20)
	surface.DrawRect( xOffset + boardWidth - (colWidth*4), y, colWidth * 2, boardHeight-y+yOffset )
	
	
	surface.SetFont( "ScoreboardText" )
	local txWidth, txHeight = surface.GetTextSize( "W" )
	
	surface.SetDrawColor(GreyColor.r, GreyColor.g, GreyColor.b, GreyColor.a)
	surface.DrawRect( xOffset, y, boardWidth, txHeight + 6 )

	y = y + 2
	
	surface.SetTextColor(255, 255, 255, 255);
	surface.SetTextPos( xOffset + 16,								y)	surface.DrawText("#Name")
	surface.SetTextPos( xOffset + boardWidth - (colWidth*5) + 8,	y)	surface.DrawText("Finishes")
	surface.SetTextPos( xOffset + boardWidth - (colWidth*4) + 8,	y)	surface.DrawText("Map Record")
	surface.SetTextPos( xOffset + boardWidth - (colWidth*2) + 8,	y)	surface.DrawText("Queued")
	surface.SetTextPos( xOffset + boardWidth - (colWidth*1) + 8,	y)	surface.DrawText("#Ping")
	
	
	y = y + txHeight + 4

	local yPosition = y
	for teami,info in pairs(ScoreboardInfo) do

		
		for index,plinfo in pairs(info.Players) do
		
			surface.SetFont( "ScoreboardText" )
			surface.SetTextColor(TextColor.r, TextColor.g, TextColor.b, 200)
			surface.SetTextPos( xOffset + 16, yPosition )
			txWidth, txHeight = surface.GetTextSize( plinfo.Name )
			
			if (plinfo.PlayerObj == LocalPlayer()) then
				surface.SetDrawColor(0, 255, 255, 50 )
				surface.DrawRect( xOffset+1, yPosition, boardWidth - 2, txHeight + 2)
			elseif plinfo.PlayerObj:Team() != 5 then
				local color = team.GetColor(plinfo.PlayerObj:Team());
				
				if plinfo.PlayerObj:Team() == 1 then
					surface.SetDrawColor(255, 0, 0, 100)
				else
					surface.SetDrawColor(color.r, color.g, color.b, 50)
				end
				
				surface.DrawRect( xOffset+1, yPosition, boardWidth - 2, txHeight + 2)
			end
			
			
			local px, py = xOffset + 16, yPosition
			local textcolor = Color(TextColor.r, TextColor.g, TextColor.b, alpha)
			
			local shadowcolor = Color( 0, 0, 0, alpha * 0.8 )
			
			draw.SimpleText( plinfo.Name, "ScoreboardText", px, py, textcolor )
			
			px = xOffset + boardWidth - (colWidth*4) + 8		
			local Time = plinfo.PlayerObj:GetNetworkedInt("MapRecord");
			
			if Time != 1337 then
				draw.SimpleText( string.ToMinutesSecondsMilliseconds(Time) .. " Seconds", "ScoreboardText", px, py, textcolor )
			else
				draw.SimpleText( "No Record", "ScoreboardText", px, py, textcolor )
			end
			
			px = xOffset + boardWidth - (colWidth*2) + 8			
			if plinfo.PlayerObj:GetNetworkedBool("IsQueued") then
				draw.SimpleText( "Yes", "ScoreboardText", px, py, textcolor )
			else
				draw.SimpleText( "No", "ScoreboardText", px, py, textcolor )
			end
			
			px = xOffset + boardWidth - (colWidth*1) + 8			
			draw.SimpleText( plinfo.Ping, "ScoreboardText", px, py, textcolor )
			
			px = xOffset + boardWidth - (colWidth*5-15) + 8			
			draw.SimpleText(plinfo.Wins, "ScoreboardText", px, py, textcolor )
			//surface.DrawText( plinfo.Name )
			//surface.SetTextPos( xOffset + 16 + 2, yPosition + 2 )
			//surface.SetTextColor( 0, 0, 0, 200 )
			//surface.DrawText( plinfo.Name )

			//surface.SetTextPos( xOffset + boardWidth - (colWidth*3) + 8, yPosition )
			//surface.DrawText( plinfo.Frags )

			//surface.SetTextPos( xOffset + boardWidth - (colWidth*2) + 8, yPosition )
			//surface.DrawText( plinfo.Deaths )

			//surface.SetTextPos( xOffset + boardWidth - (colWidth*1) + 8, yPosition )
			//surface.DrawText( plinfo.Ping )

			yPosition = yPosition + txHeight + 3
		end
	end
	
	yPosition = yPosition + 8
	
	GAMEMODE.ScoreDesign.Height = (GAMEMODE.ScoreDesign.Height * 2) + (yPosition-yOffset)
	GAMEMODE.ScoreDesign.Height = GAMEMODE.ScoreDesign.Height / 3
	
end