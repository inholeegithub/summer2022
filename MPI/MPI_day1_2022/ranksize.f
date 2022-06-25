      program main
      include 'mpif.h'

      integer ierr, rank, size

      call MPI_INIT(ierr)
      call MPI_COMM_SIZE(MPI_COMM_WORLD,size,ierr)
      call MPI_COMM_RANK(MPI_COMM_WORLD,rank,ierr)
      print*, "I am rank", rank, " out of ", size, "processors"
      call MPI_FINALIZE(ierr)
      end
