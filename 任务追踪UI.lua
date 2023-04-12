module(..., package.seeall)

local 全局设置 = require("公用.全局设置")
local 游戏设置 = require("公用.游戏设置")
local 实用工具 = require("公用.实用工具")
local 消息 = require("网络.消息")
local 地图表 = require("配置.地图表")
local 技能逻辑 = require("技能.技能逻辑")
local 地图UI = require("主界面.地图UI")
local 角色逻辑 = require("主界面.角色逻辑")
local 个人副本UI = require("主界面.个人副本UI")
local Boss副本UI = require("主界面.Boss副本UI")
local 小地图UI = require("主界面.小地图UI")
local 聊天UI = require("主界面.聊天UI")

m_init = false
m_autoDoTask = true
m_info = nil
m_query = false
m_doTask = nil
m_copyinfo = info

function setCopySceneInfo(info, time, leftcnt, totalcnt)
	m_copyinfo = info
	updateCopyInfo()
end

function updateCopyInfo()
	if not m_init or m_copyinfo == nil then
		return
	end
	local str = ""
	for i,v in ipairs(m_copyinfo) do
		local name = txt(v[2])
		local color = v[2] == 角色逻辑.m_rolename and "38BB41" or (v[8] ~= 0 and v[8] == 角色逻辑.m_teamid) and "38BB41" or "ffffff"
		str = str.."#c"..color..","..v[2]..string.rep(" ",20 - name:len()).."#cffff00,等级"..v[3].."  #cff0000,杀敌"..v[4].."#C#n"
	end
	if str == "" then str = " " end
	ui.tasktxt:setTitleText(txt(str))
	ui:setVisible(str ~= "" and str ~= " ")----
end

function SortInfo(v1, v2)
	if v1[7] ~= v2[7] then
		return v1[7] < v2[7]
	elseif v1[3] ~= v2[3] then
		return v1[3] < v2[3]
	else
		return false
	end
end

function setTaskInfo(info, query)
	m_info = info
	table.sort(m_info, SortInfo)
	m_query = query
	update()
end

function update()
if not m_init or m_info==nil or not g_role then
		return
	end
	m_doTask = nil
	local str = ""
	local linecnt = g_mobileMode and math.floor((ui:getWidth()-20)/9) or math.floor((ui:getWidth()-20)/6)
	local lcnt = 0
	local fontsize = g_mobileMode and "#s"..(游戏设置.TASKFONTSIZE and 游戏设置.TASKFONTSIZE[3] or 24)..",#s"..(游戏设置.TASKFONTSIZE and 游戏设置.TASKFONTSIZE[4] or 18).."," or "#s"..(游戏设置.TASKFONTSIZE and 游戏设置.TASKFONTSIZE[1] or 16)..",#s"..(游戏设置.TASKFONTSIZE and 游戏设置.TASKFONTSIZE[2] or 12)..","
	local sss,lc
	for i,v in ipairs(m_info) do
