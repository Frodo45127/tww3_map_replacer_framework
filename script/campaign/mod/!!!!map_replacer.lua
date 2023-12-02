--[[-------------------------------------------------------------------------------------------------------------
    Script by Frodo45127.

    This allows to add custom settlement maps to any region of the campaign map.
]]---------------------------------------------------------------------------------------------------------------


--- Object with all the maps to replace. DO NOT ADD DIRECTLY TO THIS. USE THE HELPERS.
map_replacer = {
    enabled = true,
    campaigns = {},
}

local supported_campaigns = {
    "wh3_main_prologue",        -- Wh3 Prologue
    "wh3_main_chaos",           -- Wh3 RoC
    "main_warhammer",           -- Wh3 IME
    "cr_combi_expanded",        -- Wh3 IME Expanded (ChaosRobie)
    "cr_oldworld",              -- Wh3 Old World (ChaosRobie)
};

campaign_replacements_set = {
    "coastal_battle",
    "domination",
    "fort_relief",
    "fort_sally",
    "fort_standard",
    "land_ambush",
    "land_bridge",
    "land_normal",
    "naval_blockade",
    "naval_breakout",
    "naval_normal",
    "overthrow",
    "port_assault",
    "region_slot",
    "settlement_relief",
    "settlement_sally",
    "settlement_standard",
    "settlement_unfortified",
    "survival",
    "trial",
    "underground_intercept",
    "unfortified_port",
    "unspecified",
};

local function printTable( t )

    local printTable_cache = {}

    local function sub_printTable( t, indent )

        if ( printTable_cache[tostring(t)] ) then
            print( indent .. "*" .. tostring(t) )
        else
            printTable_cache[tostring(t)] = true
            if ( type( t ) == "table" ) then
                for pos,val in pairs( t ) do
                    if ( type(val) == "table" ) then
                        out( indent .. "[" .. pos .. "] => " .. tostring( t ).. " {" )
                        sub_printTable( val, indent .. string.rep( " ", string.len(pos)+8 ) )
                        out( indent .. string.rep( " ", string.len(pos)+6 ) .. "}" )
                    elseif ( type(val) == "string" ) then
                        out( indent .. "[" .. pos .. '] => "' .. val .. '"' )
                    else
                        out( indent .. "[" .. pos .. "] => " .. tostring(val) )
                    end
                end
            else
                out( indent..tostring(t) )
            end
        end
    end

    if ( type(t) == "table" ) then
        out( tostring(t) .. " {" )
        sub_printTable( t, "  " )
        out( "}" )
    else
        sub_printTable( t, "  " )
    end
end

-- Function to setup the save/load from savegame logic for items.
--
-- Pretty much a reusable function to load data from save and set it to be saved on the next save.
---@param item table #Object/Table to save.
---@param save_key string #Unique key to identify the saved data.
local function setup_save(item, save_key)
    local old_data = cm:get_saved_value(save_key);
    if old_data ~= nil then

        -- For tables we only set data IF IT'S IN THE CURRENT TABLE.
        -- This makes it so we can add/remove maps between saves.
        if is_table(old_data) then
            for campaign_key, campaign_replacements in pairs(item) do
                for battle_type_key, battle_type_replacements in pairs(campaign_replacements) do

                    -- Coordinate-based replacements are requested from MCT using the unique key, if they have it.
                    if battle_type_replacements["coordinate_based"] ~= nil and old_data[campaign_key][battle_type_key]["coordinate_based"] ~= nil then
                        for _, replacement in ipairs(battle_type_replacements["coordinate_based"]) do
                            if replacement["unique_key"] ~= nil then

                                local old_replacement = nil;
                                for _, old_replacements in ipairs(old_data[campaign_key][battle_type_key]["coordinate_based"]) do
                                    if old_replacements.unique_key == replacement.unique_key then
                                        old_replacement = old_replacements;
                                        break;
                                    end
                                end

                                if old_replacement ~= nil then
                                    replacement.enabled = old_replacement.enabled;
                                end
                            end
                        end
                    end

                    if battle_type_replacements["region_based"] ~= nil and old_data[campaign_key][battle_type_key]["region_based"] ~= nil then
                        for region_key, replacement in pairs(battle_type_replacements["region_based"]) do
                            if old_data[campaign_key][battle_type_key]["region_based"][region_key] ~= nil then
                                replacement.enabled = old_data[campaign_key][battle_type_key]["region_based"][region_key].enabled;
                            end
                        end
                    end

                    if battle_type_replacements["province_based"] ~= nil and old_data[campaign_key][battle_type_key]["province_based"] ~= nil then
                        for province_key, replacement in pairs(battle_type_replacements["province_based"]) do
                            if old_data[campaign_key][battle_type_key]["province_based"][province_key] ~= nil then
                                replacement.enabled = old_data[campaign_key][battle_type_key]["province_based"][province_key].enabled;
                            end
                        end
                    end
                end
            end
        else
            item = old_data;
        end
    end
    cm:set_saved_value(save_key, item);
