#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>

/*
! This program shows how to use MPI_Alltoallv.  Each processor
! send/rec a different and random amount of data to/from other
! processors.  
! We use MPI_Alltoall to tell how much data is going to be sent.
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
/* find out how much data to send */
	for(i=0;i<numnodes;i++){
		random_number(&z);
		scounts[i]=(int)(5.0*z)+1;
	}
	printf("myid= %d scounts=%d %d %d %d\n",myid,scounts[0],scounts[1],scounts[2],scounts[3]);
for(i=0;i<numnodes;i++)
		printf("%d ",scounts[i]);
	printf("\n");
/* tell the other processors how much data is coming */
	mpi_err = MPI_Alltoall(	scounts,1,MPI_INT,
						    rcounts,1,MPI_INT,
	                 	    MPI_COMM_WORLD);
/*	write(*,*)"myid= ",myid," rcounts= ",rcounts */
/* calculate displacements and the size of the arrays */
	sdisp[0]=0;
	for(i=1;i<numnodes;i++){
		sdisp[i]=scounts[i-1]+sdisp[i-1];
	}
	rdisp[0]=0;
	for(i=1;i<numnodes;i++){
		rdisp[i]=rcounts[i-1]+rdisp[i-1];
	}
	ssize=0;
	rsize=0;
	for(i=0;i<numnodes;i++){
		ssize=ssize+scounts[i];
		rsize=rsize+rcounts[i];
	}
	
/* allocate send and rec arrays */
	sray=(int*)malloc(sizeof(int)*ssize);
	rray=(int*)malloc(sizeof(int)*rsize);
	for(i=0;i<ssize;i++)
		sray[i]=myid;
/* send/rec different amounts of data to/from each processor */
	mpi_err = MPI_Alltoallv(	sray,scounts,sdisp,MPI_INT,
						        rray,rcounts,rdisp,MPI_INT,
	                 	        MPI_COMM_WORLD);
	                
	printf("myid= %d rray=",myid);
	for(i=0;i<rsize;i++)
		printf("%d ",rray[i]);
	printf("\n");
    mpi_err = MPI_Finalize();
}
/*
  0:myid= 0 scounts=1 7 4
  0:myid= 0 scounts=0 1 1 1 1 1 1 2
  1:myid= 1 scounts=6 2 4
  1:myid= 1 scounts=0 0 0 0 0 0 0 1 1 2 2 2 2 2 2 2
  2:myid= 2 scounts=1 7 4
  2:myid= 2 scounts=0 0 0 0 1 1 1 1 2 2 2 2
*/

void seed_random(int  id){
	srand((unsigned int)id);
}
void random_number(float *z){
	int i;
	i=rand();
	*z=(float)i/RAND_MAX;
}
