/*---------------------------------------------------------------------------
	Database
---------------------------------------------------------------------------*/
coffeeInventory.database = {}
function coffeeInventory.database.init()
	if not sql.TableExists( "coffee_inventory" ) then
		sql.Query( "CREATE TABLE coffee_inventory ( id INTEGER, items VARCHAR( 255 ) )" )
	end
end
hook.Add( "Initialize", "coffeeInventory_databaseInit", coffeeInventory.database.init )

function coffeeInventory.database.addPlayerData( ply )
	local emptyInventory = {}

	local _x, _y = coffeeInventory.config.xSize, coffeeInventory.config.ySize
	if( coffeeInventory.config.customGroupSizes[ ply:GetUserGroup() ] ) then
		_x, _y = coffeeInventory.config.customGroupSizes[ ply:GetUserGroup() ].xSize, coffeeInventory.config.customGroupSizes[ ply:GetUserGroup() ].ySize
	end

	for x = 1, _y do
		emptyInventory[ x ] = {}
		for y = 1, _x do
			emptyInventory[ x ][ y ] = false
		end
	end

	sql.Query( "INSERT INTO coffee_inventory ( id, items ) VALUES ( " .. ply:UniqueID() .. ", '" .. util.TableToJSON( emptyInventory ) .. "' )" )
	coffeeInventory.database.fetchPlayerData( ply )
end

function coffeeInventory.database.fetchPlayerData( ply )
	local q = sql.Query( "SELECT items FROM coffee_inventory WHERE id = " .. ply:UniqueID() .. " LIMIT 1" )
	if not q then
		coffeeInventory.database.addPlayerData( ply )
	else
		local _x, _y = coffeeInventory.config.xSize, coffeeInventory.config.ySize
		if( coffeeInventory.config.customGroupSizes[ ply:GetUserGroup() ] ) then
			_x, _y = coffeeInventory.config.customGroupSizes[ ply:GetUserGroup() ].xSize, coffeeInventory.config.customGroupSizes[ ply:GetUserGroup() ].ySize
		end

		local emptyInventory = {}

		for x = 1, _y do
			emptyInventory[ x ] = {}
			for y = 1, _x do
				if( util.JSONToTable( q[1].items )[ x ] && util.JSONToTable( q[1].items )[ x ][ y ] ) then
					emptyInventory[ x ][ y ] = util.JSONToTable( q[1].items )[ x ][ y ]
				else
					emptyInventory[ x ][ y ] = false
				end
			end
		end

		PrintTable( emptyInventory )

		ply.coffeeInventory = table.Copy( emptyInventory )
		coffeeInventory.sendPlayerData( ply )
	end
end

function coffeeInventory.database.savePlayerData( ply )
	coffeeInventory.removeInvalidItems( ply )
	sql.Query( "UPDATE coffee_inventory SET items = '" .. util.TableToJSON( ply.coffeeInventory ) .. "' WHERE id = " .. ply:UniqueID() .. "" )
end

//USE ONLY IF YOU KNOW THAT YOU WANT TO GET RID OF WHOLE DATABASE AS THIS WIPES IT OUT
function coffeeInventory.database.drop( ply, cmd, args )
	if not ply:IsSuperAdmin() then return end
	sql.Query( "DROP TABLE coffee_inventory" )
end
concommand.Add( "coffee_inventory_dropdatabase", coffeeInventory.database.drop )

