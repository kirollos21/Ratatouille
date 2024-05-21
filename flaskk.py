from flask import Flask, request, jsonify
from flask_cors import CORS
import requests
import base64

app = Flask(__name__)
CORS(app)

API_URL = "https://detect.roboflow.com"
API_KEY = "2dS40Rg8jaJfaMvPoLjc"

@app.route('/infer', methods=['POST'])
def infer_image():
    try:
        if 'image' not in request.files:
            return jsonify({'error': 'No image uploaded'}), 400

        image = request.files['image']
        print('Image received:', image.filename)
        image_bytes = image.read()
        base64_image = base64.b64encode(image_bytes).decode('utf-8')

        request_body = {
            "image": base64_image,
            "model_id": "food-ingredient-recognition-51ngf/4"
        }

        response = requests.post(
            f'{API_URL}/infer',
            headers={
                'Content-Type': 'application/json',
                'Authorization': f'Bearer {API_KEY}',
            },
            json=request_body
        )

        print('Response from Roboflow:', response.status_code, response.json())

        if response.status_code == 200:
            return jsonify(response.json())
        else:
            return jsonify({'error': f'Failed to infer image: {response.status_code}'}), response.status_code

    except Exception as e:
        print('Error:', e)
        return jsonify({'error': f'Error during image inference: {str(e)}'}), 500

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)