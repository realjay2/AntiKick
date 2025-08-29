-- ======================= Console Helper =======================
local function log(msg, level)
	if level == "warn" then
		warn("[WARN] "..msg)
	elseif level == "error" then
		warn("[ERROR] "..msg)
	else
		print("[INFO] "..msg)
	end
end

-- ======================= Anti-Kick =======================
pcall(function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/realjay2/AntiKick/refs/heads/main/acbypass.lua"))()
	log("AntiKick bypass enabled.", "info")
end)

-- ======================= Load Compkiller =======================
local Compkiller = loadstring(game:HttpGet("https://raw.githubusercontent.com/4lpaca-pin/CompKiller/refs/heads/main/src/source.luau"))();
log("Compkiller loaded.", "info")
task.wait(1)
Compkiller:Loader(nil,1).yield()
log("Compkiller initialized.", "info")

local FileWatcher = Compkiller:ConfigManager({ Directory = "Infinial", Config = "Example-Configs" })
local Window = Compkiller.new({ Keybind = "LeftAlt" })

-- ======================= Watermark =======================
local watermark = Window:Watermark()
watermark:AddText({ Icon = "user", Text = "Steal a Brainrot" })
local vim = watermark:AddText({ Icon = "clock", Text = Compkiller:GetTimeNow() })
task.spawn(function()
	while true do task.wait()
		vim:SetText(Compkiller:GetTimeNow())
		Window.Username = "Tester"
	end
end)
Window:Update({ ExpireDate = Compkiller:GetDate(tick()+84000) })
watermark:AddText({ Icon = "server", Text = "Owner" })

-- ======================= Tabs =======================
local General = Window:DrawTab({ Name = "General", Icon = "settings-3", Type = "Single" })
local Player = Window:DrawTab({ Name = "Player", Icon = "user", Type = "Single" })
local Client = Window:DrawTab({ Name = "Client", Icon = "cpu", Type = "Single" })
local Misc = Window:DrawTab({ Name = "Misc", Icon = "box", Type = "Single" })
local Configs = Window:DrawConfig({ Name = "Configs", Icon = "folder", Config = FileWatcher })
Configs:Init()

-- ======================= General Tab =======================
do
	local section = General:DrawSection({ Name = "Protections", Position = "left" })
	section:AddToggle({ Name = "Anti-Ragdoll", Default=false, Callback=function(s) _G.AntiRagdoll=s log("Anti-Ragdoll "..(s and "ENABLED" or "DISABLED")) end })
	section:AddToggle({ Name = "Auto Get Up", Default=false, Callback=function(s) _G.AutoGetUp=s log("Auto Get Up "..(s and "ENABLED" or "DISABLED")) end })
	section:AddToggle({ Name = "Anti-Kick", Default=false, Callback=function(s)
		if s then
			local mt=getrawmetatable(game)
			local old=mt.__namecall
			setreadonly(mt,false)
			mt.__namecall = newcclosure(function(self,...)
				local method=getnamecallmethod()
				if tostring(self)=="Kick" or method=="Kick" then
					log("Kick attempt blocked.","warn")
					return nil
				end
				return old(self,...)
			end)
			setreadonly(mt,true)
			log("Anti-Kick ENABLED","info")
		else
			log("Anti-Kick DISABLED","warn")
		end
	end })
end

