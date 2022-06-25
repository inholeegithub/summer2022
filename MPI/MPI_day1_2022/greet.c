#include <stdio.h>
#include <string.h>
#include "mpi.h"

main(int argc, char* argv[]) {
    int         my_rank;       /* rank of process      */
    int         np;            /* number of processes  */
    int         source;        /* rank of sender       */
    int         dest;          /* rank of receiver     */
    int         tag = 123;     /* tag for messages     */
    char        message[100];  /* storage for message  */
    MPI_Status  status;        /* return status for  receive  */
    
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &my_rank);
    MPI_Comm_size(MPI_COMM_WORLD, &np);

    if (my_rank == 0) {
        sprintf(message, "Greetings from process %d!", my_rank);
        for (dest = 1; dest < np; dest++) {
            MPI_Send(message, 100, MPI_CHAR, 
                     dest, tag, MPI_COMM_WORLD);
        }
    } else {
        source = 0;
        MPI_Recv(message, 100, MPI_CHAR, source, tag, 
                 MPI_COMM_WORLD, &status);
        printf("%s\n", message);
    }

    MPI_Finalize();
}
