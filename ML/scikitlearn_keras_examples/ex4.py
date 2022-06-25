from sklearn import linear_model
X= [[0., 0.], [1., 1.], [2., 2.], [3., 3.]]
Y= [0., 1., 2., 3.]
reg = linear_model.BayesianRidge()
reg.fit(X, Y)
print(reg.predict([[1, 0.]]))
print(reg.coef_)
