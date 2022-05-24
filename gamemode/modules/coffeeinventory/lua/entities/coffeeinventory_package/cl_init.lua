include("shared.lua")

net.Receive( "coffeeInv_itemPackageData", function()
	local ent = net.ReadEntity()
	ent.item = net.ReadTable()
end )

function ENT:Draw()
	self:DrawModel()
	if self:GetPos():Distance( LocalPlayer():GetPos() ) < 250 then 	
		cam.Start3D2D( self:GetPos() + Vector( 0, 0, 15 ), Angle( 0, LocalPlayer():EyeAngles().yaw - 90, 90 ), 0.02 )
			surface.SetDrawColor( Color( 235, 189, 99, 50 ) )
			surface.DrawRect( -400, 0 + math.sin( CurTime() ) * 50, 800, 100 )
			draw.SimpleText( "Item Pack ", "coffeeinventory_medium3d", 0, 50 + math.sin( CurTime() ) * 50, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		cam.End3D2D()
	end
end