end

--[[-------------------------------------------------------------------------------------------------------------
    MCT logic (listeners and helpers), so the users can configure the maps they want.

    Contains the logic to load settings to/from the MCT automagically. Users should not touch this.
]]---------------------------------------------------------------------------------------------------------------

-- Listener to initialize the mod from the MCT settings, if available.
core:add_listener(
    "MapReplacerSettingsLoader",
    "MctInitialized",
    true,
    function(context)
        map_replacer:load_from_mct(context:mct());
    end,
    true
)

-- Listener to update the mod mid-campaign from the MCT settings, if available.
core:add_listener(
    "MapReplacerSettingsMidCamnpaignLoader",
    "MctFinalized",
    true,
    function(context)
        map_replacer:load_from_mct(context:mct());
    end,
    true
)

-- Function to load settings from the mct.
---@param mct userdata #MCT object.
function map_replacer:load_from_mct(mct)
    out("Frodo45127: Saving settings from MCT.")

    local mod = mct:get_mod_by_key("map_replacer")

    self.enabled = mod:get_option_by_key("a_mod_config__enable"):get_finalized_setting();

    for campaign_key, campaign_replacements in pairs(self.campaigns) do
        for battle_type_key, battle_type_replacements in pairs(campaign_replacements) do

            -- Coordinate-based replacements are requested from MCT using the unique key, if they have it.
            if battle_type_replacements["coordinate_based"] ~= nil then
                for _, replacement in ipairs(battle_type_replacements["coordinate_based"]) do
                    if replacement["unique_key"] ~= nil then
                        local setting_key = campaign_key .. "_coordinate_based_" .. battle_type_key .. "_" .. replacement["unique_key"];
                        local setting = mod:get_option_by_key(setting_key);
                        if not setting == false then
                            replacement.enabled = setting:get_finalized_setting();
                        end
                    end
                end
            end

            if battle_type_replacements["region_based"] ~= nil then
                for region_key, replacement in pairs(battle_type_replacements["region_based"]) do
                    local setting_key = campaign_key .. "_region_based_" .. battle_type_key .. "_" .. region_key;
                    local setting = mod:get_option_by_key(setting_key);
                    if not setting == false then
                        replacement.enabled = setting:get_finalized_setting();
                    end
                end
            end

            if battle_type_replacements["province_based"] ~= nil then
                for province_key, replacement in pairs(battle_type_replacements["province_based"]) do
                    local setting_key = campaign_key .. "_province_based_" .. battle_type_key .. "_" .. province_key;
                    local setting = mod:get_option_by_key(setting_key);
                    if not setting == false then
                        replacement.enabled = setting:get_finalized_setting();
                    end
                end
            end
        end
    end
end

