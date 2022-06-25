#!/usr/bin/env python
from mpi4py import MPI
comm = MPI.COMM_WORLD

sendmsg = comm.rank**2

recvmsg1 = comm.gather (sendmsg, root=0)
print 'rank=%d, recvmsg1 = %s' % (comm.rank, recvmsg1)
comm.barrier ()
recvmsg2 = comm.allgather (sendmsg)
print 'rank=%d, recvmsg2 = %s' % (comm.rank, recvmsg2)
