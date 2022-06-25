#!/usr/bin/env python
from mpi4py import MPI
comm = MPI.COMM_WORLD

if comm.rank == 0:
    data = {'a':7, 'b':3.14, 'c':'string'}
    req  = comm.isend (data, dest = 1, tag = 11)
    data['a'] += 3
    data['d'] = 'new'
    req.Wait()
else:
    data = comm.recv(source = 0, tag = 11)

print 'rank = %s, msg = %s' % (comm.rank, data)



