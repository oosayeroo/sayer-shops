local QBCore = exports['qb-core']:GetCoreObject()
--Callback

QBCore.Functions.CreateCallback('sayer-shops:CheckMoney', function(source, cb, money,account)
    local src = source
    local hasMoney = false
    local Player = QBCore.Functions.GetPlayer(src)
    local mycash = 0
    if account == 'business' then
        local Job = Player.PlayerData.job.name
        if Player.PlayerData.job.isboss == true then
            mycash = exports['qb-management']:GetAccount(Job)
        else return TriggerClientEvent('QBCore:Notify', src, "You Are Not The Boss!", "error")
        end
    else
        mycash = Player.Functions.GetMoney(account)
    end
    if mycash >= money then
        cb(true)
    else
        cb(false)
    end
end)

RegisterNetEvent('sayer-shops:BuyItem', function(item,amount,worth,account)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Name = Player.PlayerData.name
    local ID = Player.PlayerData.cid
    local fullworth = amount*worth
    if account == 'business' then
        local Job = Player.PlayerData.job.name
        if exports['qb-management']:RemoveMoney(Job,fullworth) then
            Player.Functions.AddItem(item,amount)
            SendDiscordMessage("Items Bought",Name.." ID( "..ID.." ) Bought x"..amount.." "..QBCore.Shared.Items[item].label.." For $"..fullworth.." Using Business Account!", 'orange')
        end
    elseif account == 'cash' or account == 'bank' then
        if Player.Functions.RemoveMoney(account,fullworth) then
            Player.Functions.AddItem(item,amount)
            TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[item], "add")
            SendDiscordMessage("Items Bought",Name.." ID( "..ID.." ) Bought x"..amount.." "..QBCore.Shared.Items[item].label.." For $"..fullworth.." Money Taken From Their "..string.upper(account).."!", 'orange')
        end
    end
end)

RegisterNetEvent('sayer-shops:SellItem', function(item,amount,worth,account)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Name = Player.PlayerData.name
    local ID = Player.PlayerData.cid
    local fullworth = amount*worth
    if account == 'business' then
        local Job = Player.PlayerData.job.name
        if Player.Functions.RemoveItem(item,amount) then
            exports['qb-management']:AddMoney(Job,fullworth)
            SendDiscordMessage("Items Sold",Name.." ID( "..ID.." ) Sold x"..amount.." "..QBCore.Shared.Items[item].label.." For $"..fullworth.." Using Business Account!", 'orange')
        end
    elseif account == 'cash' or account == 'bank' then
        if Player.Functions.RemoveItem(item,amount) then
            Player.Functions.AddMoney(account,fullworth)
            TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[item], "remove")
            SendDiscordMessage("Items Sold",Name.." ID( "..ID.." ) Sold x"..amount.." "..QBCore.Shared.Items[item].label.." For $"..fullworth.." Money Sent To Their "..string.upper(account).."!", 'orange')
        end
    end
end)

--webhook
local webhookUrl = Config.Webhooks.URL 
local Colors = { -- https://www.spycolor.com/
    ['default'] = 16744192,
    ['blue'] = 255,
    ['red'] = 16711680,
    ['green'] = 65280,
    ['white'] = 16777215,
    ['black'] = 0,
    ['orange'] = 16744192,
    ['yellow'] = 16776960,
    ['pink'] = 16761035,
    ["lightgreen"] = 65309,
}
function SendDiscordMessage(title,message,color)
    if Config.Webhooks.Enable then
        local embedData = {
            {
                ['title'] = title or "Sayer Shops",
                ['color'] = Colors[color] or Colors['default'],
                ['footer'] = {
                    ['text'] = os.date('%c'),
                },
                ['description'] = message,
                ['author'] = {
                    ['name'] = 'Sayer Shops',
                    ['icon_url'] = 'https://cdn.discordapp.com/attachments/1061012675112476672/1061012749133565962/oosayerooscriptspng.png',
                },
            }
        }
        PerformHttpRequest(webhookUrl, function() end, 'POST', json.encode({ username = 'Sayer Shops', embeds = embedData}), { ['Content-Type'] = 'application/json' })
    end
end
