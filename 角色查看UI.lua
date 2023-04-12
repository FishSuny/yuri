module(..., package.seeall)

local 全局设置 = require("公用.全局设置")
local 游戏设置 = require("公用.游戏设置")
local 实用工具 = require("公用.实用工具")
local 消息 = require("网络.消息")
local 装备提示UI = require("主界面.装备提示UI")
local 物品内观表 = require("配置.物品内观表").Config

m_init = false
m_downposx = 0
m_avt = nil
m_rolejob = 0
m_bodyid = 0
m_weaponid = 0
m_bodyeff = 0
m_weaponeff = 0
m_itemdata = nil
m_tabid2 = 0
tipsui = nil
tipsgrid = nil
角色逻辑 = nil
显示内观 = true
EQUIPMAX = 35

function setEquipData(rolename,objid,level,job,sex,expmax,exp,bodyid,weaponid,wingid,horseid,bodyeff,weaponeff,wingeff,horseeff,hpmax,mpmax,speed,power,suitcnts,转生等级,防御,防御上限,魔御,魔御上限,攻击,攻击上限,魔法,魔法上限,道术,道术上限,幸运,准确,敏捷,魔法命中,魔法躲避,生命恢复,魔法恢复,中毒恢复,攻击速度,移动速度,itemdata,显示时装,显示炫武)
	角色逻辑={
		m_rolename = rolename,
		m_rolejob = job,
		m_rolesex = sex,
		m_expmax = expmax < 0 and 0x7fffffff - expmax or expmax,
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
		m_suitcnts = suitcnts,
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
		m_显示时装 = 显示时装,
		m_显示炫武 = 显示炫武,
		m_PK值 = PK值,
	}
	m_itemdata = {}
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
	update()
	updateEquips()
end

function updateEquips()
	if not m_init or m_itemdata == nil then
		return
	end
	for i=1,EQUIPMAX do
		local v = m_itemdata[i]
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
			ui.equips[i].id = v.pos
			ui.equips[i]:setTextureFile(全局设置.getItemIconUrl(v.icon))
			ui.equips[i].grade:setTextureFile(全局设置.getGradeUrl(v.grade))
			ui.equips[i].lock:setTextureFile(v.bind == 1 and UIPATH.."公用/grid/img_bind.png" or "")
			ui.equips[i].strengthen:setText(v.strengthen > 0 and "+"..v.strengthen or "")
			local gray = 持久上限 > 0 and 持久 >= 持久上限
			ui.equips[i]:setShaderType(gray and F3DImage.SHADER_GRAY or F3DImage.SHADER_NULL)
		elseif ui.equips[i] then
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

function 更新内观()
	if not m_init or m_itemdata == nil then
		return
	end
	if 显示内观 then
		if m_avt then
			m_avt:setVisible(false)
		end
		local 时装武器 = false
		ui.内观位置:setVisible(not 游戏设置.MIRROLEPANEL or m_tabid2 == 0 or m_tabid2 == 1)
