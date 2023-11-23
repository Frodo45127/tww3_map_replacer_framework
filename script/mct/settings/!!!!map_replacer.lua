--[[-------------------------------------------------------------------------------------------------------------
    Script by Frodo45127 for the Map Replacer & Assets mod.

    MCT Module, with support MCT 0.9.
]]---------------------------------------------------------------------------------------------------------------

local loc_prefix = "mct_map_rep_";
local mct = get_mct()
local mod = mct:register_mod("map_replacer");

local coord_based = "_coordinate_based";
local region_based = "_region_based";
local province_based = "_province_based";
local supported_campaigns = {
    "wh3_main_prologue",        -- Wh3 Prologue
    "wh3_main_chaos",           -- Wh3 RoC
    "main_warhammer",           -- Wh3 IME
    "cr_combi_expanded",        -- Wh3 IME Expanded (ChaosRobie)
    "cr_oldworld",              -- Wh3 Old World (ChaosRobie)
};

--- Function to load checkbox settings in the global category.
---@param setting_key string #Key of the setting we're loading.
---@param default_value boolean #Default value of the setting we're loading.
function mct_map_replacer_load_checkbox_global(setting_key, default_value)
    mct_map_replacer_load_checkbox("a_mod_config", "", setting_key, default_value);
end

--- Function to load checkbox settings in the ROC Coordinates category.
---@param battle_type_key string #Key of the battle type of this battle.
---@param setting_key string #Key of the setting we're loading.
---@param default_value boolean #Default value of the setting we're loading.
function mct_map_replacer_load_checkbox_roc_coordinates(battle_type_key, setting_key, default_value)
    mct_map_replacer_load_checkbox("wh3_main_chaos" .. coord_based, battle_type_key, setting_key, default_value);
end

--- Function to load checkbox settings in the ROC Region category.
---@param battle_type_key string #Key of the battle type of this battle.
---@param setting_key string #Key of the setting we're loading.
---@param default_value boolean #Default value of the setting we're loading.
function mct_map_replacer_load_checkbox_roc_region(battle_type_key, setting_key, default_value)
    mct_map_replacer_load_checkbox("wh3_main_chaos" .. region_based, battle_type_key, setting_key, default_value);
end

--- Function to load checkbox settings in the ROC Province category.
---@param battle_type_key string #Key of the battle type of this battle.
---@param setting_key string #Key of the setting we're loading.
---@param default_value boolean #Default value of the setting we're loading.
function mct_map_replacer_load_checkbox_roc_province(battle_type_key, setting_key, default_value)
    mct_map_replacer_load_checkbox("wh3_main_chaos" .. province_based, battle_type_key, setting_key, default_value);
end

--- Function to load checkbox settings in the IME Coordinates category.
---@param battle_type_key string #Key of the battle type of this battle.
---@param setting_key string #Key of the setting we're loading.
---@param default_value boolean #Default value of the setting we're loading.
function mct_map_replacer_load_checkbox_ime_coordinates(battle_type_key, setting_key, default_value)
    mct_map_replacer_load_checkbox("main_warhammer" .. coord_based, battle_type_key, setting_key, default_value);
end

--- Function to load checkbox settings in the IME Region category.
---@param battle_type_key string #Key of the battle type of this battle.
---@param setting_key string #Key of the setting we're loading.
---@param default_value boolean #Default value of the setting we're loading.
function mct_map_replacer_load_checkbox_ime_region(battle_type_key, setting_key, default_value)
    mct_map_replacer_load_checkbox("main_warhammer" .. region_based, battle_type_key, setting_key, default_value);
end

--- Function to load checkbox settings in the IME Province category.
---@param battle_type_key string #Key of the battle type of this battle.
---@param setting_key string #Key of the setting we're loading.
---@param default_value boolean #Default value of the setting we're loading.
function mct_map_replacer_load_checkbox_ime_province(battle_type_key, setting_key, default_value)
    mct_map_replacer_load_checkbox("main_warhammer" .. province_based, battle_type_key, setting_key, default_value);
end

