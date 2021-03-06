---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Bzouk.
--- DateTime: 22.12.2020 11:11
---

require "ISUI/ISPanel"
require "ISUI/ISButton"
require "ISUI/ISInventoryPane"
require "ISUI/ISInventoryPage"
require "ISUI/ISResizeWidget"
require "ISUI/ISMouseDrag"
require "ISUI/ISLayoutManager"
require "TimedActions/ISInventoryTransferAction"
require "bcUtils"

-- same function in ISInventoryPaneContextMenu
local function predicateNotBroken(item)
    return not item:isBroken()
end

ISBzHotSlot = ISPanel:derive("ISBzHotSlot");
function ISBzHotSlot:new (x, y, width, height, parent, object, slot, windowNum)
    local o = {}
    o = ISPanel:new(x, y, width, height);
    setmetatable(o, self)
    self.__index = self
    o.x = x;
    o.y = y;
    o.anchorBottom = true;
    o.anchorLeft = true;
    o.anchorRight = true;
    o.anchorTop = true;
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 0.8 };
    o.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 };
    o.dirty = true;
    o.height = height;
    o.width = width;
    o.object = object;
    o.parent = parent;
    o.slot = slot;
    o.sizeOfRemoveButton = math.max(10, getTextManager():MeasureStringY(UIFont.Small, getText("UI_Bz_Fast_HotBar_Slot_Remove")))
    o.windowNum = windowNum

    return o
end

function ISBzHotSlot:createChildren()
    self.removeButton = ISButton:new(0, self:getHeight() - self.sizeOfRemoveButton, self:getWidth(), self.sizeOfRemoveButton, getText("UI_Bz_Fast_HotBar_Slot_Remove"))
    self.removeButton:setOnClick(ISBzHotBar.ClearSlotButton, self.slot, self.windowNum)
    self:addChild(self.removeButton);
    self.removeButton:setVisible(false);
end

function ISBzHotSlot:render()
    if self.object.item == nil then
        self.removeButton:setVisible(false);
        return ;
    end

    self.removeButton:setVisible(true);

    local imgSize = math.min(self.width, self.height - self.sizeOfRemoveButton);
    local alpha = 0.3;

    if self.object.count > 0 then
        alpha = 0.7;
    end

    if self.object.texture ~= nil then
        self:drawTextureScaled(self.object.texture, (self.width - imgSize) / 2, 0, imgSize, imgSize, alpha, 1, 1, 1);
    else
        self.removeButton:setVisible(false);
        return ;
    end

    local text = "(" .. self.object.count .. ")";
    -- ( text, x,double y,double r,double g, double b,double alpha)
    self:drawText(text, self.width - getTextManager():MeasureStringX(UIFont.Small, text), self.removeButton.y - (getTextManager():MeasureStringY(UIFont.Small, text) + 1), 1, 1, 1, 1, UIFont.Small);
end


function ISBzHotSlot:update()
    --ISPanel.update(self)
    if self.object.item ~= nil then
        local player = getPlayer()
        if player == nil then
            return
        end ;
        local playerInv = player:getInventory()
        if playerInv == nil then
            return
        end ;
        --self.object.count = playerInv:getItemCountRecurse(self.object.item)
        self.object.count = playerInv:getCountTypeEvalRecurse(self.object.item, predicateNotBroken)
    end
end

function ISBzHotSlot:onMouseUp(_, _)
    if ISMouseDrag.dragging then
        local dragging = ISInventoryPane.getActualItems(ISMouseDrag.dragging);
        for _, v in ipairs(dragging) do
            ISBzHotBar.PutItemInSlot(v:getFullType(), self.slot, self.windowNum)
            break
        end
    else
        self:ActivateSlot()
    end
end

function ISBzHotSlot:onRightMouseUp(x, y)
    if self.object.item == nil then
        return
    end
    local items = {};
    local playerObj = getPlayer()
    -- do nothing if sleeping
    if playerObj:isAsleep() then
        return
    end
    table.insert(items, playerObj:getInventory():getFirstTypeEvalRecurse(self.object.item, predicateNotBroken));
    ISInventoryPaneContextMenu.createMenu(0, true, items, self:getAbsoluteX() + x, self:getAbsoluteY() + y)
