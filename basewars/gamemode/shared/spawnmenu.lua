
local SpawnList = {}

SpawnList = BaseWars.SpawnList

if SERVER then 

	local function Spawn(ply, cat, subcat, item)

		local l = SpawnList and SpawnList.Models

		if not l then return end

		if not cat or not item then return end

		local i = l[cat]

		if not i then return end

		i = i[subcat]

		if not i then return end

		i = i[item]

		if not i then return end

		local model, price, ent, sf = i.Model, i.Price, i.ClassName, i.UseSpawnFunc

		local tr
		
		if ent then
		
			tr = {}

			tr.start = ply:EyePos()
			tr.endpos = tr.start + ply:GetAimVector() * 85
			tr.filter = ply

			tr = util.TraceLine(tr)
			
		else
			
			tr = ply:GetEyeTraceNoCursor()
			
			if not tr.Hit then return end
		
		end

		if price > 0 then
			
			local plyMoney = ply:GetMoney()

			if plyMoney < price then
				
				ply:Notify(BaseWars.LANG.SpawnMenuMoney, Color(255, 0, 0))

			return end

			ply:SetMoney(plyMoney - price)
			ply:EmitSound("mvm/mvm_money_pickup.wav")

			ply:Notify(string.format(BaseWars.LANG.SpawnMenuBuy, item, price), Color(0, 255, 0))

		end

		local prop
		local noundo

		if ent then
			
			local newEnt = ents.Create(ent)

			if not newEnt then return end

			if newEnt.SpawnFunction and sf then
			
				local phys = newEnt:GetPhysicsObject()

				if IsValid(phys) then

					if i.ShouldFreeze then
					
						phys:EnableMotion(false)

					end

				end	
				
				if newEnt.CPPISetOwner then

					newEnt:CPPISetOwner(ply)

				end
				
				newEnt:SpawnFunction(ply, tr, ent)
				
			return end

			prop = newEnt

			noundo = true

		end

		local SpawnPos = tr.HitPos + tr.HitNormal * 60
		local SpawnAng = ply:EyeAngles()
		SpawnAng.p = 0
		SpawnAng.y = SpawnAng.y + 180
		SpawnAng.y = math.Round(SpawnAng.y / 45) * 45

		if not prop then prop = ents.Create(ent or "prop_physics") end
		if not noundo then undo.Create("prop") end
		
		if not prop or not IsValid(prop) then return end

		prop:SetPos(SpawnPos)
		prop:SetAngles(SpawnAng)

		if model and not ent then

			prop:SetModel(model)

		end

		prop:Spawn()
		prop:Activate()

		local phys = prop:GetPhysicsObject()

		if IsValid(phys) then
			
			if i.ShouldFreeze then

				phys:EnableMotion(false)

			end

		end

		undo.AddEntity(prop)
		undo.SetPlayer(ply)
		undo.Finish()

		if prop.CPPISetOwner then

			prop:CPPISetOwner(ply)

		end

	
	end

	concommand.Add("basewars_spawn",function(ply,_,args)

		if not IsValid(ply) then return end
		Spawn(ply, args[1], args[2], args[3], args[4])

	end)

	local function Disallow_Spawning(ply)

		if not ply:IsAdmin()  then
			
			BaseWars.Util_Player:Notification(ply, "Use the BaseWars spawnlist!", Color(255, 0, 0))
			return false

		end

	end

	hook.Add("PlayerSpawnObject", "BaseWars.Disallow_Spawning",Disallow_Spawning)
	hook.Add("PlayerSpawnSENT", "BaseWars.Disallow_Spawning",Disallow_Spawning)
	hook.Add("PlayerSpawnVehicle", "BaseWars.Disallow_Spawning",Disallow_Spawning)

return end

language.Add("spawnmenu.category.basewars","BaseWars")

local overlayFont = "BaseWars.SpawnList.Overlay"
surface.CreateFont(overlayFont,{

	font = "Roboto",
	size = 15,
	weight = 800,

})

local PANEL = {}

function PANEL:Init()

	self.Panels = {}

end

function PANEL:AddPanel(name,pnl)

	self.Panels[name] = pnl
	
	if not self.CurrentPanel then
		
		pnl:Show()
		self.CurrentPanel = pnl

	else

		pnl:Hide()

	end

end

function PANEL:SwitchTo(name,instant)

	local pnl = self.Panels[name]

	if not pnl then return end

	local oldpnl = self.CurrentPanel

	if pnl == oldpnl then return end

	if oldpnl then
		
		oldpnl:AlphaTo(0, instant and 0 or 0.2, 0, function(_,pnl) pnl:Hide() end)

	end

	pnl:Show()
	pnl:AlphaTo(255, instant and 0 or 0.2, 0, function() end)

	self.CurrentPanel = pnl

end

vgui.Register("BaseWars.PanelCollection", PANEL, "Panel")

local PANEL = {}

local white = Color(255, 255, 255)
local gray = Color(192, 192, 192)
local black = Color(0, 0, 0)
local errorcolor = Color(255, 100, 100)
local highlight = Color(100, 100, 100, 200)

function PANEL:CheckError()

	return false

end

function PANEL:Paint(w, h)

	draw.RoundedBox(4, 0, 0, w, h, black)
	draw.RoundedBox(4, 1, 1, w - 2, h - 2, self:CheckError() and errorcolor or white)

	self:DrawTextEntryText(black, highlight, gray)

	return false

end

vgui.Register("BaseWars.ErrorCheckTextEntry", PANEL, "DTextEntry")

local white = Color(255, 255, 255)

local canBuy  = Color(90, 200, 0, 180)
local cantBuy = Color(100, 100, 100, 180)

local shade = Color(0, 0, 0, 200)

local SpawnList = BaseWars.SpawnList

