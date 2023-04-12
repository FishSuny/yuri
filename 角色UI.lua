module(..., package.seeall)
 
local 全局设置 = require("公用.全局设置")
local 游戏设置 = require("公用.游戏设置")
local 实用工具 = require("公用.实用工具")
local 消息 = require("网络.消息")
local 角色逻辑 = require("主界面.角色逻辑")
local 装备提示UI = require("主界面.装备提示UI")
local 锻造UI = require("主界面.锻造UI")
local 物品内观表 = require("配置.物品内观表").Config
local 背包UI = require("主界面.背包UI")
local 英雄信息UI = require("主界面.英雄信息UI")
local 技能UI = require("技能.技能UI")

m_init = false
m_downposx = 0
m_avt = nil
m_rolejob = 0
m_rolesex = 0
m_bodyid = 0
m_weaponid = 0
m_bodyeff = 0
m_weaponeff = 0
m_itemdata = nil
m_tabid = 0
m_tabid2 = 0
tipsui = nil
tipsgrid = nil
英雄角色逻辑 = {}
英雄物品数据 = {}
显示内观 = true
m_剩余点数 = 0
m_英雄剩余点数 = 0
m_内功等级 = 0
m_内功经验 = nil
m_内功信息 = nil
m_内功需求 = ""
m_称号当前页 = 1
m_称号当前索引 = 1
m_称号信息 = nil
m_称号获得索引 = nil
m_称号排序信息 = {}
EQUIPMAX = 35 

function setInternalInfo(是否英雄,等级,经验,信息,需求)
if#信息==0 and 等级~=m_内功等级 then
m_内功等级=等级
消息.CG_INTERNAL_QUERY(0)
return
elseif#信息==0 and m_内功经验 then
m_内功经验[1]=经验[1]or 0
else
m_内功等级=等级
m_内功经验=经验
m_内功信息=信息
m_内功需求=需求
end
updateInternal()
end

function updateInternal()
if not m_init or not 游戏设置.MIRROLEPANEL or not ui.panels or not ui.panels[4][1]or m_内功信息==nil then
return
end
ui.内功等级:setTitleText(txt("内功等级: ")..m_内功等级..(m_内功经验[2]and" -> "..(m_内功等级+1)or""))
ui.内功经验:setTextColor(m_内功经验[1]>=(m_内功经验[2]or 0)and 0xFF00 or 0xFF0000)
ui.内功经验:setTitleText(txt("内功经验: ")..m_内功经验[1]..(m_内功经验[2]and" / "..m_内功经验[2]or""))
ui.内功生命值:setTitleText(txt("生命值: ")..m_内功信息[1][1]..
((m_内功信息[2]and m_内功信息[2][1]>0)and" -> "..(m_内功信息[1][1]+m_内功信息[2][1])or""))
ui.内功魔法值:setTitleText(txt("魔法值: ")..m_内功信息[1][2]..
((m_内功信息[2]and m_内功信息[2][2]>0)and" -> "..(m_内功信息[1][2]+m_内功信息[2][2])or""))
ui.内功防御:setTitleText(txt("防御: ")..m_内功信息[1][3].."-"..m_内功信息[1][4]..
((m_内功信息[2]and(m_内功信息[2][3]>0 or m_内功信息[2][4]>0))and" -> "..(m_内功信息[1][3]+m_内功信息[2][3]).."-"..(m_内功信息[1][4]+m_内功信息[2][4])or""))
ui.内功魔御:setTitleText(txt("魔御: ")..m_内功信息[1][5].."-"..m_内功信息[1][6]..
((m_内功信息[2]and(m_内功信息[2][5]>0 or m_内功信息[2][6]>0))and" -> "..(m_内功信息[1][5]+m_内功信息[2][5]).."-"..(m_内功信息[1][6]+m_内功信息[2][6])or""))
ui.内功攻击:setTitleText(txt("攻击: ")..m_内功信息[1][7].."-"..m_内功信息[1][8]..
((m_内功信息[2]and(m_内功信息[2][7]>0 or m_内功信息[2][8]>0))and" -> "..(m_内功信息[1][7]+m_内功信息[2][7]).."-"..(m_内功信息[1][8]+m_内功信息[2][8])or""))
ui.内功魔法:setTitleText(txt("魔法: ")..m_内功信息[1][9].."-"..m_内功信息[1][10]..
((m_内功信息[2]and(m_内功信息[2][9]>0 or m_内功信息[2][10]>0))and" -> "..(m_内功信息[1][9]+m_内功信息[2][9]).."-"..(m_内功信息[1][10]+m_内功信息[2][10])or""))
ui.内功道术:setTitleText(txt("道术: ")..m_内功信息[1][11].."-"..m_内功信息[1][12]..
((m_内功信息[2]and(m_内功信息[2][11]>0 or m_内功信息[2][12]>0))and" -> "..(m_内功信息[1][11]+m_内功信息[2][11]).."-"..(m_内功信息[1][12]+m_内功信息[2][12])or""))
ui.内功需求:setTitleText(txt("需求: "..m_内功需求))
end

