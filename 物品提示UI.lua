module(..., package.seeall)

local 全局设置 = require("公用.全局设置")
local 游戏设置=require("公用.游戏设置")
local 实用工具=require("公用.实用工具")
local 消息 = require("网络.消息")
local 背包UI = require("主界面.背包UI")
local 地图表=require("配置.地图表")
local 怪物表=require("配置.怪物表")
local Npc表=require("配置.Npc表")
m_init = false
m_itemdata = nil
m_isbag = false
_v_1876=false


function setItemData(itemdata, isbag,_v_1878)
	m_itemdata = itemdata
	m_isbag = isbag
	_v_1876=_v_1878
	update()
end

function setEmptyItemData()
	if not m_init then
		return
	end
	ui.color:setBackground(COLORBG[1])
	ui.img:setTextureFile("")
	ui.grade:setTextureFile("")
	ui.lock:setTextureFile("")
	ui.name:setTitleText("")
	ui.name:setTextColor(全局设置.getColorRgbVal(1))
for i=1,#ui.descs do
ui.descs[i]:setVisible(false)
end
	ui.job:setTitleText("")
	ui.level:setTitleText("")
	ui.cd:setTitleText("")
	ui.类型:setTitleText("")
	if g_mobileMode then
		for i = 1,5 do
			ui.menus[i]:setVisible(false)
		end
	end
end

COLORBG = {
	"",
	UIPATH.."公用/tip/tips_color_1.png",
	UIPATH.."公用/tip/tips_color_2.png",
	UIPATH.."公用/tip/tips_color_3.png",
	UIPATH.."公用/tip/tips_color_4.png",
	UIPATH.."公用/tip/tips_color_5.png",
}
function update()
	if not m_init or not m_itemdata then
		return
	end
	ui.color:setBackground(COLORBG[m_itemdata.grade])
	ui.img:setTextureFile(全局设置.getItemIconUrl(m_itemdata.icon))
	ui.grade:setTextureFile(全局设置.getGradeUrl(m_itemdata.grade))
	ui.lock:setTextureFile(m_itemdata.bind == 1 and UIPATH.."公用/grid/img_bind.png" or "")
	ui.name:setTitleText(txt(m_itemdata.name))
	ui.name:setTextColor(m_itemdata.color > 0 and m_itemdata.color or 全局设置.getColorRgbVal(m_itemdata.grade))

