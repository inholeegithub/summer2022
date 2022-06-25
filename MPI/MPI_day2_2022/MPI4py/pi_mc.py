#!/usr/bin/env python
from mpi4py import MPI
import math, random

comm = MPI.COMM_WORLD
nproc = comm.Get_size ()
rank  = comm.Get_rank ()

def compute_pi (nsamples):
    #random.seed (rank)
    count = 0
    for i in xrange(nsamples):
        # randomly choose a point in the box
        x = random.random()
        y = random.random()
        if x*x + y*y < 1.0:
            count += 1
    mypi = float(count)/nsamples
    print mypi*4
    pi   = (4.0/nproc)*comm.allreduce (mypi,op=MPI.SUM)
    return pi

if __name__ == '__main__':
    n  = 100000
    start = MPI.Wtime ()
    pi = compute_pi (n)
    end   = MPI.Wtime ()

    if rank == 0:
        err = abs (pi - math.pi)
        print 'pi is approximately %.16f, \
               error is %.16f' % (pi, err)
        print 'elapsed time = %.8f' % (end - start)


