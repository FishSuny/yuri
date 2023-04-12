module(..., package.seeall)

local 全局设置 = require("公用.全局设置")
local 游戏设置 = require("公用.游戏设置")
local 实用工具 = require("公用.实用工具")
local 消息 = require("网络.消息")
local 小地图UI = require("主界面.小地图UI")
local 任务追踪UI = require("主界面.任务追踪UI")
local 聊天UI = require("主界面.聊天UI")
local 聊天UID = require("主界面.聊天UID")
local 角色UI = require("主界面.角色UI")
local 背包UI = require("主界面.背包UI")
local 头像信息UI = require("主界面.头像信息UI")
local 英雄信息UI = require("主界面.英雄信息UI")
local 宠物UI = require("宠物.宠物UI")
local 技能逻辑 = require("技能.技能逻辑")
local 宠物信息UI = require("宠物.宠物信息UI")
local 技能UI = require("技能.技能UI")
local 锻造UI = require("主界面.锻造UI")
local 商城UI = require("主界面.商城UI")
local 角色逻辑 = require("主界面.角色逻辑")
local 获得提示UI = require("主界面.获得提示UI")
local Boss信息UI = require("主界面.Boss信息UI")
local 队伍信息UI = require("主界面.队伍信息UI")
local 目标信息UI = require("主界面.目标信息UI")
local 活动UI = require("主界面.活动UI")
local 简单提示UI = require("主界面.简单提示UI")
local 地图表 = require("配置.地图表")
local 物品提示UI = require("主界面.物品提示UI")
local 装备提示UI = require("主界面.装备提示UI")
local 装备对比提示UI = require("主界面.装备对比提示UI")
local 宠物蛋提示UI = require("主界面.宠物蛋提示UI")
local 行会UI = require("主界面.行会UI")
local 消息框UI1 = require("主界面.消息框UI1")
local 网络连接 = require("公用.网络连接")
local 登录UI=require("登录.登录UI")
local 选区UI=require("登录.选区UI")
local 行会UI = require("主界面.行会UI")
local 队伍UI = require("主界面.队伍UI")
local 寄售UI = require("主界面.寄售UI")
local Buff表 = require("配置.Buff表").Config
local 排行榜UI=require("主界面.排行榜UI")

local 目标信息UI = require("主界面.目标信息UI")
local nameid = 目标信息UI.m_goalinfo
	
	
	
sound=nil
m_init = false
m_tipsmsgcont1 = nil
m_tipsmsgcont2 = nil
m_tipsmsgcont3 = nil
m_tipsmsgcont4 = nil
m_tipsmsgs = {}
m_tipsrollmsgs = {}
m_tipsmsg3 = nil
m_tipsheartbeat = 0
m_tipsrollheartbeat1 = 0
m_tipsrollheartbeat2 = 0
m_showtipstime = 0
m_showtipsmsg = {}
m_quickid = nil
m_skillquickid = nil
m_xpinfo = nil
m_ptcache = F3DPoint:new()
m_startMoveDir = false
m_startMoveDir2 = false
m_chassisDown = false
m_chassisDown2 = false
m_touchid = -1
m_touchid2 = -1
m_equiptipsui = nil
m_equiptipsdown = nil
tipsskill = nil
tipsskillmove = false
tipsui = nil
tipsgrid = nil
m_autofight = nil
m_autofindpath = nil
CHASSISOFFSET = 游戏设置.ROCKEROFFSET or 0

prop4 = F3DTweenProp:new()
sound=nil


LastNPC = 0
zuixinid = 0


function removeUI()
if ui then
if ui.anim then
ui.anim:removeFromParent(true)
ui.anim=nil
end
if ui.animx then
ui.animx:removeFromParent(true)
ui.animx=nil
end
ui:removeFromParent(true)
ui=nil
end
if sound then
sound:destory()
sound=nil
end
m_init=false
m_info={}
end

function upd111ate()
if not m_init or not m_goalinfo then
return
end
if m_goalinfo.objid~=-1 then
ui:setVisible(true)
local p1=m_goalinfo.name:find("#c")
local p2=p1 and m_goalinfo.name:find("%[",p1+2)or nil
local _v_1636=p2 and m_goalinfo.name:sub(1,p2-1)or m_goalinfo.name
local belong=p2 and m_goalinfo.name:sub(p2)or""
local namecolor=p1 and tonumber("0x".._v_1636:sub(p1+2))or 0xffffff
local name=p1 and _v_1636:sub(1,p1-1)or _v_1636
local p=name:find("\\")
ui.rolename:setTitleText(p and txt(name:sub(1,p-1)..belong)or txt(name..belong))
ui.rolename:setTextColor(namecolor)
ui.level:setTitleText((m_goalinfo.lv and m_goalinfo.lv>=0)and m_goalinfo.lv or-1)
ui.hp:setPercent(m_goalinfo.hp/m_goalinfo.hpmax)
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

	ui.转生修为 = ui:findComponent("right,转生修为")
	if 转生修为显示 and not g_mobileMode then
	ui.转生修为:setTextColor(0x00FF00)
	ui.转生修为:setTitleText(txt("修为：")..(角色逻辑.m_level > 54 and math.floor(角色逻辑.m_转生修为*100/角色逻辑.m_转生经验上限).."%" or txt("未开启")))
	elseif 转生修为显示 and g_mobileMode then
	ui.转生修为:setTextColor(0x00FF00)
	ui.转生修为:setTitleText((角色逻辑.m_level > 54 and math.floor(角色逻辑.m_转生修为*100/角色逻辑.m_转生经验上限).."%" or txt("未开启")))
else
--ui.转生修为:setTitleText("")
	end
	if g_mobileMode then
		ui.exptext1 = ui:findComponent("exp,exptext1")--自定义经验显示
		ui.exptext1:setTitleText(角色逻辑.m_exp.." / "..角色逻辑.m_expmax)
		ui.时间 = ui:findComponent("exp,时间")
		ui.时间:setTitleText(txt(角色逻辑.m_当前小时..":"..角色逻辑.m_当前分钟..":"..角色逻辑.m_当前秒))
end
end

function update()
	角色逻辑.m_mpmax = 角色逻辑.m_mpmax
	if not m_init then return end
	if not g_mobileMode and ISMIRUI then
		ui.level:setTitleText(角色逻辑.m_level)
	if 角色逻辑.m_hpmax >=100000000 then
		ui.hp:setTitleText(" "..string.format(txt("%.2f亿"),角色逻辑.m_hpmax/100000000))
	elseif 角色逻辑.m_hpmax >= 10000000 then
		ui.hp:setTitleText(" "..string.format(txt("%.2f千万"),角色逻辑.m_hpmax/10000000))
	elseif 角色逻辑.m_hpmax >= 1000000 then
		ui.hp:setTitleText(" "..string.format(txt("%.2f百万"),角色逻辑.m_hpmax/1000000))
	elseif 角色逻辑.m_hpmax >= 100000 then
		ui.hp:setTitleText(" "..string.format(txt("%.2f十万"),角色逻辑.m_hpmax/100000))
	elseif 角色逻辑.m_hpmax >= 10000 then
		ui.hp:setTitleText(" "..string.format(txt("%.2f万"),角色逻辑.m_hpmax/10000))
	else
		ui.hp:setTitleText(" "..角色逻辑.m_hpmax)
		
	end
		ui.mp:setTitleText(" "..角色逻辑.m_mpmax)
		ui.weight:setMaxVal(背包UI.BAG_CAP)
		ui.weight:setCurrVal(背包UI.BAG_CAP-背包UI.getLeftCount())
		ui.pkmode:setTitleText(头像信息UI.m_pkmode == 0 and txt("[和平模式]") or 头像信息UI.m_pkmode == 1 and txt("[组队模式]") or txt("[行会模式]"))
	--	ui.pkmode:setTitleText(地图表.Config[g_mapid].safemap == 1 and txt("[安全地图无法PK]") or
	--	角色逻辑.m_level >= 11 and txt("[全体攻击模式]") or txt("[11级以下无法PK]"))
	end
	ui.转生修为 = ui:findComponent("right,转生修为")
	if 转生修为显示 and not g_mobileMode then
	ui.转生修为:setTextColor(0x00FF00)
	ui.转生修为:setTitleText(txt("修为：")..(角色逻辑.m_level > 54 and math.floor(角色逻辑.m_转生修为*100/角色逻辑.m_转生经验上限).."%" or txt("未开启")))
	elseif 转生修为显示 and g_mobileMode then
	ui.转生修为:setTextColor(0x00FF00)
	ui.转生修为:setTitleText((角色逻辑.m_level > 54 and math.floor(角色逻辑.m_转生修为*100/角色逻辑.m_转生经验上限).."%" or txt("未开启")))
else
--ui.转生修为:setTitleText("")
	end
	if g_mobileMode then
		ui.exptext1 = ui:findComponent("exp,exptext1")--自定义经验显示
		ui.exptext1:setTitleText(角色逻辑.m_exp.." / "..角色逻辑.m_expmax)
		ui.时间 = ui:findComponent("exp,时间")
		--ui.时间:setTitleText(txt(角色逻辑.m_当前小时..":"..角色逻辑.m_当前分钟..":"..角色逻辑.m_当前秒))
		ui.时间:setTitleText(txt("1"..":".."2"..":".."3"))
end
end

function updateExp()
	if not m_init or not ui.exp then return end
	ui.exp:setMaxVal(角色逻辑.m_expmax)
	ui.exp:setCurrVal(角色逻辑.m_exp)
end

function updatePower()
	if not m_init or not ui.zhanli then return end
	实用工具.setClipNumber(角色逻辑.m_totalpower,ui.zhanli)
end

function setXPInfo(status,cd,cdmax,icon)
	m_xpinfo = {status=status,cd=cd,cdmax=cdmax,icon=icon}
	updateXP()
end

function updateXP()
	if not m_init or not m_xpinfo or not ui.xphead then return end
	if m_xpinfo.status == 0 then
		ui.xphead:setVisible(false)
		ui.xptext:setVisible(false)
		ui.xpprogress:setCurrVal(m_xpinfo.cd)
		ui.xpprogress:setMaxVal(m_xpinfo.cdmax)
		ui.xpprogress:doAnim(m_xpinfo.cdmax, (m_xpinfo.cdmax - m_xpinfo.cd) / 1000)
	elseif m_xpinfo.status == 1 then
		ui.xphead:setVisible(true)
		ui.xpimg:setTextureFile(全局设置.getSkillIconUrl(m_xpinfo.icon))
		ui.xptext:setVisible(true)
		ui.xpprogress:setCurrVal(m_xpinfo.cd)
		ui.xpprogress:setMaxVal(m_xpinfo.cdmax)
	elseif m_xpinfo.status == 2 then
		ui.xphead:setVisible(false)
		ui.xptext:setVisible(false)
		ui.xpprogress:setCurrVal(m_xpinfo.cd)
		ui.xpprogress:setMaxVal(m_xpinfo.cdmax)
		ui.xpprogress:doAnim(0, m_xpinfo.cd / 1000)
	end
end

function setQuickData(id)
	m_quickid = id
	updateQuick()
end

function setSkillQuickData(id)
	m_skillquickid = id
	updateSkill()
end

function initBGUI()
	bg = F3DComponent:new()
	bg:setPositionX(stage:getWidth()/5)
	bg:setPositionY(stage:getHeight()-stage:getHeight()/5)
	bg:setBackground("/res/game/direction_key_2.png")
	bg:getBackground():setPivot(0.5,0.5)
	bg:setAlpha(0.5)
	uiLayer:addChild(bg)

	btn = F3DComponent:new()
	btn:setBackground("/res/game/direction_key_1.png")
	btn:getBackground():setPivot(0.5,0.5)
	bg:addChild(btn)
end

function checkSkillQuickPos(px, py)
	if not m_init then return end
	--local top = ui:findComponent("top")
	local x = px - ui:getPositionX()-- - top:getPositionX()
	local y = py - ui:getPositionY()-- - top:getPositionY()
	local qbg = ui.skillbgs[1]
	while qbg and qbg:getParent() and qbg:getParent() ~= ui do
		qbg = qbg:getParent()
		x = x - qbg:getPositionX()
		y = y - qbg:getPositionY()
	end
	for i=1,8 do
		local skillbg = ui.skillbgs[i]
		if x >= skillbg:getPositionX() and x <= skillbg:getPositionX() + skillbg:getWidth() and
			y >= skillbg:getPositionY() and y <= skillbg:getPositionY() + skillbg:getHeight() then
			return i
		end
	end
