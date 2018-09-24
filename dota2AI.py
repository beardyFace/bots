import numpy as np
import os
import sys
import tensorflow as tf

import cv2

class BotAI:
    def __init__(self):
        self.previous_state = None
        self.current_state  = None

        network = self.create_network()

        cv2.namedWindow('input', cv2.WINDOW_NORMAL)
        cv2.moveWindow('input', 40,30)

    def create_network(self):
        pass

    def update_state(self, state):
        self.previous_state = self.current_state
        self.current_state  = state

        # print(state)

    def drawHero(self, hero, input, bounds, ally):
        location        = hero['location']
        orientation     = hero['orientation']
        bounding_radius = hero['boundingRadius']

        x = (int)(location[0] + abs(bounds['minY']) - bounding_radius)
        y = (int)(location[1] + abs(bounds['minY']) - bounding_radius)

        input[x:x+bounding_radius, y:y+bounding_radius] = 1 if ally else 2

    def next_action(self):
        print('taking action')

        bounds        = self.current_state['bounds']
        ally_heroes   = self.current_state['ally_hero']
        enemry_heroes = self.current_state['enemy_hero']
        buildings     = self.current_state['buildings']
        ally_creep    = self.current_state['ally_creep']
        enemy_creep   = self.current_state['enemy_creep']

        width  = abs(minX) + abs(maxX)
        height = abs(minY) + abs(maxY)

        input = np.zeros((height, width, 3))

        for ally in ally_heroes:
            drawHero(ally, input, bounds, True)

        for enemy in enemy_heroes:
            drawHero(enemy, input, bounds, False)

        

        #scale the size of the image to something managable
        scale = 0.05
        height, width, channels = input.shape
        input = cv2.resize(input, ((int)(height*scale), (int)(width*scale), channels))

        cv2.imshow('input', input)
        cv2.waitKey(1)

        return 0