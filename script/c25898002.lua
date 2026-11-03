--25898002
--scripted by R0bo7M4n
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	
	--Special Summon Procedure
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_EXTRA)
        e1:SetCountLimit(1,id,EFFECT_COUNT_OATH)
	e1:SetCondition(s.sprcon)
	e1:SetTarget(s.sprtg)
	e1:SetOperation(s.sprop)
	c:RegisterEffect(e1)
	
	--Cannot be used as Fusion Material
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	
	--This card's name becomes "Harpie Lady" while on the field or in the GY
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_CHANGE_CODE)
	e3:SetRange(LOCATION_MZONE|LOCATION_GRAVE)
	e3:SetValue(CARD_HARPIE_LADY)
	c:RegisterEffect(e3)
        
        local e4=Effect.CreateEffect(c)
    	e4:SetType(EFFECT_TYPE_IGNITION)
    	e4:SetRange(LOCATION_MZONE)
    	e4:SetCountLimit(1)
    	e4:SetCost(s.cost)
    	e4:SetOperation(s.operation)
    	c:RegisterEffect(e4)
end

function s.matfilter1(c, sc)
	return c:IsSummonCode(sc, SUMMON_TYPE_SPECIAL, c:GetControler(), CARD_HARPIE_LADY) 
		and c:IsAbleToGraveAsCost()
end

function s.anywindfilter(c, sc)
	return c:IsAttribute(ATTRIBUTE_WIND) 
		and c:IsAbleToGraveAsCost()
end

function s.rescon(sg, e, tp, mg)
	if #sg ~= 2 then return false end
	
	local tc1, tc2 = sg:GetFirst(), sg:GetNext()
	if not tc1 or not tc2 or tc1 == tc2 then return false end
	
	local sc = e:GetHandler()
	local has_harpie = s.matfilter1(tc1, sc) or s.matfilter1(tc2, sc)
	local has_wind = s.anywindfilter(tc1, sc) and s.anywindfilter(tc2, sc)
	
	if not (has_harpie and has_wind) then return false end
	
	local has_hand = tc1:IsLocation(LOCATION_HAND) or tc2:IsLocation(LOCATION_HAND)
	local has_field = tc1:IsLocation(LOCATION_MZONE) or tc2:IsLocation(LOCATION_MZONE)
	
	return has_hand and has_field
end

function s.sprcon(e, c)
	if c==nil then return true end
	local tp=c:GetControler()
	local rg=Duel.GetMatchingGroup(function(tc) 
		return s.matfilter1(tc,c) or s.anywindfilter(tc,c) 
	end, tp, LOCATION_HAND|LOCATION_MZONE, 0, nil)
	return Duel.GetLocationCountFromEx(tp,tp,rg,c)>0 and aux.SelectUnselectGroup(rg, e, tp, 2, 2, s.rescon, 0)
end

function s.sprtg(e,tp,eg,ep,ev,re,r,rp,c)
	local rg=Duel.GetMatchingGroup(function(tc) 
		return s.matfilter1(tc,c) or s.anywindfilter(tc,c) 
	end, tp, LOCATION_HAND|LOCATION_MZONE, 0, nil)
	local g=aux.SelectUnselectGroup(rg, e, tp, 2, 2, s.rescon, 1, tp, HINTMSG_TOGRAVE, s.rescon, s.rescon)
	if g and #g > 0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end

function s.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.SendtoGrave(g, REASON_COST+REASON_MATERIAL)
	g:DeleteGroup()
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckLPCost(tp,500) end
    Duel.PayLPCost(tp,500)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetFlagEffect(tp,id)~=0 then return end
    
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
    e1:SetTarget(s.sumtg)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
    
    Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end

function s.sumtg(e,c)
    return c:IsSetCard(0x64)
end