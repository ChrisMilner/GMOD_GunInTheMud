AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( 'shared.lua' )

PlayerStuckTable = {}

-- Allows user to pick teams
function GM:PlayerInitialSpawn( ply )
	ply:ConCommand( "team_menu" )
	table.insert(PlayerStuckTable , ply:UserID() , false)
end

-- Assigns different weapons to players dependent on their team
function GM:PlayerLoadout( ply )

	ply:StripWeapons()

	ply:ChatPrint( "Player Loadout Function Called" )

	if ply:Team() == 1 then
		ply:Give( "weapon_pistol" )
		ply:Give( "weapon_crowbar" )
	elseif ply:Team() == 2 then
		ply:Give( "weapon_ar2" )
	end
end

-- Is called when a player takes damage
function GM:PlayerHurt(ply , atk)
	ply:SetHealth(100)

	if ply:Team() == 2 then
		MakePlayerStuck(ply)
	elseif ply:Team() == 1 then
		DarkenScreen(ply)
	end
end

-- Switches player to team 1
function team_1(ply)
	ply:SetTeam(1)
	ply:Spawn()
	ply:ChatPrint( ply:Nick().." joined team HUNTERS" )
end
concommand.Add( "team_1" , team_1)

-- Switches player to team 2
function team_2(ply)
	ply:SetTeam(2)
	ply:Spawn()
	ply:ChatPrint( ply:Nick().." joined team HUNTED" )
end
concommand.Add( "team_2" , team_2)

-- Slows the player down massively
function MakePlayerStuck( ply )
	ply:SetWalkSpeed(20)
	ply:SetRunSpeed(20)
	PlayerStuckTable[ ply:UserID() ] = true
end
concommand.Add( "stick" , MakePlayerStuck)

-- Usticks  the player ressetting their speed to normal
function UnstickPlayer( ply )
	ply:SetWalkSpeed(250)
	ply:SetRunSpeed(500)
	PlayerStuckTable[ ply:UserID() ] = false
end
concommand.Add( "unstick" , UnstickPlayer)

--Returns a boolean representative of whether the player is stuck
function IsPlayerStuck( ply )
	return PlayerStuckTable[ ply:UserID() ]
end
concommand.Add( "amistuck" , IsPlayerStuck)

--Darkens the screen and slows speed when a hunter is hit
function DarkenScreen( ply )
	ply:ScreenFade(2 , Color(0,0,0,100) , 0.1 , 1.5)
	ply:SetWalkSpeed(ply:GetWalkSpeed() - 20)
	ply:SetRunSpeed(ply:GetRunSpeed() - 20)
	timer.Create( "SpeedTimer" , 1 , (250 - ply:GetWalkSpeed()) / 5 , function() SpeedTimerCall(ply) end)
end
concommand.Add( "dark" , DarkenScreen )

--Called to increase the run/walk speed
function SpeedTimerCall( ply )
	ply:SetWalkSpeed( ply:GetWalkSpeed() + 5)
	ply:SetRunSpeed( ply:GetRunSpeed() + 5)
	ply:ChatPrint(ply:GetWalkSpeed())
end
