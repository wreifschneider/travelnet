-- contains the node definition for a general travelnet that can be used by anyone
--   further travelnets can only be installed by the owner or by people with the travelnet_attach priv
--   digging of such a travelnet is limited to the owner and to people with the travelnet_remove priv (useful for admins to clean up)
-- (this can be overrided in config.lua)
-- Autor: Sokomine
local TColors = {
	"blue",
	"green",
	"violet",
	"yellow",
	"red",
}
for _, colors in ipairs(TColors) do
	minetest.register_node("travelnet:travelnet_public_" .. colors, {

		description = "Travelnet Public Box " .. colors:gsub("^%l", string.upper),

		drawtype = "mesh",
		mesh = "travelnet.obj",
		sunlight_propagates = true,
		paramtype = 'light',
		paramtype2 = "facedir",
		wield_scale = {x=0.6, y=0.6, z=0.6},
		selection_box = {
			type = "fixed",
			fixed = { -0.5, -0.5, -0.5, 0.5, 1.5, 0.5 }
		},

		collision_box = {
			type = "fixed",
			fixed = {

				{ 0.45, -0.5,-0.5,  0.5,  1.45, 0.5},
				{-0.5 , -0.5, 0.45, 0.45, 1.45, 0.5},
				{-0.5,  -0.5,-0.5 ,-0.45, 1.45, 0.5},

				--groundplate to stand on
				{ -0.5,-0.5,-0.5,0.5,-0.45, 0.5},
				--roof
				{ -0.5, 1.45,-0.5,0.5, 1.5, 0.5},

				-- control panel
				--                { -0.2, 0.6,  0.3, 0.2, 1.1,  0.5},

			},
		},

		tiles = {
			"travelnet_public_front_" .. colors ..".png",  -- backward view
			"travelnet_public_back_" .. colors .. ".png", -- front view
			"travelnet_side_" .. colors .. ".png", -- sides :)
			"default_steel_block.png",  -- view from top
			"default_clay.png",  -- view from bottom
		},
	    inventory_image = "travelnet_public_" .. colors .. "_inv.png",

	    groups = {cracky=1,choppy=1,snappy=1,travelnetbox=1,},

	    light_source = 10,

	    after_place_node  = function(pos, placer, itemstack)
		local meta = minetest.get_meta(pos);
	        meta:set_string("infotext",       "Travelnet-box (unconfigured)");
	        meta:set_string("station_name",   "");
	        meta:set_string("station_network","");
	        meta:set_string("owner",          placer:get_player_name() );
	        -- request initinal data
	        meta:set_string("formspec",
	                            "size[12,9]"..
	                            "field[0.3,3.6;6,0.7;station_name;Name of this station:;]"..
	                            "field[0.3,4.6;6,0.7;station_network;Assign to Network:;]"..
	                            "field[0.3,5.6;6,0.7;owner_name;(optional) owned by:;]"..
	                            "button_exit[6.3,4.2;1.7,0.7;station_set;Store]" );
	    end,

	    on_receive_fields = travelnet.on_receive_fields,
	    on_punch          = function(pos, node, puncher)
	                          travelnet.update_formspec(pos, puncher:get_player_name())
	    end,

	    can_dig = function( pos, player )
	                          return travelnet.can_dig( pos, player, 'travelnet box' )
	    end,

	    after_dig_node = function(pos, oldnode, oldmetadata, digger)
				  travelnet.remove_box( pos, oldnode, oldmetadata, digger )
	    end,

	    -- taken from VanessaEs homedecor fridge
	    on_place = function(itemstack, placer, pointed_thing)

	       local pos = pointed_thing.above;
	       if( minetest.get_node({x=pos.x, y=pos.y+1, z=pos.z}).name ~= "air" ) then

	          minetest.chat_send_player( placer:get_player_name(), 'Not enough vertical space to place the travelnet box!' )
	          return;
	       end

	       return minetest.item_place(itemstack, placer, pointed_thing);
	    end,

	})
	minetest.register_craft({
	        output = "travelnet:travelnet_public_" .. colors,
					recipe = {
					{"default:glass", "default:steel_ingot", "default:glass", },
					{"unifieddyes:" .. colors, "default:mese", "unifieddyes:" .. colors, },
					{"default:glass", "default:steel_ingot", "default:glass", },
				},
	})
end

