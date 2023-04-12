module(...,package.seeall)

local 全局设置=require("公用.全局设置")
local 游戏设置=require("公用.游戏设置")
local 实用工具=require("公用.实用工具")
local 消息=require("网络.消息")
local 角色逻辑=require("主界面.角色逻辑")
local 物品提示UI=require("主界面.物品提示UI")
local 装备提示UI=require("主界面.装备提示UI")
local 宠物蛋提示UI=require("主界面.宠物蛋提示UI")
local 主界面UI=require("主界面.主界面UI")
local 充值礼包表=require("配置.充值礼包表").Config
local 活动奖励表=require("配置.活动奖励表").Config
local 福利抽奖表=require("配置.福利抽奖表").Config

_v_1639={}
_v_1640={}
_v_1641={}
_v_1642={}
m_iteminfo={}
m_VIP升级经验={}
for i,v in ipairs(充值礼包表)do
if v.类型==0 then
_v_1639[#_v_1639+1]=v
elseif v.类型==1 then
_v_1640[#_v_1640+1]=v
elseif v.类型==2 then
_v_1641[#_v_1641+1]=v
elseif v.类型==3 then
_v_1642[#_v_1642+1]=v
elseif v.类型==4 then
for ii,vv in ipairs(v.奖励)do
m_iteminfo[#m_iteminfo+1]=vv
end
elseif v.类型==5 then
m_VIP升级经验[#m_VIP升级经验+1]=v.领取充值
end
end
_v_1644={}
_v_1645={}
_v_1646={}
_v_1647={}
for i,v in ipairs(活动奖励表)do
if v.类型==0 then
_v_1644[#_v_1644+1]=v
elseif v.类型==1 then
_v_1645[#_v_1645+1]=v
elseif v.类型==2 then
_v_1646[#_v_1646+1]=v
elseif v.类型==3 then
_v_1647[#_v_1647+1]=v
end
end

m_init=false
m_itemdata=nil
m_推广人=""
m_成长经验=0
m_推广人数=0
m_推广有效人数=0
_v_1652={}
_v_1653={}
_v_1654={}
_v_1655={}
_v_1656={}
_v_1657={}
_v_1658={}
_v_1659={}
m_curpage=1
m_tabid=0
m_subtabid=0

特戒碎片={}
王者宝藏={}
for i,v in ipairs(福利抽奖表)do
if v.类型==0 then
特戒碎片[#特戒碎片+1]=v.奖励
else
王者宝藏[#王者宝藏+1]=v.奖励
end
end

function setVIPSpread(推广人,成长经验,推广人数,推广有效人数,礼包领取,每日充值领取)
m_推广人=推广人
m_成长经验=成长经验
m_推广人数=推广人数
m_推广有效人数=推广有效人数
实用工具.DeleteTable(_v_1652)
实用工具.DeleteTable(_v_1653)
实用工具.DeleteTable(_v_1654)
实用工具.DeleteTable(_v_1655)
local index=0
for i,v in ipairs(礼包领取)do
if index==0 and v==-1 then
index=1
elseif index==0 then
_v_1652[#_v_1652+1]=v
elseif index==1 and v==-1 then
index=2
elseif index==1 then
_v_1653[#_v_1653+1]=v
elseif index==2 and v==-1 then
index=3
elseif index==2 then
_v_1654[#_v_1654+1]=v
elseif index==3 and v==-1 then
index=4
elseif index==3 then
_v_1655[#_v_1655+1]=v
end
end
实用工具.DeleteTable(_v_1656)
实用工具.DeleteTable(_v_1657)
实用工具.DeleteTable(_v_1658)
实用工具.DeleteTable(_v_1659)
index=0
for i,v in ipairs(每日充值领取)do
if index==0 and v==-1 then
index=1
elseif index==0 then
_v_1656[#_v_1656+1]=v
elseif index==1 and v==-1 then
index=2
elseif index==1 then
_v_1657[#_v_1657+1]=v
elseif index==2 and v==-1 then
index=3
elseif index==2 then
_v_1658[#_v_1658+1]=v
elseif index==3 and v==-1 then
index=4
elseif index==3 then
_v_1659[#_v_1659+1]=v
end
end
update()
updateVIPPrize()
end

function updateVipLevel()
if not m_init then
return
end
ui.VIP成长经验:setPercent(m_成长经验/(m_VIP升级经验[math.min(角色逻辑.m_vip等级+1,#m_VIP升级经验)]or 1))
ui.VIP成长经验:setTitleText(m_成长经验.." / "..(m_VIP升级经验[math.min(角色逻辑.m_vip等级+1,#m_VIP升级经验)]or 1))
ui.VIP等级:setTitleText(txt("我的VIP等级: ")..角色逻辑.m_vip等级)
if m_tabid==3 and m_subtabid==1 then
ui.今日抽取:setTitleText(txt("我的元宝数量: ")..角色逻辑.m_rmb)
else
ui.今日抽取:setTitleText(txt("我的积分抽奖次数: ")..角色逻辑.m_特戒抽取次数.." / "..角色逻辑.m_总充值)
end
updateVIPPrize()
end

function update()
if not m_init then return end
for i=1,3 do
local v=m_iteminfo[i]
if v then
ui.items[i].grid:setVisible(true)
ui.items[i].icon:setTextureFile(全局设置.getItemIconUrl(v[3]))
ui.items[i].grade:setTextureFile(全局设置.getGradeUrl(v[5]))
ui.items[i].count:setText(v[4]>1 and v[4]or"")
ui.items[i].lock:setTextureFile(UIPATH.."公用/grid/img_bind.png")
else
ui.items[i].grid:setVisible(false)
end
end
if m_推广人~=""then
ui.推广人:setTitleText(txt(m_推广人))
ui.推广人:setDisable(true)
ui.推广人确定:setVisible(false)
end
ui.VIP成长经验:setPercent(m_成长经验/(m_VIP升级经验[math.min(角色逻辑.m_vip等级+1,#m_VIP升级经验)]or 1))
ui.VIP成长经验:setTitleText(m_成长经验.." / "..(m_VIP升级经验[math.min(角色逻辑.m_vip等级+1,#m_VIP升级经验)]or 1))
ui.VIP等级:setTitleText(txt("我的VIP等级: ")..角色逻辑.m_vip等级)
ui.成长经验:setTitleText(txt("我的VIP成长经验: ")..m_成长经验)
ui.推广人数:setTitleText(txt("我的推广人数: ")..m_推广人数)
ui.推广有效人数:setTitleText(txt("我的推广有效人数: ")..m_推广有效人数)
ui.subtab:setVisible(m_tabid~=0)
end

function updateVIPPrize()
if not m_init or(m_tabid~=1 and m_tabid~=2)then return end
local 礼包表=nil
local 礼包领取=nil
local 总充值=0
if m_tabid==1 then
礼包表=m_subtabid==0 and _v_1639 or m_subtabid==1 and _v_1640 or m_subtabid==2 and _v_1641 or _v_1642
礼包领取=m_subtabid==0 and _v_1652 or m_subtabid==1 and _v_1653 or m_subtabid==2 and _v_1654 or _v_1655
总充值=m_subtabid==1 and 角色逻辑.m_每日充值 or m_subtabid==3 and m_成长经验 or 角色逻辑.m_总充值
else
礼包表=m_subtabid==0 and _v_1644 or m_subtabid==1 and _v_1645 or m_subtabid==2 and _v_1646 or _v_1647
礼包领取=m_subtabid==0 and _v_1656 or m_subtabid==1 and _v_1657 or m_subtabid==2 and _v_1658 or _v_1659
end
if m_tabid==1 then
if m_subtabid==0 then
ui.今日充值:setTitleText(txt("我的VIP等级: ")..角色逻辑.m_vip等级)
elseif m_subtabid==1 then
ui.今日充值:setTitleText(txt("我的今日充值: ")..角色逻辑.m_每日充值)
elseif m_subtabid==2 then
ui.今日充值:setTitleText(txt("我的累计充值: ")..角色逻辑.m_总充值)
elseif m_subtabid==3 then
ui.今日充值:setTitleText(txt("我的VIP成长经验: ")..m_成长经验)
end
else
local cnt=0
for i,v in ipairs(礼包领取)do
if v==1 then
cnt=cnt+1
end
end
ui.今日充值:setTitleText(txt("我的当前进度: ")..cnt.." / "..#礼包领取)
end
local index=(m_curpage-1)*4
for i=1,4 do
local v=礼包表[index+i]
if v then
local candraw=(m_tabid==2 and 礼包领取[index+i]==2)or(m_tabid==1 and 礼包领取[index+i]~=1 and 角色逻辑.m_vip等级>=v.领取VIP and 总充值>=v.领取充值)
ui.VIP礼包[i].name:setTitleText(txt(v.name))
ui.VIP礼包[i].已领取:setVisible(礼包领取[index+i]==1)
ui.VIP礼包[i].cont:setVisible(true)
for ii,vv in ipairs(v.奖励)do
ui.VIP礼包[i][ii].grid:setVisible(true)
ui.VIP礼包[i][ii].icon:setTextureFile(全局设置.getItemIconUrl(vv[3]))
ui.VIP礼包[i][ii].count:setText(vv[4]>1 and vv[4]or"")
ui.VIP礼包[i][ii].grade:setTextureFile(全局设置.getGradeUrl(vv[5]))
ui.VIP礼包[i][ii].lock:setTextureFile((m_tabid==1 or m_tabid==2)and UIPATH.."公用/grid/img_bind.png"or"")
ui.VIP礼包[i][ii].领取按钮:setVisible(candraw and(v.领取类型==1 or ii==1))
end
for ii=#v.奖励+1,7 do
ui.VIP礼包[i][ii].grid:setVisible(false)
ui.VIP礼包[i][ii].领取按钮:setVisible(false)
end
else
ui.VIP礼包[i].name:setTitleText("")
ui.VIP礼包[i].已领取:setVisible(false)
ui.VIP礼包[i].cont:setVisible(false)
end
end
local totalpage=math.ceil(#礼包表/4)
ui.page:setTitleText(m_curpage.." / "..totalpage)
end

function updateRingEx()
if m_subtabid==1 then
for i=1,#王者宝藏 do
ui.碎片[i].icon:setTextureFile(全局设置.getItemIconUrl(王者宝藏[i][3]))
ui.碎片[i].grade:setTextureFile(全局设置.getGradeUrl(王者宝藏[i][5]))
end
else
for i=1,#特戒碎片 do
ui.碎片[i].icon:setTextureFile(全局设置.getItemIconUrl(特戒碎片[i][3]))
ui.碎片[i].grade:setTextureFile(全局设置.getGradeUrl(特戒碎片[i][5]))
end
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
if tipsui and tipsgrid then
local 提示UI=(m_itemdata.type==3 and m_itemdata.equippos==14)and 宠物蛋提示UI or m_itemdata.type==3 and 装备提示UI or 物品提示UI
提示UI.setItemData(m_itemdata)
end
end

function onGridOver(e)
if ui.tweenhide then return end
local g=g_mobileMode and e:getCurrentTarget()or e:getTarget()
if g and g.id1 and g.id2 and F3DUIManager.sTouchComp==g then
local 礼包表=nil
if m_tabid==1 then
礼包表=m_subtabid==0 and _v_1639 or m_subtabid==1 and _v_1640 or m_subtabid==2 and _v_1641 or _v_1642
else
礼包表=m_subtabid==0 and _v_1644 or m_subtabid==1 and _v_1645 or m_subtabid==2 and _v_1646 or _v_1647
end
local index=(m_curpage-1)*4
v=礼包表[index+g.id1]
local iteminfo=v and v.奖励[g.id2]or nil
if iteminfo then
local 提示UI=iteminfo[1]==3 and 宠物蛋提示UI or iteminfo[1]==2 and 装备提示UI or 物品提示UI
提示UI.initUI()
if not m_itemdata or m_itemdata.id~=iteminfo[2]then
消息.CG_ITEM_QUERY(iteminfo[2],3)
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
end
elseif g and g.碎片id and F3DUIManager.sTouchComp==g then
local iteminfo=m_subtabid==1 and 王者宝藏[g.碎片id]or 特戒碎片[g.碎片id]
if iteminfo then
local 提示UI=iteminfo[1]==3 and 宠物蛋提示UI or iteminfo[1]==2 and 装备提示UI or 物品提示UI
提示UI.initUI()
if not m_itemdata or m_itemdata.id~=iteminfo[2]then
消息.CG_ITEM_QUERY(iteminfo[2],3)
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
end
elseif g==nil or g.id==nil or not m_iteminfo[g.id]then
elseif F3DUIManager.sTouchComp~=g then
else
local mallinfo=m_iteminfo[g.id]
local 提示UI=mallinfo[1]==2 and 装备提示UI or 物品提示UI
提示UI.initUI()
if not m_itemdata or m_itemdata.id~=mallinfo[2]then
消息.CG_ITEM_QUERY(mallinfo[2],3)
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

function onVIP礼包领取(e)
local g=e:getCurrentTarget()
if g==nil or g.id1==nil or g.id2==nil then
else
local index=(m_curpage-1)*4
消息.CG_VIP_SPREAD("",{index+g.id1,g.id2},(m_tabid==2 and 4 or 0)+m_subtabid)
end
end

function onTabChange(e)
m_tabid=ui.tab:getSelectIndex()
if m_tabid==1 then
ui:findComponent("tab_2,btns,btn_1"):setTitleText(txt("VIP礼包"))
ui:findComponent("tab_2,btns,btn_2"):setTitleText(txt("每日充值"))
ui:findComponent("tab_2,btns,btn_3"):setTitleText(txt("累计充值"))
ui:findComponent("tab_2,btns,btn_4"):setTitleText(txt("推广奖励"))
ui:findComponent("tab_2,btns,btn_3"):setVisible(true)
ui:findComponent("tab_2,btns,btn_4"):setVisible(true)
elseif m_tabid==2 then
ui:findComponent("tab_2,btns,btn_1"):setTitleText(txt("在线奖励"))
ui:findComponent("tab_2,btns,btn_2"):setTitleText(txt("七天登录"))
ui:findComponent("tab_2,btns,btn_3"):setTitleText(txt("签到奖励"))
ui:findComponent("tab_2,btns,btn_4"):setTitleText(txt("每日活动"))
ui:findComponent("tab_2,btns,btn_3"):setVisible(true)
ui:findComponent("tab_2,btns,btn_4"):setVisible(true)
elseif m_tabid==3 then
ui:findComponent("tab_2,btns,btn_1"):setTitleText(txt("积分抽奖"))
ui:findComponent("tab_2,btns,btn_2"):setTitleText(txt("元宝抽奖"))
ui:findComponent("tab_2,btns,btn_3"):setVisible(false)
ui:findComponent("tab_2,btns,btn_4"):setVisible(false)
end
m_subtabid=0
ui.subtab:setSelectIndex(0)
if m_tabid==1 or m_tabid==2 then
ui:findComponent("tab_1,conts,cont_2"):setVisible(true)
m_curpage=1
updateVIPPrize()
end
update()
end

function onSubTabChange(e)
m_subtabid=ui.subtab:getSelectIndex()
m_curpage=1
update()
updateVipLevel()
updateRingEx()
end

function onUIInit()
ui.close=ui:findComponent("titlebar,close")
ui.close:addEventListener(F3DMouseEvent.CLICK,func_me(onClose))
ui:addEventListener(F3DMouseEvent.MOUSE_DOWN,func_me(onMouseDown))
ui.items={}
for i=1,3 do
ui.items[i]={}
ui.items[i].grid=ui:findComponent("tab_1,conts,cont_1,物品框_"..i)
ui.items[i].grid.id=i
if g_mobileMode then
ui.items[i].grid:addEventListener(F3DMouseEvent.CLICK,func_me(onGridOver))
else
ui.items[i].grid:addEventListener(F3DUIEvent.MOUSE_OVER,func_ue(onGridOver))
ui.items[i].grid:addEventListener(F3DUIEvent.MOUSE_OUT,func_ue(onGridOut))
end
ui.items[i].icon=F3DImage:new()
ui.items[i].icon:setPositionX(math.floor(ui.items[i].grid:getWidth()/2))
ui.items[i].icon:setPositionY(math.floor(ui.items[i].grid:getHeight()/2))
ui.items[i].icon:setPivot(0.5,0.5)
ui.items[i].grid:addChild(ui.items[i].icon)
ui.items[i].grade=F3DImage:new()
ui.items[i].grade:setPositionX(1)
ui.items[i].grade:setPositionY(1)
ui.items[i].grade:setWidth(ui.items[i].grid:getWidth()-2)
ui.items[i].grade:setHeight(ui.items[i].grid:getHeight()-2)
ui.items[i].grid:addChild(ui.items[i].grade)
ui.items[i].count=F3DTextField:new()
ui.items[i].count:setPositionX(36)
ui.items[i].count:setPositionY(36)
ui.items[i].count:setPivot(1,1)
ui.items[i].grid:addChild(ui.items[i].count)
ui.items[i].lock=F3DImage:new()
ui.items[i].lock:setPositionX(4)
ui.items[i].lock:setPositionY(4)
ui.items[i].grid:addChild(ui.items[i].lock)
end
ui.推广人=tt(ui:findComponent("tab_1,conts,cont_1,textinput_1"),F3DTextInput)
ui.推广人确定=ui:findComponent("tab_1,conts,cont_1,按钮1")
ui.推广人确定:addEventListener(F3DMouseEvent.CLICK,func_me(function(e)
if ui.推广人:isDefault()or ui.推广人:getTitleText()==""then
主界面UI.showTipsMsg(1,txt("请输入推广人名字"))
return
end
消息.CG_VIP_SPREAD(utf8(ui.推广人:getTitleText()),{0,0},0)
end))
ui.复制推广链接=ui:findComponent("tab_1,conts,cont_1,按钮2")




ui.复制推广链接:setVisible(false)
ui.VIP成长经验=tt(ui:findComponent("tab_1,conts,cont_1,progress_1"),F3DProgress)
ui.VIP成长经验:setPercent(0.3)
ui.VIP成长经验:setTitleText("1000 / 10000")
ui.VIP等级=ui:findComponent("tab_1,conts,cont_1,component_13")
ui.成长经验=ui:findComponent("tab_1,conts,cont_1,component_5")
ui.推广人数=ui:findComponent("tab_1,conts,cont_1,component_7")
ui.推广有效人数=ui:findComponent("tab_1,conts,cont_1,component_8")
ui.碎片={}
for i=1,31 do
ui.碎片[i]={}
ui.碎片[i].grid=ui:findComponent("tab_1,conts,cont_4,碎片_"..i)
ui.碎片[i].grid.碎片id=i
if g_mobileMode then
ui.碎片[i].grid:addEventListener(F3DMouseEvent.CLICK,func_me(onGridOver))
else
ui.碎片[i].grid:addEventListener(F3DUIEvent.MOUSE_OVER,func_ue(onGridOver))
ui.碎片[i].grid:addEventListener(F3DUIEvent.MOUSE_OUT,func_ue(onGridOut))
end
ui.碎片[i].icon=F3DImage:new()
ui.碎片[i].icon:setPositionX(math.floor(ui.碎片[i].grid:getWidth()/2))
ui.碎片[i].icon:setPositionY(math.floor(ui.碎片[i].grid:getHeight()/2))
ui.碎片[i].icon:setPivot(0.5,0.5)
ui.碎片[i].grid:addChild(ui.碎片[i].icon)
ui.碎片[i].grade=F3DImage:new()
ui.碎片[i].grade:setPositionX(1)
ui.碎片[i].grade:setPositionY(1)
ui.碎片[i].grade:setWidth(ui.碎片[i].grid:getWidth()-2)
ui.碎片[i].grade:setHeight(ui.碎片[i].grid:getHeight()-2)
ui.碎片[i].grid:addChild(ui.碎片[i].grade)
end
ui.抽取=ui:findComponent("tab_1,conts,cont_4,抽取")
ui.抽取:addEventListener(F3DMouseEvent.CLICK,func_me(function(e)
消息.CG_DRAW_SRING(1,m_subtabid==1 and 1 or 0)
end))
ui.抽取十次=ui:findComponent("tab_1,conts,cont_4,抽取十次")
ui.抽取十次:addEventListener(F3DMouseEvent.CLICK,func_me(function(e)
消息.CG_DRAW_SRING(10,m_subtabid==1 and 1 or 0)
end))
ui.今日抽取=ui:findComponent("tab_1,conts,cont_4,今日抽取")
ui.VIP礼包={}
for i=1,4 do
ui.VIP礼包[i]={}
ui.VIP礼包[i].name=ui:findComponent("tab_1,conts,cont_2,底_"..i..",说明")
ui.VIP礼包[i].已领取=ui:findComponent("tab_1,conts,cont_2,底_"..i..",已领取")
ui.VIP礼包[i].cont=ui:findComponent("tab_1,conts,cont_2,底_"..i)
for ii=1,7 do
ui.VIP礼包[i][ii]={}
ui.VIP礼包[i][ii].grid=ui:findComponent("tab_1,conts,cont_2,底_"..i..",物品底_"..ii)
ui.VIP礼包[i][ii].grid.id1=i
ui.VIP礼包[i][ii].grid.id2=ii
if g_mobileMode then
ui.VIP礼包[i][ii].grid:addEventListener(F3DMouseEvent.CLICK,func_me(onGridOver))
else
ui.VIP礼包[i][ii].grid:addEventListener(F3DUIEvent.MOUSE_OVER,func_ue(onGridOver))
ui.VIP礼包[i][ii].grid:addEventListener(F3DUIEvent.MOUSE_OUT,func_ue(onGridOut))
end
ui.VIP礼包[i][ii].icon=F3DImage:new()
ui.VIP礼包[i][ii].icon:setPositionX(math.floor(ui.VIP礼包[i][ii].grid:getWidth()/2))
ui.VIP礼包[i][ii].icon:setPositionY(math.floor(ui.VIP礼包[i][ii].grid:getHeight()/2))
ui.VIP礼包[i][ii].icon:setPivot(0.5,0.5)
ui.VIP礼包[i][ii].grid:addChild(ui.VIP礼包[i][ii].icon)
ui.VIP礼包[i][ii].grade=F3DImage:new()
ui.VIP礼包[i][ii].grade:setPositionX(1)
ui.VIP礼包[i][ii].grade:setPositionY(1)
ui.VIP礼包[i][ii].grade:setWidth(ui.VIP礼包[i][ii].grid:getWidth()-2)
ui.VIP礼包[i][ii].grade:setHeight(ui.VIP礼包[i][ii].grid:getHeight()-2)
ui.VIP礼包[i][ii].grid:addChild(ui.VIP礼包[i][ii].grade)
ui.VIP礼包[i][ii].count=F3DTextField:new()
ui.VIP礼包[i][ii].count:setPositionX(42)
ui.VIP礼包[i][ii].count:setPositionY(42)
ui.VIP礼包[i][ii].count:setPivot(1,1)
ui.VIP礼包[i][ii].grid:addChild(ui.VIP礼包[i][ii].count)
ui.VIP礼包[i][ii].lock=F3DImage:new()
ui.VIP礼包[i][ii].lock:setPositionX(4)
ui.VIP礼包[i][ii].lock:setPositionY(4)
ui.VIP礼包[i][ii].grid:addChild(ui.VIP礼包[i][ii].lock)
ui.VIP礼包[i][ii].领取按钮=ui:findComponent("tab_1,conts,cont_2,底_"..i..",按钮_"..ii)
ui.VIP礼包[i][ii].领取按钮.id1=i
ui.VIP礼包[i][ii].领取按钮.id2=ii
ui.VIP礼包[i][ii].领取按钮:addEventListener(F3DMouseEvent.CLICK,func_me(onVIP礼包领取))
end
end
ui.page=ui:findComponent("tab_1,conts,cont_2,page")
ui.page_pre=ui:findComponent("tab_1,conts,cont_2,page_pre")
ui.page_pre:addEventListener(F3DMouseEvent.CLICK,func_me(function(e)
local 礼包表=nil
if m_tabid==1 then
礼包表=m_subtabid==0 and _v_1639 or m_subtabid==1 and _v_1640 or m_subtabid==2 and _v_1641 or _v_1642
else
礼包表=m_subtabid==0 and _v_1644 or m_subtabid==1 and _v_1645 or m_subtabid==2 and _v_1646 or _v_1647
end
local totalpage=math.ceil(#礼包表/4)
m_curpage=math.max(1,m_curpage-1)
updateVIPPrize()
end))
ui.page_next=ui:findComponent("tab_1,conts,cont_2,page_next")
ui.page_next:addEventListener(F3DMouseEvent.CLICK,func_me(function(e)
local 礼包表=nil
if m_tabid==1 then
礼包表=m_subtabid==0 and _v_1639 or m_subtabid==1 and _v_1640 or m_subtabid==2 and _v_1641 or _v_1642
else
礼包表=m_subtabid==0 and _v_1644 or m_subtabid==1 and _v_1645 or m_subtabid==2 and _v_1646 or _v_1647
end
local totalpage=math.ceil(#礼包表/4)
m_curpage=math.min(totalpage,m_curpage+1)
updateVIPPrize()
end))
ui.今日充值=ui:findComponent("tab_1,conts,cont_2,今日充值")
ui.tab=tt(ui:findComponent("tab_1"),F3DTab)
ui.tab:addEventListener(F3DUIEvent.CHANGE,func_me(onTabChange))
ui.subtab=tt(ui:findComponent("tab_2"),F3DTab)
ui.subtab:addEventListener(F3DUIEvent.CHANGE,func_me(onSubTabChange))
m_init=true
update()
updateVIPPrize()
updateRingEx()
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
_v_62(ui,true)
		return
	end
	ui = F3DLayout:new()
	uiLayer:addChild(ui)
	ui:setLoadPriority(getUIPriority())
	ui:setMovable(true)
	ui:addEventListener(F3DObjEvent.OBJ_INITED, func_e(onUIInit))
if ui.setUIPack and USEUIPACK then
ui:setUIPack(g_mobileMode and UIPATH.."福利UIm.pack"or UIPATH.."福利UI.pack")
else
	ui:setLayout(g_mobileMode and UIPATH.."福利UIm.layout" or UIPATH.."福利UI.layout")
end
_v_62(ui,true)
end

