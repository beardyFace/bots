import numpy as np
import os
import sys
import tensorflow as tf

import cv2

HERO = 0
CREEP = 1
TOWER = 2
RAX = 3
THRONE = 4

class BotAI:
    def __init__(self):
        self.previous_state = None
        self.current_state  = None

        network = self.create_network()

        self.scale = 0.05
        self.state_size = 49

        cv2.namedWindow('input_data', cv2.WINDOW_NORMAL)
        cv2.moveWindow('input_data', 40,30)

    def create_network(self):
        pass

    def update_state(self, state):
        self.previous_state = self.current_state
        self.current_state  = state

        # print(state)

    def getPose(self, unit, bounds):
        enlarge         = 2 if (unit['type'] == TOWER or unit['type'] == RAX) else 10
        
        location        = unit['location']
        orientation     = unit['orientation']
        bounding_radius = unit['boundingRadius'] * enlarge * self.scale

        x = (int)(location[0] + abs(bounds['minY'])) * self.scale
        y = (int)(location[1] + abs(bounds['minY'])) * self.scale

        return {'x' : x, 'y' : y, 't' : orientation, 'r' : bounding_radius}

    def drawUnit(self, unit, input_data, bounds):
        pose = self.getPose(unit, bounds)

        unit_state = np.zeros(self.state_size)

        index = 0
        def setValue(state, index, value):
            state[index] = value
            index+=1
            return index
            
        index = setValue(unit_state, index, unit['team'])
        index = setValue(unit_state, index, unit['id'])
        index = setValue(unit_state, index, unit['type'])
        index = setValue(unit_state, index, unit['alive'])
        index = setValue(unit_state, index, unit['level'])
        index = setValue(unit_state, index, unit['activity'])
        index = setValue(unit_state, index, unit['health'])
        index = setValue(unit_state, index, unit['maxHealth'])
        index = setValue(unit_state, index, unit['healthRegen'])
        index = setValue(unit_state, index, unit['mana'])
        index = setValue(unit_state, index, unit['maxMana'])
        index = setValue(unit_state, index, unit['manaRegen'])
        index = setValue(unit_state, index, unit['moveSpeed'])
        index = setValue(unit_state, index, unit['visionRange'])
        index = setValue(unit_state, index, unit['attackDamage'])
        index = setValue(unit_state, index, unit['attackRange'])
        index = setValue(unit_state, index, unit['attackSpeed'])
        index = setValue(unit_state, index, unit['attackProjSpeed'])
        index = setValue(unit_state, index, unit['spellAmp'])
        index = setValue(unit_state, index, unit['armor'])
        index = setValue(unit_state, index, unit['magicResist'])
        index = setValue(unit_state, index, unit['evasion'])
        index = setValue(unit_state, index, unit['netWorth'])
        index = setValue(unit_state, index, unit['isIllusion'])
        index = setValue(unit_state, index, unit['isChanneling'])
        index = setValue(unit_state, index, unit['isCastingAbility'])
        index = setValue(unit_state, index, unit['isUsingAbility'])
        index = setValue(unit_state, index, unit['isAttackImmune'])
        index = setValue(unit_state, index, unit['isBlind'])
        index = setValue(unit_state, index, unit['isBlockDisabled'])
        index = setValue(unit_state, index, unit['isDisarmed'])
        index = setValue(unit_state, index, unit['isEvadeDisabled'])
        index = setValue(unit_state, index, unit['isHexed'])
        index = setValue(unit_state, index, unit['isInvisible'])
        index = setValue(unit_state, index, unit['isInvulnerable'])
        index = setValue(unit_state, index, unit['isMagicImmune'])
        index = setValue(unit_state, index, unit['isMuted'])
        index = setValue(unit_state, index, unit['isNightmared'])
        index = setValue(unit_state, index, unit['isRooted'])
        index = setValue(unit_state, index, unit['isSilenced'])
        index = setValue(unit_state, index, unit['isSpeciallyDeniable'])
        index = setValue(unit_state, index, unit['isStunned'])
        index = setValue(unit_state, index, unit['isUnableToMiss'])
        # index = setValue(state, index, unit['velocity'])

        if 'items' in unit:
            def adddItemState(state, index, item):
                index = setValue(state, index, int(item['name']))
                index = setValue(state, index, item['mana_cost'])
                index = setValue(state, index, item['cd_remaining'])
                index = setValue(state, index, item['cast_range'])
                index = setValue(state, index, item['damage'])
                return index

            for _, item in unit['items'].iteritems():
                index = adddItemState(unit_state, index, item)
            
        input_data[pose['x']:pose['x']+pose['r'], pose['y']:pose['y']+pose['r']] = unit_state

        if 'incomingProjectiles' in unit:
            def createTrackingState(state, projectile):
                projectile_state = np.zeros(self.state_size)
                # projectile_msg.location = VectorToArray(projectile.location)

                # projectile_msg.caster   = projectile.caster:GetPlayerID()
                # projectile_msg.team     = projectile.caster:GetTeam()
                
                # projectile_msg.velocity = VectorToArray(projectile.velocity)
                # projectile_msg.radius   = projectile.radius
                
                # projectile_msg.ability    = projectile.ability:GetName()
                # projectile_msg.damage     = projectile.ability:GetAbilityDamage()
                # projectile_msg.damageType = projectile.ability:GetDamageType()
                return projectile_state

            # tracked
            for _, projectile in unit['projectile']['tracked']:
                pose = self.getPose(projectile, bounds)
                projectile_state = createTrackingState(projectile)
                input_data[pose['x']:pose['x']+pose['r'], pose['y']:pose['y']+pose['r']] = projectile_state
            #linear

            #avoidance
            # avoidance_zones = unit['projectile']['avoidance']
            # for _, zone in avoidance_zones.iteritems():
            #     pass

        # unit['projectiles']    
                # print item
            # abilities
            # projectiles

    def next_action(self):
        print('taking action')

        bounds        = self.current_state['bounds']
        ally_heroes   = self.current_state['ally_hero']
        enemy_heroes  = self.current_state['enemy_hero']
        buildings     = self.current_state['buildings']
        ally_creep    = self.current_state['ally_creep']
        enemy_creep   = self.current_state['enemy_creep']

        minX = bounds['minX']
        minY = bounds['minY']
        maxX = bounds['maxX']
        maxY = bounds['maxY']

        width  = int((abs(minX) + abs(maxX)) * self.scale)
        height = int((abs(minY) + abs(maxY)) * self.scale)

        input_data = np.zeros((height, width, self.state_size))

        for _, rax in buildings['raxes'].iteritems():
            self.drawUnit(rax, input_data, bounds)

        for _, tower in buildings['towers'].iteritems():
            self.drawUnit(tower, input_data, bounds)

        for creep in ally_creep:
            self.drawUnit(creep, input_data, bounds)

        for creep in enemy_creep:
            self.drawUnit(creep, input_data, bounds)

        for enemy in enemy_heroes:
            self.drawUnit(enemy, input_data, bounds)

        for ally in ally_heroes:
            self.drawUnit(ally, input_data, bounds)

        cv2.imshow('input_data', input_data[: , :, :3])
        cv2.waitKey(1)

        return 0