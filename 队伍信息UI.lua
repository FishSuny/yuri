module(..., package.seeall)

local 全局设置 = require("公用.全局设置")
local 消息 = require("网络.消息")

m_init = false
m_teaminfo = nil

function setTeamInfo(teaminfo)
	m_teaminfo = {}
	local index = 1
	for i,v in ipairs(teaminfo) do
		if g_role and v[1] ~= g_role.objid then
			m_teaminfo[index] = {}
			m_teaminfo[index].objid = v[1]
			m_teaminfo[index].name = v[2]
			m_teaminfo[index].lv = v[3]
			m_teaminfo[index].hp = v[5]
			m_teaminfo[index].hpmax = v[6]
			m_teaminfo[index].job = v[7]
			index = index + 1
		end
	end
	update()
end

function update()
	if not m_init or not m_teaminfo then
		return
	end
	local index = 0
	for i,v in ipairs(m_teaminfo) do
		if i <= 4 then
			ui.teamui[i].component:setVisible(true)
			ui.teamui[i].hp:setPercent(v.hp / v.hpmax)
			ui.teamui[i].head:setBackground(全局设置.getHeadIconUrl(v.job))
			ui.teamui[i].myname:setTitleText(txt(v.name))
			ui.teamui[i].lv:setTitleText(v.lv)
			ui.teamui[i].head:setDisable(v.hp <= 0)
			index = i
		end
	end
	for i=index+1,4 do
		ui.teamui[i].component:setVisible(false)
	end
end

function onClickHead(e)
	if g_role.hp > 0 then
		return
	end
	local head = e:getCurrentTarget()
	if head and head.id and m_teaminfo[head.id] then
		消息.CG_VIEWER(m_teaminfo[head.id].objid)
	end
end

function onUIInit()
	ui.teamui = {}
	for i=1,4 do
		ui.teamui[i] = {}
		ui.teamui[i].component = ui:findComponent("ui_"..i)
ui.teamui[i].component:setVisible(false)
		ui.teamui[i].hp = tt(ui:findComponent("ui_"..i..",hp"),F3DProgress)
		ui.teamui[i].head = ui:findComponent("ui_"..i..",head")
		ui.teamui[i].head.id = i
		ui.teamui[i].head:addEventListener(F3DMouseEvent.CLICK, func_me(onClickHead))
		ui.teamui[i].myname = ui:findComponent("ui_"..i..",myname")
		ui.teamui[i].lv = ui:findComponent("ui_"..i..",lv")
	end
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

function initUI()
	if ui then
		uiLayer:removeChild(ui)
		uiLayer:addChild(ui)
		ui:updateParent()

		return
	end
	ui = F3DLayout:new()
	uiLayer:addChild(ui)
	ui:setLoadPriority(getUIPriority())
	ui:addEventListener(F3DObjEvent.OBJ_INITED, func_e(onUIInit))
if ui.setUIPack and USEUIPACK then
ui:setUIPack(UIPATH.."队伍信息UI.pack")
else
	ui:setLayout(UIPATH.."队伍信息UI.layout")
end
end
