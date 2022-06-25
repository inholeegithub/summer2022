#!/usr/bin/env python
import numpy
from matplotlib import pyplot

def mandelbrot(x, y, maxit):
    c = x + y*1j
    z = 0 + 0j
    it = 0
    while abs(z) < 2 and it < maxit:
        z = z**2 + c
        it += 1
    return it
def show (C):
    pyplot.imshow(C, aspect='equal')
    pyplot.spectral()
    pyplot.show()

if __name__ == '__main__':
    x1, x2 = -2.0, 1.0 
    y1, y2 = -1.0, 1.0 
    w, h   = 150, 100
    #w, h   = 600, 400
    #w, h   = 1200, 800
    maxit  = 127
    C = numpy.zeros ([h, w], dtype='i')
    dx=(x2-x1)/w 
    dy=(y2-y1)/h
    for i in range(h):
        y = y1 + i * dy
        for j in range(w):
            x = x1 + j * dx
            C[i,j]=mandelbrot(x,y,maxit)
    show (C)

    f=open('z.dat','w')
    for i in range(h):
        for j in range(w):
            print >>f,'%d %d %d' % (i,j,C[i,j])
    f.close()