if v[3]==-1 then
if v[2]~=""then
sss,lc=聊天UI.trimText(txt(v[2]),linecnt)
str=str..fontsize..sss.."#n"
lcnt=lcnt+lc
end
else
		local typestr = v[7] == 0 and "主线" or v[7] == 1 and "支线" or v[7] == 2 and "日常" or v[7] == 3 and "悬赏" or v[7] == 4 and "押镖" or v[7] == 5 and "灵兽" or v[7] == 6 and "采集" or ""
		sss,lc = 聊天UI.trimText("#cEB7B29"..txt(",【"..typestr.."】")..(g_role.level < v[5] and "#cff0000," or "#cff00,")..txt(v[1]..(v[7] > 1 and "("..v[8].."/"..v[9]..")" or "")..(g_role.level < v[5] and "("..v[5].."级)" or v[4]==0 and "(可接)" or v[4]==2 and "(可交)" or "")).."#C", linecnt)
		str = str..fontsize..sss.."#n"
		lcnt = lcnt + lc
		if v[4] == 0 or v[4] == 2 then
			local conf = v[6][1]
			local link = conf[3]..":"..conf[4]..":"..conf[5]..":"..conf[6]..":"..v[3]
			if not m_doTask and v[7] == 0 and g_role.level >= v[5] then
				m_doTask = {1, conf[3], conf[4], conf[5], conf[6], v[3]}
			end
			if m_autoDoTask and m_query == 0 then
				autoDoTask()
			end
			local ss
			if conf[3] == -1 then
				ss = "  点击查看#lc0000ff:1:"..link..",#cffff00,#u".."任务描述".."#L#U#C"
			else
				ss = "  前往#lc0000ff:1:"..link..",#cffff00,#u"..地图表.Config[conf[3]].name.."#L#U#C寻找#lc0000ff:1:"..link..",#cff0000,#u"..conf[2].."#L#U#C"
			end
			sss,lc = 聊天UI.trimText(txt(ss), linecnt)
			str = str..fontsize..sss.."#n"
			lcnt = lcnt + lc
		elseif v[4] == 1 then
			for ii,vv in ipairs(v[6]) do
				local s = (vv[1] == 1 or vv[1] == 4 or vv[1] == 6) and "消灭" or vv[1] == 5 and "通关" or vv[1] == 2 and "采集" or "收集"
				local link = vv[3]..":"..vv[4]..":"..vv[5]..":"..vv[6]..":"..v[3]
				if not m_doTask and v[7] == 0 and g_role.level >= v[5] then
					m_doTask = {1, vv[3], vv[4], vv[5], vv[6], v[3]}
				end
				if m_autoDoTask and m_query == 0 then
					autoDoTask()
				end
				local ss
				if vv[1] == 5 then
					ss = "  "..s.."#lc0000ff:1:"..link..",#cff0000,#u"..vv[2].."#L#U"
				elseif vv[3] == 0 then
					ss = "  "..s.."#lc0000ff:1:"..link..",#cff0000,#u"..vv[2].."#L#U#cffff00,("..vv[7].."/"..vv[8]..")#C"
				elseif vv[1] == 6 then
					ss = "  前往#lc0000ff:1:"..link..",#cffff00,#u"..地图表.Config[vv[3]].name.."#L#U#C"..s.."#lc0000ff:1:"..link..",#cff0000,#u任意怪物#L#U#cffff00,("..vv[7].."/"..vv[8]..")#C"
				else
					ss = "  前往#lc0000ff:1:"..link..",#cffff00,#u"..地图表.Config[vv[3]].name.."#L#U#C"..s.."#lc0000ff:1:"..link..",#cff0000,#u"..vv[2].."#L#U#cffff00,("..vv[7].."/"..vv[8]..")#C"
				end
				sss,lc = 聊天UI.trimText(txt(ss), linecnt)
				str = str..fontsize..sss.."#n"
				lcnt = lcnt + lc
			end
		end
		if v[2] ~= "" then
			sss,lc = 聊天UI.trimText("  "..txt(v[2]), linecnt)
			str = str..fontsize..sss.."#n"
			lcnt = lcnt + lc
		end
	end
end
	if str == "" then str = " " end
	ui.tasktxt:setTitleText(str)
	ui.tasktxt:setHeight(g_mobileMode and (lcnt*26+10) or (lcnt*18+10))
	ui.view:updateContentArea()
	ui:setVisible(str ~= "" and str ~= " ")
end

function autoDoTask()
	if m_doTask then
		onAutoTask(m_doTask[1], m_doTask[2], m_doTask[3], m_doTask[4], m_doTask[5], m_doTask[6])
	end
end

function onLinkDown(e)
	local str = ui.tasktxt:getCurrLinkSrc()
	local strs = 实用工具.SplitString(str, ":", true)
	local t, mapid, x, y, bodyid, taskid = tonumber(strs[1]), tonumber(strs[2]), tonumber(strs[3]), tonumber(strs[4]), tonumber(strs[5]), tonumber(strs[6])
	onAutoTask(t, mapid, x, y, bodyid, taskid)
