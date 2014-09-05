include( "shared.lua" )

t1 = {}
t2 = {}
HunterText = ""
HuntedText = ""

--Creates a window allowing the player to choose a team
function set_team()
	local frame = vgui.Create( "DFrame" )
	frame:SetPos(100, 100)
	frame:SetSize(ScrW() - 200, ScrH() - 200)
	frame:SetTitle( "Select your Team" )
	frame:SetVisible(true)
	frame:SetDraggable(false)
	frame:ShowCloseButton(false)
	frame:MakePopup()

	info_text = vgui.Create( "DLabel" , frame )
	info_text:SetPos(ScrW() / 2 - 200, 100)
	info_text:SetSize(400, 20)
	info_text:SetText( "Please choose the team that you want to be on:" )

	team_1 = vgui.Create( "DButton" , frame )
	team_1:SetPos(100, 200)
	team_1:SetSize(200,80)
	team_1:SetText( "HUNTERS" )
	team_1.DoClick = function() 
		RunConsoleCommand( "team_1" ) 
		frame:Close()
	end

	team_2 = vgui.Create( "DButton" , frame )
	team_2:SetPos(frame:GetWide() - 300, 200)
	team_2:SetSize(200,80)
	team_2:SetText( "HUNTED" )
	team_2.DoClick = function() 
		RunConsoleCommand( "team_2" )
		RunConsoleCommand( "AddHunted" )
		frame:Close()
	end
end
concommand.Add( "team_menu" , set_team)

--Displays a screen saying tht the hunters win
function HunterVictoryScreen()
	local frame = vgui.Create( "DFrame" )
	frame:SetPos(100, 100)
	frame:SetSize(ScrW() - 200, ScrH() - 200)
	frame:SetTitle( "Hunters Win" )
	frame:SetVisible( true )
	frame:SetDraggable( false )
	frame:ShowCloseButton( true )
	frame:MakePopup()

	HuntersWin = vgui.Create( "DLabel" , frame )
	HuntersWin:SetPos(ScrW() / 2 - 200, 100)
	HuntersWin:SetSize(400, 50)
	HuntersWin:SetFont( "DermaLarge" )
	HuntersWin:SetText( "Hunters Win The Round!!" )
end
concommand.Add( "HunterWinScreen" , HunterVictoryScreen)

--Displays a screen saying tht the hunted win
function HuntedVictoryScreen()
	local frame = vgui.Create( "DFrame" )
	frame:SetPos(100, 100)
	frame:SetSize(ScrW() - 200, ScrH() - 200)
	frame:SetTitle( "The Hunted Win" )
	frame:SetVisible( true )
	frame:SetDraggable( false )
	frame:ShowCloseButton( true )
	frame:MakePopup()

	HuntersWin = vgui.Create( "DLabel" , frame )
	HuntersWin:SetPos(ScrW() / 2 - 200, 100)
	HuntersWin:SetSize(400, 50)
	HuntersWin:SetFont( "DermaLarge" )
	HuntersWin:SetText( "The Hunted Win The Round!!" )
end
concommand.Add( "HuntedWinScreen" , HuntedVictoryScreen)

-- Adds in the timer displayed at the top of the screen
function GM:HUDPaint()
	if  seconds < 10 then
		draw.DrawText( "0"..minutes..":0"..seconds , "DermaLarge" , ScrW() / 2 - 10 , 0 , Color(255,255,255,255) , TEXT_ALIGN_CENTER )
	else
		draw.DrawText( "0"..minutes..":"..seconds , "DermaLarge" , ScrW() / 2 - 10 , 0 , Color(255,255,255,255) , TEXT_ALIGN_CENTER )
	end
	draw.DrawText( TeamName , "DermaLarge" , ScrW() - 80 , ScrH() - 50 , TeamColour , TEXT_ALIGN_CENTER )
end

--Displays the scoreboard when the button is pressed
function GM:ScoreboardShow()
	--[[Scoreboard = vgui.Create( "DFrame" )
	Scoreboard:SetPos(100, 100)
	Scoreboard:SetSize(ScrW() - 200, ScrH() - 200)
	Scoreboard:SetTitle( "Scoreboard" )
	Scoreboard:SetVisible( true )
	Scoreboard:SetDraggable( false )
	Scoreboard:ShowCloseButton( false )
	Scoreboard:MakePopup()

	HuntersPlayers = vgui.Create( "DLabel" , Scoreboard )
	HuntersPlayers:SetPos(ScrW() / 2 - 550, 100)
	HuntersPlayers:SetSize(400, 500)
	HuntersPlayers:SetFont( "DermaLarge" )
	HuntersPlayers:SetText( "Hunters\n"..HunterText )

	HuntedPlayers = vgui.Create( "DLabel" , Scoreboard )
	HuntedPlayers:SetPos(ScrW() / 2 , 100)
	HuntedPlayers:SetSize(400, 500)
	HuntedPlayers:SetFont( "DermaLarge" )
	HuntedPlayers:SetText( "Hunted\n"..HuntedText )]]
end

--Hides the scoreboard when the button is released
function GM:ScoreboardHide()
	--Scoreboard:Close()
end

-- Converts the number of seconds to minutes and seconds
function GetTimeInfo( len , ply )
	local time = net.ReadInt(9)
	minutes = math.floor(time / 60)
	seconds = time % 60
end
net.Receive( "time_info" , GetTimeInfo )

-- Recieves the team name message and chooses the correct colour
function GetTeamName( len , ply )
	TeamName = net.ReadString()

	if TeamName == "HUNTER" then
		TeamColour = Color(255,50,50,255)
	elseif TeamName == "HUNTED" then
		TeamColour = Color(50,255,50,255)
	else
		TeamColour = Color(255,255,255,255)
	end
end
net.Receive( "team_info" , GetTeamName )

function GetTeamData( len , ply )
	if net.ReadInt(2) == 1 then
		t1 = net.ReadTable()
		HunterText = GetTeamText( t1 )
	else
		t2 = net.ReadTable()
		HuntedText = GetTeamText( t2 )
	end
end
net.Receive( "team_data" , GetTeamData )

function GetTeamText( table )
	local text = ""
	for x , p in pairs(table) do
		local name = p:Nick()
		text = text.."\n"..name
	end
	return text
end
