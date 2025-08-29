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

-- ======================= Load Compkiller =======================
local Compkiller = loadstring(game:HttpGet("https://raw.githubusercontent.com/4lpaca-pin/CompKiller/refs/heads/main/src/source.luau"))();
log("Compkiller loaded.", "info")
task.wait(1)
Compkiller:Loader(nil,1).yield()
log("Compkiller initialized.", "info")

local FileWatcher = Compkiller:ConfigManager({ Directory = "Infinial", Config = "HCBB-Configs" })
local Window = Compkiller.new({ Keybind = "LeftAlt" })

-- ======================= Watermark =======================
local watermark = Window:Watermark()
watermark:AddText({ Icon = "user", Text = "HCBB" })
local vim = watermark:AddText({ Icon = "clock", Text = Compkiller:GetTimeNow() })
task.spawn(function()
	while true do task.wait()
		vim:SetText(Compkiller:GetTimeNow())
		Window.Username = "Player"
	end
end)

-- ======================= Tabs =======================
local Player = Window:DrawTab({ Name = "Player", Icon = "user", Type = "Single" })
local Misc = Window:DrawTab({ Name = "Misc", Icon = "box", Type = "Single" })
local Configs = Window:DrawConfig({ Name = "Configs", Icon = "folder", Config = FileWatcher })
Configs:Init()

-- ======================= Player Tab =======================
do
	local section = Player:DrawSection({ Name = "Movement", Position = "left" })

	_G.WalkSpeedEnabled = false
	_G.CustomWalkSpeed = 25
	_G.CustomJumpPower = 50
	_G.NoclipEnabled = false
	_G.ClickTPEnabled = false
	_G.ClickTPKey = Enum.KeyCode.E

	-- WalkSpeed toggle
	section:AddToggle({ Name="Enable WalkSpeed", Default=true, Callback=function(state)
		_G.WalkSpeedEnabled=state
		log("WalkSpeed "..(state and "ENABLED" or "DISABLED"))
	end })

	-- JumpPower slider
	section:AddSlider({ Name="Jump Power", Min=50, Max=65, Default=50, Callback=function(val)
		_G.CustomJumpPower=val
		log("JumpPower set to "..val)
	end })

	-- NoClip
	section:AddToggle({ Name="NoClip", Default=false, Callback=function(s)
		_G.NoclipEnabled=s
		log("NoClip "..(s and "ENABLED" or "DISABLED"))
	end })

	-- Click TP using mouse
	section:AddToggle({ Name="Click TP", Default=false, Callback=function(s)
		_G.ClickTPEnabled=s
		log("Click TP "..(s and "ENABLED" or "DISABLED"))
	end })

	game:GetService("UserInputService").InputBegan:Connect(function(input, processed)
		if processed then return end
		if _G.ClickTPEnabled and input.UserInputType == Enum.UserInputType.MouseButton1 then
			local mouse = game.Players.LocalPlayer:GetMouse()
			local targetPos = mouse.Hit
			local char = game.Players.LocalPlayer.Character
			if char and char:FindFirstChild("HumanoidRootPart") then
				char.HumanoidRootPart.CFrame = targetPos + Vector3.new(0,3,0)
				log("Teleported to click position!", "info")
			end
		end
	end)
end