-- Listener to swap the battle map with a custom one pre-battle.
core:add_listener(
    "TheSwapperPendingBattle",
    "PendingBattle",
    function(context)
        local pending_battle = context:pending_battle();
        return map_replacer.enabled == true and not pending_battle:has_been_fought();
    end,
    function(context)
        out("Frodo45127: pending battle, checking for map replacement...");

        local campaign_key = cm:get_campaign_name();
        local pending_battle = context:pending_battle();
        local battle_type = pending_battle:battle_type();
        local attacker_general_cqi, _, _ = cm:pending_battle_cache_get_attacker(1);
        local attacker_general = cm:get_character_by_cqi(attacker_general_cqi);
        local region = pending_battle:region_data():region();

        -- Land battle replacements.
        if not region == false and region:is_null_interface() == false then
            out("Frodo45127: possible land battle replacement.");

            local region_name = region:name();
            local province_name = region:province():key();

            map_replacer:check_for_map_replacement(campaign_key, battle_type, region_name, province_name, attacker_general, false);

        -- Naval battle replacements.
        else
            out("Frodo45127: possible naval battle replacement.");

            map_replacer:check_for_map_replacement(campaign_key, battle_type, nil, nil, attacker_general, true);
        end
    end,
    true
);

--- Function to check if a replacement map should be used, and apply it if so.
---@param campaign_key string #Key of the campaign to check for replacements.
---@param battle_type string #Type of the battle to be fought.
---@param region_name string #Key of the region the battle takes place.
---@param province_name string #Key of the province the battle takes place.
---@param attacker_general CHARACTER_SCRIPT_INTERFACE #Key of the province the battle takes place.
---@param is_naval boolean #If the battle is naval (island battle) or not.
function map_replacer:check_for_map_replacement(campaign_key, battle_type, region_name, province_name, attacker_general, is_naval)
    if is_naval == nil then
        is_naval = false;
    end

    -- Use the last match for coords.
    local chosen_replacement = nil;
    if self.campaigns[campaign_key][battle_type]["coordinate_based"] ~= nil then
        for _, replacement in ipairs(self.campaigns[campaign_key][battle_type]["coordinate_based"]) do
            if replacement.enabled == true then
                local distance = distance_squared(attacker_general:logical_position_x(), attacker_general:logical_position_y(), replacement.x, replacement.y);
                out("Frodo45127: distance: " .. tostring(distance));
                if distance < replacement.range then
                    chosen_replacement = replacement;
                end
            end
        end
    end

    if chosen_replacement ~= nil then
        local tile_upgrade_key = chosen_replacement.tile_upgrade_key;
        cm:pending_battle_add_scripted_tile_upgrade_tag(tile_upgrade_key);
        out("Frodo45127: Campaign " .. tostring(campaign_key) .. ", selected upgrade key " .. tostring(tile_upgrade_key) .. " for battle in coords X: " .. tostring(chosen_replacement.x) .. ", Y: " .. tostring(chosen_replacement.x) .. ", Range: " .. tostring(chosen_replacement.range) .. ".");

    elseif not is_naval and self.campaigns[campaign_key][battle_type]["region_based"] ~= nil and self.campaigns[campaign_key][battle_type]["region_based"][region_name] ~= nil and self.campaigns[campaign_key][battle_type]["region_based"][region_name]["enabled"] == true then
        local tile_upgrade_key = self.campaigns[campaign_key][battle_type]["region_based"][region_name].tile_upgrade_key;
        cm:pending_battle_add_scripted_tile_upgrade_tag(tile_upgrade_key);
        out("Frodo45127: Campaign " .. tostring(campaign_key) .. ", selected upgrade key " .. tostring(tile_upgrade_key) .. " for battle in region " .. tostring(region_name) .. ".");

    elseif not is_naval and self.campaigns[campaign_key][battle_type]["province_based"] ~= nil and self.campaigns[campaign_key][battle_type]["province_based"][province_name] ~= nil and self.campaigns[campaign_key][battle_type]["province_based"][province_name]["enabled"] == true then
        local tile_upgrade_key = self.campaigns[campaign_key][battle_type]["province_based"][province_name].tile_upgrade_key;
        cm:pending_battle_add_scripted_tile_upgrade_tag(tile_upgrade_key);
        out("Frodo45127: Campaign " .. tostring(campaign_key) .. ", selected upgrade key " .. tostring(tile_upgrade_key) .. " for battle in province " .. tostring(province_name) .. ".");
    end

    cm:update_pending_battle();
