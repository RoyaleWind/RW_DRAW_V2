function Clmsg(data) 
    if debug then 
        print(data)
    end
end

function RotationToDirection(rotation)
	local adjustedRotation =
	{
		x = (math.pi / 180) * rotation.x,
		y = (math.pi / 180) * rotation.y,
		z = (math.pi / 180) * rotation.z
	}
	local direction =
	{
		x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
		y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
		z = math.sin(adjustedRotation.x)
	}
	return direction
end

function RayCastGamePlayCamera(distance)
    local cameraRotation = GetGameplayCamRot()
	local cameraCoord = GetGameplayCamCoord()
	local direction = RotationToDirection(cameraRotation)
	local destination =
	{
		x = cameraCoord.x + direction.x * distance,
		y = cameraCoord.y + direction.y * distance,
		z = cameraCoord.z + direction.z * distance
	}
	local a, b, c, d, e = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, -1, PlayerPedId(), 0))
	return b, c, e
end

function Draw2DText(content, font, colour, scale, x, y)
    SetTextFont(font)
    SetTextScale(scale, scale)
    SetTextColour(colour[1],colour[2],colour[3], 255)
    SetTextEntry("STRING")
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextDropShadow()
    SetTextEdge(4, 0, 0, 0, 255)
    SetTextOutline()
    AddTextComponentString(content)
    DrawText(x, y)
end

function GetPoint(id)
    local run = true
    while run do
            local Wait = 5
            local color = {r = 0, g = 255, b = 0, a = 200}
            local position = GetEntityCoords(PlayerPedId())
            local hit, coords, entity = RayCastGamePlayCamera(1000.0)
            Draw2DText('Raycast Coords: ' .. coords.x .. ' ' ..  coords.y .. ' ' .. coords.z, 4, {255, 255, 255}, 0.4, 0.55, 0.650)
            Draw2DText('Press ~g~E ~w~to POSITION : '..id, 4, {255, 255, 255}, 0.4, 0.55, 0.650 + 0.025)
            Draw2DText('Press ~r~DEL ~w~to CANCEL ', 4, {255, 255, 255}, 0.4, 0.55, 0.650 + 0.050)
            DrawMarker(28, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.1, 0.1, 0.1, color.r, color.g, color.b, color.a, false, true, 2, nil, nil, false)
            if draw then 
                local topLeft = tpm1
                DrawMarker(28, topLeft.x, topLeft.y, topLeft.z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.1, 0.1, 0.1, color.r, color.g, color.b, color.a, false, true, 2, nil, nil, false)
            end
            if IsControlJustReleased(0, 38) then
                run = false
                return(coords)
            end
            if IsControlJustReleased(0, 178) then ---[DEL CANCEL]
                run = false
                return(nil)
            end
        Citizen.Wait(Wait)
	end
end

local IsDrawing = false
function DrawUi()
    if IsDrawing then return end
    IsDrawing = true
    Clmsg("IsDrawing Start")
    -----<<<<
    local TL = GetPoint("[1] TOP LEFT")
    if TL == nil then Clmsg("ACTION CANCELLED") IsDrawing = false return end
    Citizen.Wait(500)
    --
    local TR = GetPoint("[2] TOP RIGHT")
    if TR == nil then Clmsg("ACTION CANCELLED") IsDrawing = false return end
    Citizen.Wait(500)
    --
    local BL = GetPoint("[3] BOTTOM LEFT")
    if BL == nil then Clmsg("ACTION CANCELLED") IsDrawing = false return end
    Citizen.Wait(500)
    --
    local BR = GetPoint("[4] BOTTOM RIGHT")
    if BR == nil then Clmsg("ACTION CANCELLED") IsDrawing = false return end
    Citizen.Wait(500)
    --
    local input = lib.inputDialog('Dialog title', {
        {type = 'number', label = 'Height', description = 'Url Height', required = true, default = 1080},
        {type = 'number', label = 'Width', description = 'Url Width', required = true, default = 1920},
        {type = 'input', label = 'Url', description = 'Url', required = true, default = "https://t4.ftcdn.net/jpg/02/77/71/45/360_F_277714513_fQ0akmI3TQxa0wkPCLeO12Rx3cL2AuIf.jpg"},
    })
    if not input then return end
    local Height = input[1]
    local Width = input[2] 
    local Url = input[3]
    --
    local n_data = { 
        Data = {
            Url = Url,
            Height = Height,
            Width = Width
        },
        Vertices = {
            [1] = TL, -- TOP LEFT  >> ALSO USED FOR ITS POSITION
            [2] = TR, -- TOP RIGHT  
            [3] = BL, -- BOTTOM LEFT
            [4] = BR, -- BOTTOM RIGHT
        },
    }
    TriggerServerEvent("rw_draw++:new", n_data)
    -----<<<<
    IsDrawing = false
    Clmsg("IsDrawing Stop")
