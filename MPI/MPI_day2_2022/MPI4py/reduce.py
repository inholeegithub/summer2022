#!/usr/bin/env python

from mpi4py import MPI
comm = MPI.COMM_WORLD

sendmsg = [0] *comm.size
sendmsg[comm.rank] = comm.rank

recvmsg1 = comm.reduce (sendmsg, op=MPI.SUM, root=0)
#recvmsg2 = comm.allreduce (sendmsg, op=MPI.SUM, root=0)

print 'rank=%d, recvmsg1= %s' % (comm.rank, recvmsg1)
#print 'rank=%d, recvmsg2= %s' % (comm.rank, recvmsg1)
