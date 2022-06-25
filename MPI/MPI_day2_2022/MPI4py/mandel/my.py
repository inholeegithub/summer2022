#!/usr/bin/env python
from mandel import *
from mpi4py import MPI
comm= MPI.COMM_WORLD
size= comm.Get_size (); rank= comm.Get_rank ()
def GetLoad (h):
    # number of rows to compute here
    N = h // size + (h % size > rank)
    # first row to compute here
    start = comm.scan(N)-N
    return start, N
if __name__ == '__main__':
    x1, x2 = -2.0, 1.0; y1, y2 = -1.0, 1.0 
    w, h   = 1200, 800
    #w, h   = 1200, 800
    #w, h   = 4800, 3200
    maxit  = 127
    start, N = GetLoad (h)
    print 'rank= %d, N=%d, start=%d'%(rank,N,start)
    tic = MPI.Wtime ()
    C0= numpy.zeros ([N, w], dtype='i')
    dx=(x2-x1)/w 
    dy=(y2-y1)/h
    for i in range(N):
        y = y1 + (i+start) * dy
        for j in range(w):
            x = x1 + j * dx
            C0[i, j] = mandelbrot(x, y, maxit)
    # gather results at root
    if rank == 0: C = numpy.zeros ([h, w],dtype='i')
    else: C = None
    comm.Gatherv([C0, MPI.INT], [C,MPI.INT], root=0)
    #comm.Gatherv(C0, C, root=0)
    toc = MPI.Wtime ()
    if rank == 0: 
        print '%d time= %f secs' % (size, toc-tic)
        show (C)