function setTitleInfo(是否英雄,信息,获得索引)
if#信息>0 then
m_称号信息=信息
end
m_称号获得索引=获得索引
if m_称号信息 then
实用工具.DeleteTable(m_称号排序信息)
local index=1
for i,v in ipairs(m_称号信息)do
if 实用工具.FindIndex(m_称号获得索引,v[1])then
table.insert(m_称号排序信息,index,v)
index=index+1
else
m_称号排序信息[#m_称号排序信息+1]=v
end
end
end
updateTitle()
end

function updateTitle()
if not m_init or not 游戏设置.MIRROLEPANEL or not ui.panels or not ui.panels[4][1]or m_称号信息==nil then
return
end
local index=(m_称号当前页-1)*6+m_称号当前索引
ui.称号选中:setPositionY(ui.称号格子[m_称号当前索引]:getPositionY()-(ui.称号选中:getHeight()-ui.称号格子[m_称号当前索引]:getHeight())/2)
if m_称号排序信息[index]then
ui.称号选中格子.grid:setTextureFile(全局设置.getItemIconUrl(m_称号排序信息[index][2]))
if m_称号排序信息[index][3]==-1 then
ui.称号选中动画.grid:setTextureFile("")
ui.称号选中动画.effect:reset()
ui.称号选中动画:setTitleText(txt(m_称号排序信息[index][4]))
elseif m_称号排序信息[index][3]>=1000 then
ui.称号选中动画.grid:setTextureFile("")
ui.称号选中动画.effect:setAnimPack(全局设置.getAnimPackUrl(m_称号排序信息[index][3]))
ui.称号选中动画:setTitleText("")
v=物品内观表[m_称号排序信息[index][3]]
if v then
ui.称号选中动画.effect:setPositionX(math.floor(ui.称号选中动画:getWidth()/2)+v.偏移X+游戏设置.偏移X)
ui.称号选中动画.effect:setPositionY(math.floor(ui.称号选中动画:getHeight()/2)+v.偏移Y+游戏设置.偏移Y)
else
ui.称号选中动画.effect:setPositionX(math.floor(ui.称号选中动画:getWidth()/2))
ui.称号选中动画.effect:setPositionY(math.floor(ui.称号选中动画:getHeight()/2))
end
else
ui.称号选中动画.effect:reset()
ui.称号选中动画.grid:setTextureFile(全局设置.getIconIconUrl(m_称号排序信息[index][3]))
ui.称号选中动画:setTitleText("")
end
ui.称号名称:setTitleText(txt("名称: "..m_称号排序信息[index][4]))
ui.称号生命值:setTitleText(txt("生命值: ")..m_称号排序信息[index][5])
ui.称号魔法值:setTitleText(txt("魔法值: ")..m_称号排序信息[index][6])
ui.称号防御:setTitleText(txt("防御: ")..m_称号排序信息[index][7].."-"..m_称号排序信息[index][8])
ui.称号魔御:setTitleText(txt("魔御: ")..m_称号排序信息[index][9].."-"..m_称号排序信息[index][10])
ui.称号攻击:setTitleText(txt("攻击: ")..m_称号排序信息[index][11].."-"..m_称号排序信息[index][12])
ui.称号魔法:setTitleText(txt("魔法: ")..m_称号排序信息[index][13].."-"..m_称号排序信息[index][14])
ui.称号道术:setTitleText(txt("道术: ")..m_称号排序信息[index][15].."-"..m_称号排序信息[index][16])
ui.称号来源:setTitleText(txt(m_称号排序信息[index][17]))
else
ui.称号选中格子.grid:setTextureFile("")
ui.称号选中动画.grid:setTextureFile("")
ui.称号选中动画.effect:reset()
ui.称号名称:setTitleText(txt("名称: "))
ui.称号生命值:setTitleText(txt("生命值: "))
ui.称号魔法值:setTitleText(txt("魔法值: "))
ui.称号防御:setTitleText(txt("防御: "))
ui.称号魔御:setTitleText(txt("魔御: "))
ui.称号攻击:setTitleText(txt("攻击: "))
ui.称号魔法:setTitleText(txt("魔法: "))
ui.称号道术:setTitleText(txt("道术: "))
ui.称号来源:setTitleText("")
end
for i=1,6 do
v=m_称号排序信息[(m_称号当前页-1)*6+i]
if v then
ui.称号格子[i].index=v[1]
ui.称号格子[i].grid:setTextureFile(全局设置.getItemIconUrl(v[2]))
ui.称号格子[i].grid:setShaderType(not 实用工具.FindIndex(m_称号获得索引,v[1])and F3DImage.SHADER_GRAY or F3DImage.SHADER_NULL)
if v[3]==-1 then
ui.称号动画[i].grid:setTextureFile("")
ui.称号动画[i].effect:reset()
ui.称号动画[i]:setTitleText(txt(v[4]))
elseif v[3]>=1000 then
ui.称号动画[i].grid:setTextureFile("")
ui.称号动画[i].effect:setAnimPack(全局设置.getAnimPackUrl(v[3]))
ui.称号动画[i].effect:setShaderType(not 实用工具.FindIndex(m_称号获得索引,v[1])and F3DImage.SHADER_GRAY or F3DImage.SHADER_NULL)
ui.称号动画[i]:setTitleText("")
vv=物品内观表[v[3]]
if vv then
ui.称号动画[i].effect:setPositionX(math.floor(ui.称号动画[i]:getWidth()/2)+vv.偏移X+游戏设置.偏移X)
ui.称号动画[i].effect:setPositionY(math.floor(ui.称号动画[i]:getHeight()/2)+vv.偏移Y+游戏设置.偏移Y)
else
ui.称号动画[i].effect:setPositionX(math.floor(ui.称号动画[i]:getWidth()/2))
ui.称号动画[i].effect:setPositionY(math.floor(ui.称号动画[i]:getHeight()/2))
end
else
ui.称号动画[i].effect:reset()
ui.称号动画[i].grid:setTextureFile(全局设置.getIconIconUrl(v[3]))
ui.称号动画[i].grid:setShaderType(not 实用工具.FindIndex(m_称号获得索引,v[1])and F3DImage.SHADER_GRAY or F3DImage.SHADER_NULL)
ui.称号动画[i]:setTitleText("")
end
else
ui.称号格子[i].index=nil
ui.称号格子[i].grid:setTextureFile("")
ui.称号动画[i].grid:setTextureFile("")
ui.称号动画[i].effect:reset()
ui.称号动画[i]:setTitleText("")
end
end
local totalpage=math.max(1,math.ceil(#m_称号信息/6))
ui.称号页数:setTitleText(m_称号当前页.." / "..totalpage)
end

function setAddPointCnt(剩余点数, 英雄剩余点数)
	m_剩余点数 = 剩余点数
	m_英雄剩余点数 = 英雄剩余点数
	update()
end

function setTabID(tabid)
	if m_tabid == tabid then
		return
	end
	m_tabid = tabid
	if m_init then
		ui.tab:setSelectIndex(m_tabid)
	end
end

function setTabID2(tabid)
	if m_tabid2 == tabid then
		return
	end
	m_tabid2 = tabid
	if m_init then
		ui.tab2:setSelectIndex(m_tabid2)
	end
end

function setOnlyHeroEquipData(itemdata)
	for i,v in ipairs(itemdata) do
		英雄物品数据[v[1]] = {
			pos=v[1],
			id=v[2],
			name=v[3],
			desc=v[4],
			type=v[5],
			count=v[6],
			icon=v[7],
			cd=v[8]+rtime(),
			cdmax=v[9],
			bind=v[10],
			grade=v[11],
			job=v[12],
			level=v[13],
			strengthen=v[14],
			prop=v[15],
			addprop=v[16],
			attachprop=v[17],
			gemprop=v[18],
			ringsoul=v[19],
			power=v[20],
			equippos=v[21],
			color=v[22],
			suitprop=v[23],
			suitname=v[24],
			runeprop=v[25],
		}
	end
	updateEquips()
	锻造UI.update()
end

function setHeroEquipData(guildname,rolename,objid,level,job,sex,expmax,exp,bodyid,weaponid,wingid,horseid,bodyeff,weaponeff,wingeff,horseeff,hpmax,mpmax,speed,power,suitcnts,转生等级,防御,防御上限,魔御,魔御上限,攻击,攻击上限,魔法,魔法上限,道术,道术上限,幸运,准确,敏捷,魔法命中,魔法躲避,生命恢复,魔法恢复,中毒恢复,攻击速度,移动速度,itemdata)
	英雄角色逻辑 = {

		m_rolename = rolename,
		m_guildname = guildname,
		m_rolejob = job,
		m_rolesex = sex,
		m_expmax = expmax < 0 and 0x7fffffff-expmax or expmax,
		m_exp = exp < 0 and 0x7fffffff - exp or exp,
		m_bodyid = bodyid,
		m_weaponid = weaponid,
		m_wingid = wingid,
		m_horseid = horseid,
		m_bodyeff = bodyeff,
		m_weaponeff = weaponeff,
		m_wingeff = wingeff,
		m_horseeff = horseeff,
		m_level = level,
		m_hpmax = hpmax,
		m_mpmax = mpmax,
		m_speed = speed,
		m_power = power,
m_suitcnts=suitcnts,
		m_转生等级 = 转生等级,
		m_防御 = 防御,
		m_防御上限 = 防御上限,
		m_魔御 = 魔御,
		m_魔御上限 = 魔御上限,
		m_攻击 = 攻击,
		m_攻击上限 = 攻击上限,
		m_魔法 = 魔法,
		m_魔法上限 = 魔法上限,
		m_道术 = 道术,
		m_道术上限 = 道术上限,
		m_幸运 = 幸运,
		m_准确 = 准确,
		m_敏捷 = 敏捷,
		m_魔法命中 = 魔法命中,
		m_魔法躲避 = 魔法躲避,
		m_生命恢复 = 生命恢复,
		m_魔法恢复 = 魔法恢复,
		m_中毒恢复 = 中毒恢复,
		m_攻击速度 = 攻击速度,
		m_移动速度 = 移动速度,
	}
	英雄物品数据 = {}
	for i,v in ipairs(itemdata) do
		英雄物品数据[v[1]] = {
		pos=v[1],
		id=v[2],
		name=v[3],
		desc=v[4],
		type=v[5],
		count=v[6],
		icon=v[7],
		cd=v[8]+rtime(),
		cdmax=v[9],
		bind=v[10],
		grade=v[11],
		job=v[12],
		level=v[13],
		strengthen=v[14],
		prop=v[15],
		addprop=v[16],
		attachprop=v[17],
		gemprop=v[18],
		ringsoul=v[19],
		power=v[20],
		equippos=v[21],
		color=v[22],
		suitprop=v[23],
		suitname=v[24],
		runeprop=v[25],
		}
	end
	update()
	updateEquips()
	锻造UI.update()	 
end

function setEquipData(op, itemdata)
	if not m_itemdata then
		m_itemdata = {}
	elseif op == 0 then
		m_itemdata = {}
	end
	for i,v in ipairs(itemdata) do
		m_itemdata[v[1]] = {
			pos=v[1],
			id=v[2],
			name=v[3],
			desc=v[4],
			type=v[5],
			count=v[6],
			icon=v[7],
			cd=v[8]+rtime(),
			cdmax=v[9],
			bind=v[10],
			grade=v[11],
			job=v[12],
			level=v[13],
			strengthen=v[14],
			prop=v[15],
			addprop=v[16],
			attachprop=v[17],
			gemprop=v[18],
			ringsoul=v[19],
			power=v[20],
			equippos=v[21],
			color=v[22],
			suitprop=v[23],
			suitname=v[24],
			runeprop=v[25],
			typeex=v[26],
		}
	end
	updateEquips()
	锻造UI.update()
end

function updateEquips()
	local itemdata = m_tabid == 1 and 英雄物品数据 or m_itemdata
	if not m_init or itemdata == nil then
		return
	end
	for i=1,EQUIPMAX do
		local v = itemdata[i]
		if v and ui.equips[i] then
			local 发光特效 = 0
			local 持久 = 0
			local 持久上限 = 0
			for ii,vv in ipairs(v.prop) do
				if vv[1] == 46 then
					发光特效 = vv[2]
				elseif vv[1] == 49 then
					持久 = vv[2]
				elseif vv[1] == 50 then
					持久上限 = vv[2]
				end
			end
			for ii,vv in ipairs(v.addprop) do
				if vv[1] == 46 then
					发光特效 = vv[2]
				elseif vv[1] == 49 then
					持久 = vv[2]
				elseif vv[1] == 50 then
					持久上限 = vv[2]
			end
		end
		if 发光特效 ~= 0 then
			if not ui.equips[i].effect then
				ui.equips[i].effect = F3DImageAnim:new()
				ui.equips[i].effect:setBlendType(F3DRenderContext.BLEND_ADD)
				ui.equips[i]:addChild(ui.equips[i].effect)
			end
			ui.equips[i].effect:setAnimPack(全局设置.getAnimPackUrl(发光特效))
		elseif ui.equips[i].effect then
			ui.equips[i].effect:reset()
		end
		ui.equips[i].id=v.pos
		ui.equips[i]:setTextureFile(全局设置.getItemIconUrl(v.icon))
		ui.equips[i].grade:setTextureFile(全局设置.getGradeUrl(v.grade))
		ui.equips[i].lock:setTextureFile(v.bind == 1 and UIPATH.."公用/grid/img_bind.png"or"")
		ui.equips[i].strengthen:setText(v.strengthen>0 and"+"..v.strengthen or"")
		local gray  =  持久上限 > 0 and 持久  >=  持久上限
		ui.equips[i]:setShaderType(gray and F3DImage.SHADER_GRAY or F3DImage.SHADER_NULL)
	elseif ui.equips[i]then
		if ui.equips[i].effect then
			ui.equips[i].effect:reset()
		end
		ui.equips[i].id = 0
		ui.equips[i]:setTextureFile("")
		ui.equips[i].grade:setTextureFile("")
		ui.equips[i].lock:setTextureFile("")
		ui.equips[i].strengthen:setText("")
		ui.equips[i]:setShaderType(F3DImage.SHADER_NULL)
		end
	end
	更新内观()
end

function checkEquipPos(px,py)
	if not m_init or isHided()then return end
	local x = px - ui:getPositionX()
	local y = py - ui:getPositionY()
		for i=1,EQUIPMAX do
			local equipbg = ui:findComponent("equippos_"..i)
			if equipbg and x  >= equipbg:getPositionX()and x  <= equipbg:getPositionX() + equipbg:getWidth() and
				y  >= equipbg:getPositionY() and y  <= equipbg:getPositionY() + equipbg:getHeight() then
				return i
			end
		end
end

function 更新内观()
	local itemdata = m_tabid == 1 and 英雄物品数据 or m_itemdata
	local 显示时装 = m_tabid == 1 and 角色逻辑.m_英雄显示时装 or 角色逻辑.m_显示时装
	local 显示炫武 = m_tabid == 1 and 角色逻辑.m_英雄显示炫武 or 角色逻辑.m_显示炫武
	local 逻辑 = m_tabid == 1 and 英雄角色逻辑 or 角色逻辑
if not m_init or itemdata==nil then
		return
	end
	if 显示内观 then
		if m_avt then
			m_avt:setVisible(false)
		end
		local 时装武器 = false
		ui.内观位置:setVisible(not 游戏设置.MIRROLEPANEL or m_tabid2 == 0 or m_tabid2 == 1)
		ui.rolename = ui.rolename and ui:findComponent("内观位置,rolename") or ui:findComponent("rolename")
		if((not 游戏设置.MIRROLEPANEL and 显示炫武 == 1)or(游戏设置.MIRROLEPANEL and m_tabid2 == 1))and itemdata[27]and itemdata[27].count>0 and 物品内观表[游戏设置.ICONUSEID and itemdata[27].id or 全局设置.getFixedID(itemdata[27].icon)]then
		local 物品内观 = 物品内观表[游戏设置.ICONUSEID and itemdata[27].id or 全局设置.getFixedID(itemdata[27].icon)]
			ui.武器位置:setTextureFile(全局设置.getStateItemIconUrl(物品内观.图标ID))
			ui.武器位置:setPositionX(物品内观.偏移X+游戏设置.偏移X)
			ui.武器位置:setPositionY(物品内观.偏移Y+游戏设置.偏移Y)
			ui.武器背景:setTextureFile(全局设置.getStateItemIconUrl(物品内观.背景图片))
			ui.武器背景:setPositionX(物品内观.背景偏移X+游戏设置.偏移X)
			ui.武器背景:setPositionY(物品内观.背景偏移Y+游戏设置.偏移Y)
			ui.武器特效:setBlendType(物品内观.图标ID <= 0 and F3DRenderContext.BLEND_NORMAL or F3DRenderContext.BLEND_ADD)
			if 物品内观.特效ID ~= 0 then
				ui.武器特效:setAnimPack(全局设置.getAnimPackUrl(物品内观.特效ID))
				ui.武器特效:setPositionX(物品内观.图标ID<=0 and 物品内观.偏移X+游戏设置.偏移X or 物品内观.背景偏移X+游戏设置.偏移X)
				ui.武器特效:setPositionY(物品内观.图标ID<=0 and 物品内观.偏移Y+游戏设置.偏移Y or 物品内观.背景偏移Y+游戏设置.偏移Y)
			else
				ui.武器特效:reset()
			end
			时装武器 = true
		elseif(not 游戏设置.MIRROLEPANEL or m_tabid2 == 0)and itemdata[1]and itemdata[1].count>0 and 物品内观表[游戏设置.ICONUSEID and itemdata[1].id or 全局设置.getFixedID(itemdata[1].icon)]then
			local 物品内观 = 物品内观表[游戏设置.ICONUSEID and itemdata[1].id or 全局设置.getFixedID(itemdata[1].icon)]
			ui.武器位置:setTextureFile(全局设置.getStateItemIconUrl(物品内观.图标ID))
			ui.武器位置:setPositionX(物品内观.偏移X+游戏设置.偏移X)
			ui.武器位置:setPositionY(物品内观.偏移Y+游戏设置.偏移Y)
			ui.武器背景:setTextureFile(全局设置.getStateItemIconUrl(物品内观.背景图片))
			ui.武器背景:setPositionX(物品内观.背景偏移X+游戏设置.偏移X)
			ui.武器背景:setPositionY(物品内观.背景偏移Y+游戏设置.偏移Y)
			ui.武器特效:setBlendType(物品内观.图标ID  <= 0 and F3DRenderContext.BLEND_NORMAL or F3DRenderContext.BLEND_ADD)
			if 物品内观.特效ID ~= 0 then
				ui.武器特效:setAnimPack(全局设置.getAnimPackUrl(物品内观.特效ID))
				ui.武器特效:setPositionX(物品内观.图标ID<=0 and 物品内观.偏移X+游戏设置.偏移X or 物品内观.背景偏移X+游戏设置.偏移X)
				ui.武器特效:setPositionY(物品内观.图标ID<=0 and 物品内观.偏移Y+游戏设置.偏移Y or 物品内观.背景偏移Y+游戏设置.偏移Y)
			else
				ui.武器特效:reset()
			end
		else
			ui.武器位置:setTextureFile("")
			ui.武器背景:setTextureFile("")
			ui.武器特效:reset()
		end
		if((not 游戏设置.MIRROLEPANEL and 显示时装 == 1)or(游戏设置.MIRROLEPANEL and m_tabid2 == 1))and itemdata[23]and itemdata[23].count>0 and 物品内观表[游戏设置.ICONUSEID and itemdata[23].id or 全局设置.getFixedID(itemdata[23].icon)]then
			local 物品内观 = 物品内观表[游戏设置.ICONUSEID and itemdata[23].id or 全局设置.getFixedID(itemdata[23].icon)]
			ui.衣服位置:setTextureFile(全局设置.getStateItemIconUrl(物品内观.图标ID))
			ui.衣服位置:setPositionX(物品内观.偏移X+游戏设置.偏移X)
			ui.衣服位置:setPositionY(物品内观.偏移Y+游戏设置.偏移Y)
			ui.衣服背景:setTextureFile(全局设置.getStateItemIconUrl(物品内观.背景图片))
			ui.衣服背景:setPositionX(物品内观.背景偏移X+游戏设置.偏移X)
			ui.衣服背景:setPositionY(物品内观.背景偏移Y+游戏设置.偏移Y)
			ui.衣服特效:setBlendType(物品内观.图标ID  <= 0 and F3DRenderContext.BLEND_NORMAL or F3DRenderContext.BLEND_ADD)
			if 物品内观.特效ID ~= 0 then
				ui.衣服特效:setAnimPack(全局设置.getAnimPackUrl(物品内观.特效ID))
				ui.衣服特效:setPositionX(物品内观.图标ID<=0 and 物品内观.偏移X+游戏设置.偏移X or 物品内观.背景偏移X+游戏设置.偏移X)
				ui.衣服特效:setPositionY(物品内观.图标ID<=0 and 物品内观.偏移Y+游戏设置.偏移Y or 物品内观.背景偏移Y+游戏设置.偏移Y)
			else
				ui.衣服特效:reset()
			end
			ui.男:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2 == 0)and 物品内观.图标ID >= 0 and 逻辑.m_rolesex == 1)
			ui.女:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2 == 0)and 物品内观.图标ID >= 0 and 逻辑.m_rolesex == 2)
			ui.头盔位置:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2 == 0)and 物品内观.图标ID >= 0)
			ui.斗笠位置:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2 == 0)and 物品内观.图标ID >= 0)
			ui.面巾位置:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2 == 0)and 物品内观.图标ID >= 0)
			ui.盾牌位置:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2 == 0)and 物品内观.图标ID >= 0)
			ui.盾牌特效:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2 == 0)and 物品内观.图标ID >= 0)
			ui.武器位置:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2 == 0 or 时装武器)and 物品内观.图标ID >= 0)
			ui.武器背景:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2 == 0 or 时装武器)and 物品内观.图标ID >= 0)
			ui.武器特效:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2 == 0 or 时装武器)and 物品内观.图标ID >= 0)
			ui.翅膀位置:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2 == 0)and 物品内观.图标ID >= 0)
			ui.翅膀特效:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2 == 0)and 物品内观.图标ID >= 0)
			elseif(not 游戏设置.MIRROLEPANEL or m_tabid2 == 0)and itemdata[2]and itemdata[2].count>0 and 物品内观表[游戏设置.ICONUSEID and itemdata[2].id or 全局设置.getFixedID(itemdata[2].icon)]then
			local 物品内观 = 物品内观表[游戏设置.ICONUSEID and itemdata[2].id or 全局设置.getFixedID(itemdata[2].icon)]
			ui.衣服位置:setTextureFile(全局设置.getStateItemIconUrl(物品内观.图标ID))
			ui.衣服位置:setPositionX(物品内观.偏移X+游戏设置.偏移X)
			ui.衣服位置:setPositionY(物品内观.偏移Y+游戏设置.偏移Y)
			ui.衣服背景:setTextureFile(全局设置.getStateItemIconUrl(物品内观.背景图片))
			ui.衣服背景:setPositionX(物品内观.背景偏移X+游戏设置.偏移X)
			ui.衣服背景:setPositionY(物品内观.背景偏移Y+游戏设置.偏移Y)
			ui.衣服特效:setBlendType(物品内观.图标ID <= 0 and F3DRenderContext.BLEND_NORMAL or F3DRenderContext.BLEND_ADD)
			if 物品内观.特效ID ~= 0 then
				ui.衣服特效:setAnimPack(全局设置.getAnimPackUrl(物品内观.特效ID))
				ui.衣服特效:setPositionX(物品内观.图标ID<=0 and 物品内观.偏移X+游戏设置.偏移X or 物品内观.背景偏移X+游戏设置.偏移X)
				ui.衣服特效:setPositionY(物品内观.图标ID<=0 and 物品内观.偏移Y+游戏设置.偏移Y or 物品内观.背景偏移Y+游戏设置.偏移Y)
			else
				ui.衣服特效:reset()
			end
			ui.男:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2 == 0)and 物品内观.图标ID >= 0 and 逻辑.m_rolesex == 1)
			ui.女:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2 == 0)and 物品内观.图标ID >= 0 and 逻辑.m_rolesex == 2)
			ui.头盔位置:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2 == 0)and 物品内观.图标ID >= 0)
			ui.斗笠位置:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2 == 0)and 物品内观.图标ID >= 0)
			ui.面巾位置:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2 == 0)and 物品内观.图标ID >= 0)
			ui.盾牌位置:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2 == 0)and 物品内观.图标ID >= 0)
			ui.盾牌特效:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2 == 0)and 物品内观.图标ID >= 0)
			ui.武器位置:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2 == 0)and 物品内观.图标ID >= 0)
			ui.武器背景:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2 == 0)and 物品内观.图标ID >= 0)
			ui.武器特效:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2 == 0)and 物品内观.图标ID >= 0)
			ui.翅膀位置:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2 == 0)and 物品内观.图标ID >= 0)
			ui.翅膀特效:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2 == 0)and 物品内观.图标ID >= 0)
		else
			ui.衣服位置:setTextureFile("")
			ui.衣服背景:setTextureFile("")
			ui.衣服特效:reset()
			ui.男:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2 == 0)and 逻辑.m_rolesex == 1)
			ui.女:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2 == 0)and 逻辑.m_rolesex == 2)
			ui.头盔位置:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2 == 0)and true)
			ui.斗笠位置:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2 == 0)and true)
			ui.面巾位置:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2 == 0)and true)
			ui.盾牌位置:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2 == 0)and true)
			ui.盾牌特效:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2 == 0)and true)
			ui.武器位置:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2 == 0)and true)
			ui.武器背景:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2 == 0)and true)
			ui.武器特效:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2 == 0)and true)
			ui.翅膀位置:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2 == 0)and true)
			ui.翅膀特效:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2 == 0)and true)
			end
		if 游戏设置.MIRROLEPANEL and itemdata[11] and itemdata[11].count > 0 and 物品内观表[游戏设置.ICONUSEID and itemdata[11].id or 全局设置.getFixedID(itemdata[11].icon)]then
			local 物品内观 = 物品内观表[游戏设置.ICONUSEID and itemdata[11].id or 全局设置.getFixedID(itemdata[11].icon)]
				ui.头盔位置:setTextureFile(全局设置.getStateItemIconUrl(物品内观.图标ID))
				ui.头盔位置:setPositionX(物品内观.偏移X+游戏设置.偏移X)
				ui.头盔位置:setPositionY(物品内观.偏移Y+游戏设置.偏移Y)	
				
		elseif itemdata[3] and itemdata[3].count > 0 and 物品内观表[游戏设置.ICONUSEID and itemdata[3].id or 全局设置.getFixedID(itemdata[3].icon)]then
			local 物品内观 = 物品内观表[游戏设置.ICONUSEID and itemdata[3].id or 全局设置.getFixedID(itemdata[3].icon)]
				ui.头盔位置:setTextureFile(全局设置.getStateItemIconUrl(物品内观.图标ID))
				ui.头盔位置:setPositionX(物品内观.偏移X+游戏设置.偏移X)
				ui.头盔位置:setPositionY(物品内观.偏移Y+游戏设置.偏移Y)
				
			else
				ui.头盔位置:setTextureFile("")
				ui.斗笠位置:setTextureFile("")
			end
		if itemdata[12]and itemdata[12].count>0 and 物品内观表[游戏设置.ICONUSEID and itemdata[12].id or 全局设置.getFixedID(itemdata[12].icon)]then
			local 物品内观 = 物品内观表[游戏设置.ICONUSEID and itemdata[12].id or 全局设置.getFixedID(itemdata[12].icon)]
				ui.面巾位置:setTextureFile(全局设置.getStateItemIconUrl(物品内观.图标ID))
				ui.面巾位置:setPositionX(物品内观.偏移X+游戏设置.偏移X)
				ui.面巾位置:setPositionY(物品内观.偏移Y+游戏设置.偏移Y)
			else
				ui.面巾位置:setTextureFile("")
			end
		if itemdata[22]and itemdata[22].count>0 and 物品内观表[游戏设置.ICONUSEID and itemdata[22].id or 全局设置.getFixedID(itemdata[22].icon)]then
			local 物品内观 = 物品内观表[游戏设置.ICONUSEID and itemdata[22].id or 全局设置.getFixedID(itemdata[22].icon)]
			ui.盾牌位置:setTextureFile(全局设置.getStateItemIconUrl(物品内观.图标ID))
			ui.盾牌位置:setPositionX(物品内观.偏移X+游戏设置.偏移X)
			ui.盾牌位置:setPositionY(物品内观.偏移Y+游戏设置.偏移Y)
			ui.盾牌背景:setTextureFile(全局设置.getStateItemIconUrl(物品内观.背景图片))
			ui.盾牌背景:setPositionX(物品内观.背景偏移X+游戏设置.偏移X)
			ui.盾牌背景:setPositionY(物品内观.背景偏移Y+游戏设置.偏移Y)
			ui.盾牌特效:setBlendType(物品内观.图标ID <= 0 and F3DRenderContext.BLEND_NORMAL or F3DRenderContext.BLEND_ADD)
			if 物品内观.特效ID ~= 0 then
				ui.盾牌特效:setAnimPack(全局设置.getAnimPackUrl(物品内观.特效ID))
				ui.盾牌特效:setPositionX(物品内观.图标ID<=0 and 物品内观.偏移X+游戏设置.偏移X or 物品内观.背景偏移X+游戏设置.偏移X)
				ui.盾牌特效:setPositionY(物品内观.图标ID<=0 and 物品内观.偏移Y+游戏设置.偏移Y or 物品内观.背景偏移Y+游戏设置.偏移Y)
			else
				ui.盾牌特效:reset()
			end
		else
			ui.盾牌位置:setTextureFile("")
			ui.盾牌背景:setTextureFile("")
			ui.盾牌特效:reset()
		end
		if itemdata[24]and itemdata[24].count>0 and 物品内观表[游戏设置.ICONUSEID and itemdata[24].id or 全局设置.getFixedID(itemdata[24].icon)]then
			local 物品内观 = 物品内观表[游戏设置.ICONUSEID and itemdata[24].id or 全局设置.getFixedID(itemdata[24].icon)]
			ui.马牌位置:setTextureFile(全局设置.getStateItemIconUrl(物品内观.图标ID))
													  
			ui.马牌位置:setPositionX(物品内观.偏移X+游戏设置.偏移X)
			ui.马牌位置:setPositionY(物品内观.偏移Y+游戏设置.偏移Y)
			ui.马牌背景:setTextureFile(全局设置.getStateItemIconUrl(物品内观.背景图片))
			ui.马牌背景:setPositionX(物品内观.背景偏移X+游戏设置.偏移X)
			ui.马牌背景:setPositionY(物品内观.背景偏移Y+游戏设置.偏移Y)
			ui.马牌特效:setBlendType(物品内观.图标ID <= 0 and F3DRenderContext.BLEND_NORMAL or F3DRenderContext.BLEND_ADD)
			if 物品内观.特效ID ~= 0 then
				ui.马牌特效:setAnimPack(全局设置.getAnimPackUrl(物品内观.特效ID))
				ui.马牌特效:setPositionX(物品内观.图标ID<=0 and 物品内观.偏移X+游戏设置.偏移X or 物品内观.背景偏移X+游戏设置.偏移X)
				ui.马牌特效:setPositionY(物品内观.图标ID<=0 and 物品内观.偏移Y+游戏设置.偏移Y or 物品内观.背景偏移Y+游戏设置.偏移Y)
			else
				ui.马牌特效:reset()
			end
		else
			ui.马牌位置:setTextureFile("")
			ui.马牌背景:setTextureFile("")
			ui.马牌特效:reset()
		end
		if itemdata[25]and itemdata[25].count>0 and 物品内观表[游戏设置.ICONUSEID and itemdata[25].id or 全局设置.getFixedID(itemdata[25].icon)]then
			local 物品内观 = 物品内观表[游戏设置.ICONUSEID and itemdata[25].id or 全局设置.getFixedID(itemdata[25].icon)]
			ui.法宝位置:setTextureFile(全局设置.getStateItemIconUrl(物品内观.图标ID))
			ui.法宝位置:setPositionX(物品内观.偏移X+游戏设置.偏移X)
			ui.法宝位置:setPositionY(物品内观.偏移Y+游戏设置.偏移Y)
			ui.法宝背景:setTextureFile(全局设置.getStateItemIconUrl(物品内观.背景图片))
			ui.法宝背景:setPositionX(物品内观.背景偏移X+游戏设置.偏移X)
			ui.法宝背景:setPositionY(物品内观.背景偏移Y+游戏设置.偏移Y)
			ui.法宝特效:setBlendType(物品内观.图标ID <= 0 and F3DRenderContext.BLEND_NORMAL or F3DRenderContext.BLEND_ADD)
			if 物品内观.特效ID ~= 0 then
			ui.法宝特效:setAnimPack(全局设置.getAnimPackUrl(物品内观.特效ID))
			ui.法宝特效:setPositionX(物品内观.图标ID<=0 and 物品内观.偏移X+游戏设置.偏移X or 物品内观.背景偏移X+游戏设置.偏移X)
			ui.法宝特效:setPositionY(物品内观.图标ID<=0 and 物品内观.偏移Y+游戏设置.偏移Y or 物品内观.背景偏移Y+游戏设置.偏移Y)
			else
			ui.法宝特效:reset()
			end
		else
			ui.法宝位置:setTextureFile("")
			ui.法宝背景:setTextureFile("")
			ui.法宝特效:reset()
		end
		if itemdata[26]and itemdata[26].count>0 and 物品内观表[游戏设置.ICONUSEID and itemdata[26].id or 全局设置.getFixedID(itemdata[26].icon)]then
			local 物品内观 = 物品内观表[游戏设置.ICONUSEID and itemdata[26].id or 全局设置.getFixedID(itemdata[26].icon)]
			ui.翅膀位置:setTextureFile(全局设置.getStateItemIconUrl(物品内观.图标ID))
