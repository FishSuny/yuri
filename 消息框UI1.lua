module(..., package.seeall)

local 全局设置 = require("公用.全局设置")
local 消息 = require("网络.消息")

function onClose(e)
	ui:setVisible(false)
	
	ui:releaseMouse()
	ui.close:releaseMouse()
	e:stopPropagation()
	if m_closefunc then
		m_closefunc()
	end
	m_okfunc = nil
	m_cancelfunc = nil
	m_closefunc = nil
end

function onMouseDown(e)
	uiLayer:removeChild(ui)
	uiLayer:addChild(ui)
	e:stopPropagation()
end

m_init = false
m_text = ""
m_okfunc = nil
m_cancelfunc = nil
m_closefunc = nil
m_inputdata = nil
m_hidebutton = nil
m_repeatanim = nil

function setData(text, okfunc, cancelfunc, closefunc, inputdata, hidebutton)
	m_text = text
	m_okfunc = okfunc
	m_cancelfunc = cancelfunc
	m_closefunc = closefunc
	m_inputdata = inputdata
	m_hidebutton = hidebutton
	update()
end

function update()
	if not m_init or m_text == "" then
		return
	end
	ui.text:setTitleText(m_text)
	ui.input:setVisible(m_inputdata == true or type(m_inputdata)=="string")
	ui.input:setTitleText(type(m_inputdata)=="string" and m_inputdata or "")
	ui.combo:setVisible(type(m_inputdata) == "table")
	ui.combo:getList():removeAllItems()
	if type(m_inputdata) == "table" then
		for i,v in ipairs(m_inputdata) do
			local cb = F3DCheckBox:new()
			if g_mobileMode then
				cb:setTitleFont("宋体,16")
				cb:setHeight(28)
			else
				cb:setHeight(20)
			end
			cb:setTitleText(v)
			cb:setTitleArea("2,0,0,0")
			ui.combo:getList():addItem(cb)
		end
		ui.combo:setTitleText(m_inputdata[1] or "")
	end
	ui.ok:setVisible(not m_hidebutton)
	ui.cancel:setVisible(not m_hidebutton)
end

function onOK(e)
	ui:setVisible(false)
	
	ui.ok:releaseMouse()
	e:stopPropagation()
	if m_okfunc then
		m_okfunc(type(m_inputdata) == "table" and ui.combo:getTitleText() or
			(m_inputdata and not ui.input:isDefault()) and ui.input:getTitleText() or nil)
	end
	m_okfunc = nil
	m_cancelfunc = nil
	m_closefunc = nil
end

function onCancel(e)
	ui:setVisible(false)
	
	ui.cancel:releaseMouse()
	e:stopPropagation()
	if m_cancelfunc then
		m_cancelfunc()
	end
	m_okfunc = nil
	m_cancelfunc = nil
	m_closefunc = nil
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
	ui.text = ui:findComponent("text")
	ui.input = tt(ui:findComponent("input"),F3DTextInput)
	ui.combo = tt(ui:findComponent("combo"),F3DCombo)
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
		ui:setUIPack(g_mobileMode and UIPATH.."消息框UI1m.pack" or UIPATH.."消息框UI1.pack")
	else
		ui:setLayout(g_mobileMode and UIPATH.."消息框UI1m.layout" or UIPATH.."消息框UI1.layout")
	end
	ui:setVisible(true)
end
