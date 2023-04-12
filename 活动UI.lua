module(..., package.seeall)

local 全局设置 = require("公用.全局设置")
local 消息 = require("网络.消息")

m_init = false
m_activityinfo = {}

function setActivityInfo(pos,show,pic,text,func)
if m_activityinfo[pos]then
m_activityinfo[pos].show=show
m_activityinfo[pos].pic=pic or m_activityinfo[pos].pic
m_activityinfo[pos].text=text or m_activityinfo[pos].text
m_activityinfo[pos].func=func or m_activityinfo[pos].func
else
m_activityinfo[pos]={show=show,pic=pic,text=text,func=func}
end
	update()
end

function update()
	if not m_init then
		return
	end
	for i,v in pairs(m_activityinfo) do
		if ui.buttons[i] then
			if v.show then
				ui.buttons[i]:setVisible(true)
if v.pic and v.pic~=""and v.pic~=UIPATH then
				ui.buttons[i]:setBackground(v.pic)
end
ui.buttons[i]:setTitleText(v.text or"")
			else
				ui.buttons[i]:setVisible(false)
			end
		end
	end
end

function onUIInit()
	ui.buttons = {}
	for i=1,15 do
		ui.buttons[i] = ui:findComponent("活动_"..i)
		ui.buttons[i]:setVisible(false)
		ui.buttons[i].id = i
		ui.buttons[i]:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
			local btn = e:getCurrentTarget()
			if btn and m_activityinfo[btn.id] and m_activityinfo[btn.id].func then
				m_activityinfo[btn.id].func()
			end
		end))
	end
_v_251("活动UI",ui)
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
	ui:addEventListener(F3DObjEvent.OBJ_INITED, func_e(onUIInit))
	if ui.setUIPack and USEUIPACK then
		ui:setUIPack(g_mobileMode and UIPATH.."活动UIm.pack"or UIPATH.."活动UI.pack")
	else
		ui:setLayout(g_mobileMode and UIPATH.."活动UIm.layout" or UIPATH.."活动UI.layout")
	end
end

