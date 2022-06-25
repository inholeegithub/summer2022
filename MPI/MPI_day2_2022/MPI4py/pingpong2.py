#!/usr/bin/env python
from mpi4py import MPI
comm = MPI.COMM_WORLD

if comm.rank == 0:
    data = 123
    target = 1
else:
    data = 456
    target = 0

req = comm.isend (data, dest=target, tag = 77)
rdata = comm.recv (source=target, tag = 77)
req.Wait ()
print 'rank = %s, msg = %s' % (comm.rank, rdata)
