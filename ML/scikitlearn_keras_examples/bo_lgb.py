import lightgbm as lgb
from bayes_opt import BayesianOptimization
from sklearn.model_selection import cross_val_score
from sklearn.model_selection import train_test_split
from numpy import loadtxt
from sklearn.metrics import accuracy_score,confusion_matrix
import numpy as np
def lgb_evaluate(numLeaves, maxDepth, scaleWeight, minChildWeight, subsample, colSam):
    clf = lgb.LGBMClassifier(
        objective = 'binary',
        metric= 'auc',
        reg_alpha= 0,
        reg_lambda= 2,
#       bagging_fraction= 0.999,
        min_split_gain= 0,
        min_child_samples= 10,
        subsample_freq= 3,
#       subsample_for_bin= 50000,
#       n_estimators= 9999999,
        n_estimators= 99,
        num_leaves= int(numLeaves),
        max_depth= int(maxDepth),
        scale_pos_weight= scaleWeight,
        min_child_weight= minChildWeight,
        subsample= subsample,
        colsample_bytree= colSam,
        verbose =-1)
    scores = cross_val_score(clf, train_x, train_y, cv=5, scoring='roc_auc')
    return np.mean(scores)
def bayesOpt(train_x, train_y):
    lgbBO = BayesianOptimization(lgb_evaluate, {                                                
                                                'numLeaves':  (5, 80),
                                                'maxDepth': (2, 63),
                                                'scaleWeight': (1, 10000),
                                                'minChildWeight': (0.01, 70),
                                                'subsample': (0.4, 1),                                                
                                                'colSam': (0.4, 1)
                                            })
    lgbBO.maximize(init_points=5, n_iter=50)
    print(lgbBO.res)
dataset = loadtxt('pima-indians-diabetes.csv', delimiter=",")
X = dataset[:,0:8]
y = dataset[:,8]
train_x, X_test, train_y, y_test = train_test_split(X, y, test_size=0.2)
bayesOpt(train_x, train_y)