end

function setSkillQuickItem(id, infoid)
	if not m_init or not m_skillquickid then return end
	for i=1,8 do
		if m_skillquickid[i] == infoid then
			m_skillquickid[i] = 0
		end
	end
	m_skillquickid[id] = infoid
	消息.CG_SKILL_QUICK_SETUP(m_skillquickid)
end

function checkQuickPos(px, py)
	if not m_init then return end
	--local top = ui:findComponent("top")
	local x = px - ui:getPositionX()-- - top:getPositionX()
	local y = py - ui:getPositionY()-- - top:getPositionY()
	local qbg = ui.quickbgs[1]
	while qbg and qbg:getParent() and qbg:getParent() ~= ui do
		qbg = qbg:getParent()
		x = x - qbg:getPositionX()
		y = y - qbg:getPositionY()
	end
	for i=1,6 do
		local quickbg = ui.quickbgs[i]
		if x >= quickbg:getPositionX() and x <= quickbg:getPositionX() + quickbg:getWidth() and
			y >= quickbg:getPositionY() and y <= quickbg:getPositionY() + quickbg:getHeight() then
			return i
		end
	end
end

function setQuickItem(id, itemid)
	if not m_init or not m_quickid then return end
	for i=1,6 do
		if m_quickid[i] == itemid then
			m_quickid[i] = 0
		end
	end
	m_quickid[id] = itemid
	消息.CG_QUICK_SETUP(m_quickid)
end

function setQuick(i, itemid)
	if not m_init then return end
	if ui.quickimg[i].itemid == itemid then
		return
	end
	if itemid == 0 then
		ui.quickimg[i].pic:setTextureFile("")
		ui.quickcnt[i]:setText("")
		ui.quickcdimg[i]:setFrameRate(0)
		ui.quickcdimg[i]:setVisible(false)
		ui.quickimg[i].itemid = 0
		return
	end
	local icon = 背包UI.getItemIcon(itemid)
	ui.quickimg[i].itemid = itemid
	ui.quickimg[i].pic:setTextureFile(全局设置.getItemIconUrl(icon))
	ui.quickcnt[i]:setText(背包UI.getItemCount(itemid))
	local cd, cdmax = 背包UI.getItemCD(itemid), 背包UI.getItemCDMax(itemid)
	if cd > rtime() and cdmax > 0 then
		local frameid = math.floor((1 - (cd - rtime()) / cdmax) * 32)
		ui.quickcdimg[i]:setVisible(true)
		ui.quickcdimg[i]:setFrameRate(1000*(32-frameid)/(cd - rtime()), frameid)
	else
		ui.quickcdimg[i]:setFrameRate(0)
		ui.quickcdimg[i]:setVisible(false)
	end
end

function updateQuick()
	if not m_init or not m_quickid then return end
	for i=1,6 do
		setQuick(i, m_quickid[i] or 0)
	end
end

function updateQuickItem()
	if not m_init then return end
	for i=1,6 do
		if ui.quickimg[i].itemid ~= 0 then
			local icon = 背包UI.getItemIcon(ui.quickimg[i].itemid)
			if icon ~= 0 then
				ui.quickimg[i].pic:setTextureFile(全局设置.getItemIconUrl(icon))
			end
			ui.quickcnt[i]:setText(背包UI.getItemCount(ui.quickimg[i].itemid))
			local cd, cdmax = 背包UI.getItemCD(ui.quickimg[i].itemid), 背包UI.getItemCDMax(ui.quickimg[i].itemid)
			if cd > rtime() and cdmax > 0 then
				local frameid = math.floor((1 - (cd - rtime()) / cdmax) * 32)
				ui.quickcdimg[i]:setVisible(true)
				ui.quickcdimg[i]:setFrameRate(1000*(32-frameid)/(cd - rtime()), frameid)
			else
				ui.quickcdimg[i]:setFrameRate(0)
				ui.quickcdimg[i]:setVisible(false)
			end
		end
	end
end

function DoUseQuick(id)
	if not m_init then return end
	if ui.quickimg[id] and ui.quickimg[id].itemid ~= 0 then
		背包UI.DoUseItem(ui.quickimg[id].itemid)
	end
end

function checkKeyCode(keyCode)
	if not m_init or not m_skillquickid then
		return
	end
	for i,v in ipairs(技能逻辑.keyCodes) do
		if v == keyCode and m_skillquickid[i] ~= 0 then
			local id = nil
			if i == 1 and g_role:isHitFly() then
				id = 技能逻辑.findJumpSkillIndex()
			elseif i == 1 and g_role.status == 1 and g_role:getAnimName() == "run" then
				id = 技能逻辑.findRunSkillIndex()
			else
				id = 技能逻辑.findSkillIndex(m_skillquickid[i])
			end
			return id
		end
	end
end

function updateSkill()
	if not m_init or not m_skillquickid then return end
	for i=1,8 do
		local id = 技能逻辑.findSkillIndex(m_skillquickid[i])
		if id and (not g_mobileMode or i > ((ISWZ or ISZY) and 1 or 1)) then
			ui.skillbgs[i].id = id
			local icon = g_skill[id].icon
			ui.skillimg[i]:setTextureFile(icon > 10000 and 全局设置.getBossHeadUrl(icon) or 全局设置.getSkillIconUrl(icon))
		else
			ui.skillbgs[i].id = id or 0
			ui.skillimg[i]:setTextureFile("")
			ui.skillcdimg[i]:setFrameRate(0)
			ui.skillcdimg[i]:setVisible(false)
		end
	end
end

function disableSkill(index, time)
	if not m_init or not m_skillquickid then return end
	for i=1,8 do
		if m_skillquickid[i] == index then
			ui.skillcdimg[i]:setVisible(true)
			ui.skillcdimg[i]:setFrameRate(((ISWZ or ISZY) and i == 1 and 14000 or 32000)/time, 0)
			break
		end
	end
end

function onCDPlayOut(e)
	e:getTarget():setFrameRate(0)
	e:getTarget():setVisible(false)
end

function onSkillGridDown(e)
	local g = e:getCurrentTarget()
	if g == nil or g_skill[g.id] == nil then
		return
	end
	local p = e:getLocalPos()
	if g then
		ui.skillbgs[g.pid]:removeChild(ui.skillimg[g.pid])
		ui:addChild(ui.skillimg[g.pid])---是否固定拖动技能
		local x = g:getPositionX() + (ISMIRUI and 3 or 6)
		local y = g:getPositionY() + (ISMIRUI and 2 or 5)
		local p = g:getParent()
		while p and p ~= ui do
			x = x + p:getPositionX()
			y = y + p:getPositionY()
			p = p:getParent()
		end
		ui.skillimg[g.pid]:setPositionX(x)
		ui.skillimg[g.pid]:setPositionY(y)
	end
	ui.skillgriddownpos = {x=p.x,y=p.y}
end

function onSkillGridMove(e)
	if ui.skillgriddownpos == nil then
		return
	end
	local g = e:getCurrentTarget()
	local p = e:getLocalPos()
	if g then
		local x = p.x - ui.skillgriddownpos.x + g:getPositionX() + (ISMIRUI and 3 or 6)
		local y = p.y - ui.skillgriddownpos.y + g:getPositionY() + (ISMIRUI and 2 or 5)
		local p = g:getParent()
		while p and p ~= ui do
			x = x + p:getPositionX()
			y = y + p:getPositionY()
			p = p:getParent()
		end
		ui.skillimg[g.pid]:setPositionX(x)
		ui.skillimg[g.pid]:setPositionY(y)
	end
end

function onSkillGridUp(e)
	if ui.skillgriddownpos == nil then
		return
	end
	local g = e:getCurrentTarget()
	local p = e:getLocalPos()
	if g then
		local x = ui.skillimg[g.pid]:getPositionX() + ui.skillgriddownpos.x
		local y = ui.skillimg[g.pid]:getPositionY() + ui.skillgriddownpos.y
		if x < 0 or x > ui:getWidth() or y < (ISMIRUI and 0 or -50) or y > ui:getHeight() then
			x = x + ui:getPositionX()
			y = y + ui:getPositionY()
			setSkillQuickItem(g.pid, 0)
		else
			x = x + ui:getPositionX()
			y = y + ui:getPositionY()
			local qid = checkSkillQuickPos(x, y)
			if qid and m_skillquickid then
				local infoid = m_skillquickid[g.pid]
				if m_skillquickid[qid] and m_skillquickid[qid] ~= 0 then
					setSkillQuickItem(g.pid, m_skillquickid[qid])
				end
				setSkillQuickItem(qid, infoid)
			end
		end
		ui.skillimg[g.pid]:setPositionX(ISMIRUI and 3 or 6)
		ui.skillimg[g.pid]:setPositionY(ISMIRUI and 2 or 5)
		ui.skillbgs[g.pid]:addChild(ui.skillimg[g.pid])
	end
	ui.skillgriddownpos = nil
end

function onSkillDown(e)
	local g = e:getCurrentTarget()
	if g and g_skill[g.id] == nil and g_mobileMode and g.pid == 1 then
		local gid = 技能逻辑.findNormalSkillIndex()
		if gid then
			local attackObj = findAttackObj(g_skill[gid].range - RANGEOFFSET)
			技能逻辑.doUseSkill(attackObj, gid, attackObj and attackObj:getPositionX() or g_role:getPositionX(), attackObj and attackObj:getPositionY() or g_role:getPositionY())
		end
	elseif g == nil or (g_skill[g.id] == nil and g.pid ~= 11) then
	elseif F3DUIManager.sTouchComp ~= g then
	elseif g_mobileMode and IS3G and g.pid == 11 then
		if g_role.hp >= 0 and not g_role:isHitFly() and g_role.unmovable ~= 1 and g_role.unattackable ~= 1 then
			g_role:startHitFly(0.6, 200, 0.3, 0.3, 0)
			g_role:setAnimName("jump","",true,true)
			g_role.isjump = true
			消息.CG_CHANGE_STATUS(101,-1)
		end
	elseif g_mobileMode and IS3G then
		local gid = g.id
		if gid == 1 and g_role:isHitFly() then
			gid = 技能逻辑.findJumpSkillIndex()
		elseif gid == 1 and g_role.status == 1 and g_role:getAnimName() == "run" then
			gid = 技能逻辑.findRunSkillIndex()
		end
		if g_movedir.x ~= 0 or g_movedir.y ~= 0 then
			g_movedir:normalize(50)
		else
			g_movedir.x = 50
		end
		技能逻辑.doUseSkill(findAttackObj(g_skill[gid].range - RANGEOFFSET), gid, g_role:getPositionX()+g_movedir.x*8, g_role:getPositionY()+g_movedir.y*8)
	elseif g_mobileMode then
		local attackObj = findAttackObj(g_skill[g.id].range - RANGEOFFSET)
		技能逻辑.doUseSkill(attackObj, g.id, attackObj and attackObj:getPositionX() or g_role:getPositionX(), attackObj and attackObj:getPositionY() or g_role:getPositionY())
	elseif g_skill[g.id].type == 0 or g_skill[g.id].type == 3 or g_skill[g.id].type == 5 or g_skill[g.id].range == 0 then
		local pos = getMousePoint(g_hoverPos.x, g_hoverPos.y)
		技能逻辑.doUseSkill(findAttackObj(g_skill[g.id].range - RANGEOFFSET), g.id, pos.x, pos.y)
	else
		if not ISMIR2D then
			local pos = getMousePoint(g_hoverPos.x, g_hoverPos.y)
			local es = g_role:setEffectSystem(全局设置.getEffectUrl(2965), false, nil, nil, 0, -1)
			es:setScale(1, 1, 1)
			if es then
				es:setPositionX(pos.x)
				es:setPositionY(pos.y)
				es:setPositionZ(g_scene and g_scene:getTerrainHeight(pos.x, pos.y) or 0)
			end
		end
		tipsskillmove = true
	end
	e:stopPropagation()
end

