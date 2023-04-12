module(..., package.seeall)

local 全局设置 = require("公用.全局设置")
local 游戏设置 = require("公用.游戏设置")
local 消息 = require("网络.消息")
local 背包UI = require("主界面.背包UI")
local 物品提示UI = require("主界面.物品提示UI")
local 装备提示UI = require("主界面.装备提示UI")
local 角色逻辑 = require("主界面.角色逻辑")

m_init = false
m_selectitem = nil
m_pushiteminfo = {}
m_gainiteminfo = {}
m_queryiteminfo = {}
tipsui = nil
tipsgrid = nil
ITEMCOUNT = 40

function setGainItemInfo(gainiteminfo)
	m_gainiteminfo = {}
	for i,v in ipairs(gainiteminfo) do
		m_gainiteminfo[#m_gainiteminfo+1] = {
			pos=v[1],
			id=v[2],
			name=v[3],
			desc=v[4],
			type=v[5],
			count=v[6],
			icon=v[7],
			cd=v[8]+rtime(),
			cdmax=v[9],
			bind=v[10],
			grade=v[11],
			job=v[12],
			level=v[13],
			strengthen=v[14],
			prop=v[15],
			addprop=v[16],
			attachprop=v[17],
			gemprop=v[18],
			ringsoul=v[19],
			power=v[20],
			equippos=v[21],
			color=v[22],
			suitprop=v[23],
			suitname=v[24],
			runeprop=v[25],
		}
	end
	updateGainItem()
end

function updateGainItem()
	if not m_init then
		return
	end
	for i=1,24 do
		local v = m_gainiteminfo[i]
		if v then
			ui.gainitems[i].icon:setTextureFile(全局设置.getItemIconUrl(v.icon))
			ui.gainitems[i].grade:setTextureFile(全局设置.getGradeUrl(v.grade))
			ui.gainitems[i].lock:setTextureFile(v.bind == 1 and UIPATH.."公用/grid/img_bind.png" or "")
			ui.gainitems[i].count:setText(v.count > 1 and v.count or "")
			ui.gainitems[i].strengthen:setText(v.strengthen > 0 and "+"..v.strengthen or "")
		else
			ui.gainitems[i].icon:setTextureFile("")
			ui.gainitems[i].grade:setTextureFile("")
			ui.gainitems[i].lock:setTextureFile("")
			ui.gainitems[i].count:setText("")
			ui.gainitems[i].strengthen:setText("")
		end
	end
end

