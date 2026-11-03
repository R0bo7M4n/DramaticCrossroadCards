--25898006
--scripted by R0bo7M4n
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsAttribute, ATTRIBUTE_WIND), 7, 2)
	c:EnableReviveLimit()
	--Can use 1 Harpie monsters as Level 7 material
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e0:SetCode(EFFECT_XYZ_LEVEL)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetTargetRange(LOCATION_MZONE,0)
	e0:SetTarget(function(e,c) return c:IsSetCard(0x64) and not c:IsCode(85696777) end)
	e0:SetValue(s.lvval)
	c:RegisterEffect(e0)
        --Gains 300 ATK/DEF
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
        --cannot be target
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
        e3:SetCondition(s.dircon)
	e3:SetValue(1)
	c:RegisterEffect(e3)
        --Special Summon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)




end
local last_id=nil

function s.lvval(e,c,rc)
	local lv=c:GetLevel()
	if lv==0 then lv=c:GetRank() end
	if rc~=e:GetHandler() then return lv end
	if c:IsAttribute(ATTRIBUTE_WIND) and c:GetOriginalLevel()==7 then
		return 7|(lv<<16)
	end
	if last_id==nil then
		last_id=c
	end
	if last_id~=c then
		last_id=nil
		return lv
	end
	return 7|(lv<<16)
end
function s.atkval(e,c)
	local tp=c:GetControler()
	local names={}
	local count=0
	local mg=c:GetOverlayGroup()
	for tc in aux.Next(mg) do
		if (tc:IsSetCard(0x64) and tc:IsMonster()) then
			local code=tc:GetOriginalCode()
			if not names[code] then
				names[code]=true
				count=count+1
			end
		end
	end
	local gy=Duel.GetFieldGroup(tp,LOCATION_GRAVE,0)
	for tc in aux.Next(gy) do
		if (tc:IsSetCard(0x64) and tc:IsMonster()) then
			local code=tc:GetOriginalCode()
			if not names[code] then
				names[code]=true
				count=count+1
			end
		end
	end
	return count*300
end

function s.cfilter1(c)
	return c:IsFaceup() and c:IsSetCard(SET_HARPIE_LADY)
end
function s.dircon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_MZONE,0,1,nil)
end

function s.spfilter(c,e,tp,mc)
	return c:IsCode(85909450) and mc:IsCanBeXyzMaterial(c,tp) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0 and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(c),tp,nil,nil,REASON_XYZ)
		return (#pg<=0 or (#pg==1 and pg:IsContains(c))) and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsFaceup() and c:IsRelateToEffect(e) and c:IsControler(tp) and not c:IsImmuneToEffect(e)) then return end
	local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(c),tp,nil,nil,REASON_XYZ)
	if #pg>1 or (#pg==1 and not pg:IsContains(c)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c):GetFirst()
	if not sc then return end
	sc:SetMaterial(c)
	Duel.Overlay(sc,c)
	if Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)>0 then
		sc:CompleteProcedure()
		local mg=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_EXTRA,0,nil,SET_GALAXY)
		if #mg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
			local mc=mg:Select(tp,1,1,nil)
			Duel.BreakEffect()
			Duel.Overlay(sc,mc)
		end
	end
end





