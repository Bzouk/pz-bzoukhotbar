---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Bzouk.
--- DateTime: 22.12.2020 10:56
---
require "ISUI/ISBzHotBarWindow"
require "keyBinding"
require "TimedActions/ISInventoryTransferAction"
require "bcUtils"

-------------------------------------------------------------------------
-------------------------------------------------------------------------
ISBzHotBar = {};
ISBzHotBar.bzHotBar = {};
ISBzHotBar.config = {};
ISBzHotBar.config.items = {};
ISBzHotBar.config.windows = {};
ISBzHotBar.config.items[1] = {};
ISBzHotBar.config.windows[1] = {};
ISBzHotBar.config.windows[1].rows = 1;
ISBzHotBar.config.windows[1].columns = 8;
ISBzHotBar.config.items[2] = {};
ISBzHotBar.config.windows[2] = {};
ISBzHotBar.config.windows[2].rows = 1;
ISBzHotBar.config.windows[2].columns = 1;
ISBzHotBar.config.items[3] = {};
ISBzHotBar.config.windows[3] = {};
ISBzHotBar.config.windows[3].rows = 1;
ISBzHotBar.config.windows[3].columns = 1;
ISBzHotBar.config.items[4] = {};
ISBzHotBar.config.windows[4] = {};
ISBzHotBar.config.windows[4].rows = 1;
ISBzHotBar.config.windows[4].columns = 1;
ISBzHotBar.config.items[5] = {};
ISBzHotBar.config.windows[5] = {};
ISBzHotBar.config.windows[5].rows = 1;
ISBzHotBar.config.windows[5].columns = 1;
ISBzHotBar.config.main = {};
ISBzHotBar.config.main.activeWindows = 1;
ISBzHotBar.config.main.show = false;
ISBzHotBar.config.main.transferWeapons = true;
ISBzHotBar.config.main.simpleDeleteButton = false;
ISBzHotBar.config.main.slotsSize = 60; -- 78 93
ISBzHotBar.config.main.slotsSizes = {};
ISBzHotBar.config.main.slotsSizes[1] = 60;
ISBzHotBar.config.main.slotsSizes[2] = 65;
ISBzHotBar.config.main.slotsSizes[3] = 70;
ISBzHotBar.config.main.slotsSizes[4] = 75;
ISBzHotBar.config.main.slotsSizes[5] = 80;
ISBzHotBar.config.main.slotsSizes[6] = 85;
ISBzHotBar.config.main.slotsSizes[7] = 90;
ISBzHotBar.config.main.slotsSizes[8] = 55;
ISBzHotBar.config.main.slotsSizes[9] = 50;
ISBzHotBar.config.main.slotsSizes[10] = 45;
ISBzHotBar.config.main.slotsSizes[11] = 40;

local FONT_UI_SMALL = getTextManager():getFontHeight(UIFont.Small)

function str_to_bool(str)
    if str == nil then
        return false
    end
    return string.lower(str) == 'true'
end

