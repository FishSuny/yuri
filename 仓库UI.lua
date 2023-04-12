module(..., package.seeall)

local 全局设置 = require("公用.全局设置")
local 游戏设置=require("公用.游戏设置")
local 消息 = require("网络.消息")
local 背包UI = require("主界面.背包UI")
local 物品提示UI = require("主界面.物品提示UI")
local 装备提示UI = require("主界面.装备提示UI")

m_init = false
m_itemdata = nil
m_selectitem = nil
m_tabid = 0
tipsui = nil
tipsgrid = nil
BAG_CAP=游戏设置.CAPTWOPAGE and 游戏设置.包裹大 or 游戏设置.包裹小
ITEMCOUNT=游戏设置.包裹小
m_curpage=1
m_vip=0

function setItemData(op, itemdata)
BAG_CAP=(m_vip==0 and 游戏设置.CAPTWOPAGE)and 游戏设置.包裹大 or 游戏设置.包裹小
	if not m_itemdata then
		m_itemdata={}
	elseif op==0 then
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
		}
	end
	update()
end

function update()
	if not m_init or m_itemdata == nil then
		return
	end
	local tb = m_itemdata
	if m_tabid ~= 0 then
		tb = {}
		for k,v in pairs(m_itemdata) do
			if v.type == m_tabid then
				tb[#tb+1] = v
			end
		end
	end
	for i=1,ITEMCOUNT do
		local v = tb[(m_curpage-1)*ITEMCOUNT+i]
		if v then
local 发光特效=0
for ii,vv in ipairs(v.prop)do
if vv[1]==46 then
发光特效=vv[2]
end
end
for ii,vv in ipairs(v.addprop)do
if vv[1]==46 then
发光特效=vv[2]
end
end
if 发光特效~=0 then
if not ui.gridimgs[i].effect then
ui.gridimgs[i].effect=F3DImageAnim:new()
ui.gridimgs[i].effect:setBlendType(F3DRenderContext.BLEND_ADD)
ui.gridimgs[i].effect:setPositionX(ui.gridimgs[i]:getWidth()/2)
ui.gridimgs[i].effect:setPositionY(ui.gridimgs[i]:getHeight()/2)
ui.gridimgs[i]:addChild(ui.gridimgs[i].effect)
end
ui.gridimgs[i].effect:setAnimPack(全局设置.getAnimPackUrl(发光特效))
elseif ui.gridimgs[i].effect then
ui.gridimgs[i].effect:reset()
end
			ui.grids[i].id = v.pos
			ui.gridimgs[i].pic:setTextureFile(全局设置.getItemIconUrl(v.icon))
			ui.gridgrades[i]:setTextureFile(全局设置.getGradeUrl(v.grade))
ui.gridlocks[i]:setTextureFile(v.bind==1 and(g_mobileMode and UIPATH.."公用/grid/img_bind.png"or UIPATH.."公用/grid/img_bind.png")or"")
			ui.gridcounts[i]:setText(v.count > 1 and v.count or "")
			ui.gridstrengthens[i]:setText(v.strengthen > 0 and "+"..v.strengthen or "")
			if ui.grids[i] ~= movegrid then
				ui.gridcont:addChild(ui.gridimgs[i])
				ui.gridimgs[i]:setPositionX(ui.grids[i]:getPositionX() + 2)
				ui.gridimgs[i]:setPositionY(ui.grids[i]:getPositionY() + 2)
			end
			if v.cd > rtime() and v.cdmax > 0 then
				local frameid = math.floor((1 - (v.cd - rtime()) / v.cdmax) * 32)
				ui.gridcdimgs[i]:setVisible(true)
				ui.gridcdimgs[i]:setFrameRate(1000*(32-frameid)/(v.cd - rtime()), frameid)
			else
				ui.gridcdimgs[i]:setFrameRate(0)
				ui.gridcdimgs[i]:setVisible(false)
			end
		else
if ui.gridimgs[i].effect then
ui.gridimgs[i].effect:reset()
end
			ui.grids[i].id = 0
			ui.gridimgs[i].pic:setTextureFile("")
			ui.gridgrades[i]:setTextureFile("")
			ui.gridlocks[i]:setTextureFile("")
			ui.gridcounts[i]:setText("")
			ui.gridstrengthens[i]:setText("")
			ui.gridcdimgs[i]:setFrameRate(0)
			ui.gridcdimgs[i]:setVisible(false)
		end
	end
	local totalpage = math.ceil(BAG_CAP / ITEMCOUNT)
	ui.page:setTitleText(m_curpage.." / "..totalpage)
end

function onPagePre(e)
	local totalpage = math.ceil(BAG_CAP / ITEMCOUNT)
	m_curpage = math.max(1, m_curpage - 1)
	update()
	e:stopPropagation()
end

function onPageNext(e)
	local totalpage = math.ceil(BAG_CAP / ITEMCOUNT)
	m_curpage = math.min(totalpage, m_curpage + 1)
	update()
	e:stopPropagation()
end

function onRebuild(e)
	消息.CG_STORE_REBUILD(m_vip)
	e:stopPropagation()
end

function onFetchAll(e)
	消息.CG_STORE_FETCHALL(m_vip)
	e:stopPropagation()
end

function onGridDBClick(e)
	local g = e:getCurrentTarget()
	local p = e:getLocalPos()
	if g == nil or m_itemdata[g.id] == nil or m_itemdata[g.id].id == 0 then
		m_selectitem = nil
	else
		消息.CG_STORE_FETCH(g.id, m_vip)
		背包UI.hideAllTipsUI()
	end
end

function onTabChange(e)
	m_tabid = ui.tab:getSelectIndex()
	m_selectitem = nil
	update()
end

function checkGridContPos(px, py)
	if not m_init then return end
	local x = px - ui:getPositionX()
	local y = py - ui:getPositionY()
	local gridcont = ui:findComponent("gridcont")
	if x >= gridcont:getPositionX() and x <= gridcont:getPositionX() + gridcont:getWidth() and
		y >= gridcont:getPositionY() and y <= gridcont:getPositionY() + gridcont:getHeight() then
		return true
	end
end

function onCDPlayOut(e)
	e:getTarget():setFrameRate(0)
	e:getTarget():setVisible(false)
end

function checkTipsPos()
	if not ui or not tipsgrid then
		return
	end
	if not tipsui or not tipsui:isVisible() or not tipsui:isInited() then
	else
		local x = ui:getPositionX()+ui.gridcont:getPositionX()+tipsgrid:getPositionX()+tipsgrid:getWidth()
		local y = ui:getPositionY()+ui.gridcont:getPositionY()+tipsgrid:getPositionY()
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
if m_itemdata==nil then return end
	local g = g_mobileMode and e:getCurrentTarget() or e:getTarget()
	if g == nil or m_itemdata[g.id] == nil or m_itemdata[g.id].id == 0 then
	elseif F3DUIManager.sTouchComp ~= g then
	elseif m_itemdata[g.id].type == 3 then
		物品提示UI.hideUI()
		装备提示UI.initUI()
		装备提示UI.setItemData(m_itemdata[g.id], false)
		tipsui = 装备提示UI.ui
		tipsgrid = g
		if not tipsui:isInited() then
			tipsui:addEventListener(F3DObjEvent.OBJ_INITED, func_oe(checkTipsPos))
		else
			checkTipsPos()
		end
	else
		装备提示UI.hideUI()
		物品提示UI.initUI()
		物品提示UI.setItemData(m_itemdata[g.id])
		tipsui = 物品提示UI.ui
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

function onClose(e)
	if tipsui then
		物品提示UI.hideUI()
		装备提示UI.hideUI()
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

function onUIInit()
	ui.close = ui:findComponent("titlebar,close")
	ui.close:addEventListener(F3DMouseEvent.CLICK, func_me(onClose))
	ui:addEventListener(F3DMouseEvent.MOUSE_DOWN, func_me(onMouseDown))
	ui.griddownpos = nil
	ui.gridimgs = {}
	ui.gridgrades = {}
	ui.gridlocks = {}
	ui.gridcounts = {}
	ui.gridstrengthens = {}
	ui.gridcdimgs = {}
	ui.grids = {}
	ui.gridcont = ui:findComponent("gridcont")
	for i=1,ITEMCOUNT do
		local grid = ui:findComponent("gridcont,grid_"..(i-1))
		grid.id = 0
		grid:addEventListener(F3DMouseEvent.DOUBLE_CLICK, func_me(onGridDBClick))
		grid:addEventListener(F3DMouseEvent.RIGHT_CLICK, func_me(onGridDBClick))
		if g_mobileMode then
			grid:addEventListener(F3DMouseEvent.CLICK, func_me(onGridOver))
		else
			grid:addEventListener(F3DUIEvent.MOUSE_OVER, func_ue(onGridOver))
			grid:addEventListener(F3DUIEvent.MOUSE_OUT, func_ue(onGridOut))
		end
		ui.grids[i] = grid
		local img = F3DImage:new()
		img:setPositionX(grid:getPositionX() + 2)
		img:setPositionY(grid:getPositionY() + 2)
		img:setWidth(grid:getWidth()-4)--34)
		img:setHeight(grid:getHeight()-4)--34)
