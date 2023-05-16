--[[-------------------------------------------------------------------------------------------------------------
    Script by Frodo45127.

    This allows to add custom settlement maps to any region of the campaign map.
]]---------------------------------------------------------------------------------------------------------------


--- Object with all the maps to replace. DO NOT ADD DIRECTLY TO THIS. USE THE HELPERS.
map_replacer = {
    main_warhammer = {
        coastal_battle = {},
        domination = {},
        fort_relief = {},
        fort_sally = {},
        fort_standard = {},
        land_ambush = {},
        land_bridge = {},
        land_normal = {},
        naval_blockade = {},
        naval_breakout = {},
        naval_normal = {},
        overthrow = {},
        port_assault = {},
        region_slot = {},
        settlement_relief = {},
        settlement_sally = {},
        settlement_standard = {},
        settlement_unfortified = {},
        survival = {},
        trial = {},
        underground_intercept = {},
        unfortified_port = {},
        unspecified = {},
    },
    wh3_main_chaos = {
        coastal_battle = {},
        domination = {},
        fort_relief = {},
        fort_sally = {},
        fort_standard = {},
        land_ambush = {},
        land_bridge = {},
        land_normal = {},
        naval_blockade = {},
        naval_breakout = {},
        naval_normal = {},
        overthrow = {},
        port_assault = {},
        region_slot = {},
        settlement_relief = {},
        settlement_sally = {},
        settlement_standard = {},
        settlement_unfortified = {},
        survival = {},
        trial = {},
        underground_intercept = {},
        unfortified_port = {},
        unspecified = {},

    },
    wh3_main_prologue = {
        coastal_battle = {},
        domination = {},
        fort_relief = {},
        fort_sally = {},
        fort_standard = {},
        land_ambush = {},
        land_bridge = {},
        land_normal = {},
        naval_blockade = {},
        naval_breakout = {},
        naval_normal = {},
        overthrow = {},
        port_assault = {},
        region_slot = {},
        settlement_relief = {},
        settlement_sally = {},
        settlement_standard = {},
        settlement_unfortified = {},
        survival = {},
        trial = {},
        underground_intercept = {},
        unfortified_port = {},
        unspecified = {},
    },
}

