import random
import math
import numpy as np
import matplotlib.pyplot as plt
from sklearn.svm import SVR 
from sklearn.metrics import mean_squared_error 

random.seed(123)
def getData(N):
 x,y =[],[]
 for i in range(N):  
  a = i/10+random.uniform(-1,1)
  yy =math.sin(a)+3+random.uniform(-1,1)
  x.append([a])
  y.append([yy])
  
 return np.array(x), np.array(y)

x,y=getData(200)
model = SVR()
print(model)

model.fit(x,y)
pred_y = model.predict(x)
for yo, yp in zip(y[1:15,:], pred_y[1:15]):
 print(yo,yp)

x_ax=range(200)
plt.scatter(x_ax, y, s=5, color="blue", label="original")
plt.plot(x_ax, pred_y, lw=1.5, color="red", label="predicted")
plt.legend()
plt.show()

score=model.score(x,y)
print(score)

mse =mean_squared_error(y, pred_y)
print("Mean Squared Error:",mse)

rmse = math.sqrt(mse)
print("Root Mean Squared Error:", rmse)
