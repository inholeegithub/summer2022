#include <stdio.h>
#include <mpi.h>

int main(int argc, char **argv)
{
    int size, rank;
    MPI_Init(&argc, &argv);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
 // Get the name of the processor
    char name[MPI_MAX_PROCESSOR_NAME];
    int name_len;
    MPI_Get_processor_name(name, &name_len);
    printf("My name is %s, rank %d out of %d processors\n",name,rank,size);
    MPI_Finalize();
    return 0;
}
