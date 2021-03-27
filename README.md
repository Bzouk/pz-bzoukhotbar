# ZomboidMod

![Game Version](https://img.shields.io/badge/PZ%20Version-IWBUMS%3A%2041.50-red) [![License](https://img.shields.io/github/license/yooksi/pz-zmod)](https://mit-license.org/)

Hot bar mod adds quick access bar for items from player inventory.


## Motivation and credits

Mod idea is based another mod ["Hotbar for 5-20 often-used" (Blindcoder)](https://theindiestone.com/forums/index.php?/topic/13356-hotbar-for-quick-item-access-v072/) and other games like WoW and ETF. Mod is also using library "Blindcoders Modding Utility".

## Screenshots

TODO

## Installation

### Required mods:
[Blindcoders Modding Utility (saving data to ini)](https://steamcommunity.com/workshop/filedetails/?id=503640135)

### Optional mods:
[Mod Options](https://steamcommunity.com/sharedfiles/filedetails/?id=2169435993)

- Download the [latest release](https://github.com/Bzouk/pz-bzoukhotbar/releases/) from the repository releases section.
- Unpack the release with your preferred file archiver to game mod directory.
- Start the game and toggle the mod in the Mod-Options screen.

For more information read [How To Install / Uninstall Mods](https://theindiestone.com/forums/index.php?/topic/1395-how-to-install-uninstall-mods/) forum thread.

## How to use

Usage:
Pres "tab" for show/hide bars. Drag and drop item into a slot. You don't need to have item in inventory to add it to slot.  
Slot counts non-broken items in inventory ( number in slot example: (24) five items in inventory ) and in all containers that you have on you ( even in containers like bandage in medkit in a backpack)

Broken items are ignored, you have to go into inventory to work with them.

Right click: Same like in inventory window.

Left click have smart functions based on item in slot. Functions are using code already in project zomboid. Many function return used item into original container.

Example:
1) Click slot with Disinfectant ( item is inside medkit in backpack)
2) Disinfectant is moved to main inventory if needed
3) Disinfectant is used on damaged parts
4) Disinfectant is moved inside medkit in backpack if still exist.

Note: If you cancel action, item will remain in main invetory (start running etc.).

- Food - this works like double click in inventory (Cola, Chips, Cigarettes)  
  If food is non poison eat half or use whole if cigarettes ( need lighter :-) ) etc.
  After use item returns to original container.

- Water  
  If item contain water, player is thirsty and water is not tainted then drink.  
  After use item returns to original container.

- Pills (BetaBlock, AntiDeb, SleepingTablets and Vitamins)  
  Take a pill. Same like right click but item is put in an original container after use.

- Disinfectant and AlcoholWipes  
  Apply alcohol on every damaged body part without alcohol.  
  After use item returns to original container.

- DishCloth BathTowel  
  Like right click option - dry yourself with a towel

- Thread  
  If you have needle in inventory it will stitch all deep wounded body parts.  
  After use item returns to original container. (needle and thread)

- Hand weapon  
  If two handed then equip two handed else one hand.  
  Idea: spear -> broke -> click on slot with spears -> re equip new -> broke -> click on slot with spears -> re equip new

- Bandage (should work on any item that can bandage)  
  Clean burns if bandage is strong or apply bandage on damaged part

- Clothing  
  Equip if not have extra options (right click - change to right etc.).

- Literature  
  Start reading.

- Suture Needle Holder or Tweezers  
  Remove all glass and bullets from damaged parts.  
  After use item returns to original container.

- Suture needle  
  Stitch one deep wounded body part.  
  After use item returns to original container.

- Comfrey Cataplasm  
  Apply to fractured body part without any comfrey.

- Wild Garlic Cataplasm  
  Apply to one infected wound without any comfrey.

- Plantain Cataplasm  
  Apply to one scratched, deep wounded or cut body part without any comfrey.

- Splint  
  Apply to fractured body part without any splint.

- Other items  
  Do nothing -> use right click

Tips and ideas for items :
- ammo -> counter how many bullets|shells
- ammo box - right click -> open box
- watches - Equip -> add to slot -> right click to set alarm etc.
- items for quick crafting
- do not forget items
- spears -> broke -> left click -> re-equip -> broke -> left click -> re-equip  (need to throw away broken ones)
- any item with info after right click (compass, radios gps...)

## License

MIT © [Bzouk](https://github.com/Bzouk)
