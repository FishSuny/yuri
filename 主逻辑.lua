module(..., package.seeall)

local 实用工具 = require("公用.实用工具")
local 全局设置 = require("公用.全局设置")
local 游戏设置 = require("公用.游戏设置")
local 角色逻辑 = require("主界面.角色逻辑")

m_FlytextPool = {}
m_Flytexts = {}

function pushFlytext(flytext)
	if flytext.minus then
		flytext.minus:setVisible(false)
	end
	flytext:setAlpha(1)
	flytext:reset()
	flytext:removeFromParent()
	if flytext.role and m_Flytexts[flytext.role] then
		m_Flytexts[flytext.role][flytext] = nil
		flytext.role = nil
	end
	m_FlytextPool[#m_FlytextPool+1] = flytext
end

function popFlytext()
	if #m_FlytextPool > 0 then
		local flytext = m_FlytextPool[#m_FlytextPool]
		table.remove(m_FlytextPool, #m_FlytextPool)
		return flytext
	end
end

function deleteRoleFlytext(role)
	if m_Flytexts[role] then
		for ft,v in pairs(m_Flytexts[role]) do
			m_Flytexts[role][ft] = nil
			ft.role = nil
		end
	end
	m_Flytexts[role] = nil
end

function showFlytext(role, dechp, crit)   --攻击伤害飘血时候后期更新实现不同伤害显示不同颜色  比如普攻白色 暴击红色 元素伤害蓝色或者带前缀  冰伤9999 等等 
	local flytext = popFlytext() or F3DImage3D:new()
local sec=1
	if dechp == 0 then
		flytext:setTextureFile(UIPATH.."公用/fight/miss.png")
		flytext:setWidth(游戏设置.FLYTEXTSIZE[2][1])
		flytext:setHeight(游戏设置.FLYTEXTSIZE[2][2])
		flytext:setOffset(-游戏设置.FLYTEXTSIZE[2][1]/2, -游戏设置.FLYTEXTSIZE[2][2])
	elseif dechp < 0 then
		sec = 1
		dechp = -dechp
		flytext:setTextureFile(UIPATH.."公用/fight/addHit.png")
		flytext:setWidth(游戏设置.FLYTEXTSIZE[4][1]/10)
		flytext:setHeight(游戏设置.FLYTEXTSIZE[4][2])
		if not flytext.clips then
			flytext.clips = F3DPointVector:new()
		end
		flytext.clips:clear()
		while dechp >= 1 do
			flytext.clips:push(math.floor(dechp%10), -flytext.clips:size()*游戏设置.FLYTEXTSIZE[4][1]/10)
			dechp = dechp / 10
		end
		flytext:setBatchClips(10, flytext.clips)
		flytext:setOffset(-游戏设置.FLYTEXTSIZE[4][1]/10+flytext.clips:size()*游戏设置.FLYTEXTSIZE[4][1]/20, -游戏设置.FLYTEXTSIZE[4][2])
		if not flytext.minus then
			flytext.minus = F3DImage:new()
			flytext:addChild(flytext.minus)
		end
		flytext.minus:setTextureFile(UIPATH.."公用/fight/addFlag.png")
		flytext.minus:setWidth(游戏设置.FLYTEXTSIZE[3][1])
		flytext.minus:setHeight(游戏设置.FLYTEXTSIZE[3][2])
		flytext.minus:setPositionX(-(flytext.clips:size()-1)*游戏设置.FLYTEXTSIZE[4][1]/10-游戏设置.FLYTEXTSIZE[3][1])
		flytext.minus:setPositionY((游戏设置.FLYTEXTSIZE[4][2]-游戏设置.FLYTEXTSIZE[3][2])/2)
		flytext.minus:setVisible(true)
	elseif crit == 1 then
		flytext:setTextureFile(UIPATH.."公用/fight/criticalHit.png")--暴击 criticalHit
		flytext:setWidth(游戏设置.FLYTEXTSIZE[8][1]/10)
		flytext:setHeight(游戏设置.FLYTEXTSIZE[8][2])
		if not flytext.clips then
			flytext.clips = F3DPointVector:new()
		end
		flytext.clips:clear()
		while dechp >= 1 do
			flytext.clips:push(math.floor(dechp%10), -flytext.clips:size()*游戏设置.FLYTEXTSIZE[8][1]/10)
			dechp = dechp / 10
		end
		flytext:setBatchClips(10, flytext.clips)
		flytext:setOffset(-游戏设置.FLYTEXTSIZE[8][1]/10+flytext.clips:size()*游戏设置.FLYTEXTSIZE[8][1]/20, -游戏设置.FLYTEXTSIZE[8][2])
		if not flytext.minus then
			flytext.minus = F3DImage:new()
			flytext:addChild(flytext.minus)
		end
		flytext.minus:setTextureFile(UIPATH.."公用/fight/criticalFlag.png")--暴击 criticalFlag
		flytext.minus:setWidth(游戏设置.FLYTEXTSIZE[7][1])
		flytext.minus:setHeight(游戏设置.FLYTEXTSIZE[7][2])
		flytext.minus:setPositionX(-(flytext.clips:size()-1)*游戏设置.FLYTEXTSIZE[8][1]/10-游戏设置.FLYTEXTSIZE[7][1])
		flytext.minus:setPositionY((游戏设置.FLYTEXTSIZE[8][2]-游戏设置.FLYTEXTSIZE[7][2])/2)
		flytext.minus:setVisible(true)
	elseif crit == 3 then
		flytext:setTextureFile(UIPATH.."公用/fight/huixin.png")--暴击 criticalHit
		flytext:setWidth(游戏设置.FLYTEXTSIZE1[8][1]/10)
		flytext:setHeight(游戏设置.FLYTEXTSIZE1[8][2])
		if not flytext.clips then
			flytext.clips = F3DPointVector:new()
		end
		flytext.clips:clear()
		while dechp >= 1 do
			flytext.clips:push(math.floor(dechp%10), -flytext.clips:size()*游戏设置.FLYTEXTSIZE1[8][1]/10)
			dechp = dechp / 10
		end
		flytext:setBatchClips(10, flytext.clips)
		flytext:setOffset(-游戏设置.FLYTEXTSIZE1[8][1]/10+flytext.clips:size()*游戏设置.FLYTEXTSIZE1[8][1]/20, -游戏设置.FLYTEXTSIZE1[8][2])
		if not flytext.minus then
			flytext.minus = F3DImage:new()
			flytext:addChild(flytext.minus)
		end
		flytext.minus:setTextureFile(UIPATH.."公用/fight/huixin1.png")--暴击 criticalFlag
		flytext.minus:setWidth(游戏设置.FLYTEXTSIZE1[7][1])
		flytext.minus:setHeight(游戏设置.FLYTEXTSIZE1[7][2])
		flytext.minus:setPositionX(-(flytext.clips:size()-1)*游戏设置.FLYTEXTSIZE1[8][1]/10-游戏设置.FLYTEXTSIZE1[7][1])
		flytext.minus:setPositionY((游戏设置.FLYTEXTSIZE1[8][2]-游戏设置.FLYTEXTSIZE1[7][2])/2)
		flytext.minus:setVisible(true)
	elseif crit == 4 then
		flytext:setTextureFile(UIPATH.."公用/fight/zhuoyue.png")--暴击 criticalHit
		flytext:setWidth(游戏设置.FLYTEXTSIZE1[8][1]/10)
		flytext:setHeight(游戏设置.FLYTEXTSIZE1[8][2])
		if not flytext.clips then
			flytext.clips = F3DPointVector:new()
		end
		flytext.clips:clear()
		while dechp >= 1 do
			flytext.clips:push(math.floor(dechp%10), -flytext.clips:size()*游戏设置.FLYTEXTSIZE1[8][1]/10)
			dechp = dechp / 10
		end
		flytext:setBatchClips(10, flytext.clips)
		flytext:setOffset(-游戏设置.FLYTEXTSIZE1[8][1]/10+flytext.clips:size()*游戏设置.FLYTEXTSIZE1[8][1]/20, -游戏设置.FLYTEXTSIZE1[8][2])
		if not flytext.minus then
			flytext.minus = F3DImage:new()
			flytext:addChild(flytext.minus)
		end
		flytext.minus:setTextureFile(UIPATH.."公用/fight/zhuoyue1.png")--暴击 criticalFlag
		flytext.minus:setWidth(游戏设置.FLYTEXTSIZE1[7][1])
		flytext.minus:setHeight(游戏设置.FLYTEXTSIZE1[7][2])
		flytext.minus:setPositionX(-(flytext.clips:size()-1)*游戏设置.FLYTEXTSIZE1[8][1]/10-游戏设置.FLYTEXTSIZE1[7][1])
		flytext.minus:setPositionY((游戏设置.FLYTEXTSIZE1[8][2]-游戏设置.FLYTEXTSIZE1[7][2])/2)
		flytext.minus:setVisible(true)
	elseif crit == 5 then
		flytext:setTextureFile(UIPATH.."公用/fight/zhiming.png")
		flytext:setWidth(游戏设置.FLYTEXTSIZE1[8][1]/10)
		flytext:setHeight(游戏设置.FLYTEXTSIZE1[8][2])
		flytext:setPositionX(100)
		flytext:setPositionY(100)
		if not flytext.clips then
			flytext.clips = F3DPointVector:new()
		end
		flytext.clips:clear()
		while dechp >= 1 do
			flytext.clips:push(math.floor(dechp%10), -flytext.clips:size()*游戏设置.FLYTEXTSIZE1[8][1]/10)
			dechp = dechp / 10
		end
		flytext:setBatchClips(10, flytext.clips)
		flytext:setOffset(-游戏设置.FLYTEXTSIZE1[8][1]/10+flytext.clips:size()*游戏设置.FLYTEXTSIZE1[8][1]/20, -游戏设置.FLYTEXTSIZE1[8][2])
		if not flytext.minus then
			flytext.minus = F3DImage:new()
			flytext:addChild(flytext.minus)
		end
		flytext.minus:setTextureFile(UIPATH.."公用/fight/zhiming1.png")
		flytext.minus:setWidth(游戏设置.FLYTEXTSIZE1[7][1])
		flytext.minus:setHeight(游戏设置.FLYTEXTSIZE1[7][2])
		flytext.minus:setPositionX(-(flytext.clips:size()-1)*游戏设置.FLYTEXTSIZE1[8][1]/10-游戏设置.FLYTEXTSIZE1[7][1])
		flytext.minus:setPositionY((游戏设置.FLYTEXTSIZE1[8][2]-游戏设置.FLYTEXTSIZE1[7][2])/2)
		flytext.minus:setVisible(true)
	elseif crit == 10 then --真实伤害
		flytext:setTextureFile(UIPATH.."公用/fight/criticalHit2.png")
		flytext:setWidth(游戏设置.FLYTEXTSIZE10[8][1]/10)
		flytext:setHeight(游戏设置.FLYTEXTSIZE10[8][2])
		if not flytext.clips then
			flytext.clips = F3DPointVector:new()
		end
		flytext.clips:clear()
		while dechp >= 1 do
			flytext.clips:push(math.floor(dechp%10), -flytext.clips:size()*游戏设置.FLYTEXTSIZE10[8][1]/10)
			dechp = dechp / 10
		end
		flytext:setBatchClips(10, flytext.clips)
		flytext:setOffset(-游戏设置.FLYTEXTSIZE10[8][1]/10+flytext.clips:size()*游戏设置.FLYTEXTSIZE10[8][1]/20, -游戏设置.FLYTEXTSIZE10[8][2])
		if not flytext.minus then
			flytext.minus = F3DImage:new()
			flytext:addChild(flytext.minus)
		end
		flytext.minus:setTextureFile(UIPATH.."公用/fight/zhenshi.png")
		flytext.minus:setWidth(游戏设置.FLYTEXTSIZE10[7][1])
		flytext.minus:setHeight(游戏设置.FLYTEXTSIZE10[7][2])
		flytext.minus:setPositionX(-(flytext.clips:size()-1)*游戏设置.FLYTEXTSIZE10[8][1]/10-游戏设置.FLYTEXTSIZE10[7][1])
		flytext.minus:setPositionY((游戏设置.FLYTEXTSIZE10[8][2]-游戏设置.FLYTEXTSIZE10[7][2])/2)
		flytext.minus:setVisible(true)
	else
		flytext:setTextureFile(UIPATH.."公用/fight/otherHit.png")
		flytext:setWidth(游戏设置.FLYTEXTSIZE[6][1]/10)
		flytext:setHeight(游戏设置.FLYTEXTSIZE[6][2])
		if not flytext.clips then
			flytext.clips = F3DPointVector:new()
		end
		flytext.clips:clear()
		while dechp >= 1 do
			flytext.clips:push(math.floor(dechp%10), -flytext.clips:size()*游戏设置.FLYTEXTSIZE[6][1]/10)
			dechp = dechp / 10
		end
		flytext:setBatchClips(10, flytext.clips)
		flytext:setOffset(-游戏设置.FLYTEXTSIZE[6][1]/10+flytext.clips:size()*游戏设置.FLYTEXTSIZE[6][1]/20, -游戏设置.FLYTEXTSIZE[6][2])
		if not flytext.minus then
			flytext.minus = F3DImage:new()
			flytext:addChild(flytext.minus)
		end
		flytext.minus:setTextureFile(UIPATH.."公用/fight/otherFlag.png")
		flytext.minus:setWidth(游戏设置.FLYTEXTSIZE[5][1])
		flytext.minus:setHeight(游戏设置.FLYTEXTSIZE[5][2])
		flytext.minus:setPositionX(-(flytext.clips:size()-1)*游戏设置.FLYTEXTSIZE[6][1]/10-游戏设置.FLYTEXTSIZE[5][1])
		flytext.minus:setPositionY((游戏设置.FLYTEXTSIZE[6][2]-游戏设置.FLYTEXTSIZE[5][2])/2)
		flytext.minus:setVisible(true)
	end
--	flytext:setPosition(role:getPositionX()+游戏设置.FLYTEXTSIZE[9][1], role:getPositionY(), role:getPositionZ() + 游戏设置.FLYTEXTSIZE[1][1])
flytext:setPosition(role:getPositionX(), role:getPositionY(), role:getPositionZ() + 游戏设置.FLYTEXTSIZE[1][1])
	dechpcont:addChild(flytext)
	flytext.role = role
	m_Flytexts[role] = m_Flytexts[role] or {}
	for ft,v in pairs(m_Flytexts[role]) do
		local pos = ft:getPosition()
--		ft:setPosition(pos.x+游戏设置.FLYTEXTSIZE[9][1], pos.y-(游戏设置.FLYTEXTSIZE[9][2] or 30), pos.z)
ft:setPosition(pos.x, pos.y-(游戏设置.FLYTEXTSIZE[9] or 30), pos.z)
	end
	m_Flytexts[role][flytext] = 1
	F3DTween:fromPool():start(flytext, prop, sec, func_n(function()
		pushFlytext(flytext)
	end))
end
prop = F3DTweenProp:new()
prop:push("offsetY", -游戏设置.FLYTEXTSIZE[1][2], F3DTween.TYPE_SPEEDDOWN)
prop:push("alpha", 游戏设置.FLYTEXTSIZE[1][3], F3DTween.TYPE_SPEEDUP)

hpbarpool = {}

function removeMergeHP(hpbar)
	if hpbar.mergehp then
		for i,v in ipairs(hpbar.mergehp) do
			v:removeFromParent(true)
		end
		hpbar.mergehp = nil
	end
end

function createMergeHP(hpbar, hp, hpmax, mergehp)
	hpmax = hp
	for i,v in ipairs(mergehp) do
		hpmax = hpmax + (i == #mergehp and v.hpmax or v.hp)
	end
	local perc = hp / hpmax
	hpbar.hpimg:setWidth(hpbar.track:getWidth()*perc)
	hpbar.mergehp = {}
	for i,v in ipairs(mergehp) do
		local hpimg = F3DImage:new()
		local pc = (i == #mergehp and v.hpmax or v.hp) / hpmax
		hpimg:setTextureFile("tex_white")
		hpimg:setWidth(hpbar.track:getWidth()*pc-1)
		hpimg:setHeight(hpbar.track:getHeight())
		hpimg:setPositionX(hpbar.track:getWidth()*perc+1)
		hpimg:getColor():setRGB(v.color)--人宠合体颜色RGB
		hpbar.track:addChild(hpimg)
		hpbar.mergehp[#hpbar.mergehp+1] = hpimg
		perc = perc + pc
		hp = hp + v.hp
	end
	return hp, hpmax
end

function removeNP(hpbar)
	if hpbar.npbar then
		hpbar.npbar:removeFromParent(true)
		hpbar.npbar = nil
	end
end

function createNP(hpbar)
	if not hpbar.npbar then
		hpbar.npbar = tt(hpbar.pro:clone(),F3DProgress)
		hpbar.npbar.track = hpbar.npbar:getTrack()
		hpbar.npbar.hpimg = F3DImage:new()
		hpbar.npbar.hpimg:setTextureFile("tex_white")
		hpbar.npbar.hpimg:setWidth(hpbar.track:getWidth())
		hpbar.npbar.hpimg:setHeight(hpbar.track:getHeight())
		hpbar.npbar.hpimg:getColor():setRGB(0xC0C0C0)
		hpbar.npbar:setPositionY((hpbar.mpbar and hpbar.mpbar:getPositionY() or hpbar.pro:getPositionY())+hpbar.track:getHeight()+1)
		hpbar.npbar.track:addChild(hpbar.npbar.hpimg)
		hpbar:addChild(hpbar.npbar,0)
	end
end

function removeMP(hpbar)
	if hpbar.mpbar then
		hpbar.mpbar:removeFromParent(true)
		hpbar.mpbar = nil
	end
end

function createMP(hpbar)
	if not hpbar.mpbar then
		hpbar.mpbar = tt(hpbar.pro:clone(),F3DProgress)
		hpbar.mpbar.track = hpbar.mpbar:getTrack()
		hpbar.mpbar.hpimg = F3DImage:new()
		hpbar.mpbar.hpimg:setTextureFile("tex_white")
		hpbar.mpbar.hpimg:setWidth(hpbar.track:getWidth())
		hpbar.mpbar.hpimg:setHeight(hpbar.track:getHeight())
		hpbar.mpbar.hpimg:getColor():setRGB(0x0080ff)
		hpbar.mpbar:setPositionY(hpbar.pro:getPositionY()+hpbar.track:getHeight()+1)
		hpbar.mpbar.track:addChild(hpbar.mpbar.hpimg)
		hpbar:addChild(hpbar.mpbar,0)
		if hpbar.npbar then
			hpbar.npbar:setPositionY(hpbar.mpbar:getPositionY()+hpbar.track:getHeight()+1)
		end
	end
end

function _V_102()
	if _V_10 then
		_V_10=false
	else
		_V_10=true
	end
end


function _V_110()

end

function _V_111()

end



function onHpBarInit(e)
	local hpbar = e:getTarget()
	hpbar.name = hpbar:findComponent("name")
	local ss = 实用工具.SplitString(hpbar.v.name,"\\")
	hpbar.name:setTitleText(txt(ss[1]))
	local nameindex = 1
	if #ss > 1 then
		hpbar.nameexs = hpbar.nameexs or {}
		if hpbar.showtitle or 游戏设置.SHOWTITLE then
			for i=2,#ss do
				local tf = hpbar.nameexs[i-1] or F3DTextField:new()
				if g_mobileMode then
					tf:setTextFont("宋体",16,false,false,false)
				end
				tf:setText(txt(ss[i]))
				tf:setTextColor(hpbar.namecolor or 0xffffff,0)
				tf:setPivot(0.5,0.5)
				tf:setPositionX(0)
				tf:setPositionY(50+(i-1)*14)
				hpbar:addChild(tf)
				hpbar.nameexs[i-1] = tf
				nameindex = i
			end
		end
	end
	if hpbar.nameexs then
		for i=nameindex,#hpbar.nameexs do
			hpbar.nameexs[i]:setVisible(false)
		end
	end
	hpbar.name:setVisible(hpbar.showname)
	hpbar.name:setTextColor(hpbar.namecolor or 0xffffff) --怪物颜色
	--hpbar.name:setTextColor(hpbar.namecolor or 0xff0000) --NPC+怪物颜色
	hpbar.guildname = hpbar:findComponent("guildname")
hpbar.guildname:setTitleText(txt((hpbar.showname and hpbar.v.guildname)and hpbar.v.guildname or""))--	hpbar.guildname:setTitleText(txt(hpbar.v.guildname or ""))
	hpbar.guildname:setVisible(hpbar.showname)
	hpbar.guildname:setTextColor(hpbar.namecolor or 0xffffff) --NPC颜色
	hpbar.pro = tt(hpbar:findComponent("hpbar"),F3DProgress)
	hpbar.track = hpbar.pro:getTrack()
	hpbar.hpimg = F3DImage:new()
	hpbar.hpimg:setTextureFile("tex_white")--血条颜色
	hpbar.hpimg:setWidth(hpbar.track:getWidth())
	hpbar.hpimg:setHeight(hpbar.track:getHeight())
	hpbar.hpimg:getColor():setRGB(hpbar.v.color)--怪物血条颜色
	hpbar.track:addChild(hpbar.hpimg)
	if hpbar.v.mp then
		createMP(hpbar)
		hpbar.mpbar:setMaxVal(hpbar.v.mp[2])
		hpbar.mpbar:setCurrVal(hpbar.v.mp[1])
	end
	if hpbar.v.np then
		createNP(hpbar)
		hpbar.npbar:setMaxVal(hpbar.v.np[2])
		hpbar.npbar:setCurrVal(hpbar.v.np[1])
	end
	hpbar.count = F3DTextField:new()   --创建一个文字
	if g_mobileMode then
		hpbar.count:setTextFont("宋体",16,false,false,false)
	end
	hpbar.count:setPivot(0.5,0.5)  --血条文字改居中
	hpbar.count:setPositionX(hpbar.pro:getWidth()/2)
	hpbar.count:setPositionY(-10)
	hpbar.pro:addChild(hpbar.count)
--hpbar.count:setText(txt(hpbar.v.hp==hpbar.v.hpmax and"/J"..hpbar.v.role.level or hpbar.v.hp.."/"..hpbar.v.hpmax.."/J"..hpbar.v.role.level))

	if not hpbar.v.mergehp or #hpbar.v.mergehp == 0 then
removeMergeHP(hpbar)
		hpbar.pro:setMaxVal(hpbar.v.hpmax)
		hpbar.pro:setCurrVal(hpbar.v.hp)
		hpbar.pro:setVisible(hpbar.v.hp > 0)
		if hpbar.mpbar then
			hpbar.mpbar:setVisible(hpbar.v.hp > 0)
		end
		if hpbar.npbar then
			hpbar.npbar:setVisible(hpbar.v.hp > 0)
		end
	else
removeMergeHP(hpbar)
		local hp, hpmax = createMergeHP(hpbar, hpbar.v.hp, hpbar.v.hpmax, hpbar.v.mergehp)
		hpbar.pro:setMaxVal(hpmax)
		hpbar.pro:setCurrVal(hp)
		hpbar.pro:setVisible(hp > 0)
		if hpbar.mpbar then
			hpbar.mpbar:setVisible(hp > 0)
		end
		if hpbar.npbar then
			hpbar.npbar:setVisible(hp > 0)
		end
	end
end

function setHPBar(role,hp,hpmax,color,name,mergehp,showname,guildname,namecolor,np,showtitle,mp)--焦点显示
local newcreate
local hpbar
showname=showname or 显示名字==1
local p1=name:find("#c")
if p1 then
local p2=name:find("%[",p1+2)
if p2 then
namecolor=tonumber("0x"..name:sub(p1+2,p2-1))
name=name:sub(1,p1-1)..name:sub(p2)
else
namecolor=tonumber("0x"..name:sub(p1+2))
name=name:sub(1,p1-1)
end
showname=true
end
if not 游戏设置.SHOWNAMESERVER and name and not showtitle then
local p2=name:find("%.")
local p3=name:find("%[")
if p2 and p3 and p3<p2 then
name=name:sub(1,p3)..name:sub(p2+1)
elseif p2 then
name=name:sub(p2+1)
end
end
if not 游戏设置.SHOWNAMESERVER and guildname and not showtitle then
local p2=guildname:find("%.")
if p2 then
guildname=""--guildname:sub(p2+1)
end
end
if role.hpbar then
hpbar=role.hpbar
hpbar.showname=showname
hpbar.namecolor=namecolor
hpbar.showtitle=showtitle or role.objtype==全局设置.OBJTYPE_NPC
else
if#hpbarpool==0 then
hpbar=F3DLayout:new()
hpbar.showname=showname
hpbar.namecolor=namecolor
hpbar.showtitle=showtitle or role.objtype==全局设置.OBJTYPE_NPC
hpbar:setLoadPriority(g_uiFastPriority)
hpbar.v={hp=hp,hpmax=hpmax,color=color,name=name,mergehp=mergehp,guildname=guildname,np=np,mp=mp}
hpbar:addEventListener(F3DObjEvent.OBJ_INITED,func_oe(onHpBarInit))
if hpbar.setUIPack and USEUIPACK then
hpbar:setUIPack(g_mobileMode and UIPATH.."血条UIm.pack"or UIPATH.."血条UI.pack")
else
hpbar:setLayout(g_mobileMode and UIPATH.."血条UIm.layout"or UIPATH.."血条UI.layout")
end
newcreate=true
else
hpbar=hpbarpool[#hpbarpool]
hpbar.showname=showname
hpbar.namecolor=namecolor
hpbar.showtitle=showtitle or role.objtype==全局设置.OBJTYPE_NPC
table.remove(hpbarpool)
end
role.hpbar=hpbar
hpbar:setZOrder(-math.floor(role:getPositionY()/25)*10000+math.floor(role:getPositionX()/25))
hpcont:addChild(hpbar)
end
	if newcreate then
		elseif hpbar:isInited()then
		local ss=实用工具.SplitString(name,"\\")
		hpbar.name:setTitleText(txt(ss[1]))
		local nameindex=1
		if#ss>1 then
			hpbar.nameexs=hpbar.nameexs or{}
				if hpbar.showtitle or 游戏设置.SHOWTITLE then
					for i=2,#ss do
						local tf=hpbar.nameexs[i-1]or F3DTextField:new()
						if g_mobileMode then
							tf:setTextFont("宋体",16,false,false,false)
						end
						tf:setText(txt(ss[i]))
						tf:setTextColor(hpbar.namecolor or 0xffffff,0)
						tf:setPivot(0.5,0.5)
						tf:setPositionX(0)
						tf:setPositionY(50+(i-1)*14)
						tf:setVisible(true)
						hpbar:addChild(tf)
						hpbar.nameexs[i-1]=tf
						nameindex=i
					end
				end
			end
			if hpbar.nameexs then
				for i=nameindex,#hpbar.nameexs do
					hpbar.nameexs[i]:setVisible(false)
				end
			end
hpbar.guildname:setTitleText(txt((showname and guildname)and guildname or""))
			hpbar.name:setVisible(hpbar.showname or role==g_hoverObj)
			hpbar.name:setTextColor(hpbar.namecolor or 0xffffff)
			hpbar.guildname:setVisible(hpbar.showname or role == g_hoverObj)
			hpbar.guildname:setTextColor(hpbar.namecolor or 0xffffff)
			if not mp then
				removeMP(hpbar)
			else
				createMP(hpbar)
				hpbar.mpbar:setMaxVal(mp[2])
				hpbar.mpbar:setCurrVal(mp[1])
			end
			if not np then
				removeNP(hpbar)
			else
				createNP(hpbar)
				hpbar.npbar:setMaxVal(np[2])
				hpbar.npbar:setCurrVal(np[1])
			end
			if not mergehp or #mergehp == 0 then
				removeMergeHP(hpbar)
				hpbar.hpimg:setWidth(hpbar.track:getWidth())
				hpbar.hpimg:getColor():setRGB(color)--人物血条颜色
				hpbar.pro:setMaxVal(hpmax)
				hpbar.pro:setCurrVal(hp)
				hpbar.pro:setVisible(hp > 0)
			if hpbar.mpbar then
				hpbar.mpbar:setVisible(hp>0)
			end
			if hpbar.npbar then
				hpbar.npbar:setVisible(hp>0)
			end
		else
			removeMergeHP(hpbar)
			hpbar.hpimg:setWidth(hpbar.track:getWidth())
			hpbar.hpimg:getColor():setRGB(color)--人物血条颜色
			hp, hpmax = createMergeHP(hpbar, hp, hpmax, mergehp)
			hpbar.pro:setMaxVal(hpmax)
			hpbar.pro:setCurrVal(hp)
			hpbar.pro:setVisible(hp > 0)
			if hpbar.mpbar then
				hpbar.mpbar:setVisible(hp>0)
			end
			if hpbar.npbar then
				hpbar.npbar:setVisible(hp>0)
			end
		end
if role.type~=3 then
hpbar.count:setText(role.objtype==全局设置.OBJTYPE_PLAYER and txt(hp.."/"..hpmax.."/"..V_112(role.job)..role.level)or txt(hp==hpmax and (role.objtype==全局设置.OBJTYPE_MONSTER and ("J"..role.level)or "")or(role.objtype==全局设置.OBJTYPE_MONSTER and(hp.."/"..hpmax.."/J"..role.level)or(hp.."/"..hpmax))))
else
hpbar.count:setText(txt(""))
end

		else
			hpbar.v = {hp = hp,hpmax = hpmax,color = color,name = name,mergehp = mergehp,guildname = guildname}
		end
	if not role:isVisible() or (hp == hpmax and not mergehp) then
		hpbar:setVisible(true)
	else
		hpbar:setVisible(true)
	end
end
function V_112(job)
	if job==1 then
		return"Z"
	elseif job==2 then
		return"F"
	elseif job==3 then
		return"D"
	else
		return"Q"
	end
end
function delHPBar(role)
	local hpbar = role.hpbar
	if hpbar then
		hpbar.showname = nil
		hpbar.namecolor = nil
		if hpbar.titles then
			for i,v in pairs(hpbar.titles) do
				v:removeFromParent(true)
			end
			实用工具.DeleteTable(hpbar.titles)
		end
		if hpbar.titleanims then
			for i,v in pairs(hpbar.titleanims) do
				v:removeFromParent(true)
			end
			实用工具.DeleteTable(hpbar.titleanims)
		end
		if hpbar.nameexs then
			for i,v in ipairs(hpbar.nameexs) do
				v:removeFromParent(true)
			end
			实用工具.DeleteTable(hpbar.nameexs)
		end
		hpbar:removeFromParent()
		hpbarpool[#hpbarpool] = hpbar
		role.hpbar = nil
	end
end

function updateHPBar(role)
	local hpbar = role.hpbar
	if hpbar then
		hpbar:setVisible(role:isVisible())
	end
	if hpbar and hpbar:isVisible() then
		hpbar:setZOrder(-math.floor(role:getPositionY()/25)*10000+math.floor(role:getPositionX()/25))
		local pt = F3DUtils:getScreenPosition(role:getPositionX(), role:getPositionY(), role:getPositionZ() + 100)
		if pt then
			hpbar:setPositionX(pt.x)
			hpbar:setPositionY(pt.y)
		end
	end
end