ui.翅膀位置:setPositionX(物品内观.偏移X+游戏设置.偏移X)
ui.翅膀位置:setPositionY(物品内观.偏移Y+游戏设置.偏移Y)
			ui.翅膀背景:setTextureFile(全局设置.getStateItemIconUrl(物品内观.背景图片))
ui.翅膀背景:setPositionX(物品内观.背景偏移X+游戏设置.偏移X)
ui.翅膀背景:setPositionY(物品内观.背景偏移Y+游戏设置.偏移Y)
			ui.翅膀特效:setBlendType(物品内观.图标ID <= 0 and F3DRenderContext.BLEND_NORMAL or F3DRenderContext.BLEND_ADD)
			if 物品内观.特效ID ~= 0 then
			ui.翅膀特效:setAnimPack(全局设置.getAnimPackUrl(物品内观.特效ID))
ui.翅膀特效:setPositionX(物品内观.图标ID<=0 and 物品内观.偏移X+游戏设置.偏移X or 物品内观.背景偏移X+游戏设置.偏移X)
ui.翅膀特效:setPositionY(物品内观.图标ID<=0 and 物品内观.偏移Y+游戏设置.偏移Y or 物品内观.背景偏移Y+游戏设置.偏移Y)
else
			ui.翅膀特效:reset()				  
			end  
		else
			ui.翅膀位置:setTextureFile("")
			ui.翅膀背景:setTextureFile("")
			ui.翅膀特效:reset()
		end
	end
