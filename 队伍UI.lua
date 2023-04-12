module(..., package.seeall)

local 全局设置 = require("公用.全局设置")
local 消息 = require("网络.消息")
local 角色逻辑 = require("主界面.角色逻辑")
local 物品内观表 = require("配置.物品内观表").Config
local 好友UI=require("主界面.好友UI")
local 消息框UI1=require("主界面.消息框UI1")
local 主界面UI=require("主界面.主界面UI")

m_init = false
m_队伍拒绝邀请 = 0
m_队伍拒绝申请 = 0
m_队友信息 = {}
m_附近队伍 = {}
m_附近玩家 = {}
m_curpage = 1
m_curindex = 1
m_tabid = 0
ITEMCOUNT = 10

function 设置队伍拒绝(队伍拒绝邀请, 队伍拒绝申请)
	m_队伍拒绝邀请 = 队伍拒绝邀请
	m_队伍拒绝申请 = 队伍拒绝申请
	update()
end

function 设置队友信息(队友信息)
	m_队友信息 = 队友信息
	update()
end

function 设置附近队伍(附近队伍)
	m_附近队伍 = 附近队伍
	update()
end

function 设置附近玩家(附近玩家)
	m_附近玩家 = 附近玩家
	update()
end

function update()
	if not m_init then return end
	m_curindex = 1
	if m_tabid == 0 then
		ui.队伍拒绝邀请:setSelected(m_队伍拒绝邀请 == 1)
		ui.队伍拒绝申请:setSelected(m_队伍拒绝申请 == 1)
		for i=1,5 do
			local v = m_队友信息[i]
			ui.队友列表[i].男:setVisible(v and v[3] == 1)
			ui.队友列表[i].女:setVisible(v and v[3] == 2)
			ui.队友列表[i].内观位置:setVisible(v ~= nil)
			if v then
