from keras.preprocessing.text import Tokenizer
from keras.preprocessing.sequence import pad_sequences
from keras.models import Sequential
from keras import layers
from sklearn.model_selection import train_test_split
from sklearn.metrics import confusion_matrix
import pandas as pd

df = pd.read_csv('datasets/sentiments.csv')
df.columns = ["label","text"]
x = df['text'].values
y = df['label'].values

x_train, x_test, y_train, y_test = train_test_split(x, y, test_size=0.1, random_state=123)

tokenizer = Tokenizer(num_words=100)
tokenizer.fit_on_texts(x)
xtrain= tokenizer.texts_to_sequences(x_train)
xtest= tokenizer.texts_to_sequences(x_test)

vocab_size=len(tokenizer.word_index)+1

maxlen=10
xtrain=pad_sequences(xtrain,padding='post', maxlen=maxlen)
xtest=pad_sequences(xtest,padding='post', maxlen=maxlen) 
 
print(x_train[3])
print(xtrain[3])
 

embedding_dim=50
model=Sequential()
model.add(layers.Embedding(input_dim=vocab_size,
         output_dim=embedding_dim,
         input_length=maxlen))
model.add(layers.LSTM(units=50,return_sequences=True))
model.add(layers.LSTM(units=10))
model.add(layers.Dropout(0.5))
model.add(layers.Dense(8))
model.add(layers.Dense(1, activation="sigmoid"))
model.compile(optimizer="adam", loss="binary_crossentropy", 
     metrics=['accuracy'])
model.summary()
model.fit(xtrain,y_train, epochs=20, batch_size=16, verbose=False)

loss, acc = model.evaluate(xtrain, y_train, verbose=False)
print("Training Accuracy: ", acc.round(2))
loss, acc = model.evaluate(xtest, y_test, verbose=False)
print("Test Accuracy: ", acc.round(2))

ypred=model.predict(xtest)

ypred[ypred>0.5]=1 
ypred[ypred<=0.5]=0 
cm = confusion_matrix(y_test, ypred)
print(cm)

result=zip(x_test, y_test, ypred)
for i in result:
 print(i)

