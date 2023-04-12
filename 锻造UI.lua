module(..., package.seeall)

local 全局设置 = require("公用.全局设置")
local 游戏设置=require("公用.游戏设置")
local 消息 = require("网络.消息")
local 背包UI = require("主界面.背包UI")
local 角色UI = require("主界面.角色UI")
local 装备提示UI = require("主界面.装备提示UI")

m_init = false
m_itemdata = nil
m_showType = 0
m_msgTips = ""
m_tipsnews=0
tipsui = nil
tipsgrid = nil
MAXCOUNT = 1
ITEMCOUNT = 32

function setShowType(showType,tips,tipsnews)
	m_showType = showType
	m_msgTips = tips
m_tipsnews=tipsnews or 0
	if m_init then
		resetTransferGrids()
	end
end

function update()
if not m_init or 角色UI.m_itemdata==nil or 背包UI.m_itemdata==nil then
		return
	end
	if m_showType == 1 then
		ui.transfer_gridcont1:setVisible(true)
		ui.transfer_grid1:setVisible(true)
		ui.transfer_gridcont2:setVisible(false)
		ui.transfer_grid2:setVisible(false)
		ui.transfer_gridcont3:setVisible(false)
		ui.transfer_grid3:setVisible(false)
		ui.transfer_msgtips:setTitleText(txt(m_msgTips))
elseif m_showType==2 or m_showType==3 then
		ui.transfer_gridcont1:setVisible(true)
		ui.transfer_grid1:setVisible(true)
		ui.transfer_gridcont2:setVisible(true)
		ui.transfer_grid2:setVisible(true)
		ui.transfer_gridcont3:setVisible(true)
		ui.transfer_grid3:setVisible(true)
		ui.transfer_msgtips:setTitleText(txt(m_msgTips))
	else
		ui.transfer_gridcont1:setVisible(false)
		ui.transfer_grid1:setVisible(false)
		ui.transfer_gridcont2:setVisible(true)
		ui.transfer_grid2:setVisible(true)
		ui.transfer_gridcont3:setVisible(true)
		ui.transfer_grid3:setVisible(true)
		ui.transfer_msgtips:setTitleText(txt(m_msgTips))
	end
	local itemdata = ui.tab2:getSelectIndex() == 1 and 角色UI.m_itemdata or ui.tab2:getSelectIndex() == 2 and 角色UI.英雄物品数据 or 背包UI.m_itemdata
	local tb = {}
	for k,v in pairs(itemdata) do
