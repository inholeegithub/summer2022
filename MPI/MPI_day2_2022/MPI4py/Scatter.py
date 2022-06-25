#!/usr/bin/env python
from mpi4py import MPI
comm = MPI.COMM_WORLD

if comm.rank == 0:
    sendmsg = [i**2 for i in range(comm.size)]
else:
    sendmsg = None

recvmsg = comm.scatter (sendmsg, root = 0)
print 'rank = %d, recvmsg = %s' % (comm.rank, recvmsg)


