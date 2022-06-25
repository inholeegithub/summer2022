#!/usr/bin/env python
#example to run: % mpiexec -n 4 python integral.py 0.0 1.0 10000
import sys,numpy
from mpi4py import MPI
comm = MPI.COMM_WORLD
rank = comm.Get_rank()
size = comm.Get_size()

def f(x):
    return x*x
def F(a,b):
    return (1./3)*(b**3 - a**3)

def integrateRange(a, b, n):
    integral = -(f(a) + f(b))/2.0
    # n+1 endpoints, but n trapazoids
    for x in numpy.linspace(a,b,n+1):
                    integral = integral + f(x)
    integral = integral* (b-a)/n
    return integral

if __name__ == '__main__':
    #takes in command-line arguments [a,b,n]
    a = float(sys.argv[1])
    b = float(sys.argv[2])
    n = int(sys.argv[3])
    #h is the step size. n is the total number of trapezoids
    h = (b-a)/n
    #local_n is the number of trapezoids each process will calculate
    #note that size must divide n
    local_n = n/size

    #we calculate the interval that each process handles
    #local_a is the starting point and local_b is the endpoint
    local_a = a + rank*local_n*h
    local_b = local_a + local_n*h

    #initializing variables. mpi4py requires that we pass numpy objects.
    integral = numpy.zeros(1)
    total = numpy.zeros(1)

    # perform local computation. Each process integrates its own interval
    start = MPI.Wtime ()
    integral[0] = integrateRange(local_a, local_b, local_n)
    end = MPI.Wtime ()

    # communication
    # root node receives results with a collective "reduce"
    comm.Reduce(integral, total, op=MPI.SUM, root=0)

    # root process prints results
    if comm.rank == 0:
        print "With n =", n, "trapezoids, our estimate of the integral from"\
        , a, "to", b, "is", total
        print "error = ", F(a,b)-total
        print "Wall time = ", end-start