end

local dev_on = false
function DevUi()
    Citizen.CreateThread(function ()
        ---
        function Get_nearest()
            PlayerPos = GetEntityCoords(GetPlayerPed(-1))
            local index = nil
            local recor = nil
            for i, v in ipairs(Map) do 
                if #(v.Vertices[1] - PlayerPos) < DATA.Edit_Distance then
                   if recor == nil then 
                        recor = #(v.Vertices[1] - PlayerPos) 
                        index = i
                    else
                        if recor >  #(v.Vertices[1] - PlayerPos)  then 
                            recor = #(v.Vertices[1] - PlayerPos) 
                            index = i
                        end
                    end
                end
            end
            return index
        end
        while dev_on do
            Citizen.Wait(1)
            local id = Get_nearest()
            if id ~= nil then 
                v = Map[id]
                local color = {r = 0, g = 255, b = 0, a = 200}
                DrawMarker(28, v.Vertices[1].x, v.Vertices[1].y, v.Vertices[1].z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.1, 0.1, 0.1, color.r, color.g, color.b, color.a, false, true, 2, nil, nil, false)
                DrawMarker(28, v.Vertices[2].x, v.Vertices[2].y, v.Vertices[2].z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.1, 0.1, 0.1, color.r, color.g, color.b, color.a, false, true, 2, nil, nil, false)
                DrawMarker(28, v.Vertices[3].x, v.Vertices[3].y, v.Vertices[3].z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.1, 0.1, 0.1, color.r, color.g, color.b, color.a, false, true, 2, nil, nil, false)
                DrawMarker(28, v.Vertices[4].x, v.Vertices[4].y, v.Vertices[4].z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.1, 0.1, 0.1, color.r, color.g, color.b, color.a, false, true, 2, nil, nil, false)
                Draw2DText('ID IS: '..v.Uid, 4, {255, 255, 255}, 0.4, 0.55, 0.650)
                Draw2DText('Remove img => rw_draw++/rem '..v.Uid, 4, {255, 255, 255}, 0.4, 0.55, 0.650 + 0.025)
                Draw2DText('Change img => rw_draw++/img '..v.Uid, 4, {255, 255, 255}, 0.4, 0.55, 0.650 + 0.050)
            end
        end
    end)
end

RegisterCommand("rw_draw++/draw", function ()
    DrawUi()
end, true)

RegisterCommand("rw_draw++/rem", function (source, args, rawCommand)
    TriggerServerEvent("rw_draw++:rem", args[1])
end, true)

RegisterCommand("rw_draw++/img", function (source, args, rawCommand)
    local input = lib.inputDialog('Dialog title', {
        {type = 'input', label = 'Url', description = 'Url', required = true, default = "https://t4.ftcdn.net/jpg/02/77/71/45/360_F_277714513_fQ0akmI3TQxa0wkPCLeO12Rx3cL2AuIf.jpg"},
    })
    if not input then return end
    local Url = input[1]
    TriggerServerEvent("rw_draw++:rem", args[1],Url)
end, true)

RegisterCommand("rw_draw++/dev", function ()
    dev_on = not dev_on
    if dev_on then DevUi() end
end, true)


RegisterNetEvent('rw_draw++:cl:add')
AddEventHandler('rw_draw++:cl:add', function(data)
    Map:Add(data)
end)
RegisterNetEvent('rw_draw++:cl:update')
AddEventHandler('rw_draw++:cl:update', function(uid,img)
    Map:UpdateImg(uid,img)
end)
RegisterNetEvent('rw_draw++:cl:rem')
AddEventHandler('rw_draw++:cl:rem', function(uid)
    Map:Rem(uid)
end)