/*---------------------------------------------------------------------------
	Functionality
---------------------------------------------------------------------------*/
function coffeeInventory.addItem( ply, class, model, amount, data )
	local item = coffeeInventory.getItemEntry( class )
	if coffeeInventory.getFreeSlots( ply, class ) >= 1 then
		local repeats = 0
		while( amount > 0 and repeats < 100 )
		do
			local x, y, space = coffeeInventory.getFreeSlot( ply, class, data, amount )
			if ply.coffeeInventory[ x ][ y ] == false then
				local newItem = {}
				newItem.mdl = model
				newItem.class = class
				newItem.data = data
				newItem.amount = 0
				if amount > coffeeInventory.config.items[ class ].stackSize then
					newItem.amount = coffeeInventory.config.items[ class ].stackSize
					amount = amount - coffeeInventory.config.items[ class ].stackSize
				else
					newItem.amount = amount
					amount = 0
				end
				ply.coffeeInventory[ x ][ y ] = newItem
			else
				ply.coffeeInventory[ x ][ y ].amount = ply.coffeeInventory[ x ][ y ].amount + amount
				amount = 0
				if ply.coffeeInventory[ x ][ y ].amount > coffeeInventory.config.items[ class ].stackSize then
					amount = ply.coffeeInventory[ x ][ y ].amount - coffeeInventory.config.items[ class ].stackSize
					ply.coffeeInventory[ x ][ y ].amount = coffeeInventory.config.items[ class ].stackSize
				end
			end
			repeats = repeats + 1
		end
	end
	coffeeInventory.sendPlayerData( ply )
	coffeeInventory.database.savePlayerData( ply )
end

function coffeeInventory.removeItem( ply, itemPos, amount )
	local x, y = itemPos[1], itemPos[2]
	if ply.coffeeInventory[ x ][ y ] != false then
		ply.coffeeInventory[ x ][ y ].amount = ply.coffeeInventory[ x ][ y ].amount - amount or ply.coffeeInventory[ x ][ y ].amount
		if ply.coffeeInventory[ x ][ y ].amount == 0 then
			ply.coffeeInventory[ x ][ y ] = false
		end
	end
end

function coffeeInventory.storeItem( ply, ent )
	if coffeeInventory.isItem( ent ) then
		local item = coffeeInventory.getItemEntry( ent:GetClass() )
		if coffeeInventory.getFreeSlots( ply, class ) > 1 then
			local data = {}
			if item.vars then
				for _, var in pairs ( item.vars ) do
					data[ var ] = ent[ var ] or ent.dt[var ]
				end
			end
			coffeeInventory.addItem( ply, ent:GetClass(), ent:GetModel(), item.fetchAmount( ent ) or 1, data )
			ent:Remove()
		end
	end
end
hook.Add( "KeyPress", "coffeeInventory_storeItem", function( ply, key )
	if key == coffeeInventory.config.pickupKey1 and ply:KeyDown( coffeeInventory.config.pickupKey2 ) then
		if ply:GetEyeTrace().Entity:GetPos():Distance( ply:GetPos() ) < coffeeInventory.config.takeDist then
			coffeeInventory.storeItem( ply, ply:GetEyeTrace().Entity, 1 )
		end
	end
end )

function coffeeInventory.removeInvalidItems( ply )
	local _x, _y = coffeeInventory.config.xSize, coffeeInventory.config.ySize
	if( coffeeInventory.config.customGroupSizes[ ply:GetUserGroup() ] ) then
		_x, _y = coffeeInventory.config.customGroupSizes[ ply:GetUserGroup() ].xSize, coffeeInventory.config.customGroupSizes[ ply:GetUserGroup() ].ySize
	end
	for x = 1, _y do
		for y = 1, _x do
			if ply.coffeeInventory[ x ][ y ] != false then
				if not coffeeInventory.config.items[ ply.coffeeInventory[ x ][ y ].class ] then
					ply.coffeeInventory[ x ][ y ] = false
				elseif ( ply.coffeeInventory[ x ][ y ].amount > coffeeInventory.config.items[ ply.coffeeInventory[ x ][ y ].class ].stackSize ) or ( ply.coffeeInventory[ x ][ y ].amount < 0 ) then
					ply.coffeeInventory[ x ][ y ] = false
				end
			end
		end
	end
end