vv=物品内观表[v[6]]
if v[6]>0 and vv then
ui.队友列表[i].武器位置:setTextureFile(全局设置.getStateItemIconUrl(vv.图标ID))
ui.队友列表[i].武器位置:setPositionX(vv.偏移X)
ui.队友列表[i].武器位置:setPositionY(vv.偏移Y)
ui.队友列表[i].武器背景:setTextureFile(全局设置.getStateItemIconUrl(vv.背景图片))
ui.队友列表[i].武器背景:setPositionX(vv.背景偏移X)
ui.队友列表[i].武器背景:setPositionY(vv.背景偏移Y)
ui.队友列表[i].武器特效:setBlendType(vv.图标ID<=0 and F3DRenderContext.BLEND_NORMAL or F3DRenderContext.BLEND_ADD)
if vv.特效ID~=0 then
ui.队友列表[i].武器特效:setAnimPack(全局设置.getAnimPackUrl(vv.特效ID))
ui.队友列表[i].武器特效:setPositionX(vv.图标ID<=0 and vv.偏移X or vv.背景偏移X)
ui.队友列表[i].武器特效:setPositionY(vv.图标ID<=0 and vv.偏移Y or vv.背景偏移Y)
else
ui.队友列表[i].武器特效:reset()
end
else
ui.队友列表[i].武器位置:setTextureFile("")
ui.队友列表[i].武器背景:setTextureFile("")
ui.队友列表[i].武器特效:reset()
end
vv=物品内观表[v[7]]
if v[7]>0 and vv then
ui.队友列表[i].衣服位置:setTextureFile(全局设置.getStateItemIconUrl(vv.图标ID))
ui.队友列表[i].衣服位置:setPositionX(vv.偏移X)
ui.队友列表[i].衣服位置:setPositionY(vv.偏移Y)
ui.队友列表[i].衣服背景:setTextureFile(全局设置.getStateItemIconUrl(vv.背景图片))
ui.队友列表[i].衣服背景:setPositionX(vv.背景偏移X)
ui.队友列表[i].衣服背景:setPositionY(vv.背景偏移Y)
ui.队友列表[i].衣服特效:setBlendType(vv.图标ID<=0 and F3DRenderContext.BLEND_NORMAL or F3DRenderContext.BLEND_ADD)
if vv.特效ID~=0 then
ui.队友列表[i].衣服特效:setAnimPack(全局设置.getAnimPackUrl(vv.特效ID))
ui.队友列表[i].衣服特效:setPositionX(vv.图标ID<=0 and vv.偏移X or vv.背景偏移X)
ui.队友列表[i].衣服特效:setPositionY(vv.图标ID<=0 and vv.偏移Y or vv.背景偏移Y)
else
ui.队友列表[i].衣服特效:reset()
end
else
ui.队友列表[i].衣服位置:setTextureFile("")
ui.队友列表[i].衣服背景:setTextureFile("")
ui.队友列表[i].衣服特效:reset()
end
vv=物品内观表[v[8]]
if v[8]>0 and vv then
ui.队友列表[i].头盔位置:setTextureFile(全局设置.getStateItemIconUrl(vv.图标ID))
ui.队友列表[i].头盔位置:setPositionX(vv.偏移X)
ui.队友列表[i].头盔位置:setPositionY(vv.偏移Y)
else
ui.队友列表[i].头盔位置:setTextureFile("")
end
vv=物品内观表[v[9]]
if v[9]>0 and vv then
ui.队友列表[i].面巾位置:setTextureFile(全局设置.getStateItemIconUrl(vv.图标ID))
ui.队友列表[i].面巾位置:setPositionX(vv.偏移X)
ui.队友列表[i].面巾位置:setPositionY(vv.偏移Y)
else
ui.队友列表[i].面巾位置:setTextureFile("")
end
end
ui.队友列表[i].名字:setTitleText(v and txt(v[1])or"")
ui.队友列表[i].职业:setTitleText(v and txt(全局设置.获取职业类型(v[2]))or"")
ui.队友列表[i].等级:setTitleText(v and txt(v[4].."级")..(v[5]>0 and txt(" ("..v[5].."转"..")")or"")or"")
end
if m_队友信息[1]then
ui.选择框:setPositionX(ui.队友列表[1]:getPositionX())
ui.选择框:setVisible(true)
else
ui.选择框:setVisible(false)
end
elseif m_tabid==1 then
local index=(m_curpage-1)*ITEMCOUNT
for i=1,ITEMCOUNT do
local v=m_附近队伍[index+i]
ui.队伍列表[i].名字:setTitleText(v and txt(v[1])or"")
ui.队伍列表[i].职业:setTitleText(v and txt(全局设置.获取职业类型(v[2]))or"")
ui.队伍列表[i].等级:setTitleText(v and txt(v[3].."级")..(v[4]>0 and txt(" ("..v[4].."转"..")")or"")or"")
ui.队伍列表[i].人数:setTitleText(v and txt(v[5].." / 5")or"")
ui.队伍列表[i].行会:setTitleText(v and txt(v[6]~=""and v[6]or"无")or"")
ui.队伍列表[i].查看:setVisible(v~=nil)
end
if m_附近队伍[index+1]then
ui.选择状态_1:setPositionY(ui.队伍列表[1]:getPositionY())
ui.选择状态_1:setVisible(true)
else
ui.选择状态_1:setVisible(false)
end
local totalpage=math.max(1,math.ceil(#m_附近队伍/ITEMCOUNT))
ui.page_1:setTitleText(m_curpage.." / "..totalpage)
elseif m_tabid==2 then
local index=(m_curpage-1)*ITEMCOUNT
for i=1,ITEMCOUNT do
local v=m_附近玩家[index+i]
ui.玩家列表[i].名字:setTitleText(v and txt(v[1])or"")
ui.玩家列表[i].职业:setTitleText(v and txt(全局设置.获取职业类型(v[2]))or"")
ui.玩家列表[i].等级:setTitleText(v and txt(v[3].."级")..(v[4]>0 and txt(" ("..v[4].."转"..")")or"")or"")
ui.玩家列表[i].战力:setTitleText(v and txt(v[5])or"")
ui.玩家列表[i].行会:setTitleText(v and txt(v[6]~=""and v[6]or"无")or"")
ui.玩家列表[i].查看:setVisible(v~=nil)
end
if m_附近玩家[index+1]then
ui.选择状态_2:setPositionY(ui.玩家列表[1]:getPositionY())
ui.选择状态_2:setVisible(true)
else
ui.选择状态_2:setVisible(false)
end
local totalpage=math.max(1,math.ceil(#m_附近玩家/ITEMCOUNT))
ui.page_2:setTitleText(m_curpage.." / "..totalpage)
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

function onChange(e)
	m_队伍拒绝邀请 = ui.队伍拒绝邀请:isSelected() and 1 or 0
	m_队伍拒绝申请 = ui.队伍拒绝申请:isSelected() and 1 or 0
消息.CG_TEAM_SETUP(m_队伍拒绝邀请,m_队伍拒绝申请,好友UI.m_好友拒绝添加)
end

function onTabChange(e)
	m_tabid = ui.标签栏:getSelectIndex()
	m_curpage = 1
	m_curindex = 1
	ui.选择框:setVisible(false)
	ui.选择状态_1:setVisible(false)
	ui.选择状态_2:setVisible(false)
	if m_tabid == 0 then
		消息.CG_TEAM_TEAMMATE()
	elseif m_tabid == 1 then
		消息.CG_TEAM_NEARBY_TEAM()
	elseif m_tabid == 2 then
ui.创建队伍:setTitleText(角色逻辑.m_teamid==0 and txt("加入队伍")or txt("添加队员"))
		消息.CG_TEAM_NEARBY_MEMBER()
	end
end

function onUIInit()
	ui.close = ui:findComponent("titlebar,close")
	ui.close:addEventListener(F3DMouseEvent.CLICK, func_me(onClose))
	ui:addEventListener(F3DMouseEvent.MOUSE_DOWN, func_me(onMouseDown))
	ui.队伍拒绝邀请 = tt(ui:findComponent("tab_1,conts,cont_1,checkbox_1"),F3DCheckBox)
	ui.队伍拒绝邀请:addEventListener(F3DMouseEvent.CLICK, func_me(onChange))
	ui.队伍拒绝申请 = tt(ui:findComponent("tab_1,conts,cont_1,checkbox_2"),F3DCheckBox)
	ui.队伍拒绝申请:addEventListener(F3DMouseEvent.CLICK, func_me(onChange))
	ui.查看装备 = ui:findComponent("tab_1,conts,cont_1,查看装备")
	ui.查看装备:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
		if m_队友信息[m_curindex] then
			消息.CG_EQUIP_VIEW(-1,m_队友信息[m_curindex][1])
		end
	end))
	ui.加为好友 = ui:findComponent("tab_1,conts,cont_1,加为好友")
	ui.加为好友:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
	end))
	ui.离开队伍 = ui:findComponent("tab_1,conts,cont_1,离开队伍")
	ui.离开队伍:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
		消息.CG_TEAM_LEAVE()
	end))
	ui.移交队长 = ui:findComponent("tab_1,conts,cont_1,移交队长")
	ui.移交队长:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
		if m_队友信息[m_curindex] then
			消息.CG_TEAM_TRANSFER(m_队友信息[m_curindex][1])
		end
	end))
	ui.踢出队伍 = ui:findComponent("tab_1,conts,cont_1,踢出队伍")
	ui.踢出队伍:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
		if m_队友信息[m_curindex] then
			消息.CG_TEAM_DELMEMBER(m_队友信息[m_curindex][1])
		end
	end))
	ui.解散队伍 = ui:findComponent("tab_1,conts,cont_1,解散队伍")
	ui.解散队伍:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
		消息.CG_TEAM_DISMISS()
	end))
	ui.标签栏 = tt(ui:findComponent("tab_1"), F3DTab)
	ui.标签栏:addEventListener(F3DUIEvent.CHANGE, func_me(onTabChange))
	ui.选择框 = ui:findComponent("tab_1,conts,cont_1,选择框")
	ui.选择框:setVisible(false)
	ui.队友列表 = {}
	for i=1,5 do
		ui.队友列表[i] = ui:findComponent("tab_1,conts,cont_1,人物框_"..i)
		ui.队友列表[i].i = i
		ui.队友列表[i]:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
			m_curindex = e:getCurrentTarget().i
			if m_队友信息[m_curindex] then
				ui.选择框:setPositionX(ui.队友列表[m_curindex]:getPositionX())
				ui.选择框:setVisible(true)
			end
		end))
		ui.队友列表[i].男 = ui:findComponent("tab_1,conts,cont_1,人物框_"..i..",男")
		ui.队友列表[i].女 = ui:findComponent("tab_1,conts,cont_1,人物框_"..i..",女")
		ui.队友列表[i].内观位置 = ui:findComponent("tab_1,conts,cont_1,人物框_"..i..",内观位置")
		ui.队友列表[i].衣服位置 = F3DImage:new()
		ui.队友列表[i].内观位置:addChild(ui.队友列表[i].衣服位置)
		ui.队友列表[i].衣服背景 = F3DImage:new()
		ui.队友列表[i].衣服背景:setBlendType(F3DRenderContext.BLEND_ADD)
		ui.队友列表[i].内观位置:addChild(ui.队友列表[i].衣服背景)
		ui.队友列表[i].衣服特效 = F3DImageAnim:new()
		ui.队友列表[i].衣服特效:setBlendType(F3DRenderContext.BLEND_ADD)
		ui.队友列表[i].内观位置:addChild(ui.队友列表[i].衣服特效)
		ui.队友列表[i].武器位置 = F3DImage:new()
		ui.队友列表[i].内观位置:addChild(ui.队友列表[i].武器位置)
		ui.队友列表[i].武器背景 = F3DImage:new()
		ui.队友列表[i].武器背景:setBlendType(F3DRenderContext.BLEND_ADD)
		ui.队友列表[i].内观位置:addChild(ui.队友列表[i].武器背景)
		ui.队友列表[i].武器特效 = F3DImageAnim:new()
		ui.队友列表[i].武器特效:setBlendType(F3DRenderContext.BLEND_ADD)
		ui.队友列表[i].内观位置:addChild(ui.队友列表[i].武器特效)
		ui.队友列表[i].头盔位置 = F3DImage:new()
		ui.队友列表[i].内观位置:addChild(ui.队友列表[i].头盔位置)
		ui.队友列表[i].面巾位置 = F3DImage:new()
		ui.队友列表[i].内观位置:addChild(ui.队友列表[i].面巾位置)
		ui.队友列表[i].名字 = ui:findComponent("tab_1,conts,cont_1,人物框_"..i..",名字")
		ui.队友列表[i].职业 = ui:findComponent("tab_1,conts,cont_1,人物框_"..i..",职业")
		ui.队友列表[i].等级 = ui:findComponent("tab_1,conts,cont_1,人物框_"..i..",等级")
		ui.队友列表[i].avtcont = ui:findComponent("tab_1,conts,cont_1,人物框_"..i..",avtcont")
		ui.队友列表[i].男:setVisible(false)
		ui.队友列表[i].女:setVisible(false)
		ui.队友列表[i].内观位置:setVisible(false)
		ui.队友列表[i].名字:setTitleText("")
		ui.队友列表[i].职业:setTitleText("")
		ui.队友列表[i].等级:setTitleText("")
		tdisui(ui.队友列表[i])
	end
	ui.选择状态_1 = ui:findComponent("tab_1,conts,cont_2,选择状态")
	ui.选择状态_1:setVisible(false)
	ui.队伍列表 = {}
	for i=1,ITEMCOUNT do
		ui.队伍列表[i] = ui:findComponent("tab_1,conts,cont_2,列表项_"..i)
		ui.队伍列表[i].i = i
		ui.队伍列表[i]:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
			m_curindex = e:getCurrentTarget().i
			local index = (m_curpage-1)*ITEMCOUNT
			if m_附近队伍[index+m_curindex] then
				ui.选择状态_2:setPositionY(ui.玩家列表[m_curindex]:getPositionY())
				ui.选择状态_2:setVisible(true)
			end
		end))
		ui.队伍列表[i].名字 = ui:findComponent("tab_1,conts,cont_2,列表项_"..i..",名字")
		ui.队伍列表[i].职业 = ui:findComponent("tab_1,conts,cont_2,列表项_"..i..",职业")
		ui.队伍列表[i].等级 = ui:findComponent("tab_1,conts,cont_2,列表项_"..i..",等级")
		ui.队伍列表[i].人数 = ui:findComponent("tab_1,conts,cont_2,列表项_"..i..",人数")
		ui.队伍列表[i].行会 = ui:findComponent("tab_1,conts,cont_2,列表项_"..i..",行会")
		ui.队伍列表[i].查看 = ui:findComponent("tab_1,conts,cont_2,列表项_"..i..",查看")
		ui.队伍列表[i].查看.i = i
		ui.队伍列表[i].查看:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
			local index = (m_curpage-1)*ITEMCOUNT
			local curindex = e:getCurrentTarget().i
			if curindex and m_附近队伍[index+curindex] then
				消息.CG_EQUIP_VIEW(-1,m_附近队伍[index+curindex][1])
			end
		end))
		ui.队伍列表[i].名字:setTitleText("")
		ui.队伍列表[i].职业:setTitleText("")
		ui.队伍列表[i].等级:setTitleText("")
		ui.队伍列表[i].人数:setTitleText("")
		ui.队伍列表[i].行会:setTitleText("")
		ui.队伍列表[i].查看:setVisible(false)
		tdisui(ui.队伍列表[i])
		ui.队伍列表[i].查看:setTouchable(true)
	end
	ui.page_1 = ui:findComponent("tab_1,conts,cont_2,page")
	ui.pagepre_1 = ui:findComponent("tab_1,conts,cont_2,pagepre")
	ui.pagepre_1:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
		local totalpage = math.max(1, math.ceil(#m_附近队伍 / ITEMCOUNT))
		if m_curpage > 1 then
			m_curpage = math.max(1, m_curpage - 1)
			update()
		end
	end))
	ui.pagenext_1 = ui:findComponent("tab_1,conts,cont_2,pagenext")
	ui.pagenext_1:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
		local totalpage = math.max(1, math.ceil(#m_附近队伍 / ITEMCOUNT))
		if m_curpage < totalpage then
			m_curpage = math.min(totalpage, m_curpage + 1)
			update()
		end
	end))