-- ======================= Player Tab =======================
do
	local section = Player:DrawSection({ Name = "Movement", Position = "left" })

	_G.NoclipEnabled=false
	_G.ClickTPEnabled=false
	_G.ClickTPKey=Enum.KeyCode.E
	_G.ClickTPDistance=5
	_G.CustomJumpPower=50
	_G.CustomHipHeight=2
	_G.SpeedCoilEnabled=false
	_G.TeleportCoords={X=0,Y=0,Z=0}
	_G.TeleportPlayer=nil

	-- Speed Coil Toggle
	section:AddToggle({ Name="Use Speed Coil", Default=false, Callback=function(state)
		_G.SpeedCoilEnabled=state
		log("Speed Coil "..(state and "ENABLED" or "DISABLED"))
	end })

	-- JumpPower Slider
	section:AddSlider({ Name="JumpPower", Min=50, Max=150, Default=50, Callback=function(val)
		_G.CustomJumpPower=val
		log("JumpPower set to "..val)
	end })

	-- HipHeight Slider
	section:AddSlider({ Name="HipHeight", Min=0, Max=10, Default=2, Callback=function(val)
		_G.CustomHipHeight=val
		log("HipHeight set to "..val)
	end })

	-- NoClip
	section:AddToggle({ Name="NoClip", Default=false, Callback=function(s)
		_G.NoclipEnabled=s
		log("NoClip "..(s and "ENABLED" or "DISABLED"))
	end })

	-- Click TP
	section:AddToggle({ Name="Click TP", Default=false, Callback=function(s)
		_G.ClickTPEnabled=s
		log("Click TP "..(s and "ENABLED" or "DISABLED"))
	end })
	section:AddSlider({ Name="Click TP Distance", Min=3, Max=10, Default=5, Callback=function(v)
		_G.ClickTPDistance=v
		log("Click TP distance set to "..v)
	end })
	section:AddKeybind({ Name="Click TP Keybind", Default=nil, Callback=function(k)
		_G.ClickTPKey=k
		log("Click TP keybind set to "..tostring(k))
	end })

	-- Teleport to Coords
	section:AddTextBox({ Name="TP to Coords", Default="", Callback=function(str)
		local x,y,z = str:match("([^,]+),([^,]+),([^,]+)")
		if x and y and z then
			_G.TeleportCoords = {X=tonumber(x),Y=tonumber(y),Z=tonumber(z)}
			log("Teleport coordinates set to "..x..","..y..","..z)
		end
	end })
	section:AddButton({ Name="Teleport to Coords", Callback=function()
		local char=game.Players.LocalPlayer.Character
		if char and char:FindFirstChild("HumanoidRootPart") then
			char.HumanoidRootPart.CFrame=CFrame.new(_G.TeleportCoords.X,_G.TeleportCoords.Y,_G.TeleportCoords.Z)
			log("Teleported to coordinates.")
		end
	end })

	-- Teleport to Player
	section:AddDropdown({ Name="Teleport to Player", Values={}, Default="", Callback=function(plrName)
		_G.TeleportPlayer=game.Players:FindFirstChild(plrName)
		log("Teleport target set to "..plrName)
	end })
	section:AddButton({ Name="Teleport to Player", Callback=function()
		local plr=_G.TeleportPlayer
		local char=game.Players.LocalPlayer.Character
		if plr and plr.Character and char and char:FindFirstChild("HumanoidRootPart") then
			char.HumanoidRootPart.CFrame=plr.Character.HumanoidRootPart.CFrame+Vector3.new(0,3,0)
			log("Teleported to player "..plr.Name)
		end
	end })

	-- Update player list dropdown
	task.spawn(function()
		while true do task.wait(2)
			local plrs={}
			for _,p in pairs(game.Players:GetPlayers()) do if p~=game.Players.LocalPlayer then table.insert(plrs,p.Name) end end
			local dd=section:FindFirstChild("Teleport to Player")
			if dd then dd.Values=plrs end
		end
	end)

	-- NoClip loop
	game:GetService("RunService").Stepped:Connect(function()
		local char=game.Players.LocalPlayer.Character
		if char and _G.NoclipEnabled then
			for _,v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide=false end end
		end
	end)

	-- Click TP logic
	game:GetService("UserInputService").InputBegan:Connect(function(input,processed)
		if processed then return end
		if _G.ClickTPEnabled and input.UserInputType==Enum.UserInputType.Keyboard and input.KeyCode==_G.ClickTPKey then
			local char=game.Players.LocalPlayer.Character
			if char and char:FindFirstChild("HumanoidRootPart") then
				char.HumanoidRootPart.CFrame=char.HumanoidRootPart.CFrame+char.HumanoidRootPart.CFrame.LookVector*_G.ClickTPDistance
				log("Click TP executed! Teleported ".._G.ClickTPDistance.." studs forward.","info")
			end
		end
	end)