end

--- Function to add a campaign to the replacer. Note that if the campaign already exists in the campaigns list, this function will do nothing.
---@param campaign_key string #Key of the campaign to add support for.
function map_replacer:add_campaign(campaign_key)
    if self.campaigns[campaign_key] ~= nil then
        out("Frodo45127: map_replacer:add_campaign() called but supplied campaign [" .. tostring(campaign_key) .. "] is already on the campaigns list.");
        return;
    end

    self.campaigns[campaign_key] = {};

    for _, replacement_set in ipairs(campaign_replacements_set) do
        self.campaigns[campaign_key][replacement_set] = {};
    end

    out("Frodo45127: added support for Campaign " .. tostring(campaign_key).. ".");
end

--- Function to add a replacement map for a specific battle type, and position on the map.
---@param campaign_key string #Key of the campaign in which the replacement is going to be done.
---@param battle_type string #Type of the battle to be fought.
---@param pos_x integer #X Coordinate around where the replacement will be applied.
---@param pos_y integer #Y Coordinate around where the replacement will be applied.
---@param range integer #Range from the provided coordinate where the replacement will be applied.
---@param tile_upgrade_key string #Upgrade key to use for map replacing.
---@param unique_key string #Unique key to identify this specific replacement for MCT. If not passed, the replacement will not be configurable in MCT.
function map_replacer:add_coordinate_replacement(campaign_key, battle_type, pos_x, pos_y, range, tile_upgrade_key, unique_key)
    if self.campaigns[campaign_key] == nil then
        out("Frodo45127: map_replacer:add_coordinate_replacement() called but supplied campaign [" .. tostring(campaign_key) .. "] is not valid.");
        return;
    end

    if self.campaigns[campaign_key][battle_type] == nil then
        out("Frodo45127: map_replacer:add_coordinate_replacement() called but supplied battle type [" .. tostring(battle_type) .. "] is not valid.");
        return;
    end

    if pos_x == nil or not is_number(pos_x) or pos_x < 0 then
        out("Frodo45127: map_replacer:add_coordinate_replacement() called but supplied pos_x [" .. tostring(pos_x) .. "] is not valid.");
        return;
    end;

    if pos_y == nil or not is_number(pos_y) or pos_y < 0 then
        out("Frodo45127: map_replacer:add_coordinate_replacement() called but supplied pos_y [" .. tostring(pos_y) .. "] is not valid.");
        return;
    end;

    if range == nil or not is_number(range) or range < 0 then
        out("Frodo45127: map_replacer:add_coordinate_replacement() called but supplied range [" .. tostring(range) .. "] is not valid.");
        return;
    end;

    if tile_upgrade_key == nil then
        out("Frodo45127: map_replacer:add_coordinate_replacement() called but supplied tile_upgrade_key [" .. tostring(tile_upgrade_key) .. "] is not valid.");
        return;
    end;

    if self.campaigns[campaign_key][battle_type]["coordinate_based"] == nil then
        self.campaigns[campaign_key][battle_type]["coordinate_based"] = {};
    end

    -- NOTE: range is stored Squared because the distance function returns the result squared. For more info why, check pitagoras stuff. Weird dude.
    local coords = {
        enabled = true,
        key = unique_key,
        x = pos_x,
        y = pos_y,
        range = range ^ 2,
        tile_upgrade_key = tile_upgrade_key,
    };

    table.insert(self.campaigns[campaign_key][battle_type]["coordinate_based"], coords);

    out("Frodo45127: added replacement map for Campaign " .. tostring(campaign_key).. ", [" .. tostring(battle_type) .. "], Coordinates X: " .. tostring(coords.x) .. ", Y: " .. tostring(coords.y) .. ", Range: " .. tostring(coords.range) .. ", tile_upgrade_key: " .. tostring(coords.tile_upgrade_key) .. ".");
end