if((not 游戏设置.MIRROLEPANEL and 角色逻辑.m_显示炫武==1)or(游戏设置.MIRROLEPANEL and m_tabid2==1))and m_itemdata[27]and m_itemdata[27].count>0 and 物品内观表[游戏设置.ICONUSEID and m_itemdata[27].id or 全局设置.getFixedID(m_itemdata[27].icon)]then
local 物品内观=物品内观表[游戏设置.ICONUSEID and m_itemdata[27].id or 全局设置.getFixedID(m_itemdata[27].icon)]
ui.武器位置:setTextureFile(全局设置.getStateItemIconUrl(物品内观.图标ID))
ui.武器位置:setPositionX(物品内观.偏移X+游戏设置.偏移X)
ui.武器位置:setPositionY(物品内观.偏移Y+游戏设置.偏移Y)
ui.武器背景:setTextureFile(全局设置.getStateItemIconUrl(物品内观.背景图片))
ui.武器背景:setPositionX(物品内观.背景偏移X+游戏设置.偏移X)
ui.武器背景:setPositionY(物品内观.背景偏移Y+游戏设置.偏移Y)
ui.武器特效:setBlendType(物品内观.图标ID<=0 and F3DRenderContext.BLEND_NORMAL or F3DRenderContext.BLEND_ADD)
if 物品内观.特效ID~=0 then
ui.武器特效:setAnimPack(全局设置.getAnimPackUrl(物品内观.特效ID))
ui.武器特效:setPositionX(物品内观.图标ID<=0 and 物品内观.偏移X+游戏设置.偏移X or 物品内观.背景偏移X+游戏设置.偏移X)
ui.武器特效:setPositionY(物品内观.图标ID<=0 and 物品内观.偏移Y+游戏设置.偏移Y or 物品内观.背景偏移Y+游戏设置.偏移Y)
else
ui.武器特效:reset()
end
时装武器=true
elseif(not 游戏设置.MIRROLEPANEL or m_tabid2==0)and m_itemdata[1]and m_itemdata[1].count>0 and 物品内观表[游戏设置.ICONUSEID and m_itemdata[1].id or 全局设置.getFixedID(m_itemdata[1].icon)]then
local 物品内观=物品内观表[游戏设置.ICONUSEID and m_itemdata[1].id or 全局设置.getFixedID(m_itemdata[1].icon)]
ui.武器位置:setTextureFile(全局设置.getStateItemIconUrl(物品内观.图标ID))
ui.武器位置:setPositionX(物品内观.偏移X+游戏设置.偏移X)
ui.武器位置:setPositionY(物品内观.偏移Y+游戏设置.偏移Y)
ui.武器背景:setTextureFile(全局设置.getStateItemIconUrl(物品内观.背景图片))
ui.武器背景:setPositionX(物品内观.背景偏移X+游戏设置.偏移X)
ui.武器背景:setPositionY(物品内观.背景偏移Y+游戏设置.偏移Y)
ui.武器特效:setBlendType(物品内观.图标ID<=0 and F3DRenderContext.BLEND_NORMAL or F3DRenderContext.BLEND_ADD)
if 物品内观.特效ID~=0 then
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
if((not 游戏设置.MIRROLEPANEL and 角色逻辑.m_显示时装==1)or(游戏设置.MIRROLEPANEL and m_tabid2==1))and m_itemdata[23]and m_itemdata[23].count>0 and 物品内观表[游戏设置.ICONUSEID and m_itemdata[23].id or 全局设置.getFixedID(m_itemdata[23].icon)]then
local 物品内观=物品内观表[游戏设置.ICONUSEID and m_itemdata[23].id or 全局设置.getFixedID(m_itemdata[23].icon)]
ui.衣服位置:setTextureFile(全局设置.getStateItemIconUrl(物品内观.图标ID))
ui.衣服位置:setPositionX(物品内观.偏移X+游戏设置.偏移X)
ui.衣服位置:setPositionY(物品内观.偏移Y+游戏设置.偏移Y)
ui.衣服背景:setTextureFile(全局设置.getStateItemIconUrl(物品内观.背景图片))
ui.衣服背景:setPositionX(物品内观.背景偏移X+游戏设置.偏移X)
ui.衣服背景:setPositionY(物品内观.背景偏移Y+游戏设置.偏移Y)
ui.衣服特效:setBlendType(物品内观.图标ID<=0 and F3DRenderContext.BLEND_NORMAL or F3DRenderContext.BLEND_ADD)
if 物品内观.特效ID~=0 then
ui.衣服特效:setAnimPack(全局设置.getAnimPackUrl(物品内观.特效ID))
ui.衣服特效:setPositionX(物品内观.图标ID<=0 and 物品内观.偏移X+游戏设置.偏移X or 物品内观.背景偏移X+游戏设置.偏移X)
ui.衣服特效:setPositionY(物品内观.图标ID<=0 and 物品内观.偏移Y+游戏设置.偏移Y or 物品内观.背景偏移Y+游戏设置.偏移Y)
else
ui.衣服特效:reset()
end
ui.男:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2==0)and 物品内观.图标ID>=0 and 角色逻辑.m_rolesex==1)
ui.女:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2==0)and 物品内观.图标ID>=0 and 角色逻辑.m_rolesex==2)
ui.头盔位置:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2==0)and 物品内观.图标ID>=0)
ui.盾牌位置:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2==0)and 物品内观.图标ID>=0)
ui.盾牌特效:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2==0)and 物品内观.图标ID>=0)
			ui.武器位置:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2 == 0 or 时装武器) and 物品内观.图标ID >= 0)
			ui.武器背景:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2 == 0 or 时装武器) and 物品内观.图标ID >= 0)
			ui.武器特效:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2 == 0 or 时装武器) and 物品内观.图标ID >= 0)
			ui.翅膀位置:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2 == 0) and 物品内观.图标ID >= 0)
			ui.翅膀特效:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2 == 0) and 物品内观.图标ID >= 0)