img.effect=nil
		ui.gridcont:addChild(img)
		ui.gridimgs[i] = img
		img.pic = F3DImage:new()
		img.pic:setPositionX(math.floor(img:getWidth()/2))
		img.pic:setPositionY(math.floor(img:getHeight()/2))
		img.pic:setPivot(0.5,0.5)
		img:addChild(img.pic)
		local grade = F3DImage:new()
		grade:setPositionX(-1)
		grade:setPositionY(-1)
		grade:setWidth(img:getWidth()+2)--36)
		grade:setHeight(img:getHeight()+2)--36)
		img:addChild(grade)
		ui.gridgrades[i] = grade
		local lock = F3DImage:new()
		lock:setPositionX(g_mobileMode and 6 or 2)--2)
		lock:setPositionY(img:getHeight()-(g_mobileMode and 8 or 2))--23)
		lock:setPivot(0,1)
		img:addChild(lock)
		ui.gridlocks[i] = lock
		local count = F3DTextField:new()
		if g_mobileMode then
			count:setTextFont("宋体",16,false,false,false)
		end
		count:setPositionX(img:getWidth()-(g_mobileMode and 8 or 2))--36)
		count:setPositionY(img:getHeight()-(g_mobileMode and 8 or 2))--36)
		count:setPivot(1,1)
		img:addChild(count)
		ui.gridcounts[i] = count
		local strengthen = F3DTextField:new()
		if g_mobileMode then
			strengthen:setTextFont("宋体",16,false,false,false)
		end
		strengthen:setPositionX(img:getWidth()-(g_mobileMode and 8 or 2))--34)
		strengthen:setPositionY(g_mobileMode and 8 or 2)--2)
		strengthen:setPivot(1,0)
		img:addChild(strengthen)
		ui.gridstrengthens[i] = strengthen
		local cd = F3DComponent:new()
		cd:setBackground(UIPATH.."主界面/cd.png")
		cd:setSizeClips("32,1,0,0")
		cd:setWidth(img:getWidth())--34)
		cd:setHeight(img:getWidth())--34)
		cd:addEventListener(F3DObjEvent.OBJ_PLAYOUT, func_oe(onCDPlayOut))
		cd:setVisible(false)
		img:addChild(cd)
		ui.gridcdimgs[i] = cd
	end
	ui.pagepre = ui:findComponent("gridcont,pagepre")
	ui.pagepre:addEventListener(F3DMouseEvent.CLICK, func_me(onPagePre))
	ui.pagenext = ui:findComponent("gridcont,pagenext")
	ui.pagenext:addEventListener(F3DMouseEvent.CLICK, func_me(onPageNext))
	ui.page = ui:findComponent("gridcont,page")
	ui.rebuild = ui:findComponent("btncont,rebuild")
	ui.rebuild:addEventListener(F3DMouseEvent.CLICK, func_me(onRebuild))
	ui.allfetch = ui:findComponent("btncont,allfetch")
	ui.allfetch:addEventListener(F3DMouseEvent.CLICK, func_me(onFetchAll))
	ui.tab = tt(ui:findComponent("tab_1"), F3DTab)
	ui.tab:addEventListener(F3DUIEvent.CHANGE, func_me(onTabChange))
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
_v_251("仓库UI",ui)
	m_init = true
	update()
	背包UI.checkResize()
end

function isHided()
return not ui or not ui:isVisible()or ui.tweenhide
end

function hideUI()
	if tipsui then
		物品提示UI.hideUI()
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
_v_62(ui,true)
		return
	end
	ui = F3DLayout:new()
	uiLayer:addChild(ui)
	ui:setLoadPriority(getUIPriority())
	ui:addEventListener(F3DObjEvent.OBJ_INITED, func_e(onUIInit))
ITEMCOUNT=(g_mobileMode and not 游戏设置.NEWBAGPANEL)and 24 or 48
if ui.setUIPack and USEUIPACK then
ui:setUIPack(g_mobileMode and UIPATH.."仓库UIm.pack"or UIPATH.."仓库UI.pack")
else
	ui:setLayout(g_mobileMode and UIPATH.."仓库UIm.layout" or UIPATH.."仓库UI.layout")
end
_v_62(ui,true)
end