function onSkillMove(e)
	if ui.skillgriddownpos ~= nil then
		onSkillGridMove(e)
		return
	end
	local g = e:getCurrentTarget()
	if g == nil or g_skill[g.id] == nil or g_skill[g.id].range == 0 then
	elseif tipsskillmove then
		if not ISMIR2D then
			local pos = getMousePoint(g_hoverPos.x, g_hoverPos.y)
			local es = g_role:getEffectSystem(全局设置.getEffectUrl(2965))
			if es then
				es:setPositionX(pos.x)
				es:setPositionY(pos.y)
				es:setPositionZ(g_scene and g_scene:getTerrainHeight(pos.x, pos.y) or 0)
			end
		end
	end
end

function onSkillUp(e)
	local g = e:getCurrentTarget()
	if ui:findComponent("youxia,玩家怪物") and g==ui:findComponent("youxia,Skill_box_1") then
	    print(txt("连..."))
		
		

		local target = nil
		if e:getLocalPos().x >= g:getWidth() and e:getLocalPos().y <= 0 then
			target = findNearObj(1)
		elseif e:getLocalPos().x <= 0 and e:getLocalPos().y >= g:getHeight() then
			target = findNearObj(2)
		end
		
		if g_attackObj and g_attackObj.objtype ~= 全局设置.OBJTYPE_NPC then
			if (头像信息UI.m_pkmode == 1 or 头像信息UI.m_pkmode == 2) and g_attackObj and g_attackObj.objtype == 全局设置.OBJTYPE_PLAYER and g_attackObj.status ~= 3 then
				setAutoAttack(true)
			else
				setAutoAttack(false)
			end
			setMainRoleTarget(g_attackObj)
		end
	end
	if g == nil or g_skill[g.id] == nil or g_skill[g.id].range == 0 then
	elseif g_mobileMode and g_skill[g.id].infoid == 21 and e:getLocalPos().x >= 0 and e:getLocalPos().y >= 0 and e:getLocalPos().x <= g:getWidth() and e:getLocalPos().y <= g:getHeight() then
		if g_role.unattackable ~= 1 and (not g_role:needMove()) then
			local attackObj = findAttackObj(g_skill[g.id].range - RANGEOFFSET)
			local posx = attackObj and attackObj:getPositionX() or g_role:getPositionX() + math.sin(g_role:getAnimRotationZ()*math.pi/180)*100
			local posy = attackObj and attackObj:getPositionY() or g_role:getPositionY() - math.cos(g_role:getAnimRotationZ()*math.pi/180)*100
			技能逻辑.doUseSkill(attackObj, g.id, posx, posy)
		else
			setSkillUseTime(g.id, rtime())
		end
	elseif tipsskillmove then
		if g_role.unattackable ~= 1 and (not g_role:needMove()) then
			if g_skill[g.id].type ~= 1 then
				local pos = getMousePoint(g_hoverPos.x, g_hoverPos.y)
				技能逻辑.doUseSkill(findAttackObj(g_skill[g.id].range - RANGEOFFSET), g.id, pos.x, pos.y)
			else
				local 移动x, 移动y = getAnglePosition()
				技能逻辑.doUseSkill(findAttackObj(g_skill[g.id].range - RANGEOFFSET), g.id, 移动x, 移动y)
			end
		elseif g_skill[g.id].type == 1 then
			setSkillUseTime(g.id, rtime(), 4)
		else
			setSkillUseTime(g.id, rtime(), 1)
		end
		if not ISMIR2D then
			g_role:removeEffectSystem(全局设置.getEffectUrl(2965))
		end
		tipsskillmove = nil
	end
end

function checkTipsPos()
	if not ui or not tipsgrid then
		return
	end
	if not tipsui or not tipsui:isVisible() or not tipsui:isInited() then
	else
		local x = ui:getPositionX()+tipsgrid:getPositionX()
		local y = ui:getPositionY()+tipsgrid:getPositionY()-tipsui:getHeight()
		local p = tipsgrid:getParent()
		while p and p ~= ui do
			x = x + p:getPositionX()
			y = y + p:getPositionY()
			p = p:getParent()
		end
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

RANGETXT = {
	[0] = ("单体"),
	[1] = ("直线"),--矩形
	[2] = ("半圆"),--扇形
	[3] = ("圆形"),
	[4] = ("范围"),--目标圆形
}

function onGridDown(e)
	local g = e:getCurrentTarget()
	if g == nil or ui.quickimg[g.id] == nil or ui.quickimg[g.id].itemid == 0 then
		return
	end
	local p = e:getLocalPos()
	if g then
		ui.quickbgs[g.id]:removeChild(ui.quickimg[g.id])
		ui:addChild(ui.quickimg[g.id])
		local x = g:getPositionX() + 3
		local y = g:getPositionY() + 2
		local p = g:getParent()
		while p and p ~= ui do
			x = x + p:getPositionX()
			y = y + p:getPositionY()
			p = p:getParent()
		end
		ui.quickimg[g.id]:setPositionX(x)
		ui.quickimg[g.id]:setPositionY(y)
	end
	ui.griddownpos = {x=p.x,y=p.y}
end

function onGridMove(e)
	if ui.griddownpos == nil then
		return
	end
	local g = e:getCurrentTarget()
	local p = e:getLocalPos()
	if g then
		local x = p.x - ui.griddownpos.x + g:getPositionX() + 3
		local y = p.y - ui.griddownpos.y + g:getPositionY() + 2
		local p = g:getParent()
		while p and p ~= ui do
			x = x + p:getPositionX()
			y = y + p:getPositionY()
			p = p:getParent()
		end
		ui.quickimg[g.id]:setPositionX(x)
		ui.quickimg[g.id]:setPositionY(y)
	end
end

function onGridUp(e)
	if ui.griddownpos == nil then
		return
	end
	local g = e:getCurrentTarget()
	local p = e:getLocalPos()
	if g then
		local x = ui.quickimg[g.id]:getPositionX() + ui.griddownpos.x
		local y = ui.quickimg[g.id]:getPositionY() + ui.griddownpos.y
		if x < 0 or x > ui:getWidth() or y < (ISMIRUI and 0 or -50) or y > ui:getHeight() then
			x = x + ui:getPositionX()
			y = y + ui:getPositionY()
			setQuickItem(g.id, 0)
		else
			x = x + ui:getPositionX()
			y = y + ui:getPositionY()
			local qid = checkQuickPos(x, y)
			if qid then
				if ui.quickimg[qid] and ui.quickimg[qid].itemid ~= 0 then
					setQuickItem(g.id, ui.quickimg[qid].itemid)
				end
				setQuickItem(qid, ui.quickimg[g.id].itemid)
			end
		end
		ui.quickimg[g.id]:setPositionX(3)
		ui.quickimg[g.id]:setPositionY(2)
		ui.quickbgs[g.id]:addChild(ui.quickimg[g.id])
	end
	ui.griddownpos = nil
end

function onGridOver(e)
	local g = e:getTarget()
	if g == nil or ui.quickimg[g.id] == nil or ui.quickimg[g.id].itemid == 0 then
	elseif F3DUIManager.sTouchComp ~= g then
	elseif 背包UI.getItemCount(ui.quickimg[g.id].itemid) > 0 then
		local v = ui.quickimg[g.id]
		简单提示UI.initUI()
		local ss = 实用工具.SplitString(背包UI.getItemDesc(v.itemid), "\n", true)
		简单提示UI.setItemData(全局设置.getItemIconUrl(背包UI.getItemIcon(v.itemid)),背包UI.getItemName(v.itemid),背包UI.getItemGrade(v.itemid),ss[1])
		tipsui = 简单提示UI.ui
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
		简单提示UI.hideUI()
		tipsui = nil
		tipsgrid = nil
	end
end

function onSkillOver(e)
	local g = e:getTarget()
	if g == nil or g_skill[g.id] == nil then
	else
		if g_skill[g.id].range > 0 and not ISMIR2D then
			local es = g_role:setEffectSystem(全局设置.getEffectUrl(2967), true)
			es:setScale(g_skill[g.id].range / 100, g_skill[g.id].range / 100, 1)
		end
		tipsskill = g
		if F3DUIManager.sTouchComp ~= g then
		else
			local v = g_skill[g.id]
			简单提示UI.initUI()
			local desc = v.desc ~= "" and 实用工具.SplitString(v.desc,";")[1] or ""
			desc = desc:gsub("%%1",v.damage1)
			desc = desc:gsub("%%2",v.damage2)
			if desc ~= "" then
				简单提示UI.setItemData(全局设置.getSkillIconUrl(v.icon),v.name.." LV: "..v.lv,v.lv,
					desc..(v.decmp > 0 and ",消耗"..v.decmp.."MP" or v.decmp < 0 and ",消耗"..(-v.decmp).."内力" or ",无消耗")..","..(v.cd/1000).."秒CD")
			elseif v.type == 5 then
				简单提示UI.setItemData(全局设置.getSkillIconUrl(v.icon),v.name.." LV: "..v.lv,v.lv,
					"施加"..
					(v.damage1 > 0 and v.damage1.."%" or "")..
					(v.damage1 > 0 and v.damage2 > 0 and "+" or "")..
					(v.damage2 > 0 and v.damage2.."点" or "")..
					"增益"..(v.decmp > 0 and ",消耗"..v.decmp.."MP" or v.decmp < 0 and ",消耗"..(-v.decmp).."内力" or ",无消耗")..","..(v.cd/1000).."秒CD")--v.grade
			else
				简单提示UI.setItemData(全局设置.getSkillIconUrl(v.icon),v.name.." LV: "..v.lv,v.lv,
					"造成"..
					(v.damage1 > 0 and v.damage1.."%" or "")..
					(v.damage1 > 0 and v.damage2 > 0 and "+" or "")..
					(v.damage2 > 0 and v.damage2.."点" or "")..
					"伤害"..(v.decmp > 0 and ",消耗"..v.decmp.."MP" or v.decmp < 0 and ",消耗"..(-v.decmp).."内力" or ",无消耗")..","..(v.cd/1000).."秒CD")--v.grade
			end
			tipsui = 简单提示UI.ui
			tipsgrid = g
			if not tipsui:isInited() then
				tipsui:addEventListener(F3DObjEvent.OBJ_INITED, func_oe(checkTipsPos))
			else
				checkTipsPos()
			end
		end
	end
end

function onSkillOut(e)
	local g = e:getTarget()
	if g ~= nil and tipsskill == g then
		if not ISMIR2D then
			g_role:removeEffectSystem(全局设置.getEffectUrl(2967))
		end
		tipsskill = nil
		if g == tipsgrid and tipsui then
			简单提示UI.hideUI()
			tipsui = nil
			tipsgrid = nil
		end
	end
end

function onQuickDown(e)
	local g = e:getCurrentTarget()
	if g == nil or ui.quickimg[g.id] == nil or ui.quickimg[g.id].itemid == 0 then
	elseif F3DUIManager.sTouchComp ~= g then
	else
		背包UI.DoUseItem(ui.quickimg[g.id].itemid)
	end
end

function onExpGridOver(e)
	local g = e:getTarget()
	if g == nil then
	else
		if g == ui.exptext then
			ui.exptext:setTitleText(角色逻辑.m_exp.." / "..角色逻辑.m_expmax)
			if ISMIRUI then
				ui.weight:setTitleText("")
			end
		elseif g == ui.weight then
			if ISMIRUI then
				ui.weight:setTitleText((背包UI.BAG_CAP-背包UI.getLeftCount()).." / "..背包UI.BAG_CAP)
			end
			ui.exptext:setTitleText("")
		end
		tipsgrid = g
	end
end

function onExpGridOut(e)
	local g = e:getTarget()
	if g ~= nil and g == tipsgrid then
		ui.exptext:setTitleText("")
		if ISMIRUI then
			ui.weight:setTitleText("")
		end
		tipsgrid = nil
	end
end

function getUILocalPos(comp,stageX,stageY)
	local x = comp:getPositionX()
	local y = comp:getPositionY()
	local p = comp:getParent()
	while p and p ~= _uiLayer do
		x = x + p:getPositionX()
		y = y + p:getPositionY()
		p = p:getParent()
	end
	return stageX - x, stageY - y
end

function updateRockerPos(localposx,localposy)
	local centerx = ui.chassis:getPositionX()+ui.chassis:getWidth()/2-ui.rocker:getWidth()/2
	local centery = ui.chassis:getPositionY()+ui.chassis:getHeight()/2-ui.rocker:getHeight()/2
	local posx = ui.chassis:getPositionX()+localposx-ui.rocker:getWidth()/2
	local posy = ui.chassis:getPositionY()+localposy-ui.rocker:getHeight()/2
	m_ptcache:setVal(posx-centerx,posy-centery)
	if m_ptcache:length() > ui.chassis:getWidth()/2 then
		m_ptcache:normalize(ui.chassis:getWidth()/2)
	end
	ui.rocker:setPositionX(centerx+m_ptcache.x)
	ui.rocker:setPositionY(centery+m_ptcache.y)
	return m_ptcache.x, m_ptcache.y
