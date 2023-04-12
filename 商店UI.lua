module(..., package.seeall)

local 全局设置 = require("公用.全局设置")
local 游戏设置 = require("公用.游戏设置")
local 消息 = require("网络.消息")
local 背包UI = require("主界面.背包UI")
local 商城表 = require("配置.商城表").Config
local 角色逻辑 = require("主界面.角色逻辑")
local 消息框UI2 = require("主界面.消息框UI2")
local 物品提示UI = require("主界面.物品提示UI")
local 宠物蛋提示UI = require("主界面.宠物蛋提示UI")
local 装备提示UI = require("主界面.装备提示UI")
local 装备对比提示UI = require("主界面.装备对比提示UI")
local 角色UI = require("主界面.角色UI")

m_init = false
m_curpage = 1
m_mallinfo = nil
m_selectitem = nil
m_itemdata = nil
m_talkid = 0
m_stallinfo = nil
m_recordinfo = nil
m_pool2 = {}
m_poolindex2 = 1
tipsui = nil
tipsgrid = nil
ITEMCOUNT = 5

function setTalkID(talkid)
	m_talkid = talkid
	m_curpage = 1
	update()
end

function setStallInfo(info)
	m_stallinfo = info
	m_curpage = 1
	updateStall()
end

function setRecordInfo(info)
	m_recordinfo = info
	updateRecord()
end

function updateRecord()
	if not m_init or not m_recordinfo or not ui.日志列表 then
		return
	end
	ui.日志列表:removeAllItems()
	m_poolindex2 = 1
	for i,v in ipairs(m_recordinfo) do
		local cb = nil
		if #m_pool2 >= m_poolindex2 then
			cb = m_pool2[m_poolindex2]
			m_poolindex2 = m_poolindex2 + 1
		else
			cb = F3DCheckBox:new()
			m_pool2[m_poolindex2] = cb
			m_poolindex2 = m_poolindex2 + 1
			cb.rtf = F3DRichTextField:new()
			cb:addChild(cb.rtf)
			if g_mobileMode then
				cb.rtf:setTitleFont("宋体,16")
				cb:setHeight(18*2+2)
			else
				cb:setHeight(14*2+2)
			end
		end
		local seller = v[1]==角色逻辑.m_rolename and txt("你") or txt(v[1])
		local buyer = v[2]==角色逻辑.m_rolename and txt("你") or txt(v[2])
		cb.rtf:setTitleText("#cffff00,"..buyer..txt("#C在#cffff00,")..v[4]..txt("#C购买了#cffff00,")..seller..
			txt("#C的#cffff00,")..txt(v[3])..
			(v[1]==角色逻辑.m_rolename and txt("#C,#n    获得了#cffff00,") or txt("#C,#n    失去了#cffff00,"))..
			v[6]..(v[5]==1 and txt("元宝") or txt("金币")))
		ui.日志列表:addItem(cb)
	end
end

