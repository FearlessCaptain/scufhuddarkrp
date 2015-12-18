-- SCUFHUD! (Super Clean Unified Floating HUD) Made by Fearless Captain 

-- Only runs the ui if it is darkrp. I didn't tab everything over because I am lazy.
if GAMEMODE_NAME == "DarkRP" or "darkrp" then 


-- Creates a convar (console variable) to disable/enable the ui.
local schHUDEnable = CreateClientConVar( "schHUD_enable", "1", true, true )

-- Precache fonts
surface.CreateFont( "Tahoma_34", {
	font = "Tahoma", 
	size = 34,
	weight = 500,
	blursize = 0,
	scanlines = 0,
} )

surface.CreateFont( "Tahoma_24", {
	font = "Tahoma", 
	size = 24,
	weight = 500,
	blursize = 0,
	scanlines = 0,
} )

surface.CreateFont( "Tahoma_14", {
	font = "Tahoma", 
	size = 14,
	weight = 500,
	blursize = 0,
	scanlines = 0,
} )

// cache a shitload of variables for great speed
// if anyone reading this knows a better way message me on steam please.

local UIColor = Color( 0, 0, 0, 130 )
local hpsmoothing = 0
local arsmoothing = 0
local hungsmoothing = 0
local angle
local HPmath
local ARmath

local forwardhplerp = Vector( -1.853423, -14.844371, -1.099756 )
local anglehplerp = Angle( 0.138, -132.993, 73.204 )

local pfov = 0
local speed = 7

local pre = 0
local lerpmult = 15
local lerpdif = 0
local alerpdif = 0
local eyetrace


local SlForward = 78.014184397163
local SlRight = 78.014184397163
local SlUp = -12.765957446809
local mult = 8.5815602836879

local xpos = 0
local xpos2 = 0
local ypos = 0
local ypos2 = 0
local height = 185
local wide = 440
local hungoff = 20

local wep 
local wepAmmo 
local wepClip1 
local wepClip1Size 

local nrg
local HungerMath = 0

local agenda
local Avatar

// Render Health and DarkRP info.
	
