import numpy
import tensorflow as tf
import random
import pandas
from keras.models import Sequential
from keras.optimizers import SGD, Adam
from keras.layers import Dense
from keras.wrappers.scikit_learn import KerasRegressor
from sklearn.model_selection import cross_val_score
from sklearn.model_selection import KFold
from sklearn.preprocessing import StandardScaler
from sklearn.pipeline import Pipeline

numpy.random.seed(123)
random.seed(1234)
tf.set_random_seed(210)

# load dataset
X=[]
Y=[]
with open("housing.csv", 'r') as afile:
     for line in afile:
         if(len(line.split()) == 14):  
             Y.append(float(line.split()[13]))
             vec=[]
             for j in range(13):
                 vec.append(float(line.split()[j]))
             X.append(vec)
X=numpy.asarray(X)
Y=numpy.asarray(Y)

# define baselin model
def baseline_model():
# Create model
    model = Sequential()
    model.add(Dense(13, input_dim=13, kernel_initializer='normal', activation='relu'))
    model.add(Dense(24, kernel_initializer='normal', activation='relu'))
    model.add(Dense(24, kernel_initializer='normal', activation='relu'))
    model.add(Dense(24, kernel_initializer='normal', activation='relu'))
    model.add(Dense(24, kernel_initializer='normal', activation='relu'))
    model.add(Dense(1, kernel_initializer='normal'))
    model.summary()
# Compile model
#   model.compile(loss='mean_squared_error', optimizer='adam', metrics=['accuracy'])
    model.compile(Adam(lr=0.1), loss='mean_squared_error', metrics=['accuracy'])
    return model

#evaluate model with standardized dataset
#estimator = KerasRegressor(build_fn=baseline_model, epochs=100, batch_size=5, verbose=2)
model=baseline_model()
#history = model.fit(X, Y, epochs=20, batch_size=5, verbose=1)
model.fit(X, Y, validation_split=0.1, epochs=20, batch_size=20, shuffle=True, verbose=2)
