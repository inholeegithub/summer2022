import lightgbm as lgb
from bayes_opt import BayesianOptimization
from sklearn.model_selection import cross_val_score
from sklearn.model_selection import train_test_split
from sklearn.datasets import load_boston
from sklearn.metrics import accuracy_score,confusion_matrix
import numpy as np
def lgb_evaluate(numLeaves, maxDepth, scaleWeight, minChildWeight, subsample, colSam):
    reg=lgb.LGBMRegressor(num_leaves=31,
                          max_depth= 2,
                          scale_pos_weight= scaleWeight,
                          min_child_weight= minChildWeight,
                          subsample= 0.4,
                          colsample_bytree= 0.4,
                         learning_rate=0.05,
                         n_estimators=20)
#   scores = cross_val_score(reg, train_x, train_y, cv=5, scoring='roc_auc')
    scores = cross_val_score(reg, train_x, train_y, cv=5, scoring='neg_mean_squared_error')
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
boston = load_boston()
X, y = boston.data, boston.target
train_x, X_test, train_y, y_test = train_test_split(X, y, test_size=0.2)
bayesOpt(train_x, train_y)
