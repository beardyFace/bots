from flask import Flask, jsonify, request
from dota2AI import BotAI

app = Flask(__name__)

bot = BotAI()

@app.route('/update', methods=['POST'])
def update():
    bot.update_state(request.json)
    return jsonify(bot.next_action())
    
if __name__ == '__main__':  
    app.run()