end

function updateRockerPos2(localposx,localposy)
	local centerx = ui.chassis2:getPositionX()+ui.chassis2:getWidth()/2-ui.rocker2:getWidth()/2
	local centery = ui.chassis2:getPositionY()+ui.chassis2:getHeight()/2-ui.rocker2:getHeight()/2
	local posx = ui.chassis2:getPositionX()+localposx-ui.rocker2:getWidth()/2
	local posy = ui.chassis2:getPositionY()+localposy-ui.rocker2:getHeight()/2
	m_ptcache:setVal(posx-centerx,posy-centery)
	if m_ptcache:length() > ui.chassis2:getWidth()/2 then
		m_ptcache:normalize(ui.chassis2:getWidth()/2)
	end
	ui.rocker2:setPositionX(centerx+m_ptcache.x)
	ui.rocker2:setPositionY(centery+m_ptcache.y)
	return m_ptcache.x, m_ptcache.y
end

function checkZuoxiaTouchable()
	if not F3DUIManager.sTouchComp or F3DUIManager.sTouchComp == ui.zuoxia then
		return true
	end
	local p = F3DUIManager.sTouchComp:getParent()
	while p and p ~= ui.zuoxia do
		p = p:getParent()
	end
	return p == ui.zuoxia
end

function checkZuoxiaTouchable2()
	if not F3DUIManager.sTouchComp or F3DUIManager.sTouchComp == ui.zuozuoxia then
		return true
	end
	local p = F3DUIManager.sTouchComp:getParent()
	while p and p ~= ui.zuozuoxia do
		p = p:getParent()
	end
	return p == ui.zuozuoxia
end

function onChassisDown(e)
	if not checkZuoxiaTouchable() then
		return
	end
	if m_touchid == -1 then
		local zuoxiaposx,zuoxiaposy = getUILocalPos(ui.zuoxia,e:getStageX(),e:getStageY())
		if zuoxiaposx < 0 or zuoxiaposx > ui.zuoxia:getWidth() or zuoxiaposy < 0 or zuoxiaposy > ui.zuoxia:getHeight() then
		else
			m_touchid = e:getID()
			if 游戏设置.FLOATROCKER then
				local posx,posy = getUILocalPos(ui.zuoxia,e:getStageX(),e:getStageY())
				ui.control:setPositionX(posx-ui.control:getWidth()/2)
				ui.control:setPositionY(posy-ui.control:getHeight()/2)
				ui.rocker:setState(F3DComponent.STATE_HOVER)
				ui.chassis:setState(F3DComponent.STATE_HOVER)
				m_chassisDown = true
				return
			end
			local localposx,localposy = getUILocalPos(ui.chassis,e:getStageX(),e:getStageY())
			local rockerposx,rockerposy = localposx-ui.rockerposx,localposy-ui.rockerposy
			local rockermovex,rockermovey = updateRockerPos(localposx,localposy)
			ui.rocker:setState(F3DComponent.STATE_HOVER)
			ui.chassis:setState(F3DComponent.STATE_HOVER)
			if rockerposx < CHASSISOFFSET or rockerposx > ui.rocker:getWidth()-CHASSISOFFSET or rockerposy < CHASSISOFFSET or rockerposy > ui.rocker:getHeight()-CHASSISOFFSET then
				setMoveDir(rockermovex,-rockermovey,1,true)
				m_startMoveDir = true
			else
				setMoveDir(rockermovex,-rockermovey,1,VIPLEVEL < 2 or 游戏设置.DOUBLEROCKER)
				m_startMoveDir = true
			end
		end
		m_chassisDown = true
	end
end

function onChassisMove(e)
	if not m_chassisDown then
		return
	end
	if m_touchid == e:getID() then
		local localposx,localposy = getUILocalPos(ui.chassis,e:getStageX(),e:getStageY())
		local rockerposx,rockerposy = localposx-ui.rockerposx,localposy-ui.rockerposy
		local rockermovex,rockermovey = updateRockerPos(localposx,localposy)
		ui.rocker:setState(F3DComponent.STATE_HOVER)
		ui.chassis:setState(F3DComponent.STATE_HOVER)
		if not m_startMoveDir and (rockerposx < CHASSISOFFSET or rockerposx > ui.rocker:getWidth()-CHASSISOFFSET or rockerposy < CHASSISOFFSET or rockerposy > ui.rocker:getHeight()-CHASSISOFFSET) then
			setMoveDir(rockermovex,-rockermovey,1,true)
			m_startMoveDir = true
		elseif not m_startMoveDir then
			setMoveDir(rockermovex,-rockermovey,1,VIPLEVEL < 2 or 游戏设置.DOUBLEROCKER)
			m_startMoveDir = true
		elseif m_startMoveDir and (rockerposx < CHASSISOFFSET or rockerposx > ui.rocker:getWidth()-CHASSISOFFSET or rockerposy < CHASSISOFFSET or rockerposy > ui.rocker:getHeight()-CHASSISOFFSET) then
			setMoveDir(rockermovex,-rockermovey,2,true)
		elseif m_startMoveDir then
			setMoveDir(rockermovex,-rockermovey,2,VIPLEVEL < 2 or 游戏设置.DOUBLEROCKER)
		end
	end
end

function onChassisUp(e)
	if m_touchid == e:getID() then
		if 游戏设置.FLOATROCKER then
			prop4:clear()
			prop4:push("x", ui.controlx, F3DTween.TYPE_SPEEDDOWN)
			prop4:push("y", ui.controly, F3DTween.TYPE_SPEEDDOWN)
			F3DTween:fromPool():start(ui.control, prop4, 0.1)
			--ui.control:setPositionX(ui.controlx)
			--ui.control:setPositionY(ui.controly)
		end
		ui.rocker:setPositionX(ui.chassis:getPositionX()+ui.chassis:getWidth()/2-ui.rocker:getWidth()/2)
		ui.rocker:setPositionY(ui.chassis:getPositionY()+ui.chassis:getHeight()/2-ui.rocker:getHeight()/2)
		ui.rocker:setState(F3DComponent.STATE_NORMAL)
		ui.chassis:setState(F3DComponent.STATE_NORMAL)
		if m_startMoveDir then
			setMoveDir(0,0)
			m_startMoveDir = false
		end
		m_touchid = -1
		m_chassisDown = false
	end
end

function onChassisDown2(e)
	if not checkZuoxiaTouchable2() then
		return
	end
	if m_touchid2 == -1 then
		local zuoxiaposx,zuoxiaposy = getUILocalPos(ui.zuozuoxia,e:getStageX(),e:getStageY())
		if zuoxiaposx < 0 or zuoxiaposx > ui.zuozuoxia:getWidth() or zuoxiaposy < 0 or zuoxiaposy > ui.zuozuoxia:getHeight() then
		else
			m_touchid2 = e:getID()
			if 游戏设置.FLOATROCKER then
				local posx,posy = getUILocalPos(ui.zuozuoxia,e:getStageX(),e:getStageY())
				ui.control2:setPositionX(posx-ui.control2:getWidth()/2)
				ui.control2:setPositionY(posy-ui.control2:getHeight()/2)
				ui.rocker2:setState(F3DComponent.STATE_HOVER)
				ui.chassis2:setState(F3DComponent.STATE_HOVER)
				m_chassisDown2 = true
				return
			end
			local localposx,localposy = getUILocalPos(ui.chassis2,e:getStageX(),e:getStageY())
			local rockerposx,rockerposy = localposx-ui.rockerposx2,localposy-ui.rockerposy2
			local rockermovex,rockermovey = updateRockerPos2(localposx,localposy)
			ui.rocker2:setState(F3DComponent.STATE_HOVER)
			ui.chassis2:setState(F3DComponent.STATE_HOVER)
			setMoveDir(rockermovex,-rockermovey,1,false)
			m_startMoveDir2 = true
		end
		m_chassisDown2 = true
	end
end

function onChassisMove2(e)
	if not m_chassisDown2 then
		return
	end
	if m_touchid2 == e:getID() then
		local localposx,localposy = getUILocalPos(ui.chassis2,e:getStageX(),e:getStageY())
		local rockerposx,rockerposy = localposx-ui.rockerposx2,localposy-ui.rockerposy2
		local rockermovex,rockermovey = updateRockerPos2(localposx,localposy)
		ui.rocker2:setState(F3DComponent.STATE_HOVER)
		ui.chassis2:setState(F3DComponent.STATE_HOVER)
		if not m_startMoveDir2 then
			setMoveDir(rockermovex,-rockermovey,1,false)
			m_startMoveDir2 = true
		else
			setMoveDir(rockermovex,-rockermovey,2,false)
		end
	end
end

function onChassisUp2(e)
	if m_touchid2 == e:getID() then
		if 游戏设置.FLOATROCKER then
			ui.control2:setPositionX(ui.controlx2)
			ui.control2:setPositionY(ui.controly2)
		end
		ui.rocker2:setPositionX(ui.chassis2:getPositionX()+ui.chassis2:getWidth()/2-ui.rocker2:getWidth()/2)
		ui.rocker2:setPositionY(ui.chassis2:getPositionY()+ui.chassis2:getHeight()/2-ui.rocker2:getHeight()/2)
		ui.rocker2:setState(F3DComponent.STATE_NORMAL)
		ui.chassis2:setState(F3DComponent.STATE_NORMAL)
		if m_startMoveDir2 then
			setMoveDir(0,0)
			m_startMoveDir2 = false
		end
		m_touchid2 = -1
		m_chassisDown2 = false
	end
end

function onChassisWinDown(e)
	if not checkZuoxiaTouchable() then
		return
	end
	if 游戏设置.FLOATROCKER then
		local posx,posy = getUILocalPos(ui.zuoxia,e:getStageX(),e:getStageY())
		ui.control:setPositionX(posx-ui.control:getWidth()/2)
		ui.control:setPositionY(posy-ui.control:getHeight()/2)
		ui.rocker:setState(F3DComponent.STATE_HOVER)
		ui.chassis:setState(F3DComponent.STATE_HOVER)
		m_chassisDown = true
		return
	end
	local localposx,localposy = getUILocalPos(ui.chassis,e:getStageX(),e:getStageY())
	local rockerposx,rockerposy = localposx-ui.rockerposx,localposy-ui.rockerposy
	local rockermovex,rockermovey = updateRockerPos(localposx,localposy)
	ui.rocker:setState(F3DComponent.STATE_HOVER)
	ui.chassis:setState(F3DComponent.STATE_HOVER)
	if rockerposx < CHASSISOFFSET or rockerposx > ui.rocker:getWidth()-CHASSISOFFSET or rockerposy < CHASSISOFFSET or rockerposy > ui.rocker:getHeight()-CHASSISOFFSET then
		setMoveDir(rockermovex,-rockermovey,1,true)
		m_startMoveDir = true
	else
		setMoveDir(rockermovex,-rockermovey,1,VIPLEVEL < 2 or 游戏设置.DOUBLEROCKER)
		m_startMoveDir = true
	end
	m_chassisDown = true
end

function onChassisWinMove(e)
	if not m_chassisDown then
		return
	end
	local localposx,localposy = getUILocalPos(ui.chassis,e:getStageX(),e:getStageY())
	local rockerposx,rockerposy = localposx-ui.rockerposx,localposy-ui.rockerposy
	local rockermovex,rockermovey = updateRockerPos(localposx,localposy)
	ui.rocker:setState(F3DComponent.STATE_HOVER)
	ui.chassis:setState(F3DComponent.STATE_HOVER)
	if not m_startMoveDir and (rockerposx < CHASSISOFFSET or rockerposx > ui.rocker:getWidth()-CHASSISOFFSET or rockerposy < CHASSISOFFSET or rockerposy > ui.rocker:getHeight()-CHASSISOFFSET) then
		setMoveDir(rockermovex,-rockermovey,1,true)
		m_startMoveDir = true
	elseif not m_startMoveDir then
		setMoveDir(rockermovex,-rockermovey,1,VIPLEVEL < 2 or 游戏设置.DOUBLEROCKER)
		m_startMoveDir = true
	elseif m_startMoveDir and (rockerposx < CHASSISOFFSET or rockerposx > ui.rocker:getWidth()-CHASSISOFFSET or rockerposy < CHASSISOFFSET or rockerposy > ui.rocker:getHeight()-CHASSISOFFSET) then
		setMoveDir(rockermovex,-rockermovey,2,true)
	elseif m_startMoveDir then
		setMoveDir(rockermovex,-rockermovey,2,VIPLEVEL < 2 or 游戏设置.DOUBLEROCKER)
	end
