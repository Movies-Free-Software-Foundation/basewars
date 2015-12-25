MODULE.Name 	= "AntiRDM"
MODULE.Author 	= "Q2F2 & Ghosty"

local tag = "BaseWars.AntiRDM"
local PLAYER = debug.getregistry().Player

local function Curry(f)

	local MODULE = MODULE
	local function curriedFunction(...)
		return f(MODULE, ...)
	end

	return curriedFunction

end

if CLIENT then

	surface.CreateFont(tag, {
		font = "FixedSys",
		size = 46,
		weight = 2000,
		antialias = false,
	})
	
end

function MODULE:IsRDM(ply, ply2)

	if ply:InRaid() and ply2:InRaid() then return false end
	
	if ply.RecentlyHurtBy[ply2] and ply.RecentlyHurtBy[ply2] < CurTime() + BaseWars.Config.AntiRDM.HurtTime then return false end
	
	return true

end

function MODULE:OnEntityTakeDamage(ply, dmginfo)

	local Attacker = dmginfo:GetAttacker()
	if not BaseWars.Ents:ValidPlayer(Attacker) then return end
	
	ply.RecentlyHurtBy = ply.RecentlyHurtBy or {}
	ply.RecentlyHurtBy[Attacker] = CurTime()

end

function MODULE:PlayerDeath(ply, inflictor, attacker)

	if not BaseWars.Ents:ValidPlayer(attacker) then return end
	if not self:IsRDM(ply, attacker) then return end
	
	ply.RecentlyHurtBy = {}

end

function MODULE:Paint()

	do return end

	local ply = LocalPlayer()

	if (ply.IsAFK and ply:IsAFK()) or not ply:GetRespawnTime() then return end
	
	local len = ply:GetRespawnTime()
	local m = math.floor(len / 60 - h * 60)
	local s = math.floor(len - m * 60 - h * 60 * 60)

	local RespawnTime = string.format("%.2d:%.2d", m, s)

	surface.SetFont(tag)
	local w, h = surface.GetTextSize(RespawnTime)
	
	surface.SetTextColor(color_black)
	
	surface.SetTextPos(ScrW() / 2 - w / 2 + 1, ScrH() / 3 + 1)
	surface.DrawText(RespawnTime)
	
	surface.SetTextColor(color_white)
	
	surface.SetTextPos(ScrW() / 2 - w / 2, ScrH() / 3)
	surface.DrawText(RespawnTime)
	
	local Txt = BaseWars.LANG.RespawnIn
	local w2, h2 = surface.GetTextSize(Txt)
	
	surface.SetTextColor(color_black)
	
	surface.SetTextPos(ScrW() / 2 - w2 / 2 + 1, ScrH() / 3 - h2)
	surface.DrawText(Txt)
	
	surface.SetTextColor(color_white)
	
	surface.SetTextPos(ScrW() / 2 - w2 / 2, ScrH() / 3 - h2 - 1)
	surface.DrawText(Txt)
	
end
hook.Add("HUDPaint", tag .. ".Paint", Curry(MODULE.Paint))