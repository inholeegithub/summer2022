#!/usr/bin/env python

from mpi4py import MPI
comm = MPI.COMM_WORLD

if comm.rank == 0:
    msg = 777
    comm.send (msg, dest = 1, tag = 55)
    msg = comm.recv(source = 1, tag = 77)
else:
    recvmsg = comm.recv(source = 0, tag = 55)
    msg = 'abc'
    comm.send (msg, dest = 0, tag = 77)

print 'rank = %s, msg = %s' % (comm.rank, msg)



