   #include "mpi.h"
   #include <stdio.h>

   int main(argc,argv)
   int argc;
   char *argv[]; {
   int  numtasks, rank, rc; 

   rc = MPI_Init(&argc,&argv);
   if (rc != MPI_SUCCESS) {
     printf ("Error starting MPI program. Terminating.\n");
     MPI_Abort(MPI_COMM_WORLD, rc);
     }

   MPI_Comm_size(MPI_COMM_WORLD,&numtasks);
   MPI_Comm_rank(MPI_COMM_WORLD,&rank);
   printf ("Number of tasks= %d My rank= %d\n", numtasks,rank);

   /*******  do some work *******/

   MPI_Finalize();
   }

