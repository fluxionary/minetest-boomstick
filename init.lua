local function rightclick(itemstack, placer, pointed_thing)
    local meta = itemstack:get_meta()
    local formspec =(
        "size[8,9]" ..
        "field[1,1;4,1;radius;radius;%i]" ..
        "field[1,2;4,1;damage_radius;damage_radius;%i]" ..
        "checkbox[1,3;explode_center;explode_center;%s]" ..
        "checkbox[1,4;ignore_protection;ignore_protection;%s]" ..
        "checkbox[1,5;ignore_on_blast;ignore_on_blast;%s]" ..
        "button[1,6;2,1;save_boomstick;save]"
    ):format(
        tonumber(meta:get("radius") or 3) or 3,
        tonumber(meta:get("damage_radius") or 6) or 6,
        meta:get("explode_center") ~= nil,
        meta:get("ignore_protection") ~= nil,
        meta:get("ignore_on_blast") ~= nil
    )
    minetest.show_formspec(placer:get_player_name(), "set_boomstick", formspec)
end

minetest.register_tool("boomstick:stick", {
    description = "boom stick",
    inventory_image = "default_stick.png",
    range = 20,
    liquids_pointable = true,
    groups = {not_in_creative_inventory = 1},
    on_use = function(itemstack, user, pointed_thing)
        local meta = itemstack:get_meta()
        local boom_def = {
            radius = tonumber(meta:get("radius") or 3) or 3,
            damage_radius = tonumber(meta:get("damage_radius") or 6) or 6,
            explode_center = meta:get("explode_center") ~= nil,
            ignore_protection = meta:get("ignore_protection") ~= nil,
            ignore_on_blast = meta:get("ignore_on_blast") ~= nil,
        }
        if pointed_thing.type == "node" then
            local pos = pointed_thing.under
            tnt.boom(pos, boom_def)
        elseif pointed_thing.type == "object" then
            local pos = vector.round(pointed_thing.ref:get_pos())
            tnt.boom(pos, boom_def)
        else
            local dir = user:get_look_dir()
            -- TODO: projectile
        end
    end,
    on_place = rightclick,
    on_secondary_use = rightclick,
})


minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "set_boomstick" then
        return
    end
    local item = player:get_wielded_item()
    if item:get_name() ~= "boomstick:stick" then
        return
    end
    local meta = item:get_meta()
    local radius = tonumber(meta:get("radius") or 3) or 3
    local damage_radius = tonumber(meta:get("damage_radius") or 6) or 6
    if fields.radius then
        meta:set_int("radius", tonumber(fields.radius) or radius)
    end
    if fields.damage_radius then
        meta:set_int("damage_radius", tonumber(fields.damage_radius) or damage_radius)
    end
    if fields.explode_center ~= nil then
        meta:set_string("explode_center", (fields.explode_center == "true") and "1" or "")
    end
    if fields.ignore_protection ~= nil then
        meta:set_string("ignore_protection", (fields.ignore_protection == "true") and "1" or "")
    end
    if fields.ignore_on_blast ~= nil then
        meta:set_string("ignore_on_blast", (fields.ignore_on_blast == "true") and "1" or "")
    end
    player:set_wielded_item(item)
end)

minetest.register_node("boomstick:node", {
    description = "test unblastable",
    tiles = {"default_obsidian.png"},
    groups = {not_in_creative_inventory = 1, dig_immediate = 3},
    on_blast = function() end,
})

minetest.register_on_player_hpchange(function(player, hp_change, reason)
    if minetest.check_player_privs(player, "server") then
        return 0
    end
    return hp_change
end, true)
