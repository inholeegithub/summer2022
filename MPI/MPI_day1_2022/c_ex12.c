/*
Shows a short cut method to create a collection of communicators.
All processors with the "same color" will be in the same communicator.
In this case the color is either 0 or 1 for even or odd processors.
Index gives rank in new communicator.
*/
#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
#include <math.h>
int main(argc,argv)
int argc;
char *argv[];
{
    int myid, numprocs;
    int color,Zero_one,new_id,new_nodes;
    MPI_Comm NEW_COMM; 
    MPI_Init(&argc,&argv);
    MPI_Comm_size(MPI_COMM_WORLD,&numprocs);
    MPI_Comm_rank(MPI_COMM_WORLD,&myid);
	color=myid % 2;
	MPI_Comm_split(MPI_COMM_WORLD,color,myid,&NEW_COMM);
	MPI_Comm_rank( NEW_COMM, &new_id);
	MPI_Comm_rank( NEW_COMM, &new_nodes);
	Zero_one = -1;
	if(new_id==0)Zero_one = color;
	MPI_Bcast(&Zero_one,1,MPI_INT,0, NEW_COMM);
	if(Zero_one==0)printf("part of even processor communicator \n");
	if(Zero_one==1)printf("part of odd processor communicator \n");
	printf("old_id= %d new_id= %d\n", myid, new_id);
    MPI_Finalize();
}