hook.Add( "PostDrawTranslucentRenderables", "SCHHealth", function()

	if schHUDEnable:GetBool() == false then return end
	
	local ply = LocalPlayer()
	local hp = ply:Health()
	local ar = ply:Armor()
	local nrg = ply:getDarkRPVar("Energy")

	hpsmoothing = math.Approach( hpsmoothing, hp, 70*FrameTime())
	arsmoothing = math.Approach( arsmoothing, ar, 70*FrameTime())
	-- if nrg then 
	-- hungsmoothing = math.Approach( arsmoothing, nrg, 100*FrameTime())
	-- end 
	
	HPmath = math.Clamp( hpsmoothing / 100, 0, 1) * 400
	ARmath = math.Clamp( arsmoothing / 100, 0, 1) * 400
	if nrg then
		HungerMath = math.Clamp( nrg / 100, 0, 1) * (-130 - height + 180)
	end

	angle = ply:GetEyeTraceNoCursor().Normal:Angle()

	angle:RotateAroundAxis( angle:Forward(), SlForward )
	angle:RotateAroundAxis( angle:Right(), SlRight )
	angle:RotateAroundAxis( angle:Up(), SlUp )
	
	eyetrace = ply:GetEyeTraceNoCursor().Normal 
	
	forwardhplerp = LerpVector( FrameTime() * speed, forwardhplerp, eyetrace * lerpmult )
	anglehplerp = LerpAngle( FrameTime() * speed, anglehplerp, angle )
	
	lerpdif = math.abs( forwardhplerp.y - eyetrace.y) 
	alerpdif = anglehplerp.y - angle.y
	if math.abs( alerpdif ) > 10 then 
		speed = math.Approach( speed, speed + 1 * lerpdif, 10*FrameTime() )
	else
		
		speed = math.Clamp( math.Approach( speed, speed - 0.5, 20*FrameTime()), 3, 20 )
	end

	-- Since this hud uses 3d2d you can't just set it to the side of the screen and call it a day,
	-- no. You have to check common resolutions and set each one.
	-- If anyone knows a better way to do this please message me.
	if ScrH() >= 1080 then 
		lerpmult = 17.5 - pfov
	elseif ScrH() >= 900 then
		lerpmult = 15 - pfov
	elseif ScrH() >= 768 then
		lerpmult = 13 - pfov
	elseif ScrH() >= 720 then
		lerpmult = 12.75 - pfov
	end
	
	// acount for players FOV
	pfov = ( ply:GetFOV() - 90 ) * 0.25

	xpos = ScrW() / -1.6
	ypos = ScrW() / 3.1

	local activeWep = ply:GetActiveWeapon()
	
	if activeWep and activeWep:IsValid() and activeWep:GetClass() != "gmod_camera" then
		cam.Start3D2D( EyePos()  + forwardhplerp, anglehplerp, 0.014 )
			render.PushFilterMin( TEXFILTER.ANISOTROPIC )
			render.PushFilterMag( TEXFILTER.ANISOTROPIC )
				
				-- Health
				draw.RoundedBox( 4, xpos - hungoff, ypos - 120, wide, height, UIColor )
				draw.RoundedBox( 2, xpos, ypos, 400, 40, UIColor )
				draw.RoundedBox( 2, xpos, ypos, HPmath, 40, Color( 200, 60, 69) )
				draw.SimpleText( hp, "Tahoma_34", xpos + 2, ypos + 2, Color( 255, 255, 255, 255 ) )
				
				-- Armor
				if ar > 0 then
					height = 240
					draw.RoundedBox( 2, xpos, ypos + 49, 400, 40, UIColor )
					draw.RoundedBox( 2, xpos, ypos + 49, ARmath, 40, Color( 57, 54, 200) )
					draw.SimpleText( ar, "Tahoma_34", xpos + 3, ypos + 52, Color( 255, 255, 255, 255 ) )
				else 
					height = 185
				end
				
				-- Hunger 
				if nrg then	
					wide = 460
					hungoff = 40
					draw.RoundedBox( 0, xpos - 25, ypos + height - 145, 15, -135 - height + 185, UIColor )
					draw.RoundedBox( 0, xpos - 25, ypos + height - 145, 15, HungerMath, Color( 255, 204, 0) )
				else 
					wide = 440
					hungoff = 20
				end
			
				-- DarkRP Info
				draw.SimpleTextOutlined( ply:getDarkRPVar("rpname"), "Tahoma_34", xpos + 2, ypos - 102, Color( 255, 255, 255, 255 ), 0, 0, 0, Color( 8, 12, 3, 255 ) )
				draw.SimpleTextOutlined( ply:getDarkRPVar("job"), "Tahoma_24", xpos + 4, ypos - 63, Color( 255, 255, 255, 255 ), 0, 0, 0, Color( 8, 12, 3, 255 ) )
				draw.SimpleTextOutlined( string.sub( DarkRP.getPhrase("wallet", DarkRP.formatMoney(ply:getDarkRPVar("money")), ""), 9 ) .. " (" .. string.sub( DarkRP.getPhrase("salary", DarkRP.formatMoney(ply:getDarkRPVar("salary")), ""), 9 ) ..")" , "Tahoma_24", xpos + 2, ypos - 35, Color( 255, 255, 255, 255 ), 0, 0, 0, Color( 8, 12, 3, 255 ) )

				-- Agenda
				agenda = ply:getAgendaTable()
				if agenda then 
			
					draw.RoundedBox( 5, xpos - 80, ypos * -1 - 63, 400, 400, UIColor )
					draw.RoundedBox( 5, xpos - 70, ypos * -1 - 53, 380, 40, UIColor )
					
					agendaText = DarkRP.textWrap((ply:getDarkRPVar("agenda") or ""):gsub("//", "\n"):gsub("\\n", "\n"), "Tahoma_24", 380)
					draw.DrawNonParsedText( agenda.Title, "Tahoma_24", xpos + 120, ypos * -1 - 48, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER)
					draw.DrawNonParsedText( agendaText, "Tahoma_24", xpos - 50, ypos * -1 + 15, Color( 255, 255, 255, 255 ), 0)
				end
				
			render.PopFilterMin()
			render.PopFilterMag()
		cam.End3D2D()
		
	end 
end )

function HideDefaultHUDD3( name )
	if schHUDEnable:GetBool() == false then return end
	-- if ( name == "CHudHealth" ) or ( name == "CHudBattery" ) or ( name == "CHudSecondaryAmmo" ) or ( name == "CHudAmmo" ) or ( name == "DarkRP_LocalPlayerHUD" ) or ( name == "DarkRP_Agenda" ) or ( name == "DarkRP_Hungermod" ) then return false end
	if ( name == "CHudHealth" ) or ( name == "CHudBattery" )  or ( name == "DarkRP_LocalPlayerHUD" ) or ( name == "DarkRP_Agenda" ) or ( name == "DarkRP_Hungermod" ) then return false end

end
hook.Add( "HUDShouldDraw", "HideDefaultHUDD3", HideDefaultHUDD3 )

hook.Add( "OnPlayerChat", "Create3d2dmove", function( ply, text, team )
	if ply == LocalPlayer() and text:lower():match("!3d2dm$") then
		-- print( "client side" )
		sliders()
		return ""
	end
end )

end