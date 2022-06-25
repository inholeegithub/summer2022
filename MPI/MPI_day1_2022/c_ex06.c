#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>

/*
! This program shows how to use MPI_Scatter and MPI_Reduce
! Each processor gets different data from the root processor
! by way of mpi_scatter.  The data is summed and then sent back
! to the root processor using MPI_Reduce.  The root processor
! then prints the global sum. 
*/
/*  globals */
int numnodes,myid,mpi_err;
#define mpi_root 0
/* end globals  */

void init_it(int  *argc, char ***argv);

void init_it(int  *argc, char ***argv) {
	mpi_err = MPI_Init(argc,argv);
    mpi_err = MPI_Comm_size( MPI_COMM_WORLD, &numnodes );
    mpi_err = MPI_Comm_rank(MPI_COMM_WORLD, &myid);
}

int main(int argc,char *argv[]){
	int *myray,*send_ray,*back_ray;
	int count;
	int size,mysize,i,k,j,total,gtotal;
	
	init_it(&argc,&argv);
/* each processor will get count elements from the root */
	count=4;
	myray=(int*)malloc(count*sizeof(int));
/* create the data to be sent on the root */
	if(myid == mpi_root){
	    size=count*numnodes;
		send_ray=(int*)malloc(size*sizeof(int));
		back_ray=(int*)malloc(numnodes*sizeof(int));
		for(i=0;i<size;i++)
			send_ray[i]=i;
		}
/* send different data to each processor */
	mpi_err = MPI_Scatter(	send_ray, count,   MPI_INT,
						    myray,    count,   MPI_INT,
	                 	    mpi_root,
	                 	    MPI_COMM_WORLD);	                
/* each processor does a local sum */
	total=0;
	for(i=0;i<count;i++)
	    total=total+myray[i];
	printf("myid= %d total= %d\n ",myid,total);
/* send the local sums back to the root */
    mpi_err = MPI_Reduce(&total,    &gtotal, 1,  MPI_INT, 
						MPI_SUM, 
	                 	mpi_root,                  
	                 	MPI_COMM_WORLD);
/* the root prints the global sum */
	if(myid == mpi_root){
	  printf("results from all processors= %d \n ",gtotal);
	}
    mpi_err = MPI_Finalize();
}
