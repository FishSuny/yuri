module(..., package.seeall)

local 全局设置 = require("公用.全局设置")
local 消息 = require("网络.消息")

m_init = false
m_scene = nil
m_finishfunc = nil
m_anim = nil

function onHeartBeat()
	ui.pro:setPercent(m_scene:getScenePercent())
	if m_scene:getScenePercent() > 0.95 then
		ui.pro:setPercent(0)
		hideUI()
		F3DScheduler:instance():removeAnimatable(m_anim)
		if m_finishfunc then
			m_finishfunc()
			m_finishfunc = nil
		end
		m_scene = nil
		m_anim = nil
	end
end

function update()
	if not m_init or not m_scene then
		return
	end
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
ui:setUIPack(UIPATH.."加载UI.pack")
else
	ui:setLayout(UIPATH.."加载UI.layout")
end
end

function loadScene(scene, finishfunc)
	m_scene = scene
	m_finishfunc = finishfunc
	initUI()
	update()
end
