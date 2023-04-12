module(..., package.seeall)

local 全局设置 = require("公用.全局设置")
local 游戏设置 = require("公用.游戏设置")
local 实用工具 = require("公用.实用工具")
local 网络连接 = require("公用.网络连接")
local 地图UI = require("主界面.地图UI")
local 地图表 = require("配置.地图表")
local 角色逻辑 = require("主界面.角色逻辑")
local 消息 = require("网络.消息")
local 技能逻辑 = require("技能.技能逻辑")
local 辅助UI = require("主界面.辅助UI")
local 聊天UI = require("主界面.聊天UI")
local 聊天UID = require("主界面.聊天UID")
local 主界面UI = require("主界面.主界面UI")
local 好友UI = require("主界面.好友UI")
local 队伍UI = require("主界面.队伍UI")
local 邮件UI = require("主界面.邮件UI")
local 商城UI = require("主界面.商城UI")
local 背包UI = require("主界面.背包UI")
local 消息框UI1 = require("主界面.消息框UI1")

m_init = false
m_money1 = 0
m_money2 = 0
m_windowsize = 1
m_showQuit = false
m_simpleMode = false
m_staticFrameTime = 0
enemyinfo = nil
enemylist = {}

m_mapurl = ""
m_mapid = 0
m_threadname = ""
m_threadid = 0
m_threadcnt = 0

function setThreadName(name)
	local ss = 实用工具.SplitString(name, "-")
	if #ss == 2 and (tonumber(ss[2]) or 0) > 0 then
		m_threadname = "["..ss[1].."线]"
		m_threadid = tonumber(ss[1]) or 0
		m_threadcnt = tonumber(ss[2]) or 0
	else
		m_threadname = ""
		m_threadid = 0
		m_threadcnt = 0
	end
	updateThreadName()
end

function updateThreadName()
	if not m_init then
		return
	end
	if m_mapid ~= 0 then
		minimapcombo:setTitleText(txt(地图表.Config[m_mapid].name..m_threadname))
		minimapcombo:getList():removeAllItems()
		for i=1,m_threadcnt do
			local cb = F3DCheckBox:new()
			if g_mobileMode then
				cb:setTitleFont("宋体,15")
				cb:setHeight(24)
			else
				cb:setHeight(20)
			end
			cb:setTitleText(txt(地图表.Config[m_mapid].name.."["..i.."线]"))
			minimapcombo:getList():addItem(cb)
		end
	end
end

function setShowQuit(show)
	m_showQuit = show
	updateShowQuit()
end

function updateShowQuit()
	if not m_init then
		return
	end
	ui.quit:setVisible(m_showQuit)
end

function setCurrency(money1, money2)
	m_money1 = money1
	m_money2 = money2
	updateCurrency()
end

function updateCurrency()
	if not m_init then
		return
	end
end

function showEnemyInfo(info)
	enemyinfo = info
	updateEnemyInfo()
end

function updateEnemyInfo()
	if not m_init or enemyinfo == nil then
		return
	end
	local img, type
	local currindex = 1
	for i,v in ipairs(enemyinfo) do
		if not g_roles[v[1]] then
			local x = v[5]
			local y = -v[6]
			local rx = g_role:getPositionX()
			local ry = -g_role:getPositionY()
			local pt = F3DPoint:new(x-rx,y-ry)
			local radiusw = minimapcomp:getWidth()/2
			local radiush = minimapcomp:getHeight()/2
			pt:normalize(math.max(radiusw,radiush)*1.414)
			if pt.x < -radiusw then
				pt.x = -radiusw
			elseif pt.x > radiusw then
				pt.x = radiusw
			end
			if pt.y < -radiush then
				pt.y = -radiush
			elseif pt.y > radiush then
				pt.y = radiush
			end
			img = #enemylist >= currindex and enemylist[currindex]
			if not img then
				img = F3DImage:new()
				enemylist[currindex] = img
			end
			type = (v[8] ~= 0 and v[8] == 角色逻辑.m_teamid) and "team" or "enemy"
			img:setTextureFile(UIPATH.."公用/radar/icon_radar_"..type..".png")
			img:setPivot(0.5,0)
			img:setRotationZ(F3DUtils:calcDirection(x-rx,y-ry))
			if g_is3D then
				img:setPositionX(minimapmeimg:getPositionX()+pt.x)
				img:setPositionY(minimapmeimg:getPositionY()+pt.y)
			end
			enemycont:addChild(img)
			currindex = currindex+1
		end
	end
	for i=currindex,#enemylist do
		enemylist[i]:removeFromParent()
	end
