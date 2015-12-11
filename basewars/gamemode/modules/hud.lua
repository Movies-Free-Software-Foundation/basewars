MODULE.Name 	= "HUD"
MODULE.Author 	= "Q2F2 & Ghosty"
MODULE.Realm 	= 2
MODULE.Credits 	= "Based on geist by ghosty; https://github.com/TrenchFroast/ghostys-server-stuff/blob/master/lua/autorun/client/geist_hud.lua"

local tag = "BaseWars.HUD"

local function Curry(f)

	local MODULE = MODULE
	local function curriedFunction(...)
		return f(MODULE, ...)
	end

	return curriedFunction

end

function MODULE:__INIT()

	surface.CreateFont(tag, {
		font = "Roboto",
		size = 16,
		weight = 800,
	})

end

local clamp = math.Clamp
local floor = math.floor
local round = math.Round

local function Calc(real, max, min, w)

	real = clamp(real,min or 0,max)
	real = real / max
	
	if w then
	
		local calw = w * real
		
		return calw, w - calw
		
	else
	
		return real
		
	end
	
end

local oldhW = 0
local oldHP = 0

local oldaW = 0
local oldAM = 0

local shade = Color(0, 0, 0, 140)
local trans = Color(255, 255, 255, 150)
local textc = Color(100, 150, 200, 255)
local hpbck = Color(255, 0  , 0  , 100)
local pwbck = Color(0  , 0  , 255, 100)

function MODULE:DrawStructureInfo(ent)
	local Pos = ent:GetPos()
	Pos.z = Pos.z + 14
	
	Pos = Pos:ToScreen()
	
	local name = (ent.PrintName or (ent.GetName and ent:GetName()) or (ent.Nick and ent:Nick()) or ent:GetClass()):Trim()
	local W = BaseWars.Config.HUD.EntW
	local H = BaseWars.Config.HUD.EntH
	
	local oldx, oldy = Pos.x, Pos.y
	local curx, cury = Pos.x, Pos.y
	local w, h
	local Font = BaseWars.Config.HUD.EntFont
	local Padding = 5
	local EndPad = -Padding * 2
	
	curx = curx - W / 2
	cury = cury - H / 2
	
	surface.SetDrawColor(shade)
	surface.DrawRect(curx, cury, W, H)
	
	surface.SetFont(Font)
	w, h = surface.GetTextSize(name)
	
	draw.DrawText(name, Font, oldx - w / 2, cury, shade)
	draw.DrawText(name, Font, oldx - w / 2, cury, textc)
	
	if ent:Health() > 0 then
	
		cury = cury + H + 1
	
		surface.SetDrawColor(shade)
		surface.DrawRect(curx, cury, W, H)
		
		local MaxHealth = ent:MaxHealth() or 100
		local HealthStr = ent:Health() .. "/" .. MaxHealth .. " HP"
	
		local HPLen = W * (ent:Health() / MaxHealth)
		
		draw.RoundedBox(0, curx + Padding, cury + Padding, HPLen + EndPad, H + EndPad, hpbck)

		surface.SetFont(Font)
		w, h = surface.GetTextSize(HealthStr)
		
		draw.DrawText(HealthStr, Font, oldx - w / 2, cury + Padding, shade)
		draw.DrawText(HealthStr, Font, oldx - w / 2, cury + Padding, color_white)
		
	end
	
	if ent.Power then
	
		cury = cury + H + 1
	
		surface.SetDrawColor(shade)
		surface.DrawRect(curx, cury, W, H)
		
		local MaxPower = ent:MaxPower() or 100
		local PowerStr = (ent:Power() > 0 and ent:Power() .. "/" .. MaxPower .. " PW") or BaseWars.LANG.PowerFailure
	
		local PWLen = W * (ent:Power() / MaxPower)
		
		draw.RoundedBox(0, curx + Padding, cury + Padding, PWLen + EndPad, H + EndPad, pwbck)

		surface.SetFont(Font)
		w, h = surface.GetTextSize(PowerStr)
		
		draw.DrawText(PowerStr, Font, oldx - w / 2, cury + Padding, shade)
		draw.DrawText(PowerStr, Font, oldx - w / 2, cury + Padding, color_white)
		
	end
	
	if ent:BadlyDamaged() then
	
		cury = cury + H + 1
	
		surface.SetDrawColor(shade)
		surface.DrawRect(curx, cury, W, H)
		
		local Str = BaseWars.LANG.HealthFailure

		surface.SetFont(Font)
		w, h = surface.GetTextSize(Str)
		
		draw.DrawText(Str, Font, oldx - w / 2, cury + Padding - 1, shade)
		draw.DrawText(Str, Font, oldx - w / 2, cury + Padding - 1, color_white)
		
	end
