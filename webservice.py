from flask import Flask, jsonify, request
# from ActorCritic import Model

app = Flask(__name__)

@app.route('/CreepBlockAI/model', methods=['POST'])
def get_model():
    return jsonify({})

@app.route('/CreepBlockAI/update', methods=['POST'])
def update():
    print("update")
    return jsonify({})
    
@app.route('/CreepBlockAI/dump', methods=['GET'])
def dump():
    print("dump")
    return jsonify({})
    
@app.route('/CreepBlockAI/load', methods=['POST'])
def load():
    print("load")
    return jsonify({})
    
if __name__ == '__main__':  
    app.run()