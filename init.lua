local W = 8
local lists = {}
local inv = {}
local tab = 1
local page = 1

local function inv_fs()
	local list = lists[tab] or "craft"
	local size = inv[list] and #inv[list] or 32
	local fs = "size["..(W+0.4)..",9.5]" ..
		"listcolors[#777;#AAA]" ..
		"tabheader[0,0;tabs;"..table.concat(lists,",")..";"..(tab or "1")..";false;false]" ..
		"label[0.3,-0.3;"..(lists[tab] or "").."]" ..
		"label["..(W-1.5)..",4.6;Trash:]" ..
		"list[detached:trash;main;"..(W-0.8)..",4.4;1,1;0]" ..
		"list[current_player;main;0.2,5.5;"..W..",4;0]" ..
		(list == "craft" and
		"list[current_player;craft;"..(inv["craft"] and #inv["craft"] == 4 and "3,0;2,2" or "2,0;3,3")..";0]" ..
		"label[5.3,0.2;->]" ..
		"list[current_player;craftpreview;6,0;1,1;]" ..
		"list[current_player;craftresult;6,1;1,1;]" ..
		"listring[current_player;main]" ..
		"listring[current_player;craft]"
		or
		"list[current_player;"..list..";0.2,0.2;"..W..",4;"..(size >= (W*4) and tostring((W*4)*page-(W*4)) or "0").."]" ..
		"listring[]" ..
		(size > 32 and
		"button[0.2,4.4;1,1;prevpage;<-]" ..
		"field[1.3,4.7;1.4,1;page;;"..(page or "1").."]" ..
		"field_close_on_enter[page;false]" ..
		"button[2.2,4.4;1,1;nextpage;->]" or ""))
	core.show_formspec("cinv",fs)
end

core.register_on_inventory_open(function(inventory)
	inv = inventory
	lists = {}
	for listname,list in pairs(inventory) do
		if listname ~= "main" and listname ~= "craft" and listname ~= "craftresult" and listname ~= "craftpreview" then
			table.insert(lists,listname)
		end
	end
	table.sort(lists)
	table.insert(lists,1,"craft")
	if inv["main"] and #inv["main"] == 36 then
		W = 9
	end
	local ctrl = core.localplayer:get_control()
	if ctrl and ctrl.aux1 and not ctrl.sneak then
		core.after(0,function()
			inv_fs()
		end)
	end
end)

core.register_chatcommand("cinv",{
  description = "Open Custom Inventory",
  func = function(param)
	inv_fs()
	return true, table.concat(lists,", ")
end})
core.register_on_formspec_input(function(formname,fields)
	if formname ~= "cinv" then return end
	if fields.tabs then
		tab = tonumber(fields.tabs) or 1
		inv_fs()
	end
	if fields.prevpage and page > 1 then
		page = page - 1
		inv_fs()
	end
	if fields.nextpage then
		page = page + 1
		inv_fs()
	end
	if fields.page and fields.key_enter_field == "page" then
		page = tonumber(fields.page) or page
		inv_fs()
	end
end)
