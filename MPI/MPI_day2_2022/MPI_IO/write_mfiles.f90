!  ! example of parallel MPI write into multiple files
PROGRAM main
    ! Fortran 90 users can (and should) use
    ! use mpi
    ! instead of include 'mpif.h' if their MPI implementation provides a
    ! mpi module.
    include 'mpif.h'

    integer ierr, i, myrank, BUFSIZE, thefile
    parameter (BUFSIZE=100)
    integer buf(BUFSIZE)
    character*12 ofname

    call MPI_INIT(ierr)
    call MPI_COMM_RANK(MPI_COMM_WORLD, myrank, ierr)

    do i = 1, BUFSIZE
        buf(i) = myrank * BUFSIZE + i
    enddo

    write(ofname,'(a8,i4.4)') 'testfile',myrank

    open(unit=11,file=ofname,form='unformatted')
    write(11) buf

    call MPI_FINALIZE(ierr)

END PROGRAM main
