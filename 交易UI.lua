module(..., package.seeall)

local 全局设置 = require("公用.全局设置")
local 游戏设置 = require("公用.游戏设置")
local 消息 = require("网络.消息")
local 背包UI = require("主界面.背包UI")
local 物品提示UI = require("主界面.物品提示UI")
local 装备提示UI = require("主界面.装备提示UI")
local 角色逻辑 = require("主界面.角色逻辑")
local 消息框UI1 = require("主界面.消息框UI1")
local 主界面UI=require("主界面.主界面UI")

m_init = false
m_selectitem = nil
m_iteminfo = {}
m_othiteminfo = {}
m_money = 0
m_rmb = 0
m_othmoney = 0
m_othrmb = 0
m_confirm = false
m_othconfirm = false
m_objid = -1
tipsui = nil
tipsgrid = nil

function initEmpty()
	m_iteminfo = {}
	m_othiteminfo = {}
	m_money = 0
	m_rmb = 0
	m_othmoney = 0
	m_othrmb = 0
	m_confirm = false
	m_othconfirm = false
	m_objid = -1
	update()
end

function onConfirm(type)
	if type == 1 then
		m_confirm = true
	else
		m_othconfirm = true
	end
	update()
end

function addItemInfo(type, itemdata, money, rmb)
	if #itemdata > 0 then
		v = itemdata[1]
		local iteminfo = type == 1 and m_iteminfo or m_othiteminfo
		iteminfo[#iteminfo+1] = {
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
	if type == 1 then
		m_money = money
		m_rmb = rmb
	else
		m_othmoney = money
		m_othrmb = rmb
	end
	update()
end

function update()
	if not m_init then
		return
	end
	for i=1,24 do
		local v = m_iteminfo[i]
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
	ui.input1:setTitleText(m_money)
	ui.input2:setTitleText(m_rmb)
	for i=1,24 do
		local v = m_othiteminfo[i]
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
				if not ui.othitems[i].effect then
					ui.othitems[i].effect = F3DImageAnim:new()
					ui.othitems[i].effect:setBlendType(F3DRenderContext.BLEND_ADD)
					ui.othitems[i].effect:setPositionX(ui.othitems[i].grid:getWidth()/2)
					ui.othitems[i].effect:setPositionY(ui.othitems[i].grid:getHeight()/2)
					ui.othitems[i].grid:addChild(ui.othitems[i].effect)
				end
				ui.othitems[i].effect:setAnimPack(全局设置.getAnimPackUrl(发光特效))
			elseif ui.othitems[i].effect then
				ui.othitems[i].effect:reset()
			end
			ui.othitems[i].icon:setTextureFile(全局设置.getItemIconUrl(v.icon))
			ui.othitems[i].grade:setTextureFile(全局设置.getGradeUrl(v.grade))
			ui.othitems[i].lock:setTextureFile(v.bind == 1 and UIPATH.."公用/grid/img_bind.png" or "")
			ui.othitems[i].count:setText(v.count > 1 and v.count or "")
			ui.othitems[i].strengthen:setText(v.strengthen > 0 and "+"..v.strengthen or "")
			if v.cd > rtime() and v.cdmax > 0 then
				local frameid = math.floor((1 - (v.cd - rtime()) / v.cdmax) * 32)
				ui.othitems[i].cd:setVisible(true)
				ui.othitems[i].cd:setFrameRate(1000*(32-frameid)/(v.cd - rtime()), frameid)
			else
				ui.othitems[i].cd:setFrameRate(0)
				ui.othitems[i].cd:setVisible(false)
			end
		else
			if ui.othitems[i].effect then
				ui.othitems[i].effect:reset()
			end
			ui.othitems[i].icon:setTextureFile("")
			ui.othitems[i].grade:setTextureFile("")
			ui.othitems[i].lock:setTextureFile("")
			ui.othitems[i].count:setText("")
			ui.othitems[i].strengthen:setText("")
			ui.othitems[i].cd:setFrameRate(0)
			ui.othitems[i].cd:setVisible(false)
		end
	end
	ui.othinput1:setTitleText(m_othmoney)
	ui.othinput2:setTitleText(m_othrmb)
	ui.confirmed1:setVisible(m_confirm)
	ui.confirmed2:setVisible(m_othconfirm)
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
	local gridcont_1 = ui:findComponent("gridcont_1")
	if x >= gridcont_1:getPositionX() and x <= gridcont_1:getPositionX() + gridcont_1:getWidth() and
		y >= gridcont_1:getPositionY() and y <= gridcont_1:getPositionY() + gridcont_1:getHeight() then
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

function onGridOver(e)
	if ui.tweenhide then return end
	local g = g_mobileMode and e:getCurrentTarget() or e:getTarget()
	if g == nil then
	elseif F3DUIManager.sTouchComp ~= g then
	else
		local itemdata
		if g.oth then
			itemdata = m_othiteminfo[g.id]
		else
			itemdata = m_iteminfo[g.id]
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
		消息.CG_DEAL_CANCEL()
		initEmpty()
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

function onMoneyOK(zijin)
	if zijin == nil or zijin == "" then
		主界面UI.showTipsMsg(1, txt("请输入交易金币"))
		return
	end
	if tonumber(zijin) == nil or tonumber(zijin) < 1 then
		主界面UI.showTipsMsg(1, txt("交易金币必须大于0"))
		return
	end
	消息.CG_DEAL_PUTITEM(0, tonumber(zijin), 0)
end

function onRmbOK(zijin)
	if zijin == nil or zijin == "" then
		主界面UI.showTipsMsg(1, txt("请输入交易元宝"))
		return
	end
	if tonumber(zijin) == nil or tonumber(zijin) < 1 then
		主界面UI.showTipsMsg(1, txt("交易元宝必须大于0"))
		return
	end
	消息.CG_DEAL_PUTITEM(0, 0, tonumber(zijin))
end

function onUIInit()
	ui.close = ui:findComponent("titlebar,close")
	ui.close:addEventListener(F3DMouseEvent.CLICK, func_me(onClose))
	ui:addEventListener(F3DMouseEvent.MOUSE_DOWN, func_me(onMouseDown))
	ui.items = {}
	for i=1,24 do
		ui.items[i] = {}
		ui.items[i].grid = ui:findComponent("gridcont,grid_"..(i-1))
		ui.items[i].grid.id = i
ui.items[i].effect=nil
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
	ui.othitems = {}
	for i=1,24 do
		ui.othitems[i] = {}
		ui.othitems[i].grid = ui:findComponent("gridcont_1,grid_"..(i-1))
		ui.othitems[i].grid.id = i
		ui.othitems[i].grid.oth = true
		if g_mobileMode then
			ui.othitems[i].grid:addEventListener(F3DMouseEvent.CLICK, func_me(onGridOver))
		else
			ui.othitems[i].grid:addEventListener(F3DUIEvent.MOUSE_OVER, func_ue(onGridOver))
			ui.othitems[i].grid:addEventListener(F3DUIEvent.MOUSE_OUT, func_ue(onGridOut))
		end
		ui.othitems[i].icon = F3DImage:new()
		ui.othitems[i].icon:setPositionX(math.floor(ui.othitems[i].grid:getWidth()/2))
		ui.othitems[i].icon:setPositionY(math.floor(ui.othitems[i].grid:getHeight()/2))
		ui.othitems[i].icon:setPivot(0.5,0.5)
		ui.othitems[i].grid:addChild(ui.othitems[i].icon)
		ui.othitems[i].grade = F3DImage:new()
		ui.othitems[i].grade:setPositionX(1)
		ui.othitems[i].grade:setPositionY(1)
		ui.othitems[i].grade:setWidth(ui.othitems[i].grid:getWidth()-2)
		ui.othitems[i].grade:setHeight(ui.othitems[i].grid:getHeight()-2)
		ui.othitems[i].grid:addChild(ui.othitems[i].grade)
		ui.othitems[i].lock = F3DImage:new()
		ui.othitems[i].lock:setPositionX(g_mobileMode and 6 or 2)
		ui.othitems[i].lock:setPositionY(ui.othitems[i].grid:getHeight()-(g_mobileMode and 8 or 2))
		ui.othitems[i].lock:setPivot(0,1)
		ui.othitems[i].grid:addChild(ui.othitems[i].lock)
		ui.othitems[i].count = F3DTextField:new()
		if g_mobileMode then
			ui.othitems[i].count:setTextFont("宋体",16,false,false,false)
		end
		ui.othitems[i].count:setPositionX(ui.othitems[i].grid:getWidth()-(g_mobileMode and 8 or 2))
		ui.othitems[i].count:setPositionY(ui.othitems[i].grid:getHeight()-(g_mobileMode and 8 or 2))
		ui.othitems[i].count:setPivot(1,1)
		ui.othitems[i].grid:addChild(ui.othitems[i].count)
		ui.othitems[i].strengthen = F3DTextField:new()
		if g_mobileMode then
			ui.othitems[i].strengthen:setTextFont("宋体",16,false,false,false)
		end
		ui.othitems[i].strengthen:setPositionX(ui.othitems[i].grid:getWidth()-(g_mobileMode and 8 or 2))
		ui.othitems[i].strengthen:setPositionY((g_mobileMode and 8 or 2))
		ui.othitems[i].strengthen:setPivot(1,0)
		ui.othitems[i].grid:addChild(ui.othitems[i].strengthen)
		ui.othitems[i].cd = F3DComponent:new()
		ui.othitems[i].cd:setBackground(UIPATH.."主界面/cd.png")
		ui.othitems[i].cd:setSizeClips("32,1,0,0")
		ui.othitems[i].cd:setTouchable(false)
		ui.othitems[i].cd:setPositionX(2)
		ui.othitems[i].cd:setPositionY(2)
		ui.othitems[i].cd:setWidth(ui.othitems[i].grid:getWidth()-4)
		ui.othitems[i].cd:setHeight(ui.othitems[i].grid:getHeight()-4)
		ui.othitems[i].cd:addEventListener(F3DObjEvent.OBJ_PLAYOUT, func_oe(onCDPlayOut))
		ui.othitems[i].cd:setVisible(false)
		ui.othitems[i].grid:addChild(ui.othitems[i].cd)
	end
	ui.input1 = ui:findComponent("textinput_1")
	ui.input2 = ui:findComponent("textinput_2")
	ui.input1:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
		if not ui.confirmed1:isVisible() then
			消息框UI1.initUI()
			消息框UI1.setData(txt("请输入交易金币(必须大于原值)"),onMoneyOK,nil,nil,true)
		end
	end))
	ui.input2:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
		if not ui.confirmed1:isVisible() then
			消息框UI1.initUI()
			消息框UI1.setData(txt("请输入交易元宝(必须大于原值)"),onRmbOK,nil,nil,true)
		end
	end))
	ui.othinput1 = ui:findComponent("textinput_3")
	ui.othinput2 = ui:findComponent("textinput_4")
	ui.confirmed1 = ui:findComponent("img_confirmed_1")
	ui.confirmed2 = ui:findComponent("img_confirmed_2")
	ui.confirmed1:setVisible(false)
	ui.confirmed2:setVisible(false)
	ui.queren = ui:findComponent("btncont,queren")
	ui.kaishi = ui:findComponent("btncont,kaishi")
	ui.quxiao = ui:findComponent("btncont,quxiao")
	ui.queren:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
		消息.CG_DEAL_CONFIRM()
	end))
	ui.kaishi:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
		消息.CG_DEAL_BEGIN()
	end))
	ui.quxiao:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
		hideUI()
	end))
	m_init = true
	update()
	背包UI.checkResize()
end

function isHided()
	return not ui or not ui:isVisible() or ui.tweenhide
end

function hideUI(nomsg)
	if tipsui then
		物品提示UI.hideUI()
		装备提示UI.hideUI()
		tipsui = nil
		tipsgrid = nil
	end
	if m_init then
		if not nomsg then 消息.CG_DEAL_CANCEL() end
		initEmpty()
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
	if ui.setUIPack and USEUIPACK then
		ui:setUIPack(g_mobileMode and UIPATH.."交易UIm.pack" or UIPATH.."交易UI.pack")
	else
		ui:setLayout(g_mobileMode and UIPATH.."交易UIm.layout" or UIPATH.."交易UI.layout")
	end
	ui:setVisible(true)
end
