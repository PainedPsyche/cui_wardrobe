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
    setVisible(true)
end)

RegisterNetEvent('cui_wardrobe:close')
AddEventHandler('cui_wardrobe:close', function()
    setVisible(false)
end)

RegisterNUICallback('close', function(data, cb)
    TriggerEvent('cui_wardrobe:close')
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