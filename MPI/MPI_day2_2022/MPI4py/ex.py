#!/usr/bin/env python
from mpi4py import MPI
comm = MPI.COMM_WORLD

sendmsg = [comm.rank]*3
right = (comm.rank + 1) % comm.size
left  = (comm.rank - 1) % comm.size

req1 = comm.isend (sendmsg, dest = right)
req2 = comm.isend (sendmsg, dest = left )
lmsg = comm.recv (source = left)
rmsg = comm.recv (source = right)
MPI.Request.Waitall ([req1, req2])

print 'rank = %s,  lmsg = %s,  rmsg = %s' % (comm.rank, lmsg, rmsg)
