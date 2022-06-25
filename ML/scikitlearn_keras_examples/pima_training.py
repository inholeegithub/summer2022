# Binary classification
# A training program with keras
# Written by In-Ho Lee, KRISS, May 10, (2019).
import time
from sklearn.model_selection import train_test_split
from sklearn.utils import shuffle
from keras.models import Sequential
from keras.layers import Dense
import numpy as np
import random
import tensorflow as tf

tf.set_random_seed(12)
np.random.seed(34)
random.seed(56)
random.seed(time.time())
start_time=time.clock()

# fix random seed for reproducibility
#np.random.seed(7)
# load pima indians dataset
dataset = np.loadtxt("C:/testAI/scikitlearn_keras_examples/pima-indians-diabetes.csv", delimiter=",")
# split into input (X) and output (Y) variables
X = dataset[:,0:8]
Y = dataset[:,8]
X, Y = shuffle(X,Y,random_state=0)
x_train, x_test, y_train, y_test= train_test_split(X,Y, test_size=0.2)
# create model
model = Sequential()
model.add(Dense(12, input_dim=8, init='normal', activation='relu'))
for i in range(4):
    model.add(Dense(8, init='normal', activation='relu'))
model.add(Dense(1, init='normal', activation='sigmoid'))
model.summary()
# Compile model
model.compile(loss='binary_crossentropy', optimizer='adam', metrics=['accuracy'])
# Fit the model
model.fit(x_train, y_train, validation_split=0.10, epochs=100, batch_size=5, verbose=2)
# evaluate the model
scores = model.evaluate(x_test, y_test)
print("\n%s: %.2f%%" % (model.metrics_names[1], scores[1]*100))
predictions=model.predict(x_test)
rounded=[round(x[0]) for x in predictions]
print(rounded)

if True:
# serialize model to JSON
    model_json = model.to_json()
    with open("model.json", "w") as json_file:
        json_file.write(model_json)
# serialize weights to HDF5
    model.save_weights("model.h5")
    print("Saved model to disk")

print((time.clock()-start_time)/60./60.,'hours')