elseif(not 游戏设置.MIRROLEPANEL or m_tabid2==0)and m_itemdata[2]and m_itemdata[2].count>0 and 物品内观表[游戏设置.ICONUSEID and m_itemdata[2].id or 全局设置.getFixedID(m_itemdata[2].icon)]then
local 物品内观=物品内观表[游戏设置.ICONUSEID and m_itemdata[2].id or 全局设置.getFixedID(m_itemdata[2].icon)]
ui.衣服位置:setTextureFile(全局设置.getStateItemIconUrl(物品内观.图标ID))
ui.衣服位置:setPositionX(物品内观.偏移X+游戏设置.偏移X)
ui.衣服位置:setPositionY(物品内观.偏移Y+游戏设置.偏移Y)
ui.衣服背景:setTextureFile(全局设置.getStateItemIconUrl(物品内观.背景图片))
ui.衣服背景:setPositionX(物品内观.背景偏移X+游戏设置.偏移X)
ui.衣服背景:setPositionY(物品内观.背景偏移Y+游戏设置.偏移Y)
ui.衣服特效:setBlendType(物品内观.图标ID<=0 and F3DRenderContext.BLEND_NORMAL or F3DRenderContext.BLEND_ADD)
if 物品内观.特效ID~=0 then
ui.衣服特效:setAnimPack(全局设置.getAnimPackUrl(物品内观.特效ID))
ui.衣服特效:setPositionX(物品内观.图标ID<=0 and 物品内观.偏移X+游戏设置.偏移X or 物品内观.背景偏移X+游戏设置.偏移X)
ui.衣服特效:setPositionY(物品内观.图标ID<=0 and 物品内观.偏移Y+游戏设置.偏移Y or 物品内观.背景偏移Y+游戏设置.偏移Y)
else
ui.衣服特效:reset()
end
ui.男:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2==0)and 物品内观.图标ID>=0 and 角色逻辑.m_rolesex==1)
ui.女:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2==0)and 物品内观.图标ID>=0 and 角色逻辑.m_rolesex==2)
ui.头盔位置:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2==0)and 物品内观.图标ID>=0)
ui.盾牌位置:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2==0)and 物品内观.图标ID>=0)
ui.盾牌特效:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2==0)and 物品内观.图标ID>=0)
			ui.武器位置:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2 == 0) and 物品内观.图标ID >= 0)
			ui.武器背景:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2 == 0) and 物品内观.图标ID >= 0)
			ui.武器特效:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2 == 0) and 物品内观.图标ID >= 0)
			ui.翅膀位置:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2 == 0) and 物品内观.图标ID >= 0)
			ui.翅膀特效:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2 == 0) and 物品内观.图标ID >= 0)
		else
			ui.衣服位置:setTextureFile("")
			ui.衣服背景:setTextureFile("")
			ui.衣服特效:reset()
			ui.男:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2 == 0) and 角色逻辑.m_rolesex == 1)
			ui.女:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2 == 0) and 角色逻辑.m_rolesex == 2)
			ui.头盔位置:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2 == 0) and true)
			ui.盾牌位置:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2 == 0) and true)
ui.盾牌特效:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2==0)and true)
			ui.武器位置:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2 == 0) and true)
			ui.武器背景:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2 == 0) and true)
			ui.武器特效:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2 == 0) and true)
			ui.翅膀位置:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2 == 0) and true)
			ui.翅膀特效:setVisible((not 游戏设置.MIRROLEPANEL or m_tabid2 == 0) and true)
		end
