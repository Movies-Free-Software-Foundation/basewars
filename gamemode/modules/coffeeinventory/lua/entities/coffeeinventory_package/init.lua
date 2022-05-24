AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel( "models/props_junk/cardboard_box003a.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( SIMPLE_USE )
	self:GetPhysicsObject():Wake()

	self.item = {}
end

function ENT:Use( activator, caller )
	local i = ents.Create( self.item.class )
	i:SetPos( self:GetPos() + Vector( 0, 0, 35 ) )
	i:SetModel( self.item.mdl )
	i:Spawn()

	for var, value in pairs ( self.item.data ) do
		i[ var ] = value
		i.dt[ var ] = value
	end

	self.item.amount = self.item.amount - 1
	if self.item.amount <= 0 then
		self:Remove()
	end
end

util.AddNetworkString( "coffeeInv_itemPackageData" )
function ENT:sendData()
	net.Start( "coffeeInv_itemPackageData" )
		net.WriteEntity( self )
		net.WriteTable( self.item )
	net.Broadcast()
end