end

function onChassisWinUp(e)
	if 游戏设置.FLOATROCKER then
		prop4:clear()
		prop4:push("x", ui.controlx, F3DTween.TYPE_SPEEDDOWN)
		prop4:push("y", ui.controly, F3DTween.TYPE_SPEEDDOWN)
		F3DTween:fromPool():start(ui.control, prop4, 0.1)
		--ui.control:setPositionX(ui.controlx)
		--ui.control:setPositionY(ui.controly)
	end
	ui.rocker:setPositionX(ui.chassis:getPositionX()+ui.chassis:getWidth()/2-ui.rocker:getWidth()/2)
	ui.rocker:setPositionY(ui.chassis:getPositionY()+ui.chassis:getHeight()/2-ui.rocker:getHeight()/2)
	ui.rocker:setState(F3DComponent.STATE_NORMAL)
	ui.chassis:setState(F3DComponent.STATE_NORMAL)
	if m_startMoveDir then
		setMoveDir(0,0)
		m_startMoveDir = false
	end
	m_chassisDown = false
end

function onChassisWinDown2(e)
	if not checkZuoxiaTouchable2() then
		return
	end
	if 游戏设置.FLOATROCKER then
		local posx,posy = getUILocalPos(ui.zuozuoxia,e:getStageX(),e:getStageY())
		ui.control2:setPositionX(posx-ui.control2:getWidth()/2)
		ui.control2:setPositionY(posy-ui.control2:getHeight()/2)
		ui.rocker2:setState(F3DComponent.STATE_HOVER)
		ui.chassis2:setState(F3DComponent.STATE_HOVER)
		m_chassisDown2 = true
		return
	end
	local localposx,localposy = getUILocalPos(ui.chassis2,e:getStageX(),e:getStageY())
	local rockerposx,rockerposy = localposx-ui.rockerposx2,localposy-ui.rockerposy2
	local rockermovex,rockermovey = updateRockerPos2(localposx,localposy)
	ui.rocker2:setState(F3DComponent.STATE_HOVER)
	ui.chassis2:setState(F3DComponent.STATE_HOVER)
	setMoveDir(rockermovex,-rockermovey,1,false)
	m_startMoveDir2 = true
	m_chassisDown2 = true
end

function onChassisWinMove2(e)
	if not m_chassisDown2 then
		return
	end
	local localposx,localposy = getUILocalPos(ui.chassis2,e:getStageX(),e:getStageY())
	local rockerposx,rockerposy = localposx-ui.rockerposx2,localposy-ui.rockerposy2
	local rockermovex,rockermovey = updateRockerPos2(localposx,localposy)
	ui.rocker2:setState(F3DComponent.STATE_HOVER)
	ui.chassis2:setState(F3DComponent.STATE_HOVER)
	if not m_startMoveDir2 then
		setMoveDir(rockermovex,-rockermovey,1,false)
		m_startMoveDir2 = true
	else
		setMoveDir(rockermovex,-rockermovey,2,false)
	end
end

function onChassisWinUp2(e)
	if 游戏设置.FLOATROCKER then
		ui.control2:setPositionX(ui.controlx2)
		ui.control2:setPositionY(ui.controly2)
	end
	ui.rocker2:setPositionX(ui.chassis2:getPositionX()+ui.chassis2:getWidth()/2-ui.rocker2:getWidth()/2)
	ui.rocker2:setPositionY(ui.chassis2:getPositionY()+ui.chassis2:getHeight()/2-ui.rocker2:getHeight()/2)
	ui.rocker2:setState(F3DComponent.STATE_NORMAL)
	ui.chassis2:setState(F3DComponent.STATE_NORMAL)
	if m_startMoveDir2 then
		setMoveDir(0,0)
		m_startMoveDir2 = false
	end
	m_chassisDown2 = false
end

function updateFightMode(fightMode)
	if fightMode then
		fightMode = fightMode == 1
	else
		fightMode = 头像信息UI.m_fightMode
	end
end

function updateSimpleMode(fightMode)
	if fightMode then
		fightMode = fightMode == 1
	else
		fightMode = 头像信息UI.m_fightMode
	end
	if not 小地图UI.m_simpleMode then
		--聊天UI.initUI()
		任务追踪UI.initUI()
		--获得提示UI.initUI()
		活动UI.initUI()
	else
		--聊天UI.hideUI()
		任务追踪UI.hideUI()
		--获得提示UI.hideUI()
		活动UI.hideUI()
	end
end

function checkFindPathPos(x, y)
	if 快捷传送 == 1 and m_autofindpath:isVisible() and x >= m_autofindpath:getPositionX()+8 and x <= m_autofindpath:getPositionX()+8+48 and
		y >= m_autofindpath:getPositionY()+215 and y <= m_autofindpath:getPositionY()+215+48 then
		return true
	else
		return false
	end
end

function checkEquipTipsUI()
	local g = F3DUIManager.sTouchComp
	while g do
		if g == 物品提示UI.ui or g == 装备提示UI.ui or g == 装备对比提示UI.ui or g == 宠物蛋提示UI.ui or g == 简单提示UI.ui then
			return g
		end
		g = g:getParent()
	end
end

function onMouseDown(e)
	m_equiptipsui = checkEquipTipsUI()
	if not m_equiptipsui then
		背包UI.hideAllTipsUI()
		return
	end
	if m_equiptipsui:getHeight() <= stage:getHeight() then
		return
	end
	m_equiptipsdown = {m_equiptipsui:getPositionY(),e:getStageY()}
end

function onMouseMove(e)
	if m_equiptipsui and m_equiptipsdown then
		local y = m_equiptipsdown[1]+e:getStageY()-m_equiptipsdown[2]
		m_equiptipsui:setPositionY(math.min(0,math.max(stage:getHeight()-m_equiptipsui:getHeight(),y)))
	end
end

function onMouseUp(e)
	if ui.菜单 then
		if uiLayer:getPositionY() == 0 then
		else
			F3DTween:fromPool():start(uiLayer, prop3, 0.25)
		end
	end
	m_equiptipsui = nil
	m_equiptipsdown = nil
end

function onUIInit()

	if sound then
		sound:destory()
		sound=nil
	end
	if not sound and F3DSoundManager:instance().playMusic then
sound=F3DSoundManager:instance():playMusic("/res/sound/"..(游戏设置.tuiguangyl or "").."",false)
	elseif not sound then