if v.count>0 then
			tb[#tb+1] = v
		end
	end
	MAXCOUNT = math.max(1, #tb)
	local totalpage = math.ceil(MAXCOUNT / ITEMCOUNT)
	m_curpage = math.min(totalpage, (m_curpage or 1))
	ui.page:setTitleText(m_curpage.." / "..totalpage)
	for i=1,ITEMCOUNT do
		local v = tb[(m_curpage-1)*ITEMCOUNT+i]
		if v then
			ui.grids[i].cont = ui.tab2:getSelectIndex() == 1 and 1 or ui.tab2:getSelectIndex() == 2 and 2 or 3
			ui.grids[i].id = v.pos
			ui.grids[i].pic:setTextureFile(全局设置.getItemIconUrl(v.icon))
			ui.grids[i].grade:setTextureFile(全局设置.getGradeUrl(v.grade))
			ui.grids[i].lock:setTextureFile(v.bind == 1 and UIPATH.."公用/grid/img_bind.png" or "")
			ui.grids[i].count:setText(v.count > 1 and v.count or "")
			ui.grids[i].strengthen:setText(v.strengthen > 0 and "+"..v.strengthen or "")
			ui.grids[i].pic:setShaderType(v.gray and F3DImage.SHADER_GRAY or F3DImage.SHADER_NULL)
		else
			ui.grids[i].cont = 0
			ui.grids[i].id = 0
			ui.grids[i].pic:setTextureFile("")
			ui.grids[i].grade:setTextureFile("")
			ui.grids[i].lock:setTextureFile("")
			ui.grids[i].count:setText("")
			ui.grids[i].strengthen:setText("")
			ui.grids[i].pic:setShaderType(F3DImage.SHADER_NULL)
		end
	end
	updateGrid()
end

function onTab1Change(e)
end

function onTab2Change(e)
	update()
end

function updateGrid()
	local grids = {}
	grids[#grids+1] = ui.transfer_grid1
	grids[#grids+1] = ui.transfer_grid2
	grids[#grids+1] = ui.transfer_grid3
	for i,grid in ipairs(grids) do
		local itemdata = grid.cont == 1 and 角色UI.m_itemdata or grid.cont == 2 and 角色UI.英雄物品数据 or 背包UI.m_itemdata
		v = itemdata[grid.id]
if v and v.count>0 then
			grid.pic:setTextureFile(全局设置.getItemIconUrl(v.icon))
			grid.grade:setTextureFile(全局设置.getGradeUrl(v.grade))
			grid.lock:setTextureFile(v.bind == 1 and UIPATH.."公用/grid/img_bind.png" or "")
			grid.count:setText(v.count > 1 and v.count or "")
			grid.strengthen:setText(v.strengthen > 0 and "+"..v.strengthen or "")
		else
			grid.cont = 0
			grid.id = 0
			grid.pic:setTextureFile("")
			grid.grade:setTextureFile("")
			grid.lock:setTextureFile("")
			grid.count:setText("")
			grid.strengthen:setText("")
end
if v and v.count>0 and(m_tipsnews==1 or m_tipsnews==2)then
local _v_2153=0
for ii,vv in ipairs(v.addprop)do
if vv[1]==49 then
_v_2153=vv[2]
end
end
if _v_2153==0 then
m_msgTips="无法或无需修理该装备"
elseif m_tipsnews==1 then
m_msgTips="修理需要花费"..math.ceil(_v_2153*(游戏设置.REPAIRCOST or 10)).."金币"
else
m_msgTips="修理需要花费"..math.ceil(_v_2153*(游戏设置.REPAIRCOST or 10)).."金币"
end
ui.transfer_msgtips:setTitleText(txt(m_msgTips))
end
end
end

function showGrid(cont, id)
	local grids = {}
	grids[#grids+1] = 
		(ui.transfer_grid1.cont == cont and ui.transfer_grid1.id == id) and ui.transfer_grid1 or
		(ui.transfer_grid2.cont == cont and ui.transfer_grid2.id == id) and ui.transfer_grid2 or
		(ui.transfer_grid3.cont == cont and ui.transfer_grid3.id == id) and ui.transfer_grid3 or
		(ui.transfer_grid1:isVisible() and ui.transfer_grid1.cont == 0 and ui.transfer_grid1.id == 0) and ui.transfer_grid1 or
		(ui.transfer_grid2:isVisible() and ui.transfer_grid2.cont == 0 and ui.transfer_grid2.id == 0) and ui.transfer_grid2 or
		ui.transfer_grid3:isVisible() and ui.transfer_grid3 or ui.transfer_grid1
	for i,grid in ipairs(grids) do
		local itemdata = grid.cont == 1 and 角色UI.m_itemdata or grid.cont == 2 and 角色UI.英雄物品数据 or 背包UI.m_itemdata
		v = itemdata[grid.id]
		if v and v.count > 0 then
			v.gray = false
		end
	end
	for i,grid in ipairs(grids) do
		local itemdata = cont == 1 and 角色UI.m_itemdata or cont == 2 and 角色UI.英雄物品数据 or 背包UI.m_itemdata
		v = itemdata[id]
if v and v.count>0 then
			v.gray = true
			grid.cont = cont
			grid.id = id
			grid.pic:setTextureFile(全局设置.getItemIconUrl(v.icon))
			grid.grade:setTextureFile(全局设置.getGradeUrl(v.grade))
			grid.lock:setTextureFile(v.bind == 1 and UIPATH.."公用/grid/img_bind.png" or "")
			grid.count:setText(v.count > 1 and v.count or "")
			grid.strengthen:setText(v.strengthen > 0 and "+"..v.strengthen or "")
		else
			grid.cont = 0
			grid.id = 0
			grid.pic:setTextureFile("")
			grid.grade:setTextureFile("")
			grid.lock:setTextureFile("")
			grid.count:setText("")
			grid.strengthen:setText("")
end
if v and v.count>0 and(m_tipsnews==1 or m_tipsnews==2)then
local _v_2153=0
for ii,vv in ipairs(v.addprop)do
if vv[1]==49 then
_v_2153=vv[2]
end
end
if _v_2153==0 then
m_msgTips="无法或无需修理该装备"
elseif m_tipsnews==1 then
m_msgTips="修理需要花费"..math.ceil(_v_2153*(游戏设置.REPAIRCOST or 10)).."金币"
else
m_msgTips="修理需要花费"..math.ceil(_v_2153*(游戏设置.REPAIRCOST or 10)).."金币"
end
ui.transfer_msgtips:setTitleText(txt(m_msgTips))
end
end
end

function updatePerfectGrid(v)
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
	local grids = {}
	for i,grid in ipairs(grids) do
		grid.cont = 4
		grid.id = 0
		grid.pic:setTextureFile(全局设置.getItemIconUrl(m_itemdata.icon))
		grid.grade:setTextureFile(全局设置.getGradeUrl(m_itemdata.grade))
		grid.lock:setTextureFile(m_itemdata.bind == 1 and UIPATH.."公用/grid/img_bind.png" or "")
		grid.count:setText(m_itemdata.count > 1 and m_itemdata.count or "")
		grid.strengthen:setText(m_itemdata.strengthen > 0 and "+"..m_itemdata.strengthen or "")
	end
end

function resetTransferGrids()
	local grids = {}
	grids[#grids+1] = ui.transfer_grid1
	grids[#grids+1] = ui.transfer_grid2
	grids[#grids+1] = ui.transfer_grid3
	for i,g in ipairs(grids) do
		if g.cont ~= 0 and g.id ~= 0 then
			local itemdata = g.cont == 1 and 角色UI.m_itemdata or g.cont == 2 and 角色UI.英雄物品数据 or 背包UI.m_itemdata
			v = itemdata[g.id]
			if v and v.count > 0 then
				v.gray = false
			end
		end
		g.cont = 0
		g.id = 0
		g.pic:setTextureFile("")
		g.grade:setTextureFile("")
		g.lock:setTextureFile("")
		g.count:setText("")
		g.strengthen:setText("")
	end
	update()
end

function reclaimItem()
if not m_init or not ui.transfer_grid1 then
return
end
local g=ui.transfer_grid1
if g.cont~=0 and g.id~=0 then
local itemdata=g.cont==1 and 角色UI.m_itemdata or g.cont==2 and 角色UI.英雄物品数据 or 背包UI.m_itemdata
v=itemdata[g.id]
if v and v.count>0 then
v.gray=false
end
end
g.cont=0
g.id=0
g.pic:setTextureFile("")
g.grade:setTextureFile("")
g.lock:setTextureFile("")
g.count:setText("")
g.strengthen:setText("")
if m_tipsnews==1 then
m_msgTips="请放入装备进行修理(不减持久)"
elseif m_tipsnews==2 then
m_msgTips="请放入装备进行修理(不减持久)"
end
update()
end

function onGridDBClick(e)
	local g = e:getCurrentTarget()
	if g == ui.transfer_grid1 or g == ui.transfer_grid2 or g == ui.transfer_grid3 then
		if g.cont ~= 0 and g.id ~= 0 then
			local itemdata = g.cont == 1 and 角色UI.m_itemdata or g.cont == 2 and 角色UI.英雄物品数据 or 背包UI.m_itemdata
			v = itemdata[g.id]
			if v and v.count > 0 then
				v.gray = false
			end
		end
		g.cont = 0
		g.id = 0
		g.pic:setTextureFile("")
		g.grade:setTextureFile("")
		g.lock:setTextureFile("")
		g.count:setText("")
		g.strengthen:setText("")
if m_tipsnews==1 then
m_msgTips="请放入装备进行修理(不减持久)"
elseif m_tipsnews==2 then
m_msgTips="请放入装备进行修理(不减持久)"
end
		update()
	elseif g.cont ~= 0 and g.id ~= 0 then
		local itemdata = ui.tab2:getSelectIndex() == 1 and 角色UI.m_itemdata or ui.tab2:getSelectIndex() == 2 and 角色UI.英雄物品数据 or 背包UI.m_itemdata
		v = itemdata[g.id]
		local gridcont = ui.tab2:getSelectIndex() == 1 and 1 or ui.tab2:getSelectIndex() == 2 and 2 or 3
		local gridid = v.pos
if v and v.count>0 then
			showGrid(gridcont, gridid)
			update()
		end
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
	if g == nil then
	elseif F3DUIManager.sTouchComp ~= g then
	else
		local itemdata = nil
		if g.cont == 4 then
			itemdata = m_itemdata
		else
			local itemdatacont = g.cont == 1 and 角色UI.m_itemdata or g.cont == 2 and 角色UI.英雄物品数据 or 背包UI.m_itemdata
			itemdata = itemdatacont[g.id]
		end
		if itemdata and itemdata.count > 0 then
			装备提示UI.initUI()
			装备提示UI.setItemData(itemdata, g.cont == 1)
			tipsui = 装备提示UI.ui
			tipsgrid = g
			if not tipsui:isInited() then
				tipsui:addEventListener(F3DObjEvent.OBJ_INITED, func_oe(checkTipsPos))
			else
				checkTipsPos()
			end
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

function onPagePre(e)
	local totalpage = math.ceil(MAXCOUNT / ITEMCOUNT)
	m_curpage = math.max(1, m_curpage - 1)
	update()
	e:stopPropagation()
end

function onPageNext(e)
	local totalpage = math.ceil(MAXCOUNT / ITEMCOUNT)
	m_curpage = math.min(totalpage, m_curpage + 1)
	update()
	e:stopPropagation()
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

function setGridImg(grid)
	grid.cont = 0
	grid.id = 0
	grid:addEventListener(F3DMouseEvent.DOUBLE_CLICK, func_me(onGridDBClick))
	grid:addEventListener(F3DMouseEvent.RIGHT_CLICK, func_me(onGridDBClick))
	if g_mobileMode then
		grid:addEventListener(F3DMouseEvent.CLICK, func_me(onGridOver))
	else
		grid:addEventListener(F3DUIEvent.MOUSE_OVER, func_ue(onGridOver))
		grid:addEventListener(F3DUIEvent.MOUSE_OUT, func_ue(onGridOut))
	end
	grid.img = F3DImage:new()
	grid.img:setPositionX(2)
	grid.img:setPositionY(2)
	grid.img:setWidth(grid:getWidth()-4)--34)
	grid.img:setHeight(grid:getHeight()-4)--34)
	grid:addChild(grid.img)
	grid.pic = F3DImage:new()
	grid.pic:setPositionX(math.floor(grid.img:getWidth()/2))
	grid.pic:setPositionY(math.floor(grid.img:getHeight()/2))
	grid.pic:setPivot(0.5,0.5)
	grid.img:addChild(grid.pic)
	grid.grade = F3DImage:new()
	grid.grade:setPositionX(-1)
	grid.grade:setPositionY(-1)
	grid.grade:setWidth(grid.img:getWidth()+2)--36)
	grid.grade:setHeight(grid.img:getHeight()+2)--36)
	grid.img:addChild(grid.grade)
	grid.lock = F3DImage:new()
	grid.lock:setPositionX(g_mobileMode and 6 or 2)--2)
	grid.lock:setPositionY(grid.img:getHeight()-(g_mobileMode and 8 or 2))--21)
	grid.lock:setPivot(0,1)
	grid.img:addChild(grid.lock)
	grid.count = F3DTextField:new()
	grid.count:setPositionX(grid.img:getWidth()-(g_mobileMode and 8 or 2))--36)
	grid.count:setPositionY(grid.img:getHeight()-(g_mobileMode and 8 or 2))--36)
	grid.count:setPivot(1,1)
	grid.img:addChild(grid.count)
	grid.strengthen = F3DTextField:new()
	grid.strengthen:setPositionX(grid.img:getWidth()-(g_mobileMode and 8 or 2))--34)
	grid.strengthen:setPositionY(g_mobileMode and 8 or 2)--2)
	grid.strengthen:setPivot(1,0)
	grid.img:addChild(grid.strengthen)
