Config = {}

Config.HideMinimapOnOpen = false
Config.SlotsNumber = 5

--[[
    UseAnywhere

    If you set this to true a command /wardrobe will be available
    to every user and below locations will not be used.

    If you set this to false, the /wardrobe command
    will be available only to admins and wardrobe will be able
    to be opened by users at the locations defined in the table below.
--]]
Config.UseAnywhere = false
Config.DisplayBlips = true
Config.Locations = {
    -- default locations
    vector3(-811.80, 175.10, 76.80),    -- Michael's house wardrobe
    vector3(8.84, 528.15, 170.81),      -- Franklin's Vinewood house wardrobe
    vector3(-18.0, -1439.0, 31.2),      -- Franklin's old room
    vector3(-1153.13, -1516.95, 10.82), -- Floyd's house in La Puerta
    vector3(-109.71, -11.97, 70.51)     -- Harvey Molina's apartment
}