util.AddNetworkString( "coffeeInv_dropStack" )
function coffeeInventory.dropStack( ply, itemPos )
	local x, y = itemPos[1], itemPos[2]
	if ply.coffeeInventory[ x ][ y ] == false then
		return
	end

	local pack = ents.Create( "coffeeinventory_package" )
	pack:SetPos( LocalToWorld( Vector( 50, 0, 35 ), Angle( 0, 0, 0 ), ply:GetPos(), ply:GetAngles() ) )
	pack:Spawn()
	pack.item = ply.coffeeInventory[ x ][ y ]
	pack:sendData()

	ply.coffeeInventory[ x ][ y ] = false

	coffeeInventory.sendPlayerData( ply )
	coffeeInventory.database.savePlayerData( ply )
end
net.Receive( "coffeeInv_dropStack", function( lenght, ply )
	coffeeInventory.dropStack( ply, net.ReadTable() )
end )

function coffeeInventory.hasMatchingData( class, data1, data2 )
	if coffeeInventory.config.items[ class ].vars then
		for var, value in pairs ( data1 ) do
			if data2[ var ] != value then
				return false
			end
		end
	end
	return true
end

util.AddNetworkString( "coffeeInv_dropItem" )
function coffeeInventory.dropItem( ply, itemPos )
	local x, y = itemPos[1], itemPos[2]
	local itemData = coffeeInventory.getItemEntry( ply.coffeeInventory[ x ][ y ].class )
	local item = ply.coffeeInventory[ x ][ y ]

	local ent = ents.Create( item.class )
	ent:SetPos( LocalToWorld( Vector( 50, 0, 35 ), Angle( 0, 0, 0 ), ply:GetPos(), ply:GetAngles() ) )
	ent:SetModel( item.mdl )

	for var, value in pairs ( item.data ) do
		ent[ var ] = value
		ent.dt[ var ] = value
	end
	ply.coffeeInventory[ x ][ y ].amount = ply.coffeeInventory[ x ][ y ].amount - 1
	if ply.coffeeInventory[ x ][ y ].amount <= 0 then
		ply.coffeeInventory[ x ][ y ] = false
	end
	ent:Spawn()

	coffeeInventory.sendPlayerData( ply )
	coffeeInventory.database.savePlayerData( ply )
end
net.Receive( "coffeeInv_dropItem", function( lenght, ply )
	local pos = net.ReadTable()
	coffeeInventory.dropItem( ply, pos )
end )

util.AddNetworkString( "coffeeInv_useItem" )
function coffeeInventory.useItem( ply, itemPos )
	local x, y = itemPos[1], itemPos[2]
	local itemData = coffeeInventory.getItemEntry( ply.coffeeInventory[ x ][ y ].class )
	if itemData.useFunc then
		ply.coffeeInventory[ x ][ y ].amount = ply.coffeeInventory[ x ][ y ].amount - 1
		itemData.useFunc( ply, ply.coffeeInventory[ x ][ y ] )
		if ply.coffeeInventory[ x ][ y ].amount <= 0 then
			ply.coffeeInventory[ x ][ y ] = false
		end
		coffeeInventory.sendPlayerData( ply )
	end
	coffeeInventory.database.savePlayerData( ply )
end
net.Receive( "coffeeInv_useItem", function( lenght, ply )
	local pos = net.ReadTable()
	coffeeInventory.useItem( ply, pos )
end )