if 游戏设置.MIRROLEPANEL and m_itemdata[11]and m_itemdata[11].count>0 and 物品内观表[游戏设置.ICONUSEID and m_itemdata[11].id or 全局设置.getFixedID(m_itemdata[11].icon)]then
local 物品内观=物品内观表[游戏设置.ICONUSEID and m_itemdata[11].id or 全局设置.getFixedID(m_itemdata[11].icon)]
ui.头盔位置:setTextureFile(全局设置.getStateItemIconUrl(物品内观.图标ID))
ui.头盔位置:setPositionX(物品内观.偏移X+游戏设置.偏移X)
ui.头盔位置:setPositionY(物品内观.偏移Y+游戏设置.偏移Y)
elseif m_itemdata[3]and m_itemdata[3].count>0 and 物品内观表[游戏设置.ICONUSEID and m_itemdata[3].id or 全局设置.getFixedID(m_itemdata[3].icon)]then
local 物品内观=物品内观表[游戏设置.ICONUSEID and m_itemdata[3].id or 全局设置.getFixedID(m_itemdata[3].icon)]
ui.头盔位置:setTextureFile(全局设置.getStateItemIconUrl(物品内观.图标ID))
ui.头盔位置:setPositionX(物品内观.偏移X+游戏设置.偏移X)
ui.头盔位置:setPositionY(物品内观.偏移Y+游戏设置.偏移Y)
else
ui.头盔位置:setTextureFile("")
end
if m_itemdata[12]and m_itemdata[12].count>0 and 物品内观表[游戏设置.ICONUSEID and m_itemdata[12].id or 全局设置.getFixedID(m_itemdata[12].icon)]then
local 物品内观=物品内观表[游戏设置.ICONUSEID and m_itemdata[12].id or 全局设置.getFixedID(m_itemdata[12].icon)]
ui.面巾位置:setTextureFile(全局设置.getStateItemIconUrl(物品内观.图标ID))
ui.面巾位置:setPositionX(物品内观.偏移X+游戏设置.偏移X)
ui.面巾位置:setPositionY(物品内观.偏移Y+游戏设置.偏移Y)
else
ui.面巾位置:setTextureFile("")
end
if m_itemdata[22]and m_itemdata[22].count>0 and 物品内观表[游戏设置.ICONUSEID and m_itemdata[22].id or 全局设置.getFixedID(m_itemdata[22].icon)]then
local 物品内观=物品内观表[游戏设置.ICONUSEID and m_itemdata[22].id or 全局设置.getFixedID(m_itemdata[22].icon)]
ui.盾牌位置:setTextureFile(全局设置.getStateItemIconUrl(物品内观.图标ID))
ui.盾牌位置:setPositionX(物品内观.偏移X+游戏设置.偏移X)
ui.盾牌位置:setPositionY(物品内观.偏移Y+游戏设置.偏移Y)
ui.盾牌背景:setTextureFile(全局设置.getStateItemIconUrl(物品内观.背景图片))
ui.盾牌背景:setPositionX(物品内观.背景偏移X+游戏设置.偏移X)
ui.盾牌背景:setPositionY(物品内观.背景偏移Y+游戏设置.偏移Y)
ui.盾牌特效:setBlendType(物品内观.图标ID<=0 and F3DRenderContext.BLEND_NORMAL or F3DRenderContext.BLEND_ADD)
if 物品内观.特效ID~=0 then
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
if m_itemdata[24]and m_itemdata[24].count>0 and 物品内观表[游戏设置.ICONUSEID and m_itemdata[24].id or 全局设置.getFixedID(m_itemdata[24].icon)]then
local 物品内观=物品内观表[游戏设置.ICONUSEID and m_itemdata[24].id or 全局设置.getFixedID(m_itemdata[24].icon)]
ui.马牌位置:setTextureFile(全局设置.getStateItemIconUrl(物品内观.图标ID))
ui.马牌位置:setPositionX(物品内观.偏移X+游戏设置.偏移X)
ui.马牌位置:setPositionY(物品内观.偏移Y+游戏设置.偏移Y)
ui.马牌背景:setTextureFile(全局设置.getStateItemIconUrl(物品内观.背景图片))
ui.马牌背景:setPositionX(物品内观.背景偏移X+游戏设置.偏移X)
ui.马牌背景:setPositionY(物品内观.背景偏移Y+游戏设置.偏移Y)
ui.马牌特效:setBlendType(物品内观.图标ID<=0 and F3DRenderContext.BLEND_NORMAL or F3DRenderContext.BLEND_ADD)
if 物品内观.特效ID~=0 then
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
if m_itemdata[25]and m_itemdata[25].count>0 and 物品内观表[游戏设置.ICONUSEID and m_itemdata[25].id or 全局设置.getFixedID(m_itemdata[25].icon)]then
local 物品内观=物品内观表[游戏设置.ICONUSEID and m_itemdata[25].id or 全局设置.getFixedID(m_itemdata[25].icon)]
ui.法宝位置:setTextureFile(全局设置.getStateItemIconUrl(物品内观.图标ID))
ui.法宝位置:setPositionX(物品内观.偏移X+游戏设置.偏移X)
ui.法宝位置:setPositionY(物品内观.偏移Y+游戏设置.偏移Y)
ui.法宝背景:setTextureFile(全局设置.getStateItemIconUrl(物品内观.背景图片))
ui.法宝背景:setPositionX(物品内观.背景偏移X+游戏设置.偏移X)
ui.法宝背景:setPositionY(物品内观.背景偏移Y+游戏设置.偏移Y)
ui.法宝特效:setBlendType(物品内观.图标ID<=0 and F3DRenderContext.BLEND_NORMAL or F3DRenderContext.BLEND_ADD)
if 物品内观.特效ID~=0 then
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
if m_itemdata[26]and m_itemdata[26].count>0 and 物品内观表[游戏设置.ICONUSEID and m_itemdata[26].id or 全局设置.getFixedID(m_itemdata[26].icon)]then
local 物品内观=物品内观表[游戏设置.ICONUSEID and m_itemdata[26].id or 全局设置.getFixedID(m_itemdata[26].icon)]
ui.翅膀位置:setTextureFile(全局设置.getStateItemIconUrl(物品内观.图标ID))
ui.翅膀位置:setPositionX(物品内观.偏移X+游戏设置.偏移X)
ui.翅膀位置:setPositionY(物品内观.偏移Y+游戏设置.偏移Y)
ui.翅膀背景:setTextureFile(全局设置.getStateItemIconUrl(物品内观.背景图片))
ui.翅膀背景:setPositionX(物品内观.背景偏移X+游戏设置.偏移X)
ui.翅膀背景:setPositionY(物品内观.背景偏移Y+游戏设置.偏移Y)
ui.翅膀特效:setBlendType(物品内观.图标ID<=0 and F3DRenderContext.BLEND_NORMAL or F3DRenderContext.BLEND_ADD)
if 物品内观.特效ID~=0 then
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
	if not m_init or 角色逻辑==nil or 角色逻辑.m_rolejob==0 then
		return
	end
	if 游戏设置.MIRROLEPANEL and ui.tab2 then
		for i,v in ipairs(ui.panels[1]) do
			v:setVisible(m_tabid2 == 0)
		end
		for i,v in ipairs(ui.panels[2]) do
			v:setVisible(m_tabid2 == 1)
		end
		for i,v in ipairs(ui.panels[3]) do
			v:setVisible(m_tabid2 == 2)
		end
	end
	if not m_avt then
