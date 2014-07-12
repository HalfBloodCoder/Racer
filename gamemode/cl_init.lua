_R = debug.getregistry()

function _R.Player:GetScriptedVehicle()
	return Entity(0)
end

surface.CreateFont( "LCD_Large", 
                    {
                    font    = "LCD",
                    size    = 50,
                    weight  = 400,
                    antialias = true,
                    shadow = false
            })
surface.CreateFont( "LCD_ExtraLarge", 
                    {
                    font    = "LCD",
                    size    = 125,
                    weight  = 400,
                    antialias = true,
                    shadow = false
            })
			
surface.CreateFont( "ScoreboardHead", {
	font 		= "Arial",
	size 		= 20,
	weight 		= 800,
	blursize 	= 0,
	scanlines 	= 0,
	antialias 	= true,
	underline 	= false,
	italic 		= false,
	strikeout 	= false,
	symbol 		= false,
	rotary 		= false,
	shadow 		= false,
	additive 	= false,
	outline 	= false
	}
)
surface.CreateFont( "ScoreboardText", {
	font 		= "Arial",
	size 		= 20,
	weight 		= 500,
	blursize 	= 0,
	scanlines 	= 0,
	antialias 	= true,
	underline 	= false,
	italic 		= false,
	strikeout 	= false,
	symbol 		= false,
	rotary 		= false,
	shadow 		= false,
	additive 	= false,
	outline 	= false
	}
)
surface.CreateFont( "ScoreboardSub", {
	font 		= "Arial",
	size 		= 25,
	weight 		= 700,
	blursize 	= 0,
	scanlines 	= 0,
	antialias 	= true,
	underline 	= false,
	italic 		= false,
	strikeout 	= false,
	symbol 		= false,
	rotary 		= false,
	shadow 		= false,
	additive 	= false,
	outline 	= false
	}
)
			
GM.EffectsOn = CreateClientConVar( "gmr_effects", "1", true, false )
GM.LightsOn = CreateClientConVar( "gmr_lights", "1", true, false )

include("cl_setup.lua");
include("shared.lua")
include("cl_networking.lua");
include("cl_draw.lua");
include("garage.lua");
include("help_menu.lua");
include("cl_misc.lua");
include("cl_draw_scoreboard.lua");
include("cl_leaderscreen.lua");
include("draw_race.lua");
include("draw_demo.lua");