end

-- ======================= Client Tab =======================
do
	local section=Client:DrawSection({ Name="Client Resources", Position="left" })

	local function refreshResources()
		local res={}
		for _,v in pairs(game:GetDescendants()) do
			if v:IsA("Script") or v:IsA("LocalScript") or v:IsA("ModuleScript") then table.insert(res,v) end
		end
		return res
	end
	section:AddButton({ Name="View All Resources", Callback=function()
		local res=refreshResources()
		for _,v in pairs(res) do log("Resource: "..v:GetFullName()) end
	end })
	section:AddButton({ Name="Disable All Resources", Callback=function()
		local res=refreshResources()
		for _,v in pairs(res) do pcall(function() v.Disabled=true end) end
		log("All scripts/modules disabled in Client tab.","warn")
	end })

	-- ================= ESP System =================
	_G.ESPSettings={Enabled=false, ShowName=true, ShowWeapon=true, ShowDistance=true, ShowSnapLines=true, BoxType="Corner", Color=Color3.fromRGB(255,0,0)}
	section:AddToggle({ Name="Enable ESP", Default=false, Callback=function(s) _G.ESPSettings.Enabled=s log("ESP "..(s and "ENABLED" or "DISABLED")) end })
	section:AddToggle({ Name="Show Name", Default=true, Callback=function(s) _G.ESPSettings.ShowName=s end })
	section:AddToggle({ Name="Show Weapon", Default=true, Callback=function(s) _G.ESPSettings.ShowWeapon=s end })
	section:AddToggle({ Name="Show Distance", Default=true, Callback=function(s) _G.ESPSettings.ShowDistance=s end })
	section:AddToggle({ Name="Show SnapLines", Default=true, Callback=function(s) _G.ESPSettings.ShowSnapLines=s end })
	section:AddDropdown({ Name="Box Type", Values={"Skeleton","Rounded","Corner","Shaded"}, Default="Corner", Callback=function(v) _G.ESPSettings.BoxType=v end })
	section:AddColorPicker({ Name="ESP Color", Default=Color3.fromRGB(255,0,0), Callback=function(c) _G.ESPSettings.Color=c end })

	-- ======================= ESP Logic =======================
	local espTable={}
	local function createESP(plr)
		if plr==game.Players.LocalPlayer then return end
		local data={Player=plr, Boxes={}, Name=Drawing.new("Text")}
		data.Name.Color=_G.ESPSettings.Color
		data.Name.Center=true; data.Name.Size=14; data.Name.Visible=true
		data.Boxes.Box=Drawing.new("Square")
		data.Boxes.Box.Color=_G.ESPSettings.Color
		data.Boxes.Box.Thickness=2; data.Boxes.Box.Filled=false; data.Boxes.Box.Visible=true
		return data
	end
	for _,p in pairs(game.Players:GetPlayers()) do if p~=game.Players.LocalPlayer then table.insert(espTable,createESP(p)) end end
	game.Players.PlayerAdded:Connect(function(plr) if plr~=game.Players.LocalPlayer then table.insert(espTable,createESP(plr)) end end)
	game.Players.PlayerRemoving:Connect(function(plr)
		for i,data in pairs(espTable) do
			if data.Player==plr then for _,v in pairs(data.Boxes) do v:Remove() end data.Name:Remove() table.remove(espTable,i) end
		end
	end)
	game:GetService("RunService").RenderStepped:Connect(function()
		for _,data in pairs(espTable) do
			local plr=data.Player
			local char=plr.Character
			if char and char:FindFirstChild("HumanoidRootPart") then
				local hrp=char.HumanoidRootPart
				local pos,vis=workspace.CurrentCamera:WorldToViewportPoint(hrp.Position)
				if _G.ESPSettings.Enabled and vis then
					local box=data.Boxes.Box
					box.Position=Vector2.new(pos.X-10,pos.Y-10)
					box.Size=Vector2.new(20,20)
					box.Color=_G.ESPSettings.Color
					box.Visible=true
					local txt=""
					if _G.ESPSettings.ShowName then txt=txt..plr.Name.." " end
					if _G.ESPSettings.ShowWeapon then
						local tool=char:FindFirstChildOfClass("Tool")
						if tool then txt=txt..tool.Name.." " end
					end
					if _G.ESPSettings.ShowDistance then
						local dist=(hrp.Position-game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
						txt=txt.."["..math.floor(dist).." studs]"
					end
					data.Name.Text=txt
					data.Name.Position=Vector2.new(pos.X,pos.Y-15)
					data.Name.Color=_G.ESPSettings.Color
					data.Name.Visible=true
				else
					data.Boxes.Box.Visible=false
					data.Name.Visible=false
				end
			end
		end
	end)
end

-- ======================= Misc Tab =======================
do
	local section=Misc:DrawSection({ Name="Utilities", Position="left" })
	section:AddButton({ Name="Rejoin", Callback=function() log("Rejoining game...","info") game:GetService("TeleportService"):Teleport(game.PlaceId,game.Players.LocalPlayer) end })
	section:AddButton({ Name="Panic (Uninject)", Callback=function()
		log("PANIC triggered! Resetting all features...","warn")
		pcall(function()
			Window:Destroy()
			for _,v in pairs(getconnections(game:GetService("RunService").Heartbeat)) do v:Disconnect() end
			for _,v in pairs(getconnections(game:GetService("RunService").Stepped)) do v:Disconnect() end
			_G.NoclipEnabled=false
			_G.ClickTPEnabled=false
			_G.SpeedCoilEnabled=false
			_G.CustomJumpPower=50
			_G.CustomHipHeight=2
			_G.AntiRagdoll=false
			_G.AutoGetUp=false
			_G.ESPSettings.Enabled=false
			log("All features reset to default.","info")
		end)
	end })
end

-- ======================= Heartbeat Loop =======================
local function onCharacterAdded(char)
	local humanoid=char:WaitForChild("Humanoid")
	local hrp=char:WaitForChild("HumanoidRootPart")
	game:GetService("RunService").Heartbeat:Connect(function()
		-- HipHeight
		humanoid.HipHeight=_G.CustomHipHeight

		-- Speed Coil effect
		if _G.SpeedCoilEnabled then
			local speedCoil = nil
			-- Look in Backpack first
			for _,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
				if v.Name:lower():find("speed") then
					speedCoil=v
					break
				end
			end
			-- Look in Character
			if not speedCoil then
				for _,v in pairs(char:GetChildren()) do
					if v.Name:lower():find("speed") then
						speedCoil=v
						break
					end
				end
			end
			if speedCoil then
				humanoid.WalkSpeed = 80 -- simulate speed coil
			end
		else
			humanoid.WalkSpeed = 32
		end

		-- Jump via Velocity
		if humanoid:GetState()==Enum.HumanoidStateType.Jumping then
			hrp.Velocity=Vector3.new(hrp.Velocity.X,_G.CustomJumpPower,hrp.Velocity.Z)
		end

		-- Anti-Ragdoll
		if _G.AntiRagdoll then
			for _,v in pairs(char:GetDescendants()) do
				if v:IsA("BallSocketConstraint") or v:IsA("HingeConstraint") or v:IsA("BodyVelocity") or v:IsA("BodyAngularVelocity") then
					v:Destroy()
				end
			end
		end

		-- Auto Get Up
		if _G.AutoGetUp then
			if humanoid:GetState()==Enum.HumanoidStateType.Ragdoll or humanoid:GetState()==Enum.HumanoidStateType.FallingDown then
				humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
			end
		end
	end)
end
local player=game.Players.LocalPlayer
if player.Character then onCharacterAdded(player.Character) end
player.CharacterAdded:Connect(onCharacterAdded)

-- ======================= Startup Logs =======================
log("-------------------------------","info")
log("✅ Script fully loaded and UI initialized.","info")
log("Press LeftAlt to open UI","info")
log("-------------------------------","info")
