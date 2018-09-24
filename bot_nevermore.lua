local fountainLocation = Vector(0, 0, 384.0);
local fountainRadius = 400.0;

local baseURL = ":5000"
local reply
local sendSate = true

function VectorToArray(v)
	return {v.x, v.y, v.z}
end

function getCreepState(creep)
	--determine if rax state has changed so we don't send data every single time step
	local creepState = {}
	creepState.team = creep:GetTeam()
	creepState.type = 'creep'

	creepState.alive    = creep:IsAlive()
	creepState.health   = creep:GetHealth()
	creepState.location = VectorToArray(creep:GetLocation())--wont change, maybe send once?

	return creepState
end

function getCreeps(unit_type)
	local creepMsg = {}
	local creeps = GetUnitList(unit_type)
	for i, creep in pairs(creeps) do
		creepMsg[i] = getCreepState(creep)
	end
	return creepMsg
end

function getRaxState(team, rax_id)
	--determine if rax state has changed so we don't send data every single time step
	local rax = GetBarracks(team, rax_id)--hUnit

	local raxState = {}
	raxState.team = rax:GetTeam()
	raxState.type = 'rax'

	raxState.alive    = rax:IsAlive()
	raxState.health   = rax:GetHealth()
	raxState.location = VectorToArray(rax:GetLocation())--wont change, maybe send once?

	return raxState
end

function getRaxStates()
	local raxes = {}

	raxes[0]  = getRaxState(TEAM_RADIANT, BARRACKS_TOP_MELEE)
	raxes[1]  = getRaxState(TEAM_RADIANT, BARRACKS_TOP_RANGED)
	raxes[2]  = getRaxState(TEAM_RADIANT, BARRACKS_MID_MELEE)
	raxes[3]  = getRaxState(TEAM_RADIANT, BARRACKS_MID_RANGED)
	raxes[4]  = getRaxState(TEAM_RADIANT, BARRACKS_BOT_MELEE)
	raxes[5]  = getRaxState(TEAM_RADIANT, BARRACKS_BOT_RANGED)

	raxes[6]  = getRaxState(TEAM_DIRE, BARRACKS_TOP_MELEE)
	raxes[7]  = getRaxState(TEAM_DIRE, BARRACKS_TOP_RANGED)
	raxes[8]  = getRaxState(TEAM_DIRE, BARRACKS_MID_MELEE)
	raxes[9]  = getRaxState(TEAM_DIRE, BARRACKS_MID_RANGED)
	raxes[10] = getRaxState(TEAM_DIRE, BARRACKS_BOT_MELEE)
	raxes[11] = getRaxState(TEAM_DIRE, BARRACKS_BOT_RANGED)

	return raxes
end

function getTowerState(team, tower_id)
	local tower = GetTower(team, tower_id)--hUnit

	local towerState = {}
	towerState.team = tower:GetTeam()
	towerState.type = 'tower'

	towerState.alive    = tower:IsAlive()
	towerState.health   = tower:GetHealth()
	towerState.location = VectorToArray(tower:GetLocation())--wont change, maybe send once?

	return towerState
end

function getTowerStates()
	--determine if tower state has changed so we don't send data every single time step
	local towers = {}

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

function getBuildings()
	local buildings = {}
	buildings['towers'] = getTowerStates()
	buildings['raxes']  = getRaxStates()
	return buildings
end

function getItems( bot)
	local items = {}
    for i = 0, 5, 1 do
    	local item = bot:GetItemInSlot(i)
    	local item_msg = {}
    	item_msg.name = ""
    	if item ~= nil then
	        item_msg.name         = item:GetName()
	        item_msg.mana_cost    = item:GetManaCost()
	        item_msg.cd_remaining = item:GetCooldownTimeRemaining()
	        item_msg.cast_range   = item:GetCastRange()
	        item_msg.damage		  = item:GetAbilityDamage()
        end
        items[i] = item_msg
    end
    return items
