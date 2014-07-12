-- taken from DarkRP's script
local ChatCommands = {}

function AddChatCommand(cmd, callback, prefixconst)
	for k,v in pairs(ChatCommands) do
		if cmd == v.cmd then return end
	end
	table.insert(ChatCommands, { cmd = cmd, callback = callback, prefixconst = prefixconst })
end