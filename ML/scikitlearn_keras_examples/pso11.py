import random
import numpy as np
from scipy.optimize import minimize
def functuser(x):
    case=3

    if case == 1:
       total=0.
       for j in range(len(x)):
           total+=(x[j])**2
    if case == 2:
#    Rastrigin
       total=10.*len(x)
       for j in range(len(x)):
           total+=x[j]**2-10.*np.cos(2.*np.pi*x[j])
    if case == 3:
#   Rosenbrock
       xarray0=np.zeros(len(x))
       for j in range(len(x)):
          xarray0[j]=x[j]
       total=sum(100.0*(xarray0[1:]-xarray0[:-1]**2.0)**2.0 + (1-xarray0[:-1])**2.0)
    if case == 4:
#   Styblinski-Tang
       total=0.
       for j in range(len(x)):
           total+=(x[j]**4-16.*x[j]**2+5.*x[j])/2.

    return total
class PARTICLE:
    def __init__(self,startx0,ww,c1,c2,xbounds,lverbo):
        self.position_i=[]         
        self.velocity_i=[]          
        self.position_best_i=[]          
        self.obj_best_i=1e18
        self.obj_i=1e18
        self.dimensions=len(startx0)
        self.ww=ww+(random.random()-0.5)*0.2
        self.c1=c1+(random.random()-0.5)*0.2*1.
        self.c2=c2+(random.random()-0.5)*0.2*1.
        if lverbo:
           print(self.ww,self.c1,self.c2)
        for j in range(self.dimensions):
            self.velocity_i.append(random.uniform(-1,1))
            self.position_i.append(startx0[j]+(random.random()-0.5)*2.)
        if random.random() < 0.8:
           for j in range(self.dimensions):
               self.position_i[j]=xbounds[j][0]+(xbounds[j][1]-xbounds[j][0])*random.random()
        for j in range(self.dimensions):
            if self.position_i[j] > xbounds[j][1]:
               self.position_i[j]=xbounds[j][0]+(xbounds[j][1]-xbounds[j][0])*random.random()
            if self.position_i[j] < xbounds[j][0]:
               self.position_i[j]=xbounds[j][0]+(xbounds[j][1]-xbounds[j][0])*random.random()
        self.position_best_i=self.position_i.copy()
    def evaluate(self,objfunct):
#       self.obj_i=objfunct(self.position_i)
        xarray0=np.zeros(self.dimensions)
        for j in range(self.dimensions):
            xarray0[j]=self.position_i[j]
        res=minimize(objfunct,xarray0,method='nelder-mead',options={'xtol':1e-6,'disp':True})
        self.position_i=res.x.copy()
        self.obj_i=res.fun
        if self.obj_i < self.obj_best_i :
           self.position_best_i=self.position_i.copy()
           self.obj_best_i=self.obj_i
    def update_velocity(self,position_best_g):
        for j in range(self.dimensions):
            vc=self.c1*(self.position_best_i[j]-self.position_i[j])*random.random()
            vs=self.c2*(position_best_g[j]-self.position_i[j])*random.random()
            self.velocity_i[j]=self.ww*self.velocity_i[j]+vc+vs
    def update_position(self,xbounds):
        for j in range(self.dimensions):
            self.position_i[j]=self.position_i[j]+self.velocity_i[j]
            if self.position_i[j] > xbounds[j][1]:
               self.position_i[j]=xbounds[j][0]+(xbounds[j][1]-xbounds[j][0])*random.random()
            if self.position_i[j] < xbounds[j][0]:
               self.position_i[j]=xbounds[j][0]+(xbounds[j][1]-xbounds[j][0])*random.random()
class PSO():
    def __init__(self, objfunct, startx0, xbounds, ww, c1, c2, nparticles, maxiter, verbose=False):
        obj_best_g=1e18
        position_best_g=[]                
        swarm=[]
        for _ in range(nparticles):
            swarm.append(PARTICLE(startx0,ww,c1,c2,xbounds,verbose))
        it=0
        while it < maxiter:
            if verbose: 
               print(f'iter: {it:>6d} best solution: {obj_best_g:16.8e}')
            for i in range(nparticles):
                swarm[i].evaluate(objfunct)
                if swarm[i].obj_i < obj_best_g :
                   position_best_g=list(swarm[i].position_i)
                   obj_best_g=float(swarm[i].obj_i)
            for i in range(nparticles):
                swarm[i].update_velocity(position_best_g)
                swarm[i].update_position(xbounds)
            it+=1
        print('\nfinal solution:')
        print(f'   > {position_best_g}')
        print(f'   > {obj_best_g}\n')
        if True:
           abc=np.zeros(nparticles)
           abcvec=np.zeros((nparticles,len(startx0)))
           for i in range(nparticles):
               abc[i]=swarm[i].obj_best_i
               abcvec[i]=swarm[i].position_best_i
           idx=abc.argsort()
           abc=abc[idx]
           abcvec=abcvec[idx,:]
           for i in range(nparticles):
               print(abc[i])
               print(abcvec[i,:])

startx0=[]
xbounds=[]
for j in range(10):
    startx0.append(0.)
for j in range(len(startx0)):
    xbounds.append((-20., 20.))
ww=0.5
c1=1.0
c2=2.0
PSO(functuser, startx0, xbounds, ww, c1, c2, nparticles=50, maxiter=50000, verbose=True)