end

function update()
	local 逻辑 = m_tabid == 1 and 英雄角色逻辑 or 角色逻辑
	if not m_init or 逻辑.m_rolejob == nil or 逻辑.m_rolejob == 0 then
		return
	end
	if m_init and ui.召唤英雄 and ui.召唤英雄 ~= ui.tab:getTabBtn(2)then
		ui.召唤英雄:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2 == 0)and m_tabid == 1)
	end
	if 游戏设置.MIRROLEPANEL and ui.tab2 then
		for i,v in ipairs(ui.panels[1])do
			v:setVisible(m_tabid2 == 0)
		end
		for i,v in ipairs(ui.panels[2])do
			v:setVisible(m_tabid2 == 1)
		end
		for i,v in ipairs(ui.panels[3])do
			v:setVisible(m_tabid2 == 2)
		end
		for i,v in ipairs(ui.panels[4])do
			v:setVisible(m_tabid2 == 4)
		end
		for i,v in ipairs(ui.panels[5])do
			v:setVisible(m_tabid2 == 5)
		end
	end
	local 剩余点数 = m_tabid == 1 and m_英雄剩余点数 or m_剩余点数
	if g_mobileMode and ui.加点背景 then
		ui.加点背景:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2 == 2)and 剩余点数>0)
	end
	for i,v in ipairs(ui.addpoints)do
		if(not 游戏设置.MIRROLEPANEL or m_tabid2 == 2)and 剩余点数 > 0 then
			v:setVisible(true)
		else
			v:setVisible(false)
		end
	end
	if 剩余点数 > 0 then
		ui.剩余点数:setTitleText(txt("剩余点数: ")..剩余点数)
	else
		ui.剩余点数:setTitleText("")
	end
	if not m_avt then
		if ISMIR2D then
			m_avt = F3DImageAnim3D:new()
			m_avt:setImage2D(true)
		else
			m_avt = F3DAvatar:new()
		end
	ui.avtcont:addChild(m_avt)	
	end
	if m_rolejob ~= 逻辑.m_rolejob or m_rolesex ~= 逻辑.m_rolesex or m_bodyid ~= 逻辑.m_bodyid or m_weaponid ~= 逻辑.m_weaponid then
		m_avt:reset()
		if 显示内观 then
		elseif ISMIR2D then
			m_avt:setVisible(true)
			ui.男:setVisible(false)
			ui.女:setVisible(false)
			ui.内观位置:setVisible(false)
			m_avt:setScaleX(1)
			m_avt:setScaleY(1)
			m_avt:setEntity(F3DImageAnim3D.PART_BODY,全局设置.getAnimPackUrl(逻辑.m_bodyid))
			m_avt:setEntity(F3DImageAnim3D.PART_HAIR,全局设置.getMirHairUrl(逻辑.m_rolesex))
			if 逻辑.m_weaponid ~= 0 then
				m_avt:setEntity(F3DImageAnim3D.PART_WEAPON,全局设置.getAnimPackUrl(逻辑.m_weaponid))
			end
		else
			m_avt:setVisible(true)
			ui.男:setVisible(false)
			ui.女:setVisible(false)
			ui.内观位置:setVisible(false)
			m_avt:setScale(1.5,1.5,1.5)
			m_avt:setShowShadow(true)
			m_avt:setLighting(true)
			m_avt:setEntity(F3DAvatar.PART_BODY,全局设置.getBodyUrl(逻辑.m_bodyid))
			m_avt:setEntity(F3DAvatar.PART_FACE,全局设置.getFaceUrl(逻辑.m_rolejob))
			m_avt:setEntity(F3DAvatar.PART_HAIR,全局设置.getHairUrl(逻辑.m_rolejob))
			m_avt:setAnimSet(全局设置.getAnimsetUrl(逻辑.m_rolejob))
			if 逻辑.m_weaponid ~= 0 then
				m_avt:setEntity(F3DAvatar.PART_WEAPON,全局设置.getWeaponUrl(逻辑.m_weaponid))
			end
		end
		m_rolejob = 逻辑.m_rolejob
		m_rolesex = 逻辑.m_rolesex
		m_bodyid = 逻辑.m_bodyid
		m_weaponid = 逻辑.m_weaponid