function pushItemData(itemdata)
	if itemdata.type ~= 3 then

	end
	for i,v in ipairs(m_pushiteminfo) do
		if v == itemdata.pos then
			return
		end
	end
	if #m_pushiteminfo >= ITEMCOUNT then
		return
	end
	m_pushiteminfo[#m_pushiteminfo+1] = itemdata.pos
	背包UI.setGridGray(itemdata.pos, true)
	update()
end

function update()
	if not m_init then
		return
	end
	for i=#m_pushiteminfo,1,-1 do
		local itemdata = 背包UI.m_itemdata[m_pushiteminfo[i]]
		if not itemdata or itemdata.count == 0 then
			背包UI.setGridGray(m_pushiteminfo[i], false)
			table.remove(m_pushiteminfo, i)
		end
	end
	for i=1,ITEMCOUNT do
		local v = 背包UI.m_itemdata[m_pushiteminfo[i]]
		if v then
			local 发光特效 = 0
			for ii,vv in ipairs(v.prop) do
				if vv[1] == 46 then
					发光特效 = vv[2]
				end
			end
			for ii,vv in ipairs(v.addprop) do
				if vv[1] == 46 then
					发光特效 = vv[2]
				end
			end
			if 发光特效 ~= 0 then
				if not ui.items[i].effect then
					ui.items[i].effect = F3DImageAnim:new()
					ui.items[i].effect:setBlendType(F3DRenderContext.BLEND_ADD)
					ui.items[i].effect:setPositionX(ui.items[i].grid:getWidth()/2)
					ui.items[i].effect:setPositionY(ui.items[i].grid:getHeight()/2)
					ui.items[i].grid:addChild(ui.items[i].effect)
				end
				ui.items[i].effect:setAnimPack(全局设置.getAnimPackUrl(发光特效))
			elseif ui.items[i].effect then
				ui.items[i].effect:reset()
			end
			ui.items[i].icon:setTextureFile(全局设置.getItemIconUrl(v.icon))
			ui.items[i].grade:setTextureFile(全局设置.getGradeUrl(v.grade))
			ui.items[i].lock:setTextureFile(v.bind == 1 and UIPATH.."公用/grid/img_bind.png" or "")
			ui.items[i].count:setText(v.count > 1 and v.count or "")
			ui.items[i].strengthen:setText(v.strengthen > 0 and "+"..v.strengthen or "")
			if v.cd > rtime() and v.cdmax > 0 then
				local frameid = math.floor((1 - (v.cd - rtime()) / v.cdmax) * 32)
				ui.items[i].cd:setVisible(true)
				ui.items[i].cd:setFrameRate(1000*(32-frameid)/(v.cd - rtime()), frameid)
			else
				ui.items[i].cd:setFrameRate(0)
				ui.items[i].cd:setVisible(false)
			end
		else
			if ui.items[i].effect then
				ui.items[i].effect:reset()
			end
			ui.items[i].icon:setTextureFile("")
			ui.items[i].grade:setTextureFile("")
			ui.items[i].lock:setTextureFile("")
			ui.items[i].count:setText("")
			ui.items[i].strengthen:setText("")
			ui.items[i].cd:setFrameRate(0)
			ui.items[i].cd:setVisible(false)
		end
	end
	if #m_pushiteminfo > 0 then
		for i=1,ITEMCOUNT do
			m_queryiteminfo[i] = m_pushiteminfo[i] or 0
		end
		消息.CG_ITEM_RESOLVE_QUERY(m_queryiteminfo)
	else
		m_gainiteminfo = {}
		updateGainItem()
	end
end

function checkGridContPos(px, py)
	if not m_init then return end
	local x = px - ui:getPositionX()
	local y = py - ui:getPositionY()
	local gridcont = ui:findComponent("gridcont")
	if x >= gridcont:getPositionX() and x <= gridcont:getPositionX() + gridcont:getWidth() and
		y >= gridcont:getPositionY() and y <= gridcont:getPositionY() + gridcont:getHeight() then
		return true
	end
end

function onCDPlayOut(e)
	e:getTarget():setFrameRate(0)
	e:getTarget():setVisible(false)
end

function checkTipsPos()
	if not ui or not tipsgrid then
		return
	end
	if not tipsui or not tipsui:isVisible() or not tipsui:isInited() then
	else
		local x = ui:getPositionX()+tipsgrid:getPositionX()+tipsgrid:getWidth()
		local y = ui:getPositionY()+tipsgrid:getPositionY()
		local p = tipsgrid:getParent()
		while p and p ~= ui do
			x = x + p:getPositionX()
			y = y + p:getPositionY()
			p = p:getParent()
		end
		if x + tipsui:getWidth() > stage:getWidth() then
			tipsui:setPositionX(x - tipsui:getWidth() - tipsgrid:getWidth())
		else
			tipsui:setPositionX(x)
		end
		if y + tipsui:getHeight() > stage:getHeight() then
			tipsui:setPositionY(stage:getHeight() - tipsui:getHeight())
		else
			tipsui:setPositionY(y)
		end
	end
end

function onGridDBClick(e)
	local g = e:getCurrentTarget()
	local p = e:getLocalPos()
	if g == nil or m_pushiteminfo[g.id] == nil or m_pushiteminfo[g.id] == 0 then
	else
		背包UI.setGridGray(m_pushiteminfo[g.id], false)
		背包UI.hideAllTipsUI()
		table.remove(m_pushiteminfo,g.id)
		update()
	end
end

function onGridOver(e)
	if ui.tweenhide then return end
	local g = g_mobileMode and e:getCurrentTarget() or e:getTarget()
	if g == nil then
	elseif F3DUIManager.sTouchComp ~= g then
	else
		local itemdata
		if g.gain then
			itemdata = m_gainiteminfo[g.id]
		else
			itemdata = 背包UI.m_itemdata[m_pushiteminfo[g.id]]
		end
		if not itemdata then
			return
		end
		if itemdata.type ~= 3 then
			装备提示UI.hideUI()
			物品提示UI.initUI()
			物品提示UI.setItemData(itemdata)
			tipsui = 物品提示UI.ui
		else
			物品提示UI.hideUI()
			装备提示UI.initUI()
			装备提示UI.setItemData(itemdata)
			tipsui = 装备提示UI.ui
		end
		tipsgrid = g
		if not tipsui:isInited() then
			tipsui:addEventListener(F3DObjEvent.OBJ_INITED, func_oe(checkTipsPos))
		else
			checkTipsPos()
		end
	end
end

function onGridOut(e)
	local g = e:getTarget()
	if g ~= nil and g == tipsgrid and tipsui then
		装备提示UI.hideUI()
		物品提示UI.hideUI()
		tipsui = nil
		tipsgrid = nil
	end
end

function onClose(e)
	if tipsui then
		物品提示UI.hideUI()
		装备提示UI.hideUI()
		tipsui = nil
		tipsgrid = nil
	end
	if m_init then
		for i=#m_pushiteminfo,1,-1 do
			背包UI.setGridGray(m_pushiteminfo[i], false)
			table.remove(m_pushiteminfo, i)
		end
		update()
	end
	ui:setVisible(false)
	
	ui:releaseMouse()
	ui.close:releaseMouse()
	背包UI.checkResize()
	e:stopPropagation()
end

function onMouseDown(e)
	if 背包UI.ui and 背包UI.ui:isVisible() then
		uiLayer:removeChild(背包UI.ui)
		uiLayer:addChild(背包UI.ui)
	end
	uiLayer:removeChild(ui)
	uiLayer:addChild(ui)
	e:stopPropagation()
end

function onUIInit()
	ui.close = ui:findComponent("titlebar,close")
	ui.close:addEventListener(F3DMouseEvent.CLICK, func_me(onClose))
	ui:addEventListener(F3DMouseEvent.MOUSE_DOWN, func_me(onMouseDown))
	ui.items = {}
	for i=1,ITEMCOUNT do
		ui.items[i] = {}
		ui.items[i].grid = ui:findComponent("gridcont,grid_"..(i-1))
		ui.items[i].grid.id = i
ui.items[i].effect=nil
		ui.items[i].grid:addEventListener(F3DMouseEvent.DOUBLE_CLICK, func_me(onGridDBClick))
		ui.items[i].grid:addEventListener(F3DMouseEvent.RIGHT_CLICK, func_me(onGridDBClick))
		if g_mobileMode then
			ui.items[i].grid:addEventListener(F3DMouseEvent.CLICK, func_me(onGridOver))
		else
			ui.items[i].grid:addEventListener(F3DUIEvent.MOUSE_OVER, func_ue(onGridOver))
			ui.items[i].grid:addEventListener(F3DUIEvent.MOUSE_OUT, func_ue(onGridOut))
		end
		ui.items[i].icon = F3DImage:new()
		ui.items[i].icon:setPositionX(math.floor(ui.items[i].grid:getWidth()/2))
		ui.items[i].icon:setPositionY(math.floor(ui.items[i].grid:getHeight()/2))
		ui.items[i].icon:setPivot(0.5,0.5)
		ui.items[i].grid:addChild(ui.items[i].icon)
		ui.items[i].grade = F3DImage:new()
		ui.items[i].grade:setPositionX(1)
		ui.items[i].grade:setPositionY(1)
		ui.items[i].grade:setWidth(ui.items[i].grid:getWidth()-2)
		ui.items[i].grade:setHeight(ui.items[i].grid:getHeight()-2)
		ui.items[i].grid:addChild(ui.items[i].grade)
		ui.items[i].lock = F3DImage:new()
		ui.items[i].lock:setPositionX(g_mobileMode and 6 or 2)
		ui.items[i].lock:setPositionY(ui.items[i].grid:getHeight()-(g_mobileMode and 8 or 2))
		ui.items[i].lock:setPivot(0,1)
		ui.items[i].grid:addChild(ui.items[i].lock)
		ui.items[i].count = F3DTextField:new()
		if g_mobileMode then
			ui.items[i].count:setTextFont("宋体",16,false,false,false)
		end
		ui.items[i].count:setPositionX(ui.items[i].grid:getWidth()-(g_mobileMode and 8 or 2))
		ui.items[i].count:setPositionY(ui.items[i].grid:getHeight()-(g_mobileMode and 8 or 2))
		ui.items[i].count:setPivot(1,1)
		ui.items[i].grid:addChild(ui.items[i].count)
		ui.items[i].strengthen = F3DTextField:new()
		if g_mobileMode then
			ui.items[i].strengthen:setTextFont("宋体",16,false,false,false)
		end
		ui.items[i].strengthen:setPositionX(ui.items[i].grid:getWidth()-(g_mobileMode and 8 or 2))
		ui.items[i].strengthen:setPositionY((g_mobileMode and 8 or 2))
		ui.items[i].strengthen:setPivot(1,0)
		ui.items[i].grid:addChild(ui.items[i].strengthen)
		ui.items[i].cd = F3DComponent:new()
		ui.items[i].cd:setBackground(UIPATH.."主界面/cd.png")
		ui.items[i].cd:setSizeClips("32,1,0,0")
		ui.items[i].cd:setTouchable(false)
		ui.items[i].cd:setPositionX(2)
		ui.items[i].cd:setPositionY(2)
		ui.items[i].cd:setWidth(ui.items[i].grid:getWidth()-4)
		ui.items[i].cd:setHeight(ui.items[i].grid:getHeight()-4)
		ui.items[i].cd:addEventListener(F3DObjEvent.OBJ_PLAYOUT, func_oe(onCDPlayOut))
		ui.items[i].cd:setVisible(false)
		ui.items[i].grid:addChild(ui.items[i].cd)
	end
	ui.gainitems = {}
	for i=1,24 do
		ui.gainitems[i] = {}
		ui.gainitems[i].grid = ui:findComponent("gridcont_1,grid_"..(i-1))
		ui.gainitems[i].grid.id = i
		ui.gainitems[i].grid.gain = true
		if g_mobileMode then
			ui.gainitems[i].grid:addEventListener(F3DMouseEvent.CLICK, func_me(onGridOver))
		else
			ui.gainitems[i].grid:addEventListener(F3DUIEvent.MOUSE_OVER, func_ue(onGridOver))
			ui.gainitems[i].grid:addEventListener(F3DUIEvent.MOUSE_OUT, func_ue(onGridOut))
		end
		ui.gainitems[i].icon = F3DImage:new()
		ui.gainitems[i].icon:setPositionX(math.floor(ui.gainitems[i].grid:getWidth()/2))
		ui.gainitems[i].icon:setPositionY(math.floor(ui.gainitems[i].grid:getHeight()/2))
		ui.gainitems[i].icon:setPivot(0.5,0.5)
		ui.gainitems[i].grid:addChild(ui.gainitems[i].icon)
		ui.gainitems[i].grade = F3DImage:new()
		ui.gainitems[i].grade:setPositionX(1)
		ui.gainitems[i].grade:setPositionY(1)
		ui.gainitems[i].grade:setWidth(ui.items[i].grid:getWidth()-2)
		ui.gainitems[i].grade:setHeight(ui.items[i].grid:getHeight()-2)
		ui.gainitems[i].grid:addChild(ui.gainitems[i].grade)
		ui.gainitems[i].lock = F3DImage:new()
		ui.gainitems[i].lock:setPositionX(g_mobileMode and 6 or 2)
		ui.gainitems[i].lock:setPositionY(ui.items[i].grid:getHeight()-(g_mobileMode and 8 or 2))
		ui.gainitems[i].lock:setPivot(0,1)
		ui.gainitems[i].grid:addChild(ui.gainitems[i].lock)
		ui.gainitems[i].count = F3DTextField:new()
		if g_mobileMode then
			ui.gainitems[i].count:setTextFont("宋体",16,false,false,false)
		end
		ui.gainitems[i].count:setPositionX(ui.items[i].grid:getWidth()-(g_mobileMode and 8 or 2))
		ui.gainitems[i].count:setPositionY(ui.items[i].grid:getHeight()-(g_mobileMode and 8 or 2))
		ui.gainitems[i].count:setPivot(1,1)
		ui.gainitems[i].grid:addChild(ui.gainitems[i].count)
		ui.gainitems[i].strengthen = F3DTextField:new()
		if g_mobileMode then
			ui.gainitems[i].strengthen:setTextFont("宋体",16,false,false,false)
		end
		ui.gainitems[i].strengthen:setPositionX(ui.items[i].grid:getWidth()-(g_mobileMode and 8 or 2))
		ui.gainitems[i].strengthen:setPositionY((g_mobileMode and 8 or 2))
		ui.gainitems[i].strengthen:setPivot(1,0)
		ui.gainitems[i].grid:addChild(ui.gainitems[i].strengthen)
	end
	ui.autoput_1 = ui:findComponent("btncont,autoput_1")
	ui.autoput_1:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
		for i=#m_pushiteminfo,1,-1 do
			背包UI.setGridGray(m_pushiteminfo[i], false)
			table.remove(m_pushiteminfo, i)
		end
		for k,v in pairs(背包UI.m_itemdata) do
			if #m_pushiteminfo >= ITEMCOUNT then
				break
			elseif not 游戏设置.RESOLVECOLOR then
				m_pushiteminfo[#m_pushiteminfo+1] = k
				背包UI.setGridGray(k, true)
			elseif v.type == 3 and v.grade == 1 and v.cd <= rtime() then
				m_pushiteminfo[#m_pushiteminfo+1] = k
				背包UI.setGridGray(k, true)
			end
		end
		update()
	end))
	ui.autoput_2 = ui:findComponent("btncont,autoput_2")
	ui.autoput_2:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
		for i=#m_pushiteminfo,1,-1 do
			背包UI.setGridGray(m_pushiteminfo[i], false)
			table.remove(m_pushiteminfo, i)
		end
		for k,v in pairs(背包UI.m_itemdata) do
			if #m_pushiteminfo >= ITEMCOUNT then
				break
			elseif not 游戏设置.RESOLVECOLOR and v.type == 1 then
				m_pushiteminfo[#m_pushiteminfo+1] = k
				背包UI.setGridGray(k, true)
			elseif v.type == 3 and v.grade == 2 and v.cd <= rtime() then
				m_pushiteminfo[#m_pushiteminfo+1] = k
				背包UI.setGridGray(k, true)
			end
		end
		update()
	end))
	ui.autoput_3 = ui:findComponent("btncont,autoput_3")
	ui.autoput_3:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
		for i=#m_pushiteminfo,1,-1 do
			背包UI.setGridGray(m_pushiteminfo[i], false)
			table.remove(m_pushiteminfo, i)
		end
		for k,v in pairs(背包UI.m_itemdata) do
			if #m_pushiteminfo >= ITEMCOUNT then
				break
			elseif not 游戏设置.RESOLVECOLOR and v.type == 2 then
				m_pushiteminfo[#m_pushiteminfo+1] = k
				背包UI.setGridGray(k, true)
			elseif v.type == 3 and v.grade == 3 and v.cd <= rtime() then
				m_pushiteminfo[#m_pushiteminfo+1] = k
				背包UI.setGridGray(k, true)
			end
		end
		update()
	end))
	ui.autoput_4 = ui:findComponent("btncont,autoput_4")
	ui.autoput_4:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
		for i=#m_pushiteminfo,1,-1 do
			背包UI.setGridGray(m_pushiteminfo[i], false)
			table.remove(m_pushiteminfo, i)
		end
		for k,v in pairs(背包UI.m_itemdata) do
			if #m_pushiteminfo >= ITEMCOUNT then
				break
			elseif not 游戏设置.RESOLVECOLOR and v.type == 3 then
				m_pushiteminfo[#m_pushiteminfo+1] = k
				背包UI.setGridGray(k, true)
			elseif v.type == 3 and v.grade == 4 and v.cd <= rtime() then
				m_pushiteminfo[#m_pushiteminfo+1] = k
				背包UI.setGridGray(k, true)
			end
		end
		update()
	end))
	ui.resolve = ui:findComponent("btncont,resolve")
	ui.resolve:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
		if #m_pushiteminfo > 0 then
			for i=1,ITEMCOUNT do
				m_queryiteminfo[i] = m_pushiteminfo[i] or 0
			end
			消息.CG_ITEM_RESOLVE(m_queryiteminfo)
		end
	end))
	if g_mobileMode then
		ui.returncont = ui:findComponent("returncont")
		ui.returnui = ui:findComponent("returncont,return")
