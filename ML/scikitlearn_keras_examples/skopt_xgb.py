from xgboost import XGBClassifier
from sklearn.metrics import f1_score
import pandas as pd
from skopt import gp_minimize
from skopt.space import Real, Integer
import numpy as np
from sklearn.datasets import make_classification
from sklearn.model_selection import train_test_split
from functools import partial
# parameters for the data
np.random.seed(42) # important if you want reproducible results
n_samples = 10000 # number of rows
n_features = 30 # number of columns excluding the binary label
n_informative = 10 # number of features that are actually useful
n_classes = 2 # for binary classification
class_weights = 0.6 # fraction of zeros
train_ratio = 0.7 # to split the data in two parts 
# generate the data
X, y = make_classification(n_samples=n_samples, n_features=n_features, n_informative=n_informative, n_classes=n_classes, weights=[class_weights], random_state=42)
# split the data into train-test(straitified) and give names to columns
col_names = ['col_' + str(i + 1) for i in range(X.shape[1])]
X_train, X_test, y_train, y_test = train_test_split(X, y, stratify=y, test_size=1 - train_ratio, random_state=42)
target_col = "target"
df_train = pd.DataFrame(X_train, columns=col_names)
df_train.loc[:, target_col] = y_train
df_test = pd.DataFrame(X_test, columns=col_names)
df_test.loc[:, target_col] = y_test
# defining the space
space = [
    Real(0.6, 0.7, name="colsample_bylevel"),
    Real(0.6, 0.7, name="colsample_bytree"),
    Real(0.01, 1, name="gamma"),
    Real(0.0001, 1, name="learning_rate"),
    Real(0.1, 10, name="max_delta_step"),
    Integer(6, 15, name="max_depth"),
    Real(10, 500, name="min_child_weight"),
    Integer(10, 100, name="n_estimators"),
    Real(0.1, 100, name="reg_alpha"),
    Real(0.1, 100, name="reg_lambda"),
    Real(0.4, 0.7, name="subsample"),
]
# function to fit the model and return the performance of the model
def return_model_assessment(args, X_train, y_train, X_test):
    global models, train_scores, test_scores, curr_model_hyper_params
    params = {curr_model_hyper_params[i]: args[i] for i, j in enumerate(curr_model_hyper_params)}
    model = XGBClassifier(random_state=42, seed=42)
    model.set_params(**params)
    fitted_model = model.fit(X_train, y_train, sample_weight=None)
    models.append(fitted_model)
    train_predictions = model.predict(X_train)
    test_predictions = model.predict(X_test)
    train_score = f1_score(train_predictions, y_train)
    test_score = f1_score(test_predictions, y_test)
    train_scores.append(train_score)
    test_scores.append(test_score)
    return 1 - test_score
# collecting the fitted models and model performance
models = []
train_scores = []
test_scores = []
curr_model_hyper_params = ['colsample_bylevel', 'colsample_bytree', 'gamma', 'learning_rate', 'max_delta_step',
                        'max_depth', 'min_child_weight', 'n_estimators', 'reg_alpha', 'reg_lambda', 'subsample']
objective_function = partial(return_model_assessment, X_train=X_train, y_train=y_train, X_test=X_test)
# running the algorithm
n_calls = 50 # number of times you want to train your model
results = gp_minimize(objective_function, space, base_estimator=None, n_calls=50, n_random_starts=n_calls-1, random_state=42)


