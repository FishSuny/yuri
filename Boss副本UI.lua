module(..., package.seeall)

local 全局设置 = require("公用.全局设置")
local 实用工具 = require("公用.实用工具")
local 消息 = require("网络.消息")
local 地图表 = require("配置.地图表")
local 角色逻辑 = require("主界面.角色逻辑")
local 刷新表 = require("配置.刷新表")
local 技能逻辑 = require("技能.技能逻辑")
local 小地图UI = require("主界面.小地图UI")
local 地图UI = require("主界面.地图UI")
local 主界面UI = require("主界面.主界面UI")

m_init = false
m_downposx = 0
m_curpage = 1
m_copyinfo = nil
m_bosscopyinfo = {}
m_tabid = 0
m_selectindex = 1
m_avt = nil
m_bodyid = 0
m_bodyeff = 0
m_tp = 0
m_selectmapid = 0

function setSelectMapID(mapid)
	m_selectmapid = mapid
	update()
end

function setCopyInfo(info)
	m_copyinfo = info
	table.sort(m_copyinfo, SortCopyinfo)
	update()
end

function SortCopyinfo(v1, v2)
	if v1[6] ~= v2[6] then
		return v1[6] < v2[6]
	elseif v1[7] ~= v2[7] then
		return v1[7] < v2[7]
	elseif v1[2] ~= v2[2] then
		return v1[2] < v2[2]
	else
		return false
	end
end

function setTP(tp)
	m_tp = tp
	updateTP()
end

function updateTP()
	if not m_init then
		return
	end
	ui.我的体力:setTitleText(txt("我的体力: ")..m_tp.." / 500")
end

function updateCnt()
	if not m_init then
		return
	end
	ui.刷新次数:setTitleText(角色逻辑.m_刷新BOSS次数.." / "..角色逻辑.m_vip等级)
end

