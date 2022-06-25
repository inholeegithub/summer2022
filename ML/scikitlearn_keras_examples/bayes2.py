from bayes_opt import BayesianOptimization
import numpy as np
import matplotlib.pyplot as plt
from matplotlib import gridspec
def target(x):
    return np.exp(-(x - 2)**2) + np.exp(-(x - 6)**2/10) + 1/ (x**2 + 1)

KAPPA = 5
x = np.linspace(-2, 10, 1000)
y = target(x)
plt.plot(x, y)
plt.show()
bo = BayesianOptimization(target, {'x': (-2, 10)})
gp_params = {'corr': 'cubic'}
bo.maximize(init_points=2, n_iter=14, acq='ei', xi=0.01)