sound=F3DSoundManager:instance():playSound("/res/sound/"..(游戏设置.tuiguangyl or "").."",false)
	end
	if g_mobileMode then
	ui.zhanli = ui:findComponent("xia,zhan_shuzhi"):getBackground()--战力
		ui.zuoxia = ui:findComponent("zuoxia")
		ui.control = ui:findComponent("zuoxia,Control")
		if ui.control then
			ui.controlx = ui.control:getPositionX()
			ui.controly = ui.control:getPositionY()
		end
		ui.chassis = ui:findComponent("zuoxia,Control,Chassis")
		ui.rocker = ui:findComponent("zuoxia,Control,Button_Rocker")
		if ui.rocker then
			ui.rockerposx = ui.rocker:getPositionX() - ui.chassis:getPositionX()
			ui.rockerposy = ui.rocker:getPositionY() - ui.chassis:getPositionY()
		end
		ui.zuozuoxia = ui:findComponent("zuozuoxia")
		ui.control2 = ui:findComponent("zuozuoxia,Control")
		if ui.control2 then
			ui.controlx2 = ui.control2:getPositionX()
			ui.controly2 = ui.control2:getPositionY()
		end
		ui.chassis2 = ui:findComponent("zuozuoxia,Control,Chassis")
		ui.rocker2 = ui:findComponent("zuozuoxia,Control,Button_Rocker")
		if ui.rocker2 then
			ui.rockerposx2 = ui.rocker2:getPositionX() - ui.chassis2:getPositionX()
			ui.rockerposy2 = ui.rocker2:getPositionY() - ui.chassis2:getPositionY()
		end
		if __PLATFORM__ == "WIN" or __PLATFORM__ == "MAC" then
			ui.zuoxia:addEventListener(F3DMouseEvent.MOUSE_DOWN, func_me(onChassisWinDown))
			ui.zuoxia:addEventListener(F3DMouseEvent.MOUSE_MOVE, func_me(onChassisWinMove))
			ui.zuoxia:addEventListener(F3DMouseEvent.MOUSE_UP, func_me(onChassisWinUp))
			if ui.zuozuoxia then
				ui.zuozuoxia:addEventListener(F3DMouseEvent.MOUSE_DOWN, func_me(onChassisWinDown2))
				ui.zuozuoxia:addEventListener(F3DMouseEvent.MOUSE_MOVE, func_me(onChassisWinMove2))
				ui.zuozuoxia:addEventListener(F3DMouseEvent.MOUSE_UP, func_me(onChassisWinUp2))
			end
		else
			F3DTouchProcessor:instance():addEventListener(F3DTouchEvent.BEGIN, func_te(onChassisDown))
			F3DTouchProcessor:instance():addEventListener(F3DTouchEvent.MOVE, func_te(onChassisMove))
			F3DTouchProcessor:instance():addEventListener(F3DTouchEvent.END, func_te(onChassisUp))
			if ui.zuozuoxia then
				F3DTouchProcessor:instance():addEventListener(F3DTouchEvent.BEGIN, func_te(onChassisDown2))
				F3DTouchProcessor:instance():addEventListener(F3DTouchEvent.MOVE, func_te(onChassisMove2))
				F3DTouchProcessor:instance():addEventListener(F3DTouchEvent.END, func_te(onChassisUp2))
			end
		end
		F3DTouchProcessor:instance():addEventListener(F3DMouseEvent.MOUSE_DOWN, func_me(onMouseDown))
		F3DTouchProcessor:instance():addEventListener(F3DMouseEvent.MOUSE_MOVE, func_me(onMouseMove))
		F3DTouchProcessor:instance():addEventListener(F3DMouseEvent.MOUSE_UP, func_me(onMouseUp))
	end
	local shp = F3DShape:new()
	shp:drawCircle(g_mobileMode and F3DPoint:new(30,30) or F3DPoint:new(16,16), g_mobileMode and 30 or 16)
	--local qshp = F3DShape:new()
	--qshp:drawCircle(g_mobileMode and F3DPoint:new(32,32) or F3DPoint:new(16,16), g_mobileMode and 32 or 16)
	ui.skillbgs = {}
	ui.skillbg11 = nil
	ui.skillimg = {}
	ui.skillcdimg = {}
	ui.quickbgs = {}
	ui.quickimg = {}
	ui.quickcnt = {}
	ui.quickcdimg = {}
	for i=0,7 do
		local img = F3DImage:new()
		img:setPositionX(g_mobileMode and (游戏设置.SKILLOFFSET or 6) or ISMIRUI and 3 or 6)
		img:setPositionY(g_mobileMode and (游戏设置.SKILLOFFSET or 6) or ISMIRUI and 2 or 5)
		img:setWidth(g_mobileMode and 55 or 32)
		img:setHeight(g_mobileMode and 55 or 32)
		if g_mobileMode or not 游戏设置.SKILLSQUARE then
			img:setMask(shp)
		end
		local cd = F3DComponent:new()
		if not g_mobileMode or i > 0 then
			cd:setBackground(UIPATH.."主界面/cd.png")
			cd:setSizeClips("32,1,0,0")
			cd:setWidth(g_mobileMode and 55 or 32)
			cd:setHeight(g_mobileMode and 55 or 32)
			if g_mobileMode or not 游戏设置.SKILLSQUARE then
				cd:getBackground():setMask(shp)
			end
			cd:addEventListener(F3DObjEvent.OBJ_PLAYOUT, func_oe(onCDPlayOut))
		end
		cd:setVisible(false)
		img:addChild(cd)
		ui.skillimg[i+1] = img
		ui.skillcdimg[i+1] = cd
		local skillbg = g_mobileMode and ui:findComponent("youxia,Skill_box_"..(i+1)) or ISMIRUI and ui:findComponent("top,skillbg_"..i) or ui:findComponent("skillbg_"..i)
		skillbg.id = 0
		skillbg.pid = i+1
		if not g_mobileMode then
			skillbg:addEventListener(F3DMouseEvent.MOUSE_DOWN, func_me(onSkillGridDown))
			skillbg:addEventListener(F3DMouseEvent.MOUSE_UP, func_me(onSkillGridUp))
			skillbg:addEventListener(F3DMouseEvent.RIGHT_DOWN, func_me(onSkillDown))
			skillbg:addEventListener(F3DMouseEvent.MOUSE_MOVE, func_me(onSkillMove))
			skillbg:addEventListener(F3DMouseEvent.RIGHT_UP, func_me(onSkillUp))
			skillbg:addEventListener(F3DUIEvent.MOUSE_OVER, func_ue(onSkillOver))
			skillbg:addEventListener(F3DUIEvent.MOUSE_OUT, func_ue(onSkillOut))
		else
			skillbg:addEventListener(F3DMouseEvent.MOUSE_DOWN, func_me(onSkillDown))
			skillbg:addEventListener(F3DMouseEvent.MOUSE_MOVE, func_me(onSkillMove))
			skillbg:addEventListener(F3DMouseEvent.MOUSE_UP, func_me(onSkillUp))
		end
		skillbg:addChild(img)
		ui.skillbgs[i+1] = skillbg
		if VIPLEVEL < 3 and i > 5 then
			skillbg:setVisible(false)
		end
	end
	for i=0,5 do
		local qimg = F3DImage:new()
		qimg.itemid = 0
		qimg:setPositionX(g_mobileMode and 4 or 3)
		qimg:setPositionY(g_mobileMode and 4 or 2)
		qimg:setWidth(g_mobileMode and 54 or 32)
		qimg:setHeight(g_mobileMode and 54 or 32)
		qimg.pic = F3DImage:new()
		qimg.pic:setPositionX(math.floor(qimg:getWidth()/2))
		qimg.pic:setPositionY(math.floor(qimg:getHeight()/2))
		qimg.pic:setPivot(0.5,0.5)
		qimg:addChild(qimg.pic)
		local qcnt = F3DTextField:new()
		if g_mobileMode then
			qcnt:setTextFont("宋体",16,false,false,false)
		end
		qcnt:setPivot(0.5,0)
		qcnt:setPositionX(g_mobileMode and 32 or 18)
		qimg:addChild(qcnt)
		local qcd = F3DComponent:new()
		qcd:setBackground(UIPATH.."主界面/cd.png")
		qcd:setSizeClips("32,1,0,0")
		qcd:setWidth(g_mobileMode and 54 or 32)
		qcd:setHeight(g_mobileMode and 54 or 32)
		qcd:addEventListener(F3DObjEvent.OBJ_PLAYOUT, func_oe(onCDPlayOut))
		qcd:setVisible(false)
		qimg:addChild(qcd)
		ui.quickimg[i+1] = qimg
		ui.quickcnt[i+1] = qcnt
		ui.quickcdimg[i+1] = qcd
		local quickbg = g_mobileMode and (ui:findComponent("xia,component_2,Props_box_"..(i+1)) or ui:findComponent("zuo,component_2,Props_box_"..(i+1)))
			or ISMIRUI and ui:findComponent("top,quickBg_"..i) or ui:findComponent("quickBg_"..i)
		quickbg.id = i+1
		if not g_mobileMode then
			quickbg:addEventListener(F3DMouseEvent.MOUSE_DOWN, func_me(onGridDown))
			quickbg:addEventListener(F3DMouseEvent.MOUSE_MOVE, func_me(onGridMove))
			quickbg:addEventListener(F3DMouseEvent.MOUSE_UP, func_me(onGridUp))
			quickbg:addEventListener(F3DUIEvent.MOUSE_OVER, func_ue(onGridOver))
			quickbg:addEventListener(F3DUIEvent.MOUSE_OUT, func_ue(onGridOut))
			quickbg:addEventListener(F3DMouseEvent.RIGHT_DOWN, func_me(onQuickDown))
		else
			quickbg:addEventListener(F3DMouseEvent.MOUSE_DOWN, func_me(onQuickDown))
		end
		quickbg:addChild(qimg)
		ui.quickbgs[i+1] = quickbg
	end
	if not g_mobileMode then
		ui.button_role = ISMIRUI and ui:findComponent("right,role") or ui:findComponent("button_role")
		ui.button_role:addEventListener(F3DMouseEvent.CLICK, func_me(function (e)
			if 游戏设置.MIRROLEPANEL and not 技能UI.isHided() then
				角色UI.setTabID(技能UI.m_tabid)
				角色UI.setTabID2(0)
				角色UI.initUI(技能UI.ui:getPositionX(), 技能UI.ui:getPositionY())
				技能UI.hideUI(true)
			elseif not 角色UI.isHided() and 角色UI.m_tabid ~= 0 then
				角色UI.setTabID(0)
			else
				角色UI.setTabID(0)
				if 游戏设置.MIRROLEPANEL and 角色UI.m_tabid2 == 3 then
					角色UI.setTabID2(0)
				end
				角色UI.toggle()
			end
		end))
		ui.button_bag = ISMIRUI and ui:findComponent("right,bag") or ui:findComponent("button_bag")
		ui.button_bag:addEventListener(F3DMouseEvent.CLICK, func_me(function (e)
			背包UI.toggle()
		end))
		ui.button_skill = ISMIRUI and ui:findComponent("right,skill") or ui:findComponent("button_skill")
		ui.button_skill:addEventListener(F3DMouseEvent.CLICK, func_me(function (e)
			if 游戏设置.MIRROLEPANEL and not 角色UI.isHided() then
				技能UI.setTabID(角色UI.m_tabid)
				技能UI.setTabID2(3)
				技能UI.initUI(角色UI.ui:getPositionX(), 角色UI.ui:getPositionY())
				角色UI.hideUI(true)
			else
				if 游戏设置.MIRROLEPANEL and 技能UI.m_tabid2 ~= 3 then
					技能UI.setTabID2(3)
				end
				技能UI.toggle()
			end
		end))
		ui.button_shop = ISMIRUI and ui:findComponent("right,shop") or ui:findComponent("button_shop")
		ui.button_shop:addEventListener(F3DMouseEvent.CLICK, func_me(function (e)
			商城UI.toggle()
		end))
	-- else
	-- ui.button_role = ISMIRUI and ui:findComponent("right,role") or ui:findComponent("button_role")
		-- ui.button_role:addEventListener(F3DMouseEvent.CLICK, func_me(function (e)
			-- if 游戏设置.MIRROLEPANEL and not 技能UI.isHided() then
				-- 角色UI.setTabID(技能UI.m_tabid)
				-- 角色UI.setTabID2(0)
				-- 角色UI.initUI(技能UI.ui:getPositionX(), 技能UI.ui:getPositionY())
				-- 技能UI.hideUI(true)
			-- elseif not 角色UI.isHided() and 角色UI.m_tabid ~= 0 then
				-- 角色UI.setTabID(0)
			-- else
				-- 角色UI.setTabID(0)
				-- if 游戏设置.MIRROLEPANEL and 角色UI.m_tabid2 == 3 then
					-- 角色UI.setTabID2(0)
				-- end
				-- 角色UI.toggle()
			-- end
		-- end))
	
	end
	ui.button_pet = g_mobileMode and ui:findComponent("menu,component_2,button_pet") or ISMIRUI and ui:findComponent("right,pet") or ui:findComponent("button_pet")
	if ui.button_pet then
		ui.button_pet:setVisible(false)
	end
	ui.button_strength = g_mobileMode and ui:findComponent("menu,component_2,button_strength") or ISMIRUI and ui:findComponent("right,strength") or ui:findComponent("button_strength")
	if ui.button_strength then
		ui.button_strength:setVisible(false)
	end
	ui.button_faction = g_mobileMode and ui:findComponent("menu,component_2,button_faction") or ISMIRUI and ui:findComponent("right,faction") or ui:findComponent("button_faction")
	if ui.button_faction then
		ui.button_faction:setVisible(false)
	end
	if ui:findComponent("menu") then
		ui:findComponent("menu"):setVisible(false)
	end
	if ui:findComponent("youxia,玩家怪物") then
		ui:findComponent("youxia,玩家怪物"):setTouchable(false)
	end
	ui.button_out = g_mobileMode and ui:findComponent("xia,button_out") or ui:findComponent("bottom,button_out")
	if ui.button_out then
		ui.button_out:addEventListener(F3DMouseEvent.CLICK, func_me(function (e)		
			消息框UI1.initUI()
			消息框UI1.setData(txt("是否确定退出到登录界面?"), function()
				消息.CG_BACK_SELECT()
				releaseScene()
				willBackSelect()
				网络连接.closeConnect()
				--removeUI()
				登录UI.initUI()
			end)
		end))
	end 
	if not g_mobileMode and ISMIRUI then
		ui.button_sound = ui:findComponent("right,sound")
		ui.button_sound:addEventListener(F3DMouseEvent.CLICK, func_me(function (e)
			setOpenSound(not g_openSound)
			F3DSoundManager:instance():playSound("/res/sound/105.mp3")
			聊天UI.添加文本("",-1,0,"音效开关: "..(g_openSound and "#cff00,开" or "#cff0000,关"))
		end))
	end
	if g_mobileMode then--声音
		ui.屏蔽声音 = ui:findComponent("xia,音量2")
		ui.屏蔽声音:setTouchable(false)
		ui.屏蔽声音:setVisible(not g_openSound)
		ui.声音 = ui:findComponent("xia,音量")
		ui.声音:addEventListener(F3DMouseEvent.CLICK, func_me(function (e)
			setOpenSound(not g_openSound)
			F3DSoundManager:instance():playSound("/res/sound/105.mp3")
			聊天UI.添加文本("",-1,0,"音效开关: "..(g_openSound and "#cff00,开" or "#cff0000,关"))
			ui.屏蔽声音:setVisible(not g_openSound)
		end))
		ui.button_shop = ui:findComponent("xia,shop")
		ui.button_shop:addEventListener(F3DMouseEvent.CLICK, func_me(function (e)
			商城UI.toggle()
			消息.CG_COLLECT_START(1234)
		end))
			end--结束
	ui.button_ride = g_mobileMode and (ui:findComponent("zuoxia,button_ride") or ui:findComponent("youxia,button_ride")) or ui:findComponent("right,ride")
	if VIPLEVEL >= 5 then
		ui.button_ride:addEventListener(F3DMouseEvent.CLICK, func_me(function (e)
			if g_role.hp > 0 then
				消息.CG_USE_MOUNT(g_role.isride and 0 or 1)
			end
		end))
	else
		ui.button_ride:setVisible(false)
	end
	ui.button_wingid = g_mobileMode and (ui:findComponent("youxia,button_wingid")) or ui:findComponent("right,wingid")
	if VIPLEVEL >= 5 then
	local dao_qu_si_quan_jia = true
		ui.button_wingid:addEventListener(F3DMouseEvent.CLICK, func_me(function (e)
			if g_role.wingid==false then
				消息.CG_USE_WING(g_role.wingid and 0 or 1)
				g_role.wingid =  true
				dao_qu_si_quan_jia = true
			else
				消息.CG_USE_WING(g_role.wingid and 0 or 1)
				g_role.wingid =  false
				dao_qu_si_quan_jia = true
			end
		end))
	else
		ui.button_wingid:setVisible(false)
	end
	
	ui.button_pick = g_mobileMode and (ui:findComponent("zuoxia,button_pick") or ui:findComponent("youxia,button_pick")) or ui:findComponent("right,pick")
	if type(游戏设置.PICKLOCKGOAL)=="string"then
		ui.button_pick=g_mobileMode and(ui:findComponent("zuoxia,"..游戏设置.PICKLOCKGOAL)or ui:findComponent("youxia,"..游戏设置.PICKLOCKGOAL))or ui:findComponent("right,"..游戏设置.PICKLOCKGOAL)
	end
	if ui.button_lockgoal then
			ui.button_lockgoal:setTitleText(g_mobileMode and txt("锁定")or txt("锁定目标"))
			ui.button_lockgoal:addEventListener(F3DMouseEvent.CLICK,func_me(function(e)
			消息.CG_COMMAND_MSG(13,g_attackObj and tostring(g_attackObj.objid)or"")
		end))
	elseif 游戏设置.PICKLOCKGOAL==true then
		ui.button_pick:setTitleText(g_mobileMode and txt("锁定")or txt("锁定目标"))
	end
	ui.button_pick:addEventListener(F3DMouseEvent.CLICK,func_me(function(e)
		if 游戏设置.PICKLOCKGOAL==true then
			消息.CG_COMMAND_MSG(13,g_attackObj and tostring(g_attackObj.objid)or"")
		else
			doMoveRoleLogic()
		end
	end))	

