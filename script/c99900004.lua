--Bestia de pesadilla aguila de Obsidiana
local s,id,o=GetID()
function s.initial_effect(c)
   -- 1. Robar cartas por cada Demonio en el campo (Incluyendo Magias Continuas)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.drwtg)
	e1:SetOperation(s.drwop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)

	-- 2. Efecto Rápido: Devolver MONSTRUOS a la mano (Sin Seleccionar)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+100)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)

	-- 3. Regla "Gema"
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCondition(s.setcon)
	e4:SetOperation(s.setop)
	c:RegisterEffect(e4)
end

-- Funciones de Robo
function s.drwfilter(c)
	return c:IsRace(RACE_FIEND) and (c:IsLocation(LOCATION_MZONE) or c:IsType(TYPE_CONTINUOUS))
end
function s.drwtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		local count=Duel.GetMatchingGroupCount(s.drwfilter,tp,LOCATION_ONFIELD,0,nil)
		return count>0 and Duel.IsPlayerCanDraw(tp,count) 
	end
	local count=Duel.GetMatchingGroupCount(s.drwfilter,tp,LOCATION_ONFIELD,0,nil)
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(count)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,count)
end
function s.drwop(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local count=Duel.GetMatchingGroupCount(s.drwfilter,tp,LOCATION_ONFIELD,0,nil)
	if count>0 then
		Duel.Draw(p,count,REASON_EFFECT)
	end
end

-- Funciones Devolver Monstruos (Bounce masivo)
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroupCount(s.drwfilter,tp,LOCATION_ONFIELD,0,nil)>=2
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsType,tp,0,LOCATION_MZONE,nil,TYPE_MONSTER)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsType,tp,0,LOCATION_MZONE,nil,TYPE_MONSTER)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end

-- Función Gema estándar
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup() and (r&REASON_EFFECT+REASON_BATTLE)~=0
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	local e1=Effect.CreateEffect(c)
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
	e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
	c:RegisterEffect(e1) 
end
