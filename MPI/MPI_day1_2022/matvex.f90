    program main
    use mpi
    integer MAX_ROWS, MAX_COLS, rows, cols
    parameter (MAX_ROWS = 1000, MAX_COLS = 1000)
    double precision a(MAX_ROWS,MAX_COLS), b(MAX_COLS)
    double precision c(MAX_ROWS), buffer(MAX_COLS), ans

    integer myid, manager, numprocs, ierr, status(MPI_STATUS_SIZE)
    integer i, j, numsent, sender
    integer anstype, row

    call MPI_INIT(ierr)
    call MPI_COMM_RANK(MPI_COMM_WORLD, myid, ierr)
    call MPI_COMM_SIZE(MPI_COMM_WORLD, numprocs, ierr)
    manager = 0
    rows   = 100
    cols   = 100

    if (myid .eq. manager) then
!     manager initializes and then dispatches
!     initialize a and b  (arbitrary)
       do j = 1,cols
          b(j) = 1
          do i = 1,rows
             a(i,j) = i
          enddo
       enddo
       numsent = 0
!     send b to each worker process
       call MPI_BCAST(b, cols, MPI_DOUBLE_PRECISION, manager, &
                      MPI_COMM_WORLD, ierr)
       !  send a row to each worker process; tag with row number
       do i = 1,min(numprocs-1,rows)
          do j = 1,cols
             buffer(j) = a(i,j)
          enddo
          call MPI_SEND(buffer, cols, MPI_DOUBLE_PRECISION, i, &
                        i, MPI_COMM_WORLD, ierr)
          numsent = numsent+1
       enddo
       do i = 1,rows
          call MPI_RECV(ans, 1, MPI_DOUBLE_PRECISION, &
                        MPI_ANY_SOURCE, MPI_ANY_TAG, &
                        MPI_COMM_WORLD, status, ierr)
          sender     = status(MPI_SOURCE)
          anstype    = status(MPI_TAG)       ! row is tag value
          c(anstype) = ans
          if (numsent .lt. rows) then        ! send another row
             do j = 1,cols
                buffer(j) = a(numsent+1,j)
             enddo
             call MPI_SEND(buffer, cols, MPI_DOUBLE_PRECISION, &
                           sender, numsent+1, MPI_COMM_WORLD, ierr)
             numsent = numsent+1
          else      ! Tell sender that there is no more work
             call MPI_SEND(MPI_BOTTOM, 0, MPI_DOUBLE_PRECISION, &
                  sender, 0, MPI_COMM_WORLD, ierr)
          endif
       enddo
       !        print out the answer
       do i = 1,cols
          print *, "c(", i, ") = ", c(i)
       enddo
    else
       !     workers receive b, then compute dot products until
       !     done message received
       call MPI_BCAST(b, cols, MPI_DOUBLE_PRECISION, manager, &
                      MPI_COMM_WORLD, ierr)
       if (myid .le. rows) then
          ! skip if more processes than work
          do
             call MPI_RECV(buffer, cols, MPI_DOUBLE_PRECISION, &
                           manager, MPI_ANY_TAG, MPI_COMM_WORLD, &
                           status, ierr)
             if (status(MPI_TAG) .eq. 0) exit
             row = status(MPI_TAG)
             ans = 0.0
             do i = 1,cols
                ans = ans+buffer(i)*b(i)
             enddo
             call MPI_SEND(ans, 1, MPI_DOUBLE_PRECISION, manager, &
                           row, MPI_COMM_WORLD, ierr)
          enddo
       endif
    endif

   call MPI_FINALIZE(ierr)
   end
