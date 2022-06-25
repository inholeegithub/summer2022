! read from a common file using explicit offsets
PROGRAM main
    use mpi

    integer FILESIZE, MAX_BUFSIZE, INTSIZE
    parameter (FILESIZE=1048576, MAX_BUFSIZE=1048576, INTSIZE=4)
    integer buf(MAX_BUFSIZE), rank, ierr, fh, nprocs, nints
    integer status(MPI_STATUS_SIZE), count
    integer (kind=MPI_OFFSET_KIND) offset

    call MPI_INIT(ierr)
    call MPI_COMM_RANK(MPI_COMM_WORLD, rank, ierr)
    call MPI_COMM_SIZE(MPI_COMM_WORLD, nprocs, ierr)

    call MPI_FILE_OPEN(MPI_COMM_WORLD, '/home/guest/jskim/datafile', &
                       MPI_MODE_RDONLY, MPI_INFO_NULL, fh, ierr)
    nints = FILESIZE/(nprocs*INTSIZE)
    offset = rank * nints * INTSIZE
    call MPI_FILE_READ_AT(fh, offset, buf, nints, MPI_INTEGER, &
                          status, ierr)
    call MPI_GET_COUNT(status, MPI_INTEGER, count, ierr)
    print *, 'process ', rank, 'read ', count, 'integers'

    call MPI_FILE_CLOSE(fh, ierr)
    call MPI_FINALIZE(ierr)
END PROGRAM main
