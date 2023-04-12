module(..., package.seeall)

local 全局设置 = require("公用.全局设置")
local 游戏设置=require("公用.游戏设置")
local 消息 = require("网络.消息")
local 角色逻辑 = require("主界面.角色逻辑")
local 主界面UI = require("主界面.主界面UI")
local 角色UI = require("主界面.角色UI")
local 技能UI=require("技能.技能UI")

m_init = false
m_hpbar = nil
m_mpbar = nil
m_autoTakeDrug1 = 0.5
m_autoTakeDrug2 = 0.5
m_setTakeDrug = false
m_fightMode = false
m_pkmode = 0
tipsgrid = nil

function setHPBar(hp, hpmax)
	m_hpbar = {hp = hp, hpmax = hpmax}
	updateHPBar()
end

function setMPBar(mp, mpmax)
	m_mpbar = {mp = mp, mpmax = mpmax}
	updateMPBar()
end

function setAutoTakeDrug(val1, val2)
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
ui.hpkedu:setPercent((游戏设置.HPBAROPPO or(not g_mobileMode and ISMIRUI))and 1-m_autoTakeDrug1 or m_autoTakeDrug1)
ui.mpkedu:setPercent((游戏设置.HPBAROPPO or(not g_mobileMode and ISMIRUI))and 1-m_autoTakeDrug2 or m_autoTakeDrug2)
end

function update()
	if not m_init or 角色逻辑.m_rolejob == 0 then
		return
	end
	if g_mobileMode or not ISMIRUI then
if 游戏设置.HIDEHEADICON then

elseif true then
			ui.head:setBackground(全局设置.getHeadIconUrl(tonumber(10+(角色逻辑.m_rolejob-1)*2+角色逻辑.m_rolesex).."3"))
		else
			ui.head:setBackground(全局设置.getHeadIconUrl(tonumber(角色逻辑.m_rolejob..角色逻辑.m_rolesex)))
		end
		ui.rolename:setTitleText(txt(角色逻辑.m_rolename))
		ui.level:setTitleText("    "..角色逻辑.m_level)
		if 角色逻辑.m_money>=10000  then
		ui.金币:setTitleText(string.format(txt("    %.1f万"),角色逻辑.m_money/10000))
		else
		ui.金币:setTitleText("    "..角色逻辑.m_money)
		end
		if 角色逻辑.m_rmb>=10000  then
		ui.rmb:setTitleText(string.format(txt("    %.1f万"),角色逻辑.m_rmb/10000))
		else
		ui.rmb:setTitleText("    "..角色逻辑.m_rmb)
		end
		if 角色逻辑.m_总充值>=10000  then
		ui.总充值:setTitleText(string.format(txt("    %.1f万"),角色逻辑.m_总充值/10000))
		else
		ui.总充值:setTitleText("    "..角色逻辑.m_总充值)
		end
		--ui.VIP:setTitleText("    "..角色逻辑.m_vip等级)		
	if 角色逻辑.m_bindmoney>=10000  then
		ui.VIP:setTitleText(string.format(txt("    %.1f万"),角色逻辑.m_bindmoney/10000))
		else
		ui.VIP:setTitleText("    "..角色逻辑.m_bindmoney)
		end
		ui.pk:setTitleText(m_pkmode == 0 and txt("和平") or m_pkmode == 1 and txt("组队") or txt("行会"))
		ui.exptext:setTitleText(角色逻辑.m_exp.." / "..角色逻辑.m_expmax .. "  (" ..math.floor(角色逻辑.m_exp*100/角色逻辑.m_expmax).."%)")
	--	ui.hp:setTitleText(角色逻辑.m_hp)----
	--	ui.mp:setTitleText(角色逻辑.m_mp)----
		end
 end


function onGridOver(e)
	local g = e:getTarget()
	if g == nil then
	else
		if g == ui.hp and m_hpbar then
			ui.hp:setTitleText(m_hpbar.hp.." / "..m_hpbar.hpmax.."           ")
		--	ui.红量:setTitleText(m_hpbar.hp .."/".. m_hpbar.hpmax)
			ui.mp:setTitleText("")
			
		elseif g == ui.mp and m_mpbar then
			ui.mp:setTitleText("          "..m_mpbar.mp.." / "..m_mpbar.mpmax)
		--	ui.蓝量:setTitleText(m_hpbar.hp .."/".. m_hpbar.hpmax)
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
	--	ui.红量:setTitleText("")
	--	ui.蓝量:setTitleText("")
		tipsgrid = nil
	end
end

