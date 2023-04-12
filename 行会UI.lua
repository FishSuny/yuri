module(..., package.seeall)

local 全局设置 = require("公用.全局设置")
local 消息 = require("网络.消息")
local 角色逻辑 = require("主界面.角色逻辑")
local 实用工具 = require("公用.实用工具")
local 游戏设置=require("公用.游戏设置")
local 消息框UI1 = require("主界面.消息框UI1")
local 主界面UI = require("主界面.主界面UI")
local 背包UI = require("主界面.背包UI")
local 商店UI = require("主界面.商店UI")

m_init = false
m_行会信息 = {}
m_行会成员 = {}
m_行会日志 = {}
m_行会列表 = {}
m_城堡信息={}
_v_1776=""
_v_1777=0
_v_1778={}
_v_1779=0
m_curpage = 1
m_curindex = 1
m_tabid = 0
m_selname = ""
ITEMCOUNT1 = 10
ITEMCOUNT2 = 11
ITEMCOUNT3 = 13

function 设置行会信息(行会信息)
	m_行会信息 = 行会信息
	update()
end

function 设置行会成员(行会成员)
	m_行会成员 = 行会成员
	table.sort(m_行会成员, CompareRanking)
	update()
end

function 设置行会日志(行会日志)
	m_行会日志 = 行会日志
	update()
end

function 设置行会列表(行会列表)
	m_行会列表 = 行会列表
	update()
end

function 设置城堡信息(_v_1794,guildname,time,score,funds)
m_城堡信息=_v_1794
_v_1776=guildname
_v_1777=time
_v_1778=score
_v_1779=funds
update()
end

function CompareRanking(first,second)
	if first[8] ~= second[8] then return first[8]>second[8] end
	if first[6] ~= second[6] then return first[6]>second[6] end
	if first[5] ~= second[5] then return first[5]>second[5] end
end

function update()
	if not m_init then return end
	m_curindex = 1
	if m_tabid == 0 then
		if m_行会信息[1] then
			实用工具.setClipNumber(m_行会信息[1][4],ui.行会等级,false)
local name,_v_1797
local ss=实用工具.SplitString(m_行会信息[1][2],"%.")
if#ss==3 then
name=ss[1].."."..ss[2]
_v_1797=tonumber(ss[3])or 0
else
name=m_行会信息[1][2]
_v_1797=20+m_行会信息[1][4]*10
end
ui.行会名称:setTitleText(txt(name))
			ui.会长:setTitleText(txt(m_行会信息[1][3]))
			ui.排名:setTitleText(m_行会信息[1][1])
ui.人数:setTitleText(m_行会信息[1][5].." / ".._v_1797)
			ui.行会资金:setTitleText(m_行会信息[1][7])
			ui.总战力:setTitleText(m_行会信息[1][6])
		else
			实用工具.setClipNumber(0,ui.行会等级,false)
			ui.行会名称:setTitleText(txt("无"))
			ui.会长:setTitleText("")
			ui.排名:setTitleText("")
			ui.人数:setTitleText("")
			ui.行会资金:setTitleText("")
			ui.总战力:setTitleText("")
		end
		local index = (m_curpage-1)*ITEMCOUNT1
		for i=1,ITEMCOUNT1 do
			local v = m_行会成员[index+i]
			ui.行会成员[i].名字:setTitleText(v and txt(v[1]) or "")
			ui.行会成员[i].职业:setTitleText(v and txt(全局设置.获取职业类型(v[2])) or "")
