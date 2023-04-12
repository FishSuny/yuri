module(..., package.seeall)

local 全局设置 = require("公用.全局设置")
local 游戏设置 = require("公用.游戏设置")
local 消息 = require("网络.消息")

function onClose(e)
	ui:setVisible(false)
	
	ui:releaseMouse()
	ui.close:releaseMouse()
	e:stopPropagation()
end

function onMouseDown(e)
	uiLayer:removeChild(ui)
	uiLayer:addChild(ui)
	e:stopPropagation()
end

m_init = false
m_rmb = 0
m_price = 0
m_okfunc = nil

function setData(rmb, price, func)
	m_rmb = rmb
	m_price = price
	m_okfunc = func
	update()
end

function update()
	if not m_init then
		return
	end
	setMoneyType(m_rmb)
	ui.count:setTitleText(m_price)
end

function onOK(e)
	ui:setVisible(false)
	
	ui.ok:releaseMouse()
	e:stopPropagation()
	if m_okfunc then
		m_price = tonumber(ui.count:getTitleText())
		m_okfunc(m_rmb,m_price)
		m_okfunc = nil
	end
end

function onCancel(e)
	ui:setVisible(false)
	
	ui.cancel:releaseMouse()
	e:stopPropagation()
end

function setMoneyType(rmb)
	m_rmb = rmb
	ui.money_0:setDisable(m_rmb ~= 0)
	ui.money_0:setAlpha(rmb==0 and 1 or 0.5)
	ui.money_2:setDisable(m_rmb ~= 1)
	ui.money_2:setAlpha(rmb==1 and 1 or 0.5)
	if ui.money_1 then
		ui.money_1:setDisable(m_rmb ~= 4)
		ui.money_1:setAlpha(rmb==4 and 1 or 0.5)
	end
	if ui.money_3 then
		ui.money_3:setDisable(m_rmb ~= 5)
		ui.money_3:setAlpha(rmb==5 and 1 or 0.5)
	end
end

function onUIInit()
	ui.close = ui:findComponent("titlebar,close")
	ui.close:addEventListener(F3DMouseEvent.CLICK, func_me(onClose))
	ui:addEventListener(F3DMouseEvent.MOUSE_DOWN, func_me(onMouseDown))
	ui.title = ui:findComponent("titlebar,title")
	ui.ok = ui:findComponent("ok")
	ui.ok:addEventListener(F3DMouseEvent.CLICK, func_me(onOK))
	ui.cancel = ui:findComponent("cancel")
	ui.cancel:addEventListener(F3DMouseEvent.CLICK, func_me(onCancel))
	ui.count = ui:findComponent("count")
	ui.money_0 = ui:findComponent("money_0")
	if 游戏设置.SELLBAGMONEY then
		ui.money_0_ui = F3DComponent:new()
		ui.money_0_ui:setPositionX(ui.money_0:getPositionX())
		ui.money_0_ui:setPositionY(ui.money_0:getPositionY())
		ui.money_0_ui:setWidth(ui.money_0:getWidth())
		ui.money_0_ui:setHeight(ui.money_0:getHeight())
		ui:addChild(ui.money_0_ui)
		ui.money_0_ui:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
			setMoneyType(0)
		end))
	end
	ui.money_2 = ui:findComponent("money_2")
	if 游戏设置.SELLBAGMONEY then
		ui.money_2_ui = F3DComponent:new()
		ui.money_2_ui:setPositionX(ui.money_2:getPositionX())
		ui.money_2_ui:setPositionY(ui.money_2:getPositionY())
		ui.money_2_ui:setWidth(ui.money_2:getWidth())
		ui.money_2_ui:setHeight(ui.money_2:getHeight())
		ui:addChild(ui.money_2_ui)
		ui.money_2_ui:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
			setMoneyType(1)
		end))
	end
	ui.money_1 = ui:findComponent("money_1")
	if ui.money_1 and 游戏设置.SELLBAGMONEY then
		ui.money_1_ui = F3DComponent:new()
		ui.money_1_ui:setPositionX(ui.money_1:getPositionX())
		ui.money_1_ui:setPositionY(ui.money_1:getPositionY())
		ui.money_1_ui:setWidth(ui.money_1:getWidth())
		ui.money_1_ui:setHeight(ui.money_1:getHeight())
		ui:addChild(ui.money_1_ui)
		ui.money_1_ui:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
			setMoneyType(4)
		end))
	end
	ui.money_3 = ui:findComponent("money_3")
	if ui.money_3 and 游戏设置.SELLBAGMONEY then
		ui.money_3_ui = F3DComponent:new()
		ui.money_3_ui:setPositionX(ui.money_3:getPositionX())
		ui.money_3_ui:setPositionY(ui.money_3:getPositionY())
		ui.money_3_ui:setWidth(ui.money_3:getWidth())
		ui.money_3_ui:setHeight(ui.money_3:getHeight())
		ui:addChild(ui.money_3_ui)
		ui.money_3_ui:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
			setMoneyType(5)
		end))
	end
	setMoneyType(1)
	m_init = true
	update()
end

function isHided()
	return not ui or not ui:isVisible() or ui.tweenhide
end

function hideUI()
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
	ui:setMovable(true)
	ui:addEventListener(F3DObjEvent.OBJ_INITED, func_e(onUIInit))
	if ui.setUIPack and USEUIPACK then
		ui:setUIPack(g_mobileMode and UIPATH.."消息框UI3m.pack" or UIPATH.."消息框UI3.pack")
	else
		ui:setLayout(g_mobileMode and UIPATH.."消息框UI3m.layout" or UIPATH.."消息框UI3.layout")
	end
	ui:setVisible(true)
end
