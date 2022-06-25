#!/usr/bin/env python
from mpi4py import MPI
import math
comm = MPI.COMM_WORLD
nproc = comm.Get_size ()
rank  = comm.Get_rank ()

def compute_pi (n, start=0, step=1):
    h = 1.0 / n
    s = 0.0
    for i in xrange(start, n, step):
        x = h * (i + 0.5)
        s += 4.0 / (1.0 + x**2)
    return s*h

if __name__ == '__main__':
    n    = 10000000
    start= MPI.Wtime ()
    mypi=compute_pi (n, rank, nproc)
    pi  =comm.reduce (mypi,op=MPI.SUM,root=0)
    end   = MPI.Wtime ()
    if rank == 0:
        err = abs (pi - math.pi)
        print 'pi is approximately %.16f, \
               error is %.16f' % (pi, err)
        print 'elapsed time=%.8f' %(end-start)

