import numpy as np
from scipy.optimize import minimize
def rastrigin(x):
#   Rastrigin
    total=10.*len(x)
    for j in range(len(x)):
        total+=x[j]**2-10.*np.cos(2.*np.pi*x[j])
    return total
def styblinski(x):
#   Styblinski-Tang
    total=0.
    for j in range(len(x)):
        total+=(x[j]**4-16.*x[j]**2+5.*x[j])/2.
    return total
def rosenbrock(x):
#  Rosenbrock
    return sum(100.0*(x[1:]-x[:-1]**2.0)**2.0 + (1-x[:-1])**2.0)
def rosenbrock_der(x):
    xm = x[1:-1]
    xm_m1 = x[:-2]
    xm_p1 = x[2:]
    der = np.zeros_like(x)
    der[1:-1] = 200*(xm-xm_m1**2) - 400*(xm_p1 - xm**2)*xm - 2*(1-xm)
    der[0] = -400*x[0]*(x[1]-x[0]**2) - 2*(1-x[0])
    der[-1] = 200*(x[-1]-x[-2]**2)
    return der

x0 = np.array([1.0, 2.0, 3.0, 4.0, 5.0])
x0 = np.array([1.1, 2.2, 3.0, 4.0, 5.0])

res = minimize(rosenbrock,x0,method='nelder-mead', options={'xtol':1e-8,'disp':True})
print('Nelder-Mead:',res.x)
print(res.fun)

x0 = np.array([1.0, 2.0, 3.0, 4.0, 5.0])
x0 = np.array([1.1, 2.2, 3.0, 4.0, 5.0])
res = minimize(rosenbrock, x0, method='BFGS', jac=rosenbrock_der, options={'disp': True})
print('BFGS:',res.x)
print(res.fun)

x0 = np.array([1.1, 2.2, 3.0, 4.0, 5.0])
x0 = np.array([0.0, 0.2, 0.0, 0.0, 0.0])
res = minimize(rastrigin,x0,method='nelder-mead', options={'xtol':1e-8,'disp':True})
print('Nelder-Mead:',res.x)
print(res.fun)
