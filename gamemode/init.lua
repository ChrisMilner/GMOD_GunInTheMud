AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( 'shared.lua' )

util.AddNetworkString( "time_info" )
util.AddNetworkString( "team_info" )
util.AddNetworkString( "team_data" )

RoundTimeLimit = 180
WalkSpeed = 250
HunterRunSpeed = 400
StuckSpeed = 20
MinimumWalkSpeed = 50
MinimumRunSpeed = 70
SpeedReduction = 10
SpeedIncrease = 5

-- Called when the game is initialised
function GM:Initialize()
	CreateRoundTimer()
	InRound = true
	PlayerStuckTable = {}
end

-- Creates the round timers
function CreateRoundTimer()
	time = RoundTimeLimit
	timer.Create( "round_timer" , 180 , 1 , function() RoundEnd( "HUNTED" ) end )
	timer.Create( "display_timer" , 1 , RoundTimeLimit , function() SendTime( time ) end)
end

--Sends the time to the client
function SendTime()
	net.Start( "time_info" )
		net.WriteInt( time , 9 )
	net.Send(player.GetHumans())

	time = time - 1
end

--Sends the team name to the client
function SendTeamName( team )
	net.Start( "team_info" )
		net.WriteString( team )
	net.Send(player.GetHumans())
end

-- Allows user to pick teams
function GM:PlayerInitialSpawn( ply )
	ply:ConCommand( "team_menu" )
end

-- Assigns different weapons to players dependent on their team
function GM:PlayerSpawn( ply )
	ply:StripWeapons()

	if ply:Team() ==  1 then -- HUNTER
		ply:SetModel( "models/player/barney.mdl" ) 

		ply:Give( "weapon_crowbar" )

		ply:SetRunSpeed( HunterRunSpeed )
	elseif ply:Team() == 2 then	 -- HUNTED
		ply:SetModel( "models/player/Eli.mdl" )

		ply:Give( "weapon_ar2" )
		ply:Give( "weapon_crowbar" )
		ply:GiveAmmo( 500 - ply:GetAmmoCount( "AR2" ) , "AR2" , false)	-- TODO Change to stop ammo incrementation

		ply:SetRunSpeed( WalkSpeed )
	end
end

-- Is called when a player takes damage
function GM:PlayerHurt(ply , atk)
	ply:SetHealth(100)

	if ply:Team() == 2 and atk:IsPlayer() and atk:Team() == 1 then -- HUNTED attacked by HUNTER
		MakePlayerStuck(ply)
	elseif atk:IsPlayer() and ply:Team() == 2 and atk:Team() == 2 then -- HUNTED attacked by HUNTED
		UnstickPlayer(ply)
	elseif ply:Team() == 1 then -- HUNTER takes damage
		DarkenScreen(ply)
	end
end

-- Switches player to team 1
function team_1(ply)
	ply:SetTeam(1)
	ply:Spawn()
	ply:SetRunSpeed( HunterRunSpeed )
	SendTeamName( "HUNTER" )
	ply:ChatPrint( ply:Nick().." joined team HUNTERS" )

	SendTeamData( 1 , GetTeam1() )
	SendTeamData( 2 , GetTeam2() )
end
concommand.Add( "team_1" , team_1)

-- Switches player to team 2
function team_2(ply)
	ply:SetTeam(2)
	ply:Spawn()
	ply:SetRunSpeed( WalkSpeed )
	SendTeamName( "HUNTED" )
	ply:ChatPrint( ply:Nick().." joined team HUNTED" )

	SendTeamData( 1 , GetTeam1() )
	SendTeamData( 2 , GetTeam2() )
end
concommand.Add( "team_2" , team_2)

-- Slows the player down massively
function MakePlayerStuck( ply )
	ply:SetWalkSpeed( StuckSpeed )
	ply:SetRunSpeed( StuckSpeed )
	PlayerStuckTable[ ply:UserID() ] = true
	if CheckForWin() then RoundEnd( "HUNTERS") end
end
concommand.Add( "stick" , MakePlayerStuck)

