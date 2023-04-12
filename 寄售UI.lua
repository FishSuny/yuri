module(..., package.seeall)

local 全局设置 = require("公用.全局设置")
local 消息 = require("网络.消息")
local 角色逻辑 = require("主界面.角色逻辑")
local 地图表 = require("配置.地图表")
local 物品提示UI = require("主界面.物品提示UI")
local 装备提示UI = require("主界面.装备提示UI")
local 装备对比提示UI = require("主界面.装备对比提示UI")
local 宠物蛋提示UI = require("主界面.宠物蛋提示UI")
local 背包UI = require("主界面.背包UI")
local 角色UI = require("主界面.角色UI")
local 游戏设置=require("公用.游戏设置")

m_init = false
m_info = nil
m_recordinfo = nil
m_curtype = 1
m_tabid = 0
m_selectitem = nil
m_itemdata = nil
m_itemsellid = nil
tipsui = nil
tipsgrid = nil
m_pool1 = {}
m_poolindex1 = 1
m_pool2 = {}
m_poolindex2 = 1

function setInfo(info)
	m_info = info
	update()
end

function setRecordInfo(info)
	m_recordinfo = info
	updateRecord()
end

function setItemData(id,itemdata)
	m_itemsellid = id
	local v = itemdata[1]
	m_itemdata = {
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
	if tipsui and tipsgrid then
		if m_itemdata.type == 3 and m_itemdata.equippos == 14 then
			宠物蛋提示UI.setItemData(m_itemdata, false)

		elseif m_itemdata.type == 3 then
			local equippos = 背包UI.GetEquipPos(m_itemdata, 角色UI.m_tabid == 1)
			local itemdata = 角色UI.m_tabid == 1 and 角色UI.英雄物品数据 or 角色UI.m_itemdata
			if itemdata and itemdata[equippos] and
				itemdata[equippos].id ~= 0 and
				itemdata[equippos].count > 0 then
				装备对比提示UI.initUI()
				装备对比提示UI.setItemData(itemdata[equippos], true)
			else
				装备对比提示UI.hideUI()
			end
			装备提示UI.setItemData(m_itemdata, false)
			checkTipsPos()
		else
			物品提示UI.setItemData(m_itemdata)
		end
	end
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
		if not 装备对比提示UI.isHided() and x + tipsui:getWidth() + 装备对比提示UI.ui:getWidth() > stage:getWidth() then
tipsui:setPositionX(math.max(装备对比提示UI.ui:getWidth(),x-tipsui:getWidth()-tipsgrid:getWidth()))
			if not 装备对比提示UI.isHided() then
装备对比提示UI.ui:setPositionX(math.max(0,x-tipsui:getWidth()-tipsgrid:getWidth()-tipsui:getWidth()))
			end
		elseif 装备对比提示UI.isHided() and x + tipsui:getWidth() > stage:getWidth() then
			tipsui:setPositionX(x - tipsui:getWidth() - tipsgrid:getWidth())
			if not 装备对比提示UI.isHided() then
				装备对比提示UI.ui:setPositionX(x - tipsui:getWidth() - tipsgrid:getWidth()-tipsui:getWidth())
end
elseif not 装备对比提示UI.isHided()then
tipsui:setPositionX(math.min(stage:getWidth()-装备对比提示UI.ui:getWidth()-tipsui:getWidth(),x))
if not 装备对比提示UI.isHided()then
装备对比提示UI.ui:setPositionX(math.min(stage:getWidth()-装备对比提示UI.ui:getWidth(),x+tipsui:getWidth()))
			end
		else
			tipsui:setPositionX(x)
			if not 装备对比提示UI.isHided() then
				装备对比提示UI.ui:setPositionX(x+tipsui:getWidth())
			end
		end
		if y + tipsui:getHeight() > stage:getHeight() then
			tipsui:setPositionY(stage:getHeight() - tipsui:getHeight())
		else
			tipsui:setPositionY(y)
end
			if not 装备对比提示UI.isHided() then
if y+装备对比提示UI.ui:getHeight()>stage:getHeight()then
装备对比提示UI.ui:setPositionY(stage:getHeight()-装备对比提示UI.ui:getHeight())
else
				装备对比提示UI.ui:setPositionY(y)
			end
		end
	end
end

function onGridOver(e)
	if ui.tweenhide then return end
	local g = g_mobileMode and e:getCurrentTarget() or e:getTarget()
	if g == nil or not g.id then
	elseif F3DUIManager.sTouchComp ~= g then
	elseif getSellItemType(g.id) == 1 then
		装备提示UI.hideUI()
		装备对比提示UI.hideUI()
		宠物蛋提示UI.hideUI()
		物品提示UI.initUI()
		if not m_itemdata or m_itemsellid ~= g.id then
			消息.CG_SELL_ITEM_QUERY(g.id)
			物品提示UI.setEmptyItemData()
		else
			物品提示UI.setItemData(m_itemdata)
		end
		tipsui = 物品提示UI.ui
		tipsgrid = g
		if not tipsui:isInited() then
			tipsui:addEventListener(F3DObjEvent.OBJ_INITED, func_oe(checkTipsPos))
		else
			checkTipsPos()
		end
	elseif getSellItemType(g.id) == 2 then
		装备提示UI.hideUI()
		装备对比提示UI.hideUI()
		物品提示UI.hideUI()
		宠物蛋提示UI.initUI()
		if not m_itemdata or m_itemsellid ~= g.id then
			消息.CG_SELL_ITEM_QUERY(g.id)
			宠物蛋提示UI.setEmptyItemData()
		else
			宠物蛋提示UI.setItemData(m_itemdata)
		end
		tipsui = 宠物蛋提示UI.ui
		tipsgrid = g
		if not tipsui:isInited() then
			tipsui:addEventListener(F3DObjEvent.OBJ_INITED, func_oe(checkTipsPos))
		else
			checkTipsPos()
		end
	else
		物品提示UI.hideUI()
		宠物蛋提示UI.hideUI()
		装备提示UI.initUI()
		if not m_itemdata or m_itemsellid ~= g.id then
			消息.CG_SELL_ITEM_QUERY(g.id)
			装备提示UI.setEmptyItemData()
			装备对比提示UI.hideUI()
		else
			local equippos = 背包UI.GetEquipPos(m_itemdata, 角色UI.m_tabid == 1)
			local itemdata = 角色UI.m_tabid == 1 and 角色UI.英雄物品数据 or 角色UI.m_itemdata
			if itemdata and itemdata[equippos] and
				itemdata[equippos].id ~= 0 and
				itemdata[equippos].count > 0 then
				装备对比提示UI.initUI()
				装备对比提示UI.setItemData(itemdata[equippos], true)
			else
				装备对比提示UI.hideUI()
			end
			装备提示UI.setItemData(m_itemdata, false)
		end
		tipsui = 装备提示UI.ui
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
		物品提示UI.hideUI()
		装备提示UI.hideUI()
		装备对比提示UI.hideUI()
		宠物蛋提示UI.hideUI()
		tipsui = nil
		tipsgrid = nil
	end
end

function _v_1487(_v_1488)
if _v_1488==0 then
return"元宝"
elseif _v_1488==1 then
return"RMB点"
elseif _v_1488==2 then
return"金币"
elseif _v_1488==3 then
return"绑定金币"
elseif _v_1488==10 then
return"充值积分"
elseif _v_1488==11 then
return"金刚石"
elseif _v_1488==12 then
return"荣誉值"
elseif _v_1488==13 then
return"声望值"
elseif _v_1488==14 then
return"灵符数"
elseif _v_1488==15 then
return"泡点数"
else
return""
end
end

function updateRecord()
	if not m_init or not m_recordinfo then
		return
	end
	ui.list:removeAllItems()
	m_poolindex2 = 1
	for i,v in ipairs(m_recordinfo) do
		local cb = nil
		if #m_pool2 >= m_poolindex2 then
			cb = m_pool2[m_poolindex2]
			m_poolindex2 = m_poolindex2 + 1
		else
			cb = F3DCheckBox:new()
			m_pool2[m_poolindex2] = cb
			m_poolindex2 = m_poolindex2 + 1
			cb.rtf = F3DRichTextField:new()
			cb:addChild(cb.rtf)
			if g_mobileMode then
				cb.rtf:setTitleFont("宋体,16")
				cb:setHeight(18+2)
			else
				cb:setHeight(14+2)
			end
		end
		local seller = v[1]==角色逻辑.m_rolename and txt("你") or txt(v[1])
		local buyer = v[2]==角色逻辑.m_rolename and txt("你") or txt(v[2])
		cb.rtf:setTitleText("#cffff00,"..buyer..txt("#C在#cffff00,")..v[4]..txt("#C购买了#cffff00,")..seller..
			txt("#C的#cffff00,")..txt(v[3])..
			(v[1]==角色逻辑.m_rolename and txt("#C,获得了#cffff00,") or txt("#C,失去了#cffff00,"))..
v[6]..txt(_v_1487(v[5])))
		ui.list:addItem(cb)
	end
end

function update()
	if not m_init or not m_info then
		return
	end
	ui.list:removeAllItems()
	m_poolindex1 = 1
	for i,v in ipairs(m_info) do
		local item = nil
		if #m_pool1 >= m_poolindex1 then
			item = m_pool1[m_poolindex1]
			m_poolindex1 = m_poolindex1 + 1
			item.grid.id = v[1]
			item.img:setTextureFile(全局设置.getItemIconUrl(v[2]))
			item.grade:setTextureFile(全局设置.getGradeUrl(v[3]))
			item.count:setText(v[4] > 1 and v[4] or "")
			if v[4] < 0 then
				if not item.effect then
					item.effect = F3DImageAnim:new()
					item.effect:setBlendType(F3DRenderContext.BLEND_ADD)
					item.effect:setPositionX(item.grid:getWidth()/2)
					item.effect:setPositionY(item.grid:getHeight()/2)
					item.grid:addChild(item.effect)
				end
				item.effect:setAnimPack(全局设置.getAnimPackUrl(-v[4]))
			elseif item.effect then
				item.effect:reset()
			end
			item.buy.id = v[1]
		else
			item = tt(ui.checkbox:clone(),F3DCheckBox)
			m_pool1[m_poolindex1] = item
			m_poolindex1 = m_poolindex1 + 1
			item.grid = item:findComponent("物品")
			item.grid.id = v[1]
item.effect=nil
			if g_mobileMode then
				item.grid:addEventListener(F3DMouseEvent.CLICK, func_me(onGridOver))
			else
				item.grid:addEventListener(F3DUIEvent.MOUSE_OVER, func_ue(onGridOver))
				item.grid:addEventListener(F3DUIEvent.MOUSE_OUT, func_ue(onGridOut))
			end
			item.img = F3DImage:new()
			item.img:setPositionX(math.floor(item.grid:getWidth()/2))
			item.img:setPositionY(math.floor(item.grid:getHeight()/2))
			item.img:setPivot(0.5,0.5)
			item.img:setTextureFile(全局设置.getItemIconUrl(v[2]))
			item.grid:addChild(item.img)
			item.grade = F3DImage:new()
			item.grade:setPositionX(1)
			item.grade:setPositionY(1)
item.grade:setWidth(item.grid:getWidth()-2)
item.grade:setHeight(item.grid:getWidth()-2)
			item.grade:setTextureFile(全局设置.getGradeUrl(v[3]))
			item.grid:addChild(item.grade)
			item.count = F3DTextField:new()
			item.count:setPositionX(36)
			item.count:setPositionY(36)
			item.count:setPivot(1,1)
			item.count:setText(v[4] > 1 and v[4] or "")
			item.grid:addChild(item.count)
			if v[4] < 0 then
				if not item.effect then
					item.effect = F3DImageAnim:new()
					item.effect:setBlendType(F3DRenderContext.BLEND_ADD)
					item.effect:setPositionX(item.grid:getWidth()/2)
					item.effect:setPositionY(item.grid:getHeight()/2)
					item.grid:addChild(item.effect)
				end
				item.effect:setAnimPack(全局设置.getAnimPackUrl(-v[4]))
			elseif item.effect then
				item.effect:reset()
			end
			item.buy = item:findComponent("购买")
			item.buy.id = v[1]
			item.buy:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
				local g = e:getCurrentTarget()
				if m_tabid==0 then
					消息.CG_SELL_ITEM_BUY(g.id)
				else
					消息.CG_SELL_ITEM_OFF(g.id)
				end
			end))
		end
		item:findComponent("名字"):setTitleText(txt(v[5]))
		item:findComponent("职业"):setTitleText(txt(全局设置.获取职业类型(v[6])))
		if v[7] < 0 then
			item:findComponent("等级"):setTitleText(txt((-v[7]).."转"))
		else
			item:findComponent("等级"):setTitleText(v[7])
		end
		if v[8] == 0 then
			item:findComponent("期限"):setTitleText(txt("已过期"))
		else
			local 时 = math.floor(v[8]/60)
			local 分 = math.floor(v[8]%60)
			item:findComponent("期限"):setTitleText(string.format("%02d:%02d",时,分))
		end
