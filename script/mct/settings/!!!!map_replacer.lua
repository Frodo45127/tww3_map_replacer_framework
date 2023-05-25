--[[-------------------------------------------------------------------------------------------------------------
    Script by Frodo45127 for the Map Replacer & Assets mod.

    MCT Module, with support MCT 0.9.
]]---------------------------------------------------------------------------------------------------------------

local loc_prefix = "mct_map_rep_";
local mct = get_mct()
local mod = mct:register_mod("map_replacer");

--- Function to load checkbox settings in the global category.
---@param setting_key string #Key of the setting we're loading.
---@param default_value boolean #Default value of the setting we're loading.
function mct_map_replacer_load_checkbox_global(setting_key, default_value)
    mct_map_replacer_load_checkbox("a_mod_config", "", setting_key, default_value);
end

--- Function to load checkbox settings in the IME Coordinates category.
---@param battle_type_key string #Key of the battle type of this battle.
---@param setting_key string #Key of the setting we're loading.
---@param default_value boolean #Default value of the setting we're loading.
function mct_map_replacer_load_checkbox_ime_coordinates(battle_type_key, setting_key, default_value)
    mct_map_replacer_load_checkbox("main_warhammer_coordinate_based", battle_type_key, setting_key, default_value);
end

--- Function to load checkbox settings in the ROC Coordinates category.
---@param battle_type_key string #Key of the battle type of this battle.
---@param setting_key string #Key of the setting we're loading.
---@param default_value boolean #Default value of the setting we're loading.
function mct_map_replacer_load_checkbox_roc_coordinates(battle_type_key, setting_key, default_value)
    mct_map_replacer_load_checkbox("wh3_main_chaos_coordinate_based", battle_type_key, setting_key, default_value);
end

--- Function to load checkbox settings in the IME Region category.
---@param battle_type_key string #Key of the battle type of this battle.
---@param setting_key string #Key of the setting we're loading.
---@param default_value boolean #Default value of the setting we're loading.
function mct_map_replacer_load_checkbox_ime_region(battle_type_key, setting_key, default_value)
    mct_map_replacer_load_checkbox("main_warhammer_region_based", battle_type_key, setting_key, default_value);
end

--- Function to load checkbox settings in the ROC Region category.
---@param battle_type_key string #Key of the battle type of this battle.
---@param setting_key string #Key of the setting we're loading.
---@param default_value boolean #Default value of the setting we're loading.
function mct_map_replacer_load_checkbox_roc_region(battle_type_key, setting_key, default_value)
    mct_map_replacer_load_checkbox("wh3_main_chaos_region_based", battle_type_key, setting_key, default_value);
end

--- Function to load checkbox settings in the IME Province category.
---@param battle_type_key string #Key of the battle type of this battle.
---@param setting_key string #Key of the setting we're loading.
---@param default_value boolean #Default value of the setting we're loading.
function mct_map_replacer_load_checkbox_ime_province(battle_type_key, setting_key, default_value)
    mct_map_replacer_load_checkbox("main_warhammer_province_based", battle_type_key, setting_key, default_value);
end

--- Function to load checkbox settings in the ROC Province category.
---@param battle_type_key string #Key of the battle type of this battle.
---@param setting_key string #Key of the setting we're loading.
---@param default_value boolean #Default value of the setting we're loading.
function mct_map_replacer_load_checkbox_roc_province(battle_type_key, setting_key, default_value)
    mct_map_replacer_load_checkbox("wh3_main_chaos_province_based", battle_type_key, setting_key, default_value);
end