ui.行会成员[i].等级:setTitleText(v and txt(v[3].."级")..(v[4]>0 and txt(" ("..v[4].."转"..")")or"")or"")
			ui.行会成员[i].战力:setTitleText(v and v[5] or "")
			ui.行会成员[i].职位:setTitleText(v and txt(全局设置.获取行会职位(v[6])) or "")
			ui.行会成员[i].行会贡献:setTitleText(v and v[7] or "")
			ui.行会成员[i].状态:setTextColor((v and v[8] == 1) and 0xff00 or 0xff0000)
			ui.行会成员[i].状态:setTitleText(v and txt(v[8] == 1 and "在线" or "离线") or "")
			ui.行会成员[i].查看:setVisible(v ~= nil)
		end
		if m_行会成员[index+1] then
			ui.选择状态_1:setPositionY(ui.行会成员[1]:getPositionY())
			ui.选择状态_1:setVisible(true)
		else
			ui.选择状态_1:setVisible(false)
		end
		local totalpage = math.max(1, math.ceil(#m_行会成员 / ITEMCOUNT1))
		ui.page_1:setTitleText(m_curpage.." / "..totalpage)
	elseif m_tabid == 1 then
		local index = (m_curpage-1)*ITEMCOUNT2
		for i=1,ITEMCOUNT2 do
			local v = m_行会日志[index+i]
			ui.行会日志[i].信息:setTitleText(v and txt(v[1]) or "")
			local str = v == nil and "" or v[2] < 60 and v[2].."秒前" or v[2] < 3600 and math.floor(v[2]/60).."分钟前" or v[2] < 86400 and math.floor(v[2]/3600).."小时前" or math.floor(v[2]/86400).."天前"
			ui.行会日志[i].时间:setTitleText(txt(str))
			ui.行会日志[i].同意:setVisible(v ~= nil and ui.日志标签栏:getSelectIndex() == 2)
			ui.行会日志[i].拒绝:setVisible(v ~= nil and ui.日志标签栏:getSelectIndex() == 2)
		end
		if m_行会日志[index+1] then
			ui.选择状态_2:setPositionY(ui.行会日志[1]:getPositionY())
			ui.选择状态_2:setVisible(true)
		else
			ui.选择状态_2:setVisible(false)
		end
		local totalpage = math.max(1, math.ceil(#m_行会日志 / ITEMCOUNT2))
		ui.page_2:setTitleText(m_curpage.." / "..totalpage)
	elseif m_tabid == 2 then
		local index = (m_curpage-1)*ITEMCOUNT3
		for i=1,ITEMCOUNT3 do
			local v = m_行会列表[index+i]
			if v and v[1] <= 3 then
				ui.行会列表[i].排名:setBackground(v[1] == 1 and UIPATH.."行会/第一.png" or v[1] == 2 and UIPATH.."行会/第二.png" or UIPATH.."行会/第三.png")
				ui.行会列表[i].排名:setTitleText("")
			else
				ui.行会列表[i].排名:setBackground("")
				ui.行会列表[i].排名:setTitleText(v and v[1] or "")
			end
local name,_v_1797
if v then
local ss=实用工具.SplitString(v[2],"%.")
if#ss==3 then
name=ss[1].."."..ss[2]
_v_1797=tonumber(ss[3])or 0
else
name=v[2]
_v_1797=20+v[4]*10
end
end
ui.行会列表[i].名称:setTitleText(v and txt(name)or"")
ui.行会列表[i].会长:setTitleText(v and txt(v[3])or"")
ui.行会列表[i].等级:setTitleText(v and txt(v[4].."级")or"")
ui.行会列表[i].人数:setTitleText(v and(v[5].." / ".._v_1797)or"")
ui.行会列表[i].战力:setTitleText(v and v[6]or"")
ui.行会列表[i].申请:setVisible(v~=nil)
if v and v[8]~=0 then
ui.行会列表[i].申请:getBackground():setVisible(false)
ui.行会列表[i].申请:setTitleText(v[8]==1 and txt("已申请")or v[8]==2 and txt("已加入")or v[8]==3 and txt("已挑战")or v[8]==4 and txt("已联盟")or v[8]==6 and txt("挑战中")or v[8]==7 and txt("联盟中")or"")
ui.行会列表[i].申请:setTouchable(false)
else
ui.行会列表[i].申请:getBackground():setVisible(true)
ui.行会列表[i].申请:setTitleText(txt("申请"))
ui.行会列表[i].申请:setTouchable(true)
end
end
if m_行会列表[index+1]then
ui.选择状态_3:setPositionY(ui.行会列表[1]:getPositionY())
ui.选择状态_3:setVisible(true)
else
ui.选择状态_3:setVisible(false)
end
local totalpage=math.max(1,math.ceil(#m_行会列表/ITEMCOUNT3))
ui.page_3:setTitleText(m_curpage.." / "..totalpage)
elseif m_tabid==3 then
for i,v in ipairs(m_城堡信息)do
local str=v[2]~=""and v[2]or"无"
if v[3]==""then
str=str.."，暂无行会攻城"
else
str=str.."，攻城行会为："..v[3]
end
if v[3]~=""then
str=str.."，攻城时间为："..(v[4]==0 and"今天"or v[4]==-1 and"明天"or(-v[4]).."天后")
elseif v[2]~=""and v[3]==""then
str=str.."，占领时间为："..(v[4]==0 and"今天"or v[4]==1 and"昨天"or v[4].."天前")
end
if v[1]==1 then
ui.比奇皇宫:setTitleText(txt("8：当前占领比奇皇宫的行会为："..str))
elseif v[1]==2 then
ui.封魔皇宫:setTitleText(txt("9：当前占领封魔皇宫的行会为："..str))
elseif v[1]==3 then
ui.沙巴克:setTitleText(txt("10：当前占领沙巴克的行会为："..str))
end
end
ui._v_1820:setTitleText(txt("13：胜利赢取挑战资金：".._v_1779.."，剩余时间："..math.ceil(_v_1777/60).."分钟，挑战行会：".._v_1776.."，敌我比分："..(_v_1778[1]or 0).."："..(_v_1778[2]or 0)))
end
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

function onTabChange(e)
	m_tabid = ui.标签栏:getSelectIndex()
	m_curpage = 1
	m_curindex = 1
	ui.选择状态_1:setVisible(false)
	ui.选择状态_2:setVisible(false)
	ui.选择状态_3:setVisible(false)
	if m_tabid == 0 then
		消息.CG_GUILD_MEMBER()
	elseif m_tabid == 1 then
		消息.CG_GUILD_RECORD(ui.日志标签栏:getSelectIndex())
	elseif m_tabid == 2 then
		消息.CG_GUILD_QUERY()
	elseif m_tabid == 3 then
		消息.CG_GUILD_CASTLEINFO()
	end
end

function onRecordTabChange(e)
	m_curpage = 1
	m_curindex = 1
	ui.选择状态_2:setVisible(false)
	消息.CG_GUILD_RECORD(ui.日志标签栏:getSelectIndex())
end

function onLevelUpOK(guildname)
	消息.CG_GUILD_LEVELUP()
end

function onCreateOK(guildname)
	if guildname == nil or guildname == "" then
		主界面UI.showTipsMsg(1,txt("请输入你的行会名称"))
		return
	end
if guildname:len()>15 then
主界面UI.showTipsMsg(1,txt("名字字数超过上限"))
		return
	end
	消息.CG_GUILD_CREATE(utf8(guildname))
end

function onChallengeOK(zijin)
if zijin==nil or zijin==""then
zijin="0"
end
if zijin==nil or zijin==""then
主界面UI.showTipsMsg(1,txt("请输入挑战资金"))
return
end
if tonumber(zijin)==nil or tonumber(zijin)<0 then
主界面UI.showTipsMsg(1,txt("请输入挑战资金"))
return
end
消息.CG_GUILD_CHALLENGE(m_selname,tonumber(zijin))
end

function _v_1831(zijin)
if zijin==nil or zijin==""then
zijin="0"
end
if zijin==nil or zijin==""then
主界面UI.showTipsMsg(1,txt("请输入结盟资金"))
return
end
if tonumber(zijin)==nil or tonumber(zijin)<0 then
主界面UI.showTipsMsg(1,txt("请输入结盟资金"))
return
end
消息.CG_GUILD_ALLIANCE(m_selname,tonumber(zijin))
end

function _v_1833()
消息.CG_GUILD_ALLIANCE(m_selname,-1)
end

function onAdjustOK(zhiwei)
if zhiwei==nil or zhiwei==""then
主界面UI.showTipsMsg(1,txt("请选择行会职位"))
return
end
消息.CG_GUILD_ADJUST(m_selname,zhiwei==txt("会长")and 3 or zhiwei==txt("副会长")and 2 or zhiwei==txt("管理员")and 1 or 0)
end

function onAttackCastleOK(castle)
if castle==nil or castle==""then
主界面UI.showTipsMsg(1,txt("请选择行会职位"))
return
end
消息.CG_GUILD_ATTACKCASTLE(castle==txt("比奇皇宫")and 1 or castle==txt("封魔皇宫")and 2 or 3)
end

function onUIInit()
	ui.close = ui:findComponent("titlebar,close")
	ui.close:addEventListener(F3DMouseEvent.CLICK, func_me(onClose))
	ui:addEventListener(F3DMouseEvent.MOUSE_DOWN, func_me(onMouseDown))
	ui.行会等级 = ui:findComponent("tab_1,conts,cont_1,军团信息底框,行会等级"):getBackground()
	ui.行会名称 = ui:findComponent("tab_1,conts,cont_1,军团信息底框,行会名称")
	ui.会长 = ui:findComponent("tab_1,conts,cont_1,军团信息底框,会长")
	ui.排名 = ui:findComponent("tab_1,conts,cont_1,军团信息底框,排名")
	ui.人数 = ui:findComponent("tab_1,conts,cont_1,军团信息底框,人数")
	ui.行会资金 = ui:findComponent("tab_1,conts,cont_1,军团信息底框,行会资金")
	ui.总战力 = ui:findComponent("tab_1,conts,cont_1,军团信息底框,总战力")
	实用工具.setClipNumber(0,ui.行会等级,false)
	ui.行会名称:setTitleText(txt("无"))
	ui.会长:setTitleText("")
	ui.排名:setTitleText("")
	ui.人数:setTitleText("")
	ui.行会资金:setTitleText("")
	ui.总战力:setTitleText("")
	ui.行会升级 = ui:findComponent("tab_1,conts,cont_1,军团信息底框,行会升级")
	ui.行会升级:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
		if m_行会信息[1] then
			local funds = math.pow(2,m_行会信息[1][4])*10000
			消息框UI1.initUI()
			消息框UI1.setData(txt("升级#cffff00,"..(m_行会信息[1][4]+1).."级#C行会需要#cff00ff,"..funds.."#C行会资金, #cff00ff,副会长以上"),onLevelUpOK,nil,nil,false)
		end
	end))
	ui.行会商店 = ui:findComponent("tab_1,conts,cont_1,军团信息底框,行会商店")
	ui.行会商店:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
		背包UI.initUI()
		if 背包UI.m_init then
			商店UI.setTalkID(-1)
			商店UI.initUI()
			背包UI.otherui = 商店UI
			背包UI.checkResize()
		else
			背包UI.ui:addEventListener(F3DObjEvent.OBJ_INITED, func_e(function(e)
				商店UI.setTalkID(-1)
				商店UI.initUI()
				背包UI.otherui = 商店UI
				背包UI.checkResize()
			end))
		end
	end))
	ui.退出行会 = ui:findComponent("tab_1,conts,cont_1,选项底,退出行会")
	ui.退出行会:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
		消息框UI1.initUI()
		消息框UI1.setData(txt("是否确定退出行会?"),function()
			消息.CG_GUILD_LEAVE()
		end,nil,nil,nil)
	end))
	ui.调整职位 = ui:findComponent("tab_1,conts,cont_1,选项底,调整职位")
	ui.调整职位:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
		local index = (m_curpage-1)*ITEMCOUNT1
		if m_行会成员[index+m_curindex] then
			m_selname = m_行会成员[index+m_curindex][1]
			消息框UI1.initUI()
			消息框UI1.setData(txt("只能调整职位比自己低的成员,可以转让#cff00ff,会长#C职位"),onAdjustOK,nil,nil,{txt("成员"),txt("管理员"),txt("副会长"),txt("会长")})
		end
	end))
	ui.踢出行会 = ui:findComponent("tab_1,conts,cont_1,选项底,踢出行会")
	ui.踢出行会:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
		local index = (m_curpage-1)*ITEMCOUNT1
		if m_行会成员[index+m_curindex] then
			m_selname = m_行会成员[index+m_curindex][1]
			消息框UI1.initUI()
			消息框UI1.setData(txt("是否确定踢出该成员?"),function()
				消息.CG_GUILD_KICK(m_selname)
			end,nil,nil,nil)
		end
	end))
	ui.标签栏 = tt(ui:findComponent("tab_1"), F3DTab)
	ui.标签栏:addEventListener(F3DUIEvent.CHANGE, func_me(onTabChange))
	ui.选择状态_1 = ui:findComponent("tab_1,conts,cont_1,成员显示底,当前选择显示")
	ui.选择状态_1:setVisible(false)
	ui.行会成员 = {}
	for i=1,ITEMCOUNT1 do
		ui.行会成员[i] = ui:findComponent("tab_1,conts,cont_1,成员显示底,列表项_"..i)
		ui.行会成员[i].i = i
		ui.行会成员[i]:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
			m_curindex = e:getCurrentTarget().i
			local index = (m_curpage-1)*ITEMCOUNT1
			if m_行会成员[index+m_curindex] then
				ui.选择状态_1:setPositionY(ui.行会成员[m_curindex]:getPositionY())
				ui.选择状态_1:setVisible(true)
			end
		end))
		ui.行会成员[i].名字 = ui:findComponent("tab_1,conts,cont_1,成员显示底,列表项_"..i..",名字")
		ui.行会成员[i].职业 = ui:findComponent("tab_1,conts,cont_1,成员显示底,列表项_"..i..",职业")
		ui.行会成员[i].等级 = ui:findComponent("tab_1,conts,cont_1,成员显示底,列表项_"..i..",等级")
		ui.行会成员[i].战力 = ui:findComponent("tab_1,conts,cont_1,成员显示底,列表项_"..i..",战力")
		ui.行会成员[i].职位 = ui:findComponent("tab_1,conts,cont_1,成员显示底,列表项_"..i..",职位")
		ui.行会成员[i].行会贡献 = ui:findComponent("tab_1,conts,cont_1,成员显示底,列表项_"..i..",行会贡献")
		ui.行会成员[i].状态 = ui:findComponent("tab_1,conts,cont_1,成员显示底,列表项_"..i..",状态")
		ui.行会成员[i].查看 = ui:findComponent("tab_1,conts,cont_1,成员显示底,列表项_"..i..",查看")
		ui.行会成员[i].查看.i = i
		ui.行会成员[i].查看:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
			local index = (m_curpage-1)*ITEMCOUNT1
			local curindex = e:getCurrentTarget().i
			if curindex and m_行会成员[index+curindex] then