-- ======================= Misc Tab =======================
do
	local section = Misc:DrawSection({ Name="Utilities", Position="left" })

	-- Ball ESP
	_G.BallESPEnabled = false
	_G.BallESPColor = Color3.fromRGB(255,0,0)
	local ballESPPart=nil

	section:AddToggle({ Name="Enable Ball ESP", Default=false, Callback=function(state)
		_G.BallESPEnabled=state
		log("Ball ESP "..(state and "ENABLED" or "DISABLED"))
	end })

	section:AddColorPicker({ Name="ESP Color", Default=Color3.fromRGB(255,0,0), Callback=function(c)
		_G.BallESPColor = c
	end })

	-- Auto Walk
	_G.AutoWalkEnabled=false
	section:AddToggle({ Name="Auto Walk Bases", Default=false, Callback=function(s)
		_G.AutoWalkEnabled=s
		log("Auto Walk "..(s and "ENABLED" or "DISABLED"))
	end })

	-- Disable Collisions
	_G.DisableCollisions=false
	section:AddToggle({ Name="Disable Collisions", Default=false, Callback=function(s)
		_G.DisableCollisions=s
		log("Disable Collisions "..(s and "ENABLED" or "DISABLED"))
	end })

	-- Rejoin Button
	section:AddButton({ Name="Rejoin", Callback=function()
		log("Rejoining game...","info")
		game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
	end })

	-- ================= Ball ESP Logic =================
	task.spawn(function()
		while task.wait(0.1) do
			local ball = workspace:FindFirstChild("Ball") -- now in workspace
			if ball and ball:IsA("BasePart") and _G.BallESPEnabled then
				if not ballESPPart then
					ballESPPart = Instance.new("Part")
					ballESPPart.Size = Vector3.new(ball.Size.X+1, ball.Size.Y+1, ball.Size.Z+1)
					ballESPPart.Anchored = true
					ballESPPart.CanCollide = false
					ballESPPart.Transparency = 0.4
					ballESPPart.BrickColor = BrickColor.new(_G.BallESPColor)
					ballESPPart.Shape = Enum.PartType.Ball
					ballESPPart.Parent = workspace
				end
				ballESPPart.Position = ball.Position
				ballESPPart.BrickColor = BrickColor.new(_G.BallESPColor)
				ballESPPart.Transparency = 0.4
				ballESPPart.Size = ball.Size + Vector3.new(1,1,1)
			elseif ballESPPart then
				ballESPPart.Transparency = 1
			end
		end
	end)
end

-- ======================= Heartbeat Loop =======================
local function onCharacterAdded(char)
	local humanoid=char:WaitForChild("Humanoid")
	local hrp=char:WaitForChild("HumanoidRootPart")

	-- Auto Walk: detect bases automatically
	local bases = {}
	local baseNames = {"FirstBase","SecondBase","ThirdBase","HomePlate"}
	for _,name in pairs(baseNames) do
		local part = workspace:FindFirstChild(name)
		if part then
			table.insert(bases, part.Position)
		end
	end
	local currentBase = 1

	game:GetService("RunService").Heartbeat:Connect(function()
		-- WalkSpeed
		if _G.WalkSpeedEnabled then
			humanoid.WalkSpeed = _G.CustomWalkSpeed
		else
			humanoid.WalkSpeed = 16
		end

		-- JumpPower
		humanoid.JumpPower = _G.CustomJumpPower

		-- NoClip
		if _G.NoclipEnabled then
			for _,v in pairs(char:GetDescendants()) do
				if v:IsA("BasePart") then v.CanCollide=false end
			end
		end

		-- Disable Collisions
		if _G.DisableCollisions then
			for _,v in pairs(workspace:GetDescendants()) do
				if v:IsA("BasePart") and (v.Parent:FindFirstChildOfClass("Humanoid") or v.Name=="Ball") then
					v.CanCollide=false
				end
			end
		end

		-- Auto Walk
		if _G.AutoWalkEnabled and #bases > 0 then
			if currentBase <= #bases then
				local targetPos = bases[currentBase]
				local direction = (targetPos - hrp.Position)
				if direction.Magnitude > 1 then
					hrp.CFrame = hrp.CFrame + direction.Unit * 0.5 -- move a bit each frame
				else
					currentBase = currentBase + 1
				end
			else
				currentBase = 1
			end
		end
	end)
end

local player=game.Players.LocalPlayer
if player.Character then onCharacterAdded(player.Character) end
player.CharacterAdded:Connect(onCharacterAdded)

log("✅ HCBB script fully loaded with WalkSpeed, JumpPower, Click TP, Ball ESP, Auto Walk (auto bases), Disable Collisions, and Rejoin","info")
