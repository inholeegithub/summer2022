        PROGRAM main
        INCLUDE 'mpif.h'
        PARAMETER (n = 1000)
        DIMENSION a(n)
        CALL MPI_INIT(ierr)
        CALL MPI_COMM_SIZE(MPI_COMM_WORLD, nprocs, ierr)
        CALL MPI_COMM_RANK(MPI_COMM_WORLD, myrank, ierr)
        DO i = 1 + myrank, n, nprocs
         a(i) = i
        ENDDO
        asum = 0.0
        DO i = 1 + myrank, n, nprocs
        asum = asum + a(i)
        ENDDO
        CALL MPI_REDUCE(asum, ssum, 1, MPI_REAL, MPI_SUM, 0, MPI_COMM_WORLD, ierr)
        asum = ssum
        PRINT *,'sum =',asum
        CALL MPI_FINALIZE(ierr)
        END

