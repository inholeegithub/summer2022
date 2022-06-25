      program main
      include 'mpif.h'
      integer ierr
      call MPI_INIT(ierr)
      print*, 'hello world' 
      call MPI_FINALIZE(ierr)
      end
