# Regression  
# A prediction program with keras
# Written by In-Ho Lee, KRISS, May 10, (2019).
from keras.models import model_from_json
from sklearn.utils import shuffle
import time
from sklearn.model_selection import train_test_split
import pandas as pd
import numpy as np
import random
import tensorflow as tf

tf.set_random_seed(12)
np.random.seed(34)
random.seed(56)
random.seed(time.time())
start_time=time.clock()

df = pd.read_csv('housing.csv', delim_whitespace=True, header=None)
data_set = df.values
X = data_set[:, 0:13]
Y = data_set[:, 13]
X_train, X_test, Y_train, Y_test = train_test_split(X, Y, test_size=0.2)

if True:
# load json and create model
    json_file = open('model.json', 'r')
    loaded_model_json = json_file.read()
    json_file.close()
    loaded_model = model_from_json(loaded_model_json)
# load weights into new model
    loaded_model.load_weights("model.h5")
    print("Loaded model from disk")

loaded_model.compile(loss='mean_squared_error', optimizer='adam')
Y_prediction = loaded_model.predict(X_test).flatten()
for i in range(10):
  real_price = Y_test[i]
  predicted_price = Y_prediction[i]
  print('Real Price: {:.3f}, Predicted Price: {:.3f}'.format(real_price, predicted_price))
print((time.clock()-start_time)/60./60.,'hours')
