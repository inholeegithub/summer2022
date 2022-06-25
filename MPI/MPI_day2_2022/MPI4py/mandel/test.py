#!/usr/bin/env python
from mandel import *
from mpi4py import MPI
comm= MPI.COMM_WORLD
size= comm.Get_size (); rank= comm.Get_rank ()

def GetLoad (h):
    # number of rows to compute here
    N = h // size + (h % size > rank)
    # first row to compute here
    print N, rank, comm.scan(N)
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