--- Function to load checkbox settings in the IEE Coordinates category.
---@param battle_type_key string #Key of the battle type of this battle.
---@param setting_key string #Key of the setting we're loading.
---@param default_value boolean #Default value of the setting we're loading.
function mct_map_replacer_load_checkbox_iee_coordinates(battle_type_key, setting_key, default_value)
    mct_map_replacer_load_checkbox("cr_combi_expanded" .. coord_based, battle_type_key, setting_key, default_value);
end

--- Function to load checkbox settings in the IEE Region category.
---@param battle_type_key string #Key of the battle type of this battle.
---@param setting_key string #Key of the setting we're loading.
---@param default_value boolean #Default value of the setting we're loading.
function mct_map_replacer_load_checkbox_iee_region(battle_type_key, setting_key, default_value)
    mct_map_replacer_load_checkbox("cr_combi_expanded" .. region_based, battle_type_key, setting_key, default_value);
end

--- Function to load checkbox settings in the IEE Province category.
---@param battle_type_key string #Key of the battle type of this battle.
---@param setting_key string #Key of the setting we're loading.
---@param default_value boolean #Default value of the setting we're loading.
function mct_map_replacer_load_checkbox_iee_province(battle_type_key, setting_key, default_value)
    mct_map_replacer_load_checkbox("cr_combi_expanded" .. province_based, battle_type_key, setting_key, default_value);
end

--- Function to load checkbox settings in the TOW Coordinates category.
---@param battle_type_key string #Key of the battle type of this battle.
---@param setting_key string #Key of the setting we're loading.
---@param default_value boolean #Default value of the setting we're loading.
function mct_map_replacer_load_checkbox_tow_coordinates(battle_type_key, setting_key, default_value)
    mct_map_replacer_load_checkbox("cr_oldworld" .. coord_based, battle_type_key, setting_key, default_value);
end

--- Function to load checkbox settings in the TOW Region category.
---@param battle_type_key string #Key of the battle type of this battle.
---@param setting_key string #Key of the setting we're loading.
---@param default_value boolean #Default value of the setting we're loading.
function mct_map_replacer_load_checkbox_tow_region(battle_type_key, setting_key, default_value)
    mct_map_replacer_load_checkbox("cr_oldworld" .. region_based, battle_type_key, setting_key, default_value);
end

--- Function to load checkbox settings in the TOW Province category.
---@param battle_type_key string #Key of the battle type of this battle.
---@param setting_key string #Key of the setting we're loading.
---@param default_value boolean #Default value of the setting we're loading.
function mct_map_replacer_load_checkbox_tow_province(battle_type_key, setting_key, default_value)
    mct_map_replacer_load_checkbox("cr_oldworld" .. province_based, battle_type_key, setting_key, default_value);
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
    setting:set_text(loc_prefix .. key, true)
    setting:set_tooltip_text(loc_prefix .. key .. "_tooltip", true)

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
    mod:set_version("1.1");
    mod:set_main_image("ui/mct/map_replacer.png", 300, 300)
end

local global_config_section = mod:add_new_section("a_mod_config", loc_prefix .. "global_mod_config", true)
if mct:get_version() == "0.9-beta" or mct:get_version() == "0.9" then
    global_config_section:set_is_collapsible(true)
    global_config_section:set_visibility(true)
end

mct_map_replacer_load_checkbox_global("enable", true);

-- Empty sections. To be populated by maps themselfs through their scripts.
for _, campaign_key in ipairs(supported_campaigns) do
    local coordinate_based_config_section = mod:add_new_section(campaign_key .. coord_based, loc_prefix .. campaign_key .. coord_based, true)
    if mct:get_version() == "0.9-beta" or mct:get_version() == "0.9" then
        coordinate_based_config_section:set_is_collapsible(true)
        coordinate_based_config_section:set_visibility(true)
    end

    local region_based_config_section = mod:add_new_section(campaign_key .. region_based, loc_prefix .. campaign_key .. region_based, true)
    if mct:get_version() == "0.9-beta" or mct:get_version() == "0.9" then
        region_based_config_section:set_is_collapsible(true)
        region_based_config_section:set_visibility(true)
    end

    local province_based_config_section = mod:add_new_section(campaign_key .. province_based, loc_prefix .. campaign_key .. province_based, true)
    if mct:get_version() == "0.9-beta" or mct:get_version() == "0.9" then
        province_based_config_section:set_is_collapsible(true)
        province_based_config_section:set_visibility(true)
    end
end