-- Listener to swap the battle map with a custom one pre-battle.
core:add_listener(
    "TheSwapperPendingBattle",
    "PendingBattle",
    function(context)
        local pending_battle = context:pending_battle();
        return not pending_battle:has_been_fought();
    end,
    function(context)
        local campaign_key = cm:get_campaign_name();
        local pending_battle = context:pending_battle();
        local battle_type = pending_battle:battle_type();
        local attacker_general_cqi, _, _ = cm:pending_battle_cache_get_attacker(1);
        local attacker_general = cm:get_character_by_cqi(attacker_general_cqi);
        local region = pending_battle:region_data():region();

        -- Land battle replacements.
        if not region == false and region:is_null_interface() == false then
            local region_name = region:name();
            local province_name = region:province():key();

            map_replacer:check_for_map_replacement(campaign_key, battle_type, region_name, province_name, attacker_general, false);

        -- Naval battle replacements.
        else
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
    if self[campaign_key][battle_type]["coordinate_based"] ~= nil then
        for _, replacement in ipairs(self[campaign_key][battle_type]["coordinate_based"]) do
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

    elseif not is_naval and self[campaign_key][battle_type]["region_based"] ~= nil and self[campaign_key][battle_type]["region_based"][region_name] ~= nil and self[campaign_key][battle_type]["region_based"][region_name]["enabled"] == true then
        local tile_upgrade_key = self[campaign_key][battle_type]["region_based"][region_name];
        cm:pending_battle_add_scripted_tile_upgrade_tag(tile_upgrade_key);
        out("Frodo45127: Campaign " .. tostring(campaign_key) .. ", selected upgrade key " .. tostring(tile_upgrade_key) .. " for battle in region " .. tostring(region_name) .. ".");

    elseif not is_naval and self[campaign_key][battle_type]["province_based"] ~= nil and self[campaign_key][battle_type]["province_based"][province_name] ~= nil and self[campaign_key][battle_type]["province_based"][province_name]["enabled"] == true then
        local tile_upgrade_key = self[campaign_key][battle_type]["province_based"][province_name];
        cm:pending_battle_add_scripted_tile_upgrade_tag(tile_upgrade_key);
        out("Frodo45127: Campaign " .. tostring(campaign_key) .. ", selected upgrade key " .. tostring(tile_upgrade_key) .. " for battle in province " .. tostring(province_name) .. ".");
    end

    cm:update_pending_battle();
end

--- Function to add a replacement map for a specific battle type, and position on the map.
---@param campaign_key string #Key of the campaign in which the replacement is going to be done.
---@param battle_type string #Type of the battle to be fought.
---@param pos_x integer #X Coordinate around where the replacement will be applied.
---@param pos_y integer #Y Coordinate around where the replacement will be applied.
---@param range integer #Range from the provided coordinate where the replacement will be applied.
---@param tile_upgrade_key string #Upgrade key to use for map replacing.
function map_replacer:add_coordinate_replacement(campaign_key, battle_type, pos_x, pos_y, range, tile_upgrade_key)
    if self[campaign_key] == nil then
        out("Frodo45127: map_replacer:add_coordinate_replacement() called but supplied campaign [" .. tostring(campaign_key) .. "] is not valid.");
        return;
    end

    if self[campaign_key][battle_type] == nil then
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

    if not self[campaign_key][battle_type]["coordinate_based"] ~= nil then
        self[campaign_key][battle_type]["coordinate_based"] = {};
    end

    -- NOTE: range is stored Squared because the distance function returns the result squared. For more info why, check pitagoras stuff. Weird dude.
    local coords = {
        enabled = true,
        x = pos_x,
        y = pos_y,
        range = range ^ 2,
        tile_upgrade_key = tile_upgrade_key,
    };

    table.insert(self[campaign_key][battle_type]["coordinate_based"], coords);

    out("Frodo45127: added replacement map for Campaign " .. tostring(campaign_key).. ", [" .. tostring(battle_type) .. "], Coordinates X: " .. tostring(coords.x) .. ", Y: " .. tostring(coords.y) .. ", Range: " .. tostring(coords.range) .. ", tile_upgrade_key: " .. tostring(coords.tile_upgrade_key) .. ".");
end

--- Function to add a replacement map for a specific battle type, and region.
---@param campaign_key string #Key of the campaign in which the replacement is going to be done.
---@param battle_type string #Type of the battle to be fought.
---@param region_key string #Key of the region the battle takes place.
---@param tile_upgrade_key string #Upgrade key to use for map replacing.
function map_replacer:add_region_replacement(campaign_key, battle_type, region_key, tile_upgrade_key)
    if self[campaign_key] == nil then
        out("Frodo45127: map_replacer:add_region_replacement() called but supplied campaign [" .. tostring(campaign_key) .. "] is not valid.");
        return;
    end

    if self[campaign_key][battle_type] == nil then
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

    if not self[campaign_key][battle_type]["region_based"] ~= nil then
        self[campaign_key][battle_type]["region_based"] = {};
    end

    local replacement = {
        enabled = true,
        tile_upgrade_key = tile_upgrade_key,
    };

    self[campaign_key][battle_type]["region_based"][region_key] = replacement;

    out("Frodo45127: added replacement map for Campaign " .. tostring(campaign_key).. ", [" .. tostring(battle_type) .. "], Region: " .. tostring(region_key) .. ", tile_upgrade_key: " .. tostring(tile_upgrade_key) .. ".");
end


--- Function to add a replacement map for a specific battle type, and province.
---@param campaign_key string #Key of the campaign in which the replacement is going to be done.
---@param battle_type string #Type of the battle to be fought.
---@param province_key string #Key of the province the battle takes place.
---@param tile_upgrade_key string #Upgrade key to use for map replacing.
function map_replacer:add_province_replacement(campaign_key, battle_type, province_key, tile_upgrade_key)
    if self[campaign_key] == nil then
        out("Frodo45127: map_replacer:add_province_replacement() called but supplied campaign [" .. tostring(campaign_key) .. "] is not valid.");
        return;
    end

    if self[campaign_key][battle_type] == nil then
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

    if not self[campaign_key][battle_type]["province_based"] ~= nil then
        self[campaign_key][battle_type]["province_based"] = {};
    end

    local replacement = {
        enabled = true,
        tile_upgrade_key = tile_upgrade_key,
    };

    self[campaign_key][battle_type]["province_based"][province_key] = replacement;

    out("Frodo45127: added replacement map for Campaign " .. tostring(campaign_key).. ", [" .. tostring(battle_type) .. "], Province: " .. tostring(province_key) .. ", tile_upgrade_key: " .. tostring(tile_upgrade_key) .. ".");
end
