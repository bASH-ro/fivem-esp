State = {
    playerNames = false,
}

function toggleESP(enable)
    if enable == State.playerNames then return end 

    State.playerNames = enable  

    if enable then
        Citizen.CreateThread(function()
            while State.playerNames do  
                Citizen.Wait(0)
                local PlayerList = GetActivePlayers()
                local playerPed = PlayerPedId()
                local px, py, pz = table.unpack(GetEntityCoords(playerPed, true))

                for i = 1, #PlayerList do
                    if not State.playerNames then break end 

                    local playerId = PlayerList[i]
                    local curplayerped = GetPlayerPed(playerId)

                    if curplayerped ~= playerPed then 
                        local bone = GetEntityBoneIndexByName(curplayerped, "SKEL_HEAD")
                        local x, y, z = table.unpack(GetPedBoneCoords(curplayerped, bone, 0.0, 0.0, 0.0))

                        z = z + 1.2 

                        local distance = math.floor(GetDistanceBetweenCoords(px, py, pz, x, y, z, true))

                        if distance < 500 and IsEntityOnScreen(curplayerped) then
                            local retval, _x, _y = GetScreenCoordFromWorldCoord(x, y, z)

                            if retval then 
                                local playerName = GetPlayerName(playerId)
                                local pId = GetPlayerServerId(playerId)
                                local isTalking = NetworkIsPlayerTalking(playerId)

                                DrawText3D(x, y, z, playerName .. " | ID: " .. pId .. " | " .. distance .. "m", isTalking)
                            end
                        end
                    end
                end
            end  
        end)
    else
        State.playerNames = false
        Citizen.Wait(100) 
    end
end


function DrawText3D(x, y, z, text, isTalking)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)

    if onScreen then
        SetTextFont(0)
        SetTextProportional(0)
        SetTextScale(0.18, 0.18)
        if isTalking then
            SetTextDropshadow(5, 5, 5, 5, 255)
            SetTextEdge(5, 0, 0, 0, 150)
            SetTextColour(50, 255, 50, 255)
        else
            SetTextDropshadow(0, 0, 0, 0, 255)
            SetTextEdge(5, 0, 0, 0, 150)
            SetTextColour(255, 255, 255, 255)
        end

        SetTextDropShadow()
        SetTextOutline()
        SetTextCentre(1)
        SetTextEntry("STRING")
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

function GetPedBoneCoordsF(ped, boneId)
    local cam = GetFinalRenderedCamCoord()
    local boneCoords = GetPedBoneCoords(ped, boneId)

    local ret, hit, shape = GetShapeTestResult(
        StartShapeTestRay(cam, boneCoords, -1)
    )

    if hit then
        local a = Vdist(cam, shape) / Vdist(cam, boneCoords)
        if a > 1 then a = 0.83 end
        return ((boneCoords - cam) * (a * 0.83)) + cam
    end

    return boneCoords
end
