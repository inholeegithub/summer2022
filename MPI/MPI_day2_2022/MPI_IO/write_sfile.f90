!  !!example of parallel MPI write into a single file
PROGRAM main
    ! Fortran 90 users can (and should) use
    !     use mpi
    ! instead of include 'mpif.h' if their MPI implementation provides a
    ! mpi module.
    include 'mpif.h'

    integer ierr, i, myrank, BUFSIZE, thefile
    parameter (BUFSIZE=100)
    integer buf(BUFSIZE)
    integer(kind=MPI_OFFSET_KIND) disp

    call MPI_INIT(ierr)
    call MPI_COMM_RANK(MPI_COMM_WORLD, myrank, ierr)

    do i = 1, BUFSIZE
        buf(i) = myrank * BUFSIZE + i
    enddo
    call MPI_FILE_OPEN(MPI_COMM_WORLD, 'testfile', &
                       MPI_MODE_WRONLY + MPI_MODE_CREATE, &
                       MPI_INFO_NULL, thefile, ierr)
    ! assume 4-byte integers
    disp = myrank * BUFSIZE * 4
    call MPI_FILE_SET_VIEW(thefile, disp, MPI_INTEGER, &
                           MPI_INTEGER, 'native', &
                           MPI_INFO_NULL, ierr)
    call MPI_FILE_WRITE(thefile, buf, BUFSIZE, MPI_INTEGER, &
                        MPI_STATUS_IGNORE, ierr)
    call MPI_FILE_CLOSE(thefile, ierr)
    call MPI_FINALIZE(ierr)

END PROGRAM main