if IS3G then
			m_avt = F3DImageAnim3D:new()
			m_avt:setImage2D(true)
		else
			m_avt = F3DAvatar:new()
		end
		ui.avtcont:addChild(m_avt)
	end
	if m_rolejob ~= 角色逻辑.m_rolejob or m_bodyid ~= 角色逻辑.m_bodyid or m_weaponid ~= 角色逻辑.m_weaponid then
		m_avt:reset()
		if 显示内观 then
elseif IS3G then
			m_avt:setVisible(true)
			ui.男:setVisible(false)
			ui.女:setVisible(false)
			ui.内观位置:setVisible(false)
			m_avt:setScaleX(1)
			m_avt:setScaleY(1)
			m_avt:setEntity(F3DImageAnim3D.PART_BODY, 全局设置.getAnimPackUrl(角色逻辑.m_bodyid))
			m_avt:setEntity(F3DImageAnim3D.PART_HAIR, 全局设置.getMirHairUrl(角色逻辑.m_rolesex))
			if 角色逻辑.m_weaponid ~= 0 then
				m_avt:setEntity(F3DImageAnim3D.PART_WEAPON, 全局设置.getAnimPackUrl(角色逻辑.m_weaponid))
			end
		else
			m_avt:setVisible(true)
			ui.男:setVisible(false)
			ui.女:setVisible(false)
			ui.内观位置:setVisible(false)
			m_avt:setScale(1.5,1.5,1.5)
			m_avt:setShowShadow(true)
			m_avt:setLighting(true)
			m_avt:setEntity(F3DAvatar.PART_BODY, 全局设置.getBodyUrl(角色逻辑.m_bodyid))
			m_avt:setEntity(F3DAvatar.PART_FACE, 全局设置.getFaceUrl(角色逻辑.m_rolejob))
			m_avt:setEntity(F3DAvatar.PART_HAIR, 全局设置.getHairUrl(角色逻辑.m_rolejob))
			m_avt:setAnimSet(全局设置.getAnimsetUrl(角色逻辑.m_rolejob))
			if 角色逻辑.m_weaponid ~= 0 then
				m_avt:setEntity(F3DAvatar.PART_WEAPON, 全局设置.getWeaponUrl(角色逻辑.m_weaponid))
			end
		end
		m_rolejob = 角色逻辑.m_rolejob
		m_bodyid = 角色逻辑.m_bodyid
		m_weaponid = 角色逻辑.m_weaponid
	end
	if m_bodyeff ~= 角色逻辑.m_bodyeff or m_weaponeff ~= 角色逻辑.m_weaponeff then
		if 显示内观 then
