import pandas as pd
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.model_selection import train_test_split
from sklearn.naive_bayes import GaussianNB
from sklearn.metrics import accuracy_score,confusion_matrix

df = pd.read_csv('sentiments.csv')
df.columns = ["label","text"]
x = df['text'].values
y = df['label'].values

x_train, x_test, y_train, y_test = \
 train_test_split(x, y, test_size=0.12, random_state=121)

vectorizer = CountVectorizer()
vectorizer.fit(x_train)
Xtrain = vectorizer.transform(x_train)
Xtest = vectorizer.transform(x_test)
print(Xtrain.shape)
print(Xtest.shape)

model = GaussianNB().fit(Xtrain.toarray(), y_train)

ypred = model.predict(Xtest.toarray())
accuracy = accuracy_score(y_test, ypred)
cm = confusion_matrix(y_test, ypred)

print("Accuracy: ", accuracy)
print("Confusion matrix:")
print(cm)

result=zip(x_test, y_test, ypred)
for i in result:
 print(i)
