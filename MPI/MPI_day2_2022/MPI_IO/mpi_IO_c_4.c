/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *
 *  Copyright (C) 2019, Northwestern University
 *  See COPYRIGHT notice in top-level directory.
 *
 * This program shows all default MPI I/O hints.
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <mpi.h>

/*
 * Compile command: mpicc -o print_mpi_io_hints print_mpi_io_hints.c
 * Run command: mpiexec -n 1 print_mpi_io_hints input_file
 *
 * MPI File Info: nkeys = 23
 * MPI File Info: [ 0] key =              cb_buffer_size, flag = 1, valuelen = 8 value = 16777216
 * MPI File Info: [ 1] key =               romio_cb_read, flag = 1, valuelen = 9 value = automatic
 * MPI File Info: [ 2] key =              romio_cb_write, flag = 1, valuelen = 9 value = automatic
 * MPI File Info: [ 3] key =                    cb_nodes, flag = 1, valuelen = 1 value = 2
 * MPI File Info: [ 4] key =                    cb_align, flag = 1, valuelen = 1 value = 2
 * MPI File Info: [ 5] key =           romio_no_indep_rw, flag = 1, valuelen = 5 value = false
 * MPI File Info: [ 6] key =                romio_cb_pfr, flag = 1, valuelen = 7 value = disable
 * MPI File Info: [ 7] key =           romio_cb_fr_types, flag = 1, valuelen = 3 value = aar
 * MPI File Info: [ 8] key =       romio_cb_fr_alignment, flag = 1, valuelen = 1 value = 1
 * MPI File Info: [ 9] key =       romio_cb_ds_threshold, flag = 1, valuelen = 1 value = 0
 * MPI File Info: [10] key =           romio_cb_alltoall, flag = 1, valuelen = 9 value = automatic
 * MPI File Info: [11] key =          ind_rd_buffer_size, flag = 1, valuelen = 7 value = 4194304
 * MPI File Info: [12] key =          ind_wr_buffer_size, flag = 1, valuelen = 6 value = 524288
 * MPI File Info: [13] key =               romio_ds_read, flag = 1, valuelen = 7 value = disable
 * MPI File Info: [14] key =              romio_ds_write, flag = 1, valuelen = 7 value = disable
 * MPI File Info: [15] key =             striping_factor, flag = 1, valuelen = 1 value = 2
 * MPI File Info: [16] key =               striping_unit, flag = 1, valuelen = 7 value = 1048576
 * MPI File Info: [17] key = romio_lustre_start_iodevice, flag = 1, valuelen = 1 value = 0
 * MPI File Info: [18] key =                   direct_io, flag = 1, valuelen = 5 value = false
 * MPI File Info: [19] key = aggregator_placement_stride, flag = 1, valuelen = 2 value = -1
 * MPI File Info: [20] key =           abort_on_rw_error, flag = 1, valuelen = 7 value = disable
 * MPI File Info: [21] key =              cb_config_list, flag = 1, valuelen = 3 value = *:*
 * MPI File Info: [22] key =       romio_filesystem_type, flag = 1, valuelen = 10 value = CRAY ADIO:
 *  */

#define CHECK_ERR(func) { \
    if (err != MPI_SUCCESS) { \
        int errorStringLen; \
        char errorString[MPI_MAX_ERROR_STRING]; \
        MPI_Error_string(err, errorString, &errorStringLen); \
        printf("Error at line %d: calling %s (%s)\n",__LINE__, #func, errorString); \
    } \
}

/*----< main() >------------------------------------------------------------*/
int main(int argc, char **argv) {
    int      i, err, rank, nkeys;
    MPI_File fh;

    MPI_Init(&argc, &argv);
    err = MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    CHECK_ERR(MPI_Comm_rank);

    if (argc != 2) {
        printf("Usage: %s filename\n",argv[0]);
        MPI_Finalize();
        return 1;
    }

    /* create a new file */
    err = MPI_File_open(MPI_COMM_WORLD, argv[1], MPI_MODE_CREATE | MPI_MODE_RDWR,
                        MPI_INFO_NULL, &fh);
    CHECK_ERR(MPI_File_open);

    if (rank == 0) {
        MPI_Info info_used;

        /* get info object set by the MPI library */
        err = MPI_File_get_info(fh, &info_used);
        CHECK_ERR(MPI_Comm_rank);

        /* find the number of hints set in the info object */
        err = MPI_Info_get_nkeys(info_used, &nkeys);
        CHECK_ERR(MPI_Info_get_nkeys);
        printf("MPI File Info: nkeys = %d\n",nkeys);

        for (i=0; i<nkeys; i++) {
            /* for each hint, find the (key, value) pairs */
	    char key[MPI_MAX_INFO_KEY], value[MPI_MAX_INFO_VAL];
	    int  valuelen, flag;

            /* get the ith key */
            err = MPI_Info_get_nthkey(info_used, i, key);
            CHECK_ERR(MPI_Info_get_nthkey);

            /* get the string length of the ith key */
	    err = MPI_Info_get_valuelen(info_used, key, &valuelen, &flag);
            CHECK_ERR(MPI_Info_get_valuelen);

            /* get the value of ith key */
	    err = MPI_Info_get(info_used, key, valuelen+1, value, &flag);
            CHECK_ERR(MPI_Info_get);

            printf("MPI File Info: [%2d] key = %27s, flag = %d, valuelen = %d value = %s\n",
	           i,key,flag,valuelen,value);
        }
        err = MPI_Info_free(&info_used);
        CHECK_ERR(MPI_Info_free);
    }
    /* close the file */
    err = MPI_File_close(&fh);
    CHECK_ERR(MPI_File_close);

    MPI_Finalize();
    return 0;
}