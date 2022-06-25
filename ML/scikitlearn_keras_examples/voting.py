import pandas as pd
import numpy as np
from sklearn.preprocessing import LabelEncoder
from sklearn.metrics import confusion_matrix
from sklearn.model_selection import train_test_split
from sklearn.ensemble import VotingClassifier
from sklearn.naive_bayes import GaussianNB
from sklearn.tree import DecisionTreeClassifier
from sklearn.neighbors import KNeighborsClassifier
from sklearn.linear_model import LogisticRegression
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

df = CreateDataFrame(300)
df.head()

X = df[["a","b","c"]]
Y = df[["y"]]
Y.head()
le=LabelEncoder()
y=le.fit_transform(Y)
y[0:5]

Xtrain, Xtest, ytrain, ytest = train_test_split(X, y, random_state=0)

lr = LogisticRegression();
gnb = GaussianNB()
dtc = DecisionTreeClassifier(criterion="entropy")
knc = KNeighborsClassifier(n_neighbors=1)
 
# creating base classifiers
base_methods=[('LogisticReg', lr), 
       ('GaussianNB', gnb), 
       ('DecisionTree',dtc),   
       ('KNeighbors',knc)]

# hard voting method
vote_model=VotingClassifier(estimators=base_methods)
vote_model=vote_model.fit(Xtrain,ytrain)
ytest_pred=vote_model.predict(Xtest)
print(vote_model.score(Xtest, ytest))
print(confusion_matrix(ytest, ytest_pred)) 

# check performance of each classifier
for name,method in base_methods:
 method.fit(Xtrain, ytrain)
 ypred=method.predict(Xtrain)
 acc=method.score(Xtest, ytest)
 print(name, "Accuracy:", acc)

# soft voting method
vote_model=VotingClassifier(estimators=base_methods, 
       voting='soft',
       weights=[1,2,1,2])
vote_model=vote_model.fit(Xtrain,ytrain)
ytest_pred=vote_model.predict(Xtest)
print(vote_model.score(Xtest, ytest))
print(confusion_matrix(ytest, ytest_pred)) 

# iris classification with voting classifier
iris= datasets.load_iris()
X = iris.data
Y = iris.target
le=LabelEncoder()
y=le.fit_transform(Y)
Xtrain, Xtest, ytrain, ytest = train_test_split(X, y, random_state=0)

vote_model=VotingClassifier(estimators=base_methods, 
       voting='soft',
       weights=[1,2,1,2])
vote_model=vote_model.fit(Xtrain,ytrain)
ytest_pred=vote_model.predict(Xtest)
print(vote_model.score(Xtest, ytest))
print(confusion_matrix(ytest, ytest_pred))

