from sklearn.naive_bayes import GaussianNB
import pandas as pd
import numpy as np
from sklearn.metrics import accuracy_score,confusion_matrix,classification_report
from sklearn.model_selection import train_test_split

def CreateDataFrame(N):
 columns = ['a','b','c','y']
 df = pd.DataFrame(columns=columns)
 for i in range(N):
  a = np.random.randint(10)
  b = np.random.randint(20)
  c = np.random.randint(5)
  y = "normal"
  if((a+b+c)>25):
   y="high"
  elif((a+b+c)<12):
   y= "low"

  df.loc[i]= [a, b, c, y]
 return df

df = CreateDataFrame(200)

X = df[["a","b","c"]]
Y = df[["y"]]
Xtrain, Xtest, ytrain, ytest = train_test_split(X, Y, random_state=0)

model = GaussianNB().fit(Xtrain, ytrain)  
ypred=model.predict(Xtest)
accuracy = accuracy_score(ytest,ypred)
report = classification_report(ypred, ytest)
cm = confusion_matrix(ytest, ypred)

print("Classification report:")
print("Accuracy: ",accuracy)
print(report)
print("Confusion matrix:")
print(cm)
