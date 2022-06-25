from keras.models import Sequential
from keras.layers import Dense, SimpleRNN
from numpy import array, sqrt, array
from numpy.random import uniform
from numpy import hstack
import matplotlib.pyplot as plt
from sklearn.metrics import mean_squared_error


def create_data(n):
 x1 = array([i/100-uniform()*10 for i in range(n)]).reshape(n,1)
 x2 = array([i/100+uniform()*5 for i in range(n)]).reshape(n,1)
 x3 = array([i/200+uniform()-5 for i in range(n)]).reshape(n,1)

 y1= [x1[i]/2+x2[i]+x3[i]+uniform() for i in range(n)]
 y2= [x1[i]-x2[i]*2-x3[i]/2-5-uniform() for i in range(n)]
 X = hstack((x1, x2, x3))
 Y = hstack((y1, y2))
 return X, Y

N=420
n=400
x, y = create_data(N)
plt.plot(y)
plt.show()

xtrain, xtest = x[0:n,:], x[n:N,:]
ytrain, ytest = y[0:n,:], y[n:N,:]

print("xtrain:", xtrain.shape, "ytrian:", ytrain.shape)

def convertData(datax,datay,step):
 X, Y = [], []
 for i in range(len(datax)-step):
  d = i+step  
  X.append(datax[i:d,])
  Y.append(datay[d])

 return array(X), array(Y)

step=2
testx,testy = convertData(xtest,ytest, step)
trainx,trainy = convertData(xtrain,ytrain, step)
print("test-x:", testx.shape, "test-y:", testy.shape)
print("train-x:", trainx.shape, "trian-y:", trainy.shape)

trainx[1:2,]
#test[1:3,1:2]
in_dim = trainx.shape[1:3]
out_dim = trainy.shape[1]

model = Sequential()
model.add(SimpleRNN(units=100, input_shape=in_dim, activation="relu")) 
model.add(Dense(16, activation="relu")) 
model.add(Dense(out_dim))
model.compile(loss='mse', optimizer='adam')
model.summary()

model.fit(trainx,trainy, epochs=500, verbose=2)
trainScore = model.evaluate(trainx, trainy, verbose=0)
print(trainScore)

predtest= model.predict(testx)

rmse_y1 = sqrt(mean_squared_error(testy[:,0], predtest[:,0]))
rmse_y2 = sqrt(mean_squared_error(testy[:,1], predtest[:,1]))
print("RMSE y1: %.2f y2: %.2f" % (rmse_y1, rmse_y2))

x_ax = range(len(testx))
plt.plot(x_ax, testy[:,0],  label="y1-test",color="c")
plt.plot(x_ax, predtest[:,0], label="y1-pred")
plt.plot(x_ax, testy[:,1],  label="y2-test",color="m")
plt.plot(x_ax, predtest[:,1], label="y2-pred")
plt.legend()
plt.show()
