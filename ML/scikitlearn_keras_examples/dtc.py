import pandas as pd
import numpy as np
from sklearn.metrics import accuracy_score,confusion_matrix,\
 classification_report
from sklearn.model_selection import train_test_split
from sklearn.tree import DecisionTreeClassifier

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

df = CreateDataFrame(500)

X = df[["a","b","c"]]
Y = df[["y"]]
XTrain, XTest, YTrain, YTest = train_test_split(X, Y, random_state=0)

dtmodel = DecisionTreeClassifier().fit(XTrain,YTrain)
YPred = dtmodel.predict(XTest)

accuracy = accuracy_score(YTest,YPred)
report = classification_report(YPred, YTest)
cm = confusion_matrix(YTest, YPred)

print("Classification report:")
print("Accuracy: ", accuracy)
print(report)
print("Confusion matrix:")
print(cm)