local type=游戏设置.Consignment--v[9]==0 and 2 or v[9]==1 and 0 or v[9]==4 and 3 or 1
item:findComponent("价格图标"):setBackground(全局设置.MONEYICON[type]or"")
		item:findComponent("价格"):setTitleText(v[10])
		item.buy:setTitleText(m_tabid==0 and txt("购买") or v[8] == 0 and txt("取回") or txt("下架"))
		ui.list:addItem(item)
	end
end

function getSellItemType(id)
	for i,v in ipairs(m_info) do
		if v[1] == id then
			return v[11]
		end
	end
	return 0
end

function onTabChange(e)
	m_tabid = ui.tab:getSelectIndex()
	if g_mobileMode then
		ui.材料:setDisable(m_tabid ~= 0)
		ui.消耗品:setDisable(m_tabid ~= 0)
		ui.装备（武器）:setDisable(m_tabid ~= 0)
		ui.装备（衣服）:setDisable(m_tabid ~= 0)
		ui.装备（头盔）:setDisable(m_tabid ~= 0)
		ui.装备（项链）:setDisable(m_tabid ~= 0)
		ui.装备（护腕）:setDisable(m_tabid ~= 0)
		ui.装备（戒指）:setDisable(m_tabid ~= 0)
		ui.装备（腰带）:setDisable(m_tabid ~= 0)
		ui.装备（靴子）:setDisable(m_tabid ~= 0)
	end
	if ui.当前状态 then
		ui.当前状态:setDisable(m_tabid ~= 0)
	end
	if m_tabid == 0 then
		setCurType(m_curtype)
	elseif m_tabid == 1 then
		消息.CG_SELL_MINE_QUERY()
	else
		消息.CG_SELL_RECORD_QUERY()
	end
	update()
