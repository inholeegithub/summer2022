import random
import math
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from keras.models import Sequential
from keras.layers import Dense, LSTM, Dropout

random.seed(123)
# create dataset
def CreateTSData(N):
 columns = ['value']
 df = pd.DataFrame(columns=columns)
 for i in range(N):    
  v = i/100+math.sin(2*i)+random.uniform(-1,1)
  df.loc[i]= [v]
 return df

# convert into dataset matrix
def convertToMatrix(data, step):
 X, Y =[], []
 for i in range(len(data)-step):
  d=i+step  
  X.append(data[i:d,])
  Y.append(data[d,])
 return np.array(X), np.array(Y)

step=3
N = 240    # total number of rows
Tp = 200     # training part 
df = CreateTSData(N)
df.index=pd.DatetimeIndex(freq="d",start=pd.Timestamp('2000-01-01'),periods=N)
df.head()

values=df.values
train,test = values[0:Tp,:], values[Tp:N,:]

# add step elements into train and test
test = np.append(test,np.repeat(test[-1,],step))
train = np.append(train,np.repeat(train[-1,],step))
 
trainX,trainY =convertToMatrix(train,step)
testX,testY =convertToMatrix(test,step)
trainX = np.reshape(trainX, (trainX.shape[0], 1, trainX.shape[1]))
testX = np.reshape(testX, (testX.shape[0], 1, testX.shape[1]))

# Keras LSTM model 
model = Sequential()
model.add(LSTM(units=32, input_shape=(1,step), activation="relu"))
model.add(Dropout(0.2))
model.add(Dense(1))
model.compile(loss='mse', optimizer='adam')
model.summary()

model.fit(trainX,trainY, epochs=100, batch_size=32, verbose=2)
trainPredict = model.predict(trainX)
testPredict= model.predict(testX)
predicted=np.concatenate((trainPredict,testPredict),axis=0)

index = df.index.values
plt.plot(index,df)
plt.plot(index,predicted)
plt.axvline(df.index[Tp], c="r")
plt.show()
