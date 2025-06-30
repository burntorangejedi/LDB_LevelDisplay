local ldb = LibStub:GetLibrary("LibDataBroker-1.1")

-- Define ANSI color codes
local colors = {
    reset = "\27[0m",
    red = "\27[31m",
    green = "\27[32m",
    yellow = "\27[33m",
    blue = "\27[34m",
    magenta = "\27[35m",
    cyan = "\27[36m",
    white = "\27[37m"
}

local dataobj = ldb:NewDataObject("LevelDisplay", {
    type = "data source",
    text = "calculating...",
    icon = "Interface\\Icons\\achievement_level_"..UnitLevel("player"), -- or any appropriate level icon
    OnClick = function(self, button)
        ldb:RefreshDataObject("LevelDisplay")
    end,
    OnTooltipShow = function(tooltip)
        --tooltip:AddLine("Level Display")
        --tooltip:AddLine("Current level: " .. UnitLevel("player"))
    end,
})

local function GetUnitLevel()
    return UnitLevel("player")
end

local function GetItemLevel()
    local avgItemLevel = 0
    local itemCount = 0
    for i = 1, 17 do -- 16 slots + 1 for the shirt
        local itemLink = GetInventoryItemLink("player", i)
        if itemLink then
            local itemLevel = select(4, GetItemInfo(itemLink))
            if itemLevel then
                avgItemLevel = avgItemLevel + itemLevel
                itemCount = itemCount + 1
            end
        end
    end
    
    if itemCount > 0 then
        return math.floor(avgItemLevel / itemCount)
    else
        return "0"
    end

end

local function GetGearDurability()
    local total, max = 0, 0
    for i = 1, 17 do -- 16 slots + 1 for the shirt
        local current, maximum = GetInventoryItemDurability(i)
        if current and maximum then
            total = total + current
            max = max + maximum
        end
    end
    return math.floor((total / max) * 100) .. "%"
end

-- Update on events like level up or login
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_LEVEL_UP")
f:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
f:RegisterEvent("UNIT_INVENTORY_CHANGED")
f:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
f:RegisterEvent("ITEM_UNLOCKED")
f:SetScript("OnEvent", function(self, event, ...)
    local unitLevel = GetUnitLevel()
    local itemLevel = GetItemLevel()
    local gearDurability = GetGearDurability()
    dataobj.text = "Level: " .. unitLevel .. " | iLevel: " .. itemLevel .. " | Durability: " .. gearDurability
    ldb:RefreshDataObject("LevelDisplay")
end)