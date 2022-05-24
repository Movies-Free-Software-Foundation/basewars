/*---------------------------------------------------------------------------
	Frame
---------------------------------------------------------------------------*/
local PANEL = {}
function PANEL:Init()
	self:SetSize( 200, 100 )
	self:Center()
	self.title = "coffeeinv_frame"
	self.theme = coffeeInventory.config.themes[ coffeeInventory.config.theme ]
end

function PANEL:Paint( w, h )
	//Background
	draw.RoundedBox( 0, 0, 0, w, h, Color( self.theme.frameBackground.r - 20, self.theme.frameBackground.g - 20, self.theme.frameBackground.b - 20, self.theme.frameBackground.a or 255 ) )
	draw.RoundedBox( 0, 1, 1, w - 2, h - 2, self.theme.frameBackground )
	draw.RoundedBox( 0, 2, 2, w - 4, h - 4, Color( self.theme.frameBackground.r - 10, self.theme.frameBackground.g - 10, self.theme.frameBackground.b - 10, self.theme.frameBackground.a or 255 ) )
	//Bar
	draw.RoundedBox( 0, 0, 0, w, 16, self.theme.frameBar )
	draw.RoundedBox( 0, 0, 16, w, 4, Color( self.theme.frameBar.r - 50, self.theme.frameBar.g - 50, self.theme.frameBar.b - 50, self.theme.frameBackground.a or 255 ) )
	//Title
	draw.SimpleText( self.title, "coffeeinventory_little", w / 2, 8, self.theme.titleText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
end

function PANEL:setTitle( text )
	self.title = text
end

function PANEL:addCloseButton()
	self.closeButton = vgui.Create( "coffeeinv_textButton", self )
	self.closeButton:SetSize( 20, 20 )
	self.closeButton:SetPos( self:GetWide() - 25, 0 )
	self.closeButton:setText( "X" )
	self.closeButton.OnMousePressed = function()
		surface.PlaySound( "buttons/button14.wav" )
		self:Remove()
	end
end
vgui.Register( "coffeeinv_frame", PANEL, "EditablePanel" )
/*---------------------------------------------------------------------------
	Button
---------------------------------------------------------------------------*/
local PANEL = {}
function PANEL:Init()
	self:SetSize( 50, 20 )
	self:Center()
	self.text = "coffeeinv_textButton"
	self.color = Color( 235, 99, 97 )
	self.theme = coffeeInventory.config.themes[ coffeeInventory.config.theme ]
end

function PANEL:OnCursorEntered()
	self:SetCursor( "hand" )
end

function PANEL:OnCursorExited()
	self:SetCursor( "arrow" )
end

function PANEL:setText( text )
	self.text = text
end

function PANEL:setColor( color )
	self.color = color
end

function PANEL:Paint( w, h )
	draw.RoundedBox( 0, 0, 0, w, h, self.color )
	draw.RoundedBox( 0, 0, h - 4, w, 4, Color( self.color.r - 50, self.color.g - 50, self.color.b - 50, self.color.a or 255 ) )
	draw.SimpleText( self.text, "coffeeinventory_little", w / 2, ( h - 4 ) * 0.5, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
end
vgui.Register( "coffeeinv_textButton", PANEL, "EditablePanel" )
/*---------------------------------------------------------------------------
	Panel
---------------------------------------------------------------------------*/
local PANEL = {}
function PANEL:Init()
	self:SetSize( 200, 100 )
	self.theme = coffeeInventory.config.themes[ coffeeInventory.config.theme ]
end

function PANEL:Paint( w, h )
	draw.RoundedBox( 0, 0, 0, w, h, Color( self.theme.panelBackground.r - 20, self.theme.panelBackground.g - 20, self.theme.panelBackground.b - 20, self.theme.panelBackground.a or 255 ) )
	draw.RoundedBox( 0, 1, 1, w - 2, h - 2, self.theme.panelBackground )
	draw.RoundedBox( 0, 2, 2, w - 4, h - 4, Color( self.theme.panelBackground.r - 10, self.theme.panelBackground.g - 10, self.theme.panelBackground.b - 10, self.theme.panelBackground.a or 255 ) )
end
vgui.Register( "coffeeinv_panel", PANEL, "EditablePanel" )
/*---------------------------------------------------------------------------
	Inventory
---------------------------------------------------------------------------*/
local PANEL = {}
function PANEL:Init()
	self:SetSize( 441, 390 )
	self:Center()
	self:setTitle( "Inventory" )
	self:addCloseButton()
	self:MakePopup()
	self.theme = coffeeInventory.config.themes[ coffeeInventory.config.theme ]

	self.modelPanel = vgui.Create( "coffeeinv_panel", self )
	self.modelPanel:SetSize( 210, 362 )
	self.modelPanel:SetPos( self:GetWide() - self.modelPanel:GetWide() - 4, 24 )

	self.playerModel = vgui.Create( "DModelPanel", self.modelPanel )
	self.playerModel:SetSize( self.modelPanel:GetWide(), self.modelPanel:GetTall() )
	self.playerModel:SetModel( LocalPlayer():GetModel() )
	self.playerModel:SetCamPos( Vector( 105, 0, 35 ) )
	self.playerModel:SetLookAt( Vector( 0, 0, 35 ) )
	self.playerModel:SetFOV( 25 )
	self.playerModel:SetTooltip( "You sexy beast!" )
	self.playerModel.Entity:SetEyeTarget( Vector( 200, 0, 75 ) )
	self.playerModel:SetDirectionalLight( BOX_FRONT, Color( 255, 255, 255 ) )

	self.useItemPanel = vgui.Create( "DPanel", self.playerModel )
	self.useItemPanel:SetSize( 210, 20 )
	self.useItemPanel:SetPos( 0, 0 )
	self.useItemPanel.Paint = function( w, h )
		if dragndrop.IsDragging() then
			surface.SetDrawColor( Color( 108, 135, 132 ) )
			surface.DrawRect( 0, 0, 210, 20 )
			draw.SimpleText( "Use Item", "coffeeinventory_tiny", 105, 10, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
	end
	self.useItemPanel:Receiver( "coffeeInventory_droppable", function( receiver, droppedPanels, isDropped, menuIndex, cursorx, cursory )
		if not isDropped then return end
		local x, y = droppedPanels[1]:GetParent().itemPos[1], droppedPanels[1]:GetParent().itemPos[2]
		net.Start( "coffeeInv_useItem" )
			net.WriteTable( { x, y } )
		net.SendToServer()
		surface.PlaySound( "buttons/lightswitch2.wav" )
	end )

	self.dropItemPanel = vgui.Create( "DPanel", self.playerModel )
	self.dropItemPanel:SetSize( 210, 20 )
	self.dropItemPanel:SetPos( 0, 342 )
	self.dropItemPanel.Paint = function( w, h )
		if dragndrop.IsDragging() then
			surface.SetDrawColor( Color( 235, 99, 97 ) )
			surface.DrawRect( 0, 0, 210, 20 )
			draw.SimpleText( "Drop Item", "coffeeinventory_tiny", 105, 10, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
	end
	self.dropItemPanel:Receiver( "coffeeInventory_droppable", function( receiver, droppedPanels, isDropped, menuIndex, cursorx, cursory )
		if not isDropped then return end
		local x, y = droppedPanels[1]:GetParent().itemPos[1], droppedPanels[1]:GetParent().itemPos[2]
		if input.IsKeyDown( KEY_LALT ) then
			net.Start( "coffeeInv_dropStack" )
				net.WriteTable( { x, y } )
			net.SendToServer()
		else
			net.Start( "coffeeInv_dropItem" )
				net.WriteTable( { x, y } )
			net.SendToServer()
		end
		surface.PlaySound( "buttons/lightswitch2.wav" )
	end )


	self.playerModel.LayoutEntity = function()
		return false
	end

	self.itemPanel = vgui.Create( "coffeeinv_panel", self )
	self.itemPanel:SetSize( 220, 362 )
	self.itemPanel:SetPos( 4, 24 )

	self.itemScrollPanel = vgui.Create( "DScrollPanel", self.itemPanel )
	self.itemScrollPanel:SetSize( 220, 362 )
	self.itemScrollPanel:SetPos( 0, 0 )

	self.itemScrollPanel.OnMouseWheeled = function( scrollPanel, dlta )
		scrollPanel:GetVBar():AddScroll( dlta * -0.7 )
	end

	self.itemScrollPanel:GetVBar():SetWide( 10 )
	self.itemScrollPanel:GetVBar().Paint = function()
		draw.RoundedBox( 0, 0, 0, self.itemScrollPanel:GetVBar():GetWide(), self.itemScrollPanel:GetVBar():GetTall(), Color( self.theme.gripBar.r - 50, self.theme.gripBar.g - 50, self.theme.gripBar.b - 50, self.theme.gripBar.a or 255 ) )
	end
	self.itemScrollPanel:GetVBar().btnGrip.Paint = function()
		draw.RoundedBox( 0, 2, 2, self.itemScrollPanel:GetVBar().btnGrip:GetWide() - 4, self.itemScrollPanel:GetVBar().btnGrip:GetTall() - 4, self.theme.gripBar )
	end
	self.itemScrollPanel:GetVBar().btnUp.Paint = function()
		draw.RoundedBox( 0, 0, 0, self.itemScrollPanel:GetVBar().btnDown:GetWide(), self.itemScrollPanel:GetVBar().btnDown:GetTall(), Color( self.theme.gripBtn.r - 50, self.theme.gripBtn.g - 50, self.theme.gripBtn.b - 50, self.theme.gripBtn.a or 255 ) )
		draw.RoundedBox( 0, 1, 1, self.itemScrollPanel:GetVBar().btnDown:GetWide() - 2, self.itemScrollPanel:GetVBar().btnDown:GetTall() - 2, self.theme.gripBtn )
	end
	self.itemScrollPanel:GetVBar().btnDown.Paint = function()
		draw.RoundedBox( 0, 0, 0, self.itemScrollPanel:GetVBar().btnDown:GetWide(), self.itemScrollPanel:GetVBar().btnDown:GetTall(), Color( self.theme.gripBtn.r - 50, self.theme.gripBtn.g - 50, self.theme.gripBtn.b - 50, self.theme.gripBtn.a or 255 ) )
		draw.RoundedBox( 0, 1, 1, self.itemScrollPanel:GetVBar().btnDown:GetWide() - 2, self.itemScrollPanel:GetVBar().btnDown:GetTall() - 2, self.theme.gripBtn )
	end

	self.itemListPanel = vgui.Create( "DIconLayout", self.itemScrollPanel )
	self.itemListPanel:SetSize( 212, 362 )
	self.itemListPanel:SetPos( 0, 0 )
	self.itemListPanel:SetSpaceY( 2 )
	self.itemListPanel:SetSpaceX( 2 )

	self:update()
end

function PANEL:update()
	if not LocalPlayer().coffeeInventory then return end

	for _, slot in pairs ( self.itemListPanel:GetChildren() ) do
		slot:Remove()
	end

	local _x, _y = coffeeInventory.config.xSize, coffeeInventory.config.ySize
	if( coffeeInventory.config.customGroupSizes[ LocalPlayer():GetNWString("usergroup") ] ) then
		_x, _y = coffeeInventory.config.customGroupSizes[ LocalPlayer():GetNWString("usergroup") ].xSize, coffeeInventory.config.customGroupSizes[ LocalPlayer():GetNWString("usergroup") ].ySize
	end

	for x = 1, _y do
		for y = 1, _x do
			local slot = vgui.Create( "coffeeinv_panel", self.itemListPanel )
			slot:SetSize( 50, 50 )
			slot.itemPos = { x, y }
			slot:Receiver( "coffeeInventory_droppable", function( receiver, droppedPanels, isDropped, menuIndex, cursorx, cursory )
				if not isDropped then return end
				local ox, oy, nx, ny = droppedPanels[1]:GetParent().itemPos[1], droppedPanels[1]:GetParent().itemPos[2], receiver.itemPos[1], receiver.itemPos[2]

				//Actual data changes
				if input.IsKeyDown( KEY_LSHIFT ) then
					net.Start( "coffeeInv_moveItem" )
						net.WriteTable( { droppedPanels[1]:GetParent().itemPos, receiver.itemPos } )
					net.SendToServer()
				else
					net.Start( "coffeeInv_moveStack" )
						net.WriteTable( { droppedPanels[1]:GetParent().itemPos, receiver.itemPos } )
					net.SendToServer()
				end
				surface.PlaySound( "buttons/lever7.wav" )
			end )

			if LocalPlayer().coffeeInventory[ x ][ y ] != false then
				local item = LocalPlayer().coffeeInventory[ x ][ y ]
				local itemModel = vgui.Create( "DModelPanel", slot )
				itemModel.amount = item.amount
				itemModel:SetSize( 50, 50 )
				itemModel:SetModel( item.mdl )
				itemModel:SetDirectionalLight( BOX_RIGHT, Color( 255, 255, 255 ) )
				itemModel:Droppable( "coffeeInventory_droppable" )
				itemModel:SetTooltip( "Name: " .. ( coffeeInventory.config.items[ item.class ].fetchName( item.data ) or coffeeInventory.config.items[ item.class ].name ) .. "\nDescription: " .. coffeeInventory.config.items[ item.class ].description )

				local mn, mx = itemModel.Entity:GetRenderBounds()
				local size = 0
				size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
				size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
				size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )

				itemModel:SetFOV( 45 )

				itemModel:SetCamPos( Vector( size, size, size ) )
				itemModel:SetLookAt( (mn + mx) * 0.5 )
				itemModel.LayoutEntity = function()
					return false
				end

				itemModel.PaintOver = function( w, h )
					draw.SimpleText( itemModel.amount, "coffeeinventory_tiny", 3, 36, self.theme.itemHover, TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT )
					if itemModel:IsHovered() then
						surface.SetDrawColor( self.theme.itemAmount )
						surface.DrawOutlinedRect( 1, 1, 48, 48 )
					end
				end
			end
			self.itemListPanel:Add( slot )
		end
	end
end
vgui.Register( "coffeeinv_inventory", PANEL, "coffeeinv_frame" )
