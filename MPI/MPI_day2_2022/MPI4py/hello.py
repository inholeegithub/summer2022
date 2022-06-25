#!/usr/bin/env python

import os, sys
from mpi4py import MPI

comm = MPI.COMM_WORLD
rank = comm.Get_rank ()

print 'Hello! I am a processor ', rank