util.AddNetworkString( "coffeeInv_moveItem" )
function coffeeInventory.moveItem( ply, fromPos, toPos )
	local x, y = fromPos[1], fromPos[2]
	local nx, ny = toPos[1], toPos[2]

	if x == nx and y == ny then return end

	if ply.coffeeInventory[ x ][ y ] == false then
		return
	end

	if ply.coffeeInventory[ nx ][ ny ] == false then
		ply.coffeeInventory[ nx ][ ny ] = table.Copy( ply.coffeeInventory[ x ][ y ] )
		ply.coffeeInventory[ nx ][ ny ].amount = 1
		ply.coffeeInventory[ x ][ y ].amount = ply.coffeeInventory[ x ][ y ].amount - 1
		if ply.coffeeInventory[ x ][ y ].amount <= 0 then
			ply.coffeeInventory[ x ][ y ] = false
		end
	else
		if ply.coffeeInventory[ nx ][ ny ].class == ply.coffeeInventory[ x ][ y ].class and coffeeInventory.hasMatchingData( ply.coffeeInventory[ x ][ y ].class, ply.coffeeInventory[ x ][ y ].data, ply.coffeeInventory[ nx ][ ny ].data ) then
			if ply.coffeeInventory[ nx ][ ny ].amount < coffeeInventory.config.items[ ply.coffeeInventory[ nx ][ ny ].class ].stackSize then
				ply.coffeeInventory[ nx ][ ny ].amount = ply.coffeeInventory[ nx ][ ny ].amount + 1
				ply.coffeeInventory[ x ][ y ].amount = ply.coffeeInventory[ x ][ y ].amount - 1
				if ply.coffeeInventory[ x ][ y ].amount <= 0 then
					ply.coffeeInventory[ x ][ y ] = false
				end
			end
		end
	end

	coffeeInventory.sendPlayerData( ply )
	coffeeInventory.database.savePlayerData( ply )
end
net.Receive( "coffeeInv_moveItem", function( lenght, ply )
	local pos = net.ReadTable()
	coffeeInventory.moveItem( ply, pos[1], pos[2] )
end )

util.AddNetworkString( "coffeeInv_moveStack" )
function coffeeInventory.moveStack( ply, fromPos, toPos )
	local x, y = fromPos[1], fromPos[2]
	local nx, ny = toPos[1], toPos[2]

	if x == nx and y == ny then return end

	if ply.coffeeInventory[ x ][ y ] == false then
		return
	end

	if ply.coffeeInventory[ nx ][ ny ] == false then
		ply.coffeeInventory[ nx ][ ny ] = ply.coffeeInventory[ x ][ y ]
		ply.coffeeInventory[ x ][ y ] = false
	else
		if ply.coffeeInventory[ nx ][ ny ].class == ply.coffeeInventory[ x ][ y ].class and coffeeInventory.hasMatchingData( ply.coffeeInventory[ x ][ y ].class, ply.coffeeInventory[ x ][ y ].data, ply.coffeeInventory[ nx ][ ny ].data ) then
			ply.coffeeInventory[ nx ][ ny ].amount = ply.coffeeInventory[ nx ][ ny ].amount + ply.coffeeInventory[ x ][ y ].amount
			if ply.coffeeInventory[ nx ][ ny ].amount > coffeeInventory.config.items[ ply.coffeeInventory[ nx ][ ny ].class ].stackSize then
				ply.coffeeInventory[ x ][ y ].amount = ply.coffeeInventory[ nx ][ ny ].amount - coffeeInventory.config.items[ ply.coffeeInventory[ nx ][ ny ].class ].stackSize
				ply.coffeeInventory[ nx ][ ny ].amount = coffeeInventory.config.items[ ply.coffeeInventory[ nx ][ ny ].class ].stackSize
			else
				ply.coffeeInventory[ x ][ y ] = false
			end
		else
			local oldItem = ply.coffeeInventory[ nx ][ ny ]
			ply.coffeeInventory[ nx ][ ny ] = ply.coffeeInventory[ x ][ y ]
			ply.coffeeInventory[ x ][ y ] = oldItem
		end
	end
	coffeeInventory.sendPlayerData( ply )
	coffeeInventory.database.savePlayerData( ply )
end
net.Receive( "coffeeInv_moveStack", function( lenght, ply )
	local pos = net.ReadTable()
	coffeeInventory.moveStack( ply, pos[1], pos[2] )
end )