elseif IS3G then
			if m_bodyeff < 0 then
				m_avt:removeEffectSystem(全局设置.getAnimPackUrl(-m_bodyeff,true))
			elseif m_bodyeff < 0 then
				m_avt:removeEntity(F3DImageAnim3D.PART_BODY_EFFECT)
			end
			if m_weaponeff ~= 0 then
				m_avt:removeEntity(F3DImageAnim3D.PART_WEAPON_EFFECT)
			end
			if 角色逻辑.m_bodyeff < 0 then
				m_avt:setEffectSystem(全局设置.getAnimPackUrl(-角色逻辑.m_bodyeff,true), true, nil, nil, 0, -1)
			elseif 角色逻辑.m_bodyeff > 0 then
				m_avt:setEntity(F3DImageAnim3D.PART_BODY_EFFECT, 全局设置.getAnimPackUrl(角色逻辑.m_bodyeff)):setBlendType(F3DRenderContext.BLEND_ADD)
			end
			if 角色逻辑.m_weaponeff ~= 0 then
				m_avt:setEntity(F3DImageAnim3D.PART_WEAPON_EFFECT, 全局设置.getAnimPackUrl(角色逻辑.m_weaponeff)):setBlendType(F3DRenderContext.BLEND_ADD)
			end
		else
			if m_bodyeff ~= 0 then
				m_avt:removeEffectSystem(全局设置.getEffectUrl(m_bodyeff))
			end
			if m_weaponeff ~= 0 then
				m_avt:removeEffectSystem(全局设置.getEffectUrl(m_weaponeff))
			end
			if 角色逻辑.m_bodyeff ~= 0 then
				m_avt:setEffectSystem(全局设置.getEffectUrl(角色逻辑.m_bodyeff), true)
			end
			if 角色逻辑.m_weaponeff ~= 0 then
				m_avt:setEffectSystem(全局设置.getEffectUrl(角色逻辑.m_weaponeff), true)
			end
		end
		m_bodyeff = 角色逻辑.m_bodyeff
		m_weaponeff = 角色逻辑.m_weaponeff
	end
	local p = 角色逻辑.m_rolename:find("\\")
	local name = string.gsub(txt(角色逻辑.m_rolename),"s0.","")
	ui.rolename:setTitleText(rolename)
	ui.rolename:setTitleText(p and txt(角色逻辑.m_rolename:sub(1,p-1)) or txt(角色逻辑.m_rolename))
	ui.rolejob:setTitleText(txt(全局设置.获取职业类型(角色逻辑.m_rolejob)))
	ui.level:setTitleText(角色逻辑.m_level..(角色逻辑.m_转生等级 > 0 and txt(" ("..角色逻辑.m_转生等级.."转"..")") or ""))
	ui.生命值:setTitleText(角色逻辑.m_hpmax)
	ui.魔法值:setTitleText(角色逻辑.m_mpmax)
	ui.防御:setTitleText(角色逻辑.m_防御.."-"..角色逻辑.m_防御上限)
	ui.魔御:setTitleText(角色逻辑.m_魔御.."-"..角色逻辑.m_魔御上限)
	ui.攻击:setTitleText(角色逻辑.m_攻击.."-"..角色逻辑.m_攻击上限)
	ui.魔法:setTitleText(角色逻辑.m_魔法.."-"..角色逻辑.m_魔法上限)
	ui.道术:setTitleText(角色逻辑.m_道术.."-"..角色逻辑.m_道术上限)
	ui.幸运:setTitleText("+ "..角色逻辑.m_幸运)
	ui.准确:setTitleText("+ "..角色逻辑.m_准确)
	ui.敏捷:setTitleText("+ "..角色逻辑.m_敏捷)
	ui.魔法命中:setTitleText("+ "..角色逻辑.m_魔法命中.."%")
	ui.魔法躲避:setTitleText("+ "..角色逻辑.m_魔法躲避.."%")
	ui.生命恢复:setTitleText("+ "..角色逻辑.m_生命恢复)
	ui.魔法恢复:setTitleText("+ "..角色逻辑.m_魔法恢复)
	ui.中毒恢复:setTitleText("+ "..角色逻辑.m_中毒恢复.."%")
	ui.攻击速度:setTitleText("+ "..角色逻辑.m_攻击速度.."%")
	ui.移动速度:setTitleText(角色逻辑.m_speed)
	ui.经验值:setTitleText(math.floor(角色逻辑.m_exp*100/角色逻辑.m_expmax).."%")
	if ui.PK值 then
		ui.PK值:setTitleText(角色逻辑.m_PK值 or 0)
	end
	实用工具.setClipNumber(角色逻辑.m_power,ui.zhanli,true)
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

function checkTipsPos()
	if not ui or not tipsgrid then
		return
	end
	if not tipsui or not tipsui:isVisible() or not tipsui:isInited() then
	else
		local x = ui:getPositionX()+tipsgrid:getPositionX()+tipsgrid:getWidth()
		local y = ui:getPositionY()+tipsgrid:getPositionY()
		if x + tipsui:getWidth() > stage:getWidth() then
			tipsui:setPositionX(x - tipsui:getWidth() - tipsgrid:getWidth())
		else
			tipsui:setPositionX(x)
		end
		if y + tipsui:getHeight() > stage:getHeight() then
			tipsui:setPositionY(stage:getHeight() - tipsui:getHeight())
		else
			tipsui:setPositionY(y)
		end
	end
end

