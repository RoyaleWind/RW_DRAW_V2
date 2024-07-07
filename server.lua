local MAP = {}
local loaded = false

Citizen.CreateThread(function ()
    for k,v in pairs(load()) do 
        v.Vertices = {
            [1] = vector3(v.Vertices[1].x,v.Vertices[1].y,v.Vertices[1].z),
            [2] = vector3(v.Vertices[2].x,v.Vertices[2].y,v.Vertices[2].z),
            [3] = vector3(v.Vertices[3].x,v.Vertices[3].y,v.Vertices[3].z),
            [4] = vector3(v.Vertices[4].x,v.Vertices[4].y,v.Vertices[4].z),
        }
        table.insert(MAP,v)
    end
    loaded = true
    print("loaded")
end)

function GetNewUid()
    local max = 0
    for k,v in pairs(MAP) do
        if max < v.Uid then max = v.Uid end
    end
    return max + 1
end

RegisterNetEvent('rw_draw++:GetData')
AddEventHandler('rw_draw++:GetData', function()
    local src = source
    while not loaded do
        Citizen.Wait(100)
    end
    TriggerClientEvent('rw_draw++:cl:init',src,MAP)
end)


RegisterNetEvent('rw_draw++:new')
AddEventHandler('rw_draw++:new', function(data)
    local src = source
    while not loaded do
        Citizen.Wait(100)
    end
    if not IsPlayerAceAllowed(src,"command") then return end
    data.Uid = GetNewUid()
    table.insert(MAP,data)
    TriggerClientEvent('rw_draw++:cl:add',src,data)
    save()
end)
RegisterNetEvent('rw_draw++:rem')
AddEventHandler('rw_draw++:rem', function(uid)
    local src = source
    while not loaded do
        Citizen.Wait(100)
    end
    if not IsPlayerAceAllowed(src,"command") then return end
    for i,v in pairs(MAP)do 
        if uid == v.Uid then 
            table.remove(MAP,i)
        end
    end
    TriggerClientEvent('rw_draw++:cl:rem',src,uid)
    save()
end)
RegisterNetEvent('rw_draw++:update')
AddEventHandler('rw_draw++:update', function(uid,url)
    local src = source
    while not loaded do
        Citizen.Wait(100)
    end
    if not IsPlayerAceAllowed(src,"command") then return end
    for k,v in pairs(MAP)do 
        if uid == v.Uid then 
            v.Data.Url = url
        end
    end
    TriggerClientEvent('rw_draw++:cl:update',src,uid,url)
    save()
end)

function load()
    local loadFile= LoadResourceFile(GetCurrentResourceName(), "./data.json")
    return (json.decode(loadFile))
end

function save()
    SaveResourceFile(GetCurrentResourceName(), "data.json", json.encode(MAP), -1)
end