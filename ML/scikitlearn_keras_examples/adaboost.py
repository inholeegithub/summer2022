import pandas as pd
import numpy as np
from sklearn.preprocessing import LabelEncoder
from sklearn.metrics import confusion_matrix
from sklearn.model_selection import train_test_split
from sklearn.ensemble import AdaBoostClassifier
from sklearn.tree import DecisionTreeClassifier
from sklearn.naive_bayes import GaussianNB
from sklearn.ensemble import RandomForestClassifier
from sklearn import datasets

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
print(df.head())

X = df[["a","b","c"]]
Y = df[["y"]]

le=LabelEncoder()
y=le.fit_transform(Y)

print(Y.head())
print(y[0:5])

Xtrain, Xtest, ytrain, ytest = train_test_split(X, y, random_state=0)

dtc = DecisionTreeClassifier(criterion="entropy", max_depth=3)
ada_model=AdaBoostClassifier(base_estimator=dtc, n_estimators=100)
ada_model=ada_model.fit(Xtrain,ytrain)
ytest_pred=ada_model.predict(Xtest)
print(ada_model.score(Xtest, ytest))
print(confusion_matrix(ytest, ytest_pred)) 

iris= datasets.load_iris()
X = iris.data
Y = iris.target

le=LabelEncoder()
y=le.fit_transform(Y)

Xtrain, Xtest, ytrain, ytest = train_test_split(X, y, random_state=0)

gnb = GaussianNB()
rf = RandomForestClassifier(n_estimators=10)

base_methods=[rf, gnb, dtc]
for bm  in base_methods:
 print("Method: ", bm)
 ada_model=AdaBoostClassifier(base_estimator=bm)
 ada_model=ada_model.fit(Xtrain,ytrain)
 ytest_pred=ada_model.predict(Xtest)
 print(ada_model.score(Xtest, ytest))
 print(confusion_matrix(ytest, ytest_pred)) 
