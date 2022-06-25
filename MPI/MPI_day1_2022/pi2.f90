!234567890
!      Written by In-Ho Lee, KRISS, February, 2011
       program pi_parallel
       implicit none
       include 'mpif.h'
       integer ierr,kount,iroot
       integer i,jdum,kdum,nn,iseed1,iseed2,ij,kl
       real*8 tmp,tmr,r,x,y, t1,t2
       real*8 tmp0,tmr0
       real ranmar
       integer myid,nproc
       integer istart,ifinish,n1,n2

       call MPI_INIT( ierr )
       call MPI_COMM_RANK( MPI_COMM_WORLD, myid, ierr )
       call MPI_COMM_SIZE( MPI_COMM_WORLD, nproc, ierr )
       if(myid == 0 .and. nproc > 1) print *,  nproc," processes are alive"
       if(myid == 0 .and. nproc ==1) print *,  nproc," process is alive"

       t1=MPI_Wtime()

       if(myid == 0) then     ! -------=== { process id =0
       iseed1=11
       iseed2=22
       nn=100

       read(5,*) nn
       read(5,*) iseed1,iseed2
                     endif    ! -------=== } process id =0
       iroot=0 ; kount=1
       call MPI_BCAST(nn, kount,MPI_INTEGER,iroot,MPI_COMM_WORLD,ierr)
       call MPI_BCAST(iseed1, kount,MPI_INTEGER,iroot,MPI_COMM_WORLD,ierr)
       call MPI_BCAST(iseed2, kount,MPI_INTEGER,iroot,MPI_COMM_WORLD,ierr)

       tmp=0.d0
       tmr=0.d0

       n1=1
       n2=nn
       call equal_load(n1,n2,nproc,myid,istart,ifinish)
!      print*, istart,ifinish
!      do i=1,nn
       do i=istart,ifinish

       ij=iseed1 +i      ; kl=iseed2
       ij=mod(ij, 31328 +1) ; kl=mod(kl, 30081 +1) 
!      print*, ij,kl
       call rmarin(ij,kl)

       do jdum=1,1000
       do kdum=1,1000

       x=ranmar()-0.5
       y=ranmar()-0.5
       r=sqrt(x*x+y*y)
       tmr=tmr+1.d0
       if(r < 0.5d0) then
       tmp=tmp+1.d0
                     endif

       enddo
       enddo
       enddo
       t2=MPI_Wtime()
       iroot=0 ; kount=1
       call MPI_REDUCE(tmp,tmp0,kount,MPI_DOUBLE_PRECISION,MPI_SUM,iroot,MPI_COMM_WORLD,ierr)
       call MPI_REDUCE(tmr,tmr0,kount,MPI_DOUBLE_PRECISION,MPI_SUM,iroot,MPI_COMM_WORLD,ierr)


       if(myid == 0) then     ! -------=== { process id =0
       print*, tmp0/tmr0*4.d0
       print*, t2-t1
                     endif    ! -------=== } process id =0

       call MPI_FINALIZE(ierr)
       stop
       end program pi_parallel

      subroutine rmarin(ij,kl)
!  This subroutine and the next function generate random numbers. See 
!  the comments for SA for more information. The only changes from the 
!  orginal code is that (1) the test to make sure that RMARIN runs first 
!  was taken out since SA assures that this is done (this test didn't 
!  compile under IBM's VS Fortran) and (2) typing ivec as integer was 
!  taken out since ivec isn't used. With these exceptions, all following 
!  lines are original. 

! This is the initialization routine for the random number generator 
!     RANMAR()
! NOTE: The seed variables can have values between:    0 <= IJ <= 31328
!                                                      0 <= KL <= 30081
      real u(97), c, cd, cm
      integer i97, j97
      common /raset1/ u, c, cd, cm, i97, j97
      if( ij .lt. 0  .or.  ij .gt. 31328  .or.  &
          kl .lt. 0  .or.  kl .gt. 30081 ) then
          print '(a)', ' The first random number seed must have a value  &
    & between 0 and 31328'
          print '(a)',' The second seed must have a value between 0 and  &
    & 30081'
            stop
      endif
      i = mod(ij/177, 177) + 2
      j = mod(ij    , 177) + 2
      k = mod(kl/169, 178) + 1
      l = mod(kl,     169)
      do 2 ii = 1, 97
         s = 0.0
         t = 0.5
         do 3 jj = 1, 24
            m = mod(mod(i*j, 179)*k, 179)
            i = j
            j = k
            k = m
            l = mod(53*l+1, 169)
            if (mod(l*m, 64) .ge. 32) then
               s = s + t
            endif
            t = 0.5 * t
 3       continue
         u(ii) = s
 2    continue
      c = 362436.0 / 16777216.0
      cd = 7654321.0 / 16777216.0
      cm = 16777213.0 /16777216.0
      i97 = 97
      j97 = 33
      return
      end
      function ranmar()
      real u(97), c, cd, cm
      integer i97, j97
      common /raset1/ u, c, cd, cm, i97, j97
         uni = u(i97) - u(j97)
         if( uni .lt. 0.0 ) uni = uni + 1.0
         u(i97) = uni
         i97 = i97 - 1
         if(i97 .eq. 0) i97 = 97
         j97 = j97 - 1
         if(j97 .eq. 0) j97 = 97
         c = c - cd
         if( c .lt. 0.0 ) c = c + cm
         uni = uni - c
         if( uni .lt. 0.0 ) uni = uni + 1.0
         ranmar = uni
      return
      end
       subroutine equal_load(n1,n2,nproc,myid,istart,ifinish)
!      Written by In-Ho Lee, KRISS, September (2006)
       implicit none
       integer nproc,myid,istart,ifinish,n1,n2
       integer iw1,iw2
       iw1=(n2-n1+1)/nproc ; iw2=mod(n2-n1+1,nproc)
       istart=myid*iw1+n1+min(myid,iw2)
       ifinish=istart+iw1-1 ; if(iw2 > myid) ifinish=ifinish+1
!      print*, n1,n2,myid,nproc,istart,ifinish
       if(n2 < istart) ifinish=istart-1
       return
       end