function onGridOver(e)
	if ui.tweenhide then return end
	local g = g_mobileMode and e:getCurrentTarget() or e:getTarget()
	if g == nil or m_itemdata[g.id] == nil or m_itemdata[g.id].id == 0 then
	elseif F3DUIManager.sTouchComp ~= g then
	else
		装备提示UI.initUI()
		装备提示UI.setItemData(m_itemdata[g.id], true, false, true)
		tipsui = 装备提示UI.ui
		tipsgrid = g
		if not tipsui:isInited() then
			tipsui:addEventListener(F3DObjEvent.OBJ_INITED, func_oe(checkTipsPos))
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

function setTabID2(tabid)
	if m_tabid2 == tabid then
		return
	end
	m_tabid2 = tabid
	if m_init then
		ui.tab2:setSelectIndex(m_tabid2)
	end
end

function onTabChange2(e)
	m_tabid2 = ui.tab2:getSelectIndex()
	update()
	updateEquips()
end

function onUIInit()
	ui.close = ui:findComponent("titlebar,close")
	ui.close:addEventListener(F3DMouseEvent.CLICK, func_me(onClose))
	ui:addEventListener(F3DMouseEvent.MOUSE_DOWN, func_me(onMouseDown))
	ui.avtcont = ui:findComponent("avtcont")
	ui.rolerect = ui:findComponent("rolerect")
	ui.rolerect:addEventListener(F3DMouseEvent.MOUSE_DOWN, func_me(function (e)
		if m_avt then
			m_downposx = e:getStageX()
		end
	end))
	ui.rolerect:addEventListener(F3DMouseEvent.MOUSE_MOVE, func_me(function (e)
		if m_avt then
if IS3G then
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
	ui.PK值=ui.属性 and ui:findComponent("属性,PK值")or ui:findComponent("PK值")
	ui.zhanli = ui:findComponent("zhan_shuzhi"):getBackground()
	ui.equips = {}
	ui.grids = {}
	for i=1,EQUIPMAX do
		local grid = ui:findComponent("equippos_"..i)
		if grid then
			tdisui(grid)
			grid.id = i
			if g_mobileMode then
				grid:addEventListener(F3DMouseEvent.CLICK, func_me(onGridOver))
			else
				grid:addEventListener(F3DUIEvent.MOUSE_OVER, func_ue(onGridOver))
				grid:addEventListener(F3DUIEvent.MOUSE_OUT, func_ue(onGridOut))
			end
			ui.grids[i] = grid
			local equip = F3DImage:new()
			equip:setPositionX(math.floor(grid:getWidth()/2))
			equip:setPositionY(math.floor(grid:getHeight()/2))
			equip:setPivot(0.5,0.5)
equip.effect=nil
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
			equip.strengthen:setPositionX(g_mobileMode and grid:getWidth()-8 or grid:getWidth()-4)--35)
			equip.strengthen:setPositionY(g_mobileMode and 8 or 4)--3)
			equip.strengthen:setPivot(1,0)
			grid:addChild(equip.strengthen)
			if 游戏设置.MIRROLEPANEL and 游戏设置.EQUIPPOSHIDE and 实用工具.FindIndex(游戏设置.EQUIPPOSHIDE, i) then
				equip:setVisible(false)
				equip.grade:setVisible(false)
				equip.lock:setVisible(false)
				equip.strengthen:setVisible(false)
			end
		end
	end
	for i=1,7 do
