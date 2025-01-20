from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello():
    
    return 'This is my cool state of the art app!'

@app.route('/health')
def health():
    return 'OK'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)