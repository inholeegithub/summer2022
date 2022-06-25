C************************************************************************
C* mpioExampleF.f:                                                      *
C* This is an example of a FORTRAN code which uses MPIO.                *
C************************************************************************
      program main
      implicit none
      include 'fMPIOTrace.h'
      include 'mpif.h'
C*    *******************************************************************
C*    * # of times to repeat write/read cycle                           *
C*    *******************************************************************
      integer NTIMES
      parameter (NTIMES=5)
C*    *******************************************************************
C*    * read/write size in bytes                                        *
C*    *******************************************************************
      integer NBYTES
      parameter (NBYTES=1024*1024*4)
      integer nprocs, myrank, i
      character*1024 str
      integer buf(NBYTES/4)
      integer fh, status(MPI_STATUS_SIZE)
      integer ierr, argc, iargc
      integer*8 offset
      call MPI_INIT(ierr)
      call MPI_COMM_SIZE(MPI_COMM_WORLD, nprocs, ierr)
      call MPI_COMM_RANK(MPI_COMM_WORLD, myrank, ierr)
C*    *******************************************************************
C*    * Pablo real-time tracing; trace output to samplef.run.nd?        *
C*    *******************************************************************
      call initmpiotrace( 'fsample.real', 12, 1 )
C*    *******************************************************************
C*    * process 0 takes the input file name as a command-line           *
C*    * argument and broadcasts it to other processes                   *
C*    *******************************************************************
      if (myrank .eq. 0) then
         argc = iargc()
         i = 0
         call getarg(i,str)
         do while ((i .lt. argc) .and. (str .ne. '-fname'))
            i = i + 1
            call getarg(i,str)
         end do
         i = i + 1
         call getarg(i,str)
         call MPI_BCAST(str, 1024, MPI_CHARACTER, 0, MPI_COMM_WORLD,
     1                  ierr)
         print*, 'Access size per process = ', NBYTES,'  bytes, ',
     1           ' NTIMES= ', NTIMES
      else
         call MPI_BCAST(str, 1024, MPI_CHARACTER, 0, MPI_COMM_WORLD,
     1                  ierr)
      end if
      offset = myrank*NBYTES
      do i=1, NTIMES
C*        ***************************************************************
C*        * open the file, seek, write, and then close                  *
C*        ***************************************************************
         call MPI_FILE_OPEN(MPI_COMM_WORLD, str,
     1                     MPI_MODE_CREATE+MPI_MODE_RDWR, MPI_INFO_NULL, 
     2                     fh, ierr)
         call MPI_FILE_SEEK(fh, offset, MPI_SEEK_SET, ierr)
         call MPI_FILE_WRITE(fh, buf, NBYTES, MPI_BYTE, status, ierr)
         call MPI_FiLE_CLOSE(fh, ierr)
C*       ****************************************************************
C*       *  wait for all nodes to close file before proceeding          *
C*       ****************************************************************
         call MPI_BARRIER(MPI_COMM_WORLD, ierr)

C*       ****************************************************************
C*       *  open the file again, seek, read, and then close             *
C*       ****************************************************************
         call MPI_FILE_OPEN(MPI_COMM_WORLD, str,
     1                     MPI_MODE_CREATE+MPI_MODE_RDWR, MPI_INFO_NULL, 
     2                     fh, ierr)
         call MPI_FILE_SEEK(fh, offset, MPI_SEEK_SET, ierr)
         call MPI_FILE_READ(fh, buf, NBYTES, MPI_BYTE, status, ierr)
         call MPI_FILE_CLOSE(fh, ierr)
C*       ****************************************************************
C*       *  wait for all nodes to close file before proceeding          *
C*       ****************************************************************
         call MPI_BARRIER(MPI_COMM_WORLD, ierr)
      end do
C*    *******************************************************************
C*    *  call this routine to wrap up MPI I/O tracing                   *
C*    *******************************************************************
      call endmpiotrace()
      call MPI_FINALIZE(ierr)
      stop
      end

