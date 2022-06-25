program ping
 use mpi
 integer myrank, nprocs
 integer ierr

 call MPI_INIT (ierr)
 call MPI_COMM_RANK (MPI_COMM_WORLD, myrank, ierr)
 call MPI_COMM_SIZE (MPI_COMM_WORLD, nprocs, ierr)
 print *, "Hello world! I am ",myrank," of ",nprocs
 call MPI_FINALIZE(ierr)

end program ping
