module(..., package.seeall)

local 全局设置 = require("公用.全局设置")
local 消息 = require("网络.消息")
local 角色逻辑 = require("主界面.角色逻辑")
local 消息框UI1 = require("主界面.消息框UI1")
local 聊天UI = require("主界面.聊天UI")
local 队伍UI = require("主界面.队伍UI")

m_init = false
m_friend = {}
m_enemy = {}
m_blacklist = {}
m_cnts = {}
m_好友拒绝添加 = 0
m_curpage = 1
m_curindex = 1
m_tabid = 0
m_pool = {}
m_poolindex = 1
ITEMCOUNT = 5

function 设置好友拒绝(好友拒绝添加)
	m_好友拒绝添加 = 好友拒绝添加
	update()
end

function 设置好友信息(type,friend,enemy,blacklist,cnts)
	if type == 0 then
		m_friend = friend
	elseif type == 1 then
		m_enemy = enemy
	elseif type == 2 then
		m_blacklist = blacklist
	end
	m_cnts = cnts
	update()
end

function update()
	if not m_init then return end
	ui.好友:setTitleText(txt("好友 ("..(m_cnts[1] or 0).." / "..(m_cnts[2] or 0)..")"))
	ui.仇人:setTitleText(txt("仇人 ("..(m_cnts[3] or 0).." / "..(m_cnts[4] or 0)..")"))
	ui.黑名单:setTitleText(txt("黑名单 ("..(m_cnts[5] or 0).." / "..(m_cnts[6] or 0)..")"))
	if m_tabid == 0 then
		ui.好友拒绝添加:setSelected(m_好友拒绝添加 == 1)
		local index = (m_curpage-1)*ITEMCOUNT
		for i=1,ITEMCOUNT do
			local v = m_friend[index+i]
			if v then
				ui.好友列表[i]:setVisible(true)
				ui.好友列表[i].头像:setDisable(v[5]==0)
				ui.好友列表[i].头像:setBackground(全局设置.getHeadIconUrl(tonumber(10+(v[3]-1)*2+v[2]).."3"))
				ui.好友列表[i].名字:setTitleText(txt(v[1]))
				ui.好友列表[i].职业:setTitleText(txt(全局设置.获取职业类型(v[3])))
				ui.好友列表[i].等级:setTitleText(txt(v[4].."级"))
				ui.好友列表[i].查看.rolename = v[1]
				ui.好友列表[i].私聊.rolename = v[1]
				ui.好友列表[i].组队.rolename = v[1]
				ui.好友列表[i].删除.rolename = v[1]
			else
				ui.好友列表[i]:setVisible(false)
			end
		end
		local totalpage = math.ceil(#m_friend / ITEMCOUNT)
		ui.page:setTitleText(m_curpage.." / "..totalpage)
	elseif m_tabid == 1 or m_tabid == 2 then
		ui.仇人列表:removeAllItems()
		ui.仇人列表:getVScroll():setPercent(0)
		m_poolindex = 1
		local tb = m_tabid == 1 and m_enemy or m_blacklist
		for i,v in ipairs(tb) do
			local item = nil
			if #m_pool >= m_poolindex then
				item = m_pool[m_poolindex]
				m_poolindex = m_poolindex + 1
			else
				item = tt(ui.列表项:clone(),F3DCheckBox)
				item.删除 = item:findComponent("删除")
				item.删除:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
					if e:getCurrentTarget().name then
						local rolename = e:getCurrentTarget().name
						local type = e:getCurrentTarget().type or 0
						消息框UI1.initUI()
						消息框UI1.setData(txt("是否确定删除#cffff00,"..e:getCurrentTarget().name.."#C？"),function()
							消息.CG_FRIEND_DELETE(type,rolename)
						end)
					end
				end))
				m_pool[m_poolindex] = item
				m_poolindex = m_poolindex + 1
			end
			item:findComponent("名字"):setTitleText(txt(v[1]))
			item:findComponent("职业"):setTitleText(v[3] ~= 0 and txt(全局设置.获取职业类型(v[3])) or "")
			item:findComponent("等级"):setTitleText(v[4] ~= 0 and txt(v[4].."级") or "")
			item.删除.type = m_tabid
			item.删除.name = v[1]
			ui.仇人列表:addItem(item)
		end
	end