end

-- look for any damaged body part on the player + from ISInventoryPaneContextMenu + merge BaseHandler from ISHealthPanel
-- bodyPart:scratched() or bodyPart:deepWounded() or bodyPart:bitten() or bodyPart:stitched() or bodyPart:bleeding() or bodyPart:isBurnt() and not bodyPart:bandaged() then
-- Java     public boolean HasInjury() {
--        return this.bitten | this.scratched | this.deepWounded | this.bleeding | this.getBiteTime() > 0.0F | this.getScratchTime() > 0.0F | this.getCutTime() > 0.0F | this.getFractureTime() > 0.0F | this.haveBullet() | this.getBurnTime() > 0.0F;
--    }
ISBzHotSlot.haveDamagePart = function(playerId)
    local result = {};
    local bodyParts = getSpecificPlayer(playerId):getBodyDamage():getBodyParts();
    -- fetch all the body part
    for i=0,BodyPartType.ToIndex(BodyPartType.MAX) - 1 do
        local bodyPart = bodyParts:get(i);
        -- if it's damaged
        if (bodyPart:HasInjury() or bodyPart:stitched()) and not bodyPart:bandaged() then
            table.insert(result, bodyPart);
        end
    end
    return result;
end

-- Main called after maouse up on item
function ISBzHotSlot:ActivateSlot()
    -- No item do nothing
    if self.object.item == nil then
        return
    end

    local playerObj = getPlayer()
    -- do nothing if sleeping
    if playerObj:isAsleep() then
        return
    end

    local playerNumber = getPlayer():getPlayerNum()
    -- search in inventory + backpack and container in inventory
   -- local item = playerObj:getInventory():getFirstTypeRecurse(self.object.item);
    local playerInv = playerObj:getInventory()
    local item = playerInv:getFirstTypeEvalRecurse(self.object.item, predicateNotBroken)
    -- no item do nothing
    if not item then
        return
    end

    -- container where item is located -- from ISWorldObjectContextMenu
    local returnToContainer = item:getContainer():isInCharacterInventory(playerObj) and item:getContainer()

    -- https://projectzomboid.com/modding/zombie/inventory/InventoryItem.html
    -- same like ISInventoryPane:doContextualDblClick(item)
    if instanceof(item, "Food") then -- food smoke (also food)
        if item:isPoison() == false then -- if not posion,
            if item:getHungChange() < 0 then
                if playerObj:getMoodles():getMoodleLevel(MoodleType.FoodEaten) >= 3 and playerObj:getNutrition():getCalories() >= 1000 then
                    return
                end
                ISInventoryPaneContextMenu.onEatItems({ item }, 0.5, playerNumber);
                if returnToContainer and (returnToContainer ~= playerInv) then
                    ISTimedActionQueue.add(ISInventoryTransferAction:new(playerObj, item, playerInv, returnToContainer))
                end
            else
                local cmd = item:getCustomMenuOption() or getText("ContextMenu_Eat")
                if cmd ~= getText("ContextMenu_Eat") then
                    ISInventoryPaneContextMenu.onEatItems({ item }, 1, playerNumber);
                end
            end
        end
    elseif instanceof(item, "DrainableComboItem") then
        if item:isWaterSource() and (playerObj:getStats():getThirst() > 0.1) and not item:isTaintedWater() then -- water ISInventoryPaneContextMenu
            ISInventoryPaneContextMenu.onDrinkForThirst(item, playerObj)
            if returnToContainer and (returnToContainer ~= playerInv) then
                ISTimedActionQueue.add(ISInventoryTransferAction:new(playerObj, item, playerInv, returnToContainer))
            end
        elseif ISInventoryPaneContextMenu.startWith(item:getType(), "Pills") then -- pills like betablockers -- ISInventoryPaneContextMenu
            ISInventoryPaneContextMenu.onPillsItems({ item }, playerNumber)
            if returnToContainer and (returnToContainer ~= playerInv) then
                ISTimedActionQueue.add(ISInventoryTransferAction:new(playerObj, item, playerInv, returnToContainer))
            end
            -- if alcohol disinfectant
        elseif (ISInventoryPaneContextMenu.startWith(item:getType(), "Disinfectant") or ISInventoryPaneContextMenu.startWith(item:getType(), "AlcoholWipes")) and item:getAlcoholPower() > 0 then
            -- we get all the damaged body part
            local bodyPartDamaged = ISBzHotSlot.haveDamagePart(playerNumber);
            for _, v in ipairs(bodyPartDamaged) do
                if v:getAlcoholLevel() == 0 then -- if  zero alcohol present then
                    for _, k in ipairs(ISInventoryPane.getActualItems({ item })) do
                        -- if Disinfectant isn't in main inventory, put it there first.
                        ISInventoryPaneContextMenu.transferIfNeeded(playerObj, k)
                        -- apply Disinfect
                        ISTimedActionQueue.add(ISDisinfect:new(playerObj, playerObj, k, v));
                    end
                end
            end
            if returnToContainer and (returnToContainer ~= playerInv) then
                ISTimedActionQueue.add(ISInventoryTransferAction:new(playerObj, item, playerInv, returnToContainer))
            end
        elseif item:getType() == "DishCloth" or item:getType() == "BathTowel" and playerObj:getBodyDamage():getWetness() > 0 then -- ISInventoryPaneContextMenu
            ISInventoryPaneContextMenu.onDryMyself({ item }, playerNumber)
        elseif item:getType() == "Thread" and item:getUsedDelta() >= 0 then
            local itemNeedle = playerObj:getInventory():getFirstTypeEvalRecurse("Needle", predicateNotBroken)
            -- no itemNeedle do nothing
            if not itemNeedle then
                return
            end ;
            local returnToContainerNeedle = itemNeedle:getContainer():isInCharacterInventory(playerObj) and item:getContainer()
            -- we get all the damaged body part
            local bodyPartsDamaged = ISBzHotSlot.haveDamagePart(playerNumber);
            for _, bodyPart in ipairs(bodyPartsDamaged) do
                if bodyPart:isDeepWounded() and not bodyPart:haveGlass() then
                    -- if thread isn't in main inventory, put it there first.
                    ISInventoryPaneContextMenu.transferIfNeeded(playerObj, item);
                    ISInventoryPaneContextMenu.transferIfNeeded(playerObj, itemNeedle);
                    ISTimedActionQueue.add( ISStitch:new(playerObj,playerObj, item, bodyPart, true));
                end
            end
            if returnToContainer and (returnToContainer ~= playerInv) then
                ISTimedActionQueue.add(ISInventoryTransferAction:new(playerObj, item, playerInv, returnToContainer))
            end
            if returnToContainerNeedle and (returnToContainerNeedle ~= playerInv) then
                ISTimedActionQueue.add(ISInventoryTransferAction:new(playerObj, itemNeedle, playerInv, returnToContainerNeedle))
            end
        end
    elseif instanceof(item, "HandWeapon") and item:getCondition() > 0 then
        local itemsInHand = playerObj:getPrimaryHandItem()
        local gameHotbar = getPlayerHotbar(playerNumber);
        local fromHotbar = gameHotbar and gameHotbar:isItemAttached(itemsInHand);

        if item:isTwoHandWeapon() and not playerObj:isItemInBothHands(item) then
            ISInventoryPaneContextMenu.OnTwoHandsEquip({ item }, playerNumber)
            if ISBzHotBar.config.main.transferWeapons and itemsInHand and not fromHotbar and returnToContainer and (returnToContainer ~= playerInv) then
                ISTimedActionQueue.add(ISInventoryTransferAction:new(playerObj, itemsInHand, playerInv, returnToContainer))
            end
        else
            if (not playerObj:isPrimaryHandItem(item)) and not getSpecificPlayer(playerNumber):getBodyDamage():getBodyPart(BodyPartType.Hand_R):isDeepWounded() and (getSpecificPlayer(playerNumber):getBodyDamage():getBodyPart(BodyPartType.Hand_R):getFractureTime() == 0 or getSpecificPlayer(playerNumber):getBodyDamage():getBodyPart(BodyPartType.Hand_R):getSplintFactor() > 0) then
                -- forbid reequipping skinned items to avoid multiple problems for now
                local add = true;
                if playerObj:getSecondaryHandItem() == item and item:getScriptItem():getReplaceWhenUnequip() then
                    add = false;
                end
                if add then
                    ISInventoryPaneContextMenu.OnPrimaryWeapon({ item }, playerNumber)
                    if ISBzHotBar.config.main.transferWeapons and  itemsInHand and not fromHotbar and returnToContainer and (returnToContainer ~= playerInv) then
                        ISTimedActionQueue.add(ISInventoryTransferAction:new(playerObj, itemsInHand, playerInv, returnToContainer))
                    end
                end
            end
        end
    elseif instanceof(item, "Radio") and (instanceof(item, "InventoryItem") and not instanceof(item, "HandWeapon")) then
        if  playerObj:isEquipped(item) then
            ISTimedActionQueue.add(ISUnequipAction:new(playerObj, item, 50));
            return
        end

        if (not playerObj:isPrimaryHandItem(item)) and not getSpecificPlayer(playerNumber):getBodyDamage():getBodyPart(BodyPartType.Hand_R):isDeepWounded() and (getSpecificPlayer(playerNumber):getBodyDamage():getBodyPart(BodyPartType.Hand_R):getFractureTime() == 0 or getSpecificPlayer(playerNumber):getBodyDamage():getBodyPart(BodyPartType.Hand_R):getSplintFactor() > 0) then
            -- forbid reequipping skinned items to avoid multiple problems for now
            local add = true;
            if playerObj:getSecondaryHandItem() == item and item:getScriptItem():getReplaceWhenUnequip() then
                add = false;
            end
            if add then
                ISInventoryPaneContextMenu.OnPrimaryWeapon({ item }, playerNumber)
            end
        end
    else -- other items
        if item:isCanBandage() then
            -- we get all the damaged body part + not bandaged
            local bodyPartsDamaged = ISBzHotSlot.haveDamagePart(playerNumber);
            local isDone = false
            for _, bodyPart in ipairs(bodyPartsDamaged) do
                if bodyPart:isNeedBurnWash() and item:getBandagePower() >= 2 then
                    ISInventoryPaneContextMenu.transferIfNeeded(playerObj, item)
                    ISTimedActionQueue.add(ISCleanBurn:new(playerObj, playerObj,item, bodyPart)); --  ISRemoveGlass:new(self:getDoctor(), self:getPatient(), self.bodyPart)
                    isDone = true
                    break
                end
            end

            if isDone then
                return
            end

            for _, bodyPart in ipairs(bodyPartsDamaged) do
                ISInventoryPaneContextMenu.onApplyBandage({ item }, bodyPart, playerNumber)
                return
            end
        elseif item:getCategory() == "Clothing" and not playerObj:isEquipped(item) then
            -- extra option items use mouse right click
            --if item:getClothingItemExtraOption() then
            --     return
           -- end
            --if item:getClothingExtraSubmenu() then
           --     return
           -- end
            ISInventoryPaneContextMenu.onWearItems({ item }, playerNumber)
        elseif item:getCategory() == "Literature" and not item:canBeWrite() and not playerObj:getTraits():isIlliterate() then
            ISInventoryPaneContextMenu.onLiteratureItems({ item }, playerNumber)
        elseif item:getType() == "SutureNeedleHolder" or item:getType() == "Tweezers" then
            -- we get all the damaged body part
            local bodyPartsDamaged = ISBzHotSlot.haveDamagePart(playerNumber);
            for _, bodyPart in ipairs(bodyPartsDamaged) do
                if bodyPart:haveGlass() then
                    -- if Tweezers or SutureNeedleHolder isn't in main inventory, put it there first.
                    ISInventoryPaneContextMenu.transferIfNeeded(playerObj, item)
                    ISTimedActionQueue.add(ISRemoveGlass:new(playerObj, playerObj,bodyPart)); --  ISRemoveGlass:new(self:getDoctor(), self:getPatient(), self.bodyPart)
                elseif bodyPart:haveBullet() then
                    ISInventoryPaneContextMenu.transferIfNeeded(playerObj, item)
                    ISTimedActionQueue.add(ISRemoveBullet:new(playerObj, playerObj, bodyPart));
                end
            end
            if returnToContainer and (returnToContainer ~= playerInv) then
                ISTimedActionQueue.add(ISInventoryTransferAction:new(playerObj, item, playerInv, returnToContainer))
            end
        elseif item:getType() == "SutureNeedle" then
            -- we get all the damaged body part
            local bodyPartsDamaged = ISBzHotSlot.haveDamagePart(playerNumber);
            for _, bodyPart in ipairs(bodyPartsDamaged) do
                if bodyPart:isDeepWounded() and not bodyPart:haveGlass() then --
                    -- if SutureNeedle isn't in main inventory, put it there first.
                    ISInventoryPaneContextMenu.transferIfNeeded(playerObj, item);
                    ISTimedActionQueue.add( ISStitch:new(playerObj,playerObj, item, bodyPart, true));
                    return
                end
            end
        elseif item:getType() == "ComfreyCataplasm" then -- Aids recovery from broken bones.
            local bodyPartsDamaged = ISBzHotSlot.haveDamagePart(playerNumber);
            for _, bodyPart in ipairs(bodyPartsDamaged) do
                if bodyPart:getFractureTime() > 0 and bodyPart:getComfreyFactor() == 0 and bodyPart:getGarlicFactor() == 0 and bodyPart:getPlantainFactor() then
                    ISInventoryPaneContextMenu.transferIfNeeded(playerObj, item);
                    ISTimedActionQueue.add(ISComfreyCataplasm:new(playerObj,playerObj, item, bodyPart));
                    return
                end
            end
        elseif item:getType() == "WildGarlicCataplasm" then -- Helps to fight against infection.
            local bodyPartsDamaged = ISBzHotSlot.haveDamagePart(playerNumber);
            for _, bodyPart in ipairs(bodyPartsDamaged) do
                if bodyPart:isInfectedWound() and bodyPart:getGarlicFactor() == 0 and bodyPart:getComfreyFactor() == 0 and bodyPart:getPlantainFactor() then
                    ISInventoryPaneContextMenu.transferIfNeeded(playerObj, item);
                    ISTimedActionQueue.add(ISGarlicCataplasm:new(playerObj,playerObj, item, bodyPart));
                    return
                end
            end
        elseif item:getType() == "PlantainCataplasm" then -- Aids recovery from wounds. - in java scratched  deepWounded cut
            local bodyPartsDamaged = ISBzHotSlot.haveDamagePart(playerNumber);
            for _, bodyPart in ipairs(bodyPartsDamaged) do
                if (bodyPart:scratched() or bodyPart:deepWounded() or bodyPart:isCut()) and bodyPart:getPlantainFactor() and bodyPart:getGarlicFactor() == 0 and bodyPart:getComfreyFactor() == 0 then
                    ISInventoryPaneContextMenu.transferIfNeeded(playerObj, item);
                    ISTimedActionQueue.add(ISPlantainCataplasm:new(playerObj,playerObj, item, bodyPart));
                    return
                end
            end
        elseif item:getType() == "Splint" then -- fix broken bones Splint.
            local bodyPartsDamaged = ISBzHotSlot.haveDamagePart(playerNumber);
            for _, bodyPart in ipairs(bodyPartsDamaged) do
                if bodyPart:getFractureTime() > 0 and bodyPart:getSplintFactor()  == 0  then
                    ISInventoryPaneContextMenu.transferIfNeeded(playerObj, item);
                    ISTimedActionQueue.add(ISSplint:new(playerObj,playerObj,nil, item, bodyPart, true));
                    return
                end
            end
        end
    end
end