end
	if m_bodyeff ~= 逻辑.m_bodyeff or m_weaponeff ~= 逻辑.m_weaponeff then
		if 显示内观 then
		elseif ISMIR2D then
		if m_bodyeff<0 then
			m_avt:removeEffectSystem(全局设置.getAnimPackUrl(-m_bodyeff,true))
		elseif m_bodyeff>0 then
			m_avt:removeEntity(F3DImageAnim3D.PART_BODY_EFFECT)
		end
		if m_weaponeff ~= 0 then
			m_avt:removeEntity(F3DImageAnim3D.PART_WEAPON_EFFECT)
		end
		if 逻辑.m_bodyeff<0 then
			m_avt:setEffectSystem(全局设置.getAnimPackUrl(-逻辑.m_bodyeff,true),true,nil,nil,0,-1)
		elseif 逻辑.m_bodyeff>0 then
			m_avt:setEntity(F3DImageAnim3D.PART_BODY_EFFECT,全局设置.getAnimPackUrl(逻辑.m_bodyeff)):setBlendType(F3DRenderContext.BLEND_ADD)
		end
		if 逻辑.m_weaponeff ~= 0 then
			m_avt:setEntity(F3DImageAnim3D.PART_WEAPON_EFFECT,全局设置.getAnimPackUrl(逻辑.m_weaponeff)):setBlendType(F3DRenderContext.BLEND_ADD)
		end
		else
		if m_bodyeff ~= 0 then
			m_avt:removeEffectSystem(全局设置.getEffectUrl(m_bodyeff))
		end
		if m_weaponeff ~= 0 then
			m_avt:removeEffectSystem(全局设置.getEffectUrl(m_weaponeff))
		end
		if 逻辑.m_bodyeff ~= 0 then
			m_avt:setEffectSystem(全局设置.getEffectUrl(逻辑.m_bodyeff),true)
		end
		if 逻辑.m_weaponeff ~= 0 then
			m_avt:setEffectSystem(全局设置.getEffectUrl(逻辑.m_weaponeff),true)
		end
	end
	m_bodyeff = 逻辑.m_bodyeff
	m_weaponeff = 逻辑.m_weaponeff
end
	local p = 逻辑.m_rolename:find("\\")
	local hh = 逻辑.m_guildname:find("\\")
	local name  =  string.gsub(txt(逻辑.m_rolename),"s0.","")
	ui.rolename:setTitleText(p and txt(逻辑.m_rolename:sub(1,p-1)) or txt(逻辑.m_rolename))
	ui.名称:setTitleText(p and txt(逻辑.m_rolename:sub(1,p-1)) or txt(逻辑.m_rolename))
	ui.行会:setTitleText(p and txt(逻辑.m_guildname:sub(1,p-1)) or txt(逻辑.m_guildname))
	ui.rolejob:setTitleText(txt(全局设置.获取职业类型(逻辑.m_rolejob)))
	ui.level:setTitleText(逻辑.m_level..(逻辑.m_转生等级 > 0 and txt(" ("..逻辑.m_转生等级.."转"..")") or ""))							   
	ui.生命值:setTitleText(逻辑.m_hpmax)
	ui.魔法值:setTitleText(逻辑.m_mpmax)
	ui.防御:setTitleText(逻辑.m_防御.."-"..逻辑.m_防御上限)
	ui.魔御:setTitleText(逻辑.m_魔御.."-"..逻辑.m_魔御上限)
	ui.攻击:setTitleText(逻辑.m_攻击.."-"..逻辑.m_攻击上限)
	ui.魔法:setTitleText(逻辑.m_魔法.."-"..逻辑.m_魔法上限)
	ui.道术:setTitleText(逻辑.m_道术.."-"..逻辑.m_道术上限)
	ui.幸运:setTitleText("+ "..逻辑.m_幸运)
	ui.准确:setTitleText("+ "..逻辑.m_准确)
	ui.敏捷:setTitleText("+ "..逻辑.m_敏捷)
	ui.魔法命中:setTitleText("+ "..逻辑.m_魔法命中.."%")
	ui.魔法躲避:setTitleText("+ "..逻辑.m_魔法躲避.."%")
	ui.生命恢复:setTitleText("+ "..逻辑.m_生命恢复)
	ui.魔法恢复:setTitleText("+ "..逻辑.m_魔法恢复)
	ui.中毒恢复:setTitleText("+ "..逻辑.m_中毒恢复.."%")
	ui.攻击速度:setTitleText("+ "..逻辑.m_攻击速度.."%")
	ui.移动速度:setTitleText(逻辑.m_speed)
	if ui.PK值 then
		ui.PK值:setTitleText(逻辑.m_PK值 or 0)
		ui.经验值:setTitleText(math.floor(逻辑.m_exp*100/逻辑.m_expmax).."%")
	elseif m_tabid == 0 then
		ui.经验值文字:setTitleText(txt("PK值："))

		ui.经验值:setTitleText(逻辑.m_PK值 or 0)
	else
		ui.经验值文字:setTitleText(txt("经验值："))
		ui.经验值:setTitleText(math.floor(逻辑.m_exp*100/逻辑.m_expmax).."%")
	end
	
	实用工具.setClipNumber(逻辑.m_power,ui.zhanli,true)
	if m_tabid == 1 then
		ui.显示时装:setSelected(角色逻辑.m_英雄显示时装 == 1)
		ui.显示炫武:setSelected(角色逻辑.m_英雄显示炫武 == 1)
	else
		ui.显示时装:setSelected(角色逻辑.m_显示时装 == 1)
		ui.显示炫武:setSelected(角色逻辑.m_显示炫武 == 1)
	end
end

function split(str,reps)
    local resultStrList  =  {}
    string.gsub(str,'[^'..reps..']+',function (w)
        table.insert(resultStrList,w)
    end)
    return resultStrList
end

function onClose(e)
	if tipsui then
		装备提示UI.hideUI()
		tipsui = nil
		tipsgrid = nil
	end

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

function onGridDBClick(e)
	local itemdata = m_tabid == 1 and 英雄物品数据 or m_itemdata
	local g = e:getCurrentTarget()
	local p = e:getLocalPos()
	if g == nil or itemdata[g.id] == nil or itemdata[g.id].id == 0 then
	else
		消息.CG_EQUIP_UNFIX(g.id, (not isHided() and m_tabid == 1) and 1 or 0)
		背包UI.hideAllTipsUI()
	end
end

function checkTipsPos()
	if not ui or not tipsgrid then
		return
	end
	if not tipsui or not tipsui:isVisible()or not tipsui:isInited()then
	else
		local x = ui:getPositionX()+tipsgrid:getPositionX()+tipsgrid:getWidth()
		local y = ui:getPositionY()+tipsgrid:getPositionY()
		if x+tipsui:getWidth()>stage:getWidth()then
			tipsui:setPositionX(x-tipsui:getWidth()-tipsgrid:getWidth())
		else
			tipsui:setPositionX(x)
		end
		if y+tipsui:getHeight()>stage:getHeight()then
			tipsui:setPositionY(stage:getHeight()-tipsui:getHeight())
		else
			tipsui:setPositionY(y)
		end
	end
end

function onGridOver(e)
	if ui.tweenhide then return end
	local itemdata = m_tabid == 1 and 英雄物品数据 or m_itemdata
	local g = g_mobileMode and e:getCurrentTarget()or e:getTarget()
	if g == nil or itemdata[g.id] == nil or itemdata[g.id].id == 0 then
	elseif F3DUIManager.sTouchComp ~= g then
	else
		装备提示UI.initUI()
		装备提示UI.setItemData(itemdata[g.id],true)
		tipsui = 装备提示UI.ui
		tipsgrid = g
		if not tipsui:isInited()then
			tipsui:addEventListener(F3DObjEvent.OBJ_INITED,func_oe(checkTipsPos))
		else
			checkTipsPos()
		end
	end
end

function onGridOut(e)
	local g = e:getTarget()
	if g ~= nil and g == tipsgrid and tipsui then
		装备提示UI.hideUI()
		tipsui = nil
		tipsgrid = nil
	end
end

function onTabChange(e)
	if ui.tab:getSelectIndex() == 2 then
		ui.tab:setSelectIndex(1)
		return
	end
	m_tabid = ui.tab:getSelectIndex()
	背包UI.update()
	update()
	updateEquips()
end

function onTabChange2(e)
	m_tabid2 = ui.tab2:getSelectIndex()
	if m_tabid2 == 3 then
		技能UI.setTabID(m_tabid)
		技能UI.setTabID2(m_tabid2)
		技能UI.initUI(ui:getPositionX(),ui:getPositionY())
		hideUI(true)
		return
	elseif m_tabid2 == 4 then
		消息.CG_INTERNAL_QUERY(0,m_内功信息 ~= nil and 1 or 0)
	elseif m_tabid2 == 5 then
		消息.CG_TITLE_QUERY(0,m_称号信息 ~= nil and 1 or 0)
end
	update()
	updateEquips()
end