for _, colors in ipairs(TColors) do
	minetest.register_node("travelnet:protected_travelnet_" .. colors, {

		description = "Travelnet Protected Box" .. colors:gsub("^%l", string.upper),

		drawtype = "mesh",
		mesh = "travelnet.obj",
		sunlight_propagates = true,
		paramtype = 'light',
		paramtype2 = "facedir",
		wield_scale = {x=0.6, y=0.6, z=0.6},
		selection_box = {
			type = "fixed",
			fixed = { -0.5, -0.5, -0.5, 0.5, 1.5, 0.5 }
		},

		collision_box = {
			type = "fixed",
			fixed = {

				{ 0.45, -0.5,-0.5,  0.5,  1.45, 0.5},
				{-0.5 , -0.5, 0.45, 0.45, 1.45, 0.5},
				{-0.5,  -0.5,-0.5 ,-0.45, 1.45, 0.5},

				--groundplate to stand on
				{ -0.5,-0.5,-0.5,0.5,-0.45, 0.5},
				--roof
				{ -0.5, 1.45,-0.5,0.5, 1.5, 0.5},

				-- control panel
				--                { -0.2, 0.6,  0.3, 0.2, 1.1,  0.5},

			},
		},

		tiles = {
			"travelnet_protected_front_" .. colors .. ".png",  -- backward view
			"travelnet_protected_back_" .. colors .. ".png", -- front view
			"travelnet_side_" .. colors .. ".png", -- sides :)
			"default_steel_block.png",  -- view from top
			"default_clay.png",  -- view from bottom
		},
	    inventory_image = "travelnet_protected_" .. colors .. "_inv.png",

	    groups = {cracky=1,choppy=1,snappy=1,travelnetbox=1,},

	    light_source = 10,

	    after_place_node  = function(pos, placer, itemstack)
		local meta = minetest.get_meta(pos);
	        meta:set_string("infotext",       "Travelnet-box (unconfigured)");
	        meta:set_string("station_name",   "");
	        meta:set_string("station_network","");
	        meta:set_string("owner",          placer:get_player_name() );
	        -- request initinal data
	        meta:set_string("formspec",
	                            "size[12,9]"..
	                            "field[0.3,3.6;6,0.7;station_name;Name of this station:;]"..
	                            "field[0.3,4.6;6,0.7;station_network;Assign to Network:;]"..
	                            "field[0.3,5.6;6,0.7;owner_name;(optional) owned by:;]"..
	                            "button_exit[6.3,4.2;1.7,0.7;station_set;Store]" );
	    end,

	    on_receive_fields = function(pos, formname, fields, player)
				local name = player:get_player_name()
				protector.reFields[name] = true
				if minetest.is_protected(pos, name) then
					return;
				end

				return travelnet.on_receive_fields(pos, formname, fields, player)
			end,
	    on_punch          = function(pos, node, puncher)
	                          travelnet.update_formspec(pos, puncher:get_player_name())
	    end,

	    can_dig = function( pos, player )
	                          return travelnet.can_dig( pos, player, 'travelnet box' )
	    end,

	    after_dig_node = function(pos, oldnode, oldmetadata, digger)
				  travelnet.remove_box( pos, oldnode, oldmetadata, digger )
	    end,

	    -- taken from VanessaEs homedecor fridge
	    on_place = function(itemstack, placer, pointed_thing)

	       local pos = pointed_thing.above;
	       if( minetest.get_node({x=pos.x, y=pos.y+1, z=pos.z}).name ~= "air" ) then

	          minetest.chat_send_player( placer:get_player_name(), 'Not enough vertical space to place the travelnet box!' )
	          return;
	       end

	       return minetest.item_place(itemstack, placer, pointed_thing);
	    end,

	})
	minetest.register_craft({
	        output = "travelnet:protected_travelnet_" .. colors,
	        recipe = {
						{'default:copper_ingot','','default:copper_ingot'},
						{'','travelnet:travelnet_public_' .. colors,''},
						{'default:copper_ingot','','default:copper_ingot'},
				},
	})

	minetest.register_craft({
	        output = "travelnet:travelnet_public_" .. colors,
	        recipe = {
						{'travelnet:protected_travelnet_' .. colors}
				},
	})
end