-- Usticks  the player ressetting their speed to normal
function UnstickPlayer( ply )
	ply:SetWalkSpeed( WalkSpeed )
	if ply:Team() == 1 then ply:SetRunSpeed( HunterRunSpeed )
	elseif ply:Team() == 2 then ply:SetRunSpeed( WalkSpeed ) end
	PlayerStuckTable[ ply:UserID() ] = false
end
concommand.Add( "unstick" , UnstickPlayer)

-- Returns a boolean representative of whether the player is stuck
function IsPlayerStuck( ply )
	return PlayerStuckTable[ ply:UserID() ]
end
concommand.Add( "amistuck" , IsPlayerStuck)

-- Darkens the screen and slows speed when a hunter is hit
function DarkenScreen( ply )
	ply:ScreenFade(1 , Color(0,0,0,245) , 0.5 , 0.5)
	if ply:GetWalkSpeed() >= MinimumWalkSpeed then  ply:SetWalkSpeed( ply:GetWalkSpeed() - SpeedReduction ) end 
	if ply:GetRunSpeed() >= MinimumRunSpeed then  ply:SetRunSpeed( ply:GetRunSpeed() - 2 * SpeedReduction ) end
	timer.Create( "SpeedTimer" , 1 , math.floor((WalkSpeed - ply:GetWalkSpeed()) / 5) , function() SpeedTimerCall(ply) end)
end
concommand.Add( "dark" , DarkenScreen )

-- Called to increase the run/walk speed
function SpeedTimerCall( ply )
	if ply:Team() == 2 then return end
	ply:ChatPrint( ply:GetWalkSpeed().."  "..ply:GetRunSpeed())
	if ply:GetWalkSpeed() < 246 then ply:SetWalkSpeed( ply:GetWalkSpeed() + SpeedIncrease) end
	if ply:GetRunSpeed() < 396 then ply:SetRunSpeed( ply:GetRunSpeed() + SpeedIncrease) end 
end

-- Checks if all of the HUNTED are stuck
function CheckForWin()
	if InRound == false then return end

	for x , ply in pairs(GetTeam2()) do
		if IsPlayerStuck( ply ) == false then return false end
	end
	return true
end

-- Adds the Hunted players to a table with them being unstuck
function AddHuntedToTable(ply)
	table.insert(PlayerStuckTable , ply:UserID() , false)
end
concommand.Add( "AddHunted" , AddHuntedToTable )

-- Called when the round ends
function RoundEnd( winner )
	print( winner.." WINS!" )
	InRound = false
	ClearTable( PlayerStuckTable )

	if winner == "HUNTED" then
		DisplayWinScreen( "HuntedWinScreen" )
	elseif winner == "HUNTERS" then
		DisplayWinScreen( "HunterWinScreen" )
	end

	timer.Create( "PostGameTimer" , 10 , 1 , function() 
		for x , p in pairs(player.GetHumans()) do 
			SwitchTeam( p )
			UnstickPlayer( p ) 
		end
		CreateRoundTimer()
		InRound = true
	end)
end

-- Switches the teams
function SwitchTeam( ply )
	if ply:Team() == 1 then 
		team_2( ply )
	elseif ply:Team() == 2 then 
		team_1( ply )
	end

	ply:ChatPrint( "Teams Switched!" )
end
concommand.Add( "switch" , SwitchTeam)

-- Runs the console command for all of the players
function DisplayWinScreen( command )
	for x , p in pairs(player.GetHumans()) do
		p:ConCommand( command )
	end
end

-- Deletes all content from the table
function ClearTable( table )
	for x , v in pairs( table ) do
		table[x] = nil
	end
end

-- Returns a table of all players in team 1
function GetTeam1()
	local t1 = {}

	for x , p in pairs(player.GetHumans()) do
		if p:Team() == 1 then
			table.insert( t1 , p )
		end
	end
	return t1
end

-- Returns a table of all of the players in team 2
function GetTeam2()
	local t2 = {}

	for x , p in pairs(player.GetHumans()) do
		if p:Team() == 2 then
			table.insert( t2 , p )
		end
	end
	return t2
end

function SendTeamData( TeamNum , table )
	net.Start( "team_data" )
		net.WriteInt( TeamNum , 2 )
		net.WriteTable( table ) 
	net.Send(player.GetHumans())

	print("Team Data Sent")
end
