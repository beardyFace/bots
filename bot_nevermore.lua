local fountainLocation = Vector(0, 0, 384.0);
local fountainRadius = 400.0;
 
--------------------------------------------------------------------------------

local baseURL = ":5000"
local reply

function VectorToArray(v)
	return {v.x, v.y, v.z}
end

function getRaxState(team, rax_id)
	--determine if rax state has changed so we don't send data every single time step
	rax = GetBarracks(team, rax_id)--hUnit
end

function getRaxStates()
	raxes = {}

	return raxes
end

function getTowerState(team, tower_id)
	tower = GetTower(team, tower_id)--hUnit

	towerState = {}
	towerState.team = tower:GetTeam()
	towerState.type = 'tower'

	towerState.alive    = tower:IsAlive()
	towerState.health   = tower:GetHealth()
	towerState.location = VectorToArray(tower:GetLocation())

	return towerState
end

function getTowerStates()
	--determine if tower state has changed so we don't send data every single time step
	towers = {}

	towers[0]  = getTowerState(TEAM_RADIANT, TOWER_TOP_1)
	towers[1]  = getTowerState(TEAM_RADIANT, TOWER_TOP_2)
	towers[2]  = getTowerState(TEAM_RADIANT, TOWER_TOP_3)

	towers[3]  = getTowerState(TEAM_RADIANT, TOWER_MID_1)
	towers[4]  = getTowerState(TEAM_RADIANT, TOWER_MID_2)
	towers[5]  = getTowerState(TEAM_RADIANT, TOWER_MID_3)

	towers[6]  = getTowerState(TEAM_RADIANT, TOWER_BOT_1)
	towers[7]  = getTowerState(TEAM_RADIANT, TOWER_BOT_2)
	towers[8]  = getTowerState(TEAM_RADIANT, TOWER_BOT_3)

	towers[9]  = getTowerState(TEAM_DIRE, TOWER_TOP_1)
	towers[10] = getTowerState(TEAM_DIRE, TOWER_TOP_2)
	towers[11] = getTowerState(TEAM_DIRE, TOWER_TOP_3)

	towers[12] = getTowerState(TEAM_DIRE, TOWER_MID_1)
	towers[13] = getTowerState(TEAM_DIRE, TOWER_MID_2)
	towers[14] = getTowerState(TEAM_DIRE, TOWER_MID_3)

	towers[15] = getTowerState(TEAM_DIRE, TOWER_BOT_1)
	towers[16] = getTowerState(TEAM_DIRE, TOWER_BOT_2)
	towers[17] = getTowerState(TEAM_DIRE, TOWER_BOT_3)

	return towers
end

function getCreepState(team)

end

function getHeroState(bot)
	jsonEvent = {}
	jsonEvent.team = bot:GetTeam()
    jsonEvent.id   = bot:GetPlayerID() 
    jsonEvent.type = 'hero'

    ----Hero stats
    jsonEvent.alive 	          = bot:IsAlive()
    jsonEvent.level 		      = bot:GetLevel()
    jsonEvent.location 		      = VectorToArray(bot:GetLocation())
    jsonEvent.orientation 	      = bot:GetFacing()
    jsonEvent.velocity            = VectorToArray(bot:GetVelocity())

    jsonEvent.health              = bot:GetHealth()
    jsonEvent.maxHealth           = bot:GetMaxHealth()
    jsonEvent.healthRegen         = bot:GetHealthRegen()
    
    jsonEvent.mana 		          = bot:GetMana()
    jsonEvent.maxMana             = bot:GetMaxMana()
    jsonEvent.manaRegen           = bot:GetManaRegen()

    jsonEvent.moveSpeed           = bot:GetCurrentMoveSpeed()
    jsonEvent.visionRange         = bot:GetCurrentVisionRange()
    jsonEvent.boundingRadius      = bot:GetBoundingRadius()

    jsonEvent.attackDamage        = bot:GetAttackDamage()
    jsonEvent.attackRange         = bot:GetAttackRange()
    jsonEvent.attackSpeed         = bot:GetAttackSpeed()
    jsonEvent.attackProjSpeed     = bot:GetAttackProjectileSpeed()

    jsonEvent.spellAmp		      = bot:GetSpellAmp()
    jsonEvent.armor 		      = bot:GetArmor()
    jsonEvent.magicResist         = bot:GetMagicResist()
    jsonEvent.evasion             = bot:GetEvaision()
    jsonEvent.netWorth 		      = bot:GetNetWorth()

    --Hero state
    jsonEvent.isChanneling 	      = bot:IsChanneling()
    jsonEvent.isUsingAbility      = bot:IsUsingAbility()
    jsonEvent.isAttackImmune      = bot:IsAttackImmune()
    jsonEvent.isBlind 		      = bot:isBlind()
    jsonEvent.isBlockDisabled     = bot:IsBlockDisabled()
    jsonEvent.isDisarmed          = bot:IsDisarmed()
    jsonEvent.isEvadeDisabled     = bot:IsEvadeDisabled()
    jsonEvent.isHexed             = bot:IsHexed()
    jsonEvent.isInvisible         = bot:IsInvisible()
    jsonEvent.isInvulnerable      = bot:IsInvulnerable()
    jsonEvent.isMagicImmune       = bot:IsMagicImmune()
    jsonEvent.isMuted 		      = bot:IsMuted()
    jsonEvent.isNightmared        = bot:IsNightmared()
    jsonEvent.isRooted 		      = bot:IsRooted()
    jsonEvent.isSilenced          = bot:IsSilenced()
    jsonEvent.isSpeciallyDeniable = bot:IsSpeciallyDeniable() 
    jsonEvent.isStunned 		  = bot:IsStunned()
    jsonEvent.isUnableToMiss 	  = bot:IsUnableToMiss()

 --    for i = 0, 5, 1 do
 --        item = bot:GetItemInSlot(i)
 --        jsonEvent.item[i] = item
 --    end

 --    jsonEvent.currentAbility = ''
 --    if bot:IsCastingAbility then
 --    	ability = bit:GetCurrentActiveAbility()
 --    	jsonEvent.currentAbility = ability
 --    end

	-- local trackProjectiles = npcBot:GetIncomingTrackingProjectiles()
	-- for i, projectile in pairs(trackProjectiles) do
	-- 	jsonEvent.incomingProjectiles[i] = projectile
	-- end

	local json = require "game/dkjson"

	-- local table = json.decode("...")
	local string = json.encode(jsonEvent)

	return string
