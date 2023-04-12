module(..., package.seeall)

local 全局设置 = require("公用.全局设置")
local 游戏设置 = require("公用.游戏设置")
local 消息 = require("网络.消息")
local 商城表 = require("配置.商城表").Config
local 角色逻辑 = require("主界面.角色逻辑")
local 消息框UI2 = require("主界面.消息框UI2")
local 物品提示UI = require("主界面.物品提示UI")
local 装备提示UI = require("主界面.装备提示UI")
local 宠物蛋提示UI = require("主界面.宠物蛋提示UI")
local 充值礼包表 = require("配置.充值礼包表").Config

充值赠送表 = {}
VIPPRIZE = {}
for i,v in ipairs(充值礼包表) do
	if v.类型 == 5 then
		VIPPRIZE[#VIPPRIZE+1] = txt("#cffff00,VIP"..v.领取VIP..".#C 总充值#cffff00,"..v.领取充值.."元#C 经验爆率加成#cffff00,"..v.每日充值.."%#C #n   每日领取#cffff00,"..v.name.."#C#n")
	elseif v.类型 == 6 then
		充值赠送表[#充值赠送表+1] = v
	end
end

ITEMCOUNT = 游戏设置.MALLITEMCOUNT or 10
m_init = false
m_curpage = 1
m_mallinfo = nil
m_tabid = 0
m_subtabid = 0
m_selectitem = nil
m_itemdata = nil
m_timeShopItem = nil
tipsui = nil
tipsgrid = nil

function setTimeShopItem(item)
	m_timeShopItem = {}
	for i,v in ipairs(item) do
		m_timeShopItem[#m_timeShopItem+1] = {
			id = v[1],
			name = v[2],
			icon = v[3],
			grade = v[4],
			type = v[5],
			price = v[6],
			status = v[7],
		}
	end
	updateTimeShop()
end

function updateTimeShop()
	if not m_init or m_timeShopItem == nil then
		return
	end
end

function updateVipLevel(updatetxt)
	if not m_init then
		return
	end
	if updatetxt then
		local vipi = math.max(1, math.min(6, 角色逻辑.m_vip等级 - 3))
		ui.vip特权:setTitleText((VIPPRIZE[vipi] or "")..(VIPPRIZE[vipi+1] or "")..(VIPPRIZE[vipi+2] or "")..(VIPPRIZE[vipi+3] or "")..(VIPPRIZE[vipi+4] or ""))
	end
	ui.vip等级:setTitleText("VIP"..角色逻辑.m_vip等级)
	ui.总充值:setTitleText(txt("我的总充值: "..角色逻辑.m_总充值.."元"))
end

function updateMoney()
	if not m_init then
		return
	end
	ui.bindmoney:setTitleText(角色逻辑.m_bindmoney)
	ui.money:setTitleText(角色逻辑.m_money)
	ui.bindrmb:setTitleText(角色逻辑.m_bindrmb)
	ui.rmb:setTitleText(角色逻辑.m_rmb)
end

function update()
	if not m_init or not 商城表 then
		return
	end
	m_mallinfo = {}
	for i,v in ipairs(商城表) do
		if v.talkid ~= 0 or v.guildshop == 1 then
		elseif m_tabid == 0 and v.hot == 1 then
			m_mallinfo[#m_mallinfo+1] = v
		elseif m_tabid == 3 and v.商城类型 ~= 0 and v.subtype == m_subtabid then
			m_mallinfo[#m_mallinfo+1] = v
		elseif m_tabid == 1 and (v.type == 0 or v.type == 1) and v.hot == 0 and v.商城类型 == 0 and v.subtype == m_subtabid then
			m_mallinfo[#m_mallinfo+1] = v
		elseif m_tabid == 2 and (v.type == 2 or v.type == 3) and v.hot == 0 and v.商城类型 == 0 and v.subtype == m_subtabid then
			m_mallinfo[#m_mallinfo+1] = v
		end
	end
	local index = (m_curpage-1)*ITEMCOUNT
	for i=1,ITEMCOUNT do
		local v = m_mallinfo[index+i]
		if v then
			ui.items[i]:setVisible(true)
			local str = ""
			if #v.limit > 2 and v.limit[3] > 0 then
				str = str.."行会"..v.limit[3].."级"
			end
			if #v.limit > 1 and v.limit[2] > 0 then
				str = str.."VIP"..v.limit[2]
			end
			if #v.limit > 0 and v.limit[1] > 0 then
				str = str.."日限"..v.limit[1].."个"
			end
			ui.items[i].name:setTitleText(txt(v.name..(str ~= "" and "("..str..")" or "")))
			ui.items[i].name:setTextColor(全局设置.getColorRgbVal(v.grade))
			ui.items[i].icon:setTextureFile(全局设置.getItemIconUrl(v.icon))
			ui.items[i].grade:setTextureFile(全局设置.getGradeUrl(v.grade))
			ui.items[i].money:setBackground(全局设置.MONEYICON[v.type] or "")
			ui.items[i].money:setTitleText(txt(v.材料名称)..(v.price > 0 and v.price or ""))
			ui.items[i].money:setTextColor(v.price == 0 and 0xFF0000 or v.材料名称 ~= "" and 0xFF00FF or 0xFFFFFF)
		else
			ui.items[i]:setVisible(false)
		end
	end
	local totalpage = math.ceil(#m_mallinfo / ITEMCOUNT)
	ui.page_cur:setTitleText(m_curpage.." / "..totalpage)
	if m_tabid == 1 and 游戏设置.MALLTABTEXT and 游戏设置.MALLTABTEXT[1] and #游戏设置.MALLTABTEXT[1] > 0 then
		for i=1,5 do
			if 游戏设置.MALLTABTEXT[1][i] then
				ui.subtab:getTabBtn(i-1):setTitleText(txt(游戏设置.MALLTABTEXT[1][i]))
				ui.subtab:getTabBtn(i-1):setVisible(true)
			else
				ui.subtab:getTabBtn(i-1):setVisible(false)
			end
		end
	elseif m_tabid == 3 and 游戏设置.MALLTABTEXT and 游戏设置.MALLTABTEXT[2] and #游戏设置.MALLTABTEXT[2] > 0 then
		for i=1,5 do
			if 游戏设置.MALLTABTEXT[2][i] then
				ui.subtab:getTabBtn(i-1):setTitleText(txt(游戏设置.MALLTABTEXT[2][i]))
				ui.subtab:getTabBtn(i-1):setVisible(true)
			else
				ui.subtab:getTabBtn(i-1):setVisible(false)
			end
		end
	end
	ui.subtab:setVisible(m_tabid == 1 or (m_tabid == 3 and 游戏设置.MALLTABTEXT and 游戏设置.MALLTABTEXT[2] and #游戏设置.MALLTABTEXT[2] > 0))
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

function setItemData(itemdata)
	local v = itemdata[1]
	m_itemdata = {
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
	if tipsui and tipsgrid and 提示UI then

		提示UI.setItemData(m_itemdata)
		checkTipsPos()
	end
end

function onTimeGridOver(e)
	local g = e:getTarget()
	if g == nil or not m_timeShopItem or not m_timeShopItem[g.id] then
	elseif F3DUIManager.sTouchComp ~= g then
	else
		local mallinfo = m_timeShopItem[g.id]
		local 提示UI = mallinfo.物品类型 == 2 and 宠物蛋提示UI or mallinfo.物品类型 == 1 and 装备提示UI or 物品提示UI
		提示UI.initUI()
		if not m_itemdata or m_itemdata.id ~= mallinfo.id then
			消息.CG_ITEM_QUERY(mallinfo.id, 1)
			提示UI.setEmptyItemData()
		else
			提示UI.setItemData(m_itemdata)
		end
		tipsui = 提示UI.ui
		tipsgrid = g
		if not tipsui:isInited() then
			tipsui:addEventListener(F3DObjEvent.OBJ_INITED, func_oe(checkTipsPos))
		else
			checkTipsPos()
		end
	end
end

function onTimeGridOut(e)
	local g = e:getTarget()
	if g ~= nil and g == tipsgrid and tipsui then
		物品提示UI.hideUI()
		装备提示UI.hideUI()
		宠物蛋提示UI.hideUI()
		tipsui = nil
		tipsgrid = nil
	end
end

function onGridOver(e)
	if ui.tweenhide then return end
	local g = g_mobileMode and e:getCurrentTarget() or e:getTarget()
	if g == nil or not m_mallinfo or not m_mallinfo[(m_curpage-1)*ITEMCOUNT+g.id] then
	elseif F3DUIManager.sTouchComp ~= g then
	else
		local mallinfo = m_mallinfo[(m_curpage-1)*ITEMCOUNT+g.id]
		提示UI = mallinfo.物品类型 == 2 and 宠物蛋提示UI or mallinfo.物品类型 == 1 and 装备提示UI or 物品提示UI
		提示UI.initUI()
		if not m_itemdata or m_itemdata.id ~= mallinfo.itemid then
			消息.CG_ITEM_QUERY(mallinfo.itemid, 1)
			提示UI.setEmptyItemData()
		else
			提示UI.setItemData(m_itemdata)
		end
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
		宠物蛋提示UI.hideUI()
		tipsui = nil
		tipsgrid = nil
	end
end

function onTabChange(e)
	m_tabid = ui.tab:getSelectIndex()
	m_subtabid = 0
	ui.subtab:setSelectIndex(0)
	m_curpage = 1
	update()
end

function onSubTabChange(e)
	m_subtabid = ui.subtab:getSelectIndex()
	m_curpage = 1
	update()
end

function onClose(e)
	if tipsui then
		物品提示UI.hideUI()
		装备提示UI.hideUI()
		宠物蛋提示UI.hideUI()
		tipsui = nil
		tipsgrid = nil
	end
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

function onBuyItemOK(count)
	if m_selectitem then
		消息.CG_ITEM_BUY(m_selectitem.type, m_selectitem.itemid, count)
		m_selectitem = nil
	end
end

function onUIInit()
	ui.close = ui:findComponent("titlebar,close")
	ui.close:addEventListener(F3DMouseEvent.CLICK, func_me(onClose))
	ui:addEventListener(F3DMouseEvent.MOUSE_DOWN, func_me(onMouseDown))
	ui.items = {}
	for i=1,ITEMCOUNT do
		ui.items[i] = ui:findComponent("component_1,img_itembg_"..i)
		ui.items[i].name = ui:findComponent("component_1,img_itembg_"..i..",name")
		ui.items[i].grid = ui:findComponent("component_1,img_itembg_"..i..",grid")
		ui.items[i].grid.id = i
		if g_mobileMode then
			ui.items[i].grid:addEventListener(F3DMouseEvent.CLICK, func_me(onGridOver))
		else
			ui.items[i].grid:addEventListener(F3DUIEvent.MOUSE_OVER, func_ue(onGridOver))
			ui.items[i].grid:addEventListener(F3DUIEvent.MOUSE_OUT, func_ue(onGridOut))
		end
		ui.items[i].icon = F3DImage:new()
		ui.items[i].icon:setPositionX(math.floor(ui.items[i].grid:getWidth()/2))
		ui.items[i].icon:setPositionY(math.floor(ui.items[i].grid:getHeight()/2))
		ui.items[i].icon:setPivot(0.5,0.5)
		ui.items[i].grid:addChild(ui.items[i].icon)
		ui.items[i].grade = F3DImage:new()
		ui.items[i].grade:setPositionX(1)
		ui.items[i].grade:setPositionY(1)
		ui.items[i].grade:setWidth(ui.items[i].grid:getWidth()-2)
		ui.items[i].grade:setHeight(ui.items[i].grid:getHeight()-2)
		ui.items[i].grid:addChild(ui.items[i].grade)
		ui.items[i].money = ui:findComponent("component_1,img_itembg_"..i..",money")
		ui.items[i].buy = ui:findComponent("component_1,img_itembg_"..i..",buy")
		ui.items[i].buy.id = i
		ui.items[i].buy:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
			local btn = e:getCurrentTarget()
			if btn and m_mallinfo and m_mallinfo[(m_curpage-1)*ITEMCOUNT+btn.id] then
				m_selectitem = m_mallinfo[(m_curpage-1)*ITEMCOUNT+btn.id]
local maxcnt=100
				if m_selectitem.type == 0 then
					maxcnt = math.floor(角色逻辑.m_rmb / m_selectitem.price)
				elseif m_selectitem.type == 1 then
					maxcnt = math.floor(角色逻辑.m_bindrmb / m_selectitem.price)
				elseif m_selectitem.type == 2 then
					maxcnt = math.floor(角色逻辑.m_money / m_selectitem.price)
				elseif m_selectitem.type == 3 then
					maxcnt = math.floor(角色逻辑.m_bindmoney / m_selectitem.price)
				end
				消息框UI2.initUI()
				消息框UI2.setData(5,1,math.min(100,math.max(1,maxcnt)),onBuyItemOK)
			end
		end))
	end
	ui.page_cur = ui:findComponent("button_page_cur")
	ui.page_pre = ui:findComponent("button_page_pre")
	ui.page_pre:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
		if not m_mallinfo then
			return
		end
		local totalpage = math.ceil(#m_mallinfo / ITEMCOUNT)
		m_curpage = math.max(1, m_curpage - 1)
		update()
	end))
	ui.page_next = ui:findComponent("button_page_next")
	ui.page_next:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
		if not m_mallinfo then
			return
		end
		local totalpage = math.ceil(#m_mallinfo / ITEMCOUNT)
		m_curpage = math.min(totalpage, m_curpage + 1)
		update()
	end))
	ui.tab = tt(ui:findComponent("tab_1"), F3DTab)
	ui.tab:addEventListener(F3DUIEvent.CHANGE, func_me(onTabChange))
	if 游戏设置.SHOPNAME then
		ui.tab:getTabBtn(3):setTitleText(游戏设置.SHOPNAME)
	end
	ui.subtab = tt(ui:findComponent("tab_2"), F3DTab)
	ui.subtab:addEventListener(F3DUIEvent.CHANGE, func_me(onSubTabChange))
	ui.bindmoney = ui:findComponent("bindmoney")
	ui.money = ui:findComponent("money")
	ui.bindrmb = ui:findComponent("bindrmb")
	ui.rmb = ui:findComponent("rmb")
	ui.vip特权 = ui:findComponent("xianshi,vip特权")
	local vipi = math.max(1, math.min(6, 角色逻辑.m_vip等级 - 3))
	ui.vip特权:setTitleText((VIPPRIZE[vipi] or "")..(VIPPRIZE[vipi+1] or "")..(VIPPRIZE[vipi+2] or "")..(VIPPRIZE[vipi+3] or "")..(VIPPRIZE[vipi+4] or ""))
	ui.vip等级 = ui:findComponent("xianshi,vip等级")
	ui.总充值 = ui:findComponent("xianshi,总充值")
	ui.元宝比例 = ui:findComponent("xianshi,元宝比例")
	for i=1,5 do
		ui:findComponent("xianshi,component_"..(2+i)):setTitleText(txt(i..". 单笔充值"..(充值赠送表[i] and 充值赠送表[i].name or "")))
	end
	if 充值赠送表[1] then
ui.元宝比例:setTitleText(txt("请点击元宝充值按钮查看充值比例"))
	else
		ui.元宝比例:setTitleText(txt("请查找元宝充值NPC查看充值比例"))
	end
	ui.领取奖励 = ui:findComponent("xianshi,领取奖励")
	ui.领取奖励:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
		消息.CG_VIP_REWARD()
	end))
ui.元宝充值=ui:findComponent("元宝充值")or ui:findComponent("xianshi,元宝充值")
	if ui.元宝充值 then
		ui.元宝充值:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
			消息.CG_CHAT(1,"@充值")
		end))
	end
	if g_mobileMode then
		ui:findComponent("xianshi"):setVisible(false)
		ui.充值说明 = ui:findComponent("充值说明")
		ui.充值说明:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
			ui:findComponent("xianshi"):setVisible(not ui:findComponent("xianshi"):isVisible())
		end))
	end
	m_init = true
	update()
	updateMoney()
	updateVipLevel()
	updateTimeShop()
end

function isHided()
	return not ui or not ui:isVisible() or ui.tweenhide
end

function hideUI()
	if tipsui then
		物品提示UI.hideUI()
		装备提示UI.hideUI()
		宠物蛋提示UI.hideUI()
		tipsui = nil
		tipsgrid = nil
	end
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
ui:setUIPack(g_mobileMode and UIPATH.."商城UIm.pack"or UIPATH.."商城UI.pack")
else
ui:setLayout(g_mobileMode and UIPATH.."商城UIm.layout" or UIPATH.."商城UI.layout")
end
		

	
end
