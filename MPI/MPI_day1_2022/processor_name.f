      program main
      include 'mpif.h' 

      integer ierr, rank, size
      character*(MPI_MAX_PROCESSOR_NAME) name
      integer name_len

      call MPI_INIT(ierr)
      call MPI_COMM_SIZE(MPI_COMM_WORLD,size,ierr)
      call MPI_COMM_RANK(MPI_COMM_WORLD,rank,ierr)

      call MPI_Get_processor_name(name,name_len,ierr)
      print*,"My name is", name,"rank",rank,"out of ",size,"processors"

      call MPI_FINALIZE(ierr)
      end