local index=1
local ss=实用工具.SplitString(m_itemdata.desc,"\n",true)
local color=0xffffff
for i,v in ipairs(ss)do
if v:sub(1,2)=="<c"and v:find(">")then
color=tonumber("0x"..v:sub(3,v:find(">")-1))or 0
v=v:sub(v:find(">")+1)
end
checkPropIndex(index,游戏设置.NEWITEMTIPS and 1 or#ss)
ui.descs[index]:setTitleText(txt(v))
ui.descs[index]:setTextColor(color)
ui.descs[index]:setVisible(true)
index=index+1
end
for i=index,#ui.descs do
ui.descs[i]:setVisible(false)
end
	if not 游戏设置.NEWITEMTIPS then
		zbjs=0
		avtcont = 0
	end
if 游戏设置.NEWITEMTIPS then
ui.job:setTitleText(txt("需求："..m_itemdata.level.."级"..(m_itemdata.job>0 and","..全局设置.获取职业类型(m_itemdata.job)or"")))
else
ui.job:setTitleText(txt("职业："..全局设置.获取职业类型(m_itemdata.job)))
end
if m_itemdata.level<0 then
ui.level:setTitleText(txt("转生等级："..(-m_itemdata.level).."转"))
else
ui.level:setTitleText(txt("等级："..m_itemdata.level))
end
ui.cd:setTitleText(txt("CD："..(m_itemdata.cdmax/1000).." 秒"))
	if 游戏设置.NEWITEMTIPS then
		ui.类型:setTitleText(txt("类型："..全局设置.获取物品类型(m_itemdata.type,m_itemdata.equippos)..(m_itemdata.cdmax>0 and","..(m_itemdata.cdmax/1000).."秒CD"or"")))
	else
		ui.类型:setTitleText(txt("类型："..全局设置.获取物品类型(m_itemdata.type,m_itemdata.equippos)))
	end
	local props={}
	local aprops={}
	local gprops={}
	local _v_1464={}
	local _v_1872={}
	for i,v in ipairs(m_itemdata.prop)do

		if m_itemdata.type==3 and m_itemdata.equippos==14 and v[1]<0 then
			props[v[1]]={v[2],v[3]}
		elseif v[1]<0 or v[1]>1000 then
			_v_1464[#_v_1464+1]={v[1],v[2],v[4]}
		else
			props[v[1]]=(props[v[1]]or 0)+v[2]+v[3]
			if v[1]==4 or v[1]==6 or v[1]==8 or v[1]==10 or v[1]==12 or v[1]==48 or v[1]==50 or v[1]==52 or v[1]==54 then--持久
				props[v[1]-1]=(props[v[1]-1]or 0)
			end
		end
	end
	for i,v in ipairs(m_itemdata.addprop)do
		if v[1]<0 or v[1]>1000 then
		_v_1464[#_v_1464+1]={v[1],v[2],v[4]}
		else
		_v_1872[v[1]]=v[4]
		props[v[1]]=(props[v[1]]or 0)+v[2]
			if v[1]==4 or v[1]==6 or v[1]==8 or v[1]==10 or v[1]==12 or v[1]==48 or v[1]==50 or v[1]==52 or v[1]==54 then
				props[v[1]-1]=(props[v[1]-1]or 0)
			end
			aprops[v[1]]=(aprops[v[1]]or 0)+v[2]
			gprops[v[1]]=math.max(gprops[v[1]]or 1,v[3])
		end
	end
	local zbjs=0
	local _v_1465=false
	local _v_1466=false
	local _v_1469=false
	local _v_1470=false
	local _v_1471=false
	local _v_1472=false
	local _v_1473=false
	local _v_1474=false
	local _v_1475=false
	local index=1
		for _,v in ipairs(全局设置.proptexts)do
		i=v[2]
		if v[1]~=""and props[i]then
			if i==91 or i==92 and not _v_1470 then
				_v_1467(index,zbjs)
				ui.props[index]:setTitleText(txt("[来源时间]："))
				ui.props[index]:setTextColor(0x00DDFF)
				ui.props[index].pic:setTextureFile("")
				ui.props[index]:setVisible(true)
				index=index+1
				_v_1470=true			
			end
			_v_1467(index,zbjs)
			if VIPLEVEL<4 and i>=47 then
			elseif(i>=3 and i<=12)or(i>=47 and i<=54)then
				if i%2==1 then
					local _v_1468=props[i]
					if(i==49 or i==51 or i==53)and props[i+1]then
						_v_1468=props[i+1]-_v_1468
					end
					
					local str
					if i==53 then
						local val=tonumber(_v_1468)or 0
						str=txt("剩余"..math.floor(val/(60*24)).."天"..(math.floor(val/60)%24).."时"..(math.floor(val)%60).."分")
					else
						str=_v_1468..((i>=47 and i<=52)and"/"or"-")..(props[i+1]or 0)
					end
					if not(i>=47 and i<=54)and(aprops[i]or aprops[i+1])then--基础属性
						if (aprops[i]) then
						--str=str.." + ("..(aprops[i]or 0).."-"..(aprops[i+1]or 0)..")"
						str=str.." + "..(aprops[i]or 0)
						elseif (aprops[i+1]) then
							str=str.." + "..(aprops[i+1]or 0)
						end
					end
					
						ui.props[index]:setTitleText(txt(v[1].."：")..str)
						ui.props[index]:setTextColor(v[4]or 全局设置.getColorRgbVal(math.max(gprops[i]or 1,gprops[i+1]or 1)))
							ui.props[index].pic:setTextureFile("")
						ui.props[index]:setVisible(true)
						index=index+1
								
					end
			elseif i==85 then
				local str=(i==85 and props[i]/1 or props[i])..(v[3]and"%"or"")
				ui.props[index]:setTitleText(txt(v[1].."：")..str)
				ui.props[index]:setTextColor(v[4]or 全局设置.getColorRgbVal(gprops[i]or 1))
				ui.props[index].pic:setTextureFile("")
				ui.props[index]:setVisible(true)
				index=index+1
			elseif i==86 then
				local str=(i==86 and props[i]/1 or props[i])..(v[3]and"%"or"")
				ui.props[index]:setTitleText(txt(v[1].."：")..str)
				ui.props[index]:setTextColor(v[4]or 全局设置.getColorRgbVal(gprops[i]or 1))
				ui.props[index].pic:setTextureFile("")
				ui.props[index]:setVisible(true)
				index=index+1	
--10-12				
			-- elseif i==92 then
				-- local riqi = props[i]
				-- riqi1 = string.sub(riqi, 1, 2)
				-- riqi2 = string.sub(riqi, 3, 4)
				-- riqi3 = string.sub(riqi, 5, 6)
				-- riqi4 = string.sub(riqi, 7, 8)
				-- riqi5 = string.sub(riqi, 9, 10)
				-- local sj = "["..riqi1..txt"/"..riqi2..txt"/23年".."]".." "..riqi3..":"..riqi4..":"..riqi5
				-- local str=(props[i]and props[i]~="")and txt(props[i])or props[i]..(v[3]and"%"or"")
				-- ui.props[index]:setTitleText(txt(v[1]..sj))
				-- ui.props[index]:setTextColor(v[4]or 全局设置.getColorRgbVal(gprops[i]or 1))
				-- ui.props[index].pic:setTextureFile("")
				-- ui.props[index]:setVisible(true)
				-- index=index+1
--1-9
		elseif i==92 then
			local riqi =props[i]
			riqi1 = string.sub(riqi, 1, 1)
			riqi2 = string.sub(riqi, 2, 3)
			riqi3 = string.sub(riqi, 4, 5)
			riqi4 = string.sub(riqi, 6, 7)
			riqi5 = string.sub(riqi, 8, 9)
			local sj = "[0"..riqi1..txt"月"..riqi2..txt"日23年".."]".." "..riqi3..":"..riqi4..":"..riqi5
			local str=(_v_1872[i]and _v_1872[i]~="")and txt(_v_1872[i])or sj..(v[3]and""or"")
			ui.props[index]:setTitleText(txt(v[1].."：")..str)
			ui.props[index]:setTextColor(v[4]or 全局设置.getColorRgbVal(gprops[i]or 1))
			ui.props[index].pic:setTextureFile("")
			ui.props[index]:setVisible(true)
			index=index+1				
			elseif i==91 then
				local laiyuan =tonumber(props[i])
				--local monsterid = math.modf(laiyuan/10000)
				--local mapid = laiyuan%10000
				local mapid = laiyuan
			local sj = 0
			if laiyuan >1000 then
				sj=txt("["..Npc表.Config[mapid].name.."]")
			elseif laiyuan >100 then
				sj=txt("["..地图表.Config[mapid].name.."]")
			else
				sj=txt(游戏设置.系统来源 or "系统")
			end
				local str=(_v_1872[i]and _v_1872[i]~="")and txt(_v_1872[i])or sj..(v[3]and""or"")
				ui.props[index]:setTitleText(txt(v[1].."：")..str)
				ui.props[index]:setTextColor(v[4]or 全局设置.getColorRgbVal(gprops[i]or 1))
				ui.props[index].pic:setTextureFile("")
				ui.props[index]:setVisible(true)
				index=index+1	
			else--攻速
				local str=(i==82 and props[i]/1 or props[i])..(v[3]and"%"or"")..(aprops[i]and" + "..aprops[i]or"")
				ui.props[index]:setTitleText(txt(v[1].."：")..str)
				ui.props[index]:setTextColor(v[4]or 全局设置.getColorRgbVal(gprops[i]or 1))
				ui.props[index].pic:setTextureFile("")
				ui.props[index]:setVisible(true)
				index=index+1
			end
		end
	end
	local proph=g_mobileMode and 18 or 14
	if not 游戏设置.NEWITEMTIPS then
		proph=0
	end
	if 游戏设置.NEWITEMTIPS and m_itemdata.desc:sub(-1,-1)=="\n"then
		index=math.max(1,index-1)
	end
	ui.img_tipsBg:setHeight(ui.oldheight+(index-2)*proph-((not m_isbag and g_mobileMode)and(游戏设置.MENUHEIGHT or 100)or 0))
	ui:setHeight(ui.oldheight+(index-2)*proph-((not m_isbag and g_mobileMode)and(游戏设置.MENUHEIGHT or 100)or 0))
	ui.img_line3:setPositionY(ui.img_line3.oldposy+zbjs+(index-5.5)*proph)
	if g_mobileMode then
		for i=1,5 do
			ui.menus[i]:setPositionY(ui.menus[i].oldposy+(index-2)*proph)
			ui.menus[i]:setVisible(m_isbag)
		end
	end
end

function onMouseDown(e)
	uiLayer:removeChild(ui)
	uiLayer:addChild(ui)
	e:stopPropagation()
end

function onMenuClick(e)
	local g = e:getCurrentTarget()
	if g == ui.menus[1] then
		背包UI.m_selectitem = m_itemdata
		背包UI.onUse(e)
	elseif g == ui.menus[2] then
		背包UI.m_selectitem = m_itemdata
		背包UI.onBatchUse(e)
	elseif g == ui.menus[3] then
		背包UI.m_selectitem = m_itemdata
		背包UI.onDivide(e)
	elseif g == ui.menus[4] then
		背包UI.m_selectitem = m_itemdata
		背包UI.onDiscard(e)
	elseif g == ui.menus[5] then
		背包UI.m_selectitem = m_itemdata
		背包UI.onSell(e)
	end
	背包UI.hideAllTipsUI()
end
function _v_1467(i,zbjs)
	if not ui.props[i]then
		ui.props[i]=i==1 and ui:findComponent("prop_1")or ui.props[1]:clone()
		ui.props[i].pic=F3DImage:new()
		ui.props[i].pic:setWidth(g_mobileMode and 26 or 22)--设置宽度
		ui.props[i].pic:setHeight(g_mobileMode and 22 or 18)--设置高度
		ui.props[i].pic:setPositionX(g_mobileMode and-30 or-25)--设置位置X
		ui.props[i]:addChild(ui.props[i].pic)--显示列表
		if i==1 then
			ui.props[i]:setVisible(true)--可见
		else
			ui:addChild(ui.props[i])--显示列表
		end
	end
	local proph=g_mobileMode and 18 or 20
	if i==1 then
		ui.props[i]:setPositionY(ui.propy+zbjs)
	else
		ui.props[i]:setPositionY(ui.propy+(proph*(i-1))+zbjs)
	end
end
function checkPropIndex(i,cnt)
if not ui.descs[i]then
ui.descs[i]=i==1 and ui:findComponent("component_2")or ui.descs[1]:clone()
ui:addChild(ui.descs[i])
end
local proph=g_mobileMode and 18 or 14
if i==1 then
ui.descs[i]:setPositionY(ui.descy-math.floor(proph*(cnt-1)/2))
else
ui.descs[i]:setPositionY(ui.descs[1]:getPositionY()+(proph*(i-1)))
end
end

function onUIInit()
	ui:addEventListener(F3DMouseEvent.MOUSE_DOWN, func_me(onMouseDown))
	ui.grid = ui:findComponent("gridBg_49X49")
	ui.name = ui:findComponent("component_1")
ui.descy=ui:findComponent("component_2"):getPositionY()
ui.descs={}
	ui.job = ui:findComponent("component_3")
	ui.level = ui:findComponent("component_4")
	ui.cd = ui:findComponent("component_5")
	ui.类型 = ui:findComponent("component_6")
	ui.color = ui:findComponent("tips_color_1")
	ui.color=ui:findComponent("img_line3")
	ui.color=ui:findComponent("prop_1")
	if g_mobileMode then
		ui.menus = {}
		for i = 1,5 do
			ui.menus[i] = ui:findComponent("menu_"..i)
			ui.menus[i].oldposy=ui.menus[i]:getPositionY()
			ui.menus[i]:addEventListener(F3DMouseEvent.CLICK, func_me(onMenuClick))
		end
	end
	ui.propy=ui:findComponent("prop_1"):getPositionY()
	ui.props={}
	ui:findComponent("prop_1"):setVisible(false)

	ui.img = F3DImage:new()
	ui.img:setPositionX(math.floor(ui.grid:getWidth()/2))
	ui.img:setPositionY(math.floor(ui.grid:getHeight()/2))
	ui.img:setPivot(0.5,0.5)
	ui.grid:addChild(ui.img)
	ui.grade = F3DImage:new()
	ui.grade:setPositionX(1)
	ui.grade:setPositionY(1)
	ui.grade:setWidth(ui.grid:getWidth()-2)
	ui.grade:setHeight(ui.grid:getHeight()-2)
	ui.grid:addChild(ui.grade)
	ui.lock = F3DImage:new()
	ui.lock:setPositionX(4)
	ui.lock:setPositionY(ui.grid:getHeight()-4)
	ui.lock:setPivot(0,1)
	ui.grid:addChild(ui.lock)
ui.img_tipsBg=ui:findComponent("img_tipsBg")
ui.oldheight=ui:getHeight()
ui.img_line3=ui:findComponent("img_line3")
ui.img_line3.oldposy=ui.img_line3:getPositionY()
	m_init = true
	setEmptyItemData()
	update()
end

function isHided()
return not ui or not ui:isVisible()or ui.tweenhide
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
	if not g_mobileMode then
		ui:setTouchable(false)
	end
	ui:addEventListener(F3DObjEvent.OBJ_INITED, func_e(onUIInit))
if ui.setUIPack and USEUIPACK then
ui:setUIPack(g_mobileMode and UIPATH.."物品提示UIm.pack"or UIPATH.."物品提示UI.pack")
else
ui:setLayout(g_mobileMode and UIPATH.."物品提示UIm.layout" or UIPATH.."物品提示UI.layout")
end
	
end