end

function onClose(e)

	
	ui:setVisible(false)
	ui:releaseMouse()
	ui.close:releaseMouse()
	e:stopPropagation()
end

function onMouseDown(e)
	uiLayer:removeChild(ui)
	uiLayer:addChild(ui)
	e:stopPropagation()
end

function onAddFriendOK(rolename)
	if rolename == nil or rolename == "" then
		主界面UI.showTipsMsg(1,txt("请输入对方的名字"))
		return
	end
	if rolename:len() > 15 then
		主界面UI.showTipsMsg(1, txt("名字字数超过上限"))
		return
	end
	消息.CG_FRIEND_ADD(0, utf8(rolename))
end

function onAddEnemyOK(rolename)
	if rolename == nil or rolename == "" then
		主界面UI.showTipsMsg(1,txt("请输入对方的名字"))
		return
	end
	if rolename:len() > 15 then
		主界面UI.showTipsMsg(1, txt("名字字数超过上限"))
		return
	end
	消息.CG_FRIEND_ADD(1, utf8(rolename))
end

function onAddBlacklistOK(rolename)
	if rolename == nil or rolename == "" then
		主界面UI.showTipsMsg(1,txt("请输入对方的名字"))
		return
	end
	if rolename:len() > 15 then
		主界面UI.showTipsMsg(1, txt("名字字数超过上限"))
		return
	end
	消息.CG_FRIEND_ADD(2, utf8(rolename))
end

function onChange(e)
	m_好友拒绝添加 = ui.好友拒绝添加:isSelected() and 1 or 0
	消息.CG_TEAM_SETUP(队伍UI.m_队伍拒绝邀请, 队伍UI.m_队伍拒绝申请, m_好友拒绝添加)
end

function onUIInit()
	ui.close = ui:findComponent("titlebar,close")
	ui.close:addEventListener(F3DMouseEvent.CLICK, func_me(onClose))
	ui:addEventListener(F3DMouseEvent.MOUSE_DOWN, func_me(onMouseDown))
	ui.好友 = ui:findComponent("checkbox_1")
	ui.好友:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
		ui.仇人:setPositionY(ui.仇人位置)
		ui.黑名单:setPositionY(ui.仇人位置 + ui.间隔)
		ui.好友容器:setVisible(true)
		ui.仇人列表:setVisible(false)
		m_tabid = 0
		消息.CG_FRIEND_QUERY(0)
	end))
	ui.添加好友 = ui:findComponent("checkbox_1,添加好友")
	ui.添加好友:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
		消息框UI1.initUI()
		消息框UI1.setData(txt("请输入对方的名字(需要加区服标识)"),onAddFriendOK,nil,nil,true)
	end))
	ui.仇人 = ui:findComponent("checkbox_2")
	ui.仇人:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
		ui.仇人:setPositionY(ui.间隔 + ui.好友:getPositionY())
		ui.黑名单:setPositionY(ui.仇人位置 + ui.间隔)
		ui.仇人列表:setPositionY(ui.间隔*2 + ui.好友:getPositionY())
		ui.好友容器:setVisible(false)
		ui.仇人列表:setVisible(true)
		m_tabid = 1
		消息.CG_FRIEND_QUERY(1)
	end))
	ui.添加仇人 = ui:findComponent("checkbox_2,添加仇人")
	ui.添加仇人:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
		消息框UI1.initUI()
		消息框UI1.setData(txt("请输入对方的名字(需要加区服标识)"),onAddEnemyOK,nil,nil,true)
	end))
	ui.黑名单 = ui:findComponent("checkbox_3")
	ui.黑名单:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
		ui.仇人:setPositionY(ui.间隔 + ui.好友:getPositionY())
		ui.黑名单:setPositionY(ui.间隔*2 + ui.好友:getPositionY())
		ui.仇人列表:setPositionY(ui.间隔*3 + ui.好友:getPositionY())
		ui.好友容器:setVisible(false)
		ui.仇人列表:setVisible(true)
		m_tabid = 2
		消息.CG_FRIEND_QUERY(2)
	end))
	ui.加入黑名单 = ui:findComponent("checkbox_3,加入黑名单")
	ui.加入黑名单:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
		消息框UI1.initUI()
		消息框UI1.setData(txt("请输入对方的名字(需要加区服标识)"),onAddBlacklistOK,nil,nil,true)
	end))
	ui.仇人位置 = ui.仇人:getPositionY()
	ui.间隔 = ui.黑名单:getPositionY() - ui.仇人位置
	ui.好友容器 = ui:findComponent("列表容器")
	ui.好友列表 = {}
	for i=1,ITEMCOUNT do
		ui.好友列表[i] = ui:findComponent("列表容器,好友列表_"..i)
		ui.好友列表[i].头像 = ui:findComponent("列表容器,好友列表_"..i..",头像")
		ui.好友列表[i].名字 = ui:findComponent("列表容器,好友列表_"..i..",名字")
		ui.好友列表[i].职业 = ui:findComponent("列表容器,好友列表_"..i..",职业")
		ui.好友列表[i].等级 = ui:findComponent("列表容器,好友列表_"..i..",等级")
		ui.好友列表[i].查看 = ui:findComponent("列表容器,好友列表_"..i..",查看")
		ui.好友列表[i].查看:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
			local rolename = e:getCurrentTarget().rolename
			if rolename then
