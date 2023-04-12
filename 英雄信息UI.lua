module(..., package.seeall)

local 全局设置 = require("公用.全局设置")
local 游戏设置=require("公用.游戏设置")
local 消息 = require("网络.消息")
local 角色逻辑 = require("主界面.角色逻辑")
local 角色UI = require("主界面.角色UI")
local 技能UI=require("技能.技能UI")

m_init = false
m_hpbar = nil
m_mpbar = nil
m_autoTakeDrug1 = 0.5
m_autoTakeDrug2 = 0.5
m_setTakeDrug = false
tipsgrid = nil
m_rolename = ""
m_objid = -1
m_level = 1
m_job = 0
m_sex = 0

function setInfo(rolename,objid,job,sex)
	m_rolename = rolename
	m_objid = objid
	m_job = job
	m_sex = sex
	update()
end

function setLevel(level)
	m_level = level
	updateLevel()
end

function setHPBar(hp, hpmax)
	m_hpbar = {hp = hp, hpmax = hpmax}
	updateHPBar()
end

function setMPBar(mp, mpmax)
	m_mpbar = {mp = mp, mpmax = mpmax}
	updateMPBar()
end

function setAutoTakeDrug(val1,val2)
	m_autoTakeDrug1 = val1
	m_autoTakeDrug2 = val2
	updateAutoKeduBar()
end

function updateHPBar()
	if not m_init or m_hpbar == nil then
		return
	end
	if m_hpbar.hpmax ~= 0 then
		ui.hp:setPercent(m_hpbar.hp / m_hpbar.hpmax)
	end
end

function updateMPBar()
	if not m_init or m_mpbar == nil then
		return
	end
	if m_mpbar.mpmax ~= 0 then
		ui.mp:setPercent(m_mpbar.mp / m_mpbar.mpmax)
	end
end

function updateAutoKeduBar()
	if not m_init then
		return
	end
	ui.hpkedu:setPercent(m_autoTakeDrug1)
	ui.mpkedu:setPercent(m_autoTakeDrug2)
end

function update()
	if not m_init then
		return
	end
	if m_objid == -1 then
		ui:setVisible(false)
		return
	end
	ui:setVisible(true)
	ui.head:setBackground(全局设置.getHeadIconUrl(tonumber(m_job..m_sex)))
	ui.rolename:setTitleText(txt(m_rolename))
end

function updateLevel()
	if not m_init then
		return
	end
	ui.level:setTitleText(m_level)
end

function onGridOver(e)
	local g = e:getTarget()
	if g == nil then
	else
		if g == ui.hp and m_hpbar then
			ui.hp:setTitleText(m_hpbar.hp.." / "..m_hpbar.hpmax)
			ui.mp:setTitleText("")
		elseif g == ui.mp and m_mpbar then
			ui.mp:setTitleText(m_mpbar.mp.." / "..m_mpbar.mpmax)
			ui.hp:setTitleText("")
		end
		tipsgrid = g
	end
end

function onGridOut(e)
	local g = e:getTarget()
	if g ~= nil and g == tipsgrid then
		ui.hp:setTitleText("")
		ui.mp:setTitleText("")
		tipsgrid = nil
	end
end




function onHPKeduChange(e)
	m_autoTakeDrug1 = ui.hpkedu:getPercent()
	m_setTakeDrug = true
end

function onMPKeduChange(e)
	m_autoTakeDrug2 = ui.mpkedu:getPercent()
	m_setTakeDrug = true
end

function onHeadClick(e)
if not m_init then
return
end
if 游戏设置.MIRROLEPANEL and not 技能UI.isHided()then
角色UI.setTabID(1)
角色UI.setTabID2(0)
角色UI.initUI(技能UI.ui:getPositionX(),技能UI.ui:getPositionY())
技能UI.hideUI(true)
elseif not 角色UI.isHided()and 角色UI.m_tabid~=1 then
角色UI.setTabID(1)
else
角色UI.setTabID(1)
if 游戏设置.MIRROLEPANEL and 角色UI.m_tabid2==3 then
角色UI.setTabID2(0)
end
角色UI.toggle()
end
end

function onUIInit()
	ui.head = ui:findComponent("head")
	ui.head:addEventListener(F3DMouseEvent.CLICK, func_me(onHeadClick))
	ui.hp = tt(ui:findComponent("hp"), F3DProgress)
	ui.hp:addEventListener(F3DUIEvent.MOUSE_OVER, func_ue(onGridOver))
	ui.hp:addEventListener(F3DUIEvent.MOUSE_OUT, func_ue(onGridOut))
	ui.hp:setTitleText("")
	ui.mp = tt(ui:findComponent("mp"), F3DProgress)
	ui.mp:addEventListener(F3DUIEvent.MOUSE_OVER, func_ue(onGridOver))
	ui.mp:addEventListener(F3DUIEvent.MOUSE_OUT, func_ue(onGridOut))
	ui.mp:setTitleText("")
	ui.rolename = ui:findComponent("rolename")
	ui.vip = ui:findComponent("vip")
	ui.clip_vip = ui:findComponent("clip_vip")
	ui.level = ui:findComponent("level")
	ui.hpkedu = tt(ui:findComponent("hpkedu"), F3DProgress)
	ui.hpkedu:addEventListener(F3DUIEvent.CHANGE, func_ue(onHPKeduChange))
	ui.mpkedu = tt(ui:findComponent("mpkedu"), F3DProgress)
	ui.mpkedu:addEventListener(F3DUIEvent.CHANGE, func_ue(onMPKeduChange))
	ui:setVisible(false)
	m_init = true
	update()
	updateLevel()
	updateHPBar()
	updateMPBar()
	updateAutoKeduBar()
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
		ui:setUIPack(g_mobileMode and UIPATH.."英雄信息UIm.pack" or UIPATH.."英雄信息UI.pack")
	else
		ui:setLayout(g_mobileMode and UIPATH.."英雄信息UIm.layout" or UIPATH.."英雄信息UI.layout")
	end
end
