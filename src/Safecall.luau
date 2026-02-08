local RunService = game:GetService("RunService")

local IS_CLIENT = RunService:IsClient()
local PRINT_IDENTIFIER = if IS_CLIENT then "[C]" else "[S]"

return function(f: (...any) -> ...any, errorMessage: string?, ...: any)
	local success, result = xpcall(f, function(err)
		warn(`{PRINT_IDENTIFIER} {errorMessage}\n{err}\n{debug.traceback()}`)
	end, ...)
	return success and result or nil
end
