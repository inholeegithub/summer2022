!234567890
       program d_access
       implicit none
       include 'mpif.h'
       integer myid, nproc, ierr, iroot, kount
       real*8 time_start,time_end
       integer nsites
       real*8, allocatable :: spin_lattice(:),tspin_lattice(:)
       real*8 before,after
       integer kdum,kk

       call MPI_INIT( ierr )
       call MPI_COMM_RANK( MPI_COMM_WORLD, myid, ierr )
       call MPI_COMM_SIZE( MPI_COMM_WORLD, nproc, ierr )
       if(myid == 0 .and. nproc > 1) print *,  nproc," processes are alive"
       if(myid == 0 .and. nproc ==1) print *,  nproc," process is alive" 
       time_start=MPI_WTIME()


       nsites=100

       allocate(spin_lattice(nsites))
       allocate(tspin_lattice(nsites))
       spin_lattice=0.d0
       tspin_lattice=0.d0
       before=float(myid)
       print*, before, myid,' node,in the memory'

       open(97,file='fort.97',access='direct',recl=8*(nsites+1))
       write(97,rec=myid+1) before,(spin_lattice(kdum),kdum=1,nsites)
       close(97)
       call MPI_BARRIER( MPI_COMM_WORLD, ierr )

       if(myid == 0)then   ! -----[   process id = 0
       open(97,file='fort.97',access='direct',recl=8*(nsites+1))
       before=2.d222
       do kk=1,nproc
       read(97,rec=kk) after,(tspin_lattice(kdum),kdum=1,nsites)
       print*, after, kk-1,' node,in the file'
!      if(before > after)then
!      before=after
!      spin_lattice=tspin_lattice
!                        endif
       enddo
       close(97)
!      print*, before,' before'
                     endif    ! -------=== } process id =0


       deallocate(spin_lattice)
       deallocate(tspin_lattice)

       time_end=MPI_WTIME()
       if(myid == 0) then     ! -------=== { process id =0
       write(6,'(4(f14.5,1x,a))') (time_end-time_start),'s', (time_end-time_start)/60.d0,'m', (time_end-time_start)/3600.d0,'h', (time_end-time_start)/3600.d0/24.d0,'d'
                     endif    ! -------=== } process id =0
       call MPI_FINALIZE(ierr)
       stop
       end program d_access

