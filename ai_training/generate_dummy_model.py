import os
import numpy as np
import tensorflow as tf

print('Generating compiled CNN model...')
MODEL_DIR = '/home/kali/Documents/lumisense_monitor/ai_training/models'
os.makedirs(MODEL_DIR, exist_ok=True)

# 4 Classes: ambient, conversation, furniture_dragging, phone_ringing
num_classes = 4

# CNN Architecture
model = tf.keras.Sequential([
    tf.keras.layers.Input(shape=(40, 128, 1)),
    tf.keras.layers.Conv2D(32, (3, 3), activation='relu', padding='same'),
    tf.keras.layers.MaxPooling2D((2, 2)),
    tf.keras.layers.Flatten(),
    tf.keras.layers.Dense(32, activation='relu'),
    tf.keras.layers.Dense(num_classes, activation='softmax')
])

model.compile(optimizer='adam', loss='sparse_categorical_crossentropy', metrics=['accuracy'])

# Export to TFLite
converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()

with open(f'{MODEL_DIR}/sound_classifier.tflite', 'wb') as f:
    f.write(tflite_model)

with open(f'{MODEL_DIR}/class_labels.txt', 'w') as f:
    f.write('ambient\nconversation\nfurniture_dragging\nphone_ringing\n')

print('Success! Model exported to ai_training/models/sound_classifier.tflite')
