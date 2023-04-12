module(...,package.seeall)

local 全局设置=require("公用.全局设置")
local 游戏设置=require("公用.游戏设置")
local 实用工具=require("公用.实用工具")
local 消息=require("网络.消息")
local 任务追踪UI=require("主界面.任务追踪UI")
local 技能逻辑=require("技能.技能逻辑")
local 物品提示UI=require("主界面.物品提示UI")
local 装备提示UI=require("主界面.装备提示UI")
local 宠物蛋提示UI=require("主界面.宠物蛋提示UI")
local 小地图UI=require("主界面.小地图UI")
local 背包UI=require("主界面.背包UI")
local 仓库UI=require("主界面.仓库UI")
local 装备分解UI=require("主界面.装备分解UI")
local 商店UI=require("主界面.商店UI")
local 交易UI=require("主界面.交易UI")
local 角色逻辑=require("主界面.角色逻辑")
local 消息框UI1=require("主界面.消息框UI1")
local 主界面UI=require("主界面.主界面UI")
local 锻造UI=require("主界面.锻造UI")
local 福利UI=require("主界面.福利UI")
local 个人副本UI=require("主界面.个人副本UI")
local Boss副本UI=require("主界面.Boss副本UI")
local 宠物UI=require("宠物.宠物UI")
local 聊天UI=require("主界面.聊天UI")

对话_打开仓库=901
对话_打开分解=902
对话_打开修理=903
对话_打开特殊修理=904
对话_打开商店=101
对话_打开结束=1000
对话_打开强化=911
对话_打开洗练=912
对话_打开附魔=913
对话_打开合成=914
对话_打开进阶=915
对话_打开镶嵌=916
对话_扩展仓库1=917
对话_扩展仓库2=918
对话_扩展仓库3=919
对话_扩展仓库4=920
对话_扩展仓库5=921
对话_扩展仓库6=922
对话_扩展仓库7=923
对话_扩展仓库8=924
对话_扩展仓库9=925
对话_扩展仓库10=926
对话_打开福利=927
对话_打开副本=928
对话_打开BOSS=929
对话_打开宠物=930
对话_打开锻造=931

m_init=false
m_objid=0
m_objpos=nil
m_bodyid=0
m_oldbodyid=0
m_effid=0
m_oldeffid=0
m_desc=""
m_talk=nil
m_taskid=0
m_state=0
m_prize=nil
m_avt=nil
m_grids={}
m_gridimgs={}
m_gradeimgs={}
m_lockimgs={}
m_uitype=1
m_callput={}
m_itemdata=nil
m_isPayNpc=false
m_uipostype=""
m_uiwidth=0
m_uiheight=0
_v_836=0
_v_837=0
_v_838=false
tipsui=nil
tipsgrid=nil
layoutfile=""
layoutimgs={}
layoutitems={}
layoutitemboxs={}
layoutanims={}
layoutbtns={}
layoutcomps={}
layoutui=nil
layoutuimove=nil
layoutbtnanims={}
_v_851=nil
_v_852={}
uis={}

