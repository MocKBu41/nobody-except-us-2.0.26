-- NEU runtime command/API diagnostics. Failure here must never stop the bot.
local okProbe, probe = pcall(require, [[/script/multiplayer/bot.command_probe]])
if okProbe and type(probe) == 'table' and type(probe.install) == 'function' then
    pcall(probe.install)
end

return require([[/script/multiplayer/bot.v1_22.logic]])
