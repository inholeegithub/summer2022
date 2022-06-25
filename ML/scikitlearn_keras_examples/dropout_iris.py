from sklearn.datasets import load_boston
from sklearn.datasets import load_iris
from keras.models import Sequential
from keras.layers import Dense
from keras.layers import Dropout
import matplotlib.pyplot as plt

boston = load_boston()
x, y = boston.data, boston.target

dropouts = [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6]
mses=[]
for d in dropouts:
 model = Sequential()
 model.add(Dense(16, input_dim=13, kernel_initializer="normal", 
                        activation="relu"))
 model.add(Dense(8, activation="relu"))
 model.add(Dropout(d))
 model.add(Dense(1, kernel_initializer="normal"))
 model.compile(loss="mean_squared_error", optimizer="adam")
 model.fit(x, y, epochs=30, batch_size=16, verbose=2)
 l = model.evaluate(x, y)
 mses.append(l)

plt.plot(dropouts, mses)
plt.ylabel("MSE")
plt.xlabel("dropout value")
plt.show()

from sklearn.datasets import load_iris
from keras.models import Sequential
from keras.layers import Dense
from keras.layers import Dropout
import matplotlib.pyplot as plt

iris = load_iris()
x, y = iris.data, iris.target

accs=[]
for d in dropouts:
   model = Sequential()
   model.add(Dense(16, input_dim=4, activation="relu"))
   model.add(Dense(8, activation="relu"))
   model.add(Dropout(d))
   model.add(Dense(3, activation="softmax"))
   model.compile(loss="sparse_categorical_crossentropy", optimizer="adam", metrics=["accuracy"])
   model.fit(x, y, epochs=40, batch_size=16, verbose=2)
   acc = model.evaluate(x, y)
   accs.append(acc[1:2])

plt.plot(dropouts,accs)
plt.ylabel("Accuracy")
plt.xlabel("dropout value")
plt.show()