end

pt1 = F3DPoint:new()
pt2 = F3DPoint:new()
pt3 = F3DPoint:new()
function clearShape()
	if shape then
		shape:clearAll()
	end
	地图UI.clearShape()
	m_pts = nil
end

m_pts = nil
function drawShape(pts)
	m_pts = {{x=g_role:getPositionX(),y=g_role:getPositionY()}}
	for i=1,pts:size() do
		local pt = pts:get(i-1)
		m_pts[#m_pts+1] = {x=pt.x,y=pt.y}
	end
	updateShape(pts)
	地图UI.updateShape()
end

function updateShape(pts)
	if not m_init or m_pts == nil then
		return
	end
	if minimapimg:getWidth() == 0 or minimapimg:getHeight() == 0 then
		return
	end
	shape:clearAll()
	if g_is3D then
		pt1.x = minimapimg:getWidth()*m_pts[1].x/g_mapWidth
		pt1.y = minimapimg:getHeight()*(g_mapHeight-m_pts[1].y)/g_mapHeight
	else
		pt1.x = minimapimg:getWidth()*m_pts[1].x/g_mapWidth
		pt1.y = minimapimg:getHeight()*to2d(m_pts[1].y)/g_mapHeight
	end
	for i=2,#m_pts do
		local pt = m_pts[i]
		if g_is3D then
			pt2.x = minimapimg:getWidth()*pt.x/g_mapWidth
			pt2.y = minimapimg:getHeight()*(g_mapHeight-pt.y)/g_mapHeight
		else
			pt2.x = minimapimg:getWidth()*pt.x/g_mapWidth
			pt2.y = minimapimg:getHeight()*pt.y/g_mapHeight
		end
		pt3.x = pt2.x - pt1.x
		pt3.y = pt2.y - pt1.y
		local len = pt3:length()
		pt3:normalize()
		while len > 10 do
			pt2.x = pt1.x + pt3.x * 10
			pt2.y = pt1.y + pt3.y * 10
			shape:drawLine(pt1, pt2)
			len = len - 10
			if len > 10 then
				pt1.x = pt2.x + pt3.x * 10
				pt1.y = pt2.y + pt3.y * 10
			else
				pt1.x = pt2.x + pt3.x * len
				pt1.y = pt2.y + pt3.y * len
			end
			len = len - 10
			if len <= 10 then
				pt2.x = pt1.x + pt3.x * len
				pt2.y = pt1.y + pt3.y * len
				break
			end
		end
		if len > 0 then
			shape:drawLine(pt1, pt2)
			pt1.x = pt2.x
			pt1.y = pt2.y
		end
	end
end

function updateSize(mapWidth, mapHeight)
	if minimapimg and g_mapWidth > 0 and g_mapHeight > 0 then
		local w = math.floor(mapWidth / 32)
		local h = math.floor(mapHeight / 32)
		local r = math.min(w / 200, h / 200)
		minimapimg:setWidth(math.floor(r >= 1 and w or w / r))
		minimapimg:setHeight(math.floor(r >= 1 and h or h / r))
	end
end

function setMapUrl(url, mapid)
	if m_mapid ~= mapid then
		m_mapurl = url
		m_mapid = mapid
		if minimapimg then
			minimapimg:setTextureFile(m_mapurl, g_mapPriority)
		end
		if minimapcombo then
			minimapcombo:setTitleText(txt(地图表.Config[mapid].name..m_threadname))
			minimapcombo:getList():removeAllItems()
			for i=1,m_threadcnt do
				local cb = F3DCheckBox:new()
				if g_mobileMode then
					cb:setTitleFont("宋体,15")
					cb:setHeight(24)
				else
					cb:setHeight(20)
				end
				cb:setTitleText(txt(地图表.Config[mapid].name.."["..i.."线]"))
				minimapcombo:getList():addItem(cb)
			end
		end
	end
	地图UI.setMapUrl(m_mapurl, mapid)
end

imglist = {}

function updateImgList()
	if not m_init or g_mapWidth == 0 or g_mapHeight == 0 then
		return
	end
	local img, type
	local currindex = 1
	for i,v in pairs(g_roles) do
		local role = v
		if role ~= g_role and role:isVisible() then
			img = #imglist >= currindex and imglist[currindex]
			if not img then
				img = F3DImage:new()
				img:setPivot(0.5,0.5)
				imglist[currindex] = img
			end
			type = (role.objtype == 全局设置.OBJTYPE_PLAYER or (role.objtype == 全局设置.OBJTYPE_MONSTER and role.isrobot)) and
				((role.teamid ~= 0 and role.teamid == 角色逻辑.m_teamid) and 5 or 6) or
				role.objtype == 全局设置.OBJTYPE_NPC and 2 or role.objtype == 全局设置.OBJTYPE_PET and 7 or
				(role.objtype == 全局设置.OBJTYPE_MONSTER and role.isboss) and 8 or 1
			img:setTextureFile(UIPATH.."公用/radar/icon_radar_"..type..".png")
			if g_is3D then
				img:setPositionX(minimapimg:getWidth()*role:getPositionX()/g_mapWidth)
				img:setPositionY(minimapimg:getHeight()*(g_mapHeight-role:getPositionY())/g_mapHeight)
			else
				img:setPositionX(minimapimg:getWidth()*role:getPositionX()/g_mapWidth)
				img:setPositionY(minimapimg:getHeight()*to2d(role:getPositionY())/g_mapHeight)
			end
			--if 实用工具.GetDistance(img:getPositionX()+minimapimg:getPositionX(),img:getPositionY()+minimapimg:getPositionY(), ui.maskradiusx,ui.maskradiusx) <= ui.maskradiusx then
			if img:getPositionX()+minimapimg:getPositionX()>=0 and img:getPositionX()+minimapimg:getPositionX()<=ui.maskradiusx*2 and img:getPositionY()+minimapimg:getPositionY()>=0 and img:getPositionY()+minimapimg:getPositionY()<=ui.maskradiusy*2 then
				minimapimglist:addChild(img)
			else
				img:removeFromParent()
			end
			currindex = currindex+1
		end
	end
	for i=currindex,#imglist do
		imglist[i]:removeFromParent()
	end
	地图UI.updateImgList()
end

function updatePos(posx, posy, rotate)
	if not m_init or g_mapWidth == 0 or g_mapHeight == 0 then
		return
	end
	minimapmeimg:setRotationZ(rotate)
	if g_is3D then
		minimaptext:setTitleText(math.floor(posx)..","..math.floor(posy))
		minimapimg:setPositionX(-(minimapimg:getWidth()*posx/g_mapWidth-minimapcomp:getWidth()/2))
		minimapimg:setPositionY(-(minimapimg:getHeight()*(g_mapHeight-posy)/g_mapHeight-minimapcomp:getHeight()/2))
		minimapmeimg:setPositionX(minimapcomp:getWidth()/2)
		minimapmeimg:setPositionY(minimapcomp:getHeight()/2)
	else
		local 格子大小X = 地图表.Config[g_mapid].movegrid[1] or 50
		local 格子大小Y = 地图表.Config[g_mapid].movegrid[2] or 25
		minimaptext:setTitleText(math.floor(posx/格子大小X)..","..math.floor(to2d(posy)/格子大小Y))
		minimapimg:setPositionX(-(minimapimg:getWidth()*posx/g_mapWidth-minimapcomp:getWidth()/2))
		minimapimg:setPositionY(-(minimapimg:getHeight()*to2d(posy)/g_mapHeight-minimapcomp:getHeight()/2))
		minimapimg:setPositionX(math.min(0,math.max(-(minimapimg:getWidth()-minimapcomp:getWidth()),minimapimg:getPositionX())))
		minimapimg:setPositionY(math.min(0,math.max(-(minimapimg:getHeight()-minimapcomp:getHeight()),minimapimg:getPositionY())))
		minimapmeimg:setPositionX(minimapimg:getPositionX()+minimapimg:getWidth()*posx/g_mapWidth)
		minimapmeimg:setPositionY(minimapimg:getPositionY()+minimapimg:getHeight()*to2d(posy)/g_mapHeight)
	end
	ui.maskshp:clearAll()
	ui.maskshp:drawRect(F3DPoint:new(-minimapimg:getPositionX(),-minimapimg:getPositionY()),F3DPoint:new(ui.maskradiusx*2-minimapimg:getPositionX(),ui.maskradiusy*2-minimapimg:getPositionY()))

	minimapimglist:setPositionX(minimapimg:getPositionX())
	minimapimglist:setPositionY(minimapimg:getPositionY())
	if shape then
		shape:setPositionX(minimapimg:getPositionX())
		shape:setPositionY(minimapimg:getPositionY())
	end
	地图UI.updatePos(posx, posy, rotate)
end

function onMapClick(e)
	地图UI.toggle()
	地图UI.setMapUrl(m_mapurl, m_mapid)
end

function onSetupClick(e)
	辅助UI.toggle()
end

function onQuit(e)
	if 地图表.Config[m_mapid].maptype > 0 then
		消息.CG_QUIT_COPYSCENE()
	elseif 地图表.Config[101] then
		消息.CG_TRANSPORT(101, 地图表.Config[101].bornpos[1], 地图表.Config[101].bornpos[2])
	end
end

function CheckHandup(autofindpath)
	if not m_init then
		return
	end
	ui.hanguptxt1:setVisible(not 技能逻辑.autoUseSkill)
	ui.hanguptxt2:setVisible(技能逻辑.autoUseSkill)
	主界面UI.m_autofindpath:setVisible(autofindpath and not 技能逻辑.autoUseSkill)
	主界面UI.m_autofight:setVisible(技能逻辑.autoUseSkill)
	if m_staticFrameTime == 0 and 技能逻辑.autoUseSkill then
		m_staticFrameTime = rtime() + 60000
	elseif not 技能逻辑.autoUseSkill then
		m_staticFrameTime = 0
	end
end

function onComboChange(e)
	local list = tt(e:getCurrentTarget(),F3DList)
	if list then
		local index = list:getSelectItemIndex()
		if m_threadid ~= index+1 then
			消息.CG_ASK_LOGIN(__ARGS__.account, (__ARGS__.authkey or "")..(g_ServerName and ","..g_ServerName or ""), (__ARGS__.server or 0) + (__ARGS__.index or 0)*10000, -(index+1))
		end
	end
end

function onUIInit(e)
	minimapcombo = tt(ui:findComponent("combo_1"),F3DCombo)
	minimapcombo:getList():addEventListener(F3DUIEvent.CHANGE, func_ue(onComboChange))
	minimapcomp = ui:findComponent("component_2")
	minimaptext = ui:findComponent("component_1")
	ui.mapbtn = ui:findComponent("mapbtn")
	ui.mapbtn:addEventListener(F3DMouseEvent.CLICK, func_me(onMapClick))
	ui.setupbtn = ui:findComponent("setupbtn")--设置
	ui.setupbtn:addEventListener(F3DMouseEvent.CLICK, func_me(onSetupClick))
	ui.maskradiusx = minimapcomp:getWidth()/2
	ui.maskradiusy = minimapcomp:getHeight()/2
	ui.maskshp = F3DShape:new()
	minimapimg = F3DImage:new()
	minimapimg:setMask(ui.maskshp)
	minimapcomp:addChild(minimapimg)
	shape = F3DShape:new()
	shape:setPenColor(0,1,1,0.5)
	shape:setPenSize(2)
	shape:setMask(ui.maskshp)
	minimapcomp:addChild(shape)
	minimapimglist = F3DDisplayContainer:new()
	minimapcomp:addChild(minimapimglist)
	minimapmeimg = F3DImage:new()
	minimapmeimg:setTextureFile(UIPATH.."公用/radar/icon_radar_me.png")
	minimapmeimg:setPivot(0.5,0.5)
	minimapcomp:addChild(minimapmeimg)
	if m_mapurl ~= "" then
		minimapimg:setTextureFile(m_mapurl, g_mapPriority)
	end
	if m_mapid ~= 0 then
		minimapcombo:setTitleText(txt(地图表.Config[m_mapid].name..m_threadname))
		minimapcombo:getList():removeAllItems()
		for i=1,m_threadcnt do
			local cb = F3DCheckBox:new()
			if g_mobileMode then
				cb:setTitleFont("宋体,15")
				cb:setHeight(24)
			else
				cb:setHeight(20)
			end
			cb:setTitleText(txt(地图表.Config[m_mapid].name.."["..i.."线]"))
			minimapcombo:getList():addItem(cb)
		end
	end
	enemycont = F3DDisplayContainer:new()
	minimapcomp:addChild(enemycont)
	ui.quit = ui:findComponent("Tuichu")
	ui.quit:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
		消息框UI1.initUI()
		消息框UI1.setData(txt("是否确定退出副本?(退出后无法进入)"), onQuit)
	end))
	ui.hangup = ui:findComponent("Button_Hangup")
	ui.hanguptxt1 = ui:findComponent("WordArt_Hangup01")
	ui.hanguptxt1:setTouchable(false)
	ui.hanguptxt2 = ui:findComponent("WordArt_Hangup02")
	ui.hanguptxt2:setTouchable(false)
	ui.hangup:addEventListener(F3DMouseEvent.CLICK, func_me(function (e)
if 游戏设置.HANGUPPAY>=0 and 角色逻辑.m_总充值>=游戏设置.HANGUPPAY then
if math.floor(地图表.Config[g_mapid].nodrug/10)%10~=1 then
		技能逻辑.autoUseSkill = not 技能逻辑.autoUseSkill
		CheckHandup()
else
主界面UI.showTipsMsg(1,txt("当前地图禁止挂机"))
end
elseif 游戏设置.HANGUPPAY>0 then
主界面UI.showTipsMsg(1,txt("总充值未达到#cffff00,"..游戏设置.HANGUPPAY.."元#C无法开启挂机"))
else
主界面UI.showTipsMsg(1,txt("当前游戏不支持挂机"))
end
	end))
	ui.精简1 = ui:findComponent("精简1")
	ui.精简1:setTouchable(false)
	ui.精简1:setVisible(not m_simpleMode)
	ui.精简 = ui:findComponent("精简") --有
	ui.精简:addEventListener(F3DMouseEvent.CLICK, func_me(function (e)--有
		m_simpleMode = not m_simpleMode---有
		F3DSoundManager:instance():playSound("/res/sound/105.mp3")--有
		主界面UI.updateSimpleMode() --有
		ui.精简1:setVisible(not  m_simpleMode)
	end))
	ui.屏蔽声音 = ui:findComponent("img_shield_line")
	ui.屏蔽声音:setTouchable(false)
	ui.屏蔽声音:setVisible(not g_openSound)
	ui.声音 = ui:findComponent("btn_new_sound")
	ui.声音:addEventListener(F3DMouseEvent.CLICK, func_me(function (e)
		setOpenSound(not g_openSound)
		F3DSoundManager:instance():playSound("/res/sound/105.mp3")
		聊天UI.添加文本("",-1,0,"音效开关: "..(g_openSound and "#cff00,开" or "#cff0000,关"))
		ui.屏蔽声音:setVisible(not g_openSound)
	end))
	
