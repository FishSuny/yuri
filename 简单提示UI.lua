module(..., package.seeall)

local 全局设置 = require("公用.全局设置")
local 消息 = require("网络.消息")
local 背包UI = require("主界面.背包UI")

m_init = false
m_itemdata = nil
m_skill = nil

function setItemData(iconurl,name,grade,desc,skill)
	m_itemdata = {iconurl=iconurl,name=name,grade=grade,desc=desc}
	m_skill = skill
	update()
end

COLORBG = {
	"",
	UIPATH.."公用/tip/tips_color_1.png",
	UIPATH.."公用/tip/tips_color_2.png",
	UIPATH.."公用/tip/tips_color_3.png",
	UIPATH.."公用/tip/tips_color_4.png",
	UIPATH.."公用/tip/tips_color_5.png",
}

function update()
	if not m_init or not m_itemdata then
		return
	end
	ui.img.pic:setTextureFile(m_itemdata.iconurl)
	ui.name:setTitleText(txt(m_itemdata.name))
	ui.name:setTextColor(全局设置.getColorRgbVal(m_itemdata.grade))
local color=0xffffff
local desc=m_itemdata.desc
if desc:sub(1,2)=="<c"and desc:find(">")then
color=tonumber("0x"..desc:sub(3,desc:find(">")-1))or 0
desc=desc:sub(desc:find(">")+1)
end
ui.desc:setTitleText(txt(desc))
ui.desc:setTextColor(color)
	if g_mobileMode then
		ui.menus[1]:setTitleText((m_skill ~= nil and m_skill.hangup == 1) and txt("关闭挂机") or txt("开启挂机"))
		ui.menus[1]:setVisible(m_skill ~= nil)
		ui.menus[2]:setVisible(m_skill ~= nil and m_skill.lv < m_skill.lvmax)
		ui.levelmax:setVisible(m_skill ~= nil and m_skill.lv >= m_skill.lvmax)
	end
end

function onMouseDown(e)
	uiLayer:removeChild(ui)
	uiLayer:addChild(ui)
	e:stopPropagation()
end

function onMenuClick(e)
	local g = e:getCurrentTarget()
	if g == ui.menus[1] then
		if m_skill ~= nil then
消息.CG_SKILL_HANGUP(m_skill.hero==1 and-m_skill.infoid or m_skill.infoid,m_skill.hangup==1 and 0 or 1)
		end
	elseif g == ui.menus[2] then
		if m_skill ~= nil then
消息.CG_SKILL_UPGRADE(m_skill.hero==1 and-m_skill.infoid or m_skill.infoid)
		end
	end
	背包UI.hideAllTipsUI()
end

function onUIInit()
	ui:addEventListener(F3DMouseEvent.MOUSE_DOWN, func_me(onMouseDown))
	ui.grid = ui:findComponent("grid")
	ui.name = ui:findComponent("name")
	ui.desc = ui:findComponent("desc")
	ui.img = F3DImage:new()
ui.img:setPositionX(0)
ui.img:setPositionY(0)
ui.img:setWidth(ui.grid:getHeight())
ui.img:setHeight(ui.grid:getHeight())
	ui.grid:addChild(ui.img)
	ui.img.pic = F3DImage:new()
	ui.img.pic:setPositionX(math.floor(ui.img:getWidth()/2))
	ui.img.pic:setPositionY(math.floor(ui.img:getHeight()/2))
	ui.img.pic:setPivot(0.5,0.5)
	ui.img:addChild(ui.img.pic)
	ui.menus = {}
	if g_mobileMode then
		for i = 1,2 do
			ui.menus[i] = ui:findComponent("menu_"..i)
			ui.menus[i]:addEventListener(F3DMouseEvent.CLICK, func_me(onMenuClick))
		end
		ui.levelmax = ui:findComponent("img_MAX")
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
	if not g_mobileMode then
		ui:setTouchable(false)
	end
	ui:addEventListener(F3DObjEvent.OBJ_INITED, func_e(onUIInit))
	if ui.setUIPack and USEUIPACK then
ui:setUIPack(g_mobileMode and UIPATH.."简单提示UIm.pack"or UIPATH.."简单提示UI.pack")
else
ui:setLayout(g_mobileMode and UIPATH.."简单提示UIm.layout" or UIPATH.."简单提示UI.layout")end
	
end
