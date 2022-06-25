/*********************************************************************
 *
 *  Copyright (C) 2019, Northwestern University
 *  See COPYRIGHT notice in top-level directory.
 *
 *********************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>

#define LEN 10

#define CHECK_ERR(func) { \
    if (err != MPI_SUCCESS) { \
        int errorStringLen; \
        char errorString[MPI_MAX_ERROR_STRING]; \
        MPI_Error_string(err, errorString, &errorStringLen); \
        printf("Error at line %d: calling %s (%s)\n",__LINE__, #func, errorString); \
    } \
}

/*----< main() >------------------------------------------------------------*/
int main(int argc, char **argv)
{
    char *filename;
    int err, rank, nprocs, cmode, omode;
    MPI_File fh;
    MPI_Info info;

    MPI_Init(&argc, &argv);
    err = MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    CHECK_ERR(MPI_Comm_rank);
    err = MPI_Comm_size(MPI_COMM_WORLD, &nprocs);
    CHECK_ERR(MPI_Comm_size);

    filename = "testfile";
    if (argc > 1) filename = argv[1];

    /* Users can set customized I/O hints in info object */
    info = MPI_INFO_NULL;  /* no user I/O hint */

    /* set file open mode */
    cmode  = MPI_MODE_CREATE; /* to create a new file */
    cmode |= MPI_MODE_WRONLY; /* with write-only permission */

    /* collectively open a file, shared by all processes in MPI_COMM_WORLD */
    err = MPI_File_open(MPI_COMM_WORLD, filename, cmode, info, &fh);
    CHECK_ERR(MPI_File_open to write);

    /* collectively close the file */
    err = MPI_File_close(&fh);
    CHECK_ERR(MPI_File_close);

    /* set file open mode */
    omode = MPI_MODE_RDONLY; /* with read-only permission */

    /* collectively open a file, shared by all processes in MPI_COMM_WORLD */
    err = MPI_File_open(MPI_COMM_WORLD, filename, omode, info, &fh);
    CHECK_ERR(MPI_File_open to read);

    /* collectively close the file */
    err = MPI_File_close(&fh);
    CHECK_ERR(MPI_File_close);

prog_exit:
    MPI_Finalize();
    return 0;
}