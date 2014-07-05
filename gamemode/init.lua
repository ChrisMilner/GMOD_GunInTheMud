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

--Switches player to team 1
function team_1(ply)
	ply:SetTeam(1)
	ply:Spawn()
end
concommand.Add( "team_1" , team_1)

--Switches player to team 2
function team_2(ply)
	ply:SetTeam(2)
	ply:Spawn()
end
concommand.Add( "team_2" , team_2)
