--!strict
local Players = game:GetService("Players")

local replace = Instance.new("IntValue")
replace.Name = "Health"
replace.Parent = game:GetService("StarterPlayer").StarterCharacterScripts

local REGEN_RATE = 0.05
local REGEN_STEP = 0.01
local REGEN_DELAY = 2

local activeRegen: {[Humanoid]: boolean} = {}
local connections: {[Humanoid]: {RBXScriptConnection}} = {}

local function startRegen(humanoid: Humanoid)
	if activeRegen[humanoid] then return end

	activeRegen[humanoid] = true

	task.delay(REGEN_DELAY, function()
		while activeRegen[humanoid] do
			if humanoid.Health <= 0 or humanoid.Health >= humanoid.MaxHealth then
				activeRegen[humanoid] = false
				break
			end

			local heal = REGEN_RATE * REGEN_STEP * humanoid.MaxHealth

			humanoid.Health = math.min(humanoid.Health + heal, humanoid.MaxHealth)

			task.wait(REGEN_STEP)
		end
	end)
end

local function cleanupHumanoid(humanoid: Humanoid)
	activeRegen[humanoid] = nil

	local conns = connections[humanoid]
	if conns then
		for _, conn in conns do
			conn:Disconnect()
		end
	end

	connections[humanoid] = nil
end

local function onCharacterAdded(character: Model)
	repeat task.wait() until character:FindFirstChildOfClass("Humanoid")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	if connections[humanoid] then return end

	connections[humanoid] = {}

	table.insert(connections[humanoid], 
		humanoid.HealthChanged:Connect(function(health)
			if health > 0 and health < humanoid.MaxHealth then
				startRegen(humanoid)
			end
		end))

	table.insert(connections[humanoid],
		humanoid.Died:Connect(function()
			cleanupHumanoid(humanoid)
		end))

	if humanoid.Health > 0 and humanoid.Health < humanoid.MaxHealth then
		startRegen(humanoid)
	end
end

local function onPlayerAdded(player: Player)
	player.CharacterAdded:Connect(onCharacterAdded)

	if player.Character then
		onCharacterAdded(player.Character)
	end
end

local function onPlayerRemoving(player: Player)
	if player.Character then
		local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			cleanupHumanoid(humanoid)
		end
	end
end

for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)