util.AddNetworkString( "coffeeInv_openInventory" )
function coffeeInventory.open( ply )
	coffeeInventory.removeInvalidItems( ply )
	coffeeInventory.sendPlayerData( ply )
	net.Start( "coffeeInv_openInventory" )
	net.Send( ply )
end

function coffeeInventory.isItem( ent )
	if coffeeInventory.config.items[ ent:GetClass() ] then
		return true
	else
		return false
	end
end

function coffeeInventory.hasItem( ply, itemClass )
	local inventory = coffeeInventory.getInventory( ply )
	local _x, _y = coffeeInventory.config.xSize, coffeeInventory.config.ySize
	if( coffeeInventory.config.customGroupSizes[ ply:GetUserGroup() ] ) then
		_x, _y = coffeeInventory.config.customGroupSizes[ ply:GetUserGroup() ].xSize, coffeeInventory.config.customGroupSizes[ ply:GetUserGroup() ].ySize
	end
	for x = 1, _y do
		for y = 1, _x do
			if inventory[ x ][ y ] != false then
				if inventory[ x ][ y ].class == itemClass then
					return true
				end
			end
		end
	end
	return false
end

function coffeeInventory.getInventory( ply )
	return ply.coffeeInventory
end

function coffeeInventory.getItemEntry( class )
	return coffeeInventory.config.items[ class ] or false
end

function coffeeInventory.getFreeSlots( ply, class, data )
	local space = 0
	local _x, _y = coffeeInventory.config.xSize, coffeeInventory.config.ySize
	if( coffeeInventory.config.customGroupSizes[ ply:GetUserGroup() ] ) then
		_x, _y = coffeeInventory.config.customGroupSizes[ ply:GetUserGroup() ].xSize, coffeeInventory.config.customGroupSizes[ ply:GetUserGroup() ].ySize
	end
	for x = 1, _y do
		for y = 1, _x do
			if ply.coffeeInventory[ x ][ y ] == false then
				space = space + 1
			else
				if class then
					if ply.coffeeInventory[ x ][ y ].class == class and ply.coffeeInventory[ x ][ y ].amount < coffeeInventory.config.items[ class ].stackSize then
						if data then
							if coffeeInventory.hasMatchingData( class, data, ply.coffeeInventory[ x ][ y ].data ) then
								space = space + 1
							end
						else
							space = space + 1
						end
					end
				end
			end
		end
	end
	return space
end

function coffeeInventory.getFreeSlot( ply, class, data, amount )
	//Check for items without full stacks first
	local _x, _y = coffeeInventory.config.xSize, coffeeInventory.config.ySize
	if( coffeeInventory.config.customGroupSizes[ ply:GetUserGroup() ] ) then
		_x, _y = coffeeInventory.config.customGroupSizes[ ply:GetUserGroup() ].xSize, coffeeInventory.config.customGroupSizes[ ply:GetUserGroup() ].ySize
	end
	for x = 1, _y do
		for y = 1, _x do
			if ply.coffeeInventory[ x ][ y ] != false then
				if ply.coffeeInventory[ x ][ y ].class == class then
					if coffeeInventory.config.items[ class ].stackSize - ply.coffeeInventory[ x ][ y ].amount > 0 then
						if coffeeInventory.hasMatchingData( class, ply.coffeeInventory[ x ][ y ].data, data ) then
							return x, y, coffeeInventory.config.items[ class ].stackSize - ply.coffeeInventory[ x ][ y ].amount
						end
					end
				end
			end
		end
	end
	//Check for empty slots
	for x = 1, _y do
		for y = 1, _x do
			if ply.coffeeInventory[ x ][ y ] == false then
				return x, y, coffeeInventory.config.items[ class ].stackSize
			end
		end
	end
	return false
end

