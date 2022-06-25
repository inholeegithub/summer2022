from sklearn.datasets import load_boston
from sklearn.model_selection import GridSearchCV
from sklearn.model_selection import train_test_split
from sklearn.ensemble import AdaBoostRegressor
from sklearn.metrics import mean_squared_error, make_scorer, r2_score
import matplotlib.pyplot as plt

boston = load_boston()
x, y = boston.data, boston.target
xtrain, xtest, ytrain, ytest=train_test_split(x, y, test_size=0.15)

abreg = AdaBoostRegressor()
params = {
 'n_estimators': [50, 100],
 'learning_rate' : [0.01, 0.05, 0.1, 0.5],
 'loss' : ['linear', 'square', 'exponential']
 }

score = make_scorer(mean_squared_error)

gridsearch = GridSearchCV(abreg, params, cv=5, return_train_score=True)
gridsearch.fit(xtrain, ytrain)
print(gridsearch.best_params_)

best_estim=gridsearch.best_estimator_
print(best_estim)

best_estim.fit(xtrain,ytrain)

ytr_pred=best_estim.predict(xtrain)
mse = mean_squared_error(ytr_pred,ytrain)
r2 = r2_score(ytr_pred,ytrain)
print("MSE: %.2f" % mse)
print("R2: %.2f" % r2)

ypred=best_estim.predict(xtest)
mse = mean_squared_error(ytest, ypred)
r2 = r2_score(ytest, ypred)
print("MSE: %.2f" % mse)
print("R2: %.2f" % r2)

x_ax = range(len(ytest))
plt.scatter(x_ax, ytest, s=5, color="blue", label="original")
plt.plot(x_ax, ypred, lw=0.8, color="red", label="predicted")
plt.legend()
plt.show()
