from keras.utils import to_categorical
from keras.models import Sequential
from keras.layers import Conv2D, MaxPooling2D 
from keras.layers import Dense, Flatten, Dropout
from keras.layers import BatchNormalization
from keras.datasets import mnist
from keras.optimizers import RMSprop
import matplotlib.pyplot as plt


(trainX, trainY), (testX, testY) = mnist.load_data()
print(trainX.shape)

trainX = trainX[1:8001,]
trainY = trainY[1:8001,]
testX = testX[1:201,]
testY = testY[1:201,]

trainX = trainX.reshape((trainX.shape[0], 28,28,1))
testX = testX.reshape((testX.shape[0], 28,28,1))
trainY = to_categorical(trainY)
testY = to_categorical(testY)

def build_model(trainX, trainY, testX, testY, bn=False):
 model= Sequential()
 model.add(Conv2D(32, (3,3), activation="relu", input_shape=(28,28,1)))
 model.add(Conv2D(64, (3,3), activation="relu"))
 if(bn):
  model.add(BatchNormalization())
 model.add(MaxPooling2D((2,2)))
 model.add(Dropout(0.2))
 model.add(Flatten())
 model.add(Dense(128, activation="relu"))
 model.add(Dropout(0.2))
 if(bn):
  model.add(BatchNormalization())
 model.add(Dense(10, activation="softmax"))
 model.compile(loss="categorical_crossentropy", optimizer=RMSprop(),
     metrics=["accuracy"]) 
 print(model.summary())
 history = model.fit(trainX, trainY, epochs=30, batch_size=16, 
       validation_data=(testX, testY), verbose=0)
 _, acc = model.evaluate(testX, testY, verbose=0)
 if(bn):
  print("Accuracy with BN: ", acc)
 else:
  print("Accuracy without BN: ", acc)
 return history

model_hist = build_model(trainX, trainY, testX, testY)
model_hist_bn = build_model(trainX, trainY, testX, testY,bn=True)


f = plt.figure()
f.add_subplot(1,2,1)
plt.title("Train without Batch Normalization")
plt.plot(model_hist.history['acc'], label='train')
plt.plot(model_hist.history['val_acc'], label="test")
plt.legend()
f.add_subplot(1,2,2)
plt.title("Train with Batch Normalization")
plt.plot(model_hist_bn.history['acc'], label='train')
plt.plot(model_hist_bn.history['val_acc'], label="test")
plt.legend()
plt.show()
