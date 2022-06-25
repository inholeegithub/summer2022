import pickle
import scipy.optimize as optimize
from sklearn.model_selection import train_test_split
import numpy as np
from xgboost import XGBClassifier
from sklearn.model_selection import cross_val_score
from sklearn.metrics import accuracy_score
# plot feature importance using built-in function
from numpy import loadtxt
from xgboost import XGBClassifier
from xgboost import plot_importance
from matplotlib import pyplot
# load data
# split data into X and y
dataset = loadtxt('pima-indians-diabetes.csv', delimiter=",")
X = dataset[:,0:8]
y = dataset[:,8]
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=7)
# fit model no training data
model = XGBClassifier()
model.fit(X, y)
# plot feature importance
plot_importance(model)
pyplot.savefig("impor.eps")
#pyplot.show()

#pbounds = {
#    'learning_rate': (0.01, 1.0),
#    'n_estimators': (100, 1000),
#    'max_depth': (3,10),
#    'subsample': (1.0, 1.0),  # Change for big datasets
#    'colsample': (1.0, 1.0),  # Change for datasets with lots of features
#    'gamma': (0, 5)}
clf = XGBClassifier()
clf.fit(X,y)
test=np.mean(cross_val_score(clf, X, y, cv=3, scoring='roc_auc'))
print(test)
pickle.dump(clf, open("pima.pickle.dat", "wb"))
if True:
   test0=-1.
   for i in (0.01, 0.05, 1.0):
       for j in (100, 500, 1000):
           for k in (3, 5,  10):
               for l in (1.0, 1.0):
                   for m in (1.0, 1.0):
                       for n in (0, 2, 5):
                          clf = XGBClassifier( max_depth=k, learning_rate=i, n_estimators=j, subsample=l, colsample_bytree=m, gamma=n)
                          clf.fit(X,y)
                          test=np.mean(cross_val_score(clf, X, y, cv=3, scoring='roc_auc'))
                          if test0 < test:
                             print(i,j,k,l,m,n,test)
                             test0=test
                             pickle.dump(clf, open("pima.pickle.dat", "wb"))


# some time later...
# load model from file
loaded_model = pickle.load(open("pima.pickle.dat", "rb"))
# make predictions for test data
y_pred = loaded_model.predict(X)
predictions = [round(value) for value in y_pred]
# evaluate predictions
accuracy = accuracy_score(y, predictions)
print("Accuracy: %.2f%%" % (accuracy * 100.0))
