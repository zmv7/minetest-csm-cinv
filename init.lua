local W = 8
local inv = {}
local lists_top = {}
local lists_bot = {}
local tab_top = 1
local tab_bot = 1
local hash = {}
local offset_mt = {
	__index = function(self ,key)
		if key == "reset" then
			return function()
				for k in pairs(self) do
					self[k] = nil
				end
			end
		else
			return 0
		end
	end
}
local offset_top = setmetatable({}, offset_mt)
local offset_bot = setmetatable({}, offset_mt)

local function cinv()
	local list_top = lists_top[tab_top] or "craft"
	local list_bot = lists_bot[tab_bot] or "main"
	local size_top = inv[list_top] and #inv[list_top] or 32
	local size_bot = inv[list_bot] and #inv[list_bot] or 32
	local fs = "size["..(W+0.4)..",9.5]" ..
		"listcolors[#777;#AAA]" ..
		"tabheader[0,0;tabs_top;"..table.concat(lists_top,",")..";"..(tab_top or "1")..";false;false]" ..
		"tabheader[0,10.7;tabs_bot;"..table.concat(lists_bot,",")..";"..(tab_bot or "1")..";false;false]" ..
		"label[0.3,-0.3;"..(lists_top[tab_top] or "").."]" ..
		"label["..(W-1.5)..",4.6;Trash:]" ..
		"list[detached:trash;main;"..(W-0.8)..",4.4;1,1;0]" ..
		"list[current_player;"..list_bot..";0.2,5.5;"..W..",4;"..(size_bot >= (W*4) and tostring(offset_bot[tab_bot]*W) or "0").."]" ..
		(size_bot > (W*4) and
		"scrollbaroptions[min=0;max="..tostring(math.ceil(size_bot/W))-4 ..";smallstep=1;largestep=4]" ..
		"scrollbar[8.1,5.5;0.3,3.9;vertical;scroll_bot;"..offset_bot[tab_bot].."]" or "") ..
		(list_top == "craft" and
		"list[current_player;craft;"..(inv["craft"] and #inv["craft"] == 4 and "3,0;2,2" or "2,0;3,3")..";0]" ..
		"listring[]" ..
		"label[5.3,0.2;->]" ..
		"list[current_player;craftpreview;6,0;1,1;]" ..
		"list[current_player;craftresult;6,1;1,1;]"
		or
		"list[current_player;"..list_top..";0.2,0.2;"..W..",4;"..(size_top >= (W*4) and tostring(offset_top[tab_top]*W) or "0").."]" ..
		"listring[]" ..
		(size_top > (W*4) and
		"set_focus[scroll;true]" ..
		"scrollbaroptions[min=0;max="..tostring(math.ceil(size_top/W))-4 ..";smallstep=1;largestep=4]" ..
		"scrollbar[8.1,0.2;0.3,3.9;vertical;scroll_top;"..offset_top[tab_top].."]" or ""))
	core.show_formspec("cinv",fs)
end

core.register_on_inventory_open(function(inventory)
	local newlists = {}
	local newhash = {}
	for listname,list in pairs(inventory) do
		table.insert(newhash, #list)
		if listname ~= "main" and listname ~= "craft" and listname ~= "craftresult" and listname ~= "craftpreview" then
			table.insert(newlists,listname)
		end
	end
	if table.concat(hash) ~= table.concat(newhash) then
		inv = inventory
		hash = newhash
		table.sort(newlists)
		lists_top = table.copy(newlists)
		lists_bot = table.copy(newlists)
		table.insert(lists_top,1,"craft")
		table.insert(lists_bot,1,"main")
		if inventory["main"] then
			W = math.ceil(#inventory["main"]/4)
			if W < 8 then
				W = 8
			end
		end
		offset_top:reset()
		offset_bot:reset()
		tab_top = 1
		tab_bot = 1
	end
	local ctrl = core.localplayer:get_control()
	if ctrl and ctrl.aux1 and not ctrl.sneak then
		core.after(0,function()
			cinv()
		end)
	end
end)

core.register_chatcommand("cinv",{
  description = "Open Custom Inventory",
  func = function(param)
	cinv()
	return true, table.concat(lists_top,", ")
end})

core.register_on_formspec_input(function(formname,fields)
	if formname ~= "cinv" then return end
	if fields.tabs_top then
		tab_top = tonumber(fields.tabs_top) or 1
		cinv()
		return
	end
	if fields.tabs_bot then
		tab_bot = tonumber(fields.tabs_bot) or 1
		cinv()
		return
	end
	if fields.scroll_top then
		local evnt = core.explode_scrollbar_event(fields.scroll_top)
		offset_top[tab_top] = evnt.value
		cinv()
	end
	if fields.scroll_bot then
		local evnt = core.explode_scrollbar_event(fields.scroll_bot)
		offset_bot[tab_bot] = evnt.value
		cinv()
	end
end)