end

function getHeroes(unit_type)
	-- UNIT_LIST_ALLIED_HEROES
	heroesMsg = {}
	heroes = GetUnitList(unit_type)
	for i, hero in pairs(heroes) do
		heroesMsg[i] = getHeroState(hero)
	end
	return heroesMsg
end

function getCreeps(unit_type)
	creepMsg = {}
	creeps = GetUnitList(unit_type)
	for i, creep in pairs(creeps) do
		creepMsg[i] = getCreepState(creep)
	end
	return creepMsg
end

function getState(bot)
	jsonEvent = {}

	jsonEvent['hero'] 		 = getHeroState(bot)
	jsonEvent['ally_hero']   = getHeroes(UNIT_LIST_ALLIED_HEROES)
	jsonEvent['enemy_hero']  = getHeroes(UNIT_LIST_ENEMY_HEROES)
	jsonEvent['buildings']   = getBuildings()
	jsonEvent['ally_creep']  = getCreeps(UNIT_LIST_ALLIED_CREEPS)
	jsonEvent['enemy_creep'] = getCreeps(UNIT_LIST_ENEMY_CREEPS)
	
	-- local table = json.decode("...")
	local json = require "game/dkjson"
	local string = json.encode(jsonEvent)
	return string
end

function Think()
 
    local npcBot = GetBot();--hUnit
 	
    local badProjectiles = GetLinearProjectiles()
    for _, projectile in pairs(badProjectiles) do
		DebugDrawCircle(projectile.location, projectile.radius, 255, 0 , 0)
		npcBot:ActionImmediate_Chat("Linear", true)
	end

	local trackProjectiles = npcBot:GetIncomingTrackingProjectiles()
	for _, projectile in pairs(trackProjectiles) do
		DebugDrawCircle(projectile.location, 30, 255, 255 , 0)
		npcBot:ActionImmediate_Chat("Tracking", true)
	end
 	
 	-- local chat = baseURL .. "/CreepBlockAI/model"
 	-- npcBot:ActionImmediate_Chat(chat, true)
 	request = CreateHTTPRequest(baseURL .. "/update")
 	
 	jsonMsg = getState(npcBot)

 	request:SetHTTPRequestRawPostBody('application/json', jsonMsg)
	request:Send( 	
					function( result ) 
						if result["StatusCode"] == 200 then
						-- 	-- local data = package.loaded['game/dkjson'].decode(result['Body'])
						-- 	npcBot:ActionImmediate_Chat("Loaded Latest Model", true)								
						-- else
						-- 	npcBot:ActionImmediate_Chat("Failed", true)								
							reply = result
							print(result)
						end
					end 
				)

	if reply ~= nil then
		npcBot:ActionImmediate_Chat("Replied: ", false)	
		reply = nil
	end
end 

-- local angle = math.rad(math.fmod(npcBot:GetFacing()+30, 360)); -- Calculate next position's angle
-- local newLocation = Vector(fountainLocation.x+fountainRadius*math.cos(angle), fountainLocation.y+fountainRadius*math.sin(angle), fountainLocation.z);
-- npcBot:Action_MoveToLocation(newLocation);
-- DebugDrawLine(fountainLocation, newLocation, 255, 0, 0);