ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-----------------------------------------------> Verification group <-----------------------------------------------

ESX.RegisterServerCallback('rx:GetUserGroup', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local group = xPlayer.getGroup()
    cb(group)
end)

-----------------------------------------------> Historique du joueur <-----------------------------------------------

ESX.RegisterServerCallback(("rx:ListeWarn"), function(source, cb, target)
    local xPlayer = ESX.GetPlayerFromId(target)
    warnList = {}

    MySQL.Async.fetchAll("SELECT * FROM warns WHERE identifier = @identifier", {['@identifier'] = xPlayer.identifier}, function(data)

        for k, v in pairs(data) do
            table.insert(warnList, {
                id 			= v.id,
                raison 		= v.raison,
                date 		= v.date,
                warn_by 	= v.warn_by,
            })
        end
        cb(warnList)
    end)
end)

RegisterServerEvent("rx:RemoveWarn")
AddEventHandler("rx:RemoveWarn", function(id)
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer.getGroup() ~= "user" then
        MySQL.Async.execute("DELETE FROM warns WHERE id = @id", {
            ["@id"] = id
        }, function()
        end)
        TriggerClientEvent('esx:showNotification', source, "[~g~Succès~s~] Vous avez supprimé un avertissement.")
    else
        TriggerClientEvent('esx:showNotification', source, "[~r~Erreur~s~] Vous n'avez pas la permission pour retirer un warn.")
    end
end)

-----------------------------------------------> Avertir le joueur <-----------------------------------------------

RegisterServerEvent("rx:WarnPlayer")
AddEventHandler("rx:WarnPlayer", function(IdSelected, raison)
    local xPlayer = ESX.GetPlayerFromId(IdSelected)
    local xPlayerStaff = ESX.GetPlayerFromId(source)
    print(xPlayerStaff)

    if xPlayerStaff.getGroup() ~= "user" then
        if xPlayer ~= nil then
            MySQL.Async.execute("INSERT INTO warns (identifier, raison, date, warn_by, identifier_warn_by) VALUES (@a, @b, @c, @d, @e)", {
                ["@a"] = xPlayer.identifier,
                ["@b"] = raison,
                ["@c"] = os.date("%d/%m/%y à %Hh%M"),
                ["@d"] = xPlayerStaff.getName(),
                ["@e"] = xPlayerStaff.identifier,
            }, function()
            end)
            TriggerClientEvent('esx:showNotification', source, ("[~g~Succès~s~] Vous avez averti le joueur ~r~%s~s~ pour ~g~%s"):format(xPlayer.getName(), raison))
            TriggerClientEvent('esx:showNotification', xPlayer.source, ("Vous avez été averti par ~o~%s~s~ pour ~r~%s"):format(xPlayerStaff.getName(), raison))
        else
            TriggerClientEvent('esx:showNotification', xPlayerStaff.source, "[~r~Erreur~s~] Cet ID n'existe pas.")
        end
    else
        TriggerClientEvent('esx:showNotification', source, "[~r~Erreur~s~] Vous n'avez pas la permission pour avertir un joueur.")
    end
end)

-----------------------------------------------> Déconnectez le joueur <-----------------------------------------------

RegisterServerEvent("rx:KickPlayer")
AddEventHandler("rx:KickPlayer", function(IdSelected, kickRaison)
    local xPlayer = ESX.GetPlayerFromId(IdSelected)
    local xPlayerStaff = ESX.GetPlayerFromId(source)

    if xPlayerStaff.getGroup() ~= "user" then
        TriggerClientEvent('esx:showNotification', source, ("Vous avez déconnectez ~o~%s~s~ pour ~g~%s"):format(xPlayer.getName(), kickRaison))
        DropPlayer(xPlayer.source, ("Par le staff : %s\nRaison de la déconnexion : %s"):format(xPlayerStaff.getName(), kickRaison))
    else
        TriggerClientEvent('esx:showNotification', source, "[~r~Erreur~s~] Vous n'avez pas la permission pour déconnecter un joueur.")
    end
end)

-----------------------------------------------> Avertir offline <-----------------------------------------------

ESX.RegisterServerCallback("rx:PlayerOffline", function(source, cb)
    local userList = {}

    MySQL.Async.fetchAll("SELECT * FROM users ", {}, function(data)

        for k, v in pairs(data) do
            table.insert(userList, {
                identifier = v.identifier,
                firstname = v.firstname,
                lastname = v.lastname
            })
        end
        cb(userList)
    end)
end)

RegisterServerEvent("rx:WarnPlayerOffline")
AddEventHandler("rx:WarnPlayerOffline", function(license, raison)
    local xPlayer = license
    local xPlayerStaff = ESX.GetPlayerFromId(source)

    if xPlayerStaff.getGroup() ~= "user" then
        if xPlayer ~= nil then
            MySQL.Async.execute("INSERT INTO warns (identifier, raison, date, warn_by, identifier_warn_by) VALUES (@a, @b, @c, @d, @e)", {
                ["@a"] = xPlayer,
                ["@b"] = raison,
                ["@c"] = os.date("%d/%m/%y à %Hh%M"),
                ["@d"] = xPlayerStaff.getName(),
                ["@e"] = xPlayerStaff.identifier,
            }, function()
            end)
            TriggerClientEvent('esx:showNotification', source, ("[~g~Succès~s~] Vous avez averti le joueur pour ~g~%s"):format(raison))
        else
            TriggerClientEvent('esx:showNotification', xPlayerStaff.source, "[~r~Erreur~s~] Cet license n'existe pas.")
        end
    else
        TriggerClientEvent('esx:showNotification', source, "[~r~Erreur~s~] Vous n'avez pas la permission pour avertir un joueur.")
    end
end)