if not SpawnList then return end

local Models = SpawnList.Models

local function MakeTab(type)
	return function(pnl)

		local cats = pnl:Add("DCategoryList")

		cats:Dock(FILL)

		function cats:Paint() end
		
		for catName, subT in SortedPairs(Models[type]) do

			local cat = cats:Add(catName)

			local iLayout = vgui.Create("DIconLayout")

			iLayout:Dock(FILL)

			iLayout:SetSpaceX(4)
			iLayout:SetSpaceY(4)

			for name, tab in SortedPairs(subT) do

				local model = tab.Model
				local money = tab.Price
				
				local icon = iLayout:Add("SpawnIcon")

				icon:SetModel(model)
				icon:SetTooltip(name .. (money > 0 and " (" .. BaseWars.LANG.CURRENCY .. BaseWars.NumberFormat(money) .. ")" or ""))

				icon:SetSize(64, 64)

				function icon:DoClick()

					local myMoney = LocalPlayer():GetMoney()

					surface.PlaySound("ui/buttonclickrelease.wav")

					local a1, a2, a3 = type, catName, name

					local function DoIt()

						RunConsoleCommand("basewars_spawn", type, catName, name)

					end

					if money > 0 then

						if myMoney < money then
							
							Derma_Message(BaseWars.LANG.SpawnMenuMoney, "Error")

						return end
						
						Derma_Query(string.format(BaseWars.LANG.SpawnMenuBuyConfirm, name, BaseWars.NumberFormat(money)),
							BaseWars.LANG.SpawnMenuConf, "   " .. BaseWars.LANG.Yes .. "   ", DoIt, "   " .. BaseWars.LANG.No .. "   ")

					else

						DoIt()

					end
					

				end

				if money > 0 then

						function icon:Paint(w, h)
								
							local myMoney = LocalPlayer():GetMoney()

							draw.RoundedBox(4, 1, 1, w - 2, h - 2, myMoney >= money and canBuy or cantBuy)

						end

						local pO = icon.PaintOver

						function icon:PaintOver(w, h)

							pO(self, w, h)

							local text = BaseWars.LANG.CURRENCY .. BaseWars.NumberFormat(money)

							draw.DrawText(text, overlayFont, w - 2, h - 14, shade, TEXT_ALIGN_RIGHT)
							draw.DrawText(text, overlayFont, w - 4, h - 16, white, TEXT_ALIGN_RIGHT)					

						end

					end

			end

			cat:SetContents(iLayout)
			cat:SetExpanded(true)

		end

	end

end

local Panels = {

	Default = function(pnl)

		local lbl = pnl:Add("ContentHeader")

		lbl:SetPos(16, 0)

		lbl:SetText("BaseWars Spawnlist")

		local lbl = pnl:Add("DLabel")

		lbl:SetPos(16, 64)

		lbl:SetFont("DermaLarge")
		lbl:SetText("Click on a category to the left.")	

		lbl:SetBright(true)

		lbl:SizeToContents()

	end,	

	Barricades = MakeTab("Barricades"),

	Furniture = MakeTab("Furniture"),

	Build = MakeTab("Build"),

	Junk = MakeTab("Junk"),
	
	Entities = MakeTab("Entities"),

}

local Tabs = {

	barricades = {
		Name = "Barricades", 
		AssociatedPanel = "Barricades",
		Icon = "icon16/shield.png",
	},

	furniture = {
		Name = "Furniture and Decor", 
		AssociatedPanel = "Furniture",
		Icon = "icon16/lorry.png",
	},

	build = {
		Name = "Build", 
		AssociatedPanel = "Build",
		Icon = "icon16/wrench.png",
	},

	junk = {
		Name = "Junk",
		AssociatedPanel = "Junk",
		Icon = "icon16/bin_closed.png",
	},
	
	entities = {
		Name = "Entities",
		AssociatedPanel = "Entities",
		Icon = "icon16/bricks.png",
	},

}

local function MakeSpawnList()

	local pnl = vgui.Create("DPanel")

	function pnl:Paint(w,h) end

	local leftPanel = pnl:Add("DPanel")

	leftPanel:Dock(LEFT)
	leftPanel:SetWide(256 - 64)
	leftPanel:DockPadding(1, 1, 1, 1)

	local tree = leftPanel:Add("DTree")

	function tree:Paint() end

	tree:Dock(FILL)

	local rightPanel = pnl:Add("BaseWars.PanelCollection")

	rightPanel:Dock(FILL)

	rightPanel:SetMouseInputEnabled(true)
	rightPanel:SetKeyboardInputEnabled(true)

	local defaultNode = tree:AddNode("Spawnlist")

	function defaultNode:OnNodeSelected()

		rightPanel:SwitchTo("Default")

	end

	defaultNode:SetIcon("icon16/application_view_tile.png")

	defaultNode:SetExpanded(true, true)

	defaultNode:GetRoot():SetSelectedItem(defaultNode)

	for _, build in SortedPairs(Tabs) do
		
		local node = defaultNode:AddNode(build.Name or "(UNNAMED)")

		node:SetIcon(build.Icon or "icon16/cancel.png")

		local ap = build.AssociatedPanel
		if ap then

			function node:OnNodeSelected()

				rightPanel:SwitchTo(ap)

			end

		end

	end

	for name, build in next, Panels do
		
		local container = rightPanel:Add("DPanel")

		function container:Paint() end

		container:Dock(FILL)

		pcall(build, container)

		rightPanel:AddPanel(name,container)

	end

	rightPanel:SwitchTo("Default", true)

	return pnl

end

spawnmenu.AddCreationTab("#spawnmenu.category.basewars", MakeSpawnList, "icon16/building.png", -100)

RunConsoleCommand("spawnmenu_reload")