--- Function to load checkbox settings.
---@param section_key string #Key of the section where to put this checkbox.
---@param battle_type_key string #Key of the battle type of this battle.
---@param setting_key string #Key of the setting we're loading.
---@param default_value boolean #Default value of the setting we're loading.
function mct_map_replacer_load_checkbox(section_key, battle_type_key, setting_key, default_value)
    out("Frodo45127: Loading checkbox for " .. tostring(section_key) .. ", " .. tostring(battle_type_key) .. ", " .. tostring(setting_key) .. ", " .. tostring(default_value) .. ".")

    local mct = get_mct()
    local mod = mct:get_mod_by_key("map_replacer");

    local loc_prefix = "mct_map_rep_";
    local key = section_key .. "_" .. battle_type_key .. "_" .. setting_key;
    local setting = mod:add_new_option(key, "checkbox")

    setting:set_default_value(default_value)
    setting:set_text(loc_prefix .. setting_key, true)
    setting:set_tooltip_text(loc_prefix .. setting_key .. "_tooltip", true)

    if section_key ~= nil then
        local section = mod:get_section_by_key(section_key);
        section:assign_option(setting);
    end
end

--[[-------------------------------------------------------------------------------------------------------------
    From here is where we build the menu.
]]---------------------------------------------------------------------------------------------------------------

mod:set_author("Frodo45127")
mod:set_title(loc_prefix.."mod_title", true)
mod:set_description(loc_prefix.."mod_desc", true)

if mct:get_version() == "0.9-beta" or mct:get_version() == "0.9" then
    mod:set_workshop_id("2969242283");
    mod:set_version("1.0");
    mod:set_main_image("ui/mct/map_replacer.png", 300, 300)
end

local global_config_section = mod:add_new_section("a_mod_config", loc_prefix .. "global_mod_config", true)
if mct:get_version() == "0.9-beta" or mct:get_version() == "0.9" then
    global_config_section:set_is_collapsible(true)
    global_config_section:set_visibility(true)
end

mct_map_replacer_load_checkbox_global("enable", true);

-- Empty sections. To be populated by maps themselfs through their scripts.
local ime_coordinate_based_config_section = mod:add_new_section("main_warhammer_coordinate_based", loc_prefix .. "main_warhammer_coordinate_based", true)
if mct:get_version() == "0.9-beta" or mct:get_version() == "0.9" then
    ime_coordinate_based_config_section:set_is_collapsible(true)
    ime_coordinate_based_config_section:set_visibility(true)
end

local roc_coordinate_based_config_section = mod:add_new_section("wh3_main_chaos_coordinate_based", loc_prefix .. "wh3_main_chaos_coordinate_based", true)
if mct:get_version() == "0.9-beta" or mct:get_version() == "0.9" then
    roc_coordinate_based_config_section:set_is_collapsible(true)
    roc_coordinate_based_config_section:set_visibility(true)
end

local ime_region_based_config_section = mod:add_new_section("main_warhammer_region_based", loc_prefix .. "main_warhammer_region_based", true)
if mct:get_version() == "0.9-beta" or mct:get_version() == "0.9" then
    ime_region_based_config_section:set_is_collapsible(true)
    ime_region_based_config_section:set_visibility(true)
end

local roc_region_based_config_section = mod:add_new_section("wh3_main_chaos_region_based", loc_prefix .. "wh3_main_chaos_region_based", true)
if mct:get_version() == "0.9-beta" or mct:get_version() == "0.9" then
    roc_region_based_config_section:set_is_collapsible(true)
    roc_region_based_config_section:set_visibility(true)
end

local ime_province_based_config_section = mod:add_new_section("main_warhammer_province_based", loc_prefix .. "main_warhammer_province_based", true)
if mct:get_version() == "0.9-beta" or mct:get_version() == "0.9" then
    ime_province_based_config_section:set_is_collapsible(true)
    ime_province_based_config_section:set_visibility(true)
end

local roc_province_based_config_section = mod:add_new_section("wh3_main_chaos_province_based", loc_prefix .. "wh3_main_chaos_province_based", true)
if mct:get_version() == "0.9-beta" or mct:get_version() == "0.9" then
    roc_province_based_config_section:set_is_collapsible(true)
    roc_province_based_config_section:set_visibility(true)
end
