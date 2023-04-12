module(..., package.seeall)

local 全局设置 = require("公用.全局设置")
local 消息 = require("网络.消息")
local 角色逻辑 = require("主界面.角色逻辑")
local 图鉴表 = require("配置.图鉴表").Config
local 实用工具 = require("公用.实用工具")
local 游戏设置 = require("公用.游戏设置")

图鉴数量记录 = {}
图鉴位置记录 = {}
图鉴重组 = {}

累计数量 = {10,30,60,100,150,210,280,360}
图鉴等级需求数量表 = {10,30,60,100,150,210,280,360,450,550,660,999999}


图鉴位置记录 = {}
图鉴重组 = {}
for n = 1 , #图鉴表 do
	if (图鉴重组[图鉴表[n].类型] == nil) then
		图鉴重组[图鉴表[n].类型] = {}
	end
	图鉴重组[图鉴表[n].类型][#图鉴重组[图鉴表[n].类型] + 1] = 图鉴表[n]
	图鉴重组[图鉴表[n].类型][#图鉴重组[图鉴表[n].类型]].id = n
	图鉴重组[图鉴表[n].类型][#图鉴重组[图鉴表[n].类型]].数量 = 0
	图鉴位置记录[n] = {图鉴表[n].类型,#图鉴重组[图鉴表[n].类型]}
end

function 图鉴表刷新()
	图鉴位置记录 = {}
	图鉴重组 = {}
	for n = 1 , #图鉴表 do
		if (图鉴重组[图鉴表[n].类型] == nil) then
			图鉴重组[图鉴表[n].类型] = {}
		end
		
		if 角色逻辑.m_level >= 图鉴表[n].显示等级 then
			图鉴重组[图鉴表[n].类型][#图鉴重组[图鉴表[n].类型] + 1] = 图鉴表[n]
			图鉴重组[图鉴表[n].类型][#图鉴重组[图鉴表[n].类型]].id = n
			图鉴重组[图鉴表[n].类型][#图鉴重组[图鉴表[n].类型]].数量 = 0
			图鉴位置记录[n] = {图鉴表[n].类型,#图鉴重组[图鉴表[n].类型]}
		end
	end
	update()
end

图鉴类型 = 1
图鉴分页 = 1
m_init = false
m_curpage = 1
m_mallinfo = nil
m_selectitem = nil
m_itemdata = nil
tipsui = nil
tipsgrid = nil
图鉴展示组 = {}
人物图鉴记录组 = {}
图鉴总体加成 = {}
玩家性别 = 1
使用外观组 = {}
染色使用外观组 = {}

允许等级加成属性 = {
[1] = 1,
[7] = 1,
[8] = 1,
[9] = 1,
[10] = 1,
[11] = 1,
[12] = 1,
}

function 使用更新(图鉴)
	使用外观组 = 图鉴
	update()
end

function 图鉴更新(图鉴,类型)
	if (类型 == 0) then
		for n = 1 , #图鉴 do
			图鉴数量记录[图鉴[n][1]] = 图鉴[n][2]
		end
	else
		图鉴数量记录[类型] = 图鉴[1][2]
	end
	update()	
end

function update()
	if not ui then
		return
	end
	图鉴重组[图鉴类型] = 图鉴重组[图鉴类型] or {}
	for n = 1 , 10 do
		if not 图鉴展示组[n] then
			图鉴展示组[n] = F3DImageAnim3D:new()
			图鉴展示组[n]:setImage2D(true)
			图鉴展示组[n]:setPositionY(-25)
			ui.rolecont[n]:addChild(图鉴展示组[n])
		end
		
		图鉴展示组[n]:reset()
		图鉴展示组[n]:setScaleX(1)
		图鉴展示组[n]:setScaleY(1)
		if (图鉴重组[图鉴类型][n + (图鉴分页 - 1) * 10] == nil) then
			图鉴展示组[n]:setVisible(false)
			ui.按钮[n]:setVisible(false)
			ui.name[n]:setTitleText("")
		else
			图鉴展示组[n]:setVisible(true)
			
			ui.name[n]:setTitleText(txt(图鉴重组[图鉴类型][n + (图鉴分页 - 1) * 10].name))
			if 图鉴重组[图鉴类型][n + (图鉴分页 - 1) * 10].获得方式 == "未开放获取" then
				ui.name[n]:setTextColor(全局设置.colorRgbVal[1])
			else
				ui.name[n]:setTextColor(全局设置.colorRgbVal[2])
			end
			
			local 图鉴外观 = 图鉴重组[图鉴类型][n + (图鉴分页 - 1) * 10].外观
			if 图鉴重组[图鉴类型][n + (图鉴分页 - 1) * 10].性别 == 1 and 角色逻辑.m_rolesex == 2 then
				图鉴外观 = 图鉴外观 + 1
			end
			图鉴展示组[n]:setEntity(F3DImageAnim3D.PART_BODY, 全局设置.getAnimPackUrl(图鉴外观))
			
			--if 图鉴类型 == 5 then
			--	图鉴展示组[n]:setBlendType(1)
			--	图鉴展示组[n]:setScaleX(0.75)
			--	图鉴展示组[n]:setScaleY(0.75)
			--else
			--	图鉴展示组[n]:setBlendType(0)
			--	图鉴展示组[n]:setScaleX(1)
			--	图鉴展示组[n]:setScaleY(1)
			--end
			
			if (图鉴类型 == 3) then
				图鉴展示组[n]:setAnimName("idle")
				图鉴展示组[n]:setAnimRotationZ(45)
			elseif (图鉴类型 == 1) then
				图鉴展示组[n]:setAnimName("idle")
				图鉴展示组[n]:setAnimRotationZ(-90)
			else
				图鉴展示组[n]:setAnimName("idle")
				图鉴展示组[n]:setAnimRotationZ(0)
				
			end
			
		--	print(图鉴重组[图鉴类型][n + (图鉴分页 - 1) * 10].name)
		--	print(图鉴重组[图鉴类型][n + (图鉴分页 - 1) * 10].id)
		--	实用工具.PrintTable(人物图鉴记录组)
			local 目标组 = 图鉴重组[图鉴类型][n + (图鉴分页 - 1) * 10]
		--	print(目标组.数量)
			ui.按钮[n]:setVisible(true)
			if (目标组.数量 == 0) then
				--ui.按钮[n]:setVisible(false)
				ui.按钮[n]:setTitleText(txt("未激活"))
				ui.按钮[n]:setTextColor(全局设置.colorRgbVal[1])
			else
				
				local 目标数量 = 图鉴数量记录[目标组.id] or 0
				local 养成等级 = 0
				
				for j = 1 , #图鉴等级需求数量表 do
					if 目标数量 <图鉴等级需求数量表[j]  then
						养成等级 = j - 1
						break
					end
				end
			
				local 显示文字 = ""
				if (养成等级 >= 目标组.等级上限) then
					养成等级 = 目标组.等级上限
					显示文字 = "\n已激活"
				elseif (养成等级 == 0) then
					显示文字 = "["..目标组.数量.."/"..(养成等级 * 10 + 10) .."]"
				else
					
					显示文字 = "\n"..养成等级.."级["..目标组.数量 .."/"..(图鉴等级需求数量表[养成等级 + 1]) .."]" --- 图鉴等级需求数量表[养成等级] -- + 1
				end
				
				if (养成等级 == 0) then
					ui.按钮[n]:setTitleText(txt("未激活"..显示文字))
					ui.按钮[n]:setTextColor(全局设置.colorRgbVal[1])
				else
					if (使用外观组[目标组.类型] == nil or 使用外观组[目标组.类型] == 0 or 使用外观组[目标组.类型] ~= 图鉴表[目标组.id].外观) then
						ui.按钮[n]:setTitleText(txt(" 使用此外观"))	--..显示文字
						ui.按钮[n]:setTextColor(全局设置.colorRgbVal[2])
					else
						ui.按钮[n]:setTitleText(txt("取消外观使用"))	--..显示文字
						ui.按钮[n]:setTextColor(全局设置.colorRgbVal[4])
					end
				end
				
				if (养成等级 ~= 0 and 目标组.是否可用 == 0) then
					ui.按钮[n]:setTitleText(txt("已收集"..显示文字))
					ui.按钮[n]:setTextColor(全局设置.colorRgbVal[4])
				end
				
			end
			
		end
	end
	
	图鉴总体加成 = {}
	for n = 1 , #图鉴表 do
		
		local 目标位置 = 图鉴位置记录[n]
		
		if ((图鉴数量记录[图鉴位置记录[n]] or 0) >= 1) then
		
			local 目标数量 = 图鉴数量记录[图鉴重组[目标位置[1]][目标位置[2]].id] or 0
			
			if 目标数量 > 10 then
				目标数量 = 10
			end
			for i,v in ipairs(图鉴表[n].prop) do
				--print(v[1],math.floor(v[2] * 目标数量 / 10))
				图鉴总体加成[v[1]] = (图鉴总体加成[v[1]] or 0) + math.floor(v[2] * 目标数量 / 10)
			end
			
			
		end
	end
	
	ui.page_cur:setTitleText(txt(图鉴分页.."/"..math.ceil(#图鉴重组[图鉴类型] / 10)))
	
end

function onClose(e)
	ui:setVisible(false)
	ui.close:releaseMouse()
	--for n = 1 , 10 do
	--	if 图鉴展示组[n] then
		--	图鉴展示组[n]:removeFromParent(true)
		--	图鉴展示组[n] = nil
	--	end
	--end
	e:stopPropagation()
end

function onGridOver(e)
	local g = e:getTarget()
	--g:setVisible(true)
	图鉴重组[图鉴类型] = 图鉴重组[图鉴类型] or {}
	
	if (g ~= nil and g.id == 11) then
		local 显示文字 = ""
		显示文字 = "[我的图鉴加成]\n"
		
		local 头部缩放 = ""
		
		
		local props = {}
		for i,v in pairs(图鉴总体加成) do
		--	print(i,v)
			props[i] = (props[i] or 0) + v
			if i == 4 or i == 6 or i == 8 or i == 10 or i == 12 then
				props[i-1] = (props[i-1] or 0)
			end
		end
		local 头部缩放 = ""
		for _,v in ipairs(全局设置.proptexts) do
			local i = v[2]
			if props[i] then
				if i >= 3 and i <= 12 then
					if i % 2 == 1 then
						local str = props[i].."-"..(props[i+1] or 0)
						显示文字 = 显示文字 .. 头部缩放..全局设置.getPropText(i).." "..str .."\n"
					end
				else
					local str = props[i]..(v[3] and "%" or "")
					显示文字 = 显示文字 .. 头部缩放..全局设置.getPropText(i).." "..str .."\n"
				end
			end
		end
		
		
		显示文字 = 显示文字 .. "\n查看图鉴总加成"
		ui.图鉴总加成:setTitleText(txt(显示文字))
	elseif g ~= nil and 图鉴重组[图鉴类型][g.id + (图鉴分页 - 1) * 10] ~= nil then
		
		g:setBackground("/res/ui/a主界面/透明黑.png")
		
		local 目标组 = 图鉴重组[图鉴类型][g.id + (图鉴分页 - 1) * 10]
		
		local 目标数量 = 图鉴数量记录[目标组.id] or 0
		local 养成等级 = 0
		
		for j = 1 , #图鉴等级需求数量表 do
			if 目标数量 <图鉴等级需求数量表[j]  then
				养成等级 = j - 1
				break
			end
		end
		
		
		local 显示文字 = ""
		if (养成等级 >= 目标组.等级上限) then
			养成等级 = 目标组.等级上限
		end
		local 显示文字 = ""
		if (养成等级 == 0) then
			显示文字 = "[未激活"..目标数量.."/10]\n"
			ui.属性[g.id]:setTextColor(全局设置.colorRgbVal[1])
		else
			显示文字 = "[已激活]\n"	--"..养成等级.."/"..目标组.等级上限.."
			ui.属性[g.id]:setTextColor(全局设置.colorRgbVal[2])
		end
		

		local props = {}
		for i,v in ipairs(图鉴重组[图鉴类型][g.id + (图鉴分页 - 1) * 10].prop) do
			props[v[1]] = (props[v[1]] or 0) + v[2]
			if v[1] == 4 or v[1] == 6 or v[1] == 8 or v[1] == 10 or v[1] == 12 then
				props[v[1]-1] = (props[v[1]-1] or 0)
			end
		end
		local 头部缩放 = ""
		for _,v in ipairs(全局设置.proptexts) do
			local i = v[2]
			if props[i] then
				if i >= 3 and i <= 12 then
					if i % 2 == 1 then
						local str = props[i].."-"..(props[i+1] or 0)
						显示文字 = 显示文字 .. 头部缩放..全局设置.getPropText(i).." "..str
						
						if 目标数量 >= 1 and 目标数量 < 10 then
							显示文字 = 显示文字 .. "(" ..math.floor(props[i] / 10 * 目标数量).."-"..(props[i+1] and math.floor(props[i+1] / 10 * 目标数量) or 0)..")"
						end
						显示文字 = 显示文字 .. "\n"
					end
				else
					local str = props[i]..(v[3] and "%" or "")
					显示文字 = 显示文字 .. 头部缩放..全局设置.getPropText(i).." "..str
					if 目标数量 >= 1 and 目标数量 < 10 then
						显示文字 = 显示文字 .. "(" ..math.floor(props[i] / 10 * 目标数量)..(v[3] and "%" or "")..")"
					end
					显示文字 = 显示文字 .. "\n"
				end
			end
		end
		
		
		
		--if 目标组.期限 == 1 then
			显示文字 = 显示文字 .. 目标组.获得方式
		--end
		
		
		ui.属性[g.id]:setTitleText(txt(显示文字))
		
	end
end
function onGridOut(e)
	local g = e:getTarget()
	if g ~= nil then
		if (g.id == 11) then
			ui.图鉴总加成:setTitleText(txt("查看图鉴总加成"))
		else
			ui.属性[g.id]:setTitleText("")
			g:setBackground("")
			--g:setVisible(false)
		end
	end
end

function onTabChange(e)
	图鉴类型 = ui.tab:getSelectIndex() + 1
	图鉴分页 = 1
	update()
end

function onUIInit()
	ui.rolecont = {}
	ui.name = {}
	ui.按钮 = {}
	ui.属性 = {}
	for n = 1 , 10 do
		ui.rolecont[n] = ui:findComponent("waiguan_"..n..",rolecont")
		ui.name[n] = ui:findComponent("waiguan_"..n..",name")
		ui.按钮[n] = ui:findComponent("waiguan_"..n..",按钮")
		ui.按钮[n].id = n
		ui.属性[n] = ui:findComponent("waiguan_"..n..",属性")
		ui.属性[n]:setTitleText("")
		ui.属性[n].id = n
		ui.属性[n]:addEventListener(F3DUIEvent.MOUSE_OVER, func_ue(onGridOver))
		ui.属性[n]:addEventListener(F3DUIEvent.MOUSE_OUT, func_ue(onGridOut))
		ui.属性[n]:setBackground("")
		
		ui.按钮[n]:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
			local btn = e:getCurrentTarget()
			
			local 目标组 = 图鉴重组[图鉴类型][btn.id + (图鉴分页 - 1) * 10]
			消息.CG_TJ_BG(目标组.id)
			
		end))
	end
	
	ui.page_cur = ui:findComponent("page_cur")
	ui.page_pre = ui:findComponent("page_pre")
	ui.page_pre:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
	--·	print("a1")
		if not 图鉴重组 or  not 图鉴重组[图鉴类型] then
			return
		end
		local totalpage = math.ceil(#图鉴重组[图鉴类型] / 10)
		if 图鉴分页 > 1 then
			图鉴分页 = math.max(1, 图鉴分页 - 1)
			update()
		end
	end))
	ui.page_next = ui:findComponent("page_next")
	ui.page_next:addEventListener(F3DMouseEvent.CLICK, func_me(function(e)
		if not 图鉴重组 or  not 图鉴重组[图鉴类型] then
			return
		end
		local totalpage = math.ceil(#图鉴重组[图鉴类型] / 10)
		if 图鉴分页 < totalpage then
			图鉴分页 = math.min(totalpage, 图鉴分页 + 1)
			update()
		end
	end))
	
	
	
	
	
	
	ui.图鉴总加成 = ui:findComponent("图鉴总加成")
	ui.图鉴总加成.id = 11
	ui.图鉴总加成:addEventListener(F3DUIEvent.MOUSE_OVER, func_ue(onGridOver))
	ui.图鉴总加成:addEventListener(F3DUIEvent.MOUSE_OUT, func_ue(onGridOut))
	
	ui.close = ui:findComponent("titlebar,close")
	ui.close:addEventListener(F3DMouseEvent.CLICK, func_me(onClose))
	ui:addEventListener(F3DMouseEvent.MOUSE_DOWN, func_me(onMouseDown))
	ui:addEventListener(F3DMouseEvent.MOUSE_MOVE, func_me(onMouseMove))
	
	ui.tab = tt(ui:findComponent("tab_1"), F3DTab)
	ui.tab:addEventListener(F3DUIEvent.CHANGE, func_me(onTabChange))
	m_init = true
	update()
end

function isHided()
	return not ui or not ui:isVisible()
end

function hideUI()
	if tipsui then
		tipsui = nil
		tipsgrid = nil
	end
	if ui then
		ui:setVisible(false)
		--for n = 1 , 10 do
		--	if 图鉴展示组[n] then
			--	图鉴展示组[n]:removeFromParent(true)
			--	图鉴展示组[n] = nil
--				print("a1")
		--	end
		--end
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
	ui:setLoadPriority(getUIPriority())
	ui:addEventListener(F3DObjEvent.OBJ_INITED, func_e(onUIInit))
if ui.setUIPack and USEUIPACK then
ui:setUIPack(g_mobileMode and UIPATH.."图鉴UI5.pack"or UIPATH.."图鉴UI5.pack")
else
ui:setLayout(g_mobileMode and UIPATH.."图鉴UI5.layout" or UIPATH.."图鉴UI5.layout")
end
	uiLayer:addChild(ui)
end