--- Function to add a replacement map for a specific battle type, and region.
---@param campaign_key string #Key of the campaign in which the replacement is going to be done.
---@param battle_type string #Type of the battle to be fought.
---@param region_key string #Key of the region the battle takes place.
---@param tile_upgrade_key string #Upgrade key to use for map replacing.
function map_replacer:add_region_replacement(campaign_key, battle_type, region_key, tile_upgrade_key)
    if self.campaigns[campaign_key] == nil then
        out("Frodo45127: map_replacer:add_region_replacement() called but supplied campaign [" .. tostring(campaign_key) .. "] is not valid.");
        return;
    end

    if self.campaigns[campaign_key][battle_type] == nil then
        out("Frodo45127: map_replacer:add_region_replacement() called but supplied battle type [" .. tostring(battle_type) .. "] is not valid.");
        return;
    end

    if region_key == nil then
        out("Frodo45127: map_replacer:add_region_replacement() called but supplied region_key [" .. tostring(region_key) .. "] is not valid.");
        return;
    end;

    if tile_upgrade_key == nil then
        out("Frodo45127: map_replacer:add_region_replacement() called but supplied tile_upgrade_key [" .. tostring(tile_upgrade_key) .. "] is not valid.");
        return;
    end;

    if self.campaigns[campaign_key][battle_type]["region_based"] == nil then
        self.campaigns[campaign_key][battle_type]["region_based"] = {};
    end

    local replacement = {
        enabled = true,
        tile_upgrade_key = tile_upgrade_key,
    };

    self.campaigns[campaign_key][battle_type]["region_based"][region_key] = replacement;

    out("Frodo45127: added replacement map for Campaign " .. tostring(campaign_key).. ", [" .. tostring(battle_type) .. "], Region: " .. tostring(region_key) .. ", tile_upgrade_key: " .. tostring(tile_upgrade_key) .. ".");
end


--- Function to add a replacement map for a specific battle type, and province.
---@param campaign_key string #Key of the campaign in which the replacement is going to be done.
---@param battle_type string #Type of the battle to be fought.
---@param province_key string #Key of the province the battle takes place.
---@param tile_upgrade_key string #Upgrade key to use for map replacing.
function map_replacer:add_province_replacement(campaign_key, battle_type, province_key, tile_upgrade_key)
    if self.campaigns[campaign_key] == nil then
        out("Frodo45127: map_replacer:add_province_replacement() called but supplied campaign [" .. tostring(campaign_key) .. "] is not valid.");
        return;
    end

    if self.campaigns[campaign_key][battle_type] == nil then
        out("Frodo45127: map_replacer:add_province_replacement() called but supplied battle type [" .. tostring(battle_type) .. "] is not valid.");
        return;
    end

    if province_key == nil then
        out("Frodo45127: map_replacer:add_province_replacement() called but supplied region_key [" .. tostring(province_key) .. "] is not valid.");
        return;
    end;

    if tile_upgrade_key == nil then
        out("Frodo45127: map_replacer:add_province_replacement() called but supplied tile_upgrade_key [" .. tostring(tile_upgrade_key) .. "] is not valid.");
        return;
    end;

    if self.campaigns[campaign_key][battle_type]["province_based"] == nil then
        self.campaigns[campaign_key][battle_type]["province_based"] = {};
    end

    local replacement = {
        enabled = true,
        tile_upgrade_key = tile_upgrade_key,
    };

    self.campaigns[campaign_key][battle_type]["province_based"][province_key] = replacement;

    out("Frodo45127: added replacement map for Campaign " .. tostring(campaign_key).. ", [" .. tostring(battle_type) .. "], Province: " .. tostring(province_key) .. ", tile_upgrade_key: " .. tostring(tile_upgrade_key) .. ".");
end


-- Initialize the mod with the last saved values.
cm:add_pre_first_tick_callback(
    function ()

        for _, campaign_key in ipairs(supported_campaigns) do
            map_replacer:add_campaign(campaign_key);
        end

        setup_save(map_replacer.enabled, "map_replacer_enabled");
        setup_save(map_replacer.campaigns, "map_replacer_campaigns");
    end
)
