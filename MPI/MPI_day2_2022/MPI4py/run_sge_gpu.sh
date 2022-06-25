#!/bin/bash
#$ -V
#$ -cwd
#$ -S /bin/bash
#$ -N test_ihlee

### Use Parallel Environment mpi
#$ -pe cpu_openmpi 4
### To use gpu : gpu , To use cpu : cpu 
#$ -q cpu
#$ -R yes
#$ -m ae

#mpirun echo "hi"
mpirun ./pi_parallel.py >output
