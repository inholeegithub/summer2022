      program main
      use mpi
      double precision starttime, endtime
      double precision  PI25DT
      parameter        (PI25DT = 3.141592653589793238462643d0)
      double precision  mypi, pi, h, sum, x, f, a
      integer n, myid, numprocs, i, ierr

      f(a) = 4.d0 / (1.d0 + a*a)   !   function to integrate

      call MPI_INIT(ierr)
      call MPI_COMM_RANK(MPI_COMM_WORLD, myid, ierr)
      call MPI_COMM_SIZE(MPI_COMM_WORLD, numprocs, ierr)

 10   if ( myid .eq. 0 ) then
         print *, 'Enter the number of intervals: (0 quits) '
         read(*,*) n
      endif
      starttime = MPI_WTIME()
!                                 broadcast n
      call MPI_BCAST(n,1,MPI_INTEGER,0,MPI_COMM_WORLD,ierr)
!                                 check for quit signal
      if ( n .le. 0 ) goto 30
!                                 calculate the interval size
      h   = 1.0d0/n
      sum = 0.0d0
      do 20 i = myid+1, n, numprocs
         x   = h * (dble(i) - 0.5d0)
         sum = sum + f(x)
 20   continue
      mypi = h * sum
!                                 collect all the partial sums
      call MPI_REDUCE(mypi,pi,1,MPI_DOUBLE_PRECISION,MPI_SUM,0, &
                      MPI_COMM_WORLD,ierr)
!                                 node 0 prints the answer.
      endtime = MPI_WTIME()
      if (myid .eq. 0) then
         print *, 'pi is ', pi, 'Error is ', abs(pi - PI25DT)
         print *, 'time is ', endtime-starttime, ' seconds'
      endif
      go to 10
 30   call MPI_FINALIZE(ierr)
      stop
      end
