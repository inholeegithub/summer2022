import scipy.optimize as optimize
from bayes_opt import BayesianOptimization

fun = lambda x: (x[0] - 1)**2 + (x[1] - 2.5)**2
res = optimize.minimize(fun, (2, 0), method='TNC', tol=1e-10)
print(res.x)
print(res.fun)

def fun(x1,x2):
    return -((x1-1)**2+ (x2-2.5)**2)
BO = BayesianOptimization(fun, {'x1': (0., 2.), 'x2': (0., 3.) }, verbose=2)
BO.maximize(init_points=2, n_iter=20)
for i, res in enumerate(BO.res):
    print("Iteration {}: \n\t{}".format(i, res))
print(BO.max)
