module(..., package.seeall)

local 全局设置 = require("公用.全局设置")
local 消息 = require("网络.消息")
local 角色逻辑 = require("主界面.角色逻辑")
local 物品提示UI = require("主界面.物品提示UI")
local 装备提示UI = require("主界面.装备提示UI")

m_init = false
m_iteminfo = nil
m_info = nil
m_curpage = 1
m_curselindex = 0
m_curselid = 0
ITEMCOUNT = 7
GRIDCOUNT = 10

function setInfo(type,info)
	if type == 0 then
		m_info = info
	elseif m_info and #info > 0 then
		local isfind = false
		for i,v in ipairs(m_info) do
			if v[1] == info[1][1] then
				if info[1][2] == "" and info[1][3] == "" then
					table.remove(m_info, i)
				else
					m_info[i] = info[1]
				end
				isfind = true
				break
			end
		end
		if not isfind then
			m_info[#m_info+1] = info[1]
		end
	end
	update()
end

function update()
	if not m_init then return end
	local index = (m_curpage-1)*ITEMCOUNT
	if m_info and index >= #m_info and m_curpage > 1 then
		m_curpage = m_curpage - 1
		index = (m_curpage-1)*ITEMCOUNT
	end
	for i=1,ITEMCOUNT do
		if m_info and m_info[index+i] then
			ui.mailinfo[i].id = m_info[index+i][1]
			ui.mailinfo[i].del.id = m_info[index+i][1]
ui.mailinfo[i].icon:setBackground(#m_info[index+i][6]>0 and UIPATH.."邮件/邮箱附件.png"or UIPATH.."邮件/邮件icon.png")
			ui.mailinfo[i].icon:setVisible(true)
			ui.mailinfo[i].icon:setDisable(m_info[index+i][7] == 2)
			ui.mailinfo[i].tips:setVisible(m_info[index+i][7] == 0)
			ui.mailinfo[i].del:setVisible(true)
			ui.mailinfo[i].sender:setTitleText(txt(m_info[index+i][3]))
			ui.mailinfo[i].name:setTitleText(txt(m_info[index+i][2]))
			ui.mailinfo[i].time:setTitleText(txt(m_info[index+i][4]))
		else
			ui.mailinfo[i].id = 0
			ui.mailinfo[i].del.id = 0
			ui.mailinfo[i].icon:setVisible(false)
			ui.mailinfo[i].tips:setVisible(false)
			ui.mailinfo[i].del:setVisible(false)
			ui.mailinfo[i].sender:setTitleText("")
			ui.mailinfo[i].name:setTitleText("")
			ui.mailinfo[i].time:setTitleText("")
		end
	end
	if m_info and m_info[index+1] and (m_curselindex < index+1 or m_curselindex > index+ITEMCOUNT or m_curselindex > #m_info) then
		setContent(index+1)
		ui.mailcursel:setPositionY(ui.mailinfo[1]:getPositionY())
	else
		setContent(m_curselindex)
	end
	if m_info then
		local totalpage = math.ceil(#m_info / ITEMCOUNT)
		ui.page_cur:setTitleText(m_curpage.." / "..totalpage)
	end
end

function setContent(id)
	if m_info and m_info[id] then
		if 0 ~= m_info[id][1] then
			ui.mailname:setTitleText(txt(m_info[id][2]))
			ui.mailsender:setTitleText(txt(m_info[id][3]))
			ui.mailtime:setTitleText(txt(m_info[id][4]))
			ui.mailcontent:setTitleText(txt(m_info[id][5]))
			ui.maildraw:setVisible(true)
			ui.maildraw:setTitleText(#m_info[id][6] > 0 and txt("提取附件") or txt("标记已读"))
			ui.maildraw:setDisable(m_info[id][7] == 2)
			if m_info[id][7] == 0 then
				消息.CG_MAIL_READ(m_info[id][1])
			end
			m_iteminfo = {}
			for i,v in ipairs(m_info[id][6]) do
				m_iteminfo[i] = {
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
			for i=1,GRIDCOUNT do
				if m_iteminfo[i] then
					ui.mailgrids[i].grid:setVisible(true)
					ui.mailgrids[i].icon:setTextureFile(全局设置.getItemIconUrl(m_iteminfo[i].icon))
					ui.mailgrids[i].grade:setTextureFile(全局设置.getGradeUrl(m_iteminfo[i].grade))
					ui.mailgrids[i].count:setText(m_iteminfo[i].count>1 and m_iteminfo[i].count or "")
				else
					ui.mailgrids[i].grid:setVisible(false)
				end
			end
			m_curselid = m_info[id][1]
		else
			ui.maildraw:setDisable(m_info[id][7] == 2)
		end
ui.mailcursel:setVisible(true)
	else
		ui.mailname:setTitleText("")
		ui.mailsender:setTitleText("")
		ui.mailtime:setTitleText("")
		ui.mailcontent:setTitleText("")
		ui.maildraw:setVisible(false)
ui.mailcursel:setVisible(false)
		m_curselid = 0
	end
	m_curselindex = id
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

function checkTipsPos()
	if not ui or not tipsgrid then
		return
	end
	if not tipsui or not tipsui:isVisible() or not tipsui:isInited() then
	else
		local x = ui:getPositionX()+tipsgrid:getPositionX()+tipsgrid:getWidth()
		local y = ui:getPositionY()+tipsgrid:getPositionY()
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

function onGridOver(e)
	if ui.tweenhide then return end
	local g = g_mobileMode and e:getCurrentTarget() or e:getTarget()
	if g == nil or g.id == nil or not m_iteminfo or not m_iteminfo[g.id] then
	elseif F3DUIManager.sTouchComp ~= g then
	else
		local iteminfo = m_iteminfo[g.id]
		local 提示UI = iteminfo.type == 3 and 装备提示UI or 物品提示UI
		提示UI.initUI()
		提示UI.setItemData(iteminfo)
		tipsui = 提示UI.ui
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
		物品提示UI.hideUI()
		装备提示UI.hideUI()
		tipsui = nil
		tipsgrid = nil
	end
end

function onUIInit()
	ui.close = ui:findComponent("titlebar,close")
	ui.close:addEventListener(F3DMouseEvent.CLICK, func_me(onClose))
	ui:addEventListener(F3DMouseEvent.MOUSE_DOWN, func_me(onMouseDown))
	ui.mailinfo = {}
	for i=1,ITEMCOUNT do
		ui.mailinfo[i] = ui:findComponent("花底,当前邮件信息底_"..i)
		ui.mailinfo[i].i = i
		ui.mailinfo[i].icon = ui:findComponent("花底,当前邮件信息底_"..i..",邮件icon")
		ui.mailinfo[i].tips = ui:findComponent("花底,当前邮件信息底_"..i..",新邮件提示")
		ui.mailinfo[i].del = ui:findComponent("花底,当前邮件信息底_"..i..",当前邮件删除按钮")
		ui.mailinfo[i].sender = ui:findComponent("花底,当前邮件信息底_"..i..",component_1")
		ui.mailinfo[i].name = ui:findComponent("花底,当前邮件信息底_"..i..",component_2")
		ui.mailinfo[i].time = ui:findComponent("花底,当前邮件信息底_"..i..",component_3")
		ui.mailinfo[i].sender:setTouchable(false)
		ui.mailinfo[i].name:setTouchable(false)
		ui.mailinfo[i].time:setTouchable(false)
		ui.mailinfo[i]:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
			local g = e:getCurrentTarget()
			if g and g.id and g.id ~= 0 then
				local index = (m_curpage-1)*ITEMCOUNT
				setContent(index+g.i)
				ui.mailcursel:setPositionY(g:getPositionY())
			end
		end))
		ui.mailinfo[i].del:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
			local g = e:getCurrentTarget()
			if g and g.id and g.id ~= 0 then
				消息.CG_MAIL_DELETE(g.id)
			end
		end))
	end
	ui.mailcursel = ui:findComponent("花底,当前选中状态")
	ui.mailcursel:setTouchable(false)
	ui.mailname = ui:findComponent("邮件附件框,component_2")
	ui.mailsender = ui:findComponent("邮件附件框,component_4")
	ui.mailtime = ui:findComponent("邮件附件框,component_5")
	ui.mailcontent = ui:findComponent("邮件附件框,richtextfield_1")
	ui.mailgrids = {}
	for i=1,GRIDCOUNT do
		ui.mailgrids[i] = {}
		ui.mailgrids[i].grid = ui:findComponent("邮件附件框,物品框_"..i)
		ui.mailgrids[i].grid.id = i
		if g_mobileMode then
			ui.mailgrids[i].grid:addEventListener(F3DMouseEvent.CLICK, func_me(onGridOver))
		else
			ui.mailgrids[i].grid:addEventListener(F3DUIEvent.MOUSE_OVER, func_ue(onGridOver))
			ui.mailgrids[i].grid:addEventListener(F3DUIEvent.MOUSE_OUT, func_ue(onGridOut))
		end
		ui.mailgrids[i].icon = F3DImage:new()
		ui.mailgrids[i].icon:setPositionX(math.floor(ui.mailgrids[i].grid:getWidth()/2))
		ui.mailgrids[i].icon:setPositionY(math.floor(ui.mailgrids[i].grid:getHeight()/2))
		ui.mailgrids[i].icon:setPivot(0.5,0.5)
		ui.mailgrids[i].grid:addChild(ui.mailgrids[i].icon)
		ui.mailgrids[i].grade = F3DImage:new()
		ui.mailgrids[i].grade:setPositionX(1)
		ui.mailgrids[i].grade:setPositionY(1)
		ui.mailgrids[i].grade:setWidth(ui.mailgrids[i].grid:getWidth()-2)--36)
		ui.mailgrids[i].grade:setHeight(ui.mailgrids[i].grid:getHeight()-2)--36)
		ui.mailgrids[i].grid:addChild(ui.mailgrids[i].grade)
		ui.mailgrids[i].count = F3DTextField:new()
		ui.mailgrids[i].count:setPositionX(42)
		ui.mailgrids[i].count:setPositionY(42)
		ui.mailgrids[i].count:setPivot(1,1)
		ui.mailgrids[i].grid:addChild(ui.mailgrids[i].count)
	end
	ui.maildraw = ui:findComponent("提取附件")
	ui.maildraw:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
		if m_curselid and m_curselid ~= 0 then
			消息.CG_MAIL_DRAW(m_curselid)
		end
	end))
	ui.page_cur = ui:findComponent("page")
	ui.page_pre = ui:findComponent("pagepre")
	ui.page_pre:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
		if not m_info then
			return
		end
		local totalpage = math.ceil(#m_info / ITEMCOUNT)
		m_curpage = math.max(1, m_curpage - 1)
		update()
	end))
	ui.page_next = ui:findComponent("pagenext")
	ui.page_next:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
		if not m_info then
			return
		end
		local totalpage = math.ceil(#m_info / ITEMCOUNT)
		m_curpage = math.min(totalpage, m_curpage + 1)
		update()
	end))
	m_init = true
	消息.CG_MAIL_QUERY()
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
		ui:setUIPack(g_mobileMode and UIPATH.."邮件UIm.pack" or UIPATH.."邮件UI.pack")
	else
		ui:setLayout(g_mobileMode and UIPATH.."邮件UIm.layout" or UIPATH.."邮件UI.layout")
	end
	ui:setVisible(true)
end
