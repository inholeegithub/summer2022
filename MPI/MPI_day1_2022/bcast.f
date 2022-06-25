      PROGRAM bcast
      INCLUDE 'mpif.h'
      INTEGER imsg(4)
      CALL MPI_INIT(ierr)
      CALL MPI_COMM_SIZE(MPI_COMM_WORLD, nprocs, ierr)
      CALL MPI_COMM_RANK(MPI_COMM_WORLD, myrank, ierr)
      IF (myrank==0) THEN
        DO i=1,4
            imsg(i) = i
        ENDDO
      ELSE
        DO i=1,4
            imsg(i) = 0
        ENDDO
      ENDIF
      call flush(6)
      PRINT *,'Before (',myrank,'):',imsg
      CALL MPI_BCAST(imsg, 4, MPI_INTEGER,
     & 0, MPI_COMM_WORLD, ierr)
      PRINT *,'After  (',myrank,'):',imsg
      CALL MPI_FINALIZE(ierr)
      END
