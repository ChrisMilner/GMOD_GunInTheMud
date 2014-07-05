include( "shared.lua" )

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
	info_text:SetText( "Please choose the team that you want tp be on:" )

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
		frame:Close()
	end
end
concommand.Add( "team_menu" , set_team)
