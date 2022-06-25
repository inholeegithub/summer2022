# Multi-class classification 
# A training program with keras
# Written by In-Ho Lee, KRISS, May 10, (2019).
from sklearn.model_selection import train_test_split
from keras.models import Sequential
from keras.layers import Dense
from keras.utils import np_utils
from sklearn.preprocessing import LabelEncoder
from sklearn.utils import shuffle
from sklearn.metrics import classification_report, confusion_matrix
import tensorflow as tf

import time
import random
import numpy as np
import pandas as pd

tf.set_random_seed(12)
np.random.seed(34)
random.seed(56)
random.seed(time.time())
start_time=time.clock()

df = pd.read_csv('iris.csv',names=["sepal_length", "sepal_width", "petal_length", "petal_width", "species"])
data_set = df.values
X = data_set[:, 0:4].astype(float)
obj_y = data_set[:, 4]

encoder = LabelEncoder()
encoder.fit(obj_y)
Y_encodered = encoder.transform(obj_y)
Y = np_utils.to_categorical(Y_encodered)

X, Y = shuffle(X,Y,random_state=0)
x_train, x_test, y_train, y_test= train_test_split(X,Y, test_size=0.2)

model = Sequential()
model.add(Dense(16, input_dim=4, activation='relu'))
for i in range(3):
    model.add(Dense(10, activation='relu'))
model.add(Dense(3, activation='softmax'))
model.summary()
model.compile(loss='categorical_crossentropy', optimizer='adam', metrics=['accuracy'])
model.fit(x_train, y_train, validation_split=0.10, epochs=100, batch_size=5, verbose=2)
scores=model.evaluate(x_test, y_test)
print('\nTest: Loss: {:.4f}'.format(scores[0]))
print('\nTest: Accuracy: {:.4f}'.format(scores[1]))
y_pred=model.predict(x_test)
y_pred=np.argmax(y_pred,axis=1)
y_test=np.argmax(y_test,axis=1)
print(classification_report(y_test,y_pred))
print(confusion_matrix(y_test,y_pred))
if True:
# serialize model to JSON
    model_json = model.to_json()
    with open("model.json", "w") as json_file:
        json_file.write(model_json)
# serialize weights to HDF5
    model.save_weights("model.h5")
    print("Saved model to disk")
print((time.clock()-start_time)/60./60.,'hours')
