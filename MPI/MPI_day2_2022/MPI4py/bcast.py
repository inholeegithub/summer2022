#!/usr/bin/env python

from mpi4py import MPI
comm = MPI.COMM_WORLD

if comm.rank == 0:
    sendmsg = (1, "abc", [1.0, 2+3j], {'A':'ALA','R':'ARG'})
else:
    sendmsg = None

recvmsg = comm.bcast (sendmsg, root = 0)

print 'rank=%d, recvmsg = %s' % (comm.rank, recvmsg)


