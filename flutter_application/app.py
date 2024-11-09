from fastapi import FastAPI, File, UploadFile
from PIL import Image
import numpy as np
import io
import tensorflow as tf
from starlette.middleware.cors import CORSMiddleware

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# interpreter = tf.lite.Interpreter(model_path="assets/model_unquant.tflite")
interpreter = tf.lite.Interpreter(model_path="assets/model_unquant_3_classes.tflite")
interpreter.allocate_tensors()

input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

""" with open("assets/labels.txt", "r") as f:
    labels = [line.strip().split(" ", 1)[-1] for line in f] """
    
with open("assets/labels_3_classes.txt", "r") as f:
    labels = [line.strip().split(" ", 1)[-1] for line in f]

@app.post("/predict/")
async def predict_image(file: UploadFile = File(...)):
    image_data = await file.read()
    image = Image.open(io.BytesIO(image_data)).convert("RGB").resize((224, 224))
    img_array = np.array(image, dtype=np.float32) / 255.0
    img_array = np.expand_dims(img_array, axis=0)

    interpreter.set_tensor(input_details[0]['index'], img_array)

    interpreter.invoke()

    output_data = interpreter.get_tensor(output_details[0]['index'])
    predicted_class = int(np.argmax(output_data))
    predicted_label = labels[predicted_class]

    return {"category": predicted_class, "label": predicted_label}
 