function coffeeInventory.getItemCount( ply, class, data )
	local amount = 0
	local _x, _y = coffeeInventory.config.xSize, coffeeInventory.config.ySize
	if( coffeeInventory.config.customGroupSizes[ ply:GetUserGroup() ] ) then
		_x, _y = coffeeInventory.config.customGroupSizes[ ply:GetUserGroup() ].xSize, coffeeInventory.config.customGroupSizes[ ply:GetUserGroup() ].ySize
	end
	for x = 1, _y do
		for y = 1, _x do
			if ply.coffeeInventory[ x ][ y ] != false then
				if ply.coffeeInventory[ x ][ y ].class == class then
					if coffeeInventory.hasMatchingData( class, data, ply.coffeeInventory[ x ][ y ].data ) then
						amount = amount + ply.coffeeInventory[ x ][ y ].amount
					end
				end
			end
		end
	end
	return amount
end

function coffeeInventory.initPlayerData( ply )
	ply.coffeeInventory = {}
	local _x, _y = coffeeInventory.config.xSize, coffeeInventory.config.ySize
	if( coffeeInventory.config.customGroupSizes[ ply:GetUserGroup() ] ) then
		_x, _y = coffeeInventory.config.customGroupSizes[ ply:GetUserGroup() ].xSize, coffeeInventory.config.customGroupSizes[ ply:GetUserGroup() ].ySize
	end
	for x = 1, _y do
		ply.coffeeInventory[ x ] = {}
		for y = 1, _x do
			ply.coffeeInventory[ x ][ y ] = false
		end
	end
	coffeeInventory.sendPlayerData( ply ) -- Send empty table first

	timer.Simple( 5, function()
		coffeeInventory.database.fetchPlayerData( ply ) -- Send fetched data after 5 seconds
	end )
end
hook.Add( "PlayerInitialSpawn", "coffeeInventory_initPlayerData", coffeeInventory.initPlayerData )

util.AddNetworkString( "coffeeInv_playerData" )
function coffeeInventory.sendPlayerData( ply )
	net.Start( "coffeeInv_playerData" )
		net.WriteTable( ply.coffeeInventory )
	net.Send( ply )
end
/*---------------------------------------------------------------------------
	Meta-functions, for easier access or mods
---------------------------------------------------------------------------*/
local person = FindMetaTable( "Player" )

function person:addItem( class, model, amount, data )
	coffeeInventory.addItem( self, class, model, amount, data )
end

function person:removeItem( itemPos, amount )
	coffeeInventory.removeItem( self, itemPos, amount )
end

function person:storeItem()
	coffeeInventory.storeItem( self, ent )
end

function person:dropStack( itemPos )
	coffeeInventory.dropStack( self, itemPos )
end

function person:dropItem( itemPos )
	coffeeInventory.dropItem( self, itemPos )
end

function person:useItem( itemPos )
	coffeeInventory.useItem( self, itemPos )
end

function person:moveItem( fromPos, toPos )
	coffeeInventory.moveItem( self, fromPos, toPos )
end

function person:moveStack( fromPos, toPos )
	coffeeInventory.moveStack( self, fromPos, toPos )
end

function person:openInventory()
	coffeeInventory.open( self )
end

function person:getFreeSlots( class )
	return coffeeInventory.getFreeSlots( self, class )
end

function person:getFreeSlot( class, data, amount )
	return coffeeInventory.getFreeSlot( self, class, data, amount )
end

function person:getInventory()
	return coffeeInventory.getInventory( self )
end

hook.Add( "PlayerSay", "coffeeinv_holsterweapon", function( ply, text )
	if string.lower( text ) == "/holster" then
		if coffeeInventory.config.nonHolsterableWeapons[ ply:GetActiveWeapon():GetClass() ] then
			return false
		end
		coffeeInventory.addItem( ply, "spawned_weapon", ply:GetActiveWeapon().WorldModel, 1, { WeaponClass = ply:GetActiveWeapon():GetClass() } )
		ply:StripWeapon( ply:GetActiveWeapon():GetClass() )
		return false
	end
end )
