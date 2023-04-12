module(..., package.seeall)

local 全局设置 = require("公用.全局设置")
local 消息 = require("网络.消息")
local 主界面UI = require("主界面.主界面UI")
--local 目标信息UI = require("主界面.目标信息UI")

m_init = false
m_goalinfo = nil

function setGoalInfo(objid,head,name,lv,hp,hpmax)
	m_goalinfo = {objid=objid,head=head,name=name,lv=lv,hp=hp,hpmax=hpmax}
	update()
end

function update()
	if not m_init or not m_goalinfo then
		return
	end
	if m_goalinfo.objid ~= -1 then
		ui:setVisible(true)
local p1=m_goalinfo.name:find("#c")
local p2=p1 and m_goalinfo.name:find("%[",p1+2)or nil
local _v_1636=p2 and m_goalinfo.name:sub(1,p2-1)or m_goalinfo.name
local belong=p2 and m_goalinfo.name:sub(p2)or""
local namecolor=p1 and tonumber("0x".._v_1636:sub(p1+2))or 0xffffff
local name=p1 and _v_1636:sub(1,p1-1)or _v_1636
		local p = name:find("\\")
ui.rolename:setTitleText(p and txt(name:sub(1,p-1)..belong)or txt(name..belong))
		ui.rolename:setTextColor(namecolor)
ui.level:setTitleText((m_goalinfo.lv and m_goalinfo.lv>=0)and m_goalinfo.lv or-1)
		ui.hp:setPercent(m_goalinfo.hp / m_goalinfo.hpmax)
		if m_goalinfo.hp>=100000000 and m_goalinfo.hpmax>=100000000 then
		ui.hp:setTitleText(string.format(txt("%.1f亿/%.1f亿"),m_goalinfo.hp/100000000,m_goalinfo.hpmax/100000000))
		elseif m_goalinfo.hp>=10000 and m_goalinfo.hpmax>=100000000 then
			ui.hp:setTitleText(string.format(txt("%.1f万/%.1f亿"),m_goalinfo.hp/10000,m_goalinfo.hpmax/100000000))
		elseif m_goalinfo.hp>=10000 and m_goalinfo.hpmax>=10000 then
			ui.hp:setTitleText(string.format(txt("%.1f万/%.1f万"),m_goalinfo.hp/10000,m_goalinfo.hpmax/10000))
		elseif m_goalinfo.hpmax>=10000 then
			ui.hp:setTitleText(string.format(txt("%s/%.1f万"),m_goalinfo.hp,m_goalinfo.hpmax/10000))
		else
			ui.hp:setTitleText(m_goalinfo.hp.."/"..m_goalinfo.hpmax)
		end	
	else
		ui:setVisible(false)
	end

	--添加自动更新主界面对话按钮状态
	--加入目标信息自动刷新
--local name1 = 目标信息UI.m_goalinfo.objid
    local 目标信息UI = require("主界面.目标信息UI")
	--if 目标信息UI.isHided()  then  else print(txt("wwww11..."))  end
if 目标信息UI.m_goalinfo  then
	local role = g_roles[m_goalinfo.objid]
	   if role and role.objtype and role.objtype ~=全局设置.OBJTYPE_PLAYER then
	   --print(txt("类型..."..role.objtype))
	   local str = 目标信息UI.m_goalinfo.name 
	   if  str  then 
	   主界面UI.ui.button_pick:setTitleText(g_mobileMode and txt(""..str)or txt("对话-"))
	   end
	   else
	   主界面UI.ui.button_pick:setTitleText(g_mobileMode and txt("")or txt(""))
	   --print(txt("类型..."))
	   end
end
end

function onHeadClick(e)
	if not m_init or not m_goalinfo then
		return
	end
	local role = g_roles[m_goalinfo.objid]
	if role and (role.objtype == 全局设置.OBJTYPE_PLAYER or role.objtype == 全局设置.OBJTYPE_PET) then
消息.CG_EQUIP_VIEW(role.objid,"")
	elseif role and (role.objtype == 全局设置.OBJTYPE_MONSTER or role.objtype == 全局设置.OBJTYPE_NPC) then
		setMainRoleTarget(role)
	end
end

function onUIInit()
	ui.head = ui:findComponent("component_1,head")
	ui.head:addEventListener(F3DMouseEvent.CLICK, func_me(onHeadClick))
	ui.hp = tt(ui:findComponent("component_1,hp"), F3DProgress)
	ui.rolename = ui:findComponent("component_1,myname")
	ui.level = ui:findComponent("component_1,lv")
	ui.level:setTouchable(false)
	ui.close = ui:findComponent("component_1,close")
	if ui.close then
		ui.close:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
			ui.close:releaseMouse()
			resetAttackObj(nil)
		end))
	end
	ui:setVisible(false)
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
		ui:setUIPack(g_mobileMode and UIPATH.."目标信息UIm.pack" or UIPATH.."目标信息UI.pack")
	else
		ui:setLayout(g_mobileMode and UIPATH.."目标信息UIm.layout" or UIPATH.."目标信息UI.layout")
	end
end
