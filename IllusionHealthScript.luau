--!strict
local Players = game:GetService("Players")
local replace = Instance.new("IntValue")
replace.Name = "health"
replace.Parent = game:GetService("StarterPlayer").StarterCharacterScripts

local REGEN_RATE = 1 / 20
local REGEN_STEP = 0.01
local REGEN_DELAY = 2

local function StartRegen(Humanoid: Humanoid)
	local isRegenerating = false

	local function RegenStep()
		if not Humanoid or Humanoid.Health <= 0 or Humanoid.Health >= Humanoid.MaxHealth then
			isRegenerating = false
			return
		end

		local healAmount = REGEN_STEP * REGEN_RATE * Humanoid.MaxHealth
		Humanoid.Health = math.min(Humanoid.Health + healAmount, Humanoid.MaxHealth)

		task.delay(REGEN_STEP, RegenStep)
	end

	local BeginRegen = function()
		if isRegenerating or not Humanoid or Humanoid.Health <= 0 then return end
		isRegenerating = true
		task.delay(REGEN_DELAY, RegenStep)
	end

	Humanoid.HealthChanged:Connect(function(health)
		if health > 0 and health < Humanoid.MaxHealth then
			BeginRegen()
		end
	end)

	if Humanoid.Health > 0 and Humanoid.Health < Humanoid.MaxHealth then
		BeginRegen()
	end
end

local function OnCharacterAdded(Character: Model)
	local Humanoid = Character:FindFirstChildOfClass("Humanoid")
	if not Humanoid then return end

	local oldHealthObj = Character:FindFirstChild("Health")
	if oldHealthObj then oldHealthObj:Destroy() end

	StartRegen(Humanoid)
end

local function OnPlayerAdded(Player: Player)
	Player.CharacterAdded:Connect(function(Character)
		OnCharacterAdded(Character)
	end)

	if Player.Character then
		OnCharacterAdded(Player.Character)
	end
end

for _, Player in Players:GetPlayers() do
	OnPlayerAdded(Player)
end

Players.PlayerAdded:Connect(OnPlayerAdded)
