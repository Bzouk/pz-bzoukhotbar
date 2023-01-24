---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Bzouk.
--- DateTime: 22.12.2020 11:03
---
require "ISUI/ISPanel"
require "ISUI/ISButton"
require "ISUI/ISInventoryPane"
require "ISUI/ISInventoryPage"
require "ISUI/ISResizeWidget"
require "ISUI/ISMouseDrag"
require "ISUI/ISLayoutManager"
require "ISUI/ISCollapsableWindow"
require "TimedActions/ISInventoryTransferAction"

-- --------------------------
ISBzHotBarWindow = ISBzHotBarWindow or ISCollapsableWindow:derive("ISBzHotBarWindow");
function ISBzHotBarWindow:new(x, y, width, height, slotSize, windowNum, rows, columns)
    local o = {}
    o = ISCollapsableWindow:new(x, y, width, height); -- like inventory window
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=0, g=0, b=0, a=1};
    o.borderColor = {r=0, g=0, b=0, a=0.5};
    o:setResizable(false);
    o.slotSize = slotSize
    o.items = {};
    o.slotPad = 2
    o.margins = 1
    o.windowNum = windowNum
    o.rows = rows
    o.columns = columns

    for i=0, (o.rows * o.columns)-1 do
        o.items[i] = {};
        o:updateItem(ISBzHotBar.config.items[windowNum][i],i)
    end

    o:setTitle(tostring(windowNum))

    return o
end

function ISBzHotBarWindow:createChildren()
    ISCollapsableWindow.createChildren(self)
    local tbw = self:titleBarHeight()
    local offx = self.slotSize;
    self.slots = {};
    local i = 0
    for y=0,self.rows-1 do
        for x=0, self.columns-1 do
            local slot = ISBzHotSlot:new(offx * x + self.slotPad, tbw + y * self.slotSize, offx - self.margins, self.slotSize - self.margins , self, self.items[i], i, self.windowNum)
            self:addChild(slot);
            self.slots[i] = slot
            i = i + 1;
        end
    end
end

function ISBzHotBarWindow:updateItem(item, slot)
    self.items[slot].item = item;
    if item ~= nil then
        local player = getSpecificPlayer(0)
        if player == nil then return end;
        local playerInv = player:getInventory()
        if playerInv == nil then return end;

        self.items[slot].count = playerInv:getItemCountRecurse(item)
        local p = InventoryItemFactory.CreateItem(item);
        if p ~= nil then
            self.items[slot].texture = p:getTexture();
        end
    end
end

function ISBzHotBarWindow:updateAllItems()
    for i=0, ( self.rows * self.columns)-1 do
        local slot = self.slots[i]
        if slot ~= nil then
            slot:updateAllItems()
        end
    end
end
