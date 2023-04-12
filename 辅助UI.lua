module(..., package.seeall)

local 全局设置 = require("公用.全局设置")
local 游戏设置 = require("公用.游戏设置")												   
local 消息 = require("网络.消息")
local 角色逻辑 = require("主界面.角色逻辑")
local 头像信息UI = require("主界面.头像信息UI")
local 英雄信息UI = require("主界面.英雄信息UI")
local 主界面UI = require("主界面.主界面UI")
local 物品使用表 = require("配置.物品使用表").Config

m_init = false
m_自动分解白 = 0
m_自动分解绿 = 0
m_自动分解蓝 = 0
m_自动分解紫 = 0
m_自动分解橙 = 0
m_自动分解等级 = 30
m_使用生命药 = 0
m_使用魔法药 = 0
m_英雄使用生命药 = 0
m_英雄使用魔法药 = 0
m_使用物品HP = 0--数量
m_使用物品ID = 0--物品 
m_自动使用合击 = 0
m_自动分解宠物白 = 0
m_自动分解宠物绿 = 0
m_自动分解宠物蓝 = 0
m_自动分解宠物紫 = 0
m_自动分解宠物橙 = 0
m_自动孵化宠物蛋 = 0
m_物品自动拾取 = 0
m_自动拾取白 = 1
m_自动拾取绿 = 1
m_自动拾取蓝 = 1
m_自动拾取紫 = 1
m_自动拾取橙 = 1
m_自动拾取金币 = 1
m_怪物简装 = 0
m_人物简装 = 0
m_自动拾取等级 = 0
m_挂机怪物数量 = 1
m_挂机使用物品 = 0
生命药水 = {}
魔法药水 = {}
英雄生命药水={}
英雄魔法药水={}
物品列表 = {{txt("无"),0,1},}
for i,v in ipairs(物品使用表) do
	if v.type == 1 then
		生命药水[#生命药水+1] = {txt(v.name),v.itemid,v.level}
	elseif v.type == 2 then
		魔法药水[#魔法药水+1] = {txt(v.name),v.itemid,v.level}
elseif v.type==3 then
英雄生命药水[#英雄生命药水+1]={txt(v.name),v.itemid,v.level}
elseif v.type==4 then
英雄魔法药水[#英雄魔法药水+1]={txt(v.name),v.itemid,v.level}
	else
		物品列表[#物品列表+1] = {txt(v.name),v.itemid,v.level}
	end
end

function setSetup(自动分解白,自动分解绿,自动分解蓝,自动分解紫,自动分解橙,自动分解等级,使用生命药,使用魔法药,英雄使用生命药,英雄使用魔法药,使用物品HP,使用物品ID,自动使用合击,自动分解宠物白,自动分解宠物绿,自动分解宠物蓝,自动分解宠物紫,自动分解宠物橙,自动孵化宠物蛋,物品自动拾取,自动拾取白,自动拾取绿,自动拾取蓝,自动拾取紫,自动拾取橙,自动拾取金币,自动拾取等级,挂机怪物数量,挂机使用物品)
	m_自动分解白 = 自动分解白
	m_自动分解绿 = 自动分解绿
	m_自动分解蓝 = 自动分解蓝
	m_自动分解紫 = 自动分解紫
	m_自动分解橙 = 自动分解橙
	m_自动分解等级 = 自动分解等级
	m_使用生命药 = 使用生命药
	m_使用魔法药 = 使用魔法药
	m_英雄使用生命药 = 英雄使用生命药
	m_英雄使用魔法药 = 英雄使用魔法药
	m_使用物品HP = 使用物品HP
	m_使用物品ID = 使用物品ID
	m_自动使用合击 = 自动使用合击
	m_自动分解宠物白 = 自动分解宠物白
	m_自动分解宠物绿 = 自动分解宠物绿
	m_自动分解宠物蓝 = 自动分解宠物蓝
	m_自动分解宠物紫 = 自动分解宠物紫
	m_自动分解宠物橙 = 自动分解宠物橙
	m_自动孵化宠物蛋 = 自动孵化宠物蛋
	m_物品自动拾取 = 物品自动拾取
	m_自动拾取白 = 自动拾取白
	m_自动拾取绿 = 自动拾取绿
	m_自动拾取蓝 = 自动拾取蓝
	m_自动拾取紫 = 自动拾取紫
	m_自动拾取橙 = 自动拾取橙
	m_自动拾取金币 = 自动拾取金币
	m_自动拾取等级 = 自动拾取等级
	m_挂机怪物数量 = 挂机怪物数量
	m_挂机使用物品 = 挂机使用物品
	update()				  
end
function _v_2099()
	if 游戏设置.HIDEDROPNAME then
		for i,v in pairs(g_items)do
			if v.ownerid==-3 or v.ownerid==-4 or v.ownerid==-5 then
				v.tf:setVisible((v.ownerid==-3 and 角色逻辑._v_2038[1]==1)or(v.ownerid==-4 and 角色逻辑._v_2038[2]==1)or(v.ownerid==-5 and 角色逻辑._v_2038[3]==1))
			else
				v.tf:setVisible(true)
			end
			if v.name=="元宝"or v.name=="金币"then
				if v.name=="金币"and m_自动孵化宠物蛋==1 and 辅助UI.m_自动拾取金币==0 then
					v.tf:setVisible(false)
				end
			elseif v.grade==1 and(m_自动分解宠物白==1 or(m_自动孵化宠物蛋==1 and(m_自动拾取白==0 or m_自动拾取等级>v.level)))then
				v.tf:setVisible(false)
			elseif v.grade==2 and(m_自动分解宠物绿==1 or(m_自动孵化宠物蛋==1 and(	m_自动拾取绿==0 or m_自动拾取等级>v.level)))then
				v.tf:setVisible(false)
			elseif v.grade==3 and(m_自动分解宠物蓝==1 or(m_自动孵化宠物蛋==1 and(m_自动拾取蓝==0 or m_自动拾取等级>v.level)))then
				v.tf:setVisible(false)
			elseif v.grade==4 and(m_自动分解宠物紫==1 or(m_自动孵化宠物蛋==1 and(m_自动拾取紫==0 or m_自动拾取等级>v.level)))then
				v.tf:setVisible(false)
			elseif v.grade==5 and(m_自动分解宠物橙==1 or(m_自动孵化宠物蛋==1 and(m_自动拾取橙==0 or m_自动拾取等级>v.level)))then
				v.tf:setVisible(false)
			end
		end
	end
end

function update()
	if not m_init then return end
	ui.自动分解品质白:setSelected(m_自动分解白 == 1)
	ui.自动分解品质绿:setSelected(m_自动分解绿 == 1)
	ui.自动分解品质蓝:setSelected(m_自动分解蓝 == 1)
	ui.自动分解品质紫:setSelected(m_自动分解紫 == 1)
	ui.自动分解品质橙:setSelected(m_自动分解橙 == 1)
	ui.自动分解等级:setTitleText(m_自动分解等级)
ui.优先使用药品生命1:setTitleText(math.floor(头像信息UI.m_autoTakeDrug1*100+0.5))
	for i,v in ipairs(生命药水) do
		if m_使用生命药 == 0 or m_使用生命药 == v[2] then
			ui.优先使用药品生命2:setTitleText(v[1])
			break
		end
	end
ui.优先使用药品魔法1:setTitleText(math.floor(头像信息UI.m_autoTakeDrug2*100+0.5))
	for i,v in ipairs(魔法药水) do
		if m_使用魔法药 == 0 or m_使用魔法药 == v[2] then
			ui.优先使用药品魔法2:setTitleText(v[1])
			break
		end
	end
ui.英雄使用药品生命1:setTitleText(math.floor(英雄信息UI.m_autoTakeDrug1*100+0.5))
if 游戏设置.USESECONDDRUG then
for i,v in ipairs(英雄生命药水)do
if m_英雄使用生命药==0 or m_英雄使用生命药==v[2]then
ui.英雄使用药品生命2:setTitleText(v[1])
break
end
end
else
	for i,v in ipairs(生命药水) do
		if m_英雄使用生命药 == 0 or m_英雄使用生命药 == v[2] then
			ui.英雄使用药品生命2:setTitleText(v[1])
			break
		end
	end
end
ui.英雄使用药品魔法1:setTitleText(math.floor(英雄信息UI.m_autoTakeDrug2*100+0.5))
if 游戏设置.USESECONDDRUG then
	for i,v in ipairs(魔法药水) do
		if m_英雄使用魔法药 == 0 or m_英雄使用魔法药 == v[2] then
			ui.英雄使用药品魔法2:setTitleText(v[1])
			break
end
end
else
for i,v in ipairs(魔法药水)do
if m_英雄使用魔法药==0 or m_英雄使用魔法药==v[2]then
ui.英雄使用药品魔法2:setTitleText(v[1])
break
end
		end
	end
	ui.自动使用物品1:setTitleText(m_使用物品HP)
	for i,v in ipairs(物品列表) do
		if m_使用物品ID == v[2] then
			ui.自动使用物品2:setTitleText(v[1])
			break
		end
	end
	ui.自动使用合击:setSelected(m_自动使用合击 == 1)
	ui.自动分解宠物白:setSelected(m_自动分解宠物白 == 1)
	ui.自动分解宠物绿:setSelected(m_自动分解宠物绿 == 1)
	ui.自动分解宠物蓝:setSelected(m_自动分解宠物蓝 == 1)
	ui.自动分解宠物紫:setSelected(m_自动分解宠物紫 == 1)
	ui.自动分解宠物橙:setSelected(m_自动分解宠物橙 == 1)
	ui.自动孵化宠物蛋:setSelected(m_自动孵化宠物蛋 == 1)
	ui.物品自动拾取:setSelected(m_物品自动拾取 == 1)
	ui.自动拾取品质白:setSelected(m_自动拾取白 == 1)
	ui.自动拾取品质绿:setSelected(m_自动拾取绿 == 1)
	ui.自动拾取品质蓝:setSelected(m_自动拾取蓝 == 1)
	ui.自动拾取品质紫:setSelected(m_自动拾取紫 == 1)
	ui.自动拾取品质橙:setSelected(m_自动拾取橙 == 1)
	ui.自动拾取金币:setSelected(m_自动拾取金币 == 1)
	ui.自动拾取等级:setTitleText(m_自动拾取等级)
	ui.挂机怪物数量:setTitleText(m_挂机怪物数量)
	for i,v in ipairs(物品列表) do
		if m_挂机使用物品 == v[2] then
			ui.挂机使用物品:setTitleText(v[1])
			break
		end
	end
_v_2099()
end

function onOK(e)
	local HP保护 = math.max(0, math.min(100, not ui.优先使用药品生命1:isDefault() and tonumber(ui.优先使用药品生命1:getTitleText()) or 0))
	local MP保护 = math.max(0, math.min(100, not ui.优先使用药品魔法1:isDefault() and tonumber(ui.优先使用药品魔法1:getTitleText()) or 0))
	local 英雄HP保护 = math.max(0, math.min(100, not ui.英雄使用药品生命1:isDefault() and tonumber(ui.英雄使用药品生命1:getTitleText()) or 0))
	local 英雄MP保护 = math.max(0, math.min(100, not ui.英雄使用药品魔法1:isDefault() and tonumber(ui.英雄使用药品魔法1:getTitleText()) or 0))
	头像信息UI.setAutoTakeDrug(HP保护/100, MP保护/100)
	英雄信息UI.setAutoTakeDrug(英雄HP保护/100, 英雄MP保护/100)
	m_自动分解白 = ui.自动分解品质白:isSelected() and 1 or 0
	m_自动分解绿 = ui.自动分解品质绿:isSelected() and 1 or 0
	m_自动分解蓝 = ui.自动分解品质蓝:isSelected() and 1 or 0
	m_自动分解紫 = ui.自动分解品质紫:isSelected() and 1 or 0
	m_自动分解橙 = ui.自动分解品质橙:isSelected() and 1 or 0
	m_自动分解等级 = math.max(0, math.min(100, not ui.自动分解等级:isDefault() and tonumber(ui.自动分解等级:getTitleText()) or 0))
	for i,v in ipairs(生命药水) do
		if ui.优先使用药品生命2:getTitleText() == v[1] then
			m_使用生命药 = v[2]
			break
		end
	end
	for i,v in ipairs(魔法药水) do
		if ui.优先使用药品魔法2:getTitleText() == v[1] then
			m_使用魔法药 = v[2]
			break
		end
	end
if 游戏设置.USESECONDDRUG then
for i,v in ipairs(英雄生命药水)do
if ui.英雄使用药品生命2:getTitleText()==v[1]then
m_英雄使用生命药=v[2]
break
end
end
else
	for i,v in ipairs(生命药水) do
		if ui.英雄使用药品生命2:getTitleText() == v[1] then
			m_英雄使用生命药 = v[2]
			break
		end
	end
end
if 游戏设置.USESECONDDRUG then
	for i,v in ipairs(魔法药水) do
		if ui.英雄使用药品魔法2:getTitleText() == v[1] then
			m_英雄使用魔法药 = v[2]
			break
end
end
else
for i,v in ipairs(魔法药水)do
if ui.英雄使用药品魔法2:getTitleText()==v[1]then
m_英雄使用魔法药=v[2]
break
end
		end
	end
	m_使用物品HP = math.max(0, math.min(100, not ui.自动使用物品1:isDefault() and tonumber(ui.自动使用物品1:getTitleText()) or 0))
	for i,v in ipairs(物品列表) do
		if ui.自动使用物品2:getTitleText() == v[1] then
			m_使用物品ID = v[2]
			break
		end
	end
	m_自动使用合击 = (角色逻辑.m_vip等级 > 0 and ui.自动使用合击:isSelected()) and 1 or 0
	if 角色逻辑.m_vip等级 < 1 and ui.自动使用合击:isSelected() then
		主界面UI.showTipsMsg(1,txt("非VIP1级用户无法设置自动使用合击"))
	end
	m_自动分解宠物白 = ui.自动分解宠物白:isSelected() and 1 or 0
	m_自动分解宠物绿 = ui.自动分解宠物绿:isSelected() and 1 or 0
	m_自动分解宠物蓝 = ui.自动分解宠物蓝:isSelected() and 1 or 0
	m_自动分解宠物紫 = ui.自动分解宠物紫:isSelected() and 1 or 0
	m_自动分解宠物橙 = ui.自动分解宠物橙:isSelected() and 1 or 0
m_自动孵化宠物蛋=ui.自动孵化宠物蛋:isSelected()and 1 or 0




	m_物品自动拾取 = (角色逻辑.m_vip等级 > 1 and ui.物品自动拾取:isSelected()) and 1 or 0
	if 角色逻辑.m_vip等级 < 2 and ui.物品自动拾取:isSelected() then
		主界面UI.showTipsMsg(1,txt("非VIP2级用户无法设置物品自动拾取"))
	end
	m_自动拾取白 = ui.自动拾取品质白:isSelected() and 1 or 0
	m_自动拾取绿 = ui.自动拾取品质绿:isSelected() and 1 or 0
	m_自动拾取蓝 = ui.自动拾取品质蓝:isSelected() and 1 or 0
	m_自动拾取紫 = ui.自动拾取品质紫:isSelected() and 1 or 0
	m_自动拾取橙 = ui.自动拾取品质橙:isSelected() and 1 or 0
	m_自动拾取金币 = ui.自动拾取金币:isSelected() and 1 or 0
	m_怪物简装 = ui.怪物简装:isSelected() and 1 or 0
	m_人物简装 = ui.人物简装:isSelected() and 1 or 0
	m_自动拾取等级 = math.max(0, math.min(100, not ui.自动拾取等级:isDefault() and tonumber(ui.自动拾取等级:getTitleText()) or 0))
	m_挂机怪物数量 = math.max(0, math.min(100, not ui.挂机怪物数量:isDefault() and tonumber(ui.挂机怪物数量:getTitleText()) or 0))
	for i,v in ipairs(物品列表) do
		if ui.挂机使用物品:getTitleText() == v[1] then
			m_挂机使用物品 = v[2]
			break
		end
	end
	消息.CG_HUMAN_SETUP(
math.floor(头像信息UI.m_autoTakeDrug1*100+0.5),
math.floor(头像信息UI.m_autoTakeDrug2*100+0.5),
math.floor(英雄信息UI.m_autoTakeDrug1*100+0.5),
math.floor(英雄信息UI.m_autoTakeDrug2*100+0.5),
		m_自动分解白,
		m_自动分解绿,
		m_自动分解蓝,
		m_自动分解紫,
		m_自动分解橙,
		m_自动分解等级,
		m_使用生命药,
		m_使用魔法药,
		m_英雄使用生命药,
		m_英雄使用魔法药,
		m_使用物品HP,
		m_使用物品ID,
		m_自动使用合击,
		m_自动分解宠物白,
		m_自动分解宠物绿,
		m_自动分解宠物蓝,
		m_自动分解宠物紫,
		m_自动分解宠物橙,
		m_自动孵化宠物蛋,		
m_物品自动拾取,
		m_自动拾取白,
		m_自动拾取绿,
		m_自动拾取蓝,
		m_自动拾取紫,
		m_自动拾取橙,
		m_自动拾取金币,
		m_自动拾取等级,
		m_挂机怪物数量,
		m_挂机使用物品)
	_v_2099()	 
_v_62(ui,false)
	ui.close:releaseMouse()
	e:stopPropagation()
end

function onClose(e)
_v_62(ui,false)
	ui:releaseMouse()
	ui.close:releaseMouse()
	e:stopPropagation()
end

function onMouseDown(e)
	uiLayer:removeChild(ui)
	uiLayer:addChild(ui)
	e:stopPropagation()
end

function onUIInit()
	ui.close = ui:findComponent("标题栏,关闭")
	ui.close:addEventListener(F3DMouseEvent.CLICK, func_me(onClose))
	ui:addEventListener(F3DMouseEvent.MOUSE_DOWN, func_me(onMouseDown))
	ui.自动分解品质白 = tt(ui:findComponent("自动分解品质,checkbox_1"),F3DCheckBox)
	ui.自动分解品质绿 = tt(ui:findComponent("自动分解品质,checkbox_2"),F3DCheckBox)
	ui.自动分解品质蓝 = tt(ui:findComponent("自动分解品质,checkbox_3"),F3DCheckBox)
	ui.自动分解品质紫 = tt(ui:findComponent("自动分解品质,checkbox_4"),F3DCheckBox)
	ui.自动分解品质橙 = tt(ui:findComponent("自动分解品质,checkbox_5"),F3DCheckBox)
	ui.自动分解等级 = tt(ui:findComponent("自动分解等级,textinput_1"),F3DTextInput)
	ui.优先使用药品生命1 = tt(ui:findComponent("优先使用药品1,textinput_1"),F3DTextInput)
	ui.优先使用药品生命2 = tt(ui:findComponent("优先使用药品1,combo_1"),F3DCombo)
	for i,v in ipairs(生命药水) do
		local cb = F3DCheckBox:new()
		if g_mobileMode then
			cb:setTitleFont("宋体,16")
			cb:setHeight(24)
		else
			cb:setHeight(20)
		end
		cb:setTitleText(v[1])
		cb:setTitleArea("2,0,0,0")
		ui.优先使用药品生命2:getList():addItem(cb)
	end
	ui.优先使用药品魔法1 = tt(ui:findComponent("优先使用药品2,textinput_1"),F3DTextInput)
	ui.优先使用药品魔法2 = tt(ui:findComponent("优先使用药品2,combo_1"),F3DCombo)
	for i,v in ipairs(魔法药水) do
		local cb = F3DCheckBox:new()
		if g_mobileMode then
			cb:setTitleFont("宋体,16")
			cb:setHeight(24)
		else
			cb:setHeight(20)
		end
		cb:setTitleText(v[1])
		cb:setTitleArea("2,0,0,0")
		ui.优先使用药品魔法2:getList():addItem(cb)
	end
	ui.英雄使用药品生命1 = tt(ui:findComponent("英雄使用药品1,textinput_1"),F3DTextInput)
	ui.英雄使用药品生命2 = tt(ui:findComponent("英雄使用药品1,combo_1"),F3DCombo)
if 游戏设置.USESECONDDRUG then
for i,v in ipairs(英雄生命药水)do
local cb=F3DCheckBox:new()
if g_mobileMode then
cb:setTitleFont("宋体,16")
cb:setHeight(24)
else
cb:setHeight(20)
end
cb:setTitleText(v[1])
cb:setTitleArea("2,0,0,0")
ui.英雄使用药品生命2:getList():addItem(cb)
end
else
	for i,v in ipairs(生命药水) do
		local cb = F3DCheckBox:new()
		if g_mobileMode then
			cb:setTitleFont("宋体,16")
			cb:setHeight(24)
		else
			cb:setHeight(20)
		end
		cb:setTitleText(v[1])
		cb:setTitleArea("2,0,0,0")
		ui.英雄使用药品生命2:getList():addItem(cb)
	end
end
	ui.英雄使用药品魔法1 = tt(ui:findComponent("英雄使用药品2,textinput_1"),F3DTextInput)
	ui.英雄使用药品魔法2 = tt(ui:findComponent("英雄使用药品2,combo_1"),F3DCombo)
if 游戏设置.USESECONDDRUG then
	for i,v in ipairs(魔法药水) do
		local cb = F3DCheckBox:new()
		if g_mobileMode then
			cb:setTitleFont("宋体,16")
			cb:setHeight(24)
		else
			cb:setHeight(20)
		end
		cb:setTitleText(v[1])
		cb:setTitleArea("2,0,0,0")
		ui.英雄使用药品魔法2:getList():addItem(cb)
end
else
for i,v in ipairs(魔法药水)do
local cb=F3DCheckBox:new()
if g_mobileMode then
cb:setTitleFont("宋体,16")
cb:setHeight(24)
else
cb:setHeight(20)
end
cb:setTitleText(v[1])
cb:setTitleArea("2,0,0,0")
ui.英雄使用药品魔法2:getList():addItem(cb)
end
	end
	ui.自动使用物品1 = tt(ui:findComponent("自动使用物品,textinput_1"),F3DTextInput)
	ui.自动使用物品2 = tt(ui:findComponent("自动使用物品,combo_1"),F3DCombo)
	for i,v in ipairs(物品列表) do
		local cb = F3DCheckBox:new()
		if g_mobileMode then
			cb:setTitleFont("宋体,16")
			cb:setHeight(24)
		else
			cb:setHeight(20)
		end
		cb:setTitleText(v[1])
		cb:setTitleArea("2,0,0,0")
		ui.自动使用物品2:getList():addItem(cb)
	end
	ui.自动使用合击 = tt(ui:findComponent("自动使用合击,checkbox_1"),F3DCheckBox)
	ui.自动分解宠物白 = tt(ui:findComponent("自动分解宠物蛋,checkbox_1"),F3DCheckBox)
	ui.自动分解宠物绿 = tt(ui:findComponent("自动分解宠物蛋,checkbox_2"),F3DCheckBox)
	ui.自动分解宠物蓝 = tt(ui:findComponent("自动分解宠物蛋,checkbox_3"),F3DCheckBox)
	ui.自动分解宠物紫 = tt(ui:findComponent("自动分解宠物蛋,checkbox_4"),F3DCheckBox)
	ui.自动分解宠物橙 = tt(ui:findComponent("自动分解宠物蛋,checkbox_5"),F3DCheckBox)
	ui.自动孵化宠物蛋 = tt(ui:findComponent("自动孵化宠物蛋,checkbox_1"),F3DCheckBox)
	ui.物品自动拾取 = tt(ui:findComponent("物品自动拾取,checkbox_1"),F3DCheckBox)
	ui.自动拾取品质白 = tt(ui:findComponent("自动拾取品质,checkbox_1"),F3DCheckBox)
	ui.自动拾取品质绿 = tt(ui:findComponent("自动拾取品质,checkbox_2"),F3DCheckBox)
	ui.自动拾取品质蓝 = tt(ui:findComponent("自动拾取品质,checkbox_3"),F3DCheckBox)
	ui.自动拾取品质紫 = tt(ui:findComponent("自动拾取品质,checkbox_4"),F3DCheckBox)
	ui.自动拾取品质橙 = tt(ui:findComponent("自动拾取品质,checkbox_5"),F3DCheckBox)
	ui.自动拾取金币 = tt(ui:findComponent("自动拾取品质,checkbox_6"),F3DCheckBox)
	ui.怪物简装 = tt(ui:findComponent("自动拾取品质,checkbox_7"),F3DCheckBox)
	ui.人物简装 = tt(ui:findComponent("自动拾取品质,checkbox_8"),F3DCheckBox)
	ui.自动拾取等级 = tt(ui:findComponent("自动拾取等级,textinput_1"),F3DTextInput)
	ui.挂机怪物数量 = tt(ui:findComponent("挂机使用物品,textinput_1"),F3DTextInput)
	ui.挂机使用物品 = tt(ui:findComponent("挂机使用物品,combo_1"),F3DCombo)
	for i,v in ipairs(物品列表) do
		local cb = F3DCheckBox:new()
		if g_mobileMode then
			cb:setTitleFont("宋体,16")
			cb:setHeight(24)
		else
			cb:setHeight(20)
		end
		cb:setTitleText(v[1])
		cb:setTitleArea("2,0,0,0")
		ui.挂机使用物品:getList():addItem(cb)
	end
	
	if VIPLEVEL < 5 then
		ui:findComponent("自动拾取品质"):setVisible(false)
		ui:findComponent("自动拾取等级"):setVisible(false)
		ui:findComponent("挂机使用物品"):setVisible(false)
	end
	ui:findComponent("确定"):addEventListener(F3DMouseEvent.CLICK, func_me(onOK))
	ui:findComponent("取消"):addEventListener(F3DMouseEvent.CLICK, func_me(onClose))
_v_251("辅助UI",ui)
	m_init = true
	update()
end

function isHided()
	return not ui or not ui:isVisible() or ui.tweenhide
end

function hideUI()
	if ui then
		_v_62(ui,false)
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
_v_62(ui,true)
		return
	end
	ui = F3DLayout:new()
	uiLayer:addChild(ui)
	ui:setLoadPriority(getUIPriority())
	ui:setMovable(true)
	ui:addEventListener(F3DObjEvent.OBJ_INITED, func_e(onUIInit))
if ui.setUIPack and USEUIPACK then
ui:setUIPack(g_mobileMode and UIPATH.."辅助UIm.pack"or UIPATH.."辅助UI.pack")
else
ui:setLayout(g_mobileMode and UIPATH.."辅助UIm.layout" or UIPATH.."辅助UI.layout")
end
	
end
