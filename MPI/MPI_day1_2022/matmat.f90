!**********************************************************************
!     matmat.f - matrix - matrix multiply, simple self-scheduling version
!************************************************************************
      program main

      use mpi

      integer MAX_AROWS, MAX_ACOLS, MAX_BCOLS
      parameter (MAX_AROWS = 20, MAX_ACOLS = 1000, MAX_BCOLS = 20)
      double precision a(MAX_AROWS,MAX_ACOLS), b(MAX_ACOLS,MAX_BCOLS)
      double precision c(MAX_AROWS,MAX_BCOLS)
      double precision buffer(MAX_ACOLS), ans(MAX_ACOLS)

      integer myid, master, numprocs, ierr, status(MPI_STATUS_SIZE)
      integer i, j, numsent, sender
      integer anstype, row, arows, acols, brows, bcols, crows, ccols

      call MPI_INIT( ierr )
      call MPI_COMM_RANK( MPI_COMM_WORLD, myid, ierr )
      call MPI_COMM_SIZE( MPI_COMM_WORLD, numprocs, ierr )
      print *, "Process ", myid, " of ", numprocs, " is alive"

      master = 0
      arows  = 10
      acols  = 100
      brows  = 100
      bcols  = 10
      crows  = arows
      ccols  = bcols

      if ( myid .eq. master ) then
!        master initializes and then dispatches
!        initialize a and b
         do i = 1,acols
            do j = 1,arows
               a(j,i) = i
            enddo
         enddo
         do i = 1,bcols
            do j = 1,brows
               b(j,i) = i
            enddo
         enddo

         numsent = 0

!        send b to each other process
         do i = 1,bcols
         call MPI_BCAST(b(1,i), brows, MPI_DOUBLE_PRECISION, master, &
              MPI_COMM_WORLD, ierr)
         enddo

!        send a row of a to each other process; tag with row number
         do i = 1,numprocs-1
            do j = 1,acols
               buffer(j) = a(i,j)
            enddo
            call MPI_SEND(buffer, acols, MPI_DOUBLE_PRECISION, i, &
                 i, MPI_COMM_WORLD, ierr)
            numsent = numsent+1
         enddo

         do i = 1,crows
            call MPI_RECV(ans, ccols, MPI_DOUBLE_PRECISION, &
                 MPI_ANY_SOURCE, MPI_ANY_TAG, MPI_COMM_WORLD, status, &
                 ierr)
            sender     = status(MPI_SOURCE)
            anstype    = status(MPI_TAG)
            do j = 1,ccols
               c(anstype,j) = ans(j)
            enddo

            if (numsent .lt. arows) then
               do j = 1,acols
                  buffer(j) = a(numsent+1,j)
               enddo
               call MPI_SEND(buffer, acols, MPI_DOUBLE_PRECISION, &
                    sender, numsent+1, MPI_COMM_WORLD, ierr)
               numsent = numsent+1
            else
               call MPI_SEND(1.0, 1, MPI_DOUBLE_PRECISION, sender, &
                    0, MPI_COMM_WORLD, ierr)
            endif
         enddo

!        print out the answer
         do i = 1,crows
            do j = 1,ccols
               print *, "c(", i, ",", j, ") = ", c(i,j)
            enddo
         enddo

      else
!        slaves receive b, then compute rows of c until done message
         do i = 1,bcols
           call MPI_BCAST(b(1,i), brows, MPI_DOUBLE_PRECISION, master, &
                MPI_COMM_WORLD, ierr)
         enddo
         do
            call MPI_RECV(buffer, acols, MPI_DOUBLE_PRECISION, master, &
                 MPI_ANY_TAG, MPI_COMM_WORLD, status, ierr)
            if (status(MPI_TAG) .eq. 0) exit
            row = status(MPI_TAG)
            do i = 1,bcols
               ans(i) = 0.0
               do j = 1,acols
                  ans(i) = ans(i) + buffer(j)*b(j,i)
               enddo
            enddo
            call MPI_SEND(ans, bcols, MPI_DOUBLE_PRECISION, master, row,&
                 MPI_COMM_WORLD, ierr)
         enddo
      endif

      call MPI_FINALIZE(ierr)
      stop
      end
