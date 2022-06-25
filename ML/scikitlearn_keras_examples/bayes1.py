from bayes_opt import BayesianOptimization
import numpy as np
def target(x):
    return np.exp(-(x-3)**2) + np.exp(-(3*x-2)**2) + 1/(x**2+1)
bayes_optimizer = BayesianOptimization(target, {'x': (-2, 6)}, random_state=0)
bayes_optimizer.maximize(init_points=2, n_iter=14, acq='ei', xi=0.01)
