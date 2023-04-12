module(..., package.seeall)

local 全局设置 = require("公用.全局设置")
local 游戏设置 = require("公用.游戏设置")
local 消息 = require("网络.消息")
local 主界面UI = require("主界面.主界面UI")
local 实用工具 = require("公用.实用工具")
local 角色逻辑 = require("主界面.角色逻辑")

CHAT_TYPE_SYSTEM = 0 --系统
CHAT_TYPE_WORLD = 1 --世界
CHAT_TYPE_NEARBY = 2 --附近
CHAT_TYPE_GUILD = 3 --行会
CHAT_TYPE_TEAM = 4 --队伍
CHAT_TYPE_PRIVATE = 5 --私聊
CHAT_TYPE_SPEAKER = 6 --喇叭

CHANNEL = {
	txt("世界"),
	txt("附近"),
	txt("行会"),
	txt("队伍"),
	txt("私聊"),
	txt("喇叭"),
}

colorval = {}
colorval[0] = "0xff8080"
colorval[1] = "0x00ffff"
colorval[2] = "0x00ff00"
colorval[3] = "0xff9900"
colorval[4] = "0xffff00"
colorval[5] = "0xff00ff"
colorval[6] = "0xff9900"

m_init = false
m_strs = {}
m_history = {}
m_historyindex = 0
m_channel = 0
m_itempool = {}
m_items = {}

function popItem()
	if #m_itempool > 0 then
		local cb = m_itempool[#m_itempool]
		table.remove(m_itempool, #m_itempool)
		return cb
	end
end

function pushItem(cb)
	cb.rtf:setTitleText("")
	m_items[cb] = nil
	m_itempool[#m_itempool+1] = cb
end

function calcTextWidth(str,fontsize,_v_1719)
	local cnt = 0
	local s = 1
	local word = 0
	local wordmax = 0
	local skip = false
	local strs = {}
	for i=1,str:len() do
		if str:byte(i) == 35 then
			skip = true
		elseif skip and str:byte(i) == 35 then
			skip = false
			cnt = cnt + 1
		elseif skip and str:byte(i) == 44 then
			skip = false
		elseif skip and str:byte(i) == 110 and str:byte(i-1) == 35 then
			break
		elseif skip and ((str:byte(i) >= 65 and str:byte(i) <= 90) or str:byte(i) == 98 or str:byte(i) == 105 or str:byte(i) == 117) and str:byte(i-1) == 35 then
			skip = false
		elseif not skip then
if str:byte(i)>127 and(_v_1719 or __PLATFORM__=="ANDROID"or __PLATFORM__=="IOS")then
				if word==0 then
					local n = str:byte(i)
					for ii=7,1,-1 do
						local b = 实用工具.GetBit(n, ii)
						if b == 0 then
							wordmax = 8-ii
							break
						end
					end
				end
				word = word + 1
				if word%wordmax==0 then
					cnt = cnt + 2
					word = 0
				end
			else
				cnt = cnt + 1
			end
		end
	end
	return cnt * fontsize / 2
end

function trimText(str, linecnt)
	local cnt = 0
	local s = 1
	local word = 0
local wordmax=0
	local skip = false
	local strs = {}
	for i=1,str:len() do
		if str:byte(i) == 35 then
			skip = true
		elseif skip and str:byte(i) == 35 then
			skip = false
			cnt = cnt + 1
		elseif skip and str:byte(i) == 44 then
			skip = false
		elseif skip and str:byte(i) == 110 and str:byte(i-1) == 35 then
			if #strs > 0 and cnt == 0 then
				strs[#strs] = strs[#strs]..str:sub(s,i-2)
				s = i+1
			else
				strs[#strs+1] = str:sub(s,i-2)
				s = i+1
			end
			skip = false
			cnt = 0
		elseif skip and ((str:byte(i) >= 65 and str:byte(i) <= 90) or str:byte(i) == 98 or str:byte(i) == 105 or str:byte(i) == 117) and str:byte(i-1) == 35 then
			if #strs > 0 and cnt == 0 then
				strs[#strs] = strs[#strs]..str:sub(s,i)
				s = i+1
			end
			skip = false
		elseif not skip then
if str:byte(i)>127 and(__PLATFORM__=="ANDROID"or __PLATFORM__=="IOS")then
if word==0 then
local n=str:byte(i)
for ii=7,1,-1 do
local b=实用工具.GetBit(n,ii)
if b==0 then
wordmax=8-ii
break
end
end
end
word=word+1
if word%wordmax==0 then
cnt=cnt+2
word=0
end
elseif str:byte(i)>127 then
				word = word + 1
if word%2==0 then
cnt=cnt+2
word=0
			end
			else
				cnt = cnt + 1
			end
		end
		if cnt >= linecnt then
local aword=1
			strs[#strs+1] = str:sub(s,i-1+aword)
			cnt = 0
			s = i+aword
		end
	end
	if s <= str:len() then
		strs[#strs+1] = str:sub(s)
	end
	return 实用工具.JoinString(strs, "#n"), #strs
end

function 添加文本(rolename,objid,msgtype,msg)
	local bk = 游戏设置.WHITECHAT and 游戏设置.WHITECHAT[3] or 0
	if msg:sub(1,3) == "##c" then
		bk = tonumber("0xff"..msg:sub(4,msg:find(",")-1), 16)
		msg = msg:sub(msg:find(",")+1)
	end
	local p = 角色逻辑.m_rolename:find("\\")
local m_rolename=p and 角色逻辑.m_rolename:sub(1,p-1)or 角色逻辑.m_rolename
	local name
	if msg:byte(1) == string.byte("/") and msg:find(" ") ~= nil then
		local role = msg:sub(2, msg:find(" ")-1)
		msg = msg:sub(msg:find(" ")+1)
		name = rolename == m_rolename and txt("我对"..role.."说：") or rolename ~= "" and txt(rolename)..": " or ""
	else
		name = rolename == m_rolename and txt("我：") or rolename ~= "" and txt(rolename)..": " or ""
		
	end
--	if(rolename ~= "" and rolename ~= nil) then
--		name = 实用工具.split(txt(rolename),".")
--		name = name[2]
--	end
	
	local str = (g_mobileMode and "#s16," or "").."#c"..colorval[msgtype]..txt(",【")..((msgtype == 0 and txt("系统") or CHANNEL[msgtype])..txt("】")..name.."#C"..txt(msg):gsub("\n","#n"))
	if #m_strs >= 100 then
		table.remove(m_strs, 1)
	end
	if m_init and ui.list:numItems() >= 100 then
		pushItem(ui.list:getItem(0))
		ui.list:removeItem(nil, 0)
	end
	local initlist = m_init and ui.list:getWidth() > 0
	local linecnt = g_mobileMode and (initlist and math.floor((ui.list:getWidth()-20)/8) or 40) or ISMIRUI and (initlist and math.floor((ui.list:getWidth()-20)/6) or 105) or (initlist and math.floor((ui.list:getWidth()-20)/6) or 38)
	str = trimText(str, linecnt)
	m_strs[#m_strs+1] = {msgtype,str,bk}
	update(msgtype,str,bk)
end

function update(msgtype,str,bk)
	if not m_init then
		return
	end
	if str == nil then
		for i,v in ipairs(m_strs) do
			if m_channel == 0 or m_channel == v[1] then
				addStr(v[2],v[3])
			end
		end
		ui.list:getVScroll():setPercent(1)
	elseif m_channel == 0 or m_channel == msgtype then
		addStr(str,bk)
		ui.list:getVScroll():setPercent(1)
	end
end

function onClick(e)
	local cb = e:getCurrentTarget()
	if cb and cb.rtf then
		local str = cb.rtf:getTitleText()
		local p1,p2 = str:find(txt("】"))
		if p1 and p2 then
			local p3 = str:find("#C", p2+1)
			local p4 = str:find(": ", p2+1)
			if p3 and p3 > p2+1 and p4 and p3 > p4 and p4 > p2+1 then
				ui.textinput:setTitleText("/"..str:sub(p2+1,p4-1).." ")
				ui.textinput:setTextInput()
			end
		end
	end
end

function addStr(str,bk)
	local cb = popItem()
	if not cb then
		cb = F3DCheckBox:new()
		cb:addEventListener(F3DMouseEvent.CLICK, func_me(onClick))
	end
	if not cb.rtf then
		cb.rtf = F3DRichTextField:new()
		cb.rtf:setTouchable(false)
		cb:addChild(cb.rtf)
	end
	local line = 1
	local s = 1
	local p = str:find("#n",s)
	while p do
		if str:byte(p-1) ~= string.byte("#") then
			line = line + 1
		end
		s = p + 2
		p = str:find("#n",s)
	end
	local hei = 游戏设置.WHITECHAT and 游戏设置.WHITECHAT[4] or 2
	cb:setHeight(g_mobileMode and (line*18+hei) or (line*14+hei))
	cb.rtf:setTitleText(str)
	if 游戏设置.OLDTEXTCOLOR then
		cb.rtf:setTextColor(0xffffff)
	else
cb.rtf:setTextColor(0xffffff,(游戏设置.WHITECHAT and 游戏设置.WHITECHAT[2]==1)and bk or 0,VIPLEVEL>=4 and bk or 0)
	end
	ui.list:addItem(cb)
	m_items[cb] = 1
end

function prop12(e)
	if ui.textinput:isDefault() or ui.textinput:getTitleText() == "" then
		主界面UI.showTipsMsg(1, txt("请输入聊天内容"))
		return
	end
	local str = ui.textinput:getTitleText()
	local channel = 1
	for i=1,6 do
		if ui.channels[i]:isSelected() then
			channel = math.max(i-1,1)
			break
		end
	end
	消息.CG_CHAT(channel,utf8(str:gsub("#","##")))
	for i,v in ipairs(m_history) do
		if v == str then
			table.remove(m_history, i)
			break
		end
	end
	m_history[#m_history+1] = str
	m_historyindex = #m_history
	ui.textinput:setTitleText("")
if e then
	e:stopPropagation()
end
end

function onKeyDown(e)
	if F3DTextInput.sTextInput ~= ui.textinput then return end
	if e:getKeyCode() == F3DKeyboardCode.UP then
		if m_history[m_historyindex] then
			ui.textinput:setTitleText(m_history[m_historyindex])
			m_historyindex = math.max(1, m_historyindex - 1)
		end
	elseif e:getKeyCode() == F3DKeyboardCode.DOWN then
		if m_history[m_historyindex] then
			ui.textinput:setTitleText(m_history[m_historyindex])
			m_historyindex = math.min(#m_history, m_historyindex + 1)
		end
	end
end

function onUIInit()
	ui.textinput = tt(ui:findComponent("输入"),F3DTextInput)
ui.textinput:addEventListener(F3DUIEvent.INPUT_ENTER,func_ue(prop12))
	if not g_mobileMode and 游戏设置.WHITECHAT and 游戏设置.WHITECHAT[1] == 1 then
		ui.textinput:setTextColor(0,0xffffff)
	end
	ui.list = tt(ui:findComponent("列表"),F3DList)
	if g_mobileMode or not ISMIRUI then
		ui.enter = ui:findComponent("回车")
		ui.enter:addEventListener(F3DMouseEvent.CLICK,func_me(prop12))
	end
	ui.channels = {}
	for i=1,6 do
		ui.channels[i] = tt(ui:findComponent("checkbox_"..i),F3DCheckBox)
if VIPLEVEL>=2 then
			ui.channels[i]:addEventListener(F3DUIEvent.CHANGE, func_ue(function(e)
				if e:getTarget():isSelected() then
					m_channel = math.min(6,i-1)
					ui.list:removeAllItems()
					update()
				end
			end))
		else
			ui.channels[i]:setVisible(false)
		end
	end
	ui.channels[1]:setSelected(true)
	F3DTouchProcessor:instance():addEventListener(F3DKeyboardEvent.KEY_DOWN, func_ke(onKeyDown))
	m_init = true
	checkResize()
	update()
end

function checkResize()
	if not ui or not 主界面UI.ui then return end
	if not g_mobileMode and ISMIRUI then return end
	if g_mobileMode then
	elseif ui:getPositionX()+ui:getWidth()>主界面UI.ui:getPositionX() and ui:getPositionY()+ui:getHeight()>主界面UI.ui:getPositionY()-50 then
		ui:setPositionY(主界面UI.ui:getPositionY()-50-ui:getHeight())
	end
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
		ui:updateParent()
		ui:setVisible(true)
		checkResize()
		return
	end
	ui = F3DLayout:new()
	uiLayer:addChild(ui)
	ui:setLoadPriority(getUIPriority())
	ui:addEventListener(F3DObjEvent.OBJ_INITED, func_e(onUIInit))
	if ui.setUIPack and USEUIPACK then
		ui:setUIPack(g_mobileMode and UIPATH.."聊天UIm.pack" or UIPATH.."聊天UI.pack")
	else
		ui:setLayout(g_mobileMode and UIPATH.."聊天UIm.layout" or UIPATH.."聊天UI.layout")
	end
end
