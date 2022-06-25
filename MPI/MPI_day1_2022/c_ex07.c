#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>

/*
! This program shows how to use MPI_Alltoall.  Each processor
! send/rec a different  random number to/from other processors.  
*/
/* globals */
int numnodes,myid,mpi_err;
#define mpi_root 0
/* end module  */

void init_it(int  *argc, char ***argv);
void seed_random(int  id);
void random_number(float *z);

void init_it(int  *argc, char ***argv) {
	mpi_err = MPI_Init(argc,argv);
    mpi_err = MPI_Comm_size( MPI_COMM_WORLD, &numnodes );
    mpi_err = MPI_Comm_rank(MPI_COMM_WORLD, &myid);
}

int main(int argc,char *argv[]){
	int *sray,*rray;
	int *sdisp,*scounts,*rdisp,*rcounts;
	int ssize,rsize,i,k,j;
	float z;

	init_it(&argc,&argv);
	scounts=(int*)malloc(sizeof(int)*numnodes);
	rcounts=(int*)malloc(sizeof(int)*numnodes);
	sdisp=(int*)malloc(sizeof(int)*numnodes);
	rdisp=(int*)malloc(sizeof(int)*numnodes);
/*
! seed the random number generator with a
! different number on each processor
*/
	seed_random(myid);
/* find  data to send */
	for(i=0;i<numnodes;i++){
		random_number(&z);
		scounts[i]=(int)(10.0*z)+1;
	}
	printf("myid= %d scounts=",myid);
	for(i=0;i<numnodes;i++)
		printf("%d ",scounts[i]);
	printf("\n");
/* send the data */
	mpi_err = MPI_Alltoall(	scounts,1,MPI_INT,
						    rcounts,1,MPI_INT,
	                 	    MPI_COMM_WORLD);
	printf("myid= %d rcounts=",myid);
	for(i=0;i<numnodes;i++)
		printf("%d ",rcounts[i]);
	printf("\n");
    mpi_err = MPI_Finalize();
}

void seed_random(int  id){
	srand((unsigned int)id);
}
void random_number(float *z){
	int i;
	i=rand();
	*z=(float)i/RAND_MAX;
}
