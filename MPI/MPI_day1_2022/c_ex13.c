#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
/*
! This program shows how to use MPI_Gatherv.  Each processor sends a
! different amount of data to the root processor.  We use MPI_Gather
! first to tell the root how much data is going to be sent.
*/
/* globals */
int numnodes,myid,mpi_err;
#define mpi_root 0
/* end of globals */
void init_it(int  *argc, char ***argv);

void init_it(int  *argc, char ***argv) {
	mpi_err = MPI_Init(argc,argv);
    mpi_err = MPI_Comm_size( MPI_COMM_WORLD, &numnodes );
    mpi_err = MPI_Comm_rank(MPI_COMM_WORLD, &myid);
}

int main(int argc,char *argv[]){
/* poe a.out -procs 3 -rmpool 1 */
	int *sray,*displacements,*counts,*allray;
	int size,mysize,i;
	
	init_it(&argc,&argv);
	mysize=myid+1;
/* counts and displacement arrays are only required on the root */
	if(myid == mpi_root){
		counts=(int*)malloc(numnodes*sizeof(int));
		displacements=(int*)malloc(numnodes*sizeof(int));
	}
/* we gather the counts to the root */
	mpi_err = MPI_Gather((void*)mysize,1,MPI_INT, 
					     (void*)counts,  1,MPI_INT, 
					     mpi_root,MPI_COMM_WORLD);
/* calculate displacements and the size of the recv array */
	if(myid == mpi_root){
		displacements[0]=0;
		for( i=1;i<numnodes;i++){
			displacements[i]=counts[i-1]+displacements[i-1];
		}
		size=0;
		for(i=0;i< numnodes;i++)
			size=size+counts[i];
		sray=(int*)malloc(size*sizeof(int));
		for(i=0;i<size;i++)
		    sray[i]=i+1;
	}
/* different amounts of data for each processor  */
/* is scattered from the root */
	allray=(int*)malloc(sizeof(int)*mysize);
	mpi_err = MPI_Scatterv(sray,counts,displacements,MPI_INT, 
	                       allray, mysize,           MPI_INT,
	                 mpi_root,                                
	                 MPI_COMM_WORLD);
	                
	for(i=0;i<mysize;i++)
		printf("%d ",allray[i]);
	printf("\n");

    mpi_err = MPI_Finalize();
}
