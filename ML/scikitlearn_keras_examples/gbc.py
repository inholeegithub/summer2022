import pandas as pd
import numpy as np
from sklearn.metrics import confusion_matrix
from sklearn.model_selection import train_test_split
from sklearn.ensemble import GradientBoostingClassifier

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
df.head()

X = df[["a","b","c"]]
Y = df[["y"]]
Xtrain, Xtest, ytrain, ytest = train_test_split(X, Y, random_state=0)

# build and train GradientBoostingClassifier model
gbc = GradientBoostingClassifier(n_estimators=100, learning_rate=0.5, max_depth=1)
gbc.fit(Xtrain, np.ravel(ytrain, order='C'))
ypred = gbc.predict(Xtest)
print(gbc.score(Xtest, ytest))
print(confusion_matrix(ytest, ypred)) 

# find optimal learning rate value
learning_rate =  [0.01, 0.05, 0.1, 0.5, 1];
for n in learning_rate:
 gbc = GradientBoostingClassifier(n_estimators=100, learning_rate=n, max_depth=1)
 gbc.fit(Xtrain, np.ravel(ytrain, order='C'))
 ypred = gbc.predict(Xtest)
 acc=gbc.score(Xtest, ytest) 
 print("Learning rate: ",n, "  Accuracy: ", acc)
 print("Confusion matrix:")
 print(confusion_matrix(ytest, ypred))

# find optimal number of estimators
estimators =  [10,50,100,200,500];
for e in estimators:
 gbc = GradientBoostingClassifier(n_estimators=e, learning_rate=1, max_depth=1)
 gbc.fit(Xtrain, np.ravel(ytrain, order='C'))
 ypred = gbc.predict(Xtest)
 acc=gbc.score(Xtest, ytest) 
 print("Number of estimators: ",e, "  Accuracy: ", acc)
 print("Confusion matrix:")
 print(confusion_matrix(ytest, ypred)) 