end

function onAutoTask(t, mapid, x, y, bodyid, taskid)
if t<0 then
消息.CG_NPC_TALK(t,mapid)
elseif mapid==-1 then
		消息.CG_NPC_TALK(-1, taskid)
	elseif mapid == 0 or not 地图表.Config[mapid] then
	elseif g_mapid ~= mapid and 地图表.Config[mapid].maptype > 0 then
		if 地图表.Config[mapid].maptype == 5 then
			消息.CG_ENTER_COPYSCENE(mapid, 1)
		elseif 地图表.Config[mapid].maptype == 3 then
			Boss副本UI.setSelectMapID(mapid)
			Boss副本UI.initUI()
		else
			个人副本UI.setSelectMapID(mapid)
			个人副本UI.initUI()
		end
	elseif t == 1 then
		if checkRoleDist(mapid, x, y) then
			g_targetPos.bodyid = bodyid
			setMainRoleTarget(nil)
			if 游戏设置.HANGUPPAY>=0 and 角色逻辑.m_总充值>=游戏设置.HANGUPPAY then
				if math.floor(地图表.Config[g_mapid].nodrug/10)%10 ~= 1 then
					技能逻辑.autoUseSkill = true
					小地图UI.CheckHandup()
				end
			end
			doRoleLogic()
		else
			地图UI.moveToMap(mapid, x, y)
			g_targetPos.bodyid = bodyid
		end
	else
		消息.CG_TRANSPORT(mapid, x, y)
		g_targetPos.bodyid = bodyid
		setMainRoleTarget(nil)
if 游戏设置.HANGUPPAY>=0 and 角色逻辑.m_总充值>=游戏设置.HANGUPPAY then
			if math.floor(地图表.Config[g_mapid].nodrug/10)%10 ~= 1 then
				技能逻辑.autoUseSkill = true
				小地图UI.CheckHandup()
			end
		end
	end
end

function onClick(e)
	if m_doTask then
		onAutoTask(m_doTask[1], m_doTask[2], m_doTask[3], m_doTask[4], m_doTask[5], m_doTask[6])
	end
end

function onUIInit()
	ui.view = tt(ui:findComponent("view_1"),F3DView)
	ui.view:getVScroll():setPercent(0)
	ui.view:addEventListener(F3DMouseEvent.CLICK, func_me(onClick))
	ui.tasktxt = tt(ui:findComponent("view_1,content,tasktxt"),F3DRichTextField)
	ui.tasktxt:addEventListener(F3DUIEvent.LINK_DOWN, func_ue(onLinkDown))
if 游戏设置.HIDETASKTRACE==1 or 游戏设置.HIDETASKTRACE==2 then
if ui:findComponent("task_titleBg")then
ui:findComponent("task_titleBg"):setVisible(false)
end
if ui:findComponent("view_1,vscroll")then
ui:findComponent("view_1,vscroll"):setVisible(false)
end
ui:setBackground("")
ui:setTouchable(游戏设置.HIDETASKTRACE~=2)
end
	ui:setVisible(false)
	m_init = true
	update()
	updateCopyInfo()
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
		ui:updateParent()
		ui:setVisible(true)
		return
	end
	ui = F3DLayout:new()
	uiLayer:addChild(ui)
--	ui:setLoadPriority(getUIPriority())
	ui:addEventListener(F3DObjEvent.OBJ_INITED, func_e(onUIInit))
	if ui.setUIPack and USEUIPACK then
ui:setUIPack(g_mobileMode and UIPATH.."任务追踪UIm.pack"or UIPATH.."任务追踪UI.pack")
else
ui:setLayout(g_mobileMode and UIPATH.."任务追踪UIm.layout" or ISMIRUI and UIPATH.."任务追踪UI.layout" or UIPATH.."任务追踪UIs.layout")
end
	
end