ui.刷新列表=ui:findComponent("tab_1,conts,cont_2,刷新列表")
ui.刷新列表:addEventListener(F3DMouseEvent.CLICK,func_me(function(e)
		m_curpage = 1
		ui.选择状态_1:setVisible(false)
		消息.CG_TEAM_NEARBY_TEAM()
	end))
ui.创建队伍=ui:findComponent("tab_1,conts,cont_2,创建队伍")
ui.创建队伍:addEventListener(F3DMouseEvent.CLICK,func_me(function(e)
		消息.CG_TEAM_CREATE()
	end))
ui.申请入队=ui:findComponent("tab_1,conts,cont_2,申请入队")
ui.申请入队:addEventListener(F3DMouseEvent.CLICK,func_me(function(e)
		local index = (m_curpage-1)*ITEMCOUNT
		if m_附近队伍[index+m_curindex] then
			消息.CG_TEAM_APPLYENTER(m_附近队伍[index+m_curindex][1])
		end
	end))
	ui.选择状态_2 = ui:findComponent("tab_1,conts,cont_3,选择状态")
	ui.选择状态_2:setVisible(false)
	ui.玩家列表 = {}
	for i=1,ITEMCOUNT do
		ui.玩家列表[i] = ui:findComponent("tab_1,conts,cont_3,列表项_"..i)
		ui.玩家列表[i].i = i
		ui.玩家列表[i]:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
			m_curindex = e:getCurrentTarget().i or 1
			local index = (m_curpage-1)*ITEMCOUNT
			if m_附近玩家[index+m_curindex] then
				ui.选择状态_2:setPositionY(ui.玩家列表[m_curindex]:getPositionY())
				ui.选择状态_2:setVisible(true)
			end
		end))
		ui.玩家列表[i].名字 = ui:findComponent("tab_1,conts,cont_3,列表项_"..i..",名字")
		ui.玩家列表[i].职业 = ui:findComponent("tab_1,conts,cont_3,列表项_"..i..",职业")
		ui.玩家列表[i].等级 = ui:findComponent("tab_1,conts,cont_3,列表项_"..i..",等级")
		ui.玩家列表[i].战力 = ui:findComponent("tab_1,conts,cont_3,列表项_"..i..",战力")
		ui.玩家列表[i].行会 = ui:findComponent("tab_1,conts,cont_3,列表项_"..i..",行会")
		ui.玩家列表[i].查看 = ui:findComponent("tab_1,conts,cont_3,列表项_"..i..",查看")
		ui.玩家列表[i].查看.i = i
		ui.玩家列表[i].查看:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
			local index = (m_curpage-1)*ITEMCOUNT
			local curindex = e:getCurrentTarget().i
			if curindex and m_附近玩家[index+curindex] then
				消息.CG_EQUIP_VIEW(-1,m_附近玩家[index+curindex][1])
			end
		end))
		ui.玩家列表[i].名字:setTitleText("")
		ui.玩家列表[i].职业:setTitleText("")
		ui.玩家列表[i].等级:setTitleText("")
		ui.玩家列表[i].战力:setTitleText("")
		ui.玩家列表[i].行会:setTitleText("")
		ui.玩家列表[i].查看:setVisible(false)
		tdisui(ui.玩家列表[i])
		ui.玩家列表[i].查看:setTouchable(true)
	end
	ui.page_2 = ui:findComponent("tab_1,conts,cont_3,page")
	ui.pagepre_2 = ui:findComponent("tab_1,conts,cont_3,pagepre")
	ui.pagepre_2:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
		local totalpage = math.max(1, math.ceil(#m_附近玩家 / ITEMCOUNT))
		if m_curpage > 1 then
			m_curpage = math.max(1, m_curpage - 1)
			update()
		end
	end))
	ui.pagenext_2 = ui:findComponent("tab_1,conts,cont_3,pagenext")
	ui.pagenext_2:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
		local totalpage = math.max(1, math.ceil(#m_附近玩家 / ITEMCOUNT))
		if m_curpage < totalpage then
			m_curpage = math.min(totalpage, m_curpage + 1)
			update()
		end
	end))
