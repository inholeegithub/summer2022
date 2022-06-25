!234567890
       program simple
       include 'mpif.h'

       integer numtasks, rank, ierr, rc

       call MPI_INIT(ierr)
       if (ierr .ne. MPI_SUCCESS) then
          print *,'Error starting MPI program. Terminating.'
          call MPI_ABORT(MPI_COMM_WORLD, rc, ierr)
       end if

       call MPI_COMM_RANK(MPI_COMM_WORLD, rank, ierr)
       call MPI_COMM_SIZE(MPI_COMM_WORLD, numtasks, ierr)
       print *, 'Number of tasks=',numtasks,' My rank=',rank

C ****** do some work ******

       call MPI_FINALIZE(ierr)

       end