local addpoint=ui.属性 and ui:findComponent("属性,btn_add_"..i)or ui:findComponent("btn_add_"..i)
addpoint:setVisible(false)
end
if g_mobileMode then
local 加点背景=ui.属性 and ui:findComponent("属性,加点背景")or ui:findComponent("加点背景")
if 加点背景 then
加点背景:setVisible(false)
end
end
local 剩余点数=ui.属性 and ui:findComponent("属性,剩余点数")or ui:findComponent("剩余点数")
if 剩余点数 then
剩余点数:setVisible(false)
end
	ui.tab = tt(ui:findComponent("tab_1"), F3DTab)
	ui.tab:setVisible(false)
	if 游戏设置.MIRROLEPANEL and ui:findComponent("tab_2") then
		ui.tab2 = tt(ui:findComponent("tab_2"), F3DTab)
		for i=3,5 do
			if ui.tab2:getTabBtn(i) then
				ui.tab2:getTabBtn(i):setTitleText("")
				ui.tab2:getTabBtn(i):setDisable(true)
			end
		end
		ui.tab2:setSelectIndex(m_tabid2)
		ui.tab2:addEventListener(F3DUIEvent.CHANGE, func_ue(onTabChange2))
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
	ui.显示时装:setVisible(false)
	ui.显示炫武 = tt(ui:findComponent("显示炫武"),F3DCheckBox)
	ui.显示炫武:setVisible(false)
	ui.召唤英雄 = ui:findComponent("call")
	if ui.召唤英雄 then
		ui.召唤英雄:setVisible(false)
	end
	ui.生肖 = ui:findComponent("生肖")
	if ui.生肖 then
		local 生肖位置 = ui:findComponent("生肖位置")
		local ox = ui.生肖:getPositionX()-生肖位置:getPositionX()
		local oy = ui.生肖:getPositionY()-生肖位置:getPositionY()
		if 游戏设置.EQUIPPOSTWO then
			for i,v in ipairs(游戏设置.EQUIPPOSTHREE) do
				if ui.grids[v] then
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
		ui.生肖显示:addEventListener(F3DMouseEvent.CLICK, func_me(function (e)
			if ui.生肖:isVisible() then
				if 游戏设置.EQUIPPOSTWO then
					for i,v in ipairs(游戏设置.EQUIPPOSTHREE) do
						if ui.grids[v] then
							ui.grids[v]:setVisible(false)
						end
					end
				end
				ui.生肖:setVisible(false)
			else
				if 游戏设置.EQUIPPOSTWO then
					for i,v in ipairs(游戏设置.EQUIPPOSTHREE) do
						if ui.grids[v] then
							ui.grids[v]:setVisible(true)
						end
					end
				end
				ui.生肖:setVisible(true)
			end
		end))
		ui.生肖关闭 = ui:findComponent("生肖,close")
		if ui.生肖关闭 then
			ui.生肖关闭:addEventListener(F3DMouseEvent.CLICK, func_me(function (e)
				if 游戏设置.EQUIPPOSTWO then
					for i,v in ipairs(游戏设置.EQUIPPOSTHREE) do
						if ui.grids[v] then
							ui.grids[v]:setVisible(false)
						end
					end
				end
				ui.生肖:setVisible(false)
			end))
		end
	end
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
		if 游戏设置.MIRROLEPANEL and ui.tab2 then
			ui.panels = {}
			ui.panels[1] = {}
				if ui.角色背景 then
					ui.panels[1][#ui.panels[1]+1] = ui.角色背景
				end
				if ui.生肖显示 then
					ui.panels[1][#ui.panels[1]+1] = ui.生肖显示
				end
		end--新加			
		for i=1,EQUIPMAX do
			if ui.grids[i] and
				(not 游戏设置.EQUIPPOSTWO or not 实用工具.FindIndex(游戏设置.EQUIPPOSTWO, i)) and
				(not 游戏设置.EQUIPPOSTHREE or not 实用工具.FindIndex(游戏设置.EQUIPPOSTHREE, i)) then
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
			for i,v in ipairs(游戏设置.EQUIPPOSTWO) do
				ui.panels[2][#ui.panels[2]+1] = ui.grids[v]
			end
		end
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
		ui.panels[3][#ui.panels[3]+1] = ui.防御
		ui.panels[3][#ui.panels[3]+1] = ui.魔御
		ui.panels[3][#ui.panels[3]+1] = ui.攻击
		ui.panels[3][#ui.panels[3]+1] = ui.魔法
		ui.panels[3][#ui.panels[3]+1] = ui.道术
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
		for i=1,22 do
			ui.panels[3][#ui.panels[3]+1] = ui:findComponent("component_"..i)
		end
		local 属性位置 = ui:findComponent("属性位置") or ui.男
		local ox = ui.panels[3][1]:getPositionX()-属性位置:getPositionX()
		local oy = ui.panels[3][1]:getPositionY()-属性位置:getPositionY()
		for i,v in ipairs(ui.panels[3]) do
			v:setPositionX(v:getPositionX()-ox)
			v:setPositionY(v:getPositionY()-oy)
		end
	end
	m_init = true
	update()
	updateEquips()
end
function isHided()
	return not ui or not ui:isVisible() or ui.tweenhide
end

function hideUI()
	if tipsui then
		装备提示UI.hideUI()
		tipsui = nil
		tipsgrid = nil
	end
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
		if m_avt then
if IS3G then
				m_avt:setAnimRotationZ(0)
			else
				m_avt:setRotationZ(0)
			end
		end
_v_62(ui,true)
		return
	end
	ui = F3DLayout:new()
	uiLayer:addChild(ui)
	ui:setLoadPriority(getUIPriority())
	ui:setMovable(true)
	ui:addEventListener(F3DObjEvent.OBJ_INITED, func_e(onUIInit))
if ui.setUIPack and USEUIPACK then
ui:setUIPack(g_mobileMode and UIPATH.."角色UIm.pack"or UIPATH.."角色UI.pack")
else
ui:setLayout(g_mobileMode and UIPATH.."角色UIm.layout"or UIPATH.."角色UI.layout")
end

_v_62(ui,true)
end