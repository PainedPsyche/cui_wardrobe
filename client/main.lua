function dump(o)
    if type(o) == 'table' then
    local s = '{ '
    for k,v in pairs(o) do
        if type(k) ~= 'number' then k = '"'..k..'"' end
        s = s .. '['..k..'] = ' .. dump(v) .. ','
    end
    return s .. '} '
    else
    return tostring(o)
    end
end

function dumpToChat(arg)
    local argVals
    if type(arg) == 'table' then
        argVals = {'Me', dump(arg)}
    else
        argVals = {'Me', arg}
    end 
    TriggerEvent('chat:addMessage', {
        color = { 255, 0, 0},
        multiline = true,
        args = argVals
    })
end

ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

local isVisible = false
local isOpening = false
local outfits = {}

function setVisible(visible)
    SetNuiFocus(visible, visible)
    SendNUIMessage({
        action = 'setVisible',
        value = visible
    })
    isVisible = visible

    if Config.HideMinimapOnOpen then
        DisplayRadar(not visible)
    end
end

function refreshUI()
    local html = ''
    local emptyName = 'Empty slot'
    for i = 1, Config.SlotsNumber do
        if outfits[i] ~= nil then
            -- existing outfit
            html = html .. '<div class="slot" data-number="' .. i .. '"><span class="slot-text">' .. outfits[i].name ..'</span><div class="controls"><button class="edit"></button><button class="clear"></button></div></div>'
        else
            -- empty slot
            html = html .. '<div class="slot empty" data-number="' .. i .. '"><span class="slot-text">' .. emptyName ..'</span><div class="controls"><button class="edit"></button></div></div>'
        end
    end
    SendNUIMessage({
        action = 'refresh',
        html = html
    })
end

RegisterNetEvent('cui_wardrobe:open')
AddEventHandler('cui_wardrobe:open', function()
    if not isOpening then
        isOpening = true
        isDataLoaded = false
        RequestStreamedTextureDict('shared')

        ESX.TriggerServerCallback('cui_wardrobe:getPlayerOutfits', function(data)
            if data ~= nil then
                outfits = data
            else
                outfits = {}
            end
            isDataLoaded = true
        end)

        while not HasStreamedTextureDictLoaded('shared') or not isDataLoaded do
            Wait(100)
        end

        refreshUI()
        setVisible(true)
        isOpening = false
    end
end)

RegisterNetEvent('cui_wardrobe:close')
AddEventHandler('cui_wardrobe:close', function()
    SetStreamedTextureDictAsNoLongerNeeded('shared')
    setVisible(false)
end)

RegisterNUICallback('close', function(data, cb)
    TriggerEvent('cui_wardrobe:close')
end)

RegisterNUICallback('save', function(data, cb)
    ESX.TriggerServerCallback('cui_wardrobe:saveOutfit', function(callback)
        if callback then
            -- TODO: save success
            SendNUIMessage({
                action = 'completeEdit',
                slot = tonumber(data['slot']),
                name = data['name']
            })
        else
            -- TODO: save failure
            print('error: failed saving to the database.')
        end
    end, data)
end)

RegisterNUICallback('clear', function(data, cb)
    ESX.TriggerServerCallback('cui_wardrobe:deleteOutfit', function(callback)
        if callback then
            SendNUIMessage({
                action = 'completeDeletion',
                slot = tonumber(data['slot'])
            })
        else
            SendNUIMessage({
                action = 'abortDeletion',
            })
        end
    end, tonumber(data['slot']))
end)

Citizen.CreateThread(function()
    while true do
        if isVisible then
            DisableControlAction(0, 1, true)
            DisableControlAction(0, 2, true)
        end
        Citizen.Wait(0)
    end
end)