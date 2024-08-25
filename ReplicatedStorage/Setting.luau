local settings = {}
-- amount of towers
settings.Towers = 2
-- max round time
settings.MaxTime = 60*2
-- rate of timer update (in seconds) it's pretty useless lol
settings.TimerStep = 1
-- making table read-only (constant)
table.freeze(settings)
return settings
