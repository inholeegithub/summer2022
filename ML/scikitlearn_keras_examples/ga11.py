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
    def __init__(self,startx0,ptbmp,pmut,pcross,xbounds,lverbo):
        self.position_i=[]         
        self.position_best_i=[]          
        self.obj_best_i=1e18
        self.obj_i=1e18
        self.dimensions=len(startx0)
        self.ptbmp=ptbmp+(random.random()-0.5)*3.5
        self.pmut=pmut+(random.random()-0.5)*0.1
        self.pcross=pcross+(random.random()-0.5)*0.1
        if self.pmut > 0.999 or self.pmut < 0.001: 
           self.pmut=random.random()
        if self.pcross > 0.999 or self.pcross < 0.001: 
           self.pcross=random.random()
        if lverbo:
           print(self.ptbmp,self.pmut,self.pcross)
        for j in range(self.dimensions):
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
    def update_mutationcrossover(self,x1vec,x2vec):
        if random.random() < 0.5:
           for j in range(self.dimensions):
               self.position_i[j]=x1vec[j]
               if random.random() < self.pmut:
                  self.position_i[j]=x1vec[j]+(random.random()-0.5)*self.ptbmp
        else:
           for j in range(self.dimensions):
               self.position_i[j]=x1vec[j]
               if random.random() < self.pcross:
                   self.position_i[j]=x2vec[j]
    def update_position(self,xbounds):
        for j in range(self.dimensions):
            if self.position_i[j] > xbounds[j][1]:
               self.position_i[j]=xbounds[j][0]+(xbounds[j][1]-xbounds[j][0])*random.random()
            if self.position_i[j] < xbounds[j][0]:
               self.position_i[j]=xbounds[j][0]+(xbounds[j][1]-xbounds[j][0])*random.random()
class GA():
    def __init__(self, objfunct, startx0, xbounds, ptbmp, pmut, pcross, nparticles, maxiter, verbose=False):
        obj_best_g=1e18
        position_best_g=[]                
        swarm=[]
        x1vec=[]                
        x2vec=[]                
        nsubpop=0
        for _ in range(nparticles):
            swarm.append(PARTICLE(startx0,ptbmp,pmut,pcross,xbounds,verbose))
        it=0
        while it < maxiter:
            if verbose: 
               print(f'iter: {it:>6d} best solution: {obj_best_g:16.8e}')
               if True and nparticles > 4:
                  print('lowest five')
                  abc=np.zeros(nparticles)
                  abcvec=np.zeros((nparticles,len(startx0)))
                  for i in range(nparticles):
                      abc[i]=swarm[i].obj_best_i
                      abcvec[i]=swarm[i].position_best_i
                  idx=abc.argsort()
                  abc=abc[idx]
                  abcvec=abcvec[idx,:]
                  print(abc[0],abc[1],abc[2],abc[3],abc[4])
                  print(abcvec[0,:])
                  print(abcvec[1,:])
                  print(abcvec[2,:])
                  print(abcvec[3,:])
                  print(abcvec[4,:])
            for i in range(nparticles):
                swarm[i].evaluate(objfunct)
                if swarm[i].obj_i < obj_best_g :
                   position_best_g=list(swarm[i].position_i)
                   obj_best_g=float(swarm[i].obj_i)
            for i in range(nparticles):
                i1=int(random.random()*nparticles) ; i2=int(random.random()*nparticles) ; k1=i2  
                if swarm[i1].obj_best_i < swarm[i2].obj_best_i : 
                   k1=i1
                for _ in range(nsubpop-1):
                    i1=int(random.random()*nparticles)
                    if swarm[i1].obj_best_i < swarm[k1].obj_best_i : 
                       k1=i1
                i1=int(random.random()*nparticles) ; i2=int(random.random()*nparticles) ; k2=i2  
                if swarm[i1].obj_best_i < swarm[i2].obj_best_i : 
                   k2=i1
                for _ in range(nsubpop-1):
                    i1=int(random.random()*nparticles)
                    if swarm[i1].obj_best_i < swarm[k2].obj_best_i : 
                       k2=i1
                x1vec=list(swarm[k1].position_best_i)
                x2vec=list(swarm[k2].position_best_i)
                swarm[i].update_mutationcrossover(x1vec,x2vec)
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
ptbmp=0.10
pmut=0.50
pcross=0.50
GA(functuser, startx0, xbounds, ptbmp, pmut, pcross, nparticles=50, maxiter=50000, verbose=True)

