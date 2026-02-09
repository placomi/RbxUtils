--!strict

local observePlayer = require(script.Parent.observePlayer)

type PlayerCallback = (player: Player) -> ((string) -> ())?
type CharacterCallback = (player: Player, character: Model) -> (() -> ())?

--[=[
	@within Observers

	Creates an observer that captures each character in the game.

	```lua
	observeCharacter(function(player, character)
		print("Character spawned for " .. player.Name)

		return function()
			-- Cleanup
			print("Character removed for " .. player.Name)
		end
	end)
	```

	An optional `allowedPlayers` array can be provided. Only characters
	belonging to players in the array are observed.

	```lua
	observeCharacter(function(player, character)
		-- ...
	end, { somePlayer, anotherPlayer })
	```
]=]
local function observeCharacter(playerCallback: PlayerCallback, callback: CharacterCallback): () -> ()
	return observePlayer(function(player)
		local playerCleanupFn: ((string) -> ())? = playerCallback(player)
		local characterCleanupFn: (() -> ())? = nil

		local characterAddedConn: RBXScriptConnection

		local function OnCharacterAdded(character: Model)
			local currentCharCleanup: (() -> ())? = nil

			-- Call the callback:
			task.defer(function()
				local cleanup = (callback :: any)(player, character)
				-- If a cleanup function is given, save it for later:
				if typeof(cleanup) == "function" then
					if characterAddedConn.Connected and character.Parent then
						currentCharCleanup = cleanup
						characterCleanupFn = cleanup
					else
						-- Character is already gone or observer has stopped; call cleanup immediately:
						task.spawn(cleanup)
					end
				end
			end)

			-- Watch for the character to be removed from the game hierarchy:
			local ancestryChangedConn: RBXScriptConnection
			ancestryChangedConn = character.AncestryChanged:Connect(function(_, newParent)
				if newParent == nil and ancestryChangedConn.Connected then
					ancestryChangedConn:Disconnect()
					if currentCharCleanup ~= nil then
						task.spawn(currentCharCleanup)
						if characterCleanupFn == currentCharCleanup then
							characterCleanupFn = nil
						end
						currentCharCleanup = nil
					end
				end
			end)
		end

		-- Handle character added:
		characterAddedConn = player.CharacterAdded:Connect(OnCharacterAdded)

		-- Handle initial character:
		task.defer(function()
			if player.Character and characterAddedConn.Connected then
				task.spawn(OnCharacterAdded, player.Character)
			end
		end)

		-- Cleanup:
		return function(exitReason: string)
			if playerCleanupFn ~= nil then
				task.spawn(playerCleanupFn, exitReason)
				playerCleanupFn = nil
			end
			characterAddedConn:Disconnect()
			if characterCleanupFn ~= nil then
				task.spawn(characterCleanupFn)
				characterCleanupFn = nil
			end
		end
	end)
end

return observeCharacter
