from flask import Flask, request
from inference_sdk import InferenceHTTPClient
import base64
import io
from PIL import Image

app = Flask(__name__)

CLIENT = InferenceHTTPClient(
    api_url="https://detect.roboflow.com",
    api_key="2dS40Rg8jaJfaMvPoLjc"
)

@app.route('/infer', methods=['POST'])
def infer():
    image_data = base64.b64decode(request.json['image'])
    image = Image.open(io.BytesIO(image_data))
    image.save('temp.jpg')
    result = CLIENT.infer('temp.jpg', model_id="food-ingredient-recognition-51ngf/4")
    return result

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