function updateStall()
	if not m_init or not m_stallinfo then
		return
	end
	m_mallinfo = {}
	for i,v in ipairs(m_stallinfo) do
		m_mallinfo[#m_mallinfo+1] = {
			id = 0,
			name = v[5],
			itemid = v[1],
			icon = v[2],
			grade = v[3],
			物品类型 = v[11]==3 and 1 or v[11]==2 and 2 or 0,
			材料名称 = "",
			材料 = {},
type=v[9]==0 and 2 or v[9]==1 and 0 or v[9]==4 and 3 or 1,
			subtype = 0,
			price = v[10],
			hot = 0,
			商城类型 = 0,
			timeshop = 0,
			guildshop = 0,
			talkid = 0,
			limit = {},
			count = v[4],
			timeleft = v[8],
		}
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
			local timeleft = (v.timeleft and v.timeleft > 0) and "["..
				(math.floor(v.timeleft/60)>0 and math.floor(v.timeleft/60).."时" or "")..math.floor(v.timeleft%60).."分]" or
				v.timeleft and "[已过期]" or ""
			ui.items[i].buy:setTitleText((游戏设置.OPENSTALL and m_talkid == -2) and
				((v.timeleft and v.timeleft > 0) and txt("下架") or txt("取回")) or txt("购买"))
			ui.items[i].name:setTitleText(txt(v.name..(str ~= "" and "("..str..")" or "")..timeleft))
			ui.items[i].name:setTextColor(全局设置.getColorRgbVal(v.grade))
			ui.items[i].icon:setTextureFile(全局设置.getItemIconUrl(v.icon))
			ui.items[i].grade:setTextureFile(全局设置.getGradeUrl(v.grade))
			ui.items[i].money:setBackground(全局设置.MONEYICON[v.type] or "")
			ui.items[i].money:setTitleText(txt(v.材料名称)..(v.price > 0 and v.price or ""))
			ui.items[i].money:setTextColor(v.price == 0 and 0xFF0000 or v.材料名称 ~= "" and 0xFF00FF or 0xFFFFFF)
			if v.count < 0 then
				if not ui.items[i].effect then
					ui.items[i].effect = F3DImageAnim:new()
					ui.items[i].effect:setBlendType(F3DRenderContext.BLEND_ADD)
					ui.items[i].effect:setPositionX(ui.items[i].grid:getWidth()/2)
					ui.items[i].effect:setPositionY(ui.items[i].grid:getHeight()/2)
					ui.items[i].grid:addChild(ui.items[i].effect)
				end
				ui.items[i].effect:setAnimPack(全局设置.getAnimPackUrl(-v.count))
			elseif ui.items[i].effect then
				ui.items[i].effect:reset()
			end
			ui.items[i].count:setText(v.count > 1 and v.count or "")
		else
			ui.items[i]:setVisible(false)
		end
	end
	local totalpage = math.ceil(#m_mallinfo / ITEMCOUNT)
	ui.page_cur:setTitleText(m_curpage.." / "..totalpage)
	if ui.摆摊 then
		ui.摆摊:setVisible(游戏设置.OPENSTALL and m_talkid == -2)
	end
	if ui.日志 then
		ui.日志:setVisible(游戏设置.OPENSTALL and m_talkid == -2)
	end
	if ui.日志列表 then
		ui.日志列表:setVisible(false)
	end
end

function update()
	if not m_init or not 商城表 then
		return
	end
	m_mallinfo = {}
	for i,v in ipairs(商城表) do
		if m_talkid == 0 and v.talkid == m_talkid and (v.type == 2 or v.type == 3) then
			m_mallinfo[#m_mallinfo+1] = v
		elseif m_talkid == -1 and v.talkid == 0 and v.guildshop == 1 then
			m_mallinfo[#m_mallinfo+1] = v
		elseif m_talkid ~= 0 and v.talkid == m_talkid then
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
			ui.items[i].buy:setTitleText(txt("购买"))
			ui.items[i].name:setTitleText(txt(v.name..(str ~= "" and "("..str..")" or "")))
			ui.items[i].name:setTextColor(全局设置.getColorRgbVal(v.grade))
			ui.items[i].icon:setTextureFile(全局设置.getItemIconUrl(v.icon))
			ui.items[i].grade:setTextureFile(全局设置.getGradeUrl(v.grade))
			ui.items[i].money:setBackground(全局设置.MONEYICON[v.type] or "")
			ui.items[i].money:setTitleText(txt(v.材料名称)..(v.price > 0 and v.price or ""))
			ui.items[i].money:setTextColor(v.price == 0 and 0xFF0000 or v.材料名称 ~= "" and 0xFF00FF or 0xFFFFFF)
			ui.items[i].count:setText("")
		else
			ui.items[i]:setVisible(false)
		end
	end
	local totalpage = math.ceil(#m_mallinfo / ITEMCOUNT)
	ui.page_cur:setTitleText(m_curpage.." / "..totalpage)
	if ui.摆摊 then
		ui.摆摊:setVisible(false)
	end
	if ui.日志 then
		ui.日志:setVisible(false)
	end
	if ui.日志列表 then
		ui.日志列表:setVisible(false)
	end
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










		if not 装备对比提示UI.isHided() and x + tipsui:getWidth() + 装备对比提示UI.ui:getWidth() > stage:getWidth() then
			tipsui:setPositionX(x - tipsui:getWidth() - tipsgrid:getWidth())
			if not 装备对比提示UI.isHided() then
				装备对比提示UI.ui:setPositionX(x - tipsui:getWidth() - tipsgrid:getWidth()-tipsui:getWidth())
			end
		elseif 装备对比提示UI.isHided() and x + tipsui:getWidth() > stage:getWidth() then
			tipsui:setPositionX(x - tipsui:getWidth() - tipsgrid:getWidth())
			if not 装备对比提示UI.isHided() then
				装备对比提示UI.ui:setPositionX(x - tipsui:getWidth() - tipsgrid:getWidth()-tipsui:getWidth())
			end
		else
			tipsui:setPositionX(x)
			if not 装备对比提示UI.isHided() then
				装备对比提示UI.ui:setPositionX(x+tipsui:getWidth())
			end
		end
		if y + tipsui:getHeight() > stage:getHeight() then
			tipsui:setPositionY(stage:getHeight() - tipsui:getHeight())
			if not 装备对比提示UI.isHided() then
				装备对比提示UI.ui:setPositionY(stage:getHeight() - tipsui:getHeight())
			end
		else
			tipsui:setPositionY(y)
			if not 装备对比提示UI.isHided() then
				装备对比提示UI.ui:setPositionY(y)
			end
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
	if tipsui and tipsgrid then


		if m_itemdata.type == 3 and m_itemdata.equippos == 14 then
			宠物蛋提示UI.setItemData(m_itemdata, false)

		elseif m_itemdata.type == 3 then
			local equippos = 背包UI.GetEquipPos(m_itemdata, 角色UI.m_tabid == 1)
			local itemdata = 角色UI.m_tabid == 1 and 角色UI.英雄物品数据 or 角色UI.m_itemdata
			if itemdata and itemdata[equippos] and
				itemdata[equippos].id ~= 0 and
				itemdata[equippos].count > 0 then
				装备对比提示UI.initUI()
				装备对比提示UI.setItemData(itemdata[equippos], true)
			else
				装备对比提示UI.hideUI()
			end
			装备提示UI.setItemData(m_itemdata, false)
			checkTipsPos()
		else
			物品提示UI.setItemData(m_itemdata)
		end
	end
end

function onGridOver(e)
	if ui.tweenhide then return end
	local g = g_mobileMode and e:getCurrentTarget() or e:getTarget()
	if g == nil or not m_mallinfo or not m_mallinfo[(m_curpage-1)*ITEMCOUNT+g.id] then
	elseif F3DUIManager.sTouchComp ~= g then
	else
		local mallinfo = m_mallinfo[(m_curpage-1)*ITEMCOUNT+g.id]
		local 提示UI
		if mallinfo.物品类型 == 0 then
			装备提示UI.hideUI()
			装备对比提示UI.hideUI()
			宠物蛋提示UI.hideUI()
			物品提示UI.initUI()
			提示UI = 物品提示UI
			if 游戏设置.OPENSTALL and (m_talkid == -2 or m_talkid == -3) then
				消息.CG_SELL_ITEM_QUERY(mallinfo.itemid)
				提示UI.setEmptyItemData()
			elseif not m_itemdata or m_itemdata.id ~= mallinfo.itemid then
				消息.CG_ITEM_QUERY(mallinfo.itemid, 2)
				提示UI.setEmptyItemData()
			else
				提示UI.setItemData(m_itemdata)
			end
		elseif mallinfo.物品类型 == 2 then
			装备提示UI.hideUI()
			装备对比提示UI.hideUI()
			物品提示UI.hideUI()
			宠物蛋提示UI.initUI()
			提示UI = 宠物蛋提示UI
			if 游戏设置.OPENSTALL and (m_talkid == -2 or m_talkid == -3) then
				消息.CG_SELL_ITEM_QUERY(mallinfo.itemid)
				提示UI.setEmptyItemData()
			elseif not m_itemdata or m_itemdata.id ~= mallinfo.itemid then
				消息.CG_ITEM_QUERY(mallinfo.itemid, 2)
				提示UI.setEmptyItemData()
			else
				提示UI.setItemData(m_itemdata)
			end
		elseif mallinfo.物品类型 == 1 then
			物品提示UI.hideUI()
			宠物蛋提示UI.hideUI()
			装备提示UI.initUI()
			提示UI = 装备提示UI
			if 游戏设置.OPENSTALL and (m_talkid == -2 or m_talkid == -3) then
				消息.CG_SELL_ITEM_QUERY(mallinfo.itemid)
				提示UI.setEmptyItemData()
				装备对比提示UI.hideUI()
			elseif not m_itemdata or m_itemdata.id ~= mallinfo.itemid then
				消息.CG_ITEM_QUERY(mallinfo.itemid, 2)
				提示UI.setEmptyItemData()
				装备对比提示UI.hideUI()
			else
				local equippos = 背包UI.GetEquipPos(m_itemdata, 角色UI.m_tabid == 1)
				local itemdata = 角色UI.m_tabid == 1 and 角色UI.英雄物品数据 or 角色UI.m_itemdata
				if itemdata and itemdata[equippos] and
					itemdata[equippos].id ~= 0 and
					itemdata[equippos].count > 0 then
					装备对比提示UI.initUI()
					装备对比提示UI.setItemData(itemdata[equippos], true)
				else
					装备对比提示UI.hideUI()
				end
				提示UI.setItemData(m_itemdata)
			end
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
		装备对比提示UI.hideUI()
		宠物蛋提示UI.hideUI()
		tipsui = nil
		tipsgrid = nil
	end
end

function onClose(e)
	if tipsui then
		物品提示UI.hideUI()
		装备提示UI.hideUI()
		装备对比提示UI.hideUI()
		宠物蛋提示UI.hideUI()
		tipsui = nil
		tipsgrid = nil
	end
_v_62(ui,false)
	ui:releaseMouse()
	ui.close:releaseMouse()
	背包UI.checkResize()
	e:stopPropagation()
end

function onMouseDown(e)
	if 背包UI.ui and 背包UI.ui:isVisible() then
		uiLayer:removeChild(背包UI.ui)
		uiLayer:addChild(背包UI.ui)
	end
	uiLayer:removeChild(ui)
	uiLayer:addChild(ui)
	e:stopPropagation()
end

function onBuyItemOK(count)
	if m_selectitem then
		消息.CG_ITEM_BUY(m_talkid > 0 and m_talkid or m_selectitem.type, m_selectitem.itemid, count)
		m_selectitem = nil
	end
end

function onUIInit()
	ui.close = ui:findComponent("titlebar,close")
	ui.close:addEventListener(F3DMouseEvent.CLICK, func_me(onClose))
	ui:addEventListener(F3DMouseEvent.MOUSE_DOWN, func_me(onMouseDown))
	ui.items = {}
	for i=1,ITEMCOUNT do
		ui.items[i] = ui:findComponent("img_shopitembg_"..i)
		ui.items[i]:setVisible(false)
		ui.items[i].name = ui:findComponent("img_shopitembg_"..i..",name")
		ui.items[i].grid = ui:findComponent("img_shopitembg_"..i..",grid")
		ui.items[i].grid.id = i
		ui.items[i].effect=nil
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
		ui.items[i].count = F3DTextField:new()
		if g_mobileMode then
			ui.items[i].count:setTextFont("宋体",16,false,false,false)
		end
		ui.items[i].count:setPositionX(ui.items[i].grid:getWidth()-(g_mobileMode and 8 or 2))
		ui.items[i].count:setPositionY(ui.items[i].grid:getHeight()-(g_mobileMode and 8 or 2))
		ui.items[i].count:setPivot(1,1)
		ui.items[i].grid:addChild(ui.items[i].count)
		ui.items[i].money = ui:findComponent("img_shopitembg_"..i..",money")
		ui.items[i].buy = ui:findComponent("img_shopitembg_"..i..",buy")
		ui.items[i].buy.id = i
		ui.items[i].buy:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
			local btn = e:getCurrentTarget()
			if btn and m_mallinfo and m_mallinfo[(m_curpage-1)*ITEMCOUNT+btn.id] then
				if 游戏设置.OPENSTALL and m_talkid == -2 then
					消息.CG_SELL_ITEM_OFF(m_mallinfo[(m_curpage-1)*ITEMCOUNT+btn.id].itemid)
				elseif 游戏设置.OPENSTALL and m_talkid == -3 then
					消息.CG_SELL_ITEM_BUY(m_mallinfo[(m_curpage-1)*ITEMCOUNT+btn.id].itemid)
				else
					m_selectitem = m_mallinfo[(m_curpage-1)*ITEMCOUNT+btn.id]
					local maxcnt = 1
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
			end
		end))
	end
	ui.page_cur = ui:findComponent("btncont,page")
	ui.page_pre = ui:findComponent("btncont,pagepre")
	ui.page_pre:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
		if not m_mallinfo then
			return
		end
		local totalpage = math.ceil(#m_mallinfo / ITEMCOUNT)
		m_curpage = math.max(1, m_curpage - 1)
		if 游戏设置.OPENSTALL and (m_talkid == -2 or m_talkid == -3) then
			updateStall()
		else
			update()
		end
	end))
	ui.page_next = ui:findComponent("btncont,pagenext")
	ui.page_next:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
		if not m_mallinfo then
			return
		end
		local totalpage = math.ceil(#m_mallinfo / ITEMCOUNT)
		m_curpage = math.min(totalpage, m_curpage + 1)
		if 游戏设置.OPENSTALL and (m_talkid == -2 or m_talkid == -3) then
			updateStall()
		else
			update()
		end
	end))
	if g_mobileMode then
		ui.returncont = ui:findComponent("returncont")
		ui.returnui = ui:findComponent("returncont,return")