end

function onClose(e)
	if tipsui then
		物品提示UI.hideUI()
		装备提示UI.hideUI()
		装备对比提示UI.hideUI()
		宠物蛋提示UI.hideUI()
		tipsui = nil
		tipsgrid = nil
	end
_v_62(ui,false)
ui:releaseMouse()
	
	ui.close:releaseMouse()
	e:stopPropagation()
end

function onMouseDown(e)
	uiLayer:removeChild(ui)
	uiLayer:addChild(ui)
	e:stopPropagation()
end

function setCurType(type)
	if m_tabid ~= 0 then
		return
	end
	m_curtype = type
	if type == 1 then
		消息.CG_SELL_QUERY(1)
	elseif type == 2 then
		消息.CG_SELL_QUERY(2)
	elseif type == 3 then
		消息.CG_SELL_QUERY(3)
	elseif type == 4 then
		消息.CG_SELL_QUERY(4)
	elseif type == 5 then
		消息.CG_SELL_QUERY(5)
	elseif type == 6 then
		消息.CG_SELL_QUERY(6)
	elseif type == 7 then
		消息.CG_SELL_QUERY(7)
	elseif type == 8 then
		消息.CG_SELL_QUERY(8)
	elseif type == 9 then
		消息.CG_SELL_QUERY(9)
	elseif type == 10 then
		消息.CG_SELL_QUERY(10)
	end
	if ui.当前状态 then
		if type == 1 then
			ui.当前状态:setPositionX(ui.材料:getPositionX()+2)
			ui.当前状态:setPositionY(ui.材料:getPositionY()+1)
		elseif type == 2 then
			ui.当前状态:setPositionX(ui.消耗品:getPositionX()+2)
			ui.当前状态:setPositionY(ui.消耗品:getPositionY()+1)
		elseif type == 3 then
			ui.当前状态:setPositionX(ui.装备（武器）:getPositionX()+2)
			ui.当前状态:setPositionY(ui.装备（武器）:getPositionY()+1)
		elseif type == 4 then
			ui.当前状态:setPositionX(ui.装备（衣服）:getPositionX()+2)
			ui.当前状态:setPositionY(ui.装备（衣服）:getPositionY()+1)
		elseif type == 5 then
			ui.当前状态:setPositionX(ui.装备（头盔）:getPositionX()+2)
			ui.当前状态:setPositionY(ui.装备（头盔）:getPositionY()+1)
		elseif type == 6 then
			ui.当前状态:setPositionX(ui.装备（项链）:getPositionX()+2)
			ui.当前状态:setPositionY(ui.装备（项链）:getPositionY()+1)
		elseif type == 7 then
			ui.当前状态:setPositionX(ui.装备（护腕）:getPositionX()+2)
			ui.当前状态:setPositionY(ui.装备（护腕）:getPositionY()+1)
		elseif type == 8 then
			ui.当前状态:setPositionX(ui.装备（戒指）:getPositionX()+2)
			ui.当前状态:setPositionY(ui.装备（戒指）:getPositionY()+1)
		elseif type == 9 then
			ui.当前状态:setPositionX(ui.装备（腰带）:getPositionX()+2)
			ui.当前状态:setPositionY(ui.装备（腰带）:getPositionY()+1)
		elseif type == 10 then
			ui.当前状态:setPositionX(ui.装备（靴子）:getPositionX()+2)
			ui.当前状态:setPositionY(ui.装备（靴子）:getPositionY()+1)
		end
	end
