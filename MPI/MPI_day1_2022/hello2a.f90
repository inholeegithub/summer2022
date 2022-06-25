 program main
    use mpi
    implicit none
    integer ierr, irank, nprocs 
    integer tag, num, next, prev
    integer istatus(MPI_STATUS_SIZE)
    integer man, i
    character*20 msg
   
    call MPI_INIT(ierr)
    call MPI_COMM_RANK(MPI_COMM_WORLD,  irank, ierr)
    call MPI_COMM_SIZE(MPI_COMM_WORLD, nprocs, ierr)
   
    tag = 10

    if (irank == 0) then
       do i=1, nprocs-1
!         write(msg,'(A,2x,I2)') 'Hello! node',i
         write(msg,'(A,2x,I2)') 'Hello! node',MPI_COMM_WORLD
         call MPI_SEND(msg,20, MPI_CHARACTER, i, tag, MPI_COMM_WORLD, ierr)
       end do
    else
       call MPI_RECV(msg,20, MPI_CHARACTER, 0, tag, MPI_COMM_WORLD, istatus, ierr)
       man = istatus (MPI_SOURCE)
       write(6,'(A)') trim(msg)
!       write(6,'(A,2x,I2)') 'Hi node',man
       write(6,'(A,2x,I2)') 'Hi node',MPI_COMM_WORLD
    endif
    
    call MPI_FINALIZE(ierr)      
 end program main
