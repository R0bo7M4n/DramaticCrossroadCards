--25898001
--scripted by R0bo7M4n
local s,id=GetID()
function s.initial_effect(c)
        --Special Summon
        local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id, 0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1, id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
        s.hand_effect = e1
        --Add from Deck to hand
        local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id, 1))
	e2:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS) 
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3 = e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
s.listed_names={CARD_HARPIE_LADY}
function s.filter(c)
	return c:IsSpellTrap()
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk, chknum)
	if chk == 0 then 
		return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
			and e:GetHandler():IsCanBeSpecialSummoned(e, 0, tp, false, false)
			and Duel.IsExistingTarget(s.filter, tp, LOCATION_ONFIELD, 0, 1, nil)
	end
	
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
	local g = Duel.SelectTarget(tp, s.filter, tp, LOCATION_ONFIELD, 0, 1, 1, nil)
	
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, e:GetHandler(), 1, 0, 0)
	Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, 1, 0, 0)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	local tc = Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) then return end
	if Duel.SpecialSummon(c, 0, tp, tp, false, false, LOCATION_MZONE) > 0 then
		if tc and tc:IsRelateToEffect(e) and tc:IsControler(tp) then
			Duel.BreakEffect() 
			Duel.Destroy(tc, REASON_EFFECT)
		end
	end
end
function s.thfilter(c)
	return (c:IsCode(19337371) or c:IsCode(25898004) or c:IsCode(77778835)) and c:IsAbleToHand()
end

function s.thcon(e, tp, eg, ep, ev, re, r, rp)
	return not (e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL) and re == s.hand_effect)
end

function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then 
		return Duel.IsExistingMatchingCard(s.thfilter, tp, LOCATION_DECK, 0, 1, nil) 
	end
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function s.thop(e, tp, eg, ep, ev, re, r, rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
	local g = Duel.SelectMatchingCard(tp, s.thfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
	if #g > 0 then
		Duel.SendtoHand(g, nil, REASON_EFFECT)
		Duel.ConfirmCards(1-tp, g)
	end
end