end

function onUIInit()
	ui.close = ui:findComponent("titlebar,close")
	ui.close:addEventListener(F3DMouseEvent.CLICK, func_me(onClose))
	ui:addEventListener(F3DMouseEvent.MOUSE_DOWN, func_me(onMouseDown))
	ui.grids = {}
	for i=1,ITEMCOUNT do
		local grid = ui:findComponent("component_1,grid_"..(i-1))
		setGridImg(grid)
		ui.grids[i] = grid
	end
	ui.transfer_gridcont1 = ui:findComponent("bg2,curgrid_1")
	ui.transfer_grid1 = ui:findComponent("bg2,grid_1")
	setGridImg(ui.transfer_grid1)
	ui.transfer_gridcont2 = ui:findComponent("bg2,curgrid_2")
	ui.transfer_grid2 = ui:findComponent("bg2,grid_2")
	setGridImg(ui.transfer_grid2)
	ui.transfer_gridcont3 = ui:findComponent("bg2,curgrid_3")
	ui.transfer_grid3 = ui:findComponent("bg2,grid_3")
	setGridImg(ui.transfer_grid3)
	ui.transfer_msgtips = ui:findComponent("bg2,msgtips")
	ui.transfer = ui:findComponent("bg2,transfer")
	ui.transfer:addEventListener(F3DMouseEvent.CLICK, func_me(function (e)
if m_showType==1 then
消息.CG_COMMAND_MSG(m_tipsnews==1 and 6 or m_tipsnews==2 and 7 or 4,ui.transfer_grid1.cont..","..ui.transfer_grid1.id)
elseif m_showType==2 then
消息.CG_COMMAND_MSG(5,ui.transfer_grid1.cont..","..ui.transfer_grid1.id..","..ui.transfer_grid2.cont..","..ui.transfer_grid2.id..","..ui.transfer_grid3.cont..","..ui.transfer_grid3.id)
elseif m_showType==3 and ui.transfer_grid1.cont~=0 and ui.transfer_grid1.id~=0 and ui.transfer_grid2.cont~=0 and ui.transfer_grid2.id~=0 and ui.transfer_grid3.cont~=0 and ui.transfer_grid3.id~=0 then
			消息.CG_STRENGTHEN_ALL(ui.transfer_grid1.cont, ui.transfer_grid1.id, ui.transfer_grid2.cont, ui.transfer_grid2.id, ui.transfer_grid3.cont, ui.transfer_grid3.id)
elseif ui.transfer_grid2.cont~=0 and ui.transfer_grid2.id~=0 and ui.transfer_grid3.cont~=0 and ui.transfer_grid3.id~=0 then
			消息.CG_STRENGTHEN_ALL(ui.transfer_grid2.cont, ui.transfer_grid2.id, ui.transfer_grid3.cont, ui.transfer_grid3.id, 0, 0)
		end
	end))
	tdisui(ui.transfer)
	ui.pagepre = ui:findComponent("component_1,pagepre")
	ui.pagepre:addEventListener(F3DMouseEvent.CLICK, func_me(onPagePre))
	ui.pagenext = ui:findComponent("component_1,pagenext")
	ui.pagenext:addEventListener(F3DMouseEvent.CLICK, func_me(onPageNext))
	ui.page = ui:findComponent("component_1,page")
	ui.tab2 = tt(ui:findComponent("tab_2"), F3DTab)
	ui.tab2:addEventListener(F3DUIEvent.CHANGE, func_me(onTab2Change))
