coffeeInventory.config = {}
coffeeInventory.config.items = {}
coffeeInventory.config.themes = {}
coffeeInventory.config.language = {}

function coffeeInventory.config.addItem( item )
	local itemClass = item.class
	item.fetchName = item.fetchName or function() return false end
	item.fetchAmount = item.fetchAmount or function() return false end
	item.useFunc = item.useFunc or false
	coffeeInventory.config.items[ itemClass ] = item
end

/*---------------------------------------------------------------------------


						Don't modify anything above!


---------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------
	Config vars
---------------------------------------------------------------------------*/
coffeeInventory.config.xSize = 4				-- Amount of columns, leave this at 4 unless you want your inventory to mess up
coffeeInventory.config.ySize = 10				-- Amount of rows
coffeeInventory.config.customGroupSizes =
{
	eyboss = { xSize = 4, ySize = 400 },
	forhorde = { xSize = 4, ySize = 2 },
}
coffeeInventory.config.takeDist = 100			-- Maxium distance at which you can pickup items
coffeeInventory.config.theme = "coffeeBean" 	-- Name of the theme you want to use, see below if you want to create your own!
coffeeInventory.config.openKey = KEY_I			-- List of possible key choices: http://wiki.garrysmod.com/page/Enums/KEY
coffeeInventory.config.pickupKey1 = IN_RELOAD	-- List of possible key choices: http://wiki.garrysmod.com/page/Enums/IN
coffeeInventory.config.pickupKey2 = IN_WALK
coffeeInventory.config.pickupText = "ALT + R"
coffeeInventory.config.nonHolsterableWeapons =
{
	keys = true,
	gmod_tool = true,
	weapon_physcannon = true,
	weapon_physgun = true,
	pocket = true,
	arrest_stick = true,
	unarrest_stick = true,
	weaponchecker = true,
	gmod_camera = true,
	door_ram = true
} -- Items you can't holster using /holster chat command
/*---------------------------------------------------------------------------
	Themes
---------------------------------------------------------------------------*/
coffeeInventory.config.themes[ "custom" ] =
{
	titleText			= Color( 0, 0, 0 ),
	frameBar 			= Color( 0, 0, 0 ),
	frameBackground		= Color( 0, 0, 0 ),
	panelBackground		= Color( 0, 0, 0 ),
	gripBtn				= Color( 0, 0, 0 ),
	gripBar				= Color( 0, 0, 0 ),
	itemHover			= Color( 0, 0, 0 ),
	itemAmount			= Color( 0, 0, 0 ),
}

coffeeInventory.config.themes[ "hotMocca" ] =
{
	titleText			= Color( 255, 214, 170 ),
	frameBar 			= Color( 36, 35, 33 ),
	frameBackground		= Color( 57, 46, 42 ),
	panelBackground		= Color( 57, 46, 42 ),
	gripBtn				= Color( 255, 214, 170 ),
	gripBar				= Color( 255, 214, 170 ),
	itemHover			= Color( 255, 214, 170 ),
	itemAmount			= Color( 255, 214, 170 ),
}

coffeeInventory.config.themes[ "elegantGrey" ] =
{
	titleText			= Color( 255, 255, 255 ),
	frameBar 			= Color( 0, 223, 252 ),
	frameBackground		= Color( 55, 55, 55 ),
	panelBackground		= Color( 55, 55, 55 ),
	gripBtn				= Color( 0, 223, 252 ),
	gripBar				= Color( 0, 223, 252 ),
	itemHover			= Color( 0, 223, 252 ),
	itemAmount			= Color( 0, 223, 252 ),
}

coffeeInventory.config.themes[ "fusionPalette" ] =
{
	titleText			= Color( 28, 32, 36 ),
	frameBar 			= Color( 199, 244, 100 ),
	frameBackground		= Color( 39, 49, 59 ),
	panelBackground		= Color( 39, 49, 59 ),
	gripBtn				= Color( 217, 91, 67 ),
	gripBar				= Color( 217, 91, 67 ),
	itemHover			= Color( 217, 91, 67 ),
	itemAmount			= Color( 217, 91, 67 ),
}

