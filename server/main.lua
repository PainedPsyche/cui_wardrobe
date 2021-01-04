ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterCommand('wardrobe', 'user', function(xPlayer, args, showError)
	xPlayer.triggerEvent('cui_wardrobe:open')
    end, true, {help = 'Open wardrobe.', validate = true, arguments = {}
})