if ui.returnui then
		ui.returnui:addEventListener(F3DMouseEvent.CLICK, func_me(背包UI.onOtherReturn))
end
if ui.returncont then
		ui.returncont:setVisible(false)
	end
end
	if 游戏设置.RESOLVECOLOR then
		ui.autoput_1:setTitleText(txt("放入白色"))
		ui.autoput_2:setTitleText(txt("放入绿色"))
		ui.autoput_3:setTitleText(txt("放入蓝色"))
		ui.autoput_4:setTitleText(txt("放入紫色"))
	end
_v_251("装备分解UI",ui)
	m_init = true
	update()
	背包UI.checkResize()
end

function isHided()
	return not ui or not ui:isVisible() or ui.tweenhide
end

function hideUI()
	if tipsui then
		物品提示UI.hideUI()
		装备提示UI.hideUI()
		tipsui = nil
		tipsgrid = nil
	end
	if m_init then
		for i=#m_pushiteminfo,1,-1 do
			背包UI.setGridGray(m_pushiteminfo[i], false)
			table.remove(m_pushiteminfo, i)
		end
		update()
	end
	if ui then
		ui:setVisible(false)
		
	end
end

function toggle()
	if isHided() then
		initUI()
	else
		hideUI()
	end
end

function initUI()
	if ui then
		uiLayer:removeChild(ui)
		uiLayer:addChild(ui)
		ui:updateParent()
		ui:setVisible(true)
		
		return
	end
	ui = F3DLayout:new()
	uiLayer:addChild(ui)
	ui:setLoadPriority(getUIPriority())
	ui:addEventListener(F3DObjEvent.OBJ_INITED, func_e(onUIInit))
	ITEMCOUNT = g_mobileMode and 36 or 40
	if ui.setUIPack and USEUIPACK then
		ui:setUIPack(g_mobileMode and UIPATH.."装备分解UIm.pack" or UIPATH.."装备分解UI.pack")
	else
		ui:setLayout(g_mobileMode and UIPATH.."装备分解UIm.layout" or UIPATH.."装备分解UI.layout")
	end
	ui:setVisible(true)
end
