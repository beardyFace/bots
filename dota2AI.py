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

	def create_network(self):
		pass

	def update_state(self, state):
		self.previous_state = self.current_state
		self.current_state  = state

		print(state)

	def next_action(self):
		print('taking action')
		return 0