function setNpcBody(objid,bodyid,effid,desc,talk,taskid,state,prize)
m_isPayNpc=bodyid<0
m_objid=objid
m_bodyid=math.abs(bodyid)
m_effid=effid
m_desc=desc
m_talk=talk
m_taskid=taskid
m_state=state
m_prize={}
for i,v in ipairs(prize)do
m_prize[i]={
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
if g_target and g_target.objid==m_objid then
g_target:setAnimRotationZ(F3DUtils:calcDirection(g_role:getPositionX()-g_target:getPositionX(),g_role:getPositionY()-g_target:getPositionY()))
end
update()
end

function setItemData(itemdata)
local v=itemdata[1]
m_itemdata={
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
if tipsui and tipsgrid and 提示UI then

提示UI.setItemData(m_itemdata)
checkTipsPos()
end
end

prop1=F3DTweenProp:new()


function updatePosition()
	if not m_init or m_uipostype==""then
		return
	end
	if m_uipostype=="LT"then
		ui:setPositionX(_v_836)
		ui:setPositionY(_v_837)
	elseif m_uipostype=="RT"then
		ui:setPositionX(_v_836+stage:getWidth()-m_uiwidth)
		ui:setPositionY(_v_837)
	elseif m_uipostype=="LB"then
		ui:setPositionX(_v_836)
		ui:setPositionY(_v_837+stage:getHeight()-m_uiheight)
	elseif m_uipostype=="RB"then
		ui:setPositionX(_v_836+stage:getWidth()-m_uiwidth)
		ui:setPositionY(_v_837+stage:getHeight()-m_uiheight)
	else
		ui:setPositionX(_v_836+math.floor((stage:getWidth()-m_uiwidth)/2))
		ui:setPositionY(_v_837+math.floor((stage:getHeight()-m_uiheight)/2))
	end
end

function updateBtnAnims(_v_864)
	if not m_init then
		return
	end
	if not _v_864 then
		for k,v in pairs(layoutbtnanims)do
			v[9]=v[9]+100
			if v[9]>=v[5]then
				v[8]=v[8]+1
				if v[8]>=v[2]+v[4]then
					v[8]=v[2]
					v[10]=v[10]+1
				end
				if v[7]>0 and v[10]>=v[7]then
					k:setVisible(false)
					layoutbtnanims[k]=nil
				else
					k:setBackground("/res/icon/"..v[1]..string.format("%05d",v[8])..".png")
					if v[3]==1 and k:getBackground().setOffsetTxt then
						k:getBackground():setOffsetTxt("/res/icon/"..v[1].."Placements/"..string.format("%05d",v[8])..".txt")
					end
				v[9]=0
				end
			end
		end
	end
	if _v_838 then
		if _v_851 and _v_851:getWidth()>0 then
			_v_836=0
			_v_837=0
			m_uiwidth=_v_851:getWidth()
			m_uiheight=_v_851:getHeight()
			if not layoutui then
				layoutui=F3DComponent:new()
				layoutui:setPositionX(0)
				layoutui:setPositionY(0)
				layoutui:setWidth(m_uiwidth)
				layoutui:setHeight(m_uiheight)
				ui:addChild(layoutui,ui.talktxtindex)
			else
				layoutui:setWidth(m_uiwidth)
				layoutui:setHeight(m_uiheight)
			end
	ui:setWidth(m_uiwidth)
	ui:setHeight(m_uiheight)
	updatePosition()
	_v_851:setPositionX(0)
	_v_851:setPositionY(0)
	_v_851:setVisible(true)
	_v_851=nil
	end
	for k,v in ipairs(_v_852)do
	for ii,vv in ipairs(v)do
	if(vv.itemimg and vv.itemimg:getWidth()==0)or(vv.itemimg==nil and vv:getWidth()==0)then
	return
	end
	end
	end
	local desc=""
	local _v_865=1
	for k,v in ipairs(_v_852)do
	local _v_866=0
	for ii,vv in ipairs(v)do
	local width=vv.itemimg and vv.itemimg:getWidth()or vv:getWidth()
	vv:setPositionX(vv:getPositionX()+_v_866-(vv.itembox and v[ii-1]:getWidth()or 0))
	vv:setVisible(true)
	if vv.itemboxindex and layoutitemboxs[vv.itemboxindex]then
	layoutitemboxs[vv.itemboxindex][1]=layoutitemboxs[vv.itemboxindex][1]+_v_866-(vv.itembox and v[ii-1]:getWidth()or 0)
	end
	if not vv.itembox then
	_v_866=_v_866+width
	end
	if vv.itemimg then
	vv:setWidth(vv.itemimg:getWidth())
	vv:setHeight(vv.itemimg:getHeight())
	vv.itemimg:setPositionX(math.floor(vv:getWidth()/2))
	vv.itemimg:setPositionY(math.floor(vv:getHeight()/2))
	vv.img:setPositionX(math.floor(vv:getWidth()/2))
	vv.img:setPositionY(math.floor(vv:getHeight()/2))
	vv.gimg:setWidth(vv:getWidth()-2)
	vv.gimg:setHeight(vv:getHeight()-2)
	vv.limg:setPositionX(4)
	vv.limg:setPositionY(vv:getHeight()-4)
	vv.count:setPositionX(vv:getWidth()-(g_mobileMode and 8 or 2))
	vv.count:setPositionY(vv:getHeight()-(g_mobileMode and 8 or 2))
	end
	if vv.descindex and vv.descindex-1>=1 and vv.descindex<m_desc:len()then
	local str=m_desc:sub(vv.descindex,(m_desc:find("#n",vv.descindex)or 0)-1)
	str=str:gsub("\t","")
	str=str:gsub(" ","")
	str=str:gsub("　","")
	if str:len()>0 and str~="#C"then
	local cnt=math.ceil(width/6)
	desc=desc..m_desc:sub(_v_865,vv.descindex-1)..string.rep("　",math.floor(cnt/2))..(cnt%2==1 and" "or"")
	_v_865=vv.descindex
	end
	end
	end
	end
	实用工具.DeleteTable(_v_852)
	if desc~=""then
	m_desc=desc..m_desc:sub(_v_865)
	local titlesize=12
	ui.talktxt:setTitleText("#s"..titlesize..","..txt(m_desc:gsub("#n","#n#s"..math.ceil(titlesize*1.1)..",#s"..titlesize..",")))
	end
	end
end

function update()
if not m_init or(m_objid==-1 and m_desc=="")then
return
end
_v_838=false
ui.addindexhind=ui.talktxtindex
ui.addindex=ui.talktxtindex+1
if layoutui then
layoutui:removeFromParent(true)
layoutui=nil
end
if layoutuimove then
layoutuimove:removeFromParent(true)
layoutuimove=nil
end
local fontsize=0
if m_desc:sub(1,4)=="[LT:"or m_desc:sub(1,4)=="[RT:"or m_desc:sub(1,4)=="[LB:"or m_desc:sub(1,4)=="[RB:"or m_desc:sub(1,4)=="[CT:"then
local p1=m_desc:find("]",5)
if p1 and m_desc:sub(p1-1,p1-1)==_v_177 then
_v_838=true
end
local s=实用工具.SplitString(m_desc:sub(5,_v_838 and p1-2 or p1-1),"|")
if _v_838 then
fontsize=12
elseif g_mobileMode and#s>2 then
fontsize=tonumber(s[3])or 12
elseif#s>1 then
fontsize=tonumber(s[2])or 12
else
fontsize=12
end
local ss=实用工具.SplitString(s[1],";")
if ss[2]=="1"then
ui.close:setPositionX(tonumber(ss[(g_mobileMode and#ss>4)and 5 or 3])or 0)
ui.close:setPositionY(tonumber(ss[(g_mobileMode and#ss>4)and 6 or 4])or 0)
ui.close:setVisible(true)
else
ui.close:setVisible(false)
end
ss=实用工具.SplitString(ss[1],":")
m_uipostype=m_desc:sub(2,3)
local index=(g_mobileMode and#ss>6)and 6 or 0
if ss[index+1]:find(",")then
m_uiwidth=tonumber(ss[index+1]:sub(1,ss[index+1]:find(",")-1))or 0
_v_836=tonumber(ss[index+1]:sub(ss[index+1]:find(",")+1))or 0
else
m_uiwidth=tonumber(ss[index+1])or 0
_v_836=0
end
if ss[index+2]:find(",")then
m_uiheight=tonumber(ss[index+2]:sub(1,ss[index+2]:find(",")-1))or 0
_v_837=tonumber(ss[index+2]:sub(ss[index+2]:find(",")+1))or 0
else
m_uiheight=tonumber(ss[index+2])or 0
_v_837=0
end
local _v_869=tonumber(ss[index+5])or 0
local _v_870=tonumber(ss[index+6])or 0
m_desc=m_desc:sub(p1+1)
ui.titlebar:setVisible(false)
if m_uiwidth>0 and m_uiheight>0 then
layoutui=F3DComponent:new()
layoutui:setPositionX(0)
layoutui:setPositionY(0)
layoutui:setWidth(m_uiwidth)
layoutui:setHeight(m_uiheight)
ui:addChild(layoutui,ui.addindex)
ui.addindex=ui.addindex+1
end
if _v_869>0 and _v_870>0 then
layoutuimove=F3DComponent:new()
layoutuimove:setName("moverect")
layoutuimove:setPositionX(tonumber(ss[index+3])or 0)
layoutuimove:setPositionY(tonumber(ss[index+4])or 0)
layoutuimove:setWidth(_v_869)
layoutuimove:setHeight(_v_870)
ui:addChild(layoutuimove,ui.addindex)
ui.addindex=ui.addindex+1
end
ui:setWidth(m_uiwidth)
ui:setHeight(m_uiheight)
updatePosition()
else
m_uipostype=""
m_uiwidth=0
m_uiheight=0
ui.titlebar:setVisible(true)
ui.close:setVisible(true)
ui.close:setPositionX(ui.closex)
ui.close:setPositionY(ui.closey)
ui:setPositionX(ui.uiposx)
ui:setPositionY(ui.uiposy)
ui:setWidth(ui.uiwidth)
ui:setHeight(ui.uiheight)
end
if _v_838 or 游戏设置.NEWNPCTALK then
m_desc=m_desc:gsub("\\","#n")
m_desc=m_desc:gsub("\n","")
end
if _v_838 and g_mobileMode then
ui.talktxt:setPositionX(ui.talktxtx)
ui.talktxt:setPositionY(ui.talktxty)
--ui.talktxt:setPositionX(ui.talktxtx-10)
--ui.talktxt:setPositionY(ui.talktxty-10)
else
ui.talktxt:setPositionX(ui.talktxtx)
ui.talktxt:setPositionY(ui.talktxty)
end
_v_851=nil
实用工具.DeleteTable(_v_852)
for i,v in ipairs(layoutimgs)do
v:removeFromParent(true)
end
实用工具.DeleteTable(layoutimgs)
for i,v in ipairs(layoutitems)do
v:removeFromParent(true)
end
实用工具.DeleteTable(layoutitems)
实用工具.DeleteTable(layoutitemboxs)
for i,v in ipairs(layoutbtns)do
if v.iscreate then
v:removeFromParent(true)
else
v:removeEventListeners(F3DMouseEvent.CLICK)
end
end
实用工具.DeleteTable(layoutbtns)
实用工具.DeleteTable(layoutbtnanims)
for i,v in ipairs(layoutanims)do
v:removeFromParent(true)
end
实用工具.DeleteTable(layoutanims)
local _v_871=1
while 1 do
local p1=m_desc:find("<",_v_871)
local p2=p1 and m_desc:find(":",p1+1)or nil
if p1 and p2 and m_desc:sub(p1,p2)=="<img:"then
local p3=m_desc:find(">",p2+1)
local ss=实用工具.SplitString(m_desc:sub(p2+1,p3-1),":",true)
local index=(g_mobileMode and#ss>5)and 4 or 0
local img=F3DImage:new()
img:setTextureFile("/res/icon/"..ss[1])
if _v_851==nil and _v_838 then
_v_851=img
img:setVisible(false)
img:setPositionX(tonumber(ss[index+2])or 0)
img:setPositionY(tonumber(ss[index+3])or 0)
img:setWidth(0)
img:setHeight(0)
else
img:setVisible(true)
img:setPositionX(tonumber(ss[index+2])or 0)
img:setPositionY(tonumber(ss[index+3])or 0)
img:setWidth(tonumber(ss[index+4])or 0)
img:setHeight(tonumber(ss[index+5])or 0)
end
ui:addChild(img,ui.addindexhind)
ui.addindexhind=ui.addindexhind+1
ui.addindex=ui.addindex+1
layoutimgs[#layoutimgs+1]=img
m_desc=(p1-1>=1 and m_desc:sub(1,p1-1)or"")..(m_desc:len()>=p3+1 and m_desc:sub(p3+1)or"")
if _v_838 and _v_851==img and m_desc:sub(1,2)=="#n"then
m_desc=m_desc:sub(3)
end
elseif p1 and p2 and m_desc:sub(p1,p2)=="<item:"then
local p3=m_desc:find(">",p2+1)
local ss=实用工具.SplitString(m_desc:sub(p2+1,p3-1),":",true)
local index=(g_mobileMode and#ss>10)and 4 or 0
local item=F3DComponent:new()
local sss=实用工具.SplitString(ss[1],"|",true)
item.itemid=tonumber(sss[1])or 0
item.itemtype=tonumber(ss[6])or 0
if _v_838 then
local count,_v_674=实用工具.CountString(m_desc:sub(1,p1-1),"#n")
_v_852[count+1]=_v_852[count+1]or{}
for ii=count,1,-1 do
_v_852[ii]=_v_852[ii]or{}
end
_v_852[count+1][#_v_852[count+1]+1]=item
item.itembox=false
item.itemboxindex=nil
item.descindex=p1
item:setVisible(false)
item:setPositionX(20+聊天UI.calcTextWidth(m_desc:sub(_v_674,p1-1),12,true)+tonumber(ss[index+7])or 0)
item:setPositionY(16+count*16+tonumber(ss[index+8])or 0)
item:setWidth(0)
item:setHeight(0)
else
item:setVisible(true)
item:setPositionX(tonumber(ss[index+7])or 0)
item:setPositionY(tonumber(ss[index+8])or 0)
item:setWidth(tonumber(ss[index+9])or 0)
item:setHeight(tonumber(ss[index+10])or 0)
end
ui:addChild(item,ui.addindex)
ui.addindex=ui.addindex+1
item.itemindex=sss[2]or""
item:addEventListener(F3DMouseEvent.DOUBLE_CLICK,func_me(onGridDBClick))
item:addEventListener(F3DMouseEvent.RIGHT_CLICK,func_me(onGridDBClick))
if g_mobileMode then
item:addEventListener(F3DMouseEvent.CLICK,func_ue(onGridOver))
else
item:addEventListener(F3DUIEvent.MOUSE_OVER,func_ue(onGridOver))
item:addEventListener(F3DUIEvent.MOUSE_OUT,func_ue(onGridOut))
end
item.img=F3DImage:new()
item.img:setTextureFile(全局设置.getItemIconUrl(tonumber(ss[2])or 0))
item.img:setPositionX(math.floor(item:getWidth()/2))
item.img:setPositionY(math.floor(item:getHeight()/2))
item.img:setPivot(0.5,0.5)
if _v_838 then
item.itemimg=item.img
end
item:addChild(item.img)
item.gimg=F3DImage:new()
item.gimg:setTextureFile(全局设置.getGradeUrl(tonumber(ss[3])or 0))
item.gimg:setPositionX(1)
item.gimg:setPositionY(1)
item.gimg:setWidth(item:getWidth()-2)
item.gimg:setHeight(item:getHeight()-2)
item:addChild(item.gimg)
item.limg=F3DImage:new()
item.limg:setTextureFile(tonumber(ss[5])==1 and UIPATH.."公用/grid/img_bind.png"or"")
item.limg:setPositionX(4)
item.limg:setPositionY(item:getHeight()-4)
item.limg:setPivot(0,1)
item:addChild(item.limg)
item.count=F3DTextField:new()
if g_mobileMode then
item.count:setTextFont("宋体",24,false,false,false)
end
item.count:setText((tonumber(ss[4])or 1)>1 and(tonumber(ss[4])or 1)or"")
item.count:setPositionX(item:getWidth()-(g_mobileMode and 8 or 2))
item.count:setPositionY(item:getHeight()-(g_mobileMode and 8 or 2))
item.count:setPivot(1,1)
item:addChild(item.count)
item.effect=nil
item.itempos=nil
layoutitems[#layoutitems+1]=item
m_desc=(p1-1>=1 and m_desc:sub(1,p1-1)or"")..(m_desc:len()>=p3+1 and m_desc:sub(p3+1)or"")
elseif p1 and p2 and m_desc:sub(p1,p2)=="<itembox:"then
local p3=m_desc:find(">",p2+1)
local ss=实用工具.SplitString(m_desc:sub(p2+1,p3-1),":",true)
local index=(g_mobileMode and#ss>10)and 8 or 0
local count,_v_674=实用工具.CountString(m_desc:sub(1,p1-1),"#n")
if ss[1]~=""then
local img=F3DImage:new()
img:setTextureFile("/res/icon/"..ss[1])
if _v_838 then
_v_852[count+1]=_v_852[count+1]or{}
for ii=count,1,-1 do
_v_852[ii]=_v_852[ii]or{}
end
_v_852[count+1][#_v_852[count+1]+1]=img
img.itembox=false
img.itemboxindex=nil
img.itemimg=nil
img.descindex=p1
img:setVisible(false)
img:setPositionX(20+聊天UI.calcTextWidth(m_desc:sub(_v_674,p1-1),12,true)+tonumber(ss[index+3])or 0)
img:setPositionY(16+count*16+tonumber(ss[index+4])or 0)
img:setWidth(tonumber(ss[index+5])or 0)
img:setHeight(tonumber(ss[index+6])or 0)
else
img:setVisible(true)
img:setPositionX(tonumber(ss[index+3])or 0)
img:setPositionY(tonumber(ss[index+4])or 0)
img:setWidth(tonumber(ss[index+5])or 0)
img:setHeight(tonumber(ss[index+6])or 0)
end
ui:addChild(img,ui.addindexhind)
ui.addindexhind=ui.addindexhind+1
ui.addindex=ui.addindex+1
layoutimgs[#layoutimgs+1]=img
end
local item=F3DComponent:new()
if _v_838 then
_v_852[count+1]=_v_852[count+1]or{}
for ii=count,1,-1 do
_v_852[ii]=_v_852[ii]or{}
end
_v_852[count+1][#_v_852[count+1]+1]=item
item.itembox=ss[1]~=""
item.itemimg=nil
item.descindex=nil
item:setVisible(false)
item:setPositionX(20+聊天UI.calcTextWidth(m_desc:sub(_v_674,p1-1),12,true)+tonumber(ss[index+7])or 0)
item:setPositionY(16+count*16+tonumber(ss[index+8])or 0)
item:setWidth(tonumber(ss[index+9])or 0)
item:setHeight(tonumber(ss[index+10])or 0)
else
item:setVisible(true)
item:setPositionX(tonumber(ss[index+7])or 0)
item:setPositionY(tonumber(ss[index+8])or 0)
item:setWidth(tonumber(ss[index+9])or 0)
item:setHeight(tonumber(ss[index+10])or 0)
end
ui:addChild(item,ui.addindex)
ui.addindex=ui.addindex+1
item.itemindex=nil
item:addEventListener(F3DMouseEvent.DOUBLE_CLICK,func_me(onGridDBClick))
item:addEventListener(F3DMouseEvent.RIGHT_CLICK,func_me(onGridDBClick))
if g_mobileMode then
item:addEventListener(F3DMouseEvent.CLICK,func_ue(onGridOver))
else
item:addEventListener(F3DUIEvent.MOUSE_OVER,func_ue(onGridOver))
item:addEventListener(F3DUIEvent.MOUSE_OUT,func_ue(onGridOut))
end
local _v_878=0
local _v_879=ss[2]:find("|")
if _v_879 then
local _v_880=ss[2]:sub(_v_879+1)
if _v_880~=""then
item.griduptips=txt(_v_880)
item.griduptips=item.griduptips:gsub("@@","@")
item.griduptips=item.griduptips:gsub("@1","#n")
item.griduptips=item.griduptips:gsub("@2",",")
item.griduptips=item.griduptips:gsub("@3","#")
item.griduptips=item.griduptips:gsub("@4",":")
item:addEventListener(F3DMouseEvent.MOUSE_UP,func_ue(onGridUp))
end
ss[2]=ss[2]:sub(1,_v_879-1)
end
local _v_879=ss[2]:find(",")
if _v_879 then
_v_878=tonumber(ss[2]:sub(_v_879+1))or 0
ss[2]=ss[2]:sub(1,_v_879-1)
end
item.img=F3DImage:new()
item.img:setPositionX(math.floor(item:getWidth()/2))
item.img:setPositionY(math.floor(item:getHeight()/2))
item.img:setPivot(0.5,0.5)
item:addChild(item.img)
item.gimg=F3DImage:new()
item.gimg:setPositionX(1)
item.gimg:setPositionY(1)
item.gimg:setWidth(item:getWidth()-2)
item.gimg:setHeight(item:getHeight()-2)
item:addChild(item.gimg)
item.limg=F3DImage:new()
item.limg:setPositionX(4)
item.limg:setPositionY(item:getHeight()-4)
item.limg:setPivot(0,1)
item:addChild(item.limg)
item.count=F3DTextField:new()
if g_mobileMode then
item.count:setTextFont("宋体",24,false,false,false)
end
item.count:setPositionX(item:getWidth()-(g_mobileMode and 8 or 2))
item.count:setPositionY(item:getHeight()-(g_mobileMode and 8 or 2))
item.count:setPivot(1,1)
item:addChild(item.count)
item.strengthen=F3DTextField:new()
if g_mobileMode then
item.strengthen:setTextFont("宋体",24,false,false,false)
end
item.strengthen:setPositionX(item:getWidth()-(g_mobileMode and 8 or 2))
item.strengthen:setPositionY(g_mobileMode and 8 or 2)
item.strengthen:setPivot(1,0)
item:addChild(item.strengthen)
item.effect=nil
if _v_838 then
item.itemboxindex=tonumber(ss[2])or 0
end
item.itempos=nil
layoutitems[#layoutitems+1]=item
layoutitemboxs[tonumber(ss[2])or 0]={
_v_838 and 20+聊天UI.calcTextWidth(m_desc:sub(_v_674,p1-1),12,true)+(tonumber(ss[index+3])or 0)or(tonumber(ss[index+3])or 0),
_v_838 and 16+count*16+(tonumber(ss[index+4])or 0)or(tonumber(ss[index+4])or 0),
(tonumber(ss[index+5])or 50),
(tonumber(ss[index+6])or 50),item}
if _v_878>0 and 背包UI.m_itemdata[_v_878]then
setItemBoxItem(tonumber(ss[2])or 0,背包UI.m_itemdata[_v_878])
end
m_desc=(p1-1>=1 and m_desc:sub(1,p1-1)or"")..(m_desc:len()>=p3+1 and m_desc:sub(p3+1)or"")
elseif p1 and p2 and m_desc:sub(p1,p2)=="<btn:"then
local p3=m_desc:find(">",p2+1)
local ss=实用工具.SplitString(m_desc:sub(p2+1,p3-1),":",true)
local _v_883=实用工具.SplitString(ss[1],";",true)
local _v_884=_v_883[1]
local _v_885=_v_883[2]
local _v_886=_v_883[3]
local btn=ui:findComponent(ss[1])
if btn then
if _v_885 and _v_885~=""then
btn:setTitleText(txt(_v_885))
end
btn:setTouchable(true)
btn:addEventListener(F3DMouseEvent.CLICK,func_me(function(e)
onLinkTalkTxt(txt(ss[2]),txt(ss[3]),txt(ss[4]),txt(ss[5]),txt(ss[6]),txt(ss[7]))
end
))
btn.iscreate=false
layoutbtns[#layoutbtns+1]=btn
else
local sss=实用工具.SplitString(_v_884,",",true)
btn=F3DComponent:new()
local ssss=实用工具.SplitString(sss[1],"|",true)
if#ssss>2 and(tonumber(ssss[2])or 0)>0 and(tonumber(ssss[3])or 0)>0 then
btn:setBackground("/res/icon/"..ssss[1])
local _v_879=实用工具.FindLast(ssss[1],"/")
local id=tonumber(实用工具.TrimPostfix(ssss[1]:sub(_v_879+1)))or 0
layoutbtnanims[btn]={ssss[1]:sub(1,_v_879),id,tonumber(ssss[6])or 0,tonumber(ssss[2])or 0,tonumber(ssss[3])or 0,tonumber(ssss[4])or 0,tonumber(ssss[5])or 0,id,0,0}
elseif#ssss>2 and btn.setStateSkin then
btn:setStateSkin("/res/icon/"..ssss[1],0)
btn:setStateSkin("/res/icon/"..ssss[2],1)
btn:setStateSkin("/res/icon/"..ssss[3],2)
else
btn:setBackground("/res/icon/"..ssss[1])
if sss[2]=="2"or sss[2]=="3"then
btn:setSizeClips("1,"..sss[2]..",0,0")
end
end
local index=(g_mobileMode and#sss>6)and 4 or 0
if _v_838 then
local count,_v_674=实用工具.CountString(m_desc:sub(1,p1-1),"#n")
_v_852[count+1]=_v_852[count+1]or{}
for ii=count,1,-1 do
_v_852[ii]=_v_852[ii]or{}
end
_v_852[count+1][#_v_852[count+1]+1]=btn
btn.itembox=false
btn.itemboxindex=nil
btn.itemimg=nil
btn.descindex=p1
btn:setVisible(false)
btn:setPositionX(20+聊天UI.calcTextWidth(m_desc:sub(_v_674,p1-1),12,true)+tonumber(sss[index+3])or 0)
btn:setPositionY(16+count*16+tonumber(sss[index+4])or 0)
btn:setWidth(0)
btn:setHeight(0)
else
btn:setVisible(true)
btn:setPositionX(tonumber(sss[index+3])or 0)
btn:setPositionY(tonumber(sss[index+4])or 0)
btn:setWidth(tonumber(sss[index+5])or 0)
btn:setHeight(tonumber(sss[index+6])or 0)
end
if _v_885 and _v_885~=""then
btn:setTitleAlign(8)
btn:setTitleText(txt(_v_885))
end
if _v_886 and _v_886~=""then
btn:setTextColor(tonumber(_v_886)or 0)
end
if#ss==1 or tonumber(ss[2])==-3 then
btn:setTouchable(false)
else
btn:setTouchable(true)
btn:addEventListener(F3DMouseEvent.CLICK,func_me(function(e)
onLinkTalkTxt(txt(ss[2]),txt(ss[3]),txt(ss[4]),txt(ss[5]),txt(ss[6]),txt(ss[7]))
end
))
end
if#ss==1 or tonumber(ss[2])==-3 then
ui:addChild(btn,ui.addindexhind)
ui.addindexhind=ui.addindexhind+1
ui.addindex=ui.addindex+1
else
ui:addChild(btn,ui.addindex)
ui.addindex=ui.addindex+1
end
btn.iscreate=true
layoutbtns[#layoutbtns+1]=btn
end
m_desc=(p1-1>=1 and m_desc:sub(1,p1-1)or"")..(m_desc:len()>=p3+1 and m_desc:sub(p3+1)or"")
elseif p1 and p2 and m_desc:sub(p1,p2)=="<anim:"then
local p3=m_desc:find(">",p2+1)
local ss=实用工具.SplitString(m_desc:sub(p2+1,p3-1),":",true)
local index=(g_mobileMode and#ss>5)and 4 or 0
local anim=F3DImageAnim:new()
anim:setAnimPack(全局设置.getAnimPackUrl(tonumber(ss[1])or 0))
if(tonumber(ss[2])or 0)>0 then
F3DTween:fromPool():start(anim,prop1,tonumber(ss[2]),func_n(function()
anim:setVisible(false)
end))
end
anim:setBlendType(tonumber(ss[3])or 0)
anim:setPositionX(tonumber(ss[index+4])or 0)
anim:setPositionY(tonumber(ss[index+5])or 0)
anim:setScaleX((tonumber(ss[index+6])or 100)/100)
anim:setScaleY((tonumber(ss[index+7])or 100)/100)
ui:addChild(anim,ui.addindexhind)
ui.addindexhind=ui.addindexhind+1
ui.addindex=ui.addindex+1
layoutanims[#layoutanims+1]=anim
m_desc=(p1-1>=1 and m_desc:sub(1,p1-1)or"")..(m_desc:len()>=p3+1 and m_desc:sub(p3+1)or"")
elseif p1 and p2 then
_v_871=p1+1
else
break
end
end
local oldcomp=ui.talktxt
local _v_889=1
for i,v in ipairs(layoutcomps)do
if v.iscreate then
v:removeFromParent(true)
else
v:setTitleText(" ")
v:removeEventListeners(F3DUIEvent.LINK_DOWN)
end
end
实用工具.DeleteTable(layoutcomps)
while 1 do
local p1,p2=m_desc:find("<comp:")
if p1 and p2 then
local p3=m_desc:find(">",p2+1)
local _v_890=m_desc:sub(p2+1,p3-1)
local comp=tt(ui:findComponent(_v_890),F3DRichTextField)
if not comp and _v_890:find(":")then
local ss=实用工具.SplitString(_v_890,":",true)
local index=(g_mobileMode and#ss>2)and 2 or 0
comp=F3DRichTextField:new()
comp:setPositionX(tonumber(ss[index+1])or 0)
comp:setPositionY(tonumber(ss[index+2])or 0)
comp:setTitleFont(oldcomp:getTitleFont())
comp.iscreate=true
ui:addChild(comp,ui.addindex)
ui.addindex=ui.addindex+1
end
if comp then
local desc=p1-1>=1 and m_desc:sub(1,p1-1)or""
local str=desc:gsub("\n","#n").."#n"
local titlefont=实用工具.SplitString(oldcomp:getTitleFont(),",",true)
local titlesize=fontsize>0 and fontsize or(tonumber(titlefont[2])or 12)
oldcomp:setTitleText("#s"..titlesize..","..txt(str:gsub("#n","#n#s"..math.ceil(titlesize*(_v_838 and 1.1 or g_mobileMode and 1.3 or 1.3))..",#s"..titlesize..",")))
oldcomp:setTouchable(str:find("#l")~=nil)
comp:addEventListener(F3DUIEvent.LINK_DOWN,func_ue(onLinkDown))
layoutcomps[#layoutcomps+1]=comp
m_desc=m_desc:len()>=p3+1 and m_desc:sub(p3+1)or""
if 实用工具.CountString(str,"#n",true)>9 then
_v_889=2
end
oldcomp=comp
end
else
break
end
end
local str=m_desc:gsub("\n","#n").."#n"
if m_talk then
for i,v in ipairs(m_talk)do
str=str.."#n  #u#lc0000ff:"..v[3]..",#c"..F3DUtils:toString(v[2],16)..","..v[1].."#L#U#C"
end
end
if m_taskid~=0 then
if m_state==0 then
str=str.."#n  #u#lc0000ff:"..m_state..",#cff00,接受任务#L#U#C"
elseif m_state==2 then
str=str.."#n  #u#lc0000ff:"..m_state..",#cff00,完成任务#L#U#C"
end
end
local titlefont=实用工具.SplitString(oldcomp:getTitleFont(),",",true)
local titlesize=fontsize>0 and fontsize or(tonumber(titlefont[2])or 12)
oldcomp:setTitleText("#s"..titlesize..","..txt(str:gsub("#n","#n#s"..math.ceil(titlesize*(_v_838 and 1.1 or g_mobileMode and 1.3 or 1.3))..",#s"..titlesize..",")))
oldcomp:setTouchable(str:find("#l")~=nil)
if layoutfile==""then
if not m_avt then
if ISMIR2D then
m_avt=F3DImageAnim3D:new()
m_avt:setImage2D(true)
else
m_avt=F3DAvatar:new()
end
ui.avtcont:addChild(m_avt)
end
if m_oldbodyid~=m_bodyid or m_oldeffid~=m_effid then
local url=ISMIR2D and 全局设置.getAnimPackUrl(m_bodyid)or 全局设置.getModelUrl(m_bodyid)
m_avt:reset()
if url~=""then
if ISMIR2D then
m_avt:setScaleX(1)
m_avt:setScaleY(1)
m_avt:setEntity(F3DImageAnim3D.PART_BODY,url)
else
m_avt:setScale(2,2,2)
m_avt:setLighting(true)
m_avt:setEntity(F3DAvatar.PART_BODY,url)
m_avt:setAnimSet(F3DUtils:trimPostfix(url)..".txt")
if m_effid~=0 then
m_avt:setEffectSystem(全局设置.getEffectUrl(m_effid))
end
end
end
m_oldbodyid=m_bodyid
m_oldeffid=m_effid
end
local role=g_roles[m_objid]
if role and role.name then
local p=role.name:find("\\")
ui.myname:setTitleText(p and txt(role.name:sub(1,p-1))or txt(role.name))
else
ui.myname:setTitleText("")
end
for i=1,6 do
m_grids[i]:setVisible(m_taskid~=0)
if#m_prize>=i then
m_grids[i].count:setText(m_prize[i].count>1 and m_prize[i].count or"")
m_gridimgs[i]:setTextureFile(全局设置.getItemIconUrl(m_prize[i].icon))
m_gradeimgs[i]:setTextureFile(全局设置.getGradeUrl(m_prize[i].grade))
m_lockimgs[i]:setTextureFile(m_prize[i].bind==1 and UIPATH.."公用/grid/img_bind.png"or"")
else
m_grids[i].count:setText("")
m_gridimgs[i]:setTextureFile("")
m_gradeimgs[i]:setTextureFile("")
m_lockimgs[i]:setTextureFile("")
end
end
if 实用工具.CountString(str,"#n",true)>9 then
_v_889=2
end
updateUISize(_v_889)
end
updateBtnAnims(true)
end

function updateUISize(type)
if type==2 and m_uitype==1 then
ui.titlebar:setHeight(ui.titlebar:getHeight()+(g_mobileMode and 242 or 172))
ui.avtcont:setPositionY(ui.avtcont:getPositionY()+(g_mobileMode and 242 or 172))
ui.myname:setPositionY(ui.myname:getPositionY()+(g_mobileMode and 242 or 172))
for i=1,6 do
m_grids[i]:setPositionY(m_grids[i]:getPositionY()+(g_mobileMode and 242 or 172))
end
m_uitype=2
elseif type==1 and m_uitype==2 then
ui.titlebar:setHeight(ui.titlebar:getHeight()-(g_mobileMode and 242 or 172))
ui.avtcont:setPositionY(ui.avtcont:getPositionY()-(g_mobileMode and 242 or 172))
ui.myname:setPositionY(ui.myname:getPositionY()-(g_mobileMode and 242 or 172))
for i=1,6 do
m_grids[i]:setPositionY(m_grids[i]:getPositionY()-(g_mobileMode and 242 or 172))
end
m_uitype=1
end
end

function onOK(rolename)
if rolename==nil or rolename==""then
主界面UI.showTipsMsg(1,txt("请输入您的名字"))
return
end
if rolename:len()>15 then
主界面UI.showTipsMsg(1,txt("名字字数超过上限"))
return
end
消息.CG_CREATE_ROLE(utf8(rolename),角色逻辑.m_rolesex,角色逻辑.m_rolejob)
end

function onPut(rolename)
if rolename==nil or rolename==""then
主界面UI.showTipsMsg(1,txt("请输入文本或有效数字"))
return
end
if rolename:len()>84 then
主界面UI.showTipsMsg(1,txt("文本字数超过上限"))
return
end
if m_callput.type~=1 and tonumber(rolename)==nil then
主界面UI.showTipsMsg(1,txt("请输入有效的数字"))
return
end
消息.CG_NPC_TALK_PUT(m_objid,m_callput.talkid or 0,m_callput.type or 0,m_callput.callid or 0,utf8(rolename))
end

function onLinkTalkTxt(talktxt,calltype,callid,calltxt,msg1,msg2)
if tonumber(talktxt)==-2 and calltype then
calltype=calltype:gsub("@@","@")
calltype=calltype:gsub("@1","#n")
calltype=calltype:gsub("@2",",")
calltype=calltype:gsub("@3","#")
calltype=calltype:gsub("@4",":")
消息框UI1.initUI()
消息框UI1.setData(calltype,nil,nil,nil,nil,true)
return
end
local sss=talktxt:sub(1,1)=="-"and 实用工具.SplitString(talktxt:sub(2),"-")or 实用工具.SplitString(talktxt,"-")
local talkid=talktxt:sub(1,1)=="-"and-(tonumber(sss[1])or 0)or(tonumber(sss[1])or 0)
local operid=游戏设置.OLDNPCMODE and talkid or(tonumber(sss[2])or 0)
local isclose=talkid==-1 or tonumber(sss[2])==1 or tonumber(sss[3])==1
if operid==对话_打开仓库 then
	背包UI.initUI()
	if 背包UI.m_init then
		消息.CG_STORE_QUERY(0)
		仓库UI.initUI()
		装备分解UI.hideUI()
		商店UI.hideUI()
		交易UI.hideUI()
		背包UI.otherui=仓库UI
		背包UI.checkResize()
	else
		背包UI.ui:addEventListener(F3DObjEvent.OBJ_INITED,func_e(function(e)
		消息.CG_STORE_QUERY(0)
		仓库UI.initUI()
		装备分解UI.hideUI()
		商店UI.hideUI()
		交易UI.hideUI()
		背包UI.otherui=仓库UI
		背包UI.checkResize()
		end))
	end
elseif 游戏设置.OLDNPCMODE and operid>对话_打开仓库 and operid<=对话_打开结束 then
	背包UI.initUI()
	if 背包UI.m_init then

		商店UI.setTalkID(operid)
		商店UI.initUI()
		交易UI.hideUI()
		装备分解UI.hideUI()
		仓库UI.hideUI()
		背包UI.otherui=商店UI
		背包UI.checkResize()
	else
		背包UI.ui:addEventListener(F3DObjEvent.OBJ_INITED,func_e(function(e)
		商店UI.setTalkID(operid)
		商店UI.initUI()
		交易UI.hideUI()
		装备分解UI.hideUI()
		仓库UI.hideUI()
		背包UI.otherui=商店UI
		背包UI.checkResize()
		end))
	end
elseif operid==对话_打开分解 then
背包UI.initUI()
if 背包UI.m_init then
装备分解UI.initUI()
商店UI.hideUI()
交易UI.hideUI()
仓库UI.hideUI()
背包UI.otherui=装备分解UI
背包UI.checkResize()
else
背包UI.ui:addEventListener(F3DObjEvent.OBJ_INITED,func_e(function(e)
装备分解UI.initUI()
商店UI.hideUI()
交易UI.hideUI()
仓库UI.hideUI()
背包UI.otherui=装备分解UI
背包UI.checkResize()
end))
end
elseif VIPLEVEL>=4 and operid==对话_打开修理 then
锻造UI.setShowType(1,"请放入装备进行修理(不减持久)",1)
锻造UI.initUI()
elseif VIPLEVEL>=4 and operid==对话_打开特殊修理 then
锻造UI.setShowType(1,"请放入装备进行修理(不减持久)",2)
锻造UI.initUI()
elseif VIPLEVEL>=4 and operid==对话_打开强化 then
锻造UI.setShowType(0,"请在左侧放入装备,右侧放入装备强化石")
锻造UI.initUI()
elseif VIPLEVEL>=4 and operid==对话_打开洗练 then
锻造UI.setShowType(0,"请在左侧放入装备,右侧放入装备洗练石")
锻造UI.initUI()
elseif VIPLEVEL>=4 and operid==对话_打开附魔 then
锻造UI.setShowType(0,"请在左侧放入装备,右侧放入装备附魔石")
锻造UI.initUI()
elseif VIPLEVEL>=4 and operid==对话_打开合成 then
锻造UI.setShowType(0,"请在左侧放入碎片,右侧放入装备合成石")
锻造UI.initUI()
elseif VIPLEVEL>=4 and operid==对话_打开进阶 then
锻造UI.setShowType(3,"请在上格放入装备,下两格放入同类型品质装备")
锻造UI.initUI()
elseif VIPLEVEL>=4 and operid==对话_打开镶嵌 then
锻造UI.setShowType(0,"请在左侧放入装备,右侧放入宝石或符文")
锻造UI.initUI()
elseif operid==对话_扩展仓库1 then
消息.CG_STORE_QUERY(1)
elseif operid==对话_扩展仓库2 then
消息.CG_STORE_QUERY(2)
elseif operid==对话_扩展仓库3 then
消息.CG_STORE_QUERY(3)
elseif operid==对话_扩展仓库4 then
消息.CG_STORE_QUERY(4)
elseif operid==对话_扩展仓库5 then
消息.CG_STORE_QUERY(5)
elseif operid==对话_扩展仓库6 then
消息.CG_STORE_QUERY(6)
elseif operid==对话_扩展仓库7 then
消息.CG_STORE_QUERY(7)
elseif operid==对话_扩展仓库8 then
消息.CG_STORE_QUERY(8)
elseif operid==对话_扩展仓库9 then
消息.CG_STORE_QUERY(9)
elseif operid==对话_扩展仓库10 then
消息.CG_STORE_QUERY(10)
elseif operid==对话_打开福利 then
福利UI.initUI()
elseif operid==对话_打开副本 then
个人副本UI.initUI()
elseif operid==对话_打开BOSS then
Boss副本UI.initUI()
elseif operid==对话_打开宠物 then
if 宠物UI.m_isviewpet then
宠物UI.ChangePetInfo()
宠物UI.initUI()
else
宠物UI.initUI()
end
elseif operid==对话_打开锻造 then
锻造UI.setShowType(0,"")
锻造UI.initUI()
elseif operid>=对话_打开商店 and operid<对话_打开仓库 then
背包UI.initUI()
if 背包UI.m_init then
商店UI.setTalkID(operid)
商店UI.initUI()
交易UI.hideUI()
装备分解UI.hideUI()
仓库UI.hideUI()
背包UI.otherui=商店UI
背包UI.checkResize()
else
背包UI.ui:addEventListener(F3DObjEvent.OBJ_INITED,func_e(function(e)
商店UI.setTalkID(operid)
商店UI.initUI()
交易UI.hideUI()
装备分解UI.hideUI()
仓库UI.hideUI()
背包UI.otherui=商店UI
背包UI.checkResize()
end))
end
end
if isclose then
onCloseUI()
return
end
if tonumber(calltype)~=-2 and calltype and callid and tonumber(msg1)==-2 and msg2 then
m_callput.talkid=talkid
if calltype:find("%(")then
m_callput.type=tonumber(calltype:sub(1,calltype:find("%(")-1))or 0
m_callput.text=calltype:sub(calltype:find("%(")+0)
else
m_callput.type=tonumber(calltype)or 0
m_callput.text=m_callput.type==1 and txt("请输入有效文本")or txt("请输入有效数字")
end
m_callput.callid=tonumber(callid)or 0
m_callput.calltxt=calltxt
msg2=msg2:gsub("@@","@")
msg2=msg2:gsub("@1","#n")
msg2=msg2:gsub("@2",",")
msg2=msg2:gsub("@3","#")
msg2=msg2:gsub("@4",":")
消息框UI1.initUI()
消息框UI1.setData(msg2,function()
setDelayCallInput(onDelayCallInput)
end,nil,nil,nil,false)
elseif tonumber(calltype)~=-2 and calltype and callid then
m_callput.talkid=talkid
if calltype:find("%(")then
m_callput.type=tonumber(calltype:sub(1,calltype:find("%(")-1))or 0
m_callput.text=calltype:sub(calltype:find("%(")+0)
else
m_callput.type=tonumber(calltype)or 0
m_callput.text=m_callput.type==1 and txt("请输入有效文本")or txt("请输入有效数字")
end
m_callput.callid=tonumber(callid)or 0
m_callput.calltxt=calltxt
消息框UI1.initUI()
消息框UI1.setData(m_callput.text,onPut,nil,nil,calltxt and calltxt or true)


elseif tonumber(calltype)==-2 and callid then
callid=callid:gsub("@@","@")
callid=callid:gsub("@1","#n")
callid=callid:gsub("@2",",")
callid=callid:gsub("@3","#")
callid=callid:gsub("@4",":")
消息框UI1.initUI()
消息框UI1.setData(callid,(talkid>=0)and function()
消息.CG_NPC_TALK(m_objid,talkid,(背包UI.gzid or 1))
end or nil,nil,nil,nil,(talkid<0))
elseif tonumber(msg1)==-2 and msg2 then
msg2=msg2:gsub("@@","@")
msg2=msg2:gsub("@1","#n")
msg2=msg2:gsub("@2",",")
msg2=msg2:gsub("@3","#")
msg2=msg2:gsub("@4",":")
消息框UI1.initUI()
消息框UI1.setData(msg2,(talkid>=0)and function()
消息.CG_NPC_TALK(m_objid,talkid,(背包UI.gzid or 1))
end or nil,nil,nil,nil,(talkid<0))
elseif talkid>=0 then
消息.CG_NPC_TALK(m_objid,talkid,(背包UI.gzid or 1))
end
end

function onDelayCallInput()
消息框UI1.initUI()
消息框UI1.setData(m_callput.text,onPut,nil,nil,m_callput.calltxt and m_callput.calltxt or true)
end

function onLinkDown(e)
if 角色逻辑.m_rolename==""then
消息框UI1.initUI()
消息框UI1.setData(txt("#cffff00,千古留名: #C请留下您的#cff00ff,千古大名"),onOK,onOK,onOK,true)
return
end
local talktxt=e:getTarget()
if m_taskid==0 then
local ss=实用工具.SplitString(talktxt:getCurrLinkSrc(),":",true)
onLinkTalkTxt(ss[1],ss[2],ss[3],ss[4],ss[5],ss[6])
elseif m_state==0 then
消息.CG_ACCEPT_TASK(m_taskid)
onCloseUI()
elseif m_state==2 then
消息.CG_FINISH_TASK(m_taskid)
onCloseUI()
end
end

function checkTipsPos()
if not ui or not tipsgrid then
return
end
if not tipsui or not tipsui:isVisible()or not tipsui:isInited()then
else
local x=ui:getPositionX()+tipsgrid:getPositionX()+tipsgrid:getWidth()
local y=ui:getPositionY()+tipsgrid:getPositionY()
local p=tipsgrid:getParent()
while p and p~=ui do
x=x+p:getPositionX()
y=y+p:getPositionY()
p=p:getParent()
end
if x+tipsui:getWidth()>stage:getWidth()then
tipsui:setPositionX(x-tipsui:getWidth()-tipsgrid:getWidth())
else
tipsui:setPositionX(x)
end
if y+tipsui:getHeight()>stage:getHeight()then
tipsui:setPositionY(stage:getHeight()-tipsui:getHeight())
else
tipsui:setPositionY(y)
end
end
end

function checkItemBox(px,py)
px=px-ui:getPositionX()
py=py-ui:getPositionY()
for k,v in pairs(layoutitemboxs)do
if px>=v[1]and py>=v[2]and px<=v[1]+v[3]and py<=v[2]+v[4]then
return k
end
end
end

function updateItemBox(itemdatas)
for k,v in pairs(layoutitemboxs)do
if v[5].itempos and itemdatas[v[5].itempos]and itemdatas[v[5].itempos].count>0 then
local itemdata=itemdatas[v[5].itempos]
local item=v[5]
local 发光特效=0
for ii,vv in ipairs(itemdata.prop)do
if vv[1]==46 then
发光特效=vv[2]
end
end
for ii,vv in ipairs(itemdata.addprop)do
if vv[1]==46 then
发光特效=vv[2]
end
end
if 发光特效~=0 then
if not item.effect then
item.effect=F3DImageAnim:new()
item.effect:setBlendType(F3DRenderContext.BLEND_ADD)
item.effect:setPositionX(item:getWidth()/2)
item.effect:setPositionY(item:getHeight()/2)
item:addChild(item.effect)
end
item.effect:setAnimPack(全局设置.getAnimPackUrl(发光特效))
elseif item.effect then
item.effect:reset()
end
item.itemid=itemdata.id
item.itemtype=(itemdata.type==3 and itemdata.equippos==14)and 2 or itemdata.type==3 and 1 or 0
item.itempos=itemdata.pos
item.boxindex=k
item.img:setTextureFile(全局设置.getItemIconUrl(itemdata.icon))
item.gimg:setTextureFile(全局设置.getGradeUrl(itemdata.grade))
item.limg:setTextureFile(itemdata.bind==1 and UIPATH.."公用/grid/img_bind.png"or"")
item.count:setText(itemdata.count>1 and itemdata.count or"")
item.strengthen:setText(itemdata.strengthen>0 and"+"..itemdata.strengthen or"")
layoutitemboxs[k][6]=itemdata
else
local item=v[5]
if item.effect then
item.effect:reset()
end
item.itemid=nil
item.itemtype=nil
item.itempos=nil
item.boxindex=nil
item.img:setTextureFile("")
item.gimg:setTextureFile("")
item.limg:setTextureFile("")
item.count:setText("")
item.strengthen:setText("")
layoutitemboxs[k][6]=nil
end
end
end

function setItemBoxItem(k,itemdata)
if not itemdata or itemdata.count==0 or not layoutitemboxs[k]then
return
end
local item=layoutitemboxs[k][5]
local 发光特效=0
for ii,vv in ipairs(itemdata.prop)do
if vv[1]==46 then
发光特效=vv[2]
end
end
for ii,vv in ipairs(itemdata.addprop)do
if vv[1]==46 then
发光特效=vv[2]
end
end
if 发光特效~=0 then
if not item.effect then
item.effect=F3DImageAnim:new()
item.effect:setBlendType(F3DRenderContext.BLEND_ADD)
item.effect:setPositionX(item:getWidth()/2)
item.effect:setPositionY(item:getHeight()/2)
item:addChild(item.effect)
end
item.effect:setAnimPack(全局设置.getAnimPackUrl(发光特效))
elseif item.effect then
item.effect:reset()
end
item.itemid=itemdata.id
item.itemtype=(itemdata.type==3 and itemdata.equippos==14)and 2 or itemdata.type==3 and 1 or 0
item.itempos=itemdata.pos
item.boxindex=k
item.img:setTextureFile(全局设置.getItemIconUrl(itemdata.icon))
item.gimg:setTextureFile(全局设置.getGradeUrl(itemdata.grade))
item.limg:setTextureFile(itemdata.bind==1 and UIPATH.."公用/grid/img_bind.png"or"")
item.count:setText(itemdata.count>1 and itemdata.count or"")
item.strengthen:setText(itemdata.strengthen>0 and"+"..itemdata.strengthen or"")
layoutitemboxs[k][6]=itemdata
消息.CG_COMMAND_MSG(9,m_objid..","..k..","..itemdata.pos)
end

function onGridDBClick(e)
local g=e:getCurrentTarget()
local p=e:getLocalPos()
if g==nil or g.itemid==nil or g.itemtype==nil then
elseif g.itemindex then
if g.itemindex~=""then
物品提示UI.hideUI()
装备提示UI.hideUI()
宠物蛋提示UI.hideUI()
消息.CG_COMMAND_MSG(12,m_objid..","..g.itemindex)
end
else
if g.effect then
g.effect:reset()
end
g.itemid=nil
g.itemtype=nil
g.img:setTextureFile("")
g.gimg:setTextureFile("")
g.limg:setTextureFile("")
g.count:setText("")
g.strengthen:setText("")
物品提示UI.hideUI()
装备提示UI.hideUI()
宠物蛋提示UI.hideUI()
if g.boxindex and layoutitemboxs[g.boxindex]then
layoutitemboxs[g.boxindex][6]=nil
end
消息.CG_COMMAND_MSG(9,m_objid..","..(g.boxindex or 0)..",0")
g.itempos=nil
g.boxindex=nil
end
end

function onGridUp(e)
if ui.tweenhide then return end
local g=e:getCurrentTarget()
if g==nil then
elseif F3DUIManager.sTouchComp~=g then
elseif g.itemid and g.itemtype then
elseif g.griduptips then
消息框UI1.initUI()
消息框UI1.setData(g.griduptips,nil,nil,nil,nil,true)
end
end

function onGridOver(e)
if ui.tweenhide then return end
local g=g_mobileMode and e:getCurrentTarget()or e:getTarget()
if g==nil then
elseif F3DUIManager.sTouchComp~=g then
elseif g.itemid and g.itemtype then
提示UI=g.itemtype==2 and 宠物蛋提示UI or g.itemtype==1 and 装备提示UI or 物品提示UI
提示UI.initUI()
if g.boxindex and layoutitemboxs[g.boxindex]and layoutitemboxs[g.boxindex][6]then
提示UI.setItemData(layoutitemboxs[g.boxindex][6])
elseif not m_itemdata or m_itemdata.id~=g.itemid then
消息.CG_ITEM_QUERY(g.itemid,4)
提示UI.setEmptyItemData()
else
提示UI.setItemData(m_itemdata)
end
tipsui=提示UI.ui
tipsgrid=g
if not tipsui:isInited()then
tipsui:addEventListener(F3DObjEvent.OBJ_INITED,func_oe(checkTipsPos))
else
checkTipsPos()
end
elseif m_prize==nil or m_prize[g.id]==nil then
elseif m_prize[g.id].type==3 and m_prize[g.id].equippos==14 then
物品提示UI.hideUI()
装备提示UI.hideUI()
宠物蛋提示UI.initUI()
宠物蛋提示UI.setItemData(m_prize[g.id],false)
tipsui=宠物蛋提示UI.ui
tipsgrid=g
if not tipsui:isInited()then
tipsui:addEventListener(F3DObjEvent.OBJ_INITED,func_oe(checkTipsPos))
else
checkTipsPos()
end
elseif m_prize[g.id].type==3 then
物品提示UI.hideUI()
宠物蛋提示UI.hideUI()
装备提示UI.initUI()
装备提示UI.setItemData(m_prize[g.id],false)
tipsui=装备提示UI.ui
tipsgrid=g
if not tipsui:isInited()then
tipsui:addEventListener(F3DObjEvent.OBJ_INITED,func_oe(checkTipsPos))
else
checkTipsPos()
end
else
装备提示UI.hideUI()
宠物蛋提示UI.hideUI()
物品提示UI.initUI()
物品提示UI.setItemData(m_prize[g.id])
tipsui=物品提示UI.ui
tipsgrid=g
if not tipsui:isInited()then
tipsui:addEventListener(F3DObjEvent.OBJ_INITED,func_oe(checkTipsPos))
else
checkTipsPos()
end
end
end

function onGridOut(e)
local g=e:getTarget()
if g~=nil and g==tipsgrid and tipsui then
物品提示UI.hideUI()
装备提示UI.hideUI()
宠物蛋提示UI.hideUI()
tipsui=nil
tipsgrid=nil
end
end

function onCloseUI()
if not m_init then
return
end
if tipsui then
物品提示UI.hideUI()
装备提示UI.hideUI()
宠物蛋提示UI.hideUI()
tipsui=nil
tipsgrid=nil
end
ui.titlebar:releaseMouse()
ui:setVisible(false)

ui.talktxt:releaseLinkRect()
if g_target and g_target.objid==m_objid then
setMainRoleTarget(nil)
end
g_targetPos.bodyid=0
g_targetPos.x=0
g_targetPos.y=0


end

function onClose(e)
if tipsui then
物品提示UI.hideUI()
装备提示UI.hideUI()
宠物蛋提示UI.hideUI()
tipsui=nil
tipsgrid=nil
end
ui.titlebar:releaseMouse()

ui:setVisible(false)
ui:releaseMouse()
ui.close:releaseMouse()
ui.talktxt:releaseLinkRect()
e:stopPropagation()
if g_target and g_target.objid==m_objid then
setMainRoleTarget(nil)
end
g_targetPos.bodyid=0
g_targetPos.x=0
g_targetPos.y=0


end

function onMouseDown(e)
uiLayer:removeChild(ui)
uiLayer:addChild(ui)
e:stopPropagation()
end

function onClick(e)
if 角色逻辑.m_rolename==""then
消息框UI1.initUI()
消息框UI1.setData(txt("#cffff00,千古留名: #C请留下您的#cff00ff,千古大名"),onOK,onOK,onOK,true)
return
end
if m_taskid==0 then
elseif m_state==0 then
消息.CG_ACCEPT_TASK(m_taskid)
onCloseUI()
elseif m_state==2 then
消息.CG_FINISH_TASK(m_taskid)
onCloseUI()
end
end

function onUIInit()
ui.titlebar=ui:findComponent("titlebar")
ui.titlebar:addEventListener(F3DMouseEvent.CLICK,func_me(onClick))
ui.close=ui:findComponent("close")
if not ui.close then
ui.close=ui:findComponent("titlebar,close")
end
ui.close:addEventListener(F3DMouseEvent.CLICK,func_me(onClose))
ui.closex=ui.close:getPositionX()
ui.closey=ui.close:getPositionY()
ui.talktxt=tt(ui:findComponent("talktxt"),F3DRichTextField)
ui.talktxt:addEventListener(F3DUIEvent.LINK_DOWN,func_ue(onLinkDown))
ui.talktxtindex=ui:findChildIndex(ui.talktxt)
ui.talktxtx=ui.talktxt:getPositionX()
ui.talktxty=ui.talktxt:getPositionY()
ui.uiposx=ui:getPositionX()
ui.uiposy=ui:getPositionY()
ui.uiwidth=ui:getWidth()
ui.uiheight=ui:getHeight()
if layoutfile==""then
ui.avtcont=ui:findComponent("avtcont")
ui.myname=ui:findComponent("myname")
for i=1,6 do
m_grids[i]=ui:findComponent("grid_"..(i-1))
m_grids[i].id=i
if g_mobileMode then
m_grids[i]:addEventListener(F3DMouseEvent.CLICK,func_ue(onGridOver))
else
m_grids[i]:addEventListener(F3DUIEvent.MOUSE_OVER,func_ue(onGridOver))
m_grids[i]:addEventListener(F3DUIEvent.MOUSE_OUT,func_ue(onGridOut))
end
local img=F3DImage:new()
img:setPositionX(math.floor(m_grids[i]:getWidth()/2))
img:setPositionY(math.floor(m_grids[i]:getHeight()/2))
img:setPivot(0.5,0.5)
m_grids[i]:addChild(img)
m_gridimgs[i]=img
local gimg=F3DImage:new()
gimg:setPositionX(1)
gimg:setPositionY(1)
gimg:setWidth(m_grids[i]:getWidth()-2)
gimg:setHeight(m_grids[i]:getHeight()-2)
m_grids[i]:addChild(gimg)
m_gradeimgs[i]=gimg
local limg=F3DImage:new()
limg:setPositionX(4)
limg:setPositionY(m_grids[i]:getHeight()-4)
limg:setPivot(0,1)
m_grids[i]:addChild(limg)
m_grids[i].count=F3DTextField:new()
if g_mobileMode then
m_grids[i].count:setTextFont("宋体",16,false,false,false)
end
m_grids[i].count:setPositionX(m_grids[i]:getWidth()-(g_mobileMode and 8 or 2))
m_grids[i].count:setPositionY(m_grids[i]:getHeight()-(g_mobileMode and 8 or 2))
m_grids[i].count:setPivot(1,1)
m_grids[i]:addChild(m_grids[i].count)
m_lockimgs[i]=limg
end
end
m_init=true
ui.m_init=true
update()
end

function isHided()
return not ui or not ui:isVisible()or ui.tweenhide
end

function hideUI()
if tipsui then
物品提示UI.hideUI()
装备提示UI.hideUI()
宠物蛋提示UI.hideUI()
tipsui=nil
tipsgrid=nil
end
if ui then
ui:releaseMouse()

ui:setVisible(false)
end
end

function initUI()
if ui and ui~=uis[layoutfile]then
uiLayer:removeChild(ui)
ui=uis[layoutfile]
end
if ui and ui.m_init then
m_init=ui.m_init
uiLayer:removeChild(ui)
uiLayer:addChild(ui)
ui:updateParent()
ui:setVisible(true)
return
end
if not ui then
ui=F3DLayout:new()
ui.m_init=false
uis[layoutfile]=ui
end
m_init=false
uiLayer:addChild(ui)
ui:setLoadPriority(getUIPriority())
ui:setMovable(true)
ui:addEventListener(F3DObjEvent.OBJ_INITED,func_e(onUIInit))
if ui.setUIPack and USEUIPACK then
ui:setUIPack(g_mobileMode and UIPATH.."Npc对话UIm.pack"or UIPATH.."Npc对话UI.pack")
else
ui:setLayout(layoutfile~=""and UIPATH..layoutfile..".layout"or g_mobileMode and UIPATH.."Npc对话UIm.layout"or UIPATH.."Npc对话UI.layout")
end
ui:setVisible(true)
end