ui.刷新列表=ui:findComponent("tab_1,conts,cont_3,刷新列表")
ui.刷新列表:addEventListener(F3DMouseEvent.CLICK,func_me(function(e)
m_curpage=1
ui.选择状态_2:setVisible(false)
消息.CG_TEAM_NEARBY_MEMBER()
end))
ui.创建队伍=ui:findComponent("tab_1,conts,cont_3,创建队伍")
ui.创建队伍:addEventListener(F3DMouseEvent.CLICK,func_me(function(e)

消息框UI1.initUI()
if 角色逻辑.m_teamid==0 then
消息框UI1.setData(txt("请输入该队伍的队长名字(需要加区服标志)"),_v_2202,nil,nil,true)
else
消息框UI1.setData(txt("请输入要添加的队员名字(需要加区服标志)"),_v_2203,nil,nil,true)
end
end))
ui.邀请组队=ui:findComponent("tab_1,conts,cont_3,邀请组队")
ui.邀请组队:addEventListener(F3DMouseEvent.CLICK,func_me(function(e)
local index=(m_curpage-1)*ITEMCOUNT
if m_附近玩家[index+m_curindex]then
消息.CG_TEAM_ADDMEMBER(m_附近玩家[index+m_curindex][1])
end
end))
m_init=true
update()
end