--添加新功能 附近有最近npc时候将拾取按钮变为对话按钮 点击可与当前npc对象对话

	--测试传递参数
	
	
	ui.button_pick:addEventListener(F3DMouseEvent.CLICK, func_me(function (e)
	    --print(txt("连11..."))
		--ui.button_pick:setTitleText(g_mobileMode and txt("锁定")or txt("锁定目标"))
		autoPickItem()
	end))
	ui.button_pick = g_mobileMode and (ui:findComponent("zuoxia,button_pick") or ui:findComponent("youxia,button_pick")) or ui:findComponent("right,pick")

	ui.button_pick:addEventListener(F3DMouseEvent.CLICK, func_me(function (e)
	    --print(txt("222连11..."))
		autoPickItem()
	end))
	
	--加入目标信息自动刷新
--local name1 = 目标信息UI.m_goalinfo.objid
    --local 目标信息UI = require("主界面.目标信息UI")
	--if 目标信息UI.isHided()  then  else print(txt("wwww11..."))  end
    --if 目标信息UI.m_goalinfo then
	--ui.button_pick:setTitleText(g_mobileMode and txt(""..目标信息UI.m_goalinfo.name)or txt("对话-"))
	--end
	
	
	--ui.button_pick:setTitleText(g_mobileMode and txt("ssss" )or txt("对话-"))
	
	
	ui.button_goal = g_mobileMode and (ui:findComponent("zuoxia,button_goal") or ui:findComponent("youxia,button_goal")) or ui:findComponent("right,goal")
	if 游戏设置.SHOWSUBSTATE then
		ui.button_goal:setTitleText(g_mobileMode and txt("属下") or txt("属下状态"))
	end
	ui.button_goal:addEventListener(F3DMouseEvent.CLICK, func_me(function (e)
	--print(txt("连11..."))
		if 游戏设置.SHOWSUBSTATE then
		--print(txt("连22..."))
			消息.CG_CHANGE_STATUS(103,-1)
		else
			findNearObj()
		end
	end))
	if g_mobileMode then--下
	ui.z01 = ui:findComponent("xia,背包")
	ui.z01:addEventListener(F3DMouseEvent.CLICK, func_me(function (e)
	背包UI.toggle()
	end))
	end--下
	ui.exp = ISMIRUI and tt(ui:findComponent("right,exp"),F3DProgress) or tt(ui:findComponent("exp"),F3DProgress)
	ui.xpprogress = ISMIRUI and tt(ui:findComponent("right,xp"),F3DProgress) or tt(ui:findComponent("left,xp"),F3DProgress) or tt(ui:findComponent("xp"),F3DProgress)
	ui.xpprogress:setCurrVal(0)
	ui.xphead = g_mobileMode and ui:findComponent("youxia,xphead") or ISMIRUI and ui:findComponent("top,xphead") or ui:findComponent("xphead")
	ui.xpimg = F3DImage:new()
	ui.xpimg:setPositionX(g_mobileMode and (游戏设置.SKILLOFFSETXP or 6) or 6)
	ui.xpimg:setPositionY(g_mobileMode and (游戏设置.SKILLOFFSETXP or 6) or 5)
	ui.xpimg:setWidth(g_mobileMode and 52 or 32)
	ui.xpimg:setHeight(g_mobileMode and 52 or 32)
	ui.xpimg:setMask(shp)
	ui.xphead:addChild(ui.xpimg)
	ui.xphead:addEventListener(F3DMouseEvent.CLICK, func_me(function (e)
		useXPSkill()
	end))
	ui.xphead:setVisible(false)
	ui.xptext = g_mobileMode and ui:findComponent("youxia,xptext") or ISMIRUI and ui:findComponent("top,xptext") or ui:findComponent("xptext")
	ui.xptext:setTextColor(0xff0000, 0xff0000ff)
	ui.xptext:setTouchable(false)
	ui.xptext:setVisible(false)
	if not g_mobileMode then
		if ISMIRUI then
			ui.weight = tt(ui:findComponent("right,weight"),F3DProgress)
			ui.weight:addEventListener(F3DUIEvent.MOUSE_OVER, func_ue(onExpGridOver))
			ui.weight:addEventListener(F3DUIEvent.MOUSE_OUT, func_ue(onExpGridOut))
			ui.level = ui:findComponent("right,level")
			ui.hp = ui:findComponent("left,hp")
			ui.mp = ui:findComponent("left,mp")
			ui.pkmode = ui:findComponent("left,pkmode")
			ui.pkmode:addEventListener(F3DMouseEvent.CLICK, func_me(function (e)
				头像信息UI.onClickPK()
			end))
			ui.exptext = ui.exp
			ui.exptext:addEventListener(F3DUIEvent.MOUSE_OVER, func_ue(onExpGridOver))
			ui.exptext:addEventListener(F3DUIEvent.MOUSE_OUT, func_ue(onExpGridOut))
			ui.zhanli = ui:findComponent("left,zhan_shuzhi"):getBackground()
		else
			ui.exptext = ui:findComponent("exptext")
			ui.exptext:addEventListener(F3DUIEvent.MOUSE_OVER, func_ue(onExpGridOver))
			ui.exptext:addEventListener(F3DUIEvent.MOUSE_OUT, func_ue(onExpGridOut))
			ui.zhanli = ui:findComponent("zhan_shuzhi"):getBackground()
		end
	end
	if g_mobileMode then--右边切换
	ui.setupbtn = ui:findComponent("youxia,setupbtn")--设置1
	ui.setupbtn:setVisible(false)
	ui.setupbtn:addEventListener(F3DMouseEvent.CLICK, func_me(小地图UI.onSetupClick))
	
--	ui:findComponent("菜单"):addEventListener(F3DMouseEvent.CLICK, func_me(主逻辑._V_102))--菜单
	ui.菜单 = ui:findComponent("youxia,菜单")--设置1
	ui.菜单:addEventListener(F3DMouseEvent.CLICK, func_me(S_1021))
	end
	if g_mobileMode then
	ui.X02 = ui:findComponent("youxia,组队")
	ui.X02:setVisible(false)
	ui.X02:addEventListener(F3DMouseEvent.CLICK, func_me(function (e)
		队伍UI.toggle()
	end))
	end
	if g_mobileMode then
	ui.button_top = ui:findComponent("youxia,button_top")--排行
	ui.button_top:setVisible(false)
	ui.button_top:addEventListener(F3DMouseEvent.CLICK, func_me(function (e)
		排行榜UI.toggle()
	end))
	end
	if g_mobileMode then
	ui.button_faction = ui:findComponent("youxia,button_faction")--行会
	ui.button_faction:setVisible(false)
	ui.button_faction:addEventListener(F3DMouseEvent.CLICK, func_me(function (e)
		行会UI.toggle()
	end))
	end
	if g_mobileMode then
	ui.button_jishou = ui:findComponent("youxia,button_jishou")--行会
	ui.button_jishou:setVisible(false)
	ui.button_jishou:addEventListener(F3DMouseEvent.CLICK, func_me(function (e)
		寄售UI.toggle()
	end))
	end
	if g_mobileMode then
	ui.button_skill = ui:findComponent("youxia,button_skill")--行会
	ui.button_skill:setVisible(false)
	ui.button_skill:addEventListener(F3DMouseEvent.CLICK, func_me(function (e)
		技能UI.toggle()
	end))
	end
	m_init = true
	updateSkill()
	updateQuick()
	updateXP()
	updateExp()
	updateFightMode()
end


function 对话按钮()
local 目标信息UI = require("主界面.目标信息UI")
local 主界面UI = require("主界面.主界面UI")
    if g_attackObj and 目标信息UI.m_goalinfo and g_attackObj ~= nil then
   --print(txt("对话按钮222"))
        if g_attackObj and g_attackObj.objtype and g_attackObj.objid and g_attackObj.objtype == 全局设置.OBJTYPE_NPC then
            --print(txt("对话按钮"..iddd))
            --ui.button_pick:setTitleText(g_mobileMode and txt(""..iddd)or txt("对话-"))
		    ui.button_pick:addEventListener(F3DMouseEvent.CLICK, func_me(function (e)
		    if g_attackObj and g_attackObj.objtype == 全局设置.OBJTYPE_NPC then
		    消息.CG_NPC_TALK(g_attackObj.objid ,0,1)   --点击npc对话 目标为npc时候弹对话框
		    --else
		    --print(txt("对话按钮```"))
		    --主界面UI.showTipsMsg(1, txt("距离NPC太远啦" ))
		    end
		    --F3DRenderContext.sCamera:lookAt(0, 0, 1000, 0, 0, 0)
	        end))
  		--local str = ui.button_pick:getTitleText()  
		--local txt1 = utf8(str:gsub("#","##"))
		--print(txt("..."..txt1))
           end
		end
		if g_attackObj and g_attackObj.objtype and g_attackObj.objid and g_attackObj.objtype == 全局设置.OBJTYPE_MONSTER  and g_attackObj.objtype ~= 全局设置.OBJTYPE_NPC  then
		    --主界面UI.showTipsMsg(1, txt("怪物" ))
		    if g_attackObj  then
			--按钮点击时候操作
			ui.button_pick:addEventListener(F3DMouseEvent.CLICK, func_me(function (e)
		    if g_attackObj  then
		    resetAttackObj(g_attackObj)
            setMainRoleTarget(g_attackObj)   --点击npc对话  目标为怪物时候自动攻击
		    end
	        end))
			
		end
    end
end


--print(txt("222连11..."))
function S_1021()
if not r002 then
	r002 = true
--	ui.xphead:setVisible(false)
	ui.skillimg[1]:setVisible(false)
	ui.skillimg[2]:setVisible(false)
	ui.skillimg[3]:setVisible(false)
	ui.skillimg[4]:setVisible(false)
	ui.skillimg[5]:setVisible(false)
	ui.skillimg[6]:setVisible(false)
	ui.skillimg[7]:setVisible(false)
	ui.skillimg[8]:setVisible(false)
	--ui.button_pick:setVisible(false)
	ui.button_goal:setVisible(false)
	ui.button_ride:setVisible(false)
	ui.button_wingid:setVisible(false)
	ui:findComponent("youxia,Skill_box_1"):setVisible(false)
	ui:findComponent("youxia,Skill_box_2"):setVisible(false)
	ui:findComponent("youxia,Skill_box_3"):setVisible(false)
	ui:findComponent("youxia,Skill_box_4"):setVisible(false)
	ui:findComponent("youxia,Skill_box_5"):setVisible(false)
	ui:findComponent("youxia,Skill_box_6"):setVisible(false)
	ui:findComponent("youxia,Skill_box_7"):setVisible(false)
	ui:findComponent("youxia,Skill_box_8"):setVisible(false)
	ui.button_skill:setVisible(true)
	ui.button_jishou:setVisible(true)
	ui.button_top:setVisible(true)
	ui.X02:setVisible(true)
	ui.button_faction:setVisible(true)	
	ui.setupbtn:setVisible(true)
else
	r002 = false