end

function MODULE:DrawDisplay()

	local me = LocalPlayer()
	local Ent = me:GetEyeTrace().Entity

	if BaseWars.Ents:ValidClose(Ent, me, 200) and (Ent.IsElectronic or Ent.IsGenerator or Ent.DrawStructureDisplay) then
		
		self:DrawStructureInfo(Ent)
		
	end
	
end

function MODULE:Paint()

	local me = LocalPlayer()
	if not me:IsPlayer() or not IsValid(me) then return end
	
	self:DrawDisplay()

	local hp, su = me:Health(), me:Armor()

	if not me:Alive() then hp = 0 su = 0 end

	local hpF = Lerp(0.15, oldHP, hp)
	oldHP = hpF

	local suF = Lerp(0.15, oldAM, su)
	oldAM = suF

	local pbarW, pbarH = 256, 6

	local sW, sH = ScrW(), ScrH()

	local hW = Calc(hp, 100, 0, pbarW)
	local aW = Calc(su, 100, 0, pbarW)

	local nhW,naW = 0,0

	hW = Lerp(0.15,oldhW,hW)
	oldhW = hW
	nhW = pbarW - hW

	aW = Lerp(0.15,oldaW,aW)
	oldaW = aW
	naW = pbarW - aW

	-- Health

	draw.DrawText("HP", tag, 64 + 18, sH - 128 - 32 - 8, shade, TEXT_ALIGN_RIGHT)
	draw.DrawText("HP", tag, 64 + 16, sH - 128 - 32 - 10, trans, TEXT_ALIGN_RIGHT)

	if hW > 0.01 then
	
		draw.RoundedBox(0, 64 + 24, sH - 128 - 32 - 4, hW, pbarH, Color(1,159,1,150))
		draw.RoundedBox(0, 64 + 24 - nhW + pbarW, sH - 128 - 32 - 4, nhW, pbarH, Color(159,1,1,150))
		
	else
	
		draw.RoundedBox(0, 64 + 24, sH - 128 - 32 - 4, pbarW, pbarH, Color(159,1,1,150))
		
	end
	
	draw.DrawText(round(hpF), tag, pbarW + 98, sH - 128 - 32 - 8, shade, TEXT_ALIGN_LEFT)	
	draw.DrawText(round(hpF), tag, pbarW + 96, sH - 128 - 32 - 10, trans, TEXT_ALIGN_LEFT)	

	-- Armor
	draw.DrawText("SUIT", tag, 64 + 18, sH - 128 - 16 - 8, shade, TEXT_ALIGN_RIGHT)
	draw.DrawText("SUIT", tag, 64 + 16, sH - 128 - 16 - 10, trans, TEXT_ALIGN_RIGHT)
	
	if aW > 0.01 then
	
		draw.RoundedBox(0, 64 + 24, sH - 128 - 16 - 4, aW, pbarH, Color(90,120,200,150))
		draw.RoundedBox(0, 64 + 24 - naW + pbarW, sH - 128 - 16 - 4, naW, pbarH, Color(10,40,150,150))
		
	else
	
		draw.RoundedBox(0, 64 + 24, sH - 128 - 16 - 4, pbarW, pbarH, Color(10,40,150,150))
		
	end

	draw.DrawText(round(suF), tag, pbarW + 98, sH - 128 - 16 - 8, shade, TEXT_ALIGN_LEFT)
	draw.DrawText(round(suF), tag, pbarW + 96, sH - 128 - 16 - 10, trans, TEXT_ALIGN_LEFT)

end
hook.Add("HUDPaint", tag .. ".Paint", Curry(MODULE.Paint))

function HideHUD(name)

    for k, v in next, {"CHudHealth", "CHudBattery", --[["CHudAmmo", "CHudSecondaryAmmo"]]} do
	
        if name == v then
		
			return false
		
		end
		
    end
	
end
hook.Add("HUDShouldDraw", tag .. ".HideOldHUD", HideHUD)