# Binary classification
# A prediction program with keras
# Written by In-Ho Lee, KRISS, May 10, (2019).
from keras.models import model_from_json
from sklearn.utils import shuffle
import time
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
