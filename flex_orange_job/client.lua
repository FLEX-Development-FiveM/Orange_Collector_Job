ESX = exports['es_extended']:getSharedObject()

local orangesCollected = 0
local maxOranges = 25
local orangeCoords = vector3(244.5333, 6521.2788, 31.0889)
local startCoords = vector3(1701.31, 4916.18, 42.06)
local burritoCoords = vector3(1717.5500, 4932.2866, 42.0847) -- Neue Koordinaten
local burritoHeading = 15.2327 -- Neue Richtung
local casinoCoords = vector3(924.98, 47.89, 80.89)

local isInJob = false
local blip = nil
local inBurrito = false
local burrito = nil
local collectingOranges = false
local currentStep = ""
local stepCompleted = {start = false, collect = false, sell = false}

-- Blip für den Startmarker hinzufügen
Citizen.CreateThread(function()
    local blip = AddBlipForCoord(startCoords.x, startCoords.y, startCoords.z)
    SetBlipSprite(blip, 1)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.8)
    SetBlipColour(blip, 2)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Orangen Job Start")
    EndTextCommandSetBlipName(blip)
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerCoords = GetEntityCoords(PlayerPedId())

        -- Job Start Marker
        if not stepCompleted.start then
            DrawMarker(1, startCoords.x, startCoords.y, startCoords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0, 255, 0, 100, false, true, 2, false, nil, nil, false)
            if GetDistanceBetweenCoords(playerCoords, startCoords, true) < 1.0 then
                ESX.ShowHelpNotification("Drücke ~INPUT_CONTEXT~ um den Orangen-Sammel-Job zu starten")
                if IsControlJustReleased(0, 38) then
                    isInJob = true
                    ESX.ShowNotification("Job gestartet! Fahre mit dem Burrito zum Orangenfeld")
                    SpawnBurrito()
                    SetNewWaypoint(orangeCoords.x, orangeCoords.y)
                    blip = AddBlipForCoord(orangeCoords.x, orangeCoords.y, orangeCoords.z)
                    SetBlipSprite(blip, 1)
                    SetBlipDisplay(blip, 4)
                    SetBlipScale(blip, 0.8)
                    SetBlipColour(blip, 47)
                    BeginTextCommandSetBlipName("STRING")
                    AddTextComponentString("Orange Sammeln")
                    EndTextCommandSetBlipName(blip)
                    currentStep = "Fahre mit dem Burrito zum Orangenfeld"
                    stepCompleted.start = true
                end
            end
        end

        if isInJob and not stepCompleted.collect then
            -- Orange Collection Marker
            DrawMarker(1, orangeCoords.x, orangeCoords.y, orangeCoords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 10.0, 10.0, 1.0, 255, 165, 0, 100, false, true, 2, false, nil, nil, false)
            if GetDistanceBetweenCoords(playerCoords, orangeCoords, true) < 10.0 and not collectingOranges then
                ESX.ShowHelpNotification("Drücke ~INPUT_CONTEXT~ um Orangen zu sammeln")
                if IsControlJustReleased(0, 38) then
                    collectingOranges = true
                    ESX.ShowNotification("Sammeln von Orangen gestartet")
                    currentStep = "Sammle 25 Orangen"
                    Citizen.CreateThread(function()
                        while collectingOranges and orangesCollected < maxOranges do
                            Citizen.Wait(5000)
                            local playerCoordsDuringCollecting = GetEntityCoords(PlayerPedId())
                            if not collectingOranges or GetDistanceBetweenCoords(playerCoordsDuringCollecting, orangeCoords, true) > 10.0 then
                                collectingOranges = false
                                ESX.ShowNotification("Sammeln der Orangen unterbrochen. Gehe zurück zum Marker, um weiter zu sammeln.")
                                break
                            end
                            orangesCollected = orangesCollected + 1
                            ESX.ShowNotification("Du hast eine Orange gesammelt. Gesamt: " .. orangesCollected)
                            TriggerServerEvent('orangeJob:collectOrange')
                            if orangesCollected >= maxOranges then
                                collectingOranges = false
                                ESX.ShowNotification("Du hast 25 Orangen gesammelt.")
                                RemoveBlip(blip)
                                SetNewWaypoint(casinoCoords.x, casinoCoords.y)
                                blip = AddBlipForCoord(casinoCoords.x, casinoCoords.y, casinoCoords.z)
                                SetBlipSprite(blip, 1)
                                SetBlipDisplay(blip, 4)
                                SetBlipScale(blip, 0.8)
                                SetBlipColour(blip, 47)
                                BeginTextCommandSetBlipName("STRING")
                                AddTextComponentString("Casino - Orangen Verkauf")
                                EndTextCommandSetBlipName(blip)
                                inBurrito = true
                                currentStep = "Fahre zum Casino und verkaufe die Orangen"
                                stepCompleted.collect = true
                            end
                        end
                    end)
                end
            end
        end

        if inBurrito and not stepCompleted.sell then
            -- Casino Verkaufsmarker
            DrawMarker(1, casinoCoords.x, casinoCoords.y, casinoCoords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0, 255, 0, 100, false, true, 2, false, nil, nil, false)
            if GetDistanceBetweenCoords(playerCoords, casinoCoords, true) < 1.0 then
                ESX.ShowHelpNotification("Drücke ~INPUT_CONTEXT~ um die Orangen zu verkaufen")
                if IsControlJustReleased(0, 38) then
                    TriggerServerEvent('orangeJob:sellOranges')
                    inBurrito = false
                    RemoveBlip(blip)
                    DeleteVehicle(burrito)
                    ESX.ShowNotification("Orangen verkauft! Job abgeschlossen.")
                    currentStep = ""
                    stepCompleted.sell = true
                end
            end
        end

        if currentStep ~= "" then
            DrawTextOnScreen(currentStep, 0.5, 0.95)
        end

        -- Check if Burrito is destroyed or despawned
        if isInJob and burrito and (not DoesEntityExist(burrito) or IsEntityDead(burrito)) then
            if not IsEntityDead(burrito) then
                ESX.ShowNotification("Burrito wurde zerstört. Job abgebrochen.")
            end
            EndJob()
        end
    end
end)

function DrawTextOnScreen(text, x, y)
    SetTextFont(0)
    SetTextProportional(1)
    SetTextScale(0.0, 0.5)
    SetTextColour(255, 255, 255, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - 0.1, y - 0.02)
end

function SpawnBurrito()
    local model = GetHashKey('burrito3')
    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(0)
    end
    burrito = CreateVehicle(model, burritoCoords.x, burritoCoords.y, burritoCoords.z, burritoHeading, true, false)
    SetVehicleNumberPlateText(burrito, "ORANGES")
    TaskWarpPedIntoVehicle(PlayerPedId(), burrito, -1)
end

function EndJob()
    isInJob = false
    inBurrito = false
    collectingOranges = false
    RemoveBlip(blip)
    if DoesEntityExist(burrito) then
        DeleteVehicle(burrito)
    end
    orangesCollected = 0
    currentStep = ""
    stepCompleted = {start = false, collect = false, sell = false}
end