消息.CG_EQUIP_VIEW(-1,rolename)
			end
		end))
		ui.好友列表[i].私聊 = ui:findComponent("列表容器,好友列表_"..i..",私聊")
		ui.好友列表[i].私聊:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
			local rolename = e:getCurrentTarget().rolename
			if rolename then
				聊天UI.ui.textinput:setTitleText("/"..txt(rolename).." ")
			end
		end))
		ui.好友列表[i].组队 = ui:findComponent("列表容器,好友列表_"..i..",组队")
		ui.好友列表[i].组队:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
			local rolename = e:getCurrentTarget().rolename
			if rolename then
				消息.CG_TEAM_ADDMEMBER(rolename)
			end
		end))
		ui.好友列表[i].删除 = ui:findComponent("列表容器,好友列表_"..i..",删除")
		ui.好友列表[i].删除:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
			local rolename = e:getCurrentTarget().rolename
			if rolename then
				消息框UI1.initUI()
				消息框UI1.setData(txt("是否确定删除好友#cffff00,"..rolename.."#C？"),function()
					消息.CG_FRIEND_DELETE(0,rolename)
				end)
			end
		end))
	end
	ui.page = ui:findComponent("列表容器,按钮底,page")
	ui.pagepre = ui:findComponent("列表容器,按钮底,pagepre")
	ui.pagepre:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
		local totalpage = math.max(1, math.ceil(#m_friend / ITEMCOUNT))
		if m_curpage > 1 then
			m_curpage = math.max(1, m_curpage - 1)
			update()
		end
	end))
	ui.pagenext = ui:findComponent("列表容器,按钮底,pagenext")
	ui.pagenext:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
		local totalpage = math.max(1, math.ceil(#m_friend / ITEMCOUNT))
		if m_curpage < totalpage then
			m_curpage = math.min(totalpage, m_curpage + 1)
			update()
		end
	end))
	ui.好友拒绝添加 = tt(ui:findComponent("列表容器,按钮底,拒绝被添加"),F3DCheckBox)
	ui.好友拒绝添加:addEventListener(F3DMouseEvent.CLICK, func_me(onChange))
	ui.仇人列表 = tt(ui:findComponent("仇人列表"),F3DList)
	ui.仇人列表:setVisible(false)
	ui.列表项 = tt(ui:findComponent("好友显示底"),F3DCheckBox)
	ui.列表项:setVisible(false)
	m_init = true
	update()
	消息.CG_FRIEND_QUERY(0)
end

function isHided()
	return not ui or not ui:isVisible() or ui.tweenhide
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
	ui:setMovable(true)
	ui:addEventListener(F3DObjEvent.OBJ_INITED, func_e(onUIInit))
if ui.setUIPack and USEUIPACK then
ui:setUIPack(g_mobileMode and UIPATH.."好友UIm.pack"or UIPATH.."好友UI.pack")
else
ui:setLayout(g_mobileMode and UIPATH.."好友UIm.layout" or UIPATH.."好友UI.layout")
end
	
	
end
