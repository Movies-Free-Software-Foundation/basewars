surface.CreateFont( "coffeeinventory_tiny", { font = "Default", size = 12, weight = 1000, antialias = true,  additive = false } )
surface.CreateFont( "coffeeinventory_little", { font = "Default", size = 16, weight = 1000, antialias = true,  additive = false } )
surface.CreateFont( "coffeeinventory_little3d", { font = "Default", size = 50, weight = 1000, antialias = true,  additive = true } )
surface.CreateFont( "coffeeinventory_medium3d", { font = "Default", size = 100, weight = 1000, antialias = true,  additive = true } )

coffeeInventory.menuInterface = coffeeInventory.menuInterface or nil
function coffeeInventory.open()
	if coffeeInventory.menuInterface then
		if coffeeInventory.menuInterface:IsVisible() then
			return
		end
	end

	coffeeInventory.removeInvalidItems()
	coffeeInventory.menuInterface = vgui.Create( "coffeeinv_inventory" )
end
net.Receive( "coffeeInv_openInventory", coffeeInventory.open )
hook.Add( "Think", "coffeeInventory_open", function()
	if input.IsKeyDown( coffeeInventory.config.openKey ) then
		if not LocalPlayer():IsTyping() and not gui.IsGameUIVisible() and not vgui.GetKeyboardFocus() then
			coffeeInventory.open()
		end
	end
end )

function coffeeInventory.removeInvalidItems()
	local _x, _y = coffeeInventory.config.xSize, coffeeInventory.config.ySize
	if( coffeeInventory.config.customGroupSizes[ LocalPlayer():GetUserGroup() ] ) then
		_x, _y = coffeeInventory.config.customGroupSizes[ LocalPlayer():GetUserGroup() ].xSize, coffeeInventory.config.customGroupSizes[ LocalPlayer():GetUserGroup() ].ySize
	end
	for x = 1, _y do
		for y = 1, _x do
			if LocalPlayer().coffeeInventory[ x ][ y ] != false then
				if not coffeeInventory.config.items[ LocalPlayer().coffeeInventory[ x ][ y ].class ] then
					LocalPlayer().coffeeInventory[ x ][ y ] = false
				elseif ( LocalPlayer().coffeeInventory[ x ][ y ].amount > coffeeInventory.config.items[ LocalPlayer().coffeeInventory[ x ][ y ].class ].stackSize ) or ( LocalPlayer().coffeeInventory[ x ][ y ].amount < 0 ) then
					LocalPlayer().coffeeInventory[ x ][ y ] = false
				end
			end
		end
	end
end

function coffeeInventory.readPlayerData()
	LocalPlayer().coffeeInventory = net.ReadTable()
	if coffeeInventory.menuInterface then
		if coffeeInventory.menuInterface:IsVisible() then
			coffeeInventory.menuInterface:update()
		end
	end
end
net.Receive( "coffeeInv_playerData", coffeeInventory.readPlayerData )

hook.Add( "PostDrawOpaqueRenderables", "coffeeInventory_storeItemInfo", function()
	for _, e in pairs ( ents.GetAll() ) do
		if e:GetPos():Distance( LocalPlayer():GetPos() ) < coffeeInventory.config.takeDist then
			if coffeeInventory.config.items[ e:GetClass() ] then
				cam.Start3D2D( e:GetPos() + Vector( 0, 0, 7 ), Angle( 0, LocalPlayer():EyeAngles().yaw - 90, 90 ), 0.02 )
					surface.SetDrawColor( Color( 235, 189, 99, 50 ) )
					surface.DrawRect( -100, 0 + math.sin( CurTime() ) * 50, 200, 100 )
					draw.SimpleText( coffeeInventory.config.pickupText, "coffeeinventory_little3d", 0, 30 + math.sin( CurTime() ) * 50, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
					draw.SimpleText( "[Store]", "coffeeinventory_little3d", 0, 70 + math.sin( CurTime() ) * 50, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				cam.End3D2D()
			end
		end
	end
end )