end

function onUIInit()
	ui.close = ui:findComponent("titlebar,close")
	ui.close:addEventListener(F3DMouseEvent.CLICK, func_me(onClose))
	ui:addEventListener(F3DMouseEvent.MOUSE_DOWN, func_me(onMouseDown))
	ui.list = tt(ui:findComponent("list_1"),F3DList)
	ui.list:getVScroll():setPercent(0)
	ui.checkbox = ui:findComponent("checkbox_3")
	ui.checkbox:setVisible(false)
	ui.材料 = tt(ui:findComponent("checkbox_1"),F3DCheckBox)
	ui.材料:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
		setCurType(1)
	end))
	ui.消耗品 = tt(ui:findComponent("checkbox_2"),F3DCheckBox)
	ui.消耗品:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
		setCurType(2)
	end))
	ui.装备（武器） = tt(ui:findComponent("checkbox_5"),F3DCheckBox)
	ui.装备（武器）:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
		setCurType(3)
	end))
	ui.装备（衣服） = tt(ui:findComponent("checkbox_6"),F3DCheckBox)
	ui.装备（衣服）:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
		setCurType(4)
	end))
	ui.装备（头盔） = tt(ui:findComponent("checkbox_7"),F3DCheckBox)
	ui.装备（头盔）:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
		setCurType(5)
	end))
	ui.装备（项链） = tt(ui:findComponent("checkbox_8"),F3DCheckBox)
	ui.装备（项链）:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
		setCurType(6)
	end))
	ui.装备（护腕） = tt(ui:findComponent("checkbox_9"),F3DCheckBox)
	ui.装备（护腕）:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
		setCurType(7)
	end))
	ui.装备（戒指） = tt(ui:findComponent("checkbox_10"),F3DCheckBox)
	ui.装备（戒指）:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
		setCurType(8)
	end))
	ui.装备（腰带） = tt(ui:findComponent("checkbox_11"),F3DCheckBox)
	ui.装备（腰带）:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
		setCurType(9)
	end))
	ui.装备（靴子） = tt(ui:findComponent("checkbox_12"),F3DCheckBox)
	ui.装备（靴子）:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
		setCurType(10)
	end))
	if g_mobileMode then
		ui.材料:setGroupSelected()
	end
	ui.当前状态 = ui:findComponent("当前状态")
	ui.tab = tt(ui:findComponent("tab_1"), F3DTab)
	ui.tab:addEventListener(F3DUIEvent.CHANGE, func_me(onTabChange))
	setCurType(m_curtype)
	m_init = true
	update()
end

function isHided()
	return not ui or not ui:isVisible() or ui.tweenhide
end

function hideUI()
	if tipsui then
		物品提示UI.hideUI()
		装备提示UI.hideUI()
		装备对比提示UI.hideUI()
		宠物蛋提示UI.hideUI()
		tipsui = nil
		tipsgrid = nil
	end
	if ui then

_v_62(ui,false)
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
_v_62(ui,true)
		return
	end
	ui = F3DLayout:new()
	uiLayer:addChild(ui)
	ui:setLoadPriority(getUIPriority())
	ui:setMovable(true)
	ui:addEventListener(F3DObjEvent.OBJ_INITED, func_e(onUIInit))
if ui.setUIPack and USEUIPACK then
ui:setUIPack(g_mobileMode and UIPATH.."寄售UIm.pack"or UIPATH.."寄售UI.pack")
else
	ui:setLayout(g_mobileMode and UIPATH.."寄售UIm.layout" or UIPATH.."寄售UI.layout")
end
_v_62(ui,true)
end
