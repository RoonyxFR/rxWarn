local IdSession = {}
local listeWarns = {}
local users = {}
local staffGrade = nil

local warn_status = false
local menu_warn = RageUI.CreateMenu("Warn", "Options disponibles :")
local menu_warn_joueurs = RageUI.CreateSubMenu(menu_warn, "Warn", "Joueurs sur le serveur :")
local menu_warn_joueurs_warn = RageUI.CreateSubMenu(menu_warn_joueurs, "Warn", "Options disponibles :")
local menu_warn_joueurs_warn_historique = RageUI.CreateSubMenu(menu_warn_joueurs_warn, "Warn", "Historique des sanctions :")
local menu_warn_offline = RageUI.CreateSubMenu(menu_warn, "Warn", "Joueurs offline :")
menu_warn.Closed = function()
    warn_status = false
end

function WarnMenu()
    if warn_status then
        warn_status = false
        RageUI.Visible(menu_warn, false)
        return
    else
        warn_status = true
        RageUI.Visible(menu_warn, true)

        CreateThread(function()
            while warn_status do
                Wait(1)

                RageUI.IsVisible(menu_warn, function()

                    RageUI.Separator(("~o~↓~s~  %s - [~o~%s~s~]  ~o~↓~s~"):format(GetPlayerName(GetPlayerServerId(PlayerPedId())), staffGrade))
                    RageUI.Line()

                    RageUI.Button("Liste des joueurs", nil, {RightLabel = "→→"}, true, {
                        onSelected = function()
                            for k,v in pairs(GetActivePlayers()) do
                                local found = false
                                for _,j in pairs(IdSession) do
                                    if GetPlayerServerId(v) == j then
                                        found = true
                                    end
                                end
                                if not found then
                                    table.insert(IdSession, GetPlayerServerId(v))
                                end
                            end
                        end
                    }, menu_warn_joueurs)

                    RageUI.Button("Avertir un joueur via ID", nil, {RightLabel = "→→"}, true, {
                        onSelected = function()
                            local id = EntrerText("Entrer l'ID de la personne à avertir ", "", 3)
                            if tonumber(id) then
                                local raison = EntrerText("Raison de l'avertissement ", "", 20)

                                if raison == "" then
                                    Notification("[~r~Erreur~s~] Impossible de mettre un avertissement sans entrer de raison.")
                                else
                                    if raison ~= nil then
                                        TriggerServerEvent("rx:WarnPlayer", tonumber(id), raison)
                                    end
                                end
                            else
                                Notification("[~r~Erreur~s~] Veuillez mettre un chiffre.")
                            end
                        end
                    })

                    RageUI.Button("Avertir un joueur étant Offline", nil, {RightLabel = "→→"}, true, {
                        onSelected = function()
                            ESX.TriggerServerCallback("rx:PlayerOffline", function(data)
                                users = data
                            end)
                        end
                    }, menu_warn_offline)
                end)

                RageUI.IsVisible(menu_warn_joueurs, function()

                    RageUI.Separator("~o~↓↓~s~  Liste des joueurs  ~o~↓↓~s~")
                    RageUI.Line()

                    for k,v in ipairs(IdSession) do
                        if GetPlayerName(GetPlayerFromServerId(v)) == "**Invalid**" then table.remove(IdSession, k) end

                        RageUI.Button("[".. v .."] - " .. GetPlayerName(GetPlayerFromServerId(v)), nil, {RightLabel = "→→"}, true, {
                            onSelected = function()
                                IdSelected = v
                            end
                        }, menu_warn_joueurs_warn)
                    end
                end)

                RageUI.IsVisible(menu_warn_joueurs_warn, function()

                    RageUI.Separator(("~o~↓↓~w~  [%s] - %s  ~o~↓↓~w~"):format(IdSelected, GetPlayerName(GetPlayerFromServerId(IdSelected))))
                    RageUI.Line()

                    RageUI.Button("Historique des avertissements", nil, {RightLabel = "→→"}, true, {
                        onSelected = function()
                            local data = {}
                            ESX.TriggerServerCallback("rx:ListeWarn", function(data)
                                listeWarns = data
                            end, tonumber(IdSelected))
                        end
                    }, menu_warn_joueurs_warn_historique)

                    RageUI.Button("Avertir le joueur", nil, {RightLabel = "→→"}, true, {
                        onSelected = function()
                            local raison = EntrerText("Raison de l'avertissement ", "", 20)

                            if raison == "" then
                                Notification("[~r~Erreur~s~] Impossible de mettre un avertissement sans entrer de raison.")
                            else
                                if raison ~= nil then
                                    TriggerServerEvent("rx:WarnPlayer", IdSelected, raison)
                                end
                            end
                        end
                    })

                    RageUI.Button("Déconnectez le joueur", nil, {RightLabel = "→→"}, true, {
                        onSelected = function()
                            local kickRaison = EntrerText("Raison du kick ", "", 100)

                            if kickRaison == "" then
                                Notification("[~r~Erreur~s~] Impossible de kick sans raison.")
                            else
                                if kickRaison ~= nil then
                                    TriggerServerEvent("rx:KickPlayer", IdSelected, kickRaison)
                                end
                            end
                        end
                    })
                end)

                RageUI.IsVisible(menu_warn_joueurs_warn_historique, function()

                    if #listeWarns >= 1 then

                        RageUI.Separator("~b~↓↓~s~  Liste des avertissements  ~b~↓↓~s~")
                        RageUI.Line()

                        for k,v in pairs(listeWarns) do
                            RageUI.Button(("%s - %s"):format(k, v.raison), ("Averti le : %s\nAverti par : %s"):format(v.date, v.warn_by), {RightLabel = "~r~Supprimer~s~ →→"}, true, {
                                onSelected = function()
                                    local verification = EntrerText("Entrer 'Oui' pour supprimer cet avertissement", "", 3)

                                    if verification == "Oui" then
                                        TriggerServerEvent("rx:RemoveWarn", v.id)
                                        Wait(300)
                                        ESX.TriggerServerCallback("rx:ListeWarn", function(data)
                                            listeWarns = data
                                        end, tonumber(IdSelected))
                                    else
                                        Notification("[~r~Erreur~s~] Syntaxe incorrect.")
                                    end
                                end
                            })
                        end
                    else
                        RageUI.Separator("")
                        RageUI.Separator("~g~Aucun avertissement~s~")
                        RageUI.Separator("")
                    end
                end)

                RageUI.IsVisible(menu_warn_offline, function()
                    for k,v in pairs(users) do
                        RageUI.Button(("%s %s"):format(v.firstname, v.lastname), ("License : %s"):format(v.identifier), {RightLabel = "~g~Avertir~s~ →→"}, true, {
                            onSelected = function()
                                local raison = EntrerText("Raison de l'avertissement ", "", 20)

                                if raison == "" then
                                    Notification("[~r~Erreur~s~] Impossible de mettre un avertissement sans entrer de raison.")
                                else
                                    if raison ~= nil then
                                        TriggerServerEvent("rx:WarnPlayerOffline", v.identifier, raison)
                                    end
                                end
                            end
                        })
                    end
                end)
            end
        end)
    end
end

RegisterKeyMapping("warn", "Menu de warn", "keyboard", "F10")
RegisterCommand("warn", function()
    ESX.TriggerServerCallback('rx:GetUserGroup', function(group)
        if group ~= "user" then
            if warn_status == false then
                staffGrade = group
                WarnMenu()
            end
        else
            Notification("[~r~Erreur~s~] Vous n'avez pas la permissions d'accéder à ce menu.")
        end
    end, GetPlayerServerId(PlayerId()))
end)