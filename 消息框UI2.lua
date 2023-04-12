module(..., package.seeall)

local 全局设置 = require("公用.全局设置")
local 消息 = require("网络.消息")

function onClose(e)

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

m_init = false
m_titlepicindex = 0
m_countnum = 0
m_countnummax = 0
m_okfunc = nil

titlepictb = {
	UIPATH.."公用/img_tipsTitle.png",--提示
	UIPATH.."公用/img_title_useItem.png",--使用
	UIPATH.."公用/img_title_spItem.png",--拆分
	UIPATH.."公用/img_title_itemsell.png",--寄售
	UIPATH.."公用/img_title_buy.png",--购买
}

function setData(index, num, nummax, func)
	m_titlepicindex = index
	m_countnum = num
	m_countnummax = nummax
	m_okfunc = func
	update()
end

function update()
	if not m_init or m_titlepicindex == 0 then
		return
	end
	ui.title:setBackground(titlepictb[m_titlepicindex])
	ui.count:setTitleText(m_countnum)
end

function onOK(e)

_v_62(ui,false)
	ui.ok:releaseMouse()
	e:stopPropagation()
	if m_okfunc then
		m_countnum = tonumber(ui.count:getTitleText())
		m_okfunc(m_countnum)
		m_okfunc = nil
	end
end

function onCancel(e)

_v_62(ui,false)
ui.cancel:releaseMouse()
e:stopPropagation()
end

function onDec(e)
	m_countnum = tonumber(ui.count:getTitleText())
	m_countnum = math.max(1, m_countnum - 1)
	ui.count:setTitleText(m_countnum)
	e:stopPropagation()
end

function onAdd(e)
	m_countnum = tonumber(ui.count:getTitleText())
	m_countnum = math.min(m_countnummax, m_countnum + 1)
	ui.count:setTitleText(m_countnum)
	e:stopPropagation()
end

function onMax(e)
	ui.count:setTitleText(m_countnummax)
	e:stopPropagation()
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
	ui.dec = ui:findComponent("dec")
	ui.dec:addEventListener(F3DMouseEvent.CLICK, func_me(onDec))
	ui.add = ui:findComponent("add")
	ui.add:addEventListener(F3DMouseEvent.CLICK, func_me(onAdd))
	ui.max = ui:findComponent("max")
	ui.max:addEventListener(F3DMouseEvent.CLICK, func_me(onMax))
	m_init = true
	update()
end

function isHided()
	return not ui or not ui:isVisible() or ui.tweenhide
end

function hideUI()
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
		ui:setUIPack(g_mobileMode and UIPATH.."消息框UI2m.pack" or UIPATH.."消息框UI2.pack")
	else
		ui:setLayout(g_mobileMode and UIPATH.."消息框UI2m.layout" or UIPATH.."消息框UI2.layout")
	end
_v_62(ui,true)
end