消息.CG_EQUIP_VIEW(-1,m_行会成员[index+curindex][1])
			end
		end))
		ui.行会成员[i].名字:setTitleText("")
		ui.行会成员[i].职业:setTitleText("")
		ui.行会成员[i].等级:setTitleText("")
		ui.行会成员[i].战力:setTitleText("")
		ui.行会成员[i].职位:setTitleText("")
		ui.行会成员[i].行会贡献:setTitleText("")
		ui.行会成员[i].状态:setTitleText("")
		ui.行会成员[i].查看:setVisible(false)
		tdisui(ui.行会成员[i])
		ui.行会成员[i].查看:setTouchable(true)
	end
	ui.page_1 = ui:findComponent("tab_1,conts,cont_1,选项底,page")
	ui.pagepre_1 = ui:findComponent("tab_1,conts,cont_1,选项底,pagepre")
	ui.pagepre_1:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
		local totalpage = math.max(1, math.ceil(#m_行会成员 / ITEMCOUNT1))
		if m_curpage > 1 then
			m_curpage = math.max(1, m_curpage - 1)
			update()
		end
	end))
	ui.pagenext_1 = ui:findComponent("tab_1,conts,cont_1,选项底,pagenext")
	ui.pagenext_1:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
		local totalpage = math.max(1, math.ceil(#m_行会成员 / ITEMCOUNT1))
		if m_curpage < totalpage then
			m_curpage = math.min(totalpage, m_curpage + 1)
			update()
		end
	end))
	ui.日志标签栏 = tt(ui:findComponent("tab_1,conts,cont_2,tab_1"), F3DTab)
	ui.日志标签栏:addEventListener(F3DUIEvent.CHANGE, func_me(onRecordTabChange))
	ui.选择状态_2 = ui:findComponent("tab_1,conts,cont_2,当前选择显示")
	ui.选择状态_2:setVisible(false)
	ui.行会日志 = {}
	for i=1,ITEMCOUNT2 do
		ui.行会日志[i] = ui:findComponent("tab_1,conts,cont_2,列表项_"..i)
		ui.行会日志[i].i = i
		ui.行会日志[i]:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
			m_curindex = e:getCurrentTarget().i
			local index = (m_curpage-1)*ITEMCOUNT2
			if m_行会日志[index+m_curindex] then
				ui.选择状态_2:setPositionY(ui.行会日志[m_curindex]:getPositionY())
				ui.选择状态_2:setVisible(true)
			end
		end))
		ui.行会日志[i].信息 = ui:findComponent("tab_1,conts,cont_2,列表项_"..i..",信息")
		ui.行会日志[i].时间 = ui:findComponent("tab_1,conts,cont_2,列表项_"..i..",时间")
		ui.行会日志[i].同意 = ui:findComponent("tab_1,conts,cont_2,列表项_"..i..",同意")
		ui.行会日志[i].同意.i = i
		ui.行会日志[i].同意:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
			local index = (m_curpage-1)*ITEMCOUNT2
			local curindex = e:getCurrentTarget().i
			if curindex and m_行会日志[index+curindex] then
				if m_行会日志[index+curindex][4] == 1 then
					消息.CG_GUILD_CHALLENGEAGREE(m_行会日志[index+curindex][3],1)
				elseif m_行会日志[index+curindex][4] == 2 then
					消息.CG_GUILD_ALLIANCEAGREE(m_行会日志[index+curindex][3],1)
				else
					消息.CG_GUILD_APPLYAGREE(m_行会日志[index+curindex][3],1)
				end
			end
		end))
		ui.行会日志[i].拒绝 = ui:findComponent("tab_1,conts,cont_2,列表项_"..i..",拒绝")
		ui.行会日志[i].拒绝.i = i
		ui.行会日志[i].拒绝:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
			local index = (m_curpage-1)*ITEMCOUNT2
			local curindex = e:getCurrentTarget().i
			if curindex and m_行会日志[index+curindex] then
				if m_行会日志[index+curindex][4] == 1 then
					消息.CG_GUILD_CHALLENGEAGREE(m_行会日志[index+curindex][3],0)
				elseif m_行会日志[index+curindex][4] == 2 then
					消息.CG_GUILD_ALLIANCEAGREE(m_行会日志[index+curindex][3],0)
				else
					消息.CG_GUILD_APPLYAGREE(m_行会日志[index+curindex][3],0)
				end
			end
		end))
		ui.行会日志[i].信息:setTitleText("")
		ui.行会日志[i].时间:setTitleText("")
		ui.行会日志[i].同意:setVisible(false)
		ui.行会日志[i].拒绝:setVisible(false)
		tdisui(ui.行会日志[i])
		ui.行会日志[i].同意:setTouchable(true)
		ui.行会日志[i].拒绝:setTouchable(true)
	end
	ui.page_2 = ui:findComponent("tab_1,conts,cont_2,page")
	ui.pagepre_2 = ui:findComponent("tab_1,conts,cont_2,pagepre")
	ui.pagepre_2:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
		local totalpage = math.max(1, math.ceil(#m_行会日志 / ITEMCOUNT2))
		if m_curpage > 1 then
			m_curpage = math.max(1, m_curpage - 1)
			update()
		end
	end))
	ui.pagenext_2 = ui:findComponent("tab_1,conts,cont_2,pagenext")
	ui.pagenext_2:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
		local totalpage = math.max(1, math.ceil(#m_行会日志 / ITEMCOUNT2))
		if m_curpage < totalpage then
			m_curpage = math.min(totalpage, m_curpage + 1)
			update()
		end
	end))
	ui.创建行会 = ui:findComponent("tab_1,conts,cont_3,选项底,创建行会")
	ui.创建行会:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
		消息框UI1.initUI()
		消息框UI1.setData(txt("创建行会需要提交#cff00ff,沃玛号角#C, 以及#cffff00,100万金币"),onCreateOK,nil,nil,true)
	end))
	ui.挑战行会 = ui:findComponent("tab_1,conts,cont_3,选项底,挑战行会")
	ui.挑战行会:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
		local index = (m_curpage-1)*ITEMCOUNT3
