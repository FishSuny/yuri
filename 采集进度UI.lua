module(..., package.seeall)

local 全局设置 = require("公用.全局设置")
local 消息 = require("网络.消息")

m_init = false
m_finishfunc = nil
m_anim = nil
m_msgtxt = "正在执行中..."
m_sectime = 5
m_heartcnt = 0

function stop()
	if not m_init or isHided() then
		return
	end
	ui.pro:setPercent(1)
end

function start(finishfunc)
	m_finishfunc = finishfunc
	initUI()
	update()
end

function onHeartBeat()
	if ui.pro:getPercent() == 1 then
		ui.pro:setPercent(0)
		hideUI()
		F3DScheduler:instance():removeAnimatable(m_anim)
		if m_finishfunc then
			m_finishfunc()
			m_finishfunc = nil
		end
		m_anim = nil
	end
end

function updateTxt()
	if not m_init then
		return
	end
	ui.pro:setTitleText(txt(m_msgtxt:gsub("%%d%%",m_sectime)))
end

function update()
	if not m_init then
		return
	end
	ui.pro:setTitleText(txt(m_msgtxt:gsub("%%d%%",m_sectime)))
	ui.pro:setCurrVal(0)
	ui.pro:setMaxVal(100)
	ui.pro:doAnim(100, m_sectime)
	if not m_anim then
		m_anim = F3DScheduler:instance():repeatCall(func_n(onHeartBeat), 100)
	end
end

function onUIInit()
	ui.pro = tt(ui:findComponent("pro"),F3DProgress)
	ui.pro:setPercent(0)
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
	ui:addEventListener(F3DObjEvent.OBJ_INITED, func_e(onUIInit))
	if ui.setUIPack and USEUIPACK then
		ui:setUIPack(g_mobileMode and UIPATH.."采集进度UIm.pack" or UIPATH.."采集进度UI.pack")
	else
		ui:setLayout(g_mobileMode and UIPATH.."采集进度UIm.layout" or UIPATH.."采集进度UI.layout")
	end
end
