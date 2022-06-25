#!/usr/bin/env python

from mpi4py import MPI
comm = MPI.COMM_WORLD

if comm.rank == 0:
    data = {'a':7, 'b':3.14, 'c':'string'}
    comm.send (data, dest = 1, tag = 11)
else:
    data = comm.recv(source = 0, tag = 11)

print 'rank = %s, msg = %s' % (comm.rank, data)



