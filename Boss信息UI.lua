module(..., package.seeall)

local 全局设置 = require("公用.全局设置")
local 消息 = require("网络.消息")

m_init = false
m_bossinfo = {}

function setBossInfo(objid, name, lv, belong, head, hp, hpmax)
	local bossinfo = nil
	for i,v in ipairs(m_bossinfo) do
		if v.objid == objid then
			bossinfo = v
			break
		end
	end
	if bossinfo then
		bossinfo.name = name
		bossinfo.lv = lv
		bossinfo.belong = belong
		bossinfo.head = head
		bossinfo.hp = hp
		bossinfo.hpmax = hpmax
	else
		m_bossinfo[#m_bossinfo+1] = {objid=objid,name=name,lv=lv,belong=belong,head=head,hp=hp,hpmax=hpmax}
	end
	update()
end

function delBossInfo(objid)
	for i,v in ipairs(m_bossinfo) do
		if v.objid == objid then
			table.remove(m_bossinfo,i)
			break
		end
	end
	update()
end

function update()
	if not m_init then
		return
	end
	local index = 0
	for i,v in ipairs(m_bossinfo) do
		if i <= 2 then
			ui.bossui[i].component:setVisible(true)
			ui.bossui[i].hp:setPercent(v.hp / v.hpmax)
			ui.bossui[i].head:setBackground(全局设置.getBossHeadUrl(v.head))
			ui.bossui[i].myname:setTitleText(txt(v.name))
			ui.bossui[i].lv:setTitleText("LV:"..v.lv)
			ui.bossui[i].belong:setTitleText(txt("归属:"..v.belong))
			index = i
		end
	end
	for i=index+1,2 do
		ui.bossui[i].component:setVisible(false)
	end
end

function onUIInit()
	ui.bossui = {}
	for i=1,2 do
		ui.bossui[i] = {}
		ui.bossui[i].component = ui:findComponent("component_"..i)
		ui.bossui[i].component:setVisible(false)
		ui.bossui[i].hp = tt(ui:findComponent("component_"..i..",hp"),F3DProgress)
		ui.bossui[i].head = ui:findComponent("component_"..i..",head")
		ui.bossui[i].head.id = i
		ui.bossui[i].head:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
			local head = e:getCurrentTarget()
			if head and m_bossinfo[head.id] and m_bossinfo[head.id].objid then
				setMainRoleTarget(g_roles[m_bossinfo[head.id].objid])
			end
		end))
		ui.bossui[i].myname = ui:findComponent("component_"..i..",myname")
		ui.bossui[i].lv = ui:findComponent("component_"..i..",lv")
		ui.bossui[i].belong = ui:findComponent("component_"..i..",belong")
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
		ui:setVisible(true)
		return
	end
	ui = F3DLayout:new()
	uiLayer:addChild(ui)
	ui:setLoadPriority(getUIPriority())
	ui:addEventListener(F3DObjEvent.OBJ_INITED, func_e(onUIInit))
if ui.setUIPack and USEUIPACK then
ui:setUIPack(UIPATH.."Boss信息UI.pack")
else
	ui:setLayout(UIPATH.."Boss信息UI.layout")
end
end
