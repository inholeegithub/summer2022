#   http://krasserm.github.io/2018/03/21/bayesian-optimization/
#   Modified by In-Ho Lee, KRISS, February 14, 2020.
import numpy as np
from scipy.stats import norm
def expected_improvement(X,X_sample,Y_sample,gpr,xi=0.01):
    '''
    Computes the EI at points X based on existing samples X_sample
    and Y_sample using a Gaussian process surrogate model.
    Args:
        X: Points at which EI shall be computed (m x d).
        X_sample: Sample locations (n x d).
        Y_sample: Sample values (n x 1).
        gpr: A GaussianProcessRegressor fitted to samples.
        xi: Exploitation-exploration trade-off parameter.
    Returns:
        Expected improvements at points X.
    '''
    mu, sigma=gpr.predict(X,return_std=True)
    sigma1=np.zeros_like(sigma)
    sigma1[:]=sigma1[:]+1e-16
    sigma=sigma+sigma1
    mu_sample=gpr.predict(X_sample)
    sigma = sigma.reshape(-1, 1)
#   Needed for noise-based model, otherwise use np.max(Y_sample). See also section 2.4 in [...]
    mu_sample_opt = np.max(mu_sample)
    with np.errstate(divide='warn'):
        imp = mu - mu_sample_opt - xi
        Z = imp / sigma
        ei = imp * norm.cdf(Z) + sigma * norm.pdf(Z)
        ei[sigma == 0.0] = 0.0
    return ei
from scipy.optimize import minimize
def propose_location(acquisition,X_sample,Y_sample,gpr,bounds, n_restarts=25):
    '''
    Proposes the next sampling point by optimizing the acquisition function.
    Args:
        acquisition: Acquisition function.
        X_sample: Sample locations (n x d).
        Y_sample: Sample values (n x 1).
        gpr: A GaussianProcessRegressor fitted to samples.
    Returns:
        Location of the acquisition function maximum.
    '''
    ndim = X_sample.shape[1]
    min_val = 1
    min_x = None
    def min_obj(X):
#   Minimization objective is the negative acquisition function
        return -acquisition(X.reshape(-1,ndim),X_sample,Y_sample,gpr)
#   Find the best optimum by starting from n_restart different random points.
    for x0 in np.random.uniform(bounds[:, 0],bounds[:, 1],size=(n_restarts,ndim)):
        res = minimize(min_obj,x0=x0,bounds=bounds,method='L-BFGS-B')
        if res.fun < min_val:
            min_val = res.fun
            min_x = res.x           
    return min_x.reshape(-1,ndim)


import time
ndim=4
ninit=ndim*2
bounds=np.zeros((ndim,2))
for i in range(ndim):
    for j in range(2):
        if j == 0 :
           bounds[i,j]= -1.00+float(i)
           bounds[i,j]= -3.00
#          bounds[i,j]= -5.12
        if j == 1 :
           bounds[i,j]= 1.00+float(i)
           bounds[i,j]= 3.00
#          bounds[i,j]= 5.12
noise = 1e-8
def f(X,noise=noise):
    y=np.zeros((X.shape[0],))
    ndim = X.shape[1]
    if False:
        for i in range(X.shape[0]):
            y[i]=-10.*ndim
            for j in range(X.shape[1]):
                y[i]=y[i]-X[i,j]**2+10.*np.cos(2.*(np.pi)*X[i,j])
    if True:
        for i in range(X.shape[0]):
            for j in range(X.shape[1]):
                y[i]=y[i]+np.sin(X[i,j])
    if False:
        for i in range(X.shape[0]):
            for j in range(X.shape[1]):
                y[i]=y[i]-(X[i,j]-float(j))**2
    return y
X_init=np.zeros((ninit,ndim))
for i in range(ninit):
    for j in range(ndim):
        X_init[i,j]=bounds[j,0]+(bounds[j,1]-bounds[j,0])*np.random.random()
Y_init=f(X_init)
for i in range(ninit):
    print(X_init[i,:],Y_init[i])
best_obj=Y_init[0]
best_sol=X_init[0,:]
for i in range(ninit):
    if best_obj < Y_init[i]:
       best_obj=Y_init[i]
       best_sol=X_init[i,:]
       print(best_obj)
from sklearn.gaussian_process import GaussianProcessRegressor
from sklearn.gaussian_process.kernels import ConstantKernel,Matern
#   Gaussian process with Matern kernel as surrogate model
m52=ConstantKernel(1.0) * Matern(length_scale=1.0, nu=2.5)
gpr=GaussianProcessRegressor(kernel=m52, alpha=noise**2)
X_sample=X_init
Y_sample=Y_init
n_iter =ndim*20
for i in range(n_iter):
    starty=time.time()
    gpr.fit(X_sample,Y_sample)
    starty=time.time()-starty
#   Obtain next sampling point from the acquisition function (expected_improvement)
    startz=time.time()
    X_next=propose_location(expected_improvement,X_sample,Y_sample,gpr,bounds,n_restarts=ndim*30)
    startz=time.time()-startz
    print(f"{starty: .3f} {startz: .3f} sec, fit, propose {X_sample.shape[0]}")
    Y_next=f(X_next,noise)
#   print(X_next.ravel(),Y_next)
    if best_obj < Y_next:
       best_obj=Y_next
       best_sol=X_next
       print(X_next.ravel(),Y_next)
    X_sample=np.vstack((X_sample,X_next))
    Y_sample=np.hstack((Y_sample,Y_next))
print(best_sol.ravel(),best_obj)
import matplotlib.pyplot as plt
plt.rc('font', size=14)          # controls default text sizes
#plt.rc('figure', titlesize=14)  # fontsize of the figure title
#plt.rc('axes', titlesize=14)     # fontsize of the axes title
#plt.rc('axes', labelsize=18)    # fontsize of the x and y labels
#plt.rc('xtick', labelsize=16)    # fontsize of the tick labels
#plt.rc('ytick', labelsize=16)    # fontsize of the tick labels
#plt.rc('legend', fontsize=14)    # legend fontsize
x=np.zeros((Y_sample.shape[0],))
for i in range(Y_sample.shape[0]):
    x[i]=i+1
fig=plt.figure()
plt.plot(x[:ninit], Y_sample[:ninit], marker='+', color='red', linewidth=2, markersize=8, label='Random')
plt.plot(x[ninit:], Y_sample[ninit:], marker='o', color='blue', linewidth=2, markersize=8, label='Gaussian Process')
plt.xlabel('Samples', fontsize=20)
plt.ylabel('Objective function', fontsize=20)
plt.legend()
fig.tight_layout()
fig.savefig('gpsamples.eps')
#plt.show()