for _, colors in ipairs(TColors) do
	minetest.register_node("travelnet:locked_travelnet_" .. colors, {

		description = "Travelnet Locked Box" .. colors:gsub("^%l", string.upper),

		drawtype = "mesh",
		mesh = "travelnet.obj",
		sunlight_propagates = true,
		paramtype = 'light',
		paramtype2 = "facedir",
		wield_scale = {x=0.6, y=0.6, z=0.6},
		selection_box = {
			type = "fixed",
			fixed = { -0.5, -0.5, -0.5, 0.5, 1.5, 0.5 }
		},

		collision_box = {
			type = "fixed",
			fixed = {

				{ 0.45, -0.5,-0.5,  0.5,  1.45, 0.5},
				{-0.5 , -0.5, 0.45, 0.45, 1.45, 0.5},
				{-0.5,  -0.5,-0.5 ,-0.45, 1.45, 0.5},

				--groundplate to stand on
				{ -0.5,-0.5,-0.5,0.5,-0.45, 0.5},
				--roof
				{ -0.5, 1.45,-0.5,0.5, 1.5, 0.5},

				-- control panel
				--                { -0.2, 0.6,  0.3, 0.2, 1.1,  0.5},

			},
		},

		tiles = {
			"travelnet_locked_front_" .. colors .. ".png",  -- backward view
			"travelnet_locked_back_" .. colors .. ".png", -- front view
			"travelnet_side_" .. colors .. ".png", -- sides :)
			"default_steel_block.png",  -- view from top
			"default_clay.png",  -- view from bottom
		},
	    inventory_image = "travelnet_locked_" .. colors .."_inv.png",

	    groups = {cracky=1,choppy=1,snappy=1,travelnetbox=1,},

	    light_source = 10,

	    after_place_node  = function(pos, placer, itemstack)
		local meta = minetest.get_meta(pos);
	        meta:set_string("infotext",       "Travelnet-box (unconfigured)");
	        meta:set_string("station_name",   "");
	        meta:set_string("station_network","");
	        meta:set_string("owner",          placer:get_player_name() );
	        -- request initinal data
	        meta:set_string("formspec",
	                            "size[12,9]"..
	                            "field[0.3,3.6;6,0.7;station_name;Name of this station:;]"..
	                            "field[0.3,4.6;6,0.7;station_network;Assign to Network:;]"..
	                            "field[0.3,5.6;6,0.7;owner_name;(optional) owned by:;]"..
	                            "button_exit[6.3,4.2;1.7,0.7;station_set;Store]" );
	    end,

	    on_receive_fields = function(pos, formname, fields, player)
				local meta = minetest.get_meta(pos);
				local name = player:get_player_name()
				if meta:get_string( "owner" ) == ""
				or name == meta:get_string( "owner" )
				or minetest.check_player_privs(name, {server=true}) then
					return travelnet.on_receive_fields(pos, formname, fields, player)
				end
				minetest.chat_send_player(name, "The Travelnet Box is locked!")
				return;
			end,
	    on_punch          = function(pos, node, puncher)
	                          travelnet.update_formspec(pos, puncher:get_player_name())
	    end,

	    can_dig = function( pos, player )
	                          return travelnet.can_dig( pos, player, 'travelnet box' )
	    end,

	    after_dig_node = function(pos, oldnode, oldmetadata, digger)
				  travelnet.remove_box( pos, oldnode, oldmetadata, digger )
	    end,

	    -- taken from VanessaEs homedecor fridge
	    on_place = function(itemstack, placer, pointed_thing)

	       local pos = pointed_thing.above;
	       if( minetest.get_node({x=pos.x, y=pos.y+1, z=pos.z}).name ~= "air" ) then

	          minetest.chat_send_player( placer:get_player_name(), 'Not enough vertical space to place the travelnet box!' )
	          return;
	       end

	       return minetest.item_place(itemstack, placer, pointed_thing);
	    end,

	})
	minetest.register_craft({
	        output = "travelnet:locked_travelnet_" .. colors,
	        recipe = {
						{'default:steel_ingot','','default:steel_ingot'},
						{'','travelnet:travelnet_public_' .. colors,''},
						{'default:steel_ingot','','default:steel_ingot'},
				},
	})
	minetest.register_craft({
	        output = "travelnet:travelnet_public_" .. colors,
	        recipe = {
						{'travelnet:locked_travelnet_' .. colors}
				},
	})
end

minetest.register_alias("travelnet:travelnet", "travelnet:travelnet_public_yellow")
minetest.register_alias("travelnet:protected_travelnet", "travelnet:protected_travelnet_violet")
minetest.register_alias("travelnet:locked_travelnet", "travelnet:locked_travelnet_blue")





--[
-- minetest.register_craft({
--         output = "travelnet:travelnet",
--         recipe = travelnet.travelnet_recipe,
-- })
