/*
Shows how to use MPI_Type_vector to send noncontiguous blocks of data
 and MPI_Get_count and MPI_Get_elements to see the number of elements sent
*/
#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
#include <math.h>
int main(argc,argv)
int argc;
char *argv[];
{
    int myid, numprocs,mpi_err;
#define SIZE 25
    double svect[SIZE],rvect[SIZE];
    int i,bonk1,bonk2,numx,stride,extent;
    MPI_Datatype MPI_LEFT_RITE;
    MPI_Status status;
    
    MPI_Init(&argc,&argv);
    MPI_Comm_size(MPI_COMM_WORLD,&numprocs);
    MPI_Comm_rank(MPI_COMM_WORLD,&myid);
 
    stride=5;
    numx=(SIZE+1)/stride;
    extent=1;
    if(myid == 1){
      printf("numx=%d  extent=%d stride=%d\n",numx,extent,stride);
    }
    mpi_err=MPI_Type_vector(numx,extent,stride,MPI_DOUBLE,&MPI_LEFT_RITE);
    mpi_err=MPI_Type_commit(&MPI_LEFT_RITE);
    if(myid == 0){
        for (i=0;i<SIZE;i++)
            svect[i]=i;
        MPI_Send(svect,1,MPI_LEFT_RITE,1,100,MPI_COMM_WORLD);
    }
    if(myid == 1){
        for (i=0;i<SIZE;i++)
            rvect[i]=-1;
        MPI_Recv(rvect,1,MPI_LEFT_RITE,0,100,MPI_COMM_WORLD,&status);
    }
    if(myid == 1){
        MPI_Get_count(&status,MPI_LEFT_RITE,&bonk1);
        MPI_Get_elements(&status,MPI_DOUBLE,&bonk2);
        printf("got %d elements of type MY_TYPE\n",bonk1);
        printf("which contained %d elements of type MPI_DOUBLE\n",bonk2);
        for (i=0;i<SIZE;i++)
            if(rvect[i] != -1)printf("%d %g\n",i,rvect[i]);
    }
    MPI_Finalize();
}
/*
output
numx=5  extent=5 stride=1
got 1 elements of type MY_TYPE
which contained 5 elements of type MPI_DOUBLE
0 0
5 5
10 10
15 15
20 20
*/