if ui.returnui then
		ui.returnui:addEventListener(F3DMouseEvent.CLICK, func_me(背包UI.onOtherReturn))
end
if ui.returncont then
		ui.returncont:setVisible(false)
end
	end
	ui.摆摊 = ui:findComponent("btncont,摆摊")
	ui.日志 = ui:findComponent("btncont,日志")
	ui.日志列表 = tt(ui:findComponent("日志列表"),F3DList)
	if ui.日志列表 then
		ui.日志列表:getVScroll():setPercent(0)
		ui.日志列表:setVisible(false)
	end
	if ui.摆摊 then
		ui.摆摊:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
			if not 游戏设置.OPENSTALL then
				return
			end
			消息.CG_SELL_ITEM(0, 3, g_role.objid)
		end))
	end
	if ui.日志 then
		ui.日志:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
			if not 游戏设置.OPENSTALL or not ui.日志列表 then
				return
			end
			if ui.日志列表:isVisible() then
				ui.日志列表:setVisible(false)
				local index = (m_curpage-1)*ITEMCOUNT
				for i=1,ITEMCOUNT do
					if m_stallinfo and m_stallinfo[index+i] then
						ui.items[i]:setVisible(true)
					else
						ui.items[i]:setVisible(false)
					end
				end
			else
				ui.日志列表:setVisible(true)
				for i=1,ITEMCOUNT do
					ui.items[i]:setVisible(false)
				end
				消息.CG_SELL_RECORD_QUERY()
			end
		end))
	end
	m_init = true
	if 游戏设置.OPENSTALL and (m_talkid == -2 or m_talkid == -3) then
		updateStall()
	else
		update()
	end
	背包UI.checkResize()
end

function isHided()
	return not ui or not ui:isVisible() or ui.tweenhide
end

function hideUI()
	if tipsui then
		物品提示UI.hideUI()
		装备提示UI.hideUI()
		装备对比提示UI.hideUI()
		宠物蛋提示UI.hideUI()
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
_v_62(ui,true)
		return
	end
	ui = F3DLayout:new()
	uiLayer:addChild(ui)
	ui:setLoadPriority(getUIPriority())
	ui:addEventListener(F3DObjEvent.OBJ_INITED, func_e(onUIInit))
ITEMCOUNT=(g_mobileMode and not 游戏设置.NEWBAGPANEL)and 6 or 5
if ui.setUIPack and USEUIPACK then
ui:setUIPack(g_mobileMode and UIPATH.."商店UIm.pack"or UIPATH.."商店UI.pack")
else
	ui:setLayout(g_mobileMode and UIPATH.."商店UIm.layout" or UIPATH.."商店UI.layout")
end
_v_62(ui,true)
end