function onUIInit()
	ui.close = ui:findComponent("titlebar,close")
	ui.close:addEventListener(F3DMouseEvent.CLICK, func_me(onClose))
	ui:addEventListener(F3DMouseEvent.MOUSE_DOWN, func_me(onMouseDown))
	ui.avtcont = ui:findComponent("avtcont")
	ui.rolerect = ui:findComponent("rolerect")
	ui.名称 = ui:findComponent("名称")
	ui.行会 = ui:findComponent("行会")
	ui.component_23 = ui:findComponent("行会")
	ui.rolerect:addEventListener(F3DMouseEvent.MOUSE_DOWN,func_me(function(e)
		if m_avt then
			m_downposx = e:getStageX()
		end
	end))
	ui.rolerect:addEventListener(F3DMouseEvent.MOUSE_MOVE,func_me(function(e)
		if m_avt then
if ISMIR2D then
				m_avt:setAnimRotationZ(m_avt:getAnimRotationZ()+e:getStageX()-m_downposx)
			else
				m_avt:setRotationZ(m_avt:getRotationZ()+e:getStageX()-m_downposx)
			end
				m_downposx = e:getStageX()
		end
	end))
ui.属性=ui:findComponent("属性")
ui.rolename=ui.属性 and ui:findComponent("属性,rolename")or ui:findComponent("rolename")
ui.rolejob=ui.属性 and ui:findComponent("属性,rolejob")or ui:findComponent("rolejob")
ui.level=ui.属性 and ui:findComponent("属性,level")or ui:findComponent("level")
ui.生命值=ui.属性 and ui:findComponent("属性,生命值")or ui:findComponent("生命值")
ui.魔法值=ui.属性 and ui:findComponent("属性,魔法值")or ui:findComponent("魔法值")
ui.防御=ui.属性 and ui:findComponent("属性,防御")or ui:findComponent("防御")
ui.魔御=ui.属性 and ui:findComponent("属性,魔御")or ui:findComponent("魔御")
ui.攻击=ui.属性 and ui:findComponent("属性,攻击")or ui:findComponent("攻击")
ui.魔法=ui.属性 and ui:findComponent("属性,魔法")or ui:findComponent("魔法")
ui.道术=ui.属性 and ui:findComponent("属性,道术")or ui:findComponent("道术")
ui.幸运=ui.属性 and ui:findComponent("属性,幸运")or ui:findComponent("幸运")
ui.准确=ui.属性 and ui:findComponent("属性,准确")or ui:findComponent("准确")
ui.敏捷=ui.属性 and ui:findComponent("属性,敏捷")or ui:findComponent("敏捷")

ui.魔法命中=ui.属性 and ui:findComponent("属性,魔法命中")or ui:findComponent("魔法命中")
ui.魔法躲避=ui.属性 and ui:findComponent("属性,魔法躲避")or ui:findComponent("魔法躲避")
ui.生命恢复=ui.属性 and ui:findComponent("属性,生命恢复")or ui:findComponent("生命恢复")
ui.魔法恢复=ui.属性 and ui:findComponent("属性,魔法恢复")or ui:findComponent("魔法恢复")
ui.中毒恢复=ui.属性 and ui:findComponent("属性,中毒恢复")or ui:findComponent("中毒恢复")
ui.攻击速度=ui.属性 and ui:findComponent("属性,攻击速度")or ui:findComponent("攻击速度")
ui.移动速度=ui.属性 and ui:findComponent("属性,移动速度")or ui:findComponent("移动速度")
ui.经验值=ui.属性 and ui:findComponent("属性,经验值")or ui:findComponent("经验值")
ui.经验值文字=ui.属性 and ui:findComponent("属性,component_20")or ui:findComponent("component_20")
ui.PK值=ui.属性 and ui:findComponent("属性,PK值")or ui:findComponent("PK值")
	ui.zhanli = ui:findComponent("zhan_shuzhi"):getBackground()
	ui.equips = {}
	ui.grids = {}
	for i=1,EQUIPMAX do
	local grid = ui:findComponent("equippos_"..i)
		if grid then
			tdisui(grid)
			grid.id = i
			grid:addEventListener(F3DMouseEvent.DOUBLE_CLICK,func_me(onGridDBClick))
			grid:addEventListener(F3DMouseEvent.RIGHT_CLICK,func_me(onGridDBClick))
		if g_mobileMode then
			grid:addEventListener(F3DMouseEvent.CLICK,func_me(onGridOver))
		else
			grid:addEventListener(F3DUIEvent.MOUSE_OVER,func_ue(onGridOver))
			grid:addEventListener(F3DUIEvent.MOUSE_OUT,func_ue(onGridOut))
		end
			ui.grids[i] = grid
		local equip = F3DImage:new()
			equip:setPositionX(math.floor(grid:getWidth()/2))
			equip:setPositionY(math.floor(grid:getHeight()/2))
			equip:setPivot(0.5,0.5)
			equip.effect = nil
			ui.equips[i] = equip
			grid:addChild(equip)
			equip.grade = F3DImage:new()
			equip.grade:setPositionX(1)
			equip.grade:setPositionY(1)
			equip.grade:setWidth(grid:getWidth()-2)
			equip.grade:setHeight(grid:getHeight()-2)
			grid:addChild(equip.grade)
			equip.lock = F3DImage:new()
			equip.lock:setPositionX(g_mobileMode and 8 or 4)
			equip.lock:setPositionY(g_mobileMode and grid:getHeight()-8 or grid:getHeight()-4)
			equip.lock:setPivot(0,1)
			grid:addChild(equip.lock)
			equip.strengthen = F3DTextField:new()
		if g_mobileMode then
			equip.strengthen:setTextFont("宋体",16,false,false,false)
		end
			equip.strengthen:setPositionX(g_mobileMode and grid:getWidth()-8 or grid:getWidth()-4)
			equip.strengthen:setPositionY(g_mobileMode and 8 or 4)
			equip.strengthen:setPivot(1,0)
			grid:addChild(equip.strengthen)
			if 游戏设置.MIRROLEPANEL and 游戏设置.EQUIPPOSHIDE and 实用工具.FindIndex(游戏设置.EQUIPPOSHIDE,i)then
				equip:setVisible(false)
				equip.grade:setVisible(false)
				equip.lock:setVisible(false)
				equip.strengthen:setVisible(false)
			end
		end
	end
		ui.addpoints = {}
	for i=1,7 do