if m_msgTips==""then
		ui.规则说明容器 = ui:findComponent("规则说明容器")
		ui.规则说明容器:setVisible(false)
		ui.规则说明 = tt(ui:findComponent("规则说明"),F3DCheckBox)
		ui.规则说明:addEventListener(F3DUIEvent.CHANGE, func_ue(function (e)
			ui.规则说明容器:setVisible(ui.规则说明:isSelected())
		end))
		ui.合成 = tt(ui:findComponent("合成"),F3DCheckBox)
		ui.合成:addEventListener(F3DUIEvent.CHANGE, func_ue(function (e)
m_showType=ui.合成:isSelected()and 3 or 0
			resetTransferGrids()
		end))
else
ui.规则说明容器=ui:findComponent("规则说明容器")
ui.规则说明容器:setVisible(false)
ui.规则说明=tt(ui:findComponent("规则说明"),F3DCheckBox)
ui.规则说明:setVisible(false)
ui.合成=tt(ui:findComponent("合成"),F3DCheckBox)
ui.合成:setVisible(false)
ui:findComponent("component_2"):setVisible(false)
	end
	m_init = true
	update()
end

function isHided()
return not ui or not ui:isVisible()or ui.tweenhide
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
_v_62(ui,true)
		return
	end
	ui = F3DLayout:new()
	uiLayer:addChild(ui)
	ui:setLoadPriority(getUIPriority())
	ui:setMovable(true)
	ui:addEventListener(F3DObjEvent.OBJ_INITED, func_e(onUIInit))
	ITEMCOUNT = g_mobileMode and 16 or 32
if ui.setUIPack and USEUIPACK then
ui:setUIPack(g_mobileMode and UIPATH.."锻造UIm.pack"or UIPATH.."锻造UI.pack")
else
	ui:setLayout(g_mobileMode and UIPATH.."锻造UIm.layout" or UIPATH.."锻造UI.layout")
end
_v_62(ui,true)
end

