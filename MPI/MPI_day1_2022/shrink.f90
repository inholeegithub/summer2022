         PROGRAM main
		 implicit none
		 real sum1,ssum
		 integer i,ista,iend
		 integer ierr,n1,n2,nprocs,myrank
         INCLUDE 'mpif.h'
         PARAMETER (n1 = 1, n2 = 1000)
         REAL, ALLOCATABLE :: a(:)

         CALL MPI_INIT(ierr)
         CALL MPI_COMM_SIZE(MPI_COMM_WORLD, nprocs, ierr)
         CALL MPI_COMM_RANK(MPI_COMM_WORLD, myrank, ierr)
         CALL para_range(n1, n2, nprocs, myrank, ista, iend)
         ALLOCATE (a(ista:iend))
         DO i = ista, iend
         a(i) = i
         ENDDO
   !     sum1 = 0.0
   !     DO i = ista, iend
   !     sum1 = sum1 + a(i)
   !    ENDDO
		sum1=sum(a)
         DEALLOCATE (a)
        CALL MPI_REDUCE(sum1, ssum, 1, MPI_REAL,MPI_SUM, 0, MPI_COMM_WORLD, ierr)
        sum1 = ssum
        PRINT *,'sum1 =',sum1, myrank
        CALL MPI_FINALIZE(ierr)
        END


       SUBROUTINE para_range(n1, n2, nprocs, irank, ista, iend)
       iwork = (n2 - n1) / nprocs + 1
       ista = MIN(irank * iwork + n1, n2 + 1)
       iend = MIN(ista + iwork - 1, n2)
       END