coffeeInventory.config.themes[ "toxicSkeleton" ] =
{
	titleText			= Color( 255, 255, 255 ),
	frameBar 			= Color( 192, 210, 62 ),
	frameBackground		= Color( 92, 50, 62 ),
	panelBackground		= Color( 92, 50, 62 ),
	gripBtn				= Color( 192, 210, 62 ),
	gripBar				= Color( 192, 210, 62 ),
	itemHover			= Color( 192, 210, 62 ),
	itemAmount			= Color( 192, 210, 62 ),
}

coffeeInventory.config.themes[ "coffeeBean" ] =
{
	titleText			= Color( 255, 255, 255, 255 ),
	frameBar 			= Color( 235, 189, 99, 255 ),
	frameBackground		= Color( 79, 64, 56, 255 ),
	panelBackground		= Color( 79, 64, 56, 255 ),
	gripBtn				= Color( 235, 189, 99, 255 ),
	gripBar				= Color( 235, 189, 99, 255 ),
	itemHover			= Color( 235, 189, 99, 255 ),
	itemAmount			= Color( 235, 189, 99, 255 ),
}
/*---------------------------------------------------------------------------
	Language tables
---------------------------------------------------------------------------*/
coffeeInventory.config.language[ "weaponNames" ] =
{
	weapon_mp52 = "MP5",
	weapon_ak472 = "AK47",
	lockpick = "Lockpick",
	ls_sniper = "Silenced Sniper",
	med_kit = "Med Kit",
	weapon_deagle2 = "Desert Eagle",
	weapon_fiveseven2 = "Five Seven",
	weapon_glock2 = "Glock",
	weapon_m42 = "M4",
	weapon_mac102 = "MAC10",
	weapon_p2282 = "P228",
	weapon_pumpshotgun2 = "Pump Shotgun",
}
/*---------------------------------------------------------------------------
	Item config
---------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------
	Example:

		[SIMPLE, FOR PEOPLE WITHOUT LUA KNOWLEDGE]:
	local item = {}
	item.name = "" 							-- Name of your item
	item.description = ""					-- It's description
	item.class = ""							-- Class of stored entity
	item.stackSize = 0						-- Maximum amount of items in a stack

		[FOR CODERS]
	local item = {}
	item.name = "" 							-- Name of your item
	item.description = ""					-- It's description
	item.class = ""							-- Class of stored entity
	item.stackSize = 0						-- Maximum amount of items in a stack
	item.vars = {}							-- Vars to store

		[ADDITIONALS FOR CODERS, ONLY USE IF YOU KNOW HOW TO]
	item.useFunc = function( ply, itemData )			-- What to do when item is dropped on players model
	end

	item.fetchAmount = function( ent )		-- Something to get the amount from, for example: if you got spawned_weapon, you can return it's count to override amount in the inventory
		return amount
	end

	item.fetchName = function( itemData ) 	-- Where to get name of item from (see the lang table above)
		return name
	end
---------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------
	Add any custom items below
---------------------------------------------------------------------------*/
local item = {}
item.name = "Weapon"
item.description = "Pew! Pew! Pew!"
item.class = "spawned_weapon"
item.stackSize = 16
item.vars = { "WeaponClass" }
item.useFunc = function( ply, itemData )
	ply:Give( itemData.data.WeaponClass )
	ply:GetWeapon( itemData.data.WeaponClass ):SetClip1( 0 )
end
item.fetchAmount = function( ent ) return ent.dt.amount end
item.fetchName = function( itemData ) return coffeeInventory.config.language[ "weaponNames" ][ itemData.WeaponClass ] end
coffeeInventory.config.addItem( item )

local item = {}
item.name = "Shipment"
item.description = "Pew! Pew! Pew!"
item.class = "spawned_shipment"
item.stackSize = 16
item.vars = { "contents", "count", "gunspawn" }
item.fetchAmount = function( ent ) return 1 end
item.fetchName = function( itemData ) return coffeeInventory.config.language[ "weaponNames" ][ CustomShipments[ itemData.contents ].entity ] end
coffeeInventory.config.addItem( item )