local addpoint=ui.属性 and ui:findComponent("属性,btn_add_"..i)or ui:findComponent("btn_add_"..i)
			addpoint.id = i
			addpoint:addEventListener(F3DMouseEvent.CLICK,func_me(function(e)
			local g = e:getCurrentTarget()
				if g == nil or g.id == nil then
				else
					消息.CG_PROP_ADDPOINT(m_tabid == 1 and 1 or 0,g.id)
				end
			end))
		ui.addpoints[#ui.addpoints+1] = addpoint
	end
	if g_mobileMode then
ui.加点背景=ui.属性 and ui:findComponent("属性,加点背景")or ui:findComponent("加点背景")
	end
ui.剩余点数=ui.属性 and ui:findComponent("属性,剩余点数")or ui:findComponent("剩余点数")
		ui.tab = tt(ui:findComponent("tab_1"),F3DTab)
	if ui.tab:getTabBtn(2)then
		ui.召唤英雄  =  ui.tab:getTabBtn(2)
	end
		ui.tab:setSelectIndex(m_tabid)
		ui.tab:addEventListener(F3DUIEvent.CHANGE,func_ue(onTabChange))
		ui.tab:setVisible(游戏设置.SHOWHERO)
	if 游戏设置.MIRROLEPANEL and ui:findComponent("tab_2")then
		ui.tab2 = tt(ui:findComponent("tab_2"),F3DTab)
		ui.tab2:setSelectIndex(m_tabid2)
		ui.tab2:addEventListener(F3DUIEvent.CHANGE,func_ue(onTabChange2))
	end
		ui.角色背景 = ui:findComponent("角色背景")
		ui.男 = ui:findComponent("男")
		ui.女 = ui:findComponent("女")
		ui.内观位置 = ui:findComponent("内观位置")
		ui.衣服位置 = F3DImage:new()
		ui.内观位置:addChild(ui.衣服位置)
		ui.衣服背景 = F3DImage:new()
		ui.衣服背景:setBlendType(F3DRenderContext.BLEND_ADD)
		ui.内观位置:addChild(ui.衣服背景)
		ui.衣服特效 = F3DImageAnim:new()
		ui.内观位置:addChild(ui.衣服特效)
		ui.翅膀位置 = F3DImage:new()
		ui.内观位置:addChild(ui.翅膀位置)
		ui.翅膀背景 = F3DImage:new()
		ui.翅膀背景:setBlendType(F3DRenderContext.BLEND_ADD)
		ui.内观位置:addChild(ui.翅膀背景)
		ui.翅膀特效 = F3DImageAnim:new()
		ui.内观位置:addChild(ui.翅膀特效)
		ui.武器位置 = F3DImage:new()
		ui.内观位置:addChild(ui.武器位置)											   
		ui.武器背景 = F3DImage:new()									 
		ui.武器背景:setBlendType(F3DRenderContext.BLEND_ADD)
		ui.内观位置:addChild(ui.武器背景)
		ui.武器特效 = F3DImageAnim:new()
		ui.内观位置:addChild(ui.武器特效)
		ui.头盔位置 = F3DImage:new()
		ui.内观位置:addChild(ui.头盔位置)
		
		ui.斗笠位置 = F3DImage:new()
		ui.内观位置:addChild(ui.斗笠位置)
		
		ui.面巾位置 = F3DImage:new()																			
		ui.内观位置:addChild(ui.面巾位置)    
		ui.盾牌位置 = F3DImage:new()
		ui.内观位置:addChild(ui.盾牌位置)
		ui.盾牌背景 = F3DImage:new()
		ui.盾牌背景:setBlendType(F3DRenderContext.BLEND_ADD)
		ui.内观位置:addChild(ui.盾牌背景)
		ui.盾牌特效 = F3DImageAnim:new()
		ui.内观位置:addChild(ui.盾牌特效)
		ui.马牌位置 = F3DImage:new()
		ui.内观位置:addChild(ui.马牌位置)
		ui.马牌背景 = F3DImage:new()
		ui.马牌背景:setBlendType(F3DRenderContext.BLEND_ADD)
		ui.内观位置:addChild(ui.马牌背景)
		ui.马牌特效 = F3DImageAnim:new()
		ui.内观位置:addChild(ui.马牌特效)
		ui.法宝位置 = F3DImage:new()
		ui.内观位置:addChild(ui.法宝位置)
		ui.法宝背景 = F3DImage:new()
		ui.法宝背景:setBlendType(F3DRenderContext.BLEND_ADD)
		ui.内观位置:addChild(ui.法宝背景)
		ui.法宝特效 = F3DImageAnim:new()
		ui.内观位置:addChild(ui.法宝特效)
		ui.显示时装 = tt(ui:findComponent("显示时装"),F3DCheckBox)
		ui.显示时装:addEventListener(F3DUIEvent.CHANGE,func_ue(function(e)
			if m_tabid == 1 then
				角色逻辑.m_英雄显示时装 = ui.显示时装:isSelected()and 1 or 0
			else
				角色逻辑.m_显示时装 = ui.显示时装:isSelected()and 1 or 0
			end
			消息.CG_SHOW_FASHION(角色逻辑.m_显示时装,角色逻辑.m_英雄显示时装,角色逻辑.m_显示炫武,角色逻辑.m_英雄显示炫武)
			更新内观()
		end))
		ui.显示炫武 = tt(ui:findComponent("显示炫武"),F3DCheckBox)
		ui.显示炫武:addEventListener(F3DUIEvent.CHANGE,func_ue(function(e)
			if m_tabid == 1 then
				角色逻辑.m_英雄显示炫武 = ui.显示炫武:isSelected()and 1 or 0
			else
				角色逻辑.m_显示炫武 = ui.显示炫武:isSelected()and 1 or 0
			end
			消息.CG_SHOW_FASHION(角色逻辑.m_显示时装,角色逻辑.m_英雄显示时装,角色逻辑.m_显示炫武,角色逻辑.m_英雄显示炫武)
		更新内观()
		end))
		ui.召唤英雄 = ui.召唤英雄 or ui:findComponent("call")
		if ui.召唤英雄 then
			ui.召唤英雄:addEventListener(F3DMouseEvent.CLICK,func_me(function(e)
			消息.CG_CHANGE_STATUS(104,-1)
		end))
			if ui.召唤英雄 == ui.tab:getTabBtn(2)then
				ui.召唤英雄:setTitleText(英雄信息UI.m_objid == -1 and txt("召\n唤")or txt("收\n回"))
			else
				ui.召唤英雄:setTitleText(英雄信息UI.m_objid == -1 and txt("召唤")or txt("收回"))
			end
		end
		-----------------------------------神佑-----------------------------------------
		-- ui.神佑 = ui:findComponent("神佑")
		-- if ui.神佑 then
			-- local 神佑位置 = ui:findComponent("神佑位置")
			-- local ox  =  ui.神佑:getPositionX()-神佑位置:getPositionX()
			-- local oy  =  ui.神佑:getPositionY()-神佑位置:getPositionY()
			-- if 游戏设置.EQUIPPOSTHREE then
				-- for i,v in ipairs(游戏设置.EQUIPPOSTHREE)do
					-- if ui.grids[v]then
						-- ui.grids[v]:setPositionX(ui.grids[v]:getPositionX()-ox)
						-- ui.grids[v]:setPositionY(ui.grids[v]:getPositionY()-oy)
						-- ui.grids[v]:setVisible(false)
					-- end			
				-- end
			-- end
	-- ui.神佑:setPositionX(神佑位置:getPositionX())
	-- ui.神佑:setPositionY(神佑位置:getPositionY())
	-- ui.神佑:setVisible(false)	
	-- ui.神佑显示 = ui:findComponent("神佑显示")
		-- ui.神佑显示:addEventListener(F3DMouseEvent.CLICK,func_me(function(e)
			-- if ui.神佑:isVisible()then
				-- if 游戏设置.EQUIPPOSTWO then
					-- for i,v in ipairs(游戏设置.EQUIPPOSTHREE)do
						-- if ui.grids[v]then
							-- ui.grids[v]:setVisible(false)
						-- end
					-- end
				-- end
			-- ui.神佑:setVisible(false)
			-- ui.生肖:setVisible(false)
			-- else
			-- if 游戏设置.EQUIPPOSTWO then
				-- for i,v in ipairs(游戏设置.EQUIPPOSTHREE)do
					-- if ui.grids[v]then
						-- ui.grids[v]:setVisible(true)
					-- end
				-- end
			-- end
			-- ui.神佑:setVisible(true)
			-- ui.生肖:setVisible(false)
			-- end
			-- print("00000000000000",ui.神佑显示,ui.生肖显示)
		-- end))
	-- ui.神佑关闭 = ui:findComponent("神佑,close")
		-- if ui.神佑关闭 then
			-- ui.神佑关闭:addEventListener(F3DMouseEvent.CLICK,func_me(function(e)
				-- if 游戏设置.EQUIPPOSTWO then
					-- for i,v in ipairs(游戏设置.EQUIPPOSTHREE)do
						-- if ui.grids[v]then
						-- ui.grids[v]:setVisible(false)
						-- end
					-- end
				-- end
				-- ui.神佑:setVisible(false)
				-- ui.生肖:setVisible(false)
			-- end))
		-- end
		-- print("1111111111111111",ui.神佑关闭,ui.生肖关闭)
	-- end
---------------------
-------生肖----------
		ui.生肖 = ui:findComponent("生肖")
		if ui.生肖 then
			local 生肖位置 = ui:findComponent("生肖位置")
			local ox  =  ui.生肖:getPositionX()-生肖位置:getPositionX()
			local oy  =  ui.生肖:getPositionY()-生肖位置:getPositionY()
			if 游戏设置.EQUIPPOSTHREE then
				for i,v in ipairs(游戏设置.EQUIPPOSTHREE)do
					if ui.grids[v]then
						ui.grids[v]:setPositionX(ui.grids[v]:getPositionX()-ox)
						ui.grids[v]:setPositionY(ui.grids[v]:getPositionY()-oy)
						ui.grids[v]:setVisible(false)
					end			
				end
			end
	ui.生肖:setPositionX(生肖位置:getPositionX())
	ui.生肖:setPositionY(生肖位置:getPositionY())
	ui.生肖:setVisible(false)
	
	ui.生肖显示 = ui:findComponent("生肖显示")
		ui.生肖显示:addEventListener(F3DMouseEvent.CLICK,func_me(function(e)
			if ui.生肖:isVisible()then
				if 游戏设置.EQUIPPOSTWO then
					for i,v in ipairs(游戏设置.EQUIPPOSTHREE)do
						if ui.grids[v]then
							ui.grids[v]:setVisible(false)
						end
					end
				end
			ui.生肖:setVisible(false)
			else
			if 游戏设置.EQUIPPOSTWO then
				for i,v in ipairs(游戏设置.EQUIPPOSTHREE)do
					if ui.grids[v]then
						ui.grids[v]:setVisible(true)
					end
				end
			end
			ui.生肖:setVisible(true)
			end
		end))
	ui.生肖关闭 = ui:findComponent("生肖,close")
		if ui.生肖关闭 then
			ui.生肖关闭:addEventListener(F3DMouseEvent.CLICK,func_me(function(e)
				if 游戏设置.EQUIPPOSTWO then
					for i,v in ipairs(游戏设置.EQUIPPOSTHREE)do
						if ui.grids[v]then
						ui.grids[v]:setVisible(false)
						end
					end
				end
				ui.生肖:setVisible(false)
			end))
		end
	end
-----------------	
	ui.内功 = ui:findComponent("内功")
		if ui.内功 then
			ui.内功:setVisible(false)
		end
	ui.称号 = ui:findComponent("称号")
		if ui.称号 then
			ui.称号:setVisible(false)
		end	
	if 游戏设置.MIRROLEPANEL and ui.tab2 then
		ui.panels = {}
		ui.panels[1] = {}
		if ui.角色背景 then
			ui.panels[1][#ui.panels[1]+1] = ui.角色背景
		end
		if ui.生肖显示 then
			ui.panels[1][#ui.panels[1]+1] = ui.生肖显示
		end
		-- if ui.神佑显示 then
			-- ui.panels[1][#ui.panels[1]+1] = ui.神佑显示
		-- end
		for i=1,EQUIPMAX do
			if ui.grids[i]and
			(not 游戏设置.EQUIPPOSTWO or not 实用工具.FindIndex(游戏设置.EQUIPPOSTWO,i))and
			(not 游戏设置.EQUIPPOSTHREE or not 实用工具.FindIndex(游戏设置.EQUIPPOSTHREE,i))then
			ui.panels[1][#ui.panels[1]+1] = ui.grids[i]
			end
		end
		ui.panels[1][#ui.panels[1]+1] = ui:findComponent("zhanbg")
		ui.panels[1][#ui.panels[1]+1] = ui:findComponent("zhan")
		ui.panels[1][#ui.panels[1]+1] = ui:findComponent("zhan_shuzhi")
		ui.panels[2] = {}
		if ui.角色背景 then
			ui.panels[2][#ui.panels[2]+1] = ui.角色背景
		end
		if 游戏设置.EQUIPPOSTWO then
			for i,v in ipairs(游戏设置.EQUIPPOSTWO)do
				if ui.grids[v]then
					ui.panels[2][#ui.panels[2]+1] = ui.grids[v]
				end
			end
		end
		ui.panels[2][#ui.panels[2]+1] = ui.显示时装
		ui.panels[2][#ui.panels[2]+1] = ui.显示炫武
		ui.panels[3] = {}
if ui.属性 then
ui.panels[3][#ui.panels[3]+1]=ui.属性
		else
		ui.panels[3][#ui.panels[3]+1] = ui:findComponent("kuozhan")
		ui.panels[3][#ui.panels[3]+1] = ui:findComponent("img_line1")
		ui.panels[3][#ui.panels[3]+1] = ui:findComponent("img_line1_1")
		ui.panels[3][#ui.panels[3]+1] = ui.rolename
		
		ui.panels[3][#ui.panels[3]+1] = ui.rolejob
		ui.panels[3][#ui.panels[3]+1] = ui.level
		ui.panels[3][#ui.panels[3]+1] = ui.生命值
		ui.panels[3][#ui.panels[3]+1] = ui.魔法值
ui.panels[3][#ui.panels[3]+1]=ui.防御
ui.panels[3][#ui.panels[3]+1]=ui.魔御
ui.panels[3][#ui.panels[3]+1]=ui.攻击
ui.panels[3][#ui.panels[3]+1]=ui.魔法
ui.panels[3][#ui.panels[3]+1]=ui.道术
		ui.panels[3][#ui.panels[3]+1] = ui.幸运
		ui.panels[3][#ui.panels[3]+1] = ui.准确
		ui.panels[3][#ui.panels[3]+1] = ui.敏捷
		ui.panels[3][#ui.panels[3]+1] = ui.魔法命中
		ui.panels[3][#ui.panels[3]+1] = ui.魔法躲避
		ui.panels[3][#ui.panels[3]+1] = ui.生命恢复
		ui.panels[3][#ui.panels[3]+1] = ui.魔法恢复
		ui.panels[3][#ui.panels[3]+1] = ui.中毒恢复
		ui.panels[3][#ui.panels[3]+1] = ui.攻击速度
		ui.panels[3][#ui.panels[3]+1] = ui.移动速度
		ui.panels[3][#ui.panels[3]+1] = ui.经验值
		if ui.PK值 then
			ui.panels[3][#ui.panels[3]+1] = ui.PK值
		end
	end
		for i=1,22 or 25 do
ui.panels[3][#ui.panels[3]+1]=ui:findComponent("component_"..i)
		end
		local 属性位置 = ui:findComponent("属性位置")or ui.男
		local ox = ui.panels[3][1]:getPositionX()-属性位置:getPositionX()
		local oy = ui.panels[3][1]:getPositionY()-属性位置:getPositionY()
		for i,v in ipairs(ui.panels[3])do
			v:setPositionX(v:getPositionX()-ox)
			v:setPositionY(v:getPositionY()-oy)
		end
		for i=1,7 do
			ui.addpoints[i]:setPositionX(ui.addpoints[i]:getPositionX()-ox)
			ui.addpoints[i]:setPositionY(ui.addpoints[i]:getPositionY()-oy)
		end
		if ui.加点背景 then
			ui.加点背景:setPositionX(ui.加点背景:getPositionX()-ox)
			ui.加点背景:setPositionY(ui.加点背景:getPositionY()-oy)
		end
		ui.panels[3][#ui.panels[3]+1] = ui.剩余点数
		ui.panels[4] = {}
		if ui.内功 then
		ui.panels[4][1] = ui.内功
		local 内功位置 = ui:findComponent("内功位置")or ui.男
		ui.内功:setPositionX(内功位置:getPositionX())
		ui.内功:setPositionY(内功位置:getPositionY())
		ui.内功升级 = ui:findComponent("内功,升级")
		ui.内功升级:addEventListener(F3DMouseEvent.CLICK,func_me(function(e)
		消息.CG_INTERNAL_UPGRADE(0)
		end))
		ui.内功等级 = ui:findComponent("内功,等级")
		ui.内功经验 = ui:findComponent("内功,经验")
		ui.内功生命值 = ui:findComponent("内功,生命值")
		ui.内功魔法值 = ui:findComponent("内功,魔法值")
		ui.内功防御 = ui:findComponent("内功,防御")
		ui.内功魔御 = ui:findComponent("内功,魔御")
		ui.内功攻击 = ui:findComponent("内功,攻击")
		ui.内功魔法 = ui:findComponent("内功,魔法")
		ui.内功道术 = ui:findComponent("内功,道术")
		ui.内功需求 = ui:findComponent("内功,需求")
		end
		ui.panels[5] = {}
		if ui.称号 then
			ui.panels[5][1] = ui.称号
		local 称号位置 = ui:findComponent("称号位置")or ui.男
			ui.称号:setPositionX(称号位置:getPositionX())
			ui.称号:setPositionY(称号位置:getPositionY())
			ui.称号使用 = ui:findComponent("称号,使用")
			ui.称号使用:addEventListener(F3DMouseEvent.CLICK,func_me(function(e)
		local index = (m_称号当前页-1)*6 + m_称号当前索引
			if m_称号排序信息[index]then
				消息.CG_TITLE_APPLY(0,m_称号排序信息[index][1])
			end
		end))
			ui.称号页数 = ui:findComponent("称号,页数")
			ui.称号上页 = ui:findComponent("称号,上页")
			ui.称号上页:addEventListener(F3DMouseEvent.CLICK,func_me(function(e)
		local totalpage = math.max(1,math.ceil(m_称号信息 and#m_称号信息/6 or 0))
			if m_称号当前页>1 then
				m_称号当前页 = math.max(1,m_称号当前页-1)
				m_称号当前索引 = 1
				updateTitle()
			end
		end))
		ui.称号下页 = ui:findComponent("称号,下页")
		ui.称号下页:addEventListener(F3DMouseEvent.CLICK,func_me(function(e)
		local totalpage = math.max(1,math.ceil(m_称号信息 and#m_称号信息/6 or 0))
			if m_称号当前页<totalpage then
				m_称号当前页 = math.max(1,m_称号当前页+1)
				m_称号当前索引 = 1
				updateTitle()
			end
		end))
		ui.称号选中 = ui:findComponent("称号,选中")
		ui.称号选中格子 = ui:findComponent("称号,格子")
		ui.称号选中格子.grid = F3DImage:new()
		ui.称号选中格子.grid:setPositionX(math.floor(ui.称号选中格子:getWidth()/2))
		ui.称号选中格子.grid:setPositionY(math.floor(ui.称号选中格子:getHeight()/2))
		ui.称号选中格子.grid:setPivot(0.5,0.5)
		ui.称号选中格子:addChild(ui.称号选中格子.grid)
		ui.称号选中动画 = ui:findComponent("称号,动画")
		ui.称号选中动画.grid = F3DImage:new()
		ui.称号选中动画.grid:setPositionX(math.floor(ui.称号选中动画:getWidth()/2))
		ui.称号选中动画.grid:setPositionY(math.floor(ui.称号选中动画:getHeight()/2))
		ui.称号选中动画.grid:setPivot(0.5,0.5)
		ui.称号选中动画:addChild(ui.称号选中动画.grid)
		ui.称号选中动画.effect = F3DImageAnim:new()
		ui.称号选中动画.effect:setPositionX(math.floor(ui.称号选中动画:getWidth()/2))
		ui.称号选中动画.effect:setPositionY(math.floor(ui.称号选中动画:getHeight()/2))
		ui.称号选中动画:addChild(ui.称号选中动画.effect)
		ui.称号格子 = {}
		ui.称号动画 = {}
	for i=1,6 do
		ui.称号格子[i] = ui:findComponent("称号,格子_"..i)
		ui.称号格子[i].i = i
		ui.称号格子[i]:addEventListener(F3DMouseEvent.CLICK,func_me(function(e)
		if m_称号排序信息[(m_称号当前页-1)*6+e:getCurrentTarget().i]then
			m_称号当前索引 = e:getCurrentTarget().i
			updateTitle()
		end
	end))
		ui.称号格子[i].grid = F3DImage:new()
		ui.称号格子[i].grid:setPositionX(math.floor(ui.称号格子[i]:getWidth()/2))
		ui.称号格子[i].grid:setPositionY(math.floor(ui.称号格子[i]:getHeight()/2))
		ui.称号格子[i].grid:setPivot(0.5,0.5)
		ui.称号格子[i]:addChild(ui.称号格子[i].grid)
		ui.称号动画[i] = ui:findComponent("称号,动画_"..i)
		ui.称号动画[i].i = i
		ui.称号动画[i]:addEventListener(F3DMouseEvent.CLICK,func_me(function(e)
		if m_称号排序信息[(m_称号当前页-1)*6+e:getCurrentTarget().i]then
			m_称号当前索引 = e:getCurrentTarget().i
			updateTitle()
		end
	end))
		ui.称号动画[i].grid = F3DImage:new()
		ui.称号动画[i].grid:setPositionX(math.floor(ui.称号动画[i]:getWidth()/2))
		ui.称号动画[i].grid:setPositionY(math.floor(ui.称号动画[i]:getHeight()/2))
		ui.称号动画[i].grid:setPivot(0.5,0.5)
		ui.称号动画[i]:addChild(ui.称号动画[i].grid)
		ui.称号动画[i].effect = F3DImageAnim:new()
		ui.称号动画[i].effect:setPositionX(math.floor(ui.称号动画[i]:getWidth()/2))
		ui.称号动画[i].effect:setPositionY(math.floor(ui.称号动画[i]:getHeight()/2))
		ui.称号动画[i]:addChild(ui.称号动画[i].effect)
	end
		ui.称号页数 = ui:findComponent("称号,页数")
		ui.称号上页 = ui:findComponent("称号,上页")
		ui.称号下页 = ui:findComponent("称号,下页")
		ui.称号名称 = ui:findComponent("称号,名称")
		ui.称号生命值 = ui:findComponent("称号,生命值")
		ui.称号魔法值 = ui:findComponent("称号,魔法值")
		ui.称号防御 = ui:findComponent("称号,防御")
		ui.称号魔御 = ui:findComponent("称号,魔御")
		ui.称号攻击 = ui:findComponent("称号,攻击")
		ui.称号魔法 = ui:findComponent("称号,魔法")
		ui.称号道术 = ui:findComponent("称号,道术")
		ui.称号来源 = ui:findComponent("称号,来源")
		end
	end
	if m_x and m_y then
		ui:setPositionX(m_x)
		ui:setPositionY(m_y)
	end
_v_251("角色UI",ui)
	m_init = true
	update()
	updateEquips()
updateInternal()
updateTitle()
end

function isHided()
	return not ui or not ui:isVisible()or ui.tweenhide
end

function hideUI(force)
	if tipsui then
		装备提示UI.hideUI()
		tipsui = nil
		tipsgrid = nil
	end
	if ui then
if force then
		ui:setVisible(false)
else
_v_62(ui,false)
end
	end
end

function toggle()
	if isHided() then
		initUI()
	else
		hideUI()
	end
end

function initUI(x, y)
	if ui then
		uiLayer:removeChild(ui)
		uiLayer:addChild(ui)
		ui:updateParent()
		ui:setVisible(true)
		if m_avt then
if ISMIR2D then
				m_avt:setAnimRotationZ(0)
			else
				m_avt:setRotationZ(0)
			end
		end
		if x and y then
			ui:setPositionX(x)
			ui:setPositionY(y)
			ui:setAlpha(1)
			ui.tweenhide = nil
		else
_v_62(ui,true)
		end
	return
end
	ui = F3DLayout:new()
	uiLayer:addChild(ui)
	ui:setLoadPriority(getUIPriority())
	ui:setMovable(true)
	ui:addEventListener(F3DObjEvent.OBJ_INITED,func_e(onUIInit))
if ui.setUIPack and USEUIPACK then
if 游戏设置.ISZY or 游戏设置.ISZYROLE then
ui:setUIPack(g_mobileMode and UIPATH.."角色UIzm.pack"or UIPATH.."角色UIz.pack")
elseif 游戏设置.NEWROLEPANEL then
ui:setUIPack(g_mobileMode and UIPATH.."角色UImn.pack"or UIPATH.."角色UIn.pack")
else
ui:setUIPack(g_mobileMode and UIPATH.."角色UIm.pack"or UIPATH.."角色UI.pack")
end
else
if 游戏设置.ISZY or 游戏设置.ISZYROLE then
ui:setLayout(g_mobileMode and UIPATH.."角色UIzm.layout"or UIPATH.."角色UIz.layout")
elseif 游戏设置.NEWROLEPANEL then
ui:setLayout(g_mobileMode and UIPATH.."角色UImn.layout"or UIPATH.."角色UIn.layout")
else
		ui:setLayout(g_mobileMode and UIPATH.."角色UIm.layout"or UIPATH.."角色UI.layout")
	end
end
	if x and y then
		m_x = x
		m_y = y
	else
_v_62(ui,true)
	end
end