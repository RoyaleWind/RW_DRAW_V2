RenderMap = {}
Map = {}


RegisterNetEvent('rw_draw++:cl:init')
AddEventHandler('rw_draw++:cl:init', function(data)
   for k,v in pairs(data) do 
        Map:Add(v)
   end
end)

function Map:Add(data)
    table.insert(self, data)
    self:Draw(data)
    print("Add Uid:" .. data.Uid)
end

function Map:UpdateImg(Uid, Url)
    Uid = tonumber(Uid)
    for _, v in ipairs(self) do
        if v.Uid == Uid then 
            v.Data.Url = Url
            SetDuiUrl(v.Dui,Url)
            Clmsg("UPDATE UpdateImg Uid:"..Uid)
        end
    end
end

function Map:Rem (Uid)
    Uid = tonumber(Uid)
    for i, v in ipairs(Map) do
        if v.Uid == Uid then
            DestroyDui(v.Dui)
            table.remove(Map, i)
            Clmsg("Rem Uid:" .. Uid)
            break
        end
    end
end

function Map:Kill()
    for _, v in ipairs(self) do
        DestroyDui(v.Dui)
    end
    self = {}
end

function Map:Draw(data)
    local RuntimeTxd = "rw_draw++_RuntimeTxd_"..data.Uid
    local TextureFromDuiHandle = "rw_draw++_TextureFromDuiHandle_"..data.Uid

    local textureDict = CreateRuntimeTxd(RuntimeTxd) 
    local duiObj = CreateDui(data.Data.Url, data.Data.Width, data.Data.Height)
    data.Dui = duiObj
    local dui = GetDuiHandle(data.Dui)
    local tx = CreateRuntimeTextureFromDuiHandle(textureDict, TextureFromDuiHandle, dui)
end

function Map:Render(data)
    if data.Dui == nil then return end
    local topLeft = data.Vertices[1]
    local topright =data.Vertices[2]
    local bottomLeft = data.Vertices[3]
    local bottomRight = data.Vertices[4]
    local RuntimeTxd = "rw_draw++_RuntimeTxd_"..data.Uid
    local TextureFromDuiHandle = "rw_draw++_TextureFromDuiHandle_"..data.Uid
    DrawSpritePoly(bottomRight.x, bottomRight.y, bottomRight.z, topright.x, topright.y, topright.z, topLeft.x, topLeft.y, topLeft.z, 255, 255, 255, 255, RuntimeTxd, TextureFromDuiHandle,
    1.0, 1.0, 1.0,
    1.0, 0.0, 1.0,
    0.0, 0.0, 1.0)
   DrawSpritePoly(topLeft.x, topLeft.y, topLeft.z, bottomLeft.x, bottomLeft.y, bottomLeft.z, bottomRight.x, bottomRight.y, bottomRight.z, 255, 255, 255, 255, RuntimeTxd, TextureFromDuiHandle,
    0.0, 0.0, 1.0,
    0.0, 1.0, 1.0,
    1.0, 1.0)  
end



Citizen.CreateThread(function()
    local PlayerPos = nil

    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(500)
            PlayerPos = GetEntityCoords(GetPlayerPed(-1))
        end
    end)

    while true do
        Citizen.Wait(0)
        if PlayerPos == nil or Map == nil then
            Citizen.Wait(500) 
        else
            for k, v in ipairs(Map) do 
                if #(v.Vertices[1] - PlayerPos) < DATA.Render_Distance then
                    Map:Render(v)
                end
            end
        end
    end
end)

---------------------------------------------------
---[EVENTS]
---------------------------------------------------
AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    Map:Kill()
end)

Citizen.CreateThread(function ()
    Citizen.Wait(500)
    TriggerServerEvent("rw_draw++:GetData")
end)