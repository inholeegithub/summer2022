import numpy as np
from numpy import loadtxt
from xgboost import XGBClassifier
from bayes_opt import BayesianOptimization
from sklearn.model_selection import cross_val_score
pbounds = {
    'learning_rate': (0.01, 1.0),
    'n_estimators': (100, 1000),
    'max_depth': (3,10),
    'subsample': (1.0, 1.0),  # Change for big datasets
    'colsample': (1.0, 1.0),  # Change for datasets with lots of features
    'gamma': (0, 5)}
def xgboost_hyper_param(learning_rate, n_estimators, max_depth, subsample, colsample, gamma):
    max_depth = int(max_depth)
    n_estimators = int(n_estimators)
    clf = XGBClassifier( max_depth=max_depth, learning_rate=learning_rate, n_estimators=n_estimators, 
         subsample=subsample, colsample=colsample, gamma=gamma)
    return np.mean(cross_val_score(clf, X, y, cv=3, scoring='roc_auc'))
def boexe(X,y):
    optimizer = BayesianOptimization( f=xgboost_hyper_param, pbounds=pbounds, random_state=1)
    optimizer.maximize(init_points=3, n_iter=50, acq='ei', xi=0.01)
dataset = loadtxt('pima-indians-diabetes.csv', delimiter=",")
X = dataset[:,0:8]
y = dataset[:,8]
boexe(X,y)
