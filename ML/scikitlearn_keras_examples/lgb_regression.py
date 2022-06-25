from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error
import lightgbm as lgb
from numpy import loadtxt
from sklearn.datasets import load_boston
from sklearn.model_selection import cross_val_score
boston = load_boston()
X, y = boston.data, boston.target
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)
#    create dataset for lightgbm
lgb_train = lgb.Dataset(X_train, y_train)
lgb_eval = lgb.Dataset(X_test, y_test, reference=lgb_train)
#    specify your configurations as a dict
params = {
    'boosting_type': 'gbdt', 'objective': 'regression', 'metric': {'l2', 'l1'},
    'num_leaves': 31, 'learning_rate': 0.05, 'feature_fraction': 0.9, 'bagging_fraction': 0.8,
    'bagging_freq': 5, 'verbose': 0
}
print('Starting training...')
#    train
gbm = lgb.train(params, lgb_train, num_boost_round=20, valid_sets=lgb_eval, early_stopping_rounds=5)
print('Saving model...')
#    save model to file
gbm.save_model('model.txt')
print('Starting predicting...')
print(gbm.best_iteration)
#    predict
y_pred = gbm.predict(X_test, num_iteration=gbm.best_iteration)
#    eval
print('The rmse of prediction is:', mean_squared_error(y_test, y_pred) ** 0.5)


