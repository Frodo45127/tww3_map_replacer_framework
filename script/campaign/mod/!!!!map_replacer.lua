--[[-------------------------------------------------------------------------------------------------------------
    Script by Frodo45127.

    This allows to add custom settlement maps to any region of the campaign map.
]]---------------------------------------------------------------------------------------------------------------


--- Object with all the maps to replace. DO NOT ADD DIRECTLY TO THIS. USE THE HELPERS.
map_replacer = {
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
        local pending_battle = context:pending_battle();
        local battle_type = pending_battle:battle_type();
        local region_name = pending_battle:region_data():region():name();
        local province_name = pending_battle:region_data():region():province():key();
        local attacker_general_cqi, _, _ = cm:pending_battle_cache_get_attacker(1);
        local attacker_general = cm:get_character_by_cqi(attacker_general_cqi);

        map_replacer:check_for_map_replacement(battle_type, region_name, province_name, attacker_general);
    end,
    true
);

--- Function to check if a replacement map should be used, and apply it if so.
---@param battle_type string #Type of the battle to be fought.
---@param region_name string #Key of the region the battle takes place.
---@param province_name string #Key of the province the battle takes place.
---@param attacker_general CHARACTER_SCRIPT_INTERFACE #Key of the province the battle takes place.
function map_replacer:check_for_map_replacement(battle_type, region_name, province_name, attacker_general)

    -- Use the last match for coords.
    local chosen_coords = nil;
    if self[battle_type]["coordinate_based"] ~= nil then
        for _, coords in ipairs(self[battle_type]["coordinate_based"]) do
            local distance = distance_squared(attacker_general:logical_position_x(), attacker_general:logical_position_y(), coords.x, coords.y);
            out("Frodo45127: distance: " .. tostring(distance));
            if distance < coords.range then
                chosen_coords = coords;
            end
        end
    end

    if chosen_coords ~= nil then
        local tile_upgrade_key = chosen_coords.tile_upgrade_key;
        cm:pending_battle_add_scripted_tile_upgrade_tag(tile_upgrade_key);
        out("Frodo45127: Selected upgrade key " .. tostring(tile_upgrade_key) .. " for battle in coords X: " .. tostring(chosen_coords.x) .. ", Y: " .. tostring(chosen_coords.x) .. ", Range: " .. tostring(chosen_coords.range) .. ".");

    elseif self[battle_type]["region_based"] ~= nil and self[battle_type]["region_based"][region_name] ~= nil then
        local tile_upgrade_key = self[battle_type]["region_based"][region_name];
        cm:pending_battle_add_scripted_tile_upgrade_tag(tile_upgrade_key);
        out("Frodo45127: Selected upgrade key " .. tostring(tile_upgrade_key) .. " for battle in region " .. tostring(region_name) .. ".");

    elseif self[battle_type]["province_based"] ~= nil and self[battle_type]["province_based"][province_name] ~= nil then
        local tile_upgrade_key = self[battle_type]["province_based"][province_name];
        cm:pending_battle_add_scripted_tile_upgrade_tag(tile_upgrade_key);
        out("Frodo45127: Selected upgrade key " .. tostring(tile_upgrade_key) .. " for battle in province " .. tostring(province_name) .. ".");
    end

    cm:update_pending_battle();
end

--- Function to add a replacement map for a specific battle type, and position on the map.
---@param battle_type string #Type of the battle to be fought.
---@param pos_x integer #X Coordinate around where the replacement will be applied.
---@param pos_y integer #Y Coordinate around where the replacement will be applied.
---@param range integer #Range from the provided coordinate where the replacement will be applied.
---@param tile_upgrade_key string #Upgrade key to use for map replacing.
function map_replacer:add_coordinate_replacement(battle_type, pos_x, pos_y, range, tile_upgrade_key)
    if self[battle_type] == nil then
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

    if not self[battle_type]["coordinate_based"] ~= nil then
        self[battle_type]["coordinate_based"] = {};
    end

    -- NOTE: range is stored Squared because the distance function returns the result squared. For more info why, check pitagoras stuff. Weird dude.
    local coords = {
        x = pos_x,
        y = pos_y,
        range = range ^ 2,
        tile_upgrade_key = tile_upgrade_key,
    };

    table.insert(self[battle_type]["coordinate_based"], coords);

    out("Frodo45127: added replacement map for [" .. tostring(battle_type) .. "], Coordinates X: " .. tostring(coords.x) .. ", Y: " .. tostring(coords.y) .. ", Range: " .. tostring(coords.range) .. ", tile_upgrade_key: " .. tostring(coords.tile_upgrade_key) .. ".");
end

--- Function to add a replacement map for a specific battle type, and region.
---@param battle_type string #Type of the battle to be fought.
---@param region_key string #Key of the region the battle takes place.
---@param tile_upgrade_key string #Upgrade key to use for map replacing.
function map_replacer:add_region_replacement(battle_type, region_key, tile_upgrade_key)
    if self[battle_type] == nil then
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

    if not self[battle_type]["region_based"] ~= nil then
        self[battle_type]["region_based"] = {};
    end

    self[battle_type]["region_based"][region_key] = tile_upgrade_key;

    out("Frodo45127: added replacement map for [" .. tostring(battle_type) .. "], Region: " .. tostring(region_key) .. ", tile_upgrade_key: " .. tostring(tile_upgrade_key) .. ".");
end


--- Function to add a replacement map for a specific battle type, and province.
---@param battle_type string #Type of the battle to be fought.
---@param province_key string #Key of the province the battle takes place.
---@param tile_upgrade_key string #Upgrade key to use for map replacing.
function map_replacer:add_province_replacement(battle_type, province_key, tile_upgrade_key)
    if self[battle_type] == nil then
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

    if not self[battle_type]["province_based"] ~= nil then
        self[battle_type]["province_based"] = {};
    end

    self[battle_type]["province_based"][province_key] = tile_upgrade_key;

    out("Frodo45127: added replacement map for [" .. tostring(battle_type) .. "], Province: " .. tostring(province_key) .. ", tile_upgrade_key: " .. tostring(tile_upgrade_key) .. ".");
end