function _v_2202(_v_2205)
if _v_2205==nil or _v_2205==""then
主界面UI.showTipsMsg(1,txt("请输入队长名称"))
return
end
if _v_2205:len()>15 then
主界面UI.showTipsMsg(1,txt("名字字数超过上限"))
return
end
消息.CG_TEAM_APPLYENTER(utf8(_v_2205))
end

function _v_2203(_v_2205)
if _v_2205==nil or _v_2205==""then
主界面UI.showTipsMsg(1,txt("请输入队员名称"))
return
end
if _v_2205:len()>15 then
主界面UI.showTipsMsg(1,txt("名字字数超过上限"))
return
end
消息.CG_TEAM_ADDMEMBER(utf8(_v_2205))
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
	ui = F3DLayout:new()
	uiLayer:addChild(ui)
	ui:setLoadPriority(getUIPriority())
	ui:setMovable(true)
	ui:addEventListener(F3DObjEvent.OBJ_INITED, func_e(onUIInit))
if ui.setUIPack and USEUIPACK then
ui:setUIPack(g_mobileMode and UIPATH.."队伍UIm.pack"or UIPATH.."队伍UI.pack")
else
	ui:setLayout(g_mobileMode and UIPATH.."队伍UIm.layout" or UIPATH.."队伍UI.layout")
end
_v_62(ui,true)
end
