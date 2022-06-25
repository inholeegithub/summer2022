# Multi-class classification 
# A prediction program with keras
# Written by In-Ho Lee, KRISS, May 10, (2019).
from keras.models import model_from_json
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

# load json and create model
json_file = open('model.json', 'r')
loaded_model_json = json_file.read()
json_file.close()
loaded_model = model_from_json(loaded_model_json)
# load weights into new model
loaded_model.load_weights("model.h5")
print("Loaded model from disk")
# evaluate loaded model on test data
loaded_model.compile(loss='mean_squared_error', optimizer='adam')
predicted = loaded_model.predict(X)
print((time.clock()-start_time),'sec')