function update()
	if not m_init or m_copyinfo == nil then
		return
	end
	local selectindex = 0
	if m_selectmapid ~= 0 then
		for i,v in ipairs(m_copyinfo) do
			if v[2] == m_selectmapid then
				m_tabid = v[1]
				ui.tab:setSelectIndex(m_tabid)
				selectindex = i
				m_selectindex = i
				break
			end
		end
		m_selectmapid = 0
	end
	m_bosscopyinfo = {}
	for i,v in ipairs(m_copyinfo) do
		if v[1] == m_tabid then
			m_bosscopyinfo[#m_bosscopyinfo+1] = v
			if i == selectindex then
				m_curpage = math.ceil(#m_bosscopyinfo / 5)
			end
		end
	end
	local index = (m_curpage-1)*5
	for i=1,5 do
		local v = m_bosscopyinfo[index+i]
		if v then
			local conf = 地图表.Config[v[2]]
			ui.copyscenes[i]:setVisible(true)
			ui.copyscenes[i].head:setBackground(全局设置.getBossIconUrl(v[3]))
			ui.copyscenes[i].name:setTitleText(txt(v[5]).." LV: "..v[7])
			ui.copyscenes[i].zhanli:setTitleText(txt("BOSS战力: ")..v[6])
			ui.copyscenes[i].ditu:setTitleText(txt("所在地图: "..conf.name.."("..conf.level.."级)"))
			ui.copyscenes[i].chuan:setVisible(false)
			local dead = v[8]~=0
			ui.copyscenes[i].zhezhao:setVisible(dead or 角色逻辑.m_level < conf.level)
			ui.copyscenes[i].dead:setVisible(dead)
			ui.copyscenes[i].fenge0:setVisible(dead)
			ui.copyscenes[i].fenge1:setVisible(dead)
			ui.copyscenes[i].shi:setVisible(dead)
			ui.copyscenes[i].fen:setVisible(dead)
			ui.copyscenes[i].miao:setVisible(dead)
			if dead then
				实用工具.setClipNumber(math.floor(v[9]/(1000*60*60)), ui.copyscenes[i].shipic, true, true)
				实用工具.setClipNumber(math.floor(v[9]/(1000*60))%60, ui.copyscenes[i].fenpic, true, true)
				实用工具.setClipNumber(math.floor(v[9]/(1000))%60, ui.copyscenes[i].miaopic, true, true)
			end
		else
			ui.copyscenes[i]:setVisible(false)
		end
	end
	if m_selectindex < (m_curpage-1)*5+1 or m_selectindex > (m_curpage-1)*5+5 then
		m_selectindex = (m_curpage-1)*5+1
	end
	if m_bosscopyinfo[m_selectindex] then
		ui.xuanzhong:setVisible(true)
		ui.xuanzhong:setPositionX(ui.copyscenes[m_selectindex-(m_curpage-1)*5]:getPositionX()-1)
		ui.xuanzhong:setPositionY(ui.copyscenes[m_selectindex-(m_curpage-1)*5]:getPositionY()-1)
		selectBossInfo(m_bosscopyinfo[m_selectindex])
	else
		ui.xuanzhong:setVisible(false)
		selectBossInfo(nil)
	end
	local totalpage = math.ceil(#m_bosscopyinfo / 5)
	ui.page_cur:setTitleText(m_curpage.." / "..totalpage)
end

function selectBossInfo(bossinfo)
	if not m_init or m_copyinfo == nil or bossinfo == nil then
		return
	end
	if not m_avt then
if IS3G then
			m_avt = F3DImageAnim3D:new()
			m_avt:setImage2D(true)
		else
			m_avt = F3DRole:new()
		end
		ui.rolecont:addChild(m_avt)
	end
	local conf = 地图表.Config[bossinfo[2]]
	local dead = bossinfo[8]~=0
	if bossinfo == nil then
		m_avt:reset()
		m_bodyid = 0
		m_bodyeff = 0
	elseif m_bodyid ~= bossinfo[3] or m_bodyeff ~= bossinfo[4] then
		m_avt:reset()
		if ISMIR2D then
			if IS3G and bossinfo[3] == 3007 then
				m_avt:setScaleX(0.7)
				m_avt:setScaleY(0.7)
			else
				m_avt:setScaleX(1)
				m_avt:setScaleY(1)
			end
			m_avt:setEntity(F3DImageAnim3D.PART_BODY, 全局设置.getAnimPackUrl(bossinfo[3]))
			if bossinfo[3] > 0 and bossinfo[3] < 1000 then
				m_avt:setEntity(F3DImageAnim3D.PART_HAIR, 全局设置.getMirHairUrl(全局设置.武神外观[bossinfo[3]][1]))
				m_avt:setEntity(F3DImageAnim3D.PART_WEAPON, 全局设置.getAnimPackUrl(全局设置.武神外观[bossinfo[3]][4]))
				if 全局设置.武神外观[bossinfo[3]][3] ~= 0 then
					m_avt:setEntity(F3DImageAnim3D.PART_BODY_EFFECT, 全局设置.getAnimPackUrl(全局设置.武神外观[bossinfo[3]][3])):setBlendType(F3DRenderContext.BLEND_ADD)
				end
				if 全局设置.武神外观[bossinfo[3]][5] ~= 0 then
					m_avt:setEntity(F3DImageAnim3D.PART_WEAPON_EFFECT, 全局设置.getAnimPackUrl(全局设置.武神外观[bossinfo[3]][5])):setBlendType(F3DRenderContext.BLEND_ADD)
				end
			end
		else
			m_avt:setShowShadow(true)
			m_avt:setLighting(true)
			m_avt:setEntity(F3DAvatar.PART_BODY, 全局设置.getMonsterUrl(bossinfo[3]))
			m_avt:setAnimSet(F3DUtils:trimPostfix(全局设置.getMonsterUrl(bossinfo[3]))..".txt")
			if bossinfo[4] ~= 0 then
				m_avt:setEffectSystem(全局设置.getEffectUrl(bossinfo[4]), true)
			end
		end
		m_bodyid = bossinfo[3]
		m_bodyeff = bossinfo[4]
	end
if not IS3G then
		m_avt:setShowGray(dead or 角色逻辑.m_level < conf.level)
	end
	ui.bossname:setTitleText(txt(bossinfo[5]).." LV: "..bossinfo[7])
	ui.bossdead:setVisible(bossinfo[8]==1)
	ui.bossiskilled:setVisible(bossinfo[8]==2)
	ui.bosslock:setVisible(角色逻辑.m_level < conf.level)
	if #conf.costtp == 1 then
		ui.bosstili:setTitleText(txt("消耗体力：")..conf.costtp[1])
	else
		ui.bosstili:setTitleText("")
	end
end

function onTabChange(e)
	m_tabid = ui.tab:getSelectIndex()
	m_curpage = 1
	m_selectindex = 1
	update()
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

function onUIInit()
	ui.close = ui:findComponent("titlebar,close")
	ui.close:addEventListener(F3DMouseEvent.CLICK, func_me(onClose))
	ui:addEventListener(F3DMouseEvent.MOUSE_DOWN, func_me(onMouseDown))
	ui.copyscenes = {}
	for i=1,5 do
		ui.copyscenes[i] = ui:findComponent("img_boss_item_"..i)
		ui.copyscenes[i].id = i
		ui.copyscenes[i]:addEventListener(F3DMouseEvent.MOUSE_DOWN, func_me(function(e)
			local btn = e:getCurrentTarget()
			if btn and m_copyinfo and m_bosscopyinfo[(m_curpage-1)*5+btn.id] then
				m_selectindex = (m_curpage-1)*5+btn.id
				ui.xuanzhong:setPositionX(btn:getPositionX()-1)
				ui.xuanzhong:setPositionY(btn:getPositionY()-1)
				selectBossInfo(m_bosscopyinfo[m_selectindex])
			end
		end))
		ui.copyscenes[i].head = ui:findComponent("img_boss_item_"..i..",head")
		ui.copyscenes[i].name = ui:findComponent("img_boss_item_"..i..",name")
		ui.copyscenes[i].zhanli = ui:findComponent("img_boss_item_"..i..",zhanli")
		ui.copyscenes[i].ditu = ui:findComponent("img_boss_item_"..i..",ditu")
		ui.copyscenes[i].grid_1 = ui:findComponent("img_boss_item_"..i..",gridBg_1")
		ui.copyscenes[i].grid_2 = ui:findComponent("img_boss_item_"..i..",gridBg_2")
		ui.copyscenes[i].grid_3 = ui:findComponent("img_boss_item_"..i..",gridBg_3")
		ui.copyscenes[i].grid_4 = ui:findComponent("img_boss_item_"..i..",gridBg_4")
		ui.copyscenes[i].qianwang = ui:findComponent("img_boss_item_"..i..",qianwang")
		ui.copyscenes[i].qianwang.id = i
		ui.copyscenes[i].qianwang:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
			local btn = e:getCurrentTarget()
			if btn and m_copyinfo and m_bosscopyinfo[(m_curpage-1)*5+btn.id] then
if m_tabid==1 or m_tabid==3 then
					resetMovePoint()
					消息.CG_ENTER_COPYSCENE(m_bosscopyinfo[(m_curpage-1)*5+btn.id][2], 1)
					g_targetPos.bodyid = 0
					setMainRoleTarget(nil)
elseif m_tabid==0 or m_tabid==2 then
					resetMovePoint()
					local mapid = m_bosscopyinfo[(m_curpage-1)*5+btn.id][2]
					消息.CG_TRANSPORT(mapid, -1, -1)
					g_targetPos.bodyid = 0
					setMainRoleTarget(nil)
				else
					for i,v in ipairs(刷新表.Config) do
						if v.mapid == m_bosscopyinfo[(m_curpage-1)*5+btn.id][2] and v.name == m_bosscopyinfo[(m_curpage-1)*5+btn.id][5] then
							地图UI.moveToMap(v.mapid, v.bornpos[1], v.bornpos[2])
							break
						end
					end
				end
			end
		end))
		ui.copyscenes[i].chuan = ui:findComponent("img_boss_item_"..i..",chuan")
		ui.copyscenes[i].chuan.id = i
		ui.copyscenes[i].chuan:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
			local btn = e:getCurrentTarget()
			if btn and m_copyinfo and m_bosscopyinfo[(m_curpage-1)*5+btn.id] then
				for i,v in ipairs(刷新表.Config) do
					if v.mapid == m_bosscopyinfo[(m_curpage-1)*5+btn.id][2] and v.name == m_bosscopyinfo[(m_curpage-1)*5+btn.id][5] then
						resetMovePoint()
						消息.CG_TRANSPORT(v.mapid, v.bornpos[1], v.bornpos[2])
						g_targetPos.bodyid = 0
						setMainRoleTarget(nil)
						break
					end
				end
			end
		end))
		ui.copyscenes[i].tiaojian = ui:findComponent("img_boss_item_"..i..",tiaojian")
		ui.copyscenes[i].tiaojian:setVisible(false)
		ui.copyscenes[i].zhezhao = ui:findComponent("img_boss_item_"..i..",zhezhao")
		ui.copyscenes[i].dead = ui:findComponent("img_boss_item_"..i..",dead")
		ui.copyscenes[i].fenge0 = ui:findComponent("img_boss_item_"..i..",img_semicolon")
		ui.copyscenes[i].fenge1 = ui:findComponent("img_boss_item_"..i..",img_semicolon_1")
		ui.copyscenes[i].shi = ui:findComponent("img_boss_item_"..i..",shi")
		ui.copyscenes[i].shipic = ui.copyscenes[i].shi:getBackground()
		ui.copyscenes[i].fen = ui:findComponent("img_boss_item_"..i..",fen")
		ui.copyscenes[i].fenpic = ui.copyscenes[i].fen:getBackground()
		ui.copyscenes[i].miao = ui:findComponent("img_boss_item_"..i..",miao")
		ui.copyscenes[i].miaopic = ui.copyscenes[i].miao:getBackground()
	end
	ui.page_cur = ui:findComponent("page_cur")
	ui.page_pre = ui:findComponent("page_pre")
	ui.page_pre:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
		if not m_copyinfo then
			return
		end
		local totalpage = math.ceil(#m_bosscopyinfo / 5)
		if m_curpage > 1 then
			m_curpage = math.max(1, m_curpage - 1)
			update()
		end
	end))
	ui.page_next = ui:findComponent("page_next")
	ui.page_next:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
		if not m_copyinfo then
			return
		end
		local totalpage = math.ceil(#m_bosscopyinfo / 5)
		if m_curpage < totalpage then
			m_curpage = math.min(totalpage, m_curpage + 1)
			update()
		end
	end))
	ui.tab = tt(ui:findComponent("tab_1"), F3DTab)
	ui.tab:addEventListener(F3DUIEvent.CHANGE, func_me(onTabChange))
	ui.xuanzhong = ui:findComponent("xuanzhong")
	ui.xuanzhong:setTouchable(false)
	ui.rolecont = ui:findComponent("img_right_boss_bg,rolecont")
	ui.rolerect = ui:findComponent("img_right_boss_bg,rolerect")
	ui.rolerect:addEventListener(F3DMouseEvent.MOUSE_DOWN, func_me(function (e)
		if m_avt then
			m_downposx = e:getStageX()
		end
	end))
	ui.rolerect:addEventListener(F3DMouseEvent.MOUSE_MOVE, func_me(function (e)
		if m_avt then
if IS3G then
				m_avt:setAnimRotationZ(m_avt:getAnimRotationZ()+e:getStageX()-m_downposx)
			else
				m_avt:setRotationZ(m_avt:getRotationZ()+e:getStageX()-m_downposx)
			end
			m_downposx = e:getStageX()
		end
	end))
	ui.bossname = ui:findComponent("img_right_boss_bg,name")
	ui.bossdead = ui:findComponent("img_right_boss_bg,dead")
	ui.bossiskilled = ui:findComponent("img_right_boss_bg,iskilled")
	ui.bosslock = ui:findComponent("img_right_boss_bg,lock")
	ui.bosstili = ui:findComponent("img_right_boss_bg,tili")
	ui.我的体力 = ui:findComponent("component_2")
	ui:findComponent("刷新BOSS"):addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
		消息.CG_REFLESH_BOSS()
	end))
	ui.刷新次数 = ui:findComponent("刷新次数")
	ui.自动挑战BOSS = tt(ui:findComponent("自动挑战BOSS"),F3DCheckBox)
	ui.自动挑战武神殿 = tt(ui:findComponent("自动挑战武神殿"),F3DCheckBox)
	ui.掉落提示 = ui:findComponent("掉落提示")
	ui.掉落提示:setVisible(false)
	m_init = true
	update()
	updateTP()
	updateCnt()
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
		if m_avt then
if IS3G then
				m_avt:setAnimRotationZ(0)
			else
				m_avt:setRotationZ(0)
			end
		end
_v_62(ui,true)
		return
	end
	ui = F3DLayout:new()
	uiLayer:addChild(ui)
	ui:setLoadPriority(getUIPriority())
	ui:setMovable(true)
	ui:addEventListener(F3DObjEvent.OBJ_INITED, func_e(onUIInit))
if ui.setUIPack and USEUIPACK then
ui:setUIPack(g_mobileMode and UIPATH.."Boss副本UIm.pack"or UIPATH.."Boss副本UI.pack")
else
	ui:setLayout(g_mobileMode and UIPATH.."Boss副本UIm.layout" or UIPATH.."Boss副本UI.layout")
end
_v_62(ui,true)
end
