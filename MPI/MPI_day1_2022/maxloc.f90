       PROGRAM maxloc_p
       INCLUDE "mpif.h"
       INTEGER n(9)
       INTEGER isend(2), irecv(2)
       DATA n /12, 15, 2, 20, 8, 3, 7, 24, 52/
       CALL MPI_INIT(ierr)
       CALL MPI_COMM_SIZE(MPI_COMM_WORLD, nprocs, ierr)
       CALL MPI_COMM_RANK(MPI_COMM_WORLD, myrank, ierr)
        ista = myrank * 3 + 1
        iend = ista + 2
        imax = -999
        DO i = ista, iend
        IF (n(i) > imax) THEN
        imax = n(i)
        iloc = i
        ENDIF
        ENDDO
        isend(1) = imax
        isend(2) = iloc
         CALL MPI_REDUCE(isend, irecv, 1, MPI_2INTEGER, MPI_MAXLOC, 0, MPI_COMM_WORLD, ierr)
         IF (myrank == 0) THEN
         PRINT *, 'Max =¡', irecv(1), 'Location =¡', irecv(2)
         ENDIF
         CALL MPI_FINALIZE(ierr)
         END