if m_行会列表[index+m_curindex]then
local ss=实用工具.SplitString(m_行会列表[index+m_curindex][2],"%.")
if#ss==3 then
m_selname=ss[1].."."..ss[2]
else
			m_selname = m_行会列表[index+m_curindex][2]
end
			消息框UI1.initUI()
消息框UI1.setData(txt("挑战行会需要输入#cff00ff,挑战资金#C, #cff00ff,副会长以上"),onChallengeOK,nil,nil,true)
end
end))
ui.行会结盟=ui:findComponent("tab_1,conts,cont_3,选项底,行会结盟")
ui.行会结盟:addEventListener(F3DMouseEvent.CLICK,func_me(function(e)
local index=(m_curpage-1)*ITEMCOUNT3
if m_行会列表[index+m_curindex]then
local ss=实用工具.SplitString(m_行会列表[index+m_curindex][2],"%.")
if#ss==3 then
m_selname=ss[1].."."..ss[2]
else
m_selname=m_行会列表[index+m_curindex][2]
end
消息框UI1.initUI()
if m_行会列表[index+m_curindex][8]==7 then
消息框UI1.setData(txt("是否确定解除行会联盟? 需要#cff00ff,副会长以上"),_v_1833,nil,nil,false)
else
消息框UI1.setData(txt("行会结盟需要输入#cff00ff,结盟资金#C, #cff00ff,副会长以上"),_v_1831,nil,nil,true)
end
end
end))
ui.选择状态_3=ui:findComponent("tab_1,conts,cont_3,当前选择显示")
ui.选择状态_3:setVisible(false)
ui.行会列表={}
for i=1,ITEMCOUNT3 do
ui.行会列表[i]=ui:findComponent("tab_1,conts,cont_3,列表项_"..i)
ui.行会列表[i].i=i
ui.行会列表[i]:addEventListener(F3DMouseEvent.CLICK,func_me(function(e)
m_curindex=e:getCurrentTarget().i
local index=(m_curpage-1)*ITEMCOUNT3
if m_行会列表[index+m_curindex]then
ui.选择状态_3:setPositionY(ui.行会列表[m_curindex]:getPositionY())
ui.选择状态_3:setVisible(true)
ui.行会结盟:setTitleText(m_行会列表[index+m_curindex][8]==7 and txt("解除联盟")or txt("行会结盟"))
end
end))
ui.行会列表[i].排名=ui:findComponent("tab_1,conts,cont_3,列表项_"..i..",排名")
ui.行会列表[i].名称=ui:findComponent("tab_1,conts,cont_3,列表项_"..i..",名称")
ui.行会列表[i].会长=ui:findComponent("tab_1,conts,cont_3,列表项_"..i..",会长")
ui.行会列表[i].等级=ui:findComponent("tab_1,conts,cont_3,列表项_"..i..",等级")
ui.行会列表[i].人数=ui:findComponent("tab_1,conts,cont_3,列表项_"..i..",人数")
ui.行会列表[i].战力=ui:findComponent("tab_1,conts,cont_3,列表项_"..i..",战力")
ui.行会列表[i].申请=ui:findComponent("tab_1,conts,cont_3,列表项_"..i..",申请")
ui.行会列表[i].申请.i=i
ui.行会列表[i].申请:addEventListener(F3DMouseEvent.CLICK,func_me(function(e)
local index=(m_curpage-1)*ITEMCOUNT3
local curindex=e:getCurrentTarget().i
if curindex and m_行会列表[index+curindex]then
local name
local ss=实用工具.SplitString(m_行会列表[index+curindex][2],"%.")
if#ss==3 then
name=ss[1].."."..ss[2]
else
name=m_行会列表[index+curindex][2]
end
消息.CG_GUILD_APPLY(name)
end
end))
ui.行会列表[i].排名:setBackground("")
ui.行会列表[i].排名:setTitleText("")
ui.行会列表[i].名称:setTitleText("")
ui.行会列表[i].会长:setTitleText("")
ui.行会列表[i].等级:setTitleText("")
ui.行会列表[i].人数:setTitleText("")
ui.行会列表[i].战力:setTitleText("")
ui.行会列表[i].申请:setVisible(false)
tdisui(ui.行会列表[i])
ui.行会列表[i].申请:setTouchable(true)
end
ui.page_3=ui:findComponent("tab_1,conts,cont_3,选项底,page")
ui.pagepre_3=ui:findComponent("tab_1,conts,cont_3,选项底,pagepre")
ui.pagepre_3:addEventListener(F3DMouseEvent.CLICK,func_me(function(e)
local totalpage=math.max(1,math.ceil(#m_行会列表/ITEMCOUNT3))
if m_curpage>1 then
m_curpage=math.max(1,m_curpage-1)
update()
end
end))
ui.pagenext_3=ui:findComponent("tab_1,conts,cont_3,选项底,pagenext")
ui.pagenext_3:addEventListener(F3DMouseEvent.CLICK,func_me(function(e)
local totalpage=math.max(1,math.ceil(#m_行会列表/ITEMCOUNT3))
if m_curpage<totalpage then
m_curpage=math.min(totalpage,m_curpage+1)
update()
end
end))
ui.比奇皇宫=ui:findComponent("tab_1,conts,cont_4,component_9")
ui.封魔皇宫=ui:findComponent("tab_1,conts,cont_4,component_10")
ui.沙巴克=ui:findComponent("tab_1,conts,cont_4,component_11")
ui._v_1820=ui:findComponent("tab_1,conts,cont_4,component_14")
ui.申请攻城=ui:findComponent("tab_1,conts,cont_4,选项底,申请攻城")
ui.申请攻城:addEventListener(F3DMouseEvent.CLICK,func_me(function(e)
消息框UI1.initUI()
消息框UI1.setData(txt("#cff00ff,副会长以上#C职位可以申请攻城,需要提交#cffff00,祖玛头像"),onAttackCastleOK,nil,nil,游戏设置.ATTACKCASTLE)
end))
ui.攻城区域=ui:findComponent("tab_1,conts,cont_4,选项底,攻城区域")
ui.攻城区域:addEventListener(F3DMouseEvent.CLICK,func_me(function(e)
消息.CG_GUILD_ATTACKMAP()
end))
ui.挑战地图=ui:findComponent("tab_1,conts,cont_4,选项底,挑战地图")
ui.挑战地图:addEventListener(F3DMouseEvent.CLICK,func_me(function(e)
消息.CG_GUILD_CHALLENGEMAP()
end))
m_init=true
update()
消息.CG_GUILD_MEMBER()
end

function isHided()
return not ui or not ui:isVisible()or ui.tweenhide
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
ui=F3DLayout:new()
uiLayer:addChild(ui)
ui:setLoadPriority(getUIPriority())
ui:setMovable(true)
ui:addEventListener(F3DObjEvent.OBJ_INITED,func_e(onUIInit))
if ui.setUIPack and USEUIPACK then
ui:setUIPack(g_mobileMode and UIPATH.."行会UIm.pack"or UIPATH.."行会UI.pack")
else
ui:setLayout(g_mobileMode and UIPATH.."行会UIm.layout"or UIPATH.."行会UI.layout")
end
_v_62(ui,true)
end

