import random
import math
import numpy as np
import matplotlib.pyplot as plt
from sklearn.metrics import mean_squared_error 
from sklearn.neighbors import KNeighborsRegressor

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
model = KNeighborsRegressor(n_neighbors=8)
print(model)

model.fit(x,y)
pred_y = model.predict(x)

score=model.score(x,y)
print(score)

mse =mean_squared_error(y, pred_y)
print("Mean Squared Error:",mse)

rmse = math.sqrt(mse)
print("Root Mean Squared Error:", rmse)

x_ax=range(200)
plt.scatter(x_ax, y, s=5, color="blue", label="original")
plt.plot(x_ax, pred_y, lw=1.5, color="red", label="predicted")
plt.legend()
plt.show()
