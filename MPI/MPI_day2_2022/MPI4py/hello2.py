#!/usr/bin/env python

import os, sys
from mpi4py import MPI

comm = MPI.COMM_WORLD
size = comm.Get_size ()
rank = comm.Get_rank ()

print 'Hello! I am a processor %d of %d.' % (rank,size)

