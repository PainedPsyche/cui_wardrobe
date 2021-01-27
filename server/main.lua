ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local processing = {}

ESX.RegisterServerCallback('cui_wardrobe:saveOutfit', function(source, cb, data)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.identifier
    local slot = tonumber(data['slot'])

    if slot > Config.SlotsNumber then
        cb(false)
        return
    end

    -- Safeguard from trying to do this too fast on one slot
    if not processing[identifier] then
        processing[identifier] = {}
    end

    if not processing[identifier][slot] then
        processing[identifier][slot] = true
        Citizen.CreateThread(function()
            local name = data['name']
            local clothes = data['clothes']

            -- TODO: Validate data (name?)
            MySQL.Async.fetchScalar('SELECT 1 FROM outfits WHERE owner = @identifier AND slot = @slot', {
                ['@identifier'] = identifier,
                ['@slot'] = slot
            }, function(exists)
                -- TODO: Maybe split new (insert into) and edit (update) ?
                if exists then
                    MySQL.Async.execute('UPDATE outfits SET name = @name, clothes = @clothes WHERE owner = @identifier AND slot = @slot', {
                        ['@identifier'] = identifier,
                        ['@slot'] = slot,
                        ['@name'] = name,
                        ['@clothes'] = json.encode(clothes)
                    }, function(rowsChanged)
                        if rowsChanged then
                            cb(true)
                        else
                            cb(false)
                        end
                        processing[identifier][slot] = nil
                    end)
                else
                    MySQL.Async.execute('INSERT INTO outfits (owner, slot, name, clothes) VALUES (@identifier, @slot, @name, @clothes)', {
                        ['@identifier'] = identifier,
                        ['@slot'] = slot,
                        ['@name'] = name,
                        ['@clothes'] = json.encode(clothes)
                    }, function(rowsChanged)
                        if rowsChanged then
                            cb(true)
                        else
                            cb(false)
                        end
                        processing[identifier][slot] = nil
                    end)
                end
            end)
        end)
    else
        -- Save request already pending, do nothing/fail
        cb(false)
        return
    end
end)

ESX.RegisterServerCallback('cui_wardrobe:deleteOutfit', function(source, cb, slot)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.identifier

    if slot > Config.SlotsNumber then
        cb(false)
        return
    end

    -- Safeguard from trying to do this too fast on one slot
    if not processing[identifier] then
        processing[identifier] = {}
    end

    if not processing[identifier][slot] then
        processing[identifier][slot] = true
        Citizen.CreateThread(function()
            MySQL.Async.fetchScalar('SELECT 1 FROM outfits WHERE owner = @identifier AND slot = @slot', {
                ['@identifier'] = identifier,
                ['@slot'] = slot
            }, function(exists)
                if exists then
                    MySQL.Async.execute('DELETE FROM outfits WHERE owner = @identifier AND slot = @slot', {
                        ['@identifier'] = identifier,
                        ['@slot'] = slot
                    }, function(rowsChanged)
                        if rowsChanged then
                            cb(true)
                        else
                            cb(false)
                        end
                        processing[identifier][slot] = nil
                    end)
                else
                    cb(false)
                    processing[identifier][slot] = nil
                end
            end)
        end)
    else
        -- Delete request already pending, do nothing/fail
        cb(false)
        return
    end
end)

ESX.RegisterServerCallback('cui_wardrobe:getPlayerOutfits', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)

    MySQL.Async.fetchAll('SELECT slot, name, clothes FROM outfits WHERE owner = @identifier', {
        ['@identifier'] = xPlayer.identifier
    }, function(result)
        local outfits = {}

        if result ~= nil then
            for k, v in pairs(result) do
                outfits[v.slot] = { name = v.name, data = json.decode(v.clothes) }
            end
        end

        cb(outfits)
    end)
end)

ESX.RegisterServerCallback('cui_wardrobe:getOutfitInSlot', function(source, cb, slot)
    local xPlayer = ESX.GetPlayerFromId(source)

    MySQL.Async.fetchAll('SELECT name, clothes FROM outfits WHERE owner = @identifier AND slot = @slot', {
        ['@identifier'] = xPlayer.identifier,
        ['@slot'] = slot
    }, function(result)
        local outfit = {}

        if result[1] ~= nil then
            outfit = { name = result[1]['name'], data = json.decode(result[1]['clothes']) }
        end

        cb(outfit)
    end)
end)

if Config.UseAnywhere then
    ESX.RegisterCommand('wardrobe', 'user', function(xPlayer, args, showError)
        xPlayer.triggerEvent('cui_wardrobe:open')
        end, false, {help = 'Open wardrobe.', validate = true, arguments = {}
    })
else
    ESX.RegisterCommand('wardrobe', 'admin', function(xPlayer, args, showError)
        xPlayer.triggerEvent('cui_wardrobe:open')
        end, true, {help = 'Open wardrobe.', validate = true, arguments = {}
    })
end