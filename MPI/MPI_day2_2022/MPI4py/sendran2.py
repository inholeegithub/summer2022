#!/usr/bin/env python
from mpi4py import MPI
import numpy as np
import random

comm = MPI.COMM_WORLD
random.seed (123+comm.rank)
data = np.arange (10, dtype = 'f')
random.shuffle (data)

if comm.rank == 0:
    target = 1
else:
    target = 0

req1 = comm.Isend (data, dest = target)
req2 = comm.Irecv (data, source = target)

MPI.Request.Waitall ([req1, req2])

print 'rank = %s, data = %s' % (comm.rank, data)
