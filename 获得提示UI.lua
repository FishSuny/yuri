module(..., package.seeall)

local 全局设置 = require("公用.全局设置")
local 消息 = require("网络.消息")
local 实用工具 = require("公用.实用工具")

m_init = false
m_strs = {}
m_itempool = {}
m_items = {}

function popItem()
	if #m_itempool > 0 then
		local cb = m_itempool[#m_itempool]
		table.remove(m_itempool, #m_itempool)
		return cb
	end
end

function pushItem(cb)
	cb.rtf:setTitleText("")
	m_items[cb] = nil
	m_itempool[#m_itempool+1] = cb
end

function addTips(str)
	if #m_strs >= 20 then
		table.remove(m_strs, 1)
		if m_init then
pushItem(ui.list:getItem(0))
			ui.list:removeItem(nil, 0)
		end
	end
	m_strs[#m_strs+1] = str
	update(str)
end

function update(str)
	if not m_init then
		return
	end
	ui.list:getVScroll():setPercent(1)
	if str == nil then
		for i,v in ipairs(m_strs) do
			addStr(v)
		end
	else
		addStr(str)
	end
end

function addStr(str)
	local cb = popItem() or F3DCheckBox:new()
	if not cb.rtf then
		cb.rtf = F3DRichTextField:new()
		cb:addChild(cb.rtf)
	end
	cb:setHeight((#实用工具.SplitString(str, "#n", true))*(g_mobileMode and 18 or 14)+2)
	cb.rtf:setTitleText((g_mobileMode and "#s16," or "")..str)
	ui.list:addItem(cb)
	m_items[cb] = 1
end

function onUIInit()
	ui.list = tt(ui:findComponent("list"),F3DList)
	ui.bg = ui:findComponent("bg")
	ui.bg:setVisible(false)
	ui.list:getVScroll():setVisible(false)
	ui.list:addEventListener(F3DUIEvent.MOUSE_OVER, func_ue(function (e)
		ui.bg:setVisible(true)
		ui.list:getVScroll():setVisible(true)
	end))
	ui.list:addEventListener(F3DUIEvent.MOUSE_OUT, func_ue(function (e)
		ui.bg:setVisible(false)
		ui.list:getVScroll():setVisible(false)
	end))
	m_init = true
	update()
end

function isHided()
return not ui or not ui:isVisible()or ui.tweenhide
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
ui:setUIPack(g_mobileMode and UIPATH.."获得提示UIm.pack"or ISMIRUI and UIPATH.."获得提示UI.pack"or UIPATH.."获得提示UIs.pack")
else
	ui:setLayout(g_mobileMode and UIPATH.."获得提示UIm.layout" or ISMIRUI and UIPATH.."获得提示UI.layout" or UIPATH.."获得提示UIs.layout")
end
end
