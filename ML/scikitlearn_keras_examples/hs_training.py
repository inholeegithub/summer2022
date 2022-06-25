# Regression  
# A training program with keras
# Written by In-Ho Lee, KRISS, May 10, (2019).
import time
from keras.models import Sequential
from keras.layers import Dense
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

X_train, X_validation, Y_train, Y_validation = train_test_split(X, Y, test_size=0.2)

model = Sequential()
model.add(Dense(30, input_dim=13, activation='relu'))
model.add(Dense(20, activation='relu'))
model.add(Dense(10, activation='relu'))
model.add(Dense(6, activation='relu'))
model.add(Dense(6, activation='relu'))
model.add(Dense(1))
model.summary()

model.compile(loss='mean_squared_error', optimizer='adam')
#model.fit(X_train, Y_train, epochs=200, batch_size=10)
model.fit(X_train, Y_train, validation_split=0.10, epochs=200, batch_size=10, verbose=2)

Y_prediction = model.predict(X_validation).flatten()
for i in range(10):
  real_price = Y_validation[i]
  predicted_price = Y_prediction[i]
  print('Real Price: {:.3f}, Predicted Price: {:.3f}'.format(real_price, predicted_price))


if True:
# serialize model to JSON
    model_json = model.to_json()
    with open("model.json", "w") as json_file:
        json_file.write(model_json)
# serialize weights to HDF5
    model.save_weights("model.h5")
    print("Saved model to disk")

print((time.clock()-start_time)/60./60.,'hours')