function onClickPK()
	消息.CG_CHANGE_STATUS(g_role.status, m_pkmode == 0 and 1 or m_pkmode == 1 and 2 or 0)
end

function onHPKeduChange(e)
m_autoTakeDrug1=(游戏设置.HPBAROPPO or(not g_mobileMode and ISMIRUI))and 1-ui.hpkedu:getPercent()or ui.hpkedu:getPercent()
	m_setTakeDrug = true
end

function onMPKeduChange(e)
m_autoTakeDrug2=(游戏设置.HPBAROPPO or(not g_mobileMode and ISMIRUI))and 1-ui.mpkedu:getPercent()or ui.mpkedu:getPercent()
	m_setTakeDrug = true
end

function onHeadClick(e)
	if not m_init then
		return
	end
	m_fightMode = not m_fightMode
	主界面UI.updateFightMode()
if 游戏设置.MIRROLEPANEL and not 技能UI.isHided()then
角色UI.setTabID(技能UI.m_tabid)
角色UI.setTabID2(0)
角色UI.initUI(技能UI.ui:getPositionX(),技能UI.ui:getPositionY())
技能UI.hideUI(true)
elseif not 角色UI.isHided()and 角色UI.m_tabid~=0 then
		角色UI.setTabID(0)--角色逻辑.m_rolejob-1)
	else
		角色UI.setTabID(0)--角色逻辑.m_rolejob-1)
if 游戏设置.MIRROLEPANEL and 角色UI.m_tabid2==3 then
角色UI.setTabID2(0)
end
		角色UI.toggle()
	end
end

function onUIInit()
	if g_mobileMode or not ISMIRUI then
		ui.head = ui:findComponent("head")
		ui.head:addEventListener(F3DMouseEvent.CLICK, func_me(onHeadClick))
		ui.rolename = ui:findComponent("rolename")
		ui.level = ui:findComponent("level") 
		ui.金币 = ui:findComponent("金币")--自定义货币
		ui.金币:setTitleText("金币:")
		ui.rmb = ui:findComponent("rmb")
		ui.rmb:setTitleText("元宝:")
		ui.红量 = ui:findComponent("红量")
		ui.红量:setTitleText("hong")
		ui.蓝量 = ui:findComponent("蓝量")
		ui.蓝量:setTitleText("lan")
		ui.总充值 = ui:findComponent("总充值")--自定义货币
		ui.总充值:setTitleText("赞助:")
		ui.VIP = ui:findComponent("VIP")--自定义货币
		ui.VIP:setTitleText("VIP:")		
		ui.exptext = ui:findComponent("exptext")--自定义经验显示
		ui.pk = ui:findComponent("pk")
		ui.pk:addEventListener(F3DMouseEvent.CLICK, func_me(onClickPK))
	end
	ui.hp = tt(ui:findComponent("hp"), F3DProgress)
	ui.hp:addEventListener(F3DUIEvent.MOUSE_OVER, func_ue(onGridOver))
	ui.hp:addEventListener(F3DUIEvent.MOUSE_OUT, func_ue(onGridOut))
	ui.hp:setTitleText("")
	ui.mp = tt(ui:findComponent("mp"), F3DProgress)
	ui.mp:addEventListener(F3DUIEvent.MOUSE_OVER, func_ue(onGridOver))
	ui.mp:addEventListener(F3DUIEvent.MOUSE_OUT, func_ue(onGridOut))
	ui.mp:setTitleText("")
	ui.vip = ui:findComponent("vip")
	ui.总充值 = ui:findComponent("总充值")
	ui.rmb = ui:findComponent("rmb")
	ui.金币 = ui:findComponent("金币")
	ui.clip_vip = ui:findComponent("clip_vip")
	ui.hpkedu = tt(ui:findComponent("hpkedu"), F3DProgress)
	ui.hpkedu:addEventListener(F3DUIEvent.CHANGE, func_ue(onHPKeduChange))
	ui.mpkedu = tt(ui:findComponent("mpkedu"), F3DProgress)
	ui.mpkedu:addEventListener(F3DUIEvent.CHANGE, func_ue(onMPKeduChange))
_v_251("头像信息UI",ui)
	m_init = true
	update()
	updateHPBar()
	updateMPBar()
	updateAutoKeduBar()
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
ui:setUIPack(g_mobileMode and UIPATH.."头像信息UIm.pack"or UIPATH.."头像信息UI.pack")
else
ui:setLayout(g_mobileMode and UIPATH.."头像信息UIm.layout" or UIPATH.."头像信息UI.layout")
end
	
end
