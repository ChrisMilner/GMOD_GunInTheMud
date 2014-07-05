AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( 'shared.lua' )

-- Allows user to pick teams
function GM:PlayerInitialSpawn( ply )
	ply:ConCommand( "team_menu" )	
end

-- Assigns different weapons to players dependent on their team
function GM:PlayerLoadout( ply )

	ply:StripWeapons()

	if ply:Team() == 1 then
		ply:Give( "weapon_pistol" )
		ply:Give( "weapon_crowbar" )
	else
		ply:Give( "weapon_ar2" )
	end
end

-- Is called when a player takes damage
function GM:PlayerHurt(ply , atk)
	ply:SetHealth(100)

	if ply:Team() == 2 then
		MakePlayerStuck(ply)
	end
end

--Switches player to team 1
function team_1(ply)
	ply:SetTeam(1)
	ply:Spawn()
	ply:ChatPrint( ply:Nick().." joined team HUNTERS" )
end
concommand.Add( "team_1" , team_1)

--Switches player to team 2
function team_2(ply)
	ply:SetTeam(2)
	ply:Spawn()
	ply:ChatPrint( ply:Nick().." joined team HUNTED" )
end
concommand.Add( "team_2" , team_2)

function MakePlayerStuck(ply)
	ply:SetWalkSpeed(20)
	ply:SetRunSpeed(20)
end
concommand.Add( "stick" , MakePlayerStuck)

function UnstickPlayer(ply)
	ply:SetWalkSpeed(250)
	ply:SetRunSpeed(500)
end
concommand.Add( "unstick" , UnstickPlayer)