if not g_mobileMode and g_mobileMode and ISMIRUI then
		ui.精简:setVisible(false)
		ui.精简1:setVisible(false)
		ui.屏蔽声音:setVisible(false)
		ui.声音:setVisible(false)
	end
	ui.商城 = ui:findComponent("好友")
	ui.商城:addEventListener(F3DMouseEvent.CLICK, func_me(function (e)
		商城UI.toggle()
		--F3DSoundManager:instance():playSound("/res/sound/商城语音.mp3")
	end))
	ui.组队 = ui:findComponent("组队")
	ui.组队:addEventListener(F3DMouseEvent.CLICK, func_me(function (e)
		队伍UI.toggle()
	end))
	ui.背包 = ui:findComponent("邮件")
	ui.背包:addEventListener(F3DMouseEvent.CLICK, func_me(function (e)
		背包UI.toggle()
	end))
	ui.聊天 = ui:findComponent("聊天")
	ui.聊天:addEventListener(F3DMouseEvent.CLICK, func_me(function (e)
		聊天UID.toggle()
	end))	
	ui:findComponent("bg"):setTouchable(false)
	m_init = true
	CheckHandup()
	updateShowQuit()
	updateCurrency()
	updateShape()
	updateEnemyInfo()
	updateSize(g_mapWidth, g_mapHeight)
	updateThreadName()
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
	ui:addEventListener(F3DObjEvent.OBJ_INITED, func_e(onUIInit))
	if ui.setUIPack and USEUIPACK then
		ui:setUIPack(g_mobileMode and UIPATH.."小地图UIm.pack" or UIPATH.."小地图UI.pack")
	else
		ui:setLayout(g_mobileMode and UIPATH.."小地图UIm.layout" or UIPATH.."小地图UI.layout")
	end
end
