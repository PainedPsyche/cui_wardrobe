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

RegisterNetEvent('cui_wardrobe:open')
AddEventHandler('cui_wardrobe:open', function(outfits)
    RequestStreamedTextureDict('shared')
    while not HasStreamedTextureDictLoaded('shared') do
        Wait(100)
    end

    --[[
    ESX.TriggerServerCallback('cui_wardrobe:getPlayerOutfits', function(outfits)
        dumpToChat(outfits)
    end)

    ESX.TriggerServerCallback('cui_wardrobe:getOutfitInSlot', function(outfit)
        dumpToChat(outfit)
    end, 1)
    --]]

    setVisible(true)
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