end

function GetAvoidanceZoneState(zone)
	-- { {location, ability, caster, radius }, ... } GetAvoidanceZones() 
end

function getLinearProjectileState(projectile)
	-- { {location, caster, player, ability, velocity, radius, handle }, ... } GetLinearProjectiles() 
	local projectile_msg = {}
	projectile_msg.location = VectorToArray(projectile.location)

	projectile_msg.caster 	= projectile.caster:GetPlayerID()
	projectile_msg.team 	= projectile.caster:GetTeam()
	
	projectile_msg.velocity = VectorToArray(projectile.velocity)
	projectile_msg.radius   = projectile.radius
	
	projectile_msg.ability    = projectile.ability:GetName()
	projectile_msg.damage 	  = projectile.ability:GetAbilityDamage()
	projectile_msg.damageType = projectile.ability:GetDamageType()

	return projectile_msg
end

function getTrackedProjectileState(projectile)
	-- { { location, caster, player, ability, is_dodgeable, is_attack }, ... } GetIncomingTrackingProjectiles() 
	local projectile_msg = {}

	projectile_msg.location     = VectorToArray(projectile.location)
	
	projectile_msg.caster 		= projectile.caster:GetPlayerID()
	projectile_msg.team 		= projectile.caster:GetTeam()

	projectile_msg.isDodgeable  = projectile.is_dodgeable
	
	projectile_msg.isAttack     = projectile.is_attack
	
	if projectile.is_attack then
		projectile_msg.damage 		= projectile.caster:GetAttackDamage()
	else
		projectile_msg.damage 	  	= projectile.ability:GetAbilityDamage()
		projectile_msg.damageType 	= projectile.ability:GetDamageType()
	end


	if not projectile.is_attack then
		projectile_msg.ability    = projectile.ability:GetName()
	end
	
	return projectile_msg
end

function getProjectiles(bot)
	local projectiles = {}

	local trackedProjStates = {}
	local trackProjectiles = bot:GetIncomingTrackingProjectiles()
	for i, projectile in pairs(trackProjectiles) do
		trackedProjStates[i] = getTrackedProjectileState(projectile)
		bot:ActionImmediate_Chat("Tracked", true)
	end
	projectiles['tracked'] = trackedProjStates

	local linearProjStates = {}
	local linearProjectiles = GetLinearProjectiles()
	for i, projectile in pairs(linearProjectiles) do

		linearProjStates[i] = getLinearProjectileState(projectile)
	end
	projectiles['linear'] = linearProjStates

	local avoidanceZoneStates = {}
	local avoidanceZones = GetAvoidanceZones() 
	for i, zone in pairs(avoidanceZones) do
		avoidanceZoneStates[i] = GetAvoidanceZoneState(zone)
	end
	projectiles['avoidance'] = avoidanceZoneStates

	return projectiles
end

function getHeroState(bot)
	local jsonEvent = {}
	jsonEvent.team = bot:GetTeam()
    jsonEvent.id   = bot:GetPlayerID() 
    jsonEvent.type = 'hero'

    ----Hero stats
    jsonEvent.alive 	          = bot:IsAlive()
    jsonEvent.level 		      = bot:GetLevel()
    jsonEvent.location 		      = VectorToArray(bot:GetLocation())
    jsonEvent.orientation 	      = bot:GetFacing()
    jsonEvent.velocity            = VectorToArray(bot:GetVelocity())
    jsonEvent.activity 			  = bot:GetAnimActivity()

    jsonEvent.health              = bot:GetHealth()
    jsonEvent.maxHealth           = bot:GetMaxHealth()
    jsonEvent.healthRegen         = bot:GetHealthRegen()
    
    jsonEvent.mana 		          = bot:GetMana()
    jsonEvent.maxMana             = bot:GetMaxMana()
    jsonEvent.manaRegen           = bot:GetManaRegen()

    jsonEvent.moveSpeed           = bot:GetCurrentMovementSpeed()
    jsonEvent.visionRange         = bot:GetCurrentVisionRange()
    jsonEvent.boundingRadius      = bot:GetBoundingRadius()

    jsonEvent.attackDamage        = bot:GetAttackDamage()
    jsonEvent.attackRange         = bot:GetAttackRange()
    jsonEvent.attackSpeed         = bot:GetAttackSpeed()
    jsonEvent.attackProjSpeed     = bot:GetAttackProjectileSpeed()

    jsonEvent.spellAmp		      = bot:GetSpellAmp()
    jsonEvent.armor 		      = bot:GetArmor()
    jsonEvent.magicResist         = bot:GetMagicResist()
    jsonEvent.evasion             = bot:GetEvasion()
    jsonEvent.netWorth 		      = bot:GetNetWorth()

    --Hero state
    jsonEvent.isIllusion 		  = bot:IsIllusion()
    jsonEvent.isChanneling 	      = bot:IsChanneling()
    jsonEvent.isCastingAbility    = bot:IsCastingAbility()
    jsonEvent.isUsingAbility      = bot:IsUsingAbility()
    jsonEvent.isAttackImmune      = bot:IsAttackImmune()
    jsonEvent.isBlind 		      = bot:IsBlind()
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
    
    jsonEvent.items = getItems(bot)

    jsonEvent.currentAbility = ''
    if bot:IsCastingAbility() then
    	local ability = bit:GetCurrentActiveAbility()
    	local ability_msg ={}
    	ability_msg.name = ability:GetName()
    	jsonEvent.currentAbility = ability_msg
    end

    jsonEvent.incomingProjectiles = getProjectiles(bot)

	return jsonEvent
end

function getHeroes(unit_type)
	local heroesMsg = {}
	local heroes = GetUnitList(unit_type)
	for i, hero in pairs(heroes) do
		heroesMsg[i] = getHeroState(hero)
	end
	return heroesMsg
end

function getWorldBounds()
	local worldBounds = {}
	-- Returns a table containing the min X, min Y, max X, and max Y bounds of the world.
	local bounds = GetWorldBounds() 

	worldBounds.minX = bounds[1]
	worldBounds.minY = bounds[2]
	worldBounds.maxX = bounds[3]
	worldBounds.maxY = bounds[4]

	return worldBounds
end

function getState(bot)
	local jsonEvent = {}

	jsonEvent['bounds']		 = getWorldBounds()
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

    local angle = math.rad(math.fmod(npcBot:GetFacing()+30, 360)); -- Calculate next position's angle
	local newLocation = Vector(fountainLocation.x+fountainRadius*math.cos(angle), fountainLocation.y+fountainRadius*math.sin(angle), fountainLocation.z);
	npcBot:Action_MoveToLocation(newLocation);
	DebugDrawLine(fountainLocation, newLocation, 255, 0, 0);
 	
    local badProjectiles = GetLinearProjectiles()
    for _, projectile in pairs(badProjectiles) do
		DebugDrawCircle(projectile.location, projectile.radius, 255, 0 , 0)
		-- npcBot:ActionImmediate_Chat("Linear", true)
	end

	local trackProjectiles = npcBot:GetIncomingTrackingProjectiles()
	for _, projectile in pairs(trackProjectiles) do
		DebugDrawCircle(projectile.location, 30, 255, 255 , 0)
		-- npcBot:ActionImmediate_Chat("Tracking", true)
	end
 	
 	-- local chat = baseURL .. "/CreepBlockAI/model"
 	-- npcBot:ActionImmediate_Chat(chat, true)
 	if sendSate then
 		sendSate = false
	 	local request = CreateHTTPRequest(baseURL .. "/update")
	 	
	 	local jsonMsg = getState(npcBot)

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
	end
	if reply ~= nil then
		-- npcBot:ActionImmediate_Chat("Replied: ", false)	
		reply = nil
		sendSate = true
	end
end 