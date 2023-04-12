module(...,package.seeall)

local 全局设置=require("公用.全局设置")
local 游戏设置=require("公用.游戏设置")
local 实用工具=require("公用.实用工具")
local 消息=require("网络.消息")
local 角色逻辑=require("主界面.角色逻辑")
local 角色UI=require("主界面.角色UI")
local 聊天UI=require("主界面.聊天UI")
local 地图表=require("配置.地图表")
local Npc表=require("配置.Npc表")
m_init=false
m_itemdata=nil
m_isEquipped=false
COLORBG={
"",
UIPATH.."公用/tip/tips_color_1.png",
UIPATH.."公用/tip/tips_color_2.png",
UIPATH.."公用/tip/tips_color_3.png",
UIPATH.."公用/tip/tips_color_4.png",
}

function setItemData(itemdata,isEquipped)
m_itemdata=itemdata
m_isEquipped=isEquipped
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
ui.类型:setTitleText("")
ui.isEquipped:setVisible(false)
for i=1,#ui.props do
ui.props[i]:setVisible(false)
end
local clips=F3DPointVector:new()
clips:clear()
clips:push(0,-clips:size()*13)
ui.zhanli:setBatchClips(10,clips)
ui.zhanli:setOffset(-13+clips:size()*13,0)
end

function update()
if not m_init or not m_itemdata then
return
end
ui.color:setBackground(COLORBG[m_itemdata.grade])
ui.img:setTextureFile(全局设置.getItemIconUrl(m_itemdata.icon))
ui.grade:setTextureFile(全局设置.getGradeUrl(m_itemdata.grade))
ui.lock:setTextureFile(m_itemdata.bind==1 and UIPATH.."公用/grid/img_bind.png"or"")
ui.strengthen:setText(m_itemdata.strengthen>0 and"+"..m_itemdata.strengthen or"")
ui.name:setTitleText(txt(m_itemdata.name))
ui.name:setTextColor(m_itemdata.color>0 and m_itemdata.color or 全局设置.getColorRgbVal(m_itemdata.grade))

local index=1
local ss=实用工具.SplitString(m_itemdata.desc,"\n",true)
local _v_1459=g_mobileMode and 18 or 14
local _v_1868={}
local zbjs=0
local 角色逻辑=角色UI.m_tabid==1 and 角色UI.英雄角色逻辑 or 角色逻辑
if m_itemdata.suitname==""and#m_itemdata.suitprop>0 then
for ii,vv in ipairs(m_itemdata.suitprop)do
local cnt=0
local suitid=vv[1]
local suitcnts=角色逻辑.m_suitcnts
for i=1,#suitcnts,2 do
if suitcnts[i]==suitid then
cnt=suitcnts[i+1]
break
end
end
local sss=实用工具.SplitString(vv[4],"\n",true)
for i,v in ipairs(sss)do
ss[#ss+1]=(i==1 and vv[2]>1)and v.." ("..cnt.." / "..vv[2]..")"or v
end
end
end
for i,v in ipairs(ss)do
if v:sub(1,2)=="<s"and v:find(">")then
local sss=实用工具.SplitString(v:sub(3,v:find(">")-1),",",true)
local w=g_mobileMode and tonumber(sss[2])or tonumber(sss[1])
_v_1868[#_v_1868+1]=w
if i>1 then
zbjs=zbjs+w
end
elseif v:sub(1,2)=="<p"and v:find(">")then
_v_1868[#_v_1868+1]=_v_1459+2
if i>1 then
zbjs=zbjs+_v_1459+2
end
else
_v_1868[#_v_1868+1]=_v_1459
if i>1 then
zbjs=zbjs+_v_1459
end
end
end
for i,v in ipairs(ss)do
checkPropIndex(index,i>1 and _v_1868[i-1]or 0,游戏设置.NEWITEMTIPS and 0 or zbjs)
local color=0xffffff
if v:sub(1,2)=="<c"and v:find(">")then
color=tonumber("0x"..v:sub(3,v:find(">")-1))or 0
v=v:sub(v:find(">")+1)
end
local _v_1869=1
if v:sub(1,2)=="<s"and v:find(">")then
local sss=实用工具.SplitString(v:sub(3,v:find(">")-1),",",true)
v=v:sub(v:find(">")+1)
local w=g_mobileMode and tonumber(sss[2])or tonumber(sss[1])
local _v_1870=tonumber(sss[4])or 0
local _v_1871=tonumber(sss[6])or 0
for ii=1,_v_1870+_v_1871 do
if not ui.descs[index].pics[ii]then
ui.descs[index].pics[ii]=F3DImage:new()
ui.descs[index]:addChild(ui.descs[index].pics[ii])
end
ui.descs[index].pics[ii]:setWidth(w)
ui.descs[index].pics[ii]:setHeight(w)
ui.descs[index].pics[ii]:setPositionX((ii-1)*w-math.floor((_v_1870+_v_1871)*w/20))
ui.descs[index].pics[ii]:setPositionY(-math.floor(_v_1459/2))
ui.descs[index].pics[ii]:setTextureFile("/res/icon/"..(ii>_v_1870 and sss[5]or sss[3])..".png")
ui.descs[index].pics[ii]:setVisible(true)
end
_v_1869=_v_1870+_v_1871+1
end
for ii=_v_1869,#ui.descs[index].pics do
ui.descs[index].pics[ii]:setVisible(false)
end
if v:sub(1,2)=="<p"and v:find(">")then
local sss=实用工具.SplitString(v:sub(3,v:find(">")-1),",",true)
if sss[1]~=""then
color=tonumber("0x"..sss[1])or 0
end
if not ui.descs[index].prog then
ui.descs[index].prog=F3DProgress:new()
ui.descs[index].prog:initWithEmpty()
ui.descs[index].prog:setContentArea("4,1,8,3")
ui.descs[index].prog:setScaleX(g_mobileMode and 1.33 or 1)
ui.descs[index].prog:setScaleY(g_mobileMode and 1.33 or 1)
ui.descs[index]:addChild(ui.descs[index].prog)
end
ui.descs[index].prog:setBackground(UIPATH.."公用/grid/"..string.format("%05d",sss[3])..".png")
ui.descs[index].prog:getTrack():setBackground(UIPATH.."公用/grid/"..string.format("%05d",sss[4])..".png")
ui.descs[index].prog:setPositionX(聊天UI.calcTextWidth(sss[2],g_mobileMode and 16 or 12,true)+4)
ui.descs[index].prog:setPositionY(2)
ui.descs[index].prog:setMaxVal(tonumber(sss[6]))
ui.descs[index].prog:setCurrVal(tonumber(sss[5]))
if tonumber(sss[7])==1 then
v=sss[2]..string.rep(" ",g_mobileMode and 14 or 8)..math.floor(ui.descs[index].prog:getPercent()*100).."%"
elseif tonumber(sss[7])==2 then
v=sss[2]..string.rep(" ",g_mobileMode and 14 or 8)..sss[5].."/"..sss[6]
else
v=sss[2]
end
ui.descs[index].prog:setVisible(true)
end
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
end
if 游戏设置.NEWITEMTIPS then
ui.job:setTitleText(txt("需求："..(m_itemdata.level<0 and(-m_itemdata.level).."转"or m_itemdata.level.."级")..(m_itemdata.job>0 and","..全局设置.获取职业类型(m_itemdata.job)or"")))
else
ui.job:setTitleText(txt("职业："..全局设置.获取职业类型(m_itemdata.job)))
end
if m_itemdata.level<0 then
ui.level:setTitleText(txt("转生等级："..(-m_itemdata.level).."转"))
else
ui.level:setTitleText(txt("等级："..m_itemdata.level))
end
ui.类型:setTitleText(txt("类型："..全局设置.获取物品类型(m_itemdata.type,m_itemdata.equippos)))
ui.isEquipped:setVisible(m_isEquipped)
local props={}
local aprops={}
local gprops={}
local _v_1464={}
local _v_1872={}
for i,v in ipairs(m_itemdata.prop)do
if v[1]<0 or v[1]>1000 then
_v_1464[#_v_1464+1]={v[1],v[2],v[4]}
else
props[v[1]]=(props[v[1]]or 0)+v[2]+v[3]
if v[1]==4 or v[1]==6 or v[1]==8 or v[1]==10 or v[1]==12 or v[1]==48 or v[1]==50 or v[1]==52 or v[1]==54 then
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
local _v_1465=false
local _v_1466=false
local _v_1469=false
local _v_1470=false
	local _v_1471=false
	local _v_1472=false
	local _v_1473=false
local index=1
	for _,v in ipairs(全局设置.proptexts)do
		i=v[2]
		if v[1]~=""and props[i]then
			if i<=22 and not _v_1465 then
				_v_1467(index,zbjs)
				ui.props[index]:setTitleText(txt("[基础属性]："))
				ui.props[index]:setTextColor(0x00DDFF)
				ui.props[index].pic:setTextureFile("")
				ui.props[index]:setVisible(true)
				index=index+1
				_v_1465=true
			elseif i>22 and i<46 and not _v_1466 then
				_v_1467(index,zbjs)
				ui.props[index]:setTitleText(txt("[元素属性]："))
				ui.props[index]:setTextColor(0x00DDFF)
				ui.props[index].pic:setTextureFile("")
				ui.props[index]:setVisible(true)
				index=index+1
				_v_1466=true
			elseif i>74 and i<82 and not _v_1473 then
				_v_1467(index,zbjs)
				ui.props[index]:setTitleText(txt("[BUFF属性]："))
				ui.props[index]:setTextColor(0x00DDFF)
				ui.props[index].pic:setTextureFile("")
				ui.props[index]:setVisible(true)
				index=index+1
				_v_1473=true
			elseif i==91 or i==92 and not _v_1470 then
				_v_1467(index,zbjs)
				ui.props[index]:setTitleText(txt("[来源时间]："))
				ui.props[index]:setTextColor(0x00DDFF)
				ui.props[index].pic:setTextureFile("")
				ui.props[index]:setVisible(true)
				index=index+1
				_v_1470=true	
			elseif i > 99 and i < 106 and not _v_1469 then
				_v_1467(index,zbjs)
				ui.props[index]:setTitleText(txt("[额外属性]："))
				ui.props[index]:setTextColor(0x00DDFF)
				ui.props[index].pic:setTextureFile("")
				ui.props[index]:setVisible(true)
				index=index+1
				_v_1469=true	
			elseif i>48 and i<51 and not _v_1471 then
				_v_1467(index,zbjs)
				ui.props[index]:setTitleText(txt("[装备持久]："))
				ui.props[index]:setTextColor(0x00DDFF)
				ui.props[index].pic:setTextureFile("")
				ui.props[index]:setVisible(true)
				index=index+1
				_v_1471=true
		elseif i==82 and not _v_1472 then
				_v_1467(index,zbjs)
				ui.props[index]:setTitleText(txt("[切割属性]："))
				ui.props[index]:setTextColor(0x00DDFF)
				ui.props[index].pic:setTextureFile("")
				ui.props[index]:setVisible(true)
				index=index+1
				_v_1472=true				
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
if not(i>=47 and i<=54)and(aprops[i]or aprops[i+1])then
str=str.." ("..(aprops[i]or 0).."-"..(aprops[i+1]or 0)..")"
end
ui.props[index]:setTitleText(txt(v[1].."：")..str)
ui.props[index]:setTextColor(v[4]or 全局设置.getColorRgbVal(math.max(gprops[i]or 1,gprops[i+1]or 1)))
ui.props[index].pic:setTextureFile("")
ui.props[index]:setVisible(true)
index=index+1
end
elseif i==92 then
	local riqi =props[i]
riqi1 = string.sub(riqi, 1, 1)
riqi2 = string.sub(riqi, 2, 3)
riqi3 = string.sub(riqi, 4, 5)
riqi4 = string.sub(riqi, 6, 7)
riqi5 = string.sub(riqi, 8, 9)

local sj = "[0"..riqi1.."/"..riqi2.."/".."22".."]".." "..riqi3..":"..riqi4..":"..riqi5
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
			sj=txt("系统给予")	
		end

	local str=(_v_1872[i]and _v_1872[i]~="")and txt(_v_1872[i])or sj..(v[3]and""or"")
	ui.props[index]:setTitleText(txt(v[1].."：")..str)
	ui.props[index]:setTextColor(v[4]or 全局设置.getColorRgbVal(gprops[i]or 1))
	ui.props[index].pic:setTextureFile("")
	ui.props[index]:setVisible(true)
	index=index+1		
else
local str=(i==82 and props[i]/1 or props[i])..(v[3]and"%"or"")..(aprops[i]and" ("..aprops[i]..")"or"")
ui.props[index]:setTitleText(txt(v[1].."：")..str)
ui.props[index]:setTextColor(v[4]or 全局设置.getColorRgbVal(gprops[i]or 1))
ui.props[index].pic:setTextureFile("")
ui.props[index]:setVisible(true)
index=index+1
end
end
end
for i,v in ipairs(_v_1464)do
if v[1]<-1000 and v[3]and v[3]~=""then
_v_1467(index,zbjs)
local ss=实用工具.SplitString(v[3],",",true)
ui.props[index]:setTitleText(txt(ss[1].."："..(v[2]>0 and"威力+"..(v[2]).."%"or"抵抗+"..(-v[2]).."%")))
ui.props[index]:setTextColor((#ss>1 and ss[2]~="")and tonumber("0x"..ss[2])or 0xFF0000)
ui.props[index].pic:setTextureFile((#ss>2 and ss[3]~="")and"/res/icon/"..ss[3]..".png"or"")
ui.props[index]:setVisible(true)
index=index+1
elseif v[1]>1000 and v[3]and v[3]~=""then
_v_1467(index,zbjs)

local ss=实用工具.SplitString(v[3],",",true)
ui.props[index]:setTitleText(txt(ss[1].."："..
((#ss>3 and ss[4]~="")and ss[4]:gsub("%%d",math.abs(v[2]))or(v[2]>0 and"释放几率"..(v[2]).."%"or"被动几率"..(-v[2]).."%"))))
ui.props[index]:setTextColor((#ss>1 and ss[2]~="")and tonumber("0x"..ss[2])or 0xFF0000)
ui.props[index].pic:setTextureFile((#ss>2 and ss[3]~="")and"/res/icon/"..ss[3]..".png"or"")
ui.props[index]:setVisible(true)
index=index+1
elseif v[1]<0 and v[3]and v[3]~=""then
_v_1467(index,zbjs)
local ss=实用工具.SplitString(v[3],",",true)
ui.props[index]:setTitleText(txt(ss[1].."："..
((#ss>3 and ss[4]~=""and v[2]<0)and ss[4]:gsub("%%d",math.abs(v[2]))or"等级"..(v[2]>0 and("+"..v[2])or("-"..(-v[2]))))))
ui.props[index]:setTextColor((#ss>1 and ss[2]~="")and tonumber("0x"..ss[2])or 0xFF0000)
ui.props[index].pic:setTextureFile((#ss>2 and ss[3]~="")and"/res/icon/"..ss[3]..".png"or"")
ui.props[index]:setVisible(true)
index=index+1
end
end
if#m_itemdata.attachprop>0 then
_v_1467(index,zbjs)
if m_itemdata.attachprop[1][1]==-1 then
ui.props[index]:setTitleText(txt("附魔：")..txt("附魔值").." +"..m_itemdata.attachprop[1][2])
elseif m_itemdata.attachprop[1][1]<=5 then
ui.props[index]:setTitleText(txt("附魔：")..txt(全局设置.附魔[m_itemdata.attachprop[1][1]][m_itemdata.job==0 and 角色逻辑.m_rolejob or 1]).." +"..m_itemdata.attachprop[1][2].."%")
else
ui.props[index]:setTitleText(txt("附魔：")..txt(全局设置.附魔[m_itemdata.attachprop[1][1]][1]).." +"..m_itemdata.attachprop[1][2].."%")
end
ui.props[index]:setTextColor(0xDD2020)
ui.props[index].pic:setTextureFile("")
ui.props[index]:setVisible(true)
index=index+1
end
		for i,v in ipairs(m_itemdata.gemprop)do
			_v_1467(index,zbjs)
			if m_itemdata.gemprop[i][1]==1 then
				ui.props[index]:setTitleText(txt("神石：")..txt(全局设置.宝石[m_itemdata.gemprop[i][1]][1])..txt" 增加("..(m_itemdata.gemprop[i][2]*5)..")")
			else
				ui.props[index]:setTitleText(txt("神石：")..txt(全局设置.宝石[m_itemdata.gemprop[i][1]][1])..txt" 增加(0-"..(m_itemdata.gemprop[i][2]*1)..")")
			end
			ui.props[index]:setTextColor(全局设置.getColorRgbVal(m_itemdata.gemprop[i][2]))
			ui.props[index].pic:setTextureFile(全局设置.getItemIconUrl(全局设置.宝石[m_itemdata.gemprop[i][1]][2]))
			ui.props[index]:setVisible(true)
			index=index+1
		end

--for i,v in ipairs(m_itemdata.runeprop)do
--_v_1467(index,zbjs)
--if m_itemdata.runeprop[i][4]~=""and m_itemdata.runeprop[i][4]:find("符文")then
--ui.props[index]:setTitleText(txt("镶嵌：")..txt(m_itemdata.runeprop[i][4]).." (+"..(m_itemdata.runeprop[i][2]).."%)")
--elseif m_itemdata.runeprop[i][4]~=""then
--ui.props[index]:setTitleText(txt("镶嵌：")..txt(m_itemdata.runeprop[i][4]).." (+"..(m_itemdata.runeprop[i][2])..")")
--else
--ui.props[index]:setTitleText(txt("镶嵌：")..txt(全局设置.符文[m_itemdata.runeprop[i][1]][1]).." (+"..(m_itemdata.runeprop[i][2]).."%)")
--end
--ui.props[index]:setTextColor(全局设置.getColorRgbVal(m_itemdata.runeprop[i][2]))
--if m_itemdata.runeprop[i][1]>=10000 then
--ui.props[index].pic:setTextureFile(全局设置.getItemIconUrl(m_itemdata.runeprop[i][1]))
--else
--ui.props[index].pic:setTextureFile(全局设置.getItemIconUrl(全局设置.符文[m_itemdata.runeprop[i][1]][2]))
--end
--ui.props[index]:setVisible(true)
--index=index+1
--end

if#m_itemdata.ringsoul>0 then
_v_1467(index,zbjs)
ui.props[index]:setTitleText(txt("戒灵：")..txt(m_itemdata.ringsoul[1][1].." ("..m_itemdata.ringsoul[1][2].."级"..m_itemdata.ringsoul[1][3].."星)"))
ui.props[index]:setTextColor(全局设置.getColorRgbVal(m_itemdata.ringsoul[1][4]))
ui.props[index].pic:setTextureFile("")
ui.props[index]:setVisible(true)
index=index+1
end
if m_itemdata.suitname~=""and#m_itemdata.suitprop>1 then
_v_1467(index,zbjs)
local cnt=0
local suitid=m_itemdata.suitprop[1][1]
for i=1,#角色逻辑.m_suitcnts,2 do
if 角色逻辑.m_suitcnts[i]==suitid then
cnt=角色逻辑.m_suitcnts[i+1]
break
end
end
ui.props[index]:setTitleText(txt(m_itemdata.suitname)..(m_itemdata.suitprop[1][2]>1 and" ("..cnt.." / "..m_itemdata.suitprop[1][2]..")"or""))
local color=(m_itemdata.suitprop[1][2]==1 or cnt>=m_itemdata.suitprop[1][2])and 0x00dddd or 0x007777
ui.props[index]:setTextColor(color)
ui.props[index].pic:setTextureFile("")
ui.props[index]:setVisible(true)
index=index+1
local suitprops={}
local _v_1473={}
for i,v in ipairs(m_itemdata.suitprop)do
if i>1 and(v[1]<0 or v[1]>1000)then
_v_1473[#_v_1473+1]={v[1],v[2],v[4]}
elseif i>1 then
suitprops[v[1]]=(suitprops[v[1]]or 0)+v[2]+v[3]
if v[1]==4 or v[1]==6 or v[1]==8 or v[1]==10 or v[1]==12 then
suitprops[v[1]-1]=(suitprops[v[1]-1]or 0)
end
end
end
for _,v in ipairs(全局设置.proptexts)do
i=v[2]
if v[1]~=""and suitprops[i]then
_v_1467(index,zbjs)
if i>=3 and i<=12 then
if i%2==1 then
local str=suitprops[i].."-"..(suitprops[i+1]or 0)
ui.props[index]:setTitleText(txt(v[1].."：")..str)
ui.props[index]:setTextColor(color)
ui.props[index].pic:setTextureFile("")
ui.props[index]:setVisible(true)
index=index+1
end
else
local str=(i==82 and suitprops[i]/10 or suitprops[i])..(v[3]and"%"or"")
ui.props[index]:setTitleText(txt(v[1].."：")..str)
ui.props[index]:setTextColor(color)
ui.props[index].pic:setTextureFile("")
ui.props[index]:setVisible(true)
index=index+1
end
end
end
for i,v in ipairs(_v_1473)do
if v[1]<-1000 and v[3]and v[3]~=""then
_v_1467(index,zbjs)
local ss=实用工具.SplitString(v[3],",",true)
ui.props[index]:setTitleText(txt(ss[1].."："..(v[2]>0 and"威力+"..(v[2]).."%"or"抵抗+"..(-v[2]).."%")))
if m_itemdata.suitprop[1][2]==1 or cnt>=m_itemdata.suitprop[1][2]then
ui.props[index]:setTextColor((#ss>1 and ss[2]~="")and tonumber("0x"..ss[2])or 0xFF0000)
elseif#ss>1 and ss[2]~=""then
local col1=tonumber(ss[2]:sub(1,2),16)or 0
local col2=tonumber(ss[2]:sub(3,4),16)or 0
local _v_1873=tonumber(ss[2]:sub(5,6),16)or 0
local _v_1874=math.floor(col1/2)*65536+math.floor(col2/2)*256+math.floor(_v_1873/2)
ui.props[index]:setTextColor(_v_1874)
else
ui.props[index]:setTextColor(0x800000)
end
ui.props[index].pic:setTextureFile((#ss>2 and ss[3]~="")and"/res/icon/"..ss[3]..".png"or"")
ui.props[index]:setVisible(true)
index=index+1
elseif v[1]>1000 and v[3]and v[3]~=""then
_v_1467(index,zbjs)

local ss=实用工具.SplitString(v[3],",",true)
ui.props[index]:setTitleText(txt(ss[1].."："..
((#ss>3 and ss[4]~="")and ss[4]:gsub("%%d",math.abs(v[2]))or(v[2]>0 and"释放几率"..(v[2]).."%"or"被动几率"..(-v[2]).."%"))))
if m_itemdata.suitprop[1][2]==1 or cnt>=m_itemdata.suitprop[1][2]then
ui.props[index]:setTextColor((#ss>1 and ss[2]~="")and tonumber("0x"..ss[2])or 0xFF0000)
elseif#ss>1 and ss[2]~=""then
local col1=tonumber(ss[2]:sub(1,2),16)or 0
local col2=tonumber(ss[2]:sub(3,4),16)or 0
local _v_1873=tonumber(ss[2]:sub(5,6),16)or 0
local _v_1874=math.floor(col1/2)*65536+math.floor(col2/2)*256+math.floor(_v_1873/2)
ui.props[index]:setTextColor(_v_1874)
else
ui.props[index]:setTextColor(0x800000)
end
ui.props[index].pic:setTextureFile((#ss>2 and ss[3]~="")and"/res/icon/"..ss[3]..".png"or"")
ui.props[index]:setVisible(true)
index=index+1
elseif v[1]<0 and v[3]and v[3]~=""then
_v_1467(index,zbjs)
local ss=实用工具.SplitString(v[3],",",true)
ui.props[index]:setTitleText(txt(ss[1].."："..
((#ss>3 and ss[4]~=""and v[2]<0)and ss[4]:gsub("%%d",math.abs(v[2]))or"等级"..(v[2]>0 and("+"..v[2])or("-"..(-v[2]))))))
if m_itemdata.suitprop[1][2]==1 or cnt>=m_itemdata.suitprop[1][2]then
ui.props[index]:setTextColor((#ss>1 and ss[2]~="")and tonumber("0x"..ss[2])or 0xFF0000)
elseif#ss>1 and ss[2]~=""then
local col1=tonumber(ss[2]:sub(1,2),16)or 0
local col2=tonumber(ss[2]:sub(3,4),16)or 0
local _v_1873=tonumber(ss[2]:sub(5,6),16)or 0
local _v_1874=math.floor(col1/2)*65536+math.floor(col2/2)*256+math.floor(_v_1873/2)
ui.props[index]:setTextColor(_v_1874)
else
ui.props[index]:setTextColor(0x800000)
end
ui.props[index].pic:setTextureFile((#ss>2 and ss[3]~="")and"/res/icon/"..ss[3]..".png"or"")
ui.props[index]:setVisible(true)
index=index+1
end
end
end
for i=index,#ui.props do
ui.props[i]:setVisible(false)
end
if index==1 and 游戏设置.NEWITEMTIPS and m_itemdata.desc:sub(-1,-1)=="\n"then
zbjs=math.max(0,zbjs-_v_1459)
end
local proph=g_mobileMode and 18 or 20
ui.img_tipsBg:setHeight(ui.oldheight+zbjs+(index-7)*proph-(g_mobileMode and(游戏设置.MENUHEIGHT or 100)or 0))
ui:setHeight(ui.oldheight+zbjs+(index-7)*proph-(g_mobileMode and(游戏设置.MENUHEIGHT or 100)or 0))
ui.zhanlicont:setPositionY(ui.zhanlicont.oldposy+zbjs+(index-6)*proph)
ui.img_line1:setPositionY(ui.img_line1.oldposy+zbjs+(index-6)*proph)
ui.img_line2:setPositionY(ui.img_line2.oldposy+zbjs+(index-6)*proph)
ui.img_line3:setPositionY(ui.img_line3.oldposy+zbjs+(index-5.5)*proph)
local clips=F3DPointVector:new()
clips:clear()
local zhanli=m_itemdata.power
if zhanli==0 then
clips:push(0,-clips:size()*13)
else
while zhanli>=1 do
clips:push(math.floor(zhanli%10),-clips:size()*13)
zhanli=zhanli/10
end
end
ui.zhanli:setBatchClips(10,clips)
ui.zhanli:setOffset(-13+clips:size()*13,0)
end

function onMouseDown(e)
uiLayer:removeChild(ui)
uiLayer:addChild(ui)
e:stopPropagation()
end

function _v_1467(i,zbjs)
if not ui.props[i]then
ui.props[i]=i==1 and ui:findComponent("prop_1")or ui.props[1]:clone()
ui.props[i].pic=F3DImage:new()
ui.props[i].pic:setWidth(g_mobileMode and 26 or 22)
ui.props[i].pic:setHeight(g_mobileMode and 22 or 18)
ui.props[i].pic:setPositionX(g_mobileMode and-30 or-25)
ui.props[i]:addChild(ui.props[i].pic)
if i==1 then
ui.props[i]:setVisible(true)
else
ui:addChild(ui.props[i])
end
end
local proph=g_mobileMode and 18 or 20
if i==1 then
ui.props[i]:setPositionY(ui.propy+zbjs)
else
ui.props[i]:setPositionY(ui.propy+(proph*(i-1))+zbjs)
end
end

function checkPropIndex(i,h,zbjs)
if not ui.descs[i]then
ui.descs[i]=i==1 and ui:findComponent("component_2")or ui.descs[1]:clone()
ui.descs[i].pics=ui.descs[i].pics or{}
ui:addChild(ui.descs[i])
end
if ui.descs[i].prog then
ui.descs[i].prog:setVisible(false)
end
if i==1 then
ui.descs[i]:setPositionY(ui.descy-math.floor(zbjs/2))
else
ui.descs[i]:setPositionY(ui.descs[i-1]:getPositionY()+h)
end
end

function onUIInit()
ui:addEventListener(F3DMouseEvent.MOUSE_DOWN,func_me(onMouseDown))
ui.grid=ui:findComponent("gridBg_49X49")
ui.name=ui:findComponent("component_1")

ui.descy=ui:findComponent("component_2"):getPositionY()
ui.descs={}
ui.job=ui:findComponent("component_10")
ui.level=ui:findComponent("component_11")
ui.类型=ui:findComponent("component_9")
ui.color=ui:findComponent("tips_color_1")
if g_mobileMode then
ui.menus={}
for i=1,5 do
ui.menus[i]=ui:findComponent("menu_"..i)
ui.menus[i]:setVisible(false)
end
end
ui.propy=ui:findComponent("prop_1"):getPositionY()
ui.props={}
ui:findComponent("prop_1"):setVisible(false)
ui.zhanli=F3DImage:new()
ui.zhanli:setTextureFile(UIPATH.."公用/equipTips/clip_powerNum.png")
ui.zhanli:setWidth(17)
ui:findComponent("zhanlicont,clip_powerNum"):addChild(ui.zhanli)
ui.isEquipped=ui:findComponent("img_isEquipped")
ui.img=F3DImage:new()
ui.img:setPositionX(math.floor(ui.grid:getWidth()/2))
ui.img:setPositionY(math.floor(ui.grid:getHeight()/2))
ui.img:setPivot(0.5,0.5)
ui.grid:addChild(ui.img)
ui.grade=F3DImage:new()
ui.grade:setPositionX(1)
ui.grade:setPositionY(1)
ui.grade:setWidth(ui.grid:getWidth()-2)
ui.grade:setHeight(ui.grid:getHeight()-2)
ui.grid:addChild(ui.grade)
ui.lock=F3DImage:new()
ui.lock:setPositionX(4)
ui.lock:setPositionY(ui.grid:getHeight()-4)
ui.lock:setPivot(0,1)
ui.grid:addChild(ui.lock)
ui.strengthen=F3DTextField:new()
if g_mobileMode then
ui.strengthen:setTextFont("宋体",16,false,false,false)
end
ui.strengthen:setPositionX(ui.grid:getWidth()-4)
ui.strengthen:setPositionY(4)
ui.strengthen:setPivot(1,0)
ui.grid:addChild(ui.strengthen)
ui.img_tipsBg=ui:findComponent("img_tipsBg")
ui.zhanlicont=ui:findComponent("zhanlicont")
ui.zhanlicont.oldposy=ui.zhanlicont:getPositionY()
ui.img_line1=ui:findComponent("img_line1")
ui.img_line1.oldposy=ui.img_line1:getPositionY()
ui.img_line2=ui:findComponent("img_line2")
ui.img_line2.oldposy=ui.img_line2:getPositionY()
ui.img_line3=ui:findComponent("img_line3")
ui.img_line3.oldposy=ui.img_line3:getPositionY()
ui.oldheight=ui:getHeight()
m_init=true
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
if isHided()then
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
ui=F3DLayout:new()
uiLayer:addChild(ui)
ui:setLoadPriority(getUIPriority())
if not g_mobileMode then
ui:setTouchable(false)
end
ui:addEventListener(F3DObjEvent.OBJ_INITED,func_e(onUIInit))
if ui.setUIPack and USEUIPACK then
ui:setUIPack(g_mobileMode and UIPATH.."装备提示UIm.pack"or UIPATH.."装备提示UI.pack")
else
ui:setLayout(g_mobileMode and UIPATH.."装备提示UIm.layout"or UIPATH.."装备提示UI.layout")
end
end