--	ui.xphead:setVisible(true)
	ui.skillimg[1]:setVisible(true)
	ui.skillimg[2]:setVisible(true)
	ui.skillimg[3]:setVisible(true)
	ui.skillimg[4]:setVisible(true)
	ui.skillimg[5]:setVisible(true)
	ui.skillimg[6]:setVisible(true)
	ui.skillimg[7]:setVisible(true)
	ui.skillimg[8]:setVisible(true)
	--ui.button_pick:setVisible(true)
	ui.button_goal:setVisible(true)
	ui.button_ride:setVisible(true)
	ui.button_wingid:setVisible(true)
	
	ui:findComponent("youxia,Skill_box_1"):setVisible(true)
	ui:findComponent("youxia,Skill_box_2"):setVisible(true)
	ui:findComponent("youxia,Skill_box_3"):setVisible(true)
	ui:findComponent("youxia,Skill_box_4"):setVisible(true)
	ui:findComponent("youxia,Skill_box_5"):setVisible(true)
	ui:findComponent("youxia,Skill_box_6"):setVisible(true)
	ui:findComponent("youxia,Skill_box_7"):setVisible(true)
	ui:findComponent("youxia,Skill_box_8"):setVisible(true)
	ui.button_skill:setVisible(false)
	ui.button_jishou:setVisible(false)
	ui.button_top:setVisible(false)
	ui.X02:setVisible(false)
	ui.button_faction:setVisible(false)	
	ui.setupbtn:setVisible(false)
	end
end




function hideUI()
	if ui then
		ui:setVisible(false)
	end
end
prop2 = F3DTweenProp:new()
prop2:push("y", -60, F3DTween.TYPE_SPEEDDOWN)

prop3 = F3DTweenProp:new()
prop3:push("y", 0, F3DTween.TYPE_SPEEDDOWN)

function initUI()
	if ui then
		ui:updateParent()
		ui:setVisible(true)
	else
		ui = F3DLayout:new()
		uiLayer:addChild(ui)
		ui:setLoadPriority(getUIPriority())
		ui:addEventListener(F3DObjEvent.OBJ_INITED, func_e(onUIInit))
		if ui.setUIPack and USEUIPACK then
			ui:setUIPack(g_mobileMode and UIPATH.."战斗界面UIm.pack" or UIPATH.."主界面UI.pack")
		else
			ui:setLayout(g_mobileMode and UIPATH.."战斗界面UIm.layout" or UIPATH.."主界面UI.layout")
		end
	end
	获得提示UI.initUI()
	目标信息UI.initUI()
	头像信息UI.initUI()
	英雄信息UI.initUI()
	宠物信息UI.initUI()
	聊天UI.initUI()
	活动UI.initUI()
	小地图UI.initUI()
	--任务追踪UI.initUI()
end
	任务追踪UI.initUI()

function initAutoFight()
	m_autofight = F3DImageAnim:new()
	m_autofight:setAnimPack("/res/animpack/9000/9000.animpack")
	m_autofight:setPositionX(stage:getWidth() / 2 - 110)
	m_autofight:setPositionY(stage:getHeight() / 2 - 90)
	m_autofight:setVisible(false)
	uiLayer:addChild(m_autofight)
	
	
	m_autofindpath = F3DImageAnim:new()
	m_autofindpath:setAnimPack("/res/animpack/9001/9001.animpack")
	m_autofindpath:setPositionX(stage:getWidth() / 2 - 126)
	m_autofindpath:setPositionY(stage:getHeight() / 2 - 60)
	m_autofindpath:setVisible(false)
	shapeLayer:addChild(m_autofindpath)
	

	m_autofindpath:setPositionX(stage:getWidth()-(快捷传送 == 1 and 310 or 300))
	m_autofindpath:setPositionY(130)
	m_autofindpath:setVisible(false)
	shapeLayer:addChild(m_autofindpath)
end

function initTipsCont()
	initAutoFight()
	stage:addEventListener(F3DEvent.RESIZE, func_e(onStageResize))
	m_tipsmsgcont1 = F3DDisplayContainer:new()
	m_tipsmsgcont1:setPositionX(math.floor(stage:getWidth()/2))
	m_tipsmsgcont1:setPositionY(150)
	shapeLayer:addChild(m_tipsmsgcont1)
	m_tipsmsgcont2 = F3DDisplayContainer:new()
	m_tipsmsgcont2:setPositionX(math.floor(stage:getWidth()/2))
	m_tipsmsgcont2:setPositionY(stage:getHeight()-100)
	shapeLayer:addChild(m_tipsmsgcont2)
	m_tipsmsgcont3 = F3DDisplayContainer:new()
	m_tipsmsgcont3:setPositionX(math.floor(stage:getWidth()/2))
	m_tipsmsgcont3:setPositionY((not g_mobileMode and ISMIRUI) and 120 or 150)
	shapeLayer:addChild(m_tipsmsgcont3)
	m_tipsmsgcont4 = F3DDisplayContainer:new()
	m_tipsmsgcont4:setVisible(false)
	m_tipsmsgcont4:setPositionX(math.floor(stage:getWidth()/2))
	m_tipsmsgcont4:setPositionY(85)
	m_tipsmsgcont4:setClipRect(-250,-20,500,40)
	m_tipsmsgcont4.bg = F3DImage:new()
	m_tipsmsgcont4.bg:setWidth(500)
	m_tipsmsgcont4.bg:setHeight(g_mobileMode and 30 or 20)
	m_tipsmsgcont4.bg:setPivot(0.5,0.5)
	m_tipsmsgcont4.bg:setTextureFile("tex_white")
	m_tipsmsgcont4.bg:setColor(0.2,0.2,0.2)
	m_tipsmsgcont4.bg:setAlpha(0.8)
	m_tipsmsgcont4:addChild(m_tipsmsgcont4.bg)
	shapeLayer:addChild(m_tipsmsgcont4)
end

function showTipsMsg(postype, msg, prm1, prm2)
	local bk = 0
	if msg:sub(1,3) == "##c" then
		bk = tonumber("0x7f"..msg:sub(4,msg:find(",")-1), 16)
		msg = msg:sub(msg:find(",")+1)
	end
	if postype == 3 then
		if m_tipsmsg3 == nil then
			m_tipsmsg3 = F3DRichTextField:new()
			m_tipsmsg3:getTitle():setPivot(0.5,1)
			m_tipsmsg3:getTitle():setTextFont(F3DPlatform:instance():convert("楷体"), 24, false, false, false)
			m_tipsmsgcont3:addChild(m_tipsmsg3)
		end
		m_tipsmsg3:setTitleText(msg)
		if 游戏设置.OLDTEXTCOLOR then
			m_tipsmsg3:setTextColor(0xff00ff)
		else
		--	m_tipsmsg3:setTextColor(0xff00ff,0,VIPLEVEL >= 4 and bk or 0)
			m_tipsmsg3:setTextColor(0xff00ff, VIPLEVEL >= 4 and bk or 0) --修复后															   
		end
		if msg ~= "" then
			m_tipsheartbeat = g_heartbeatcnt + 50
		end
		return
	elseif postype == 5 then
		消息框UI1.initUI()
		消息框UI1.setData(msg, (prm1 and prm1 ~= "") and function()
			消息.CG_COMMAND_MSG(8, prm1)
		end or nil, (prm2 and prm2 ~= "") and function()
			消息.CG_COMMAND_MSG(8, prm2)
		end or nil, nil, nil, (not prm1 or prm1 == "") and (not prm2 or prm2 == ""))
		return
	end
	if msg == "" then return end
	if m_showtipstime > rtime() then
		m_showtipsmsg[#m_showtipsmsg+1] = {postype, msg}
		return
	end
	m_showtipstime = rtime()+400
	local tf = nil
	for i,v in ipairs(m_tipsmsgs) do
		if not v:isVisible() then
			tf = v
			break
		end
	end
	if tf == nil then
		tf = F3DRichTextField:new()
		m_tipsmsgs[#m_tipsmsgs+1] = tf
	end
	if postype == 0 then
		tf:getTitle():setPivot(0.5,1)
		if 游戏设置.OLDTEXTCOLOR then
			tf:setTextColor(0xffff00)
		else
		--	tf:setTextColor(0xffff00,0,VIPLEVEL >= 4 and bk or 0)
			tf:setTextColor(0xffff00, VIPLEVEL >= 4 and bk or 0)--修复后													  
		end
		tf:setPositionX(0)
	elseif postype == 1 then
		tf:getTitle():setPivot(0.5,1)
		if 游戏设置.OLDTEXTCOLOR then
			tf:setTextColor(0xff0000)
		else
		--	tf:setTextColor(0xff0000,0,VIPLEVEL >= 4 and bk or 0)
			tf:setTextColor(0xffff00, VIPLEVEL >= 4 and bk or 0)--修复后													  
		end
		tf:setPositionX(0)
	else
		tf:getTitle():setPivot(0,0.5)
		if 游戏设置.OLDTEXTCOLOR then
			tf:setTextColor(0xff00ff)
		else
		--	tf:setTextColor(0xff00ff,0,VIPLEVEL >= 4 and bk or 0)
			tf:setTextColor(0xffff00, VIPLEVEL >= 4 and bk or 0)--修复后													  
		end
		tf:setPositionX(250)
	end
	tf:setVisible(true)
	tf:setTitleText((g_mobileMode and "#s16," or "")..msg)
	tf:setPositionY(0)
	if postype == 0 then
		m_tipsmsgcont1:addChild(tf)
	elseif postype == 1 then
		m_tipsmsgcont2:addChild(tf)
	else
		m_tipsrollmsgs[#m_tipsrollmsgs+1] = tf
	end
	local sec = 1
	if postype == 0 or postype == 1 then
		local sec = 1
		F3DTween:fromPool():start(tf, prop1, sec, func_n(function()
			tf:setVisible(false)
			tf:removeFromParent()
		end))
	end
end

prop1 = F3DTweenProp:new()
prop1:push("y", -40, F3DTween.TYPE_LINEAR)

function onHeartBeat()
	if m_tipsheartbeat > 0 and g_heartbeatcnt >= m_tipsheartbeat then
		showTipsMsg(3,"")
		m_tipsheartbeat = 0
	end
	if #m_showtipsmsg > 0 and m_showtipstime <= rtime() then
		showTipsMsg(m_showtipsmsg[1][1], m_showtipsmsg[1][2])
		table.remove(m_showtipsmsg, 1)
	end
	if m_tipsrollheartbeat1 > 0 and g_heartbeatcnt < m_tipsrollheartbeat1 then
	elseif #m_tipsrollmsgs > 0 then
		local tf = m_tipsrollmsgs[1]
		table.remove(m_tipsrollmsgs, 1)
		m_tipsmsgcont4:setVisible(true)
		m_tipsmsgcont4:addChild(tf)
		local w = 聊天UI.calcTextWidth(tf:getTitleText(), g_mobileMode and 16 or 12)
		local sec = (500+w)/50
		local prop2 = F3DTweenProp:new()
		prop2:push("x", -250-w, F3DTween.TYPE_LINEAR)
		F3DTween:fromPool():start(tf, prop2, sec, func_n(function()
			tf:setVisible(false)
			tf:removeFromParent()
		end))
		m_tipsrollheartbeat1 = g_heartbeatcnt + ((50+w)/50)*10
		m_tipsrollheartbeat2 = g_heartbeatcnt + ((500+w)/50)*10
	elseif m_tipsrollheartbeat2 > 0 and g_heartbeatcnt < m_tipsrollheartbeat2 then
	else
		m_tipsrollheartbeat1 = 0
		m_tipsrollheartbeat2 = 0
		m_tipsmsgcont4:setVisible(false)
	end
end

function onStageResize()
	聊天UI.checkResize()
	聊天UID.checkResize()
	背包UI.checkResize()
	if bg then
		bg:setPositionX(stage:getWidth()/5)
		bg:setPositionY(stage:getHeight()-stage:getHeight()/5)
	end
	if m_tipsmsgcont1 then
		m_tipsmsgcont1:setPositionX(math.floor(stage:getWidth()/2))
		m_tipsmsgcont1:setPositionY(150)
	end
	if m_tipsmsgcont2 then
		m_tipsmsgcont2:setPositionX(math.floor(stage:getWidth()/2))
		m_tipsmsgcont2:setPositionY(stage:getHeight()-100)
	end
	if m_tipsmsgcont3 then
		m_tipsmsgcont3:setPositionX(math.floor(stage:getWidth()/2))
		m_tipsmsgcont3:setPositionY((not g_mobileMode and ISMIRUI) and 120 or 150)
	end
	if m_tipsmsgcont4 then
		m_tipsmsgcont4:setPositionX(math.floor(stage:getWidth()/2))
		m_tipsmsgcont4:setPositionY(85)
	end
	m_autofight:setPositionX(stage:getWidth()-300)
	m_autofight:setPositionY(130)
	m_autofindpath:setPositionX(stage:getWidth()-(快捷传送 == 1 and 310 or 300))
	m_autofindpath:setPositionY(130)
end
