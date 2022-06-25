#!/usr/bin/env python
from mpi4py import MPI
import numpy as np
comm = MPI.COMM_WORLD
rank = comm.Get_rank()

comm.Barrier()
start = MPI.Wtime()

A = np.array([[1.,2.],[3.,4.],[5.,6.],[7.,8.]])

a = np.zeros(2)
comm.Scatter(A, a, root = 0)
comm.Barrier()
end = MPI.Wtime()
print "process", rank, "has", a, ' time=',end-start