local ConfigFileName = "bzhotbar.ini"
-----------------------------------------------------------------------------------------
----------------------------------------Saving func--------------------------------------
ISBzHotBar.loadConfig = function()
    -- {{{
    local ini = bcUtils.readINI(ConfigFileName);
    if not bcUtils.tableIsEmpty(ini) then
        if not ini.main then
            ini.main = {}
        end

        ISBzHotBar.config.main.activeWindows = tonumber(ini.main.activeWindows)
        ISBzHotBar.config.main.transferWeapons = str_to_bool(ini.main.transferWeapons)
        ISBzHotBar.config.main.slotsSize = tonumber(ini.main.slotsSize)
        ISBzHotBar.config.main.simpleDeleteButton = str_to_bool(ini.main.simpleDeleteButton)

        for i = 1, ISBzHotBar.config.main.activeWindows do
            if not ini.items then
                ini.items = {}
            end
            if not ini.items[tostring(i)] then
                ini.items[tostring(i)] = {}
            end
            for k, v in pairs(ini.items[tostring(i)]) do
                ISBzHotBar.config.items[i][tonumber(k)] = v;
            end

            -- load last x y fow windows
            if not ini.windows then
                ini.windows = {}
            end
            if not ini.windows[tostring(i)] then
                ini.windows[tostring(i)] = {}
            end

            ISBzHotBar.config.windows[i].rows = tonumber(ini.windows[tostring(i)].rows)
            ISBzHotBar.config.windows[i].columns = tonumber(ini.windows[tostring(i)].columns)

            if ini.windows[tostring(i)].x and ini.windows[tostring(i)].y then
                ISBzHotBar.config.windows[i].x = tonumber(ini.windows[tostring(i)].x)
                ISBzHotBar.config.windows[i].y = tonumber(ini.windows[tostring(i)].y)
            end
        end
    end
end

ISBzHotBar.setWindowsPos = function()
    for windowNum = 1, ISBzHotBar.config.main.activeWindows do
        if ISBzHotBar.bzHotBar[windowNum] then
            ISBzHotBar.config.windows[windowNum].x = ISBzHotBar.bzHotBar[windowNum]:getX()
            ISBzHotBar.config.windows[windowNum].y = ISBzHotBar.bzHotBar[windowNum]:getY()
        end
    end
end

ISBzHotBar.saveConfig = function()
    bcUtils.writeINI(ConfigFileName, ISBzHotBar.config);
end

-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
ISBzHotBar.getHotBarDeleteText = function()
    if ISBzHotBar.config.main.simpleDeleteButton then
        return "X"
    end
    return getText("UI_Bz_Fast_HotBar_Slot_Remove")
end

ISBzHotBar.getHotBarSlotDimension = function()
    return math.max(ISBzHotBar.config.main.slotsSize, getTextManager():MeasureStringX(UIFont.Small, ISBzHotBar.getHotBarDeleteText()) + 10)
end

ISBzHotBar.getHotBarWidth = function(columns)
    return ISBzHotBar.getHotBarSlotDimension() * columns + 3
end

ISBzHotBar.getHotBarWindowTitleBarHeight = function()
    return math.max(16, FONT_UI_SMALL + 1)
end

ISBzHotBar.getHotBarHeight = function(rows)
    return ISBzHotBar.getHotBarWindowTitleBarHeight() + 3 + ISBzHotBar.getHotBarSlotDimension() * rows
end

ISBzHotBar.Toggle = function()
    if not MainScreen.instance.inGame then
        for windowNum = 1, ISBzHotBar.config.main.activeWindows do
            if ISBzHotBar.bzHotBar[windowNum] ~= nil then
                ISBzHotBar.bzHotBar[windowNum]:setVisible(false);
            end
        end
        return ;
    end
    --ISBzHotBar.loadConfig()
    ISBzHotBar.config.main.show = not ISBzHotBar.config.main.show
    for windowNum = 1, ISBzHotBar.config.main.activeWindows do
        if ISBzHotBar.bzHotBar[windowNum] == nil then
            local x = ISBzHotBar.config.windows[windowNum].x or (getCore():getScreenWidth() / 2 - 240);
            local y = ISBzHotBar.config.windows[windowNum].y or (getCore():getScreenHeight() - ISBzHotBar.getHotBarHeight(ISBzHotBar.config.windows[windowNum].columns) - 240);

            ISBzHotBar.bzHotBar[windowNum] = ISBzHotBarWindow:new(x, y, ISBzHotBar.getHotBarWidth(ISBzHotBar.config.windows[windowNum].columns), ISBzHotBar.getHotBarHeight(ISBzHotBar.config.windows[windowNum].rows), ISBzHotBar.getHotBarSlotDimension(), windowNum, ISBzHotBar.config.windows[windowNum].rows, ISBzHotBar.config.windows[windowNum].columns);
            ISBzHotBar.bzHotBar[windowNum]:setVisible(ISBzHotBar.config.main.show);
            ISBzHotBar.bzHotBar[windowNum]:addToUIManager();
        else
            ISBzHotBar.bzHotBar[windowNum]:setVisible(ISBzHotBar.config.main.show);
        end
    end
end

ISBzHotBar.Reset = function()
    for windowNum = 1, 5 do
        if ISBzHotBar.bzHotBar[windowNum] ~= nil then
            ISBzHotBar.bzHotBar[windowNum]:setVisible(false);
            ISBzHotBar.bzHotBar[windowNum]:removeFromUIManager();
            ISBzHotBar.bzHotBar[windowNum] = nil;
        end
    end
    ISBzHotBar.Toggle();
end

ISBzHotBar.PutItemInSlot = function(item, slot, windowNum)
    ISBzHotBar.bzHotBar[windowNum]:updateItem(item, slot);
    ISBzHotBar.config.items[windowNum][slot] = item;
    ISBzHotBar.saveConfig()
end

ISBzHotBar.ClearSlot = function(slot, windowNum)
    ISBzHotBar.PutItemInSlot(nil, slot, windowNum);
    ISBzHotBar.saveConfig()
end

ISBzHotBar.ClearSlotButton = function(_, _, slot, windowNum)
    ISBzHotBar.PutItemInSlot(nil, slot, windowNum);
    ISBzHotBar.saveConfig()
end
-----------------------------------------------------------------------
-------------------------Events func-----------------------------------
ISBzHotBar.onKeyPressed = function(key)
    if key == getCore():getKey("Bz_Toggle_Hotbar") and getPlayer() and getGameSpeed() > 0 then
        ISBzHotBar.loadConfig()
        ISBzHotBar.Toggle()
    end
end

ISBzHotBar.OnResolutionChange = function()
    -- not in game then return
    if not MainScreen.instance.inGame then
        return
    end
    for i = 1, ISBzHotBar.config.main.activeWindows do
        ISBzHotBar.config.windows[i].x = nil
        ISBzHotBar.config.windows[i].y = nil
    end
    ISBzHotBar.saveConfig()
    ISBzHotBar.Reset();
end

ISBzHotBar.OnSave = function()
    ISBzHotBar.loadConfig()
    ISBzHotBar.setWindowsPos()
    ISBzHotBar.saveConfig()
end

local function showBz()
    AUD.insp("ISBzHotBar", "simpleDeleteButton:", tostring(ISBzHotBar.config.main.simpleDeleteButton))
end

ISBzHotBar.UpdateAllItems = function(container, text)
    if container.onCharacter and text == "end" then
        for windowNum = 1, ISBzHotBar.config.main.activeWindows do
            if ISBzHotBar.bzHotBar[windowNum] ~= nil then
                ISBzHotBar.bzHotBar[windowNum]:updateAllItems();
            end
        end
    end
end

-- Called when an object with a container is added/removed from the world.
-- Added this to handle campfire containers.
ISBzHotBar.OnContainerUpdate = function(object) -- {{{
    for windowNum = 1, ISBzHotBar.config.main.activeWindows do
        if ISBzHotBar.bzHotBar[windowNum] ~= nil then
            ISBzHotBar.bzHotBar[windowNum]:updateAllItems();
        end
    end
end
-- }}}

-----------------------------------------------------------------------------------------
-----------------------------Only with ModOptions mod------------------------------------
-- Connecting the options to the menu, so user can change and save them.
if ModOptions and ModOptions.getInstance then
    function OnApplyInGame(val)
        --print("User pressed apply button. Changed value = ", self)
        ISBzHotBar.config.main.activeWindows = val.settings.options.activeWindows;
        ISBzHotBar.config.windows[1].rows = val.settings.options.dropdown1X;
        ISBzHotBar.config.windows[1].columns = val.settings.options.dropdown1y;
        ISBzHotBar.config.windows[2].rows = val.settings.options.dropdown2X;
        ISBzHotBar.config.windows[2].columns = val.settings.options.dropdown2y;
        ISBzHotBar.config.windows[3].rows = val.settings.options.dropdown3X;
        ISBzHotBar.config.windows[3].columns = val.settings.options.dropdown3y;
        ISBzHotBar.config.windows[4].rows = val.settings.options.dropdown4X;
        ISBzHotBar.config.windows[4].columns = val.settings.options.dropdown4y;
        ISBzHotBar.config.windows[5].rows = val.settings.options.dropdown5X;
        ISBzHotBar.config.windows[5].columns = val.settings.options.dropdown5y;
        ISBzHotBar.config.main.transferWeapons = val.settings.options.moveweapons;
        ISBzHotBar.config.main.slotsSize = ISBzHotBar.config.main.slotsSizes[val.settings.options.dropdownslotsize];
        ISBzHotBar.config.main.simpleDeleteButton = val.settings.options.simpledelete;
        ISBzHotBar.saveConfig()
        ISBzHotBar.Reset()
    end

    function OnApplyMainMenu(val)
        --print("User pressed apply button. Changed value = ", self)
        ISBzHotBar.config.main.activeWindows = val.settings.options.activeWindows;
        ISBzHotBar.config.windows[1].rows = val.settings.options.dropdown1X;
        ISBzHotBar.config.windows[1].columns = val.settings.options.dropdown1y;
        ISBzHotBar.config.windows[2].rows = val.settings.options.dropdown2X;
        ISBzHotBar.config.windows[2].columns = val.settings.options.dropdown2y;
        ISBzHotBar.config.windows[3].rows = val.settings.options.dropdown3X;
        ISBzHotBar.config.windows[3].columns = val.settings.options.dropdown3y;
        ISBzHotBar.config.windows[4].rows = val.settings.options.dropdown4X;
        ISBzHotBar.config.windows[4].columns = val.settings.options.dropdown4y;
        ISBzHotBar.config.windows[5].rows = val.settings.options.dropdown5X;
        ISBzHotBar.config.windows[5].columns = val.settings.options.dropdown5y;
        ISBzHotBar.config.main.transferWeapons = val.settings.options.moveweapons;
        ISBzHotBar.config.main.slotsSize = ISBzHotBar.config.main.slotsSizes[val.settings.options.dropdownslotsize];
        ISBzHotBar.config.main.simpleDeleteButton = val.settings.options.simpledelete;
        ISBzHotBar.saveConfig()
    end

    local SETTINGS = {
        options_data = {
            activeWindows = {
                -- choices 5:
                "1", "2", "3", "4", "5",
                -- other properties of the option:
                name = "IGUI_Bz_Fast_HotBar_MaxTables_Name",
                tooltip = "IGUI_Bz_Fast_HotBar_MaxTables_Tooltip",
                default = 1,
                OnApplyInGame = OnApplyInGame,
                OnApplyMainMenu = OnApplyMainMenu,
            },
            dropdown1X = {
                -- Max 10
                "1", "2", "3", "4", "5", "6", "7", "8",
                "9", "10",
                name = getText("IGUI_Bz_Fast_HotBar_DropdownX_Name") .. "1",
                tooltip = "IGUI_Bz_Fast_HotBar_DropdownX_Tooltip",
                default = 1,
                OnApplyInGame = OnApplyInGame,
                OnApplyMainMenu = OnApplyMainMenu,
            },
            dropdown1y = {
                -- Max 10
                "1", "2", "3", "4", "5", "6", "7", "8",
                "9", "10",
                name = getText("IGUI_Bz_Fast_HotBar_DropdownY_Name") .. "1",
                tooltip = "IGUI_Bz_Fast_HotBar_DropdownY_Tooltip",
                default = 8,
                OnApplyInGame = OnApplyInGame,
                OnApplyMainMenu = OnApplyMainMenu,
            },
            dropdown2X = {
                -- Max 10
                "1", "2", "3", "4", "5", "6", "7", "8",
                "9", "10",
                name = getText("IGUI_Bz_Fast_HotBar_DropdownX_Name") .. "2",
                tooltip = "IGUI_Bz_Fast_HotBar_DropdownX_Tooltip",
                default = 1,
                OnApplyInGame = OnApplyInGame,
                OnApplyMainMenu = OnApplyMainMenu,
            },
            dropdown2y = {
                -- Max 10
                "1", "2", "3", "4", "5", "6", "7", "8",
                "9", "10",
                name = getText("IGUI_Bz_Fast_HotBar_DropdownY_Name") .. "2",
                tooltip = "IGUI_Bz_Fast_HotBar_DropdownY_Tooltip",
                default = 1,
                OnApplyInGame = OnApplyInGame,
                OnApplyMainMenu = OnApplyMainMenu,
            },
            dropdown3X = {
                -- Max 10
                "1", "2", "3", "4", "5", "6", "7", "8",
                "9", "10",
                name = getText("IGUI_Bz_Fast_HotBar_DropdownX_Name") .. "3",
                tooltip = "IGUI_Bz_Fast_HotBar_DropdownX_Tooltip",
                default = 1,
                OnApplyInGame = OnApplyInGame,
                OnApplyMainMenu = OnApplyMainMenu,
            },
            dropdown3y = {
                -- Max 10
                "1", "2", "3", "4", "5", "6", "7", "8",
                "9", "10",
                name = getText("IGUI_Bz_Fast_HotBar_DropdownY_Name") .. "3",
                tooltip = "IGUI_Bz_Fast_HotBar_DropdownY_Tooltip",
                default = 1,
                OnApplyInGame = OnApplyInGame,
                OnApplyMainMenu = OnApplyMainMenu,
            },
            dropdown4X = {
                -- Max 10
                "1", "2", "3", "4", "5", "6", "7", "8",
                "9", "10",
                name = getText("IGUI_Bz_Fast_HotBar_DropdownX_Name") .. "4",
                tooltip = "IGUI_Bz_Fast_HotBar_DropdownX_Tooltip",
                default = 1,
                OnApplyInGame = OnApplyInGame,
                OnApplyMainMenu = OnApplyMainMenu,
            },
            dropdown4y = {
                -- Max 10
                "1", "2", "3", "4", "5", "6", "7", "8",
                "9", "10",
                name = getText("IGUI_Bz_Fast_HotBar_DropdownY_Name") .. "4",
                tooltip = "IGUI_Bz_Fast_HotBar_DropdownY_Tooltip",
                default = 1,
                OnApplyInGame = OnApplyInGame,
                OnApplyMainMenu = OnApplyMainMenu,
            },
            dropdown5X = {
                -- Max 10
                "1", "2", "3", "4", "5", "6", "7", "8",
                "9", "10",
                name = getText("IGUI_Bz_Fast_HotBar_DropdownX_Name") .. "5",
                tooltip = "IGUI_Bz_Fast_HotBar_DropdownX_Tooltip",
                default = 1,
                OnApplyInGame = OnApplyInGame,
                OnApplyMainMenu = OnApplyMainMenu,
            },
            dropdown5y = {
                -- Max 10
                "1", "2", "3", "4", "5", "6", "7", "8",
                "9", "10",
                name = getText("IGUI_Bz_Fast_HotBar_DropdownY_Name") .. "5",
                tooltip = "IGUI_Bz_Fast_HotBar_DropdownY_Tooltip",
                default = 1,
                OnApplyInGame = OnApplyInGame,
                OnApplyMainMenu = OnApplyMainMenu,
            },
            moveweapons = {
                name = getText("IGUI_Bz_Fast_HotBar_CheckBox_Move_Weapons_Name"),
                tooltip = "IGUI_Bz_Fast_HotBar_CheckBox_Tooltip_Move_Weapons",
                default = true,
                OnApplyInGame = OnApplyInGame,
                OnApplyMainMenu = OnApplyMainMenu,
            },
            simpledelete = {
                name = getText("IGUI_Bz_Fast_HotBar_CheckBox_Simple_Delete"),
                tooltip = "IGUI_Bz_Fast_HotBar_CheckBox_Tooltip_Simple_Delete",
                default = false,
                OnApplyInGame = OnApplyInGame,
                OnApplyMainMenu = OnApplyMainMenu,
            },
            dropdownslotsize = {
                "60 default", "65", "70", "75", "80 1x fonts", "85", "90 2x fonts", "55", "50", "45",
                name = getText("IGUI_Bz_Fast_HotBar_SlotSize_Name"),
                tooltip = "IGUI_Bz_Fast_HotBar_SlotSize_Tooltip",
                default = 1,
                OnApplyInGame = OnApplyInGame,
                OnApplyMainMenu = OnApplyMainMenu,
            },
        },
        mod_id = 'BzHotBar',
        mod_shortname = 'Fast Hotbar mod',
        mod_fullname = 'Bzouk Fast Hotbar mod',
    }

    local key_data = {
        key = Keyboard.KEY_TAB,
        name = "Bz_Toggle_Hotbar",
    }
    local category = "[Bz_Toggle_Hotbar]";
    ModOptions:AddKeyBinding(category, key_data);
    ModOptions:getInstance(SETTINGS)
    ModOptions:loadFile()
    ISBzHotBar.loadConfig();
    ISBzHotBar.config.main.activeWindows = SETTINGS.options.activeWindows;
    ISBzHotBar.config.windows[1].rows = SETTINGS.options.dropdown1X;
    ISBzHotBar.config.windows[1].columns = SETTINGS.options.dropdown1y;
    ISBzHotBar.config.windows[2].rows = SETTINGS.options.dropdown2X;
    ISBzHotBar.config.windows[2].columns = SETTINGS.options.dropdown2y;
    ISBzHotBar.config.windows[3].rows = SETTINGS.options.dropdown3X;
    ISBzHotBar.config.windows[3].columns = SETTINGS.options.dropdown3y;
    ISBzHotBar.config.windows[4].rows = SETTINGS.options.dropdown4X;
    ISBzHotBar.config.windows[4].columns = SETTINGS.options.dropdown4y;
    ISBzHotBar.config.windows[5].rows = SETTINGS.options.dropdown5X;
    ISBzHotBar.config.windows[5].columns = SETTINGS.options.dropdown5y;
    ISBzHotBar.config.main.transferWeapons = SETTINGS.options.moveweapons;
    ISBzHotBar.config.main.simpleDeleteButton = SETTINGS.options.simpledelete;
    ISBzHotBar.config.main.slotsSize = ISBzHotBar.config.main.slotsSizes[SETTINGS.options.dropdownslotsize];
    ISBzHotBar.saveConfig();
else
    local key_data = {
        key = Keyboard.KEY_TAB,
        value = "Bz_Toggle_Hotbar",
    }
    table.insert(keyBinding, key_data) -- keyBinding global key bindings in zomboid/media/lua/shared/keyBindings.lua
end
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------


-----------------------------------------------------------------------
-------------------------Events----------------------------------------
Events.OnKeyPressed.Add(ISBzHotBar.onKeyPressed);
Events.OnResolutionChange.Add(ISBzHotBar.OnResolutionChange)
Events.OnSave.Add(ISBzHotBar.OnSave)
--Events.OnTick.Add(showBz)
Events.OnGameStart.Add(ISBzHotBar.loadConfig())

Events.OnRefreshInventoryWindowContainers.Add(ISBzHotBar.UpdateAllItems);
Events.OnContainerUpdate.Add(ISBzHotBar.OnContainerUpdate);
