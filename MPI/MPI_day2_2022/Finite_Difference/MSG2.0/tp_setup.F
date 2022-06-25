c________________________________________________________________
c
c
c      Message-Passing Toolkit for Structured Grid Communications 
c
c                 Grid Setup Routines and Utilities 
c
c---------------------------------------------------------------
c
c   Contents:
c-----------
c
c
c   MSG_tsetup_int - sets up the data structures necessary for 
c                  tensor-product grid communications for the
c                  simple case when the embedding local array
c                  consits exactly of the local data segment plus
c                  the same overlap for every processor.
c
c   MSG_tp_setup_int - sets up the arrays of pointers to boundary data;
c                  these arrays will be used by MSG_tbdx_gather and
c                  MSG_tbdx_scatter.
c                  MSG_tp_setup now allows to specify an increment
c                  to exchange data within arrays having a serial
c                  first axis; this option was added to handle
c                  the interleaved memory storage mode. 
c
c   written by A. Malevsky, version  May 16, 1997.
c
c   record of changes for this version:
c
c     MSG_tsetup_int and MSG_tp_setup_int exit immediately 
c     if the number of processors is one (May 16, 1997).
c     
c________________________________________________________________
c
c

      subroutine MSG_tsetup_int(numproc,myproc,ptrn,
     *                      grid_size,proc_size,overlap,ifp, 
     *                      nproc,proc,ipr,index,sfa,pfa,ier,
     *                      gc_ld, gc_eid, la_size, eid_s)
      implicit none
      integer numproc, nproc, myproc, ptrn, sfa, pfa, ier,
     *        grid_size(3),proc_size(3),overlap(3),ifp(3),
     *        proc(*),ipr(*),index(*), 
     *        gc_ld(*), gc_eid(*), la_size(*), eid_s(*)
c-----------------------------------------------------------------------
c
c     sets up the local tables to be used by the boundary exchange
c     routines
c
c
c arguments:
c------------
c
c     numproc = number of processors or number of subdomains (input)
c
c     myproc  = my processor number (numbered from 1 to numproc) (input)
c
c     ptrn    = this argument was left for compatibility 
c               with the MSG 1.1 
c
c     grid_size = dimensions of the global grid (input)
c 
c     proc_size = number of processors allocated in each direction (input)
c
c     overlap   = length of an overlapping interval 
c                 in each direction (input)
c
c     ifp   = 1 if there is a periodic boundary and 0 if not (input)
c
c     nproc = number of adjacent processors (output)
c
c     proc  = handle to the list of adjacent processors (output)
c
c     ipr   = handle to the list of pointers to data segments (output) 
c
c     index = handle to the list of indices (output) 
c
c     sfa   = dimension of the first (serial) axis
c
c     pfa   = position of the element in the first axis
c
c     ier   = return code:
c                            0  --  successful completion
c                           -5  --  wrong number of processors
c
c     gc_ld = work array of size 6*numproc
c
c     gc_eid  = work array of size 6*numproc
c
c     la_size = work array of size 3*numproc
c
c     eid_s   = work array of size 3*numproc
c
c
c-----------------------------------------------------------------------
c
c     local variables
      ier =0
      if(numproc.eq.1) return
      if(proc_size(1)*proc_size(2)*proc_size(3).ne.numproc) then
         ier = -5
         return
      endif
c
c     create a discription of the computational grid
c
      call MSG_set_grid(gc_ld,gc_eid,numproc,ifp,
     *                  grid_size,proc_size,overlap)
c
c     set the local array geometry
c
      call MSG_set_local_geometry(la_size,eid_s,gc_ld,gc_eid,
     *                            grid_size,numproc,overlap,ifp)
c
c     set up the index tables
c
      nproc = 0
      call MSG_tp_setup(la_size,eid_s,gc_ld,gc_eid,numproc,
     *                  myproc,nproc,proc,ipr,index,sfa,pfa,ier)
      return
      end


 
      subroutine MSG_tp_setup_int(la_size, eid_s, gc_ld, gc_eid,
     &                        numproc, myproc, nproc, proc, ipr, index,
     &                        sfa, pfa, ier, Periodic)
      implicit none
      integer numproc, nproc, myproc, sfa, pfa, ier
      integer la_size(3,numproc), gc_ld(6,numproc), gc_eid(6,numproc), 
     *        eid_s(3,numproc), proc(*), ipr(*), index(*), 
     *        Periodic(3,numproc) 
c-----------------------------------------------------------------------
c
c     MSG_tp_setup sets up the local tables to be used by 
c     the boundary exchange routines
c
c                           version 2.0
c
c arguments:
c------------
c
c     numproc = number of processors or number of subdomains (input)
c
c     la_size(axis,processor) = dimensions of the local arrays
c               for every processor (input)
c   
c     eid_s(axis,processor)  = index of the first elements of EID 
c               within the local array (input)
c
c     gc_ld =   global coordinates of the local data
c               segment (LD) for every processor or every subdomain;
c               two numbers per axis define the local data segment: the 
c               index of first element and the index of last element 
c               which belongs to this processor (input).
c
c     gc_eid  = global coordinates of the data segment which consist of
c               both the local data and the external interface data (EID);
c               this array has the same format as gc_ld (input). 
c  
c     myproc  = my processor number (numbered from 1 to numproc)
c          
c     nproc = number of adjacent processors (input/output)
c
c     proc  = array of size nproc+1 (at least); it contains the list
c             of neighboring processors (input/output)
c
c     ipr   = array of size 2*nproc+1 (at least); it contains the 
c             pointers to each segment in the buffer (input/output)
c
c     index = array of size two times the number of boundary elements
c             for my processor (input/output) 
c
c     sfa   = dimension of the first (serial) axis
c
c     pfa   = position of the element in the first axis
c
c     ier   = return code:
c                            0  --  successful completion
c                           -1  --  number of adjacent processors
c                                   is larger than the allowed
c                                   maximun MAX_PROCS
c                           -6  --  eid_s is not within the local array
c
c     Periodic = work array os size 3*numproc
c
c-----------------------------------------------------------------------
c
c   Algorithm:
c             
c     for every axis:
c
c        1. find the right and left neighbors
c           if there are none go to next axis
c        2. set the index table to gather the outgoing data
c           if the outgoing segment is contiguous set its 
c           first entry in index to -index
c        3. set the index table to scatter the incoming data
c           if the incoming segment is contiguous set its 
c           first entry in index to -index 
c        4. update the global coordinates of local data (gc_ld)
c           of all the processors according the parameters
c           of the shift for this axis 
c           to incorporate the incoming segments of data
c     
c-----------------------------------------------------------------------
c
c     local variables
c
      include 'geom_param_fort.h'
      integer iproc, axis, j, k, MyProcIndex(3), ProcGridSize(3), 
     *        LastGlobalIndex(3), FirstGlobalIndex(3), old_nproc,
     *        first_proc
      logical ArraySaved, IfEven(3), MSG_shift_in_trouble
      external MSG_shift_in_trouble
c
      ier =0
      if(numproc.eq.1) return
      if(nproc.ge.MAX_PROCS) then
        ier = -1
        return
      endif
c
c     find the dimensions of the global grid
c
      ipr(1) = 1
      first_proc = nproc
      do j=1,3
         LastGlobalIndex(j) = -999999 
         FirstGlobalIndex(j) = 999999 
         k = 2*j
         do iproc=1,numproc
            if(eid_s(j,iproc).gt.la_size(j,iproc).or.
     &         eid_s(j,iproc).lt.0) then
               ier = -6
               return
            endif
            if(LastGlobalIndex(j).le.gc_ld(k,iproc))
     &         LastGlobalIndex(j) = gc_ld(k,iproc)
            if(FirstGlobalIndex(j).ge.gc_ld(k-1,iproc))
     &         FirstGlobalIndex(j) = gc_ld(k-1,iproc)
         enddo
      enddo
      ArraySaved = .false. 
c
c     find the periodicity pattern for every processor
c
      call MSG_set_periodicity(numproc, gc_eid, gc_ld, Periodic)
c
c     find is my processor's index is even or odd
c     for every axis
c
      call MSG_even_odd(gc_ld, myproc, numproc, IfEven, 
     &                  MyProcIndex, ProcGridSize)
c
c     set the tables for a "series of shifts" data transfer
c
      do axis=1,3
         old_nproc = nproc
         call MSG_set_tindex(la_size, eid_s, gc_ld, gc_eid,
     &        numproc, myproc, nproc, proc, ipr, index, sfa, pfa,
     &        IfEven(axis), FirstGlobalIndex, LastGlobalIndex,
     &        MyProcIndex, ProcGridSize, Periodic, axis, ier)
         if(ier.lt.0) return
         call MSG_set_tindex(la_size, eid_s, gc_ld, gc_eid,
     &        numproc, myproc, nproc, proc, ipr, index, sfa, pfa,
     &        .not.IfEven(axis), FirstGlobalIndex, LastGlobalIndex,
     &        MyProcIndex, ProcGridSize, Periodic, axis, ier)
         if(ier.lt.0) return
c
c        update the coordinates of local data of all the processors
c        according to the parameters of the shift along the current
c        axis 
c
         if(old_nproc.lt.nproc.and.axis.ne.3) then
            if(.not.ArraySaved) then
c             save the array gc_ld
              k = 6*numproc
              call MSG_SAVE_ARRAY(gc_ld, k)
              ArraySaved = .true.
            endif
            do iproc=1,numproc
              gc_ld(2*axis-1, iproc) = gc_eid(2*axis-1, iproc)
              gc_ld(2*axis, iproc) = gc_eid(2*axis, iproc)
            enddo
         endif
      enddo
      if(ArraySaved) then
c       restore the array gc_ld
        k = 6*numproc
        call MSG_RESTORE_ARRAY(gc_ld, k)
      endif
c
c     check if there is a potential
c     trouble with the "series of shift" data transfer
c
      if(first_proc.eq.0) then
         if(MSG_shift_in_trouble(nproc, ipr,
     &      gc_eid(1,myproc), gc_ld(1,myproc),
     &      FirstGlobalIndex, LastGlobalIndex, 
     &      Periodic(1,myproc))) then 
c
c           set the tables for a "all to all" data transfer
c
            nproc = 0
            call MSG_all(la_size, eid_s, gc_ld, gc_eid,
     &        numproc, myproc, nproc, proc, ipr, index, sfa, pfa,
     &        MyProcIndex, ProcGridSize, Periodic, IfEven,
     &        FirstGlobalIndex, LastGlobalIndex, ier)
c
c           mark the type of transfer
c
            proc(1) = -proc(1)
         endif
      endif
c
      return
      end


      subroutine MSG_all(la_size, eid_s, gc_ld, gc_eid,
     &           numproc, myproc, nproc, proc, ipr, index, sfa, pfa, 
     &           MyProcIndex, ProcGridSize, Periodic, IfEven,
     &           FirstGlobalIndex, LastGlobalIndex, ier)
      implicit none
      integer myproc, numproc, nproc, sfa, pfa, ier
      integer proc(*), MyProcIndex(3), ProcGridSize(3), 
     &        Periodic(3,numproc), FirstGlobalIndex(3),
     &        LastGlobalIndex(3), ipr(*), index(*),
     &        la_size(3,numproc), gc_ld(6,numproc), gc_eid(6,numproc), 
     &        eid_s(3,numproc) 
      logical IfEven(3)
      include 'geom_param_fort.h'
c----------------------------------------------------------------------
c
c     local data 
      integer axis, i, j, k, his_k, his_j, his_i, iproc, HisEID(6),
     &        HisLD(6),  MyEID(6), MyLD(6), first(3), last(3), step(3),
     &        PeriodicShift(3)
      logical MSG_intersect, IfEIDLD, IfLDEID
      external MSG_intersect
c
      ier = 0
      call MSG_to_contiguous(MyLD, gc_ld(1,myproc),
     &     FirstGlobalIndex, LastGlobalIndex, Periodic(1,myproc))
      call MSG_to_contiguous(MyEID, gc_eid(1,myproc),
     &     FirstGlobalIndex, LastGlobalIndex, Periodic(1,myproc))
c
      do axis=1,3
         PeriodicShift(axis) = LastGlobalIndex(axis) -
     &                         FirstGlobalIndex(axis) + 1
         if(IfEven(axis)) then
            first(axis) = -1
            last(axis) = 1
            step(axis) = 1 
         else
            first(axis) = 1
            last(axis) = -1
            step(axis) = -1
         endif
      enddo
c 
      do k=first(3),last(3),step(3)
         his_k = MyProcIndex(3)+k
         if(Periodic(3,myproc).eq.-1.and.his_k.lt.1) 
     &      his_k=ProcGridSize(3) 
         if(Periodic(3,myproc).eq.1.and.his_k.gt.ProcGridSize(3)) 
     &      his_k=1
         if(his_k.gt.0.and.his_k.le.ProcGridSize(3)) then
         do j=first(2),last(2),step(2)
            his_j = MyProcIndex(2)+j
            if(Periodic(2,myproc).eq.-1.and.his_j.lt.1) 
     &         his_j=ProcGridSize(2)
            if(Periodic(2,myproc).eq.1.and.his_j.gt.ProcGridSize(2)) 
     &         his_j=1
            if(his_j.gt.0.and.his_j.le.ProcGridSize(2)) then
            do i=first(1),last(1),step(1)
               his_i = MyProcIndex(1)+i
               if(Periodic(1,myproc).eq.-1.and.his_i.lt.1) 
     &            his_i=ProcGridSize(1)
               if(Periodic(1,myproc).eq.1.and.his_i.gt.ProcGridSize(1))
     &            his_i=1
               if(his_i.gt.0.and.his_i.le.ProcGridSize(1)) then
                  iproc = (his_k-1)*ProcGridSize(2)*ProcGridSize(1)+
     &                    (his_j-1)*ProcGridSize(1)+
     &                     his_i
                  if(iproc.ne.myproc) then
                  call MSG_to_contiguous(HisLD, gc_ld(1,iproc), 
     &                 FirstGlobalIndex, LastGlobalIndex, 
     &                 Periodic(1,iproc)) 
                  call MSG_to_contiguous(HisEID, gc_eid(1,iproc),
     &                 FirstGlobalIndex, LastGlobalIndex, 
     &                 Periodic(1,iproc))
                  do axis=1,3
                     if(Periodic(axis,myproc).eq.-1.and.
     &                  Periodic(axis,iproc).eq.1) then
                        HisEID(2*axis) = HisEID(2*axis) - 
     &                                   PeriodicShift(axis)
                        HisEID(2*axis-1) = HisEID(2*axis-1) -
     &                                   PeriodicShift(axis)
                        HisLD(2*axis) = HisLD(2*axis) -
     &                                   PeriodicShift(axis)
                        HisLD(2*axis-1) = HisLD(2*axis-1) -
     &                                   PeriodicShift(axis)
                     endif  
                     if(Periodic(axis,myproc).eq.1.and.
     &                  Periodic(axis,iproc).eq.-1) then 
                        HisEID(2*axis) = HisEID(2*axis) + 
     &                                   PeriodicShift(axis) 
                        HisEID(2*axis-1) = HisEID(2*axis-1) +
     &                                   PeriodicShift(axis)
                        HisLD(2*axis) = HisLD(2*axis) +
     &                                   PeriodicShift(axis)
                        HisLD(2*axis-1) = HisLD(2*axis-1) +
     &                                   PeriodicShift(axis)
                     endif
                  enddo 
c
c                 find out if my EID has an intersection with the
c                 other processor's LD or the other processor's EID
c                 has intersection with my LD
c
                  IfEIDLD = 
     &               MSG_intersect(MyEid(1),MyEid(2),HisLD(1),HisLD(2))
     &               .and.
     &               MSG_intersect(MyEid(3),MyEid(4),HisLD(3),HisLD(4))
     &               .and.
     &               MSG_intersect(MyEid(5),MyEid(6),HisLD(5),HisLD(6))
                  IfLDEID =
     &               MSG_intersect(HisEid(1),HisEid(2),MyLD(1),MyLD(2))
     &               .and.
     &               MSG_intersect(HisEid(3),HisEid(4),MyLD(3),MyLD(4))
     &               .and.
     &               MSG_intersect(HisEid(5),HisEid(6),MyLD(5),MyLD(6))
                  if(IfEIDLD.or.IfLDEID) then
c
c                      add the processor to the list of neighbors
c
                       nproc = nproc + 1
                       if(nproc.gt.MAX_PROCS) then
                         ier = -1
                         return
                       else
                         proc(nproc) = iproc
                       endif
c
c                      set the index table to gather the outgoing data
c
                      call MSG_set_outgoing(
     &                la_size(1,iproc),eid_s(1,iproc),
     &                gc_ld(1,iproc),gc_eid(1,iproc),
     &                la_size(1,myproc),eid_s(1,myproc),
     &                gc_ld(1,myproc),gc_eid(1,myproc), 
     &                FirstGlobalIndex,LastGlobalIndex,
     &                Periodic(1,iproc), Periodic(1,myproc),
     &                nproc,ipr,index,sfa,pfa)
c
c                     set the index table to scatter the incoming data
c
                      call MSG_set_incoming(
     &                la_size(1,iproc),eid_s(1,iproc),
     &                gc_ld(1,iproc),gc_eid(1,iproc),
     &                la_size(1,myproc),eid_s(1,myproc),
     &                gc_ld(1,myproc),gc_eid(1,myproc),
     &                FirstGlobalIndex,LastGlobalIndex,
     &                Periodic(1,iproc), Periodic(1,myproc), 
     &                nproc,ipr,index,sfa,pfa)
c
                 endif
                 endif
               endif
            enddo
            endif
         enddo
         endif
      enddo
c
      return
      end


      subroutine MSG_set_periodicity(numproc, gc_eid, gc_ld, Periodic)
      implicit none
      integer numproc
      integer gc_eid(6,numproc), gc_ld(6,numproc), Periodic(3,numproc)
c
c     find the periodicity pattern for every processor
c
      integer iproc, axis, my_first, my_last
      do iproc=1,numproc
         do axis=1,3
            my_first = gc_eid(2*axis-1, iproc)
            my_last  = gc_eid(2*axis, iproc)
            if(my_first.gt.my_last) then
c              subdomain has a periodic boundary
               if(my_first.gt.gc_ld(2*axis-1, iproc)) then
                  Periodic(axis, iproc) = -1
               else
                  Periodic(axis, iproc) = 1
               endif
            else
               Periodic(axis, iproc) = 0
            endif
         enddo
      enddo
      return
      end


      subroutine MSG_set_tindex(la_size, eid_s, gc_ld, gc_eid,
     &           numproc, myproc, nproc, proc, ipr, index, sfa, pfa,
     &           IfLeft, FirstGlobalIndex, LastGlobalIndex,
     &           MyProcIndex, ProcGridSize, Periodic, axis, ier)
      implicit none
      integer numproc, nproc, myproc, sfa, pfa, axis, ier
      integer la_size(3,numproc), gc_ld(6,numproc), gc_eid(6,numproc), 
     &        eid_s(3,numproc), proc(*), ipr(*), index(*), 
     &        Periodic(3, numproc), FirstGlobalIndex(3), 
     &        LastGlobalIndex(3), MyProcIndex(3), ProcGridSize(3) 
      logical IfLeft
c----------------------------------------------------------------------
c
c     local data
      include 'geom_param_fort.h'
      integer iproc, his_a(3), my_eid_first, my_eid_last, 
     &        his_eid_first, his_eid_last,
     &        my_ld_first, my_ld_last, 
     &        his_ld_first, his_ld_last 
      logical MSG_intersect
      external MSG_intersect
c
      ier = 0
      my_ld_first = gc_ld(2*axis-1, myproc)
      my_ld_last  = gc_ld(2*axis, myproc)
      my_eid_first   = gc_eid(2*axis-1, myproc)
      my_eid_last    = gc_eid(2*axis, myproc)
      if(IfLeft) then
c       check my left EID only
         if(Periodic(axis,myproc).eq.-1) then
c           my subdomain has a periodic left boundary
            my_eid_last = LastGlobalIndex(axis)
         else
            my_eid_last = gc_ld(2*axis-1, myproc) - 1
         endif
      else
c       check my right EID only
         if(Periodic(axis,myproc).eq.1) then
c           my subdomain has a periodic right boundary
            my_eid_first = FirstGlobalIndex(axis)
         else
            my_eid_first = gc_ld(2*axis, myproc) + 1
         endif
      endif
      his_a(3) = MyProcIndex(3)
      his_a(2) = MyProcIndex(2)
      his_a(1) = MyProcIndex(1)
      if(IfLeft) then
        his_a(axis) = MyProcIndex(axis) - 1
        if(his_a(axis).le.0) then
           if(Periodic(axis,myproc).ne.-1) return
           his_a(axis) = ProcGridSize(axis)
        endif
      else
        his_a(axis) = MyProcIndex(axis) + 1
        if(his_a(axis).gt.ProcGridSize(axis)) then
           if(Periodic(axis,myproc).ne.1) return
           his_a(axis) = 1
        endif
      endif 
      iproc = (his_a(3)-1)*ProcGridSize(2)*ProcGridSize(1)+
     &        (his_a(2)-1)*ProcGridSize(1)+
     &         his_a(1)
      his_ld_first  = gc_ld(2*axis-1, iproc)
      his_ld_last   = gc_ld(2*axis, iproc)
      his_eid_first   = gc_eid(2*axis-1, iproc)
      his_eid_last    = gc_eid(2*axis, iproc)
      if(IfLeft) then
c        check his right EID only
         if(Periodic(axis,iproc).eq.1) then
c           his subdomain has a periodic right boundary
            his_eid_first = FirstGlobalIndex(axis)
         else
            his_eid_first = gc_ld(2*axis, iproc) + 1
         endif
      else
c        check his left EID only
         if(Periodic(axis,iproc).eq.-1) then
c           his subdomain has a periodic left boundary
            his_eid_last = LastGlobalIndex(axis)
         else
            his_eid_last = gc_ld(2*axis-1, iproc) - 1
         endif
      endif
      if(MSG_intersect
     &  (my_eid_first,my_eid_last,his_ld_first,his_ld_last)
     &   .or.
     &   MSG_intersect
     &  (his_eid_first,his_eid_last,my_ld_first,my_ld_last)) then 
c
c        add the processor to the list of neighbors
c
         nproc = nproc + 1
         if(nproc.gt.MAX_PROCS) then
            ier = -1
            return
         else
            proc(nproc) = iproc
         endif
c
c        set the index table to gather the outgoing data
c
         call MSG_set_outgoing(
     &                la_size(1,iproc),eid_s(1,iproc),
     &                gc_ld(1,iproc),gc_eid(1,iproc),
     &                la_size(1,myproc),eid_s(1,myproc),
     &                gc_ld(1,myproc),gc_eid(1,myproc), 
     &                FirstGlobalIndex,LastGlobalIndex,
     &                Periodic(1,iproc), Periodic(1,myproc),
     &                nproc,ipr,index,sfa,pfa)
c
c               set the index table to scatter the incoming data
c
         call MSG_set_incoming(
     &                la_size(1,iproc),eid_s(1,iproc),
     &                gc_ld(1,iproc),gc_eid(1,iproc),
     &                la_size(1,myproc),eid_s(1,myproc),
     &                gc_ld(1,myproc),gc_eid(1,myproc),
     &                FirstGlobalIndex,LastGlobalIndex,
     &                Periodic(1,iproc), Periodic(1,myproc), 
     &                nproc,ipr,index,sfa,pfa)
c
      endif
      return
      end

 
      subroutine MSG_set_incoming(his_las, his_eid_s, 
     *                            his_ld, his_eid,
     *                            my_las, my_eid_s, 
     *                            my_ld, my_eid,
     *                            FirstGlobalIndex, LastGlobalIndex,
     *                            HisPeriodic, MyPeriodic,
     *                            nproc, ipr, index, sfa, pfa)
      implicit none
      integer his_ld(6), his_eid(6), my_ld(6), my_eid(6),
     *        his_las(3), my_las(3), his_eid_s(3), my_eid_s(3),
     *        FirstGlobalIndex(3), LastGlobalIndex(3),
     *        HisPeriodic(3), MyPeriodic(3), 
     *        nproc, ipr(*), index(*), sfa, pfa
c     local data
      integer i, j, ix, iy, iz, gix, giy, giz 
      integer MyGlobalOffset(3), ss, 
     &        HisEID(6), HisLD(6), MyEID(6), MyLD(6),
     &        PeriodicShift(3), my_eid_f(3)

      logical IfCont
c
      j = ipr(2*nproc) - 1
      ss = 0 
c
c     translate the segment's boundaries into
c     contiguous coordinates
c
      call MSG_to_contiguous(HisLD, his_ld, 
     &     FirstGlobalIndex, LastGlobalIndex, HisPeriodic) 
      call MSG_to_contiguous(HisEID, his_eid,
     &     FirstGlobalIndex, LastGlobalIndex, HisPeriodic)
      call MSG_to_contiguous(MyLD, my_ld,
     &     FirstGlobalIndex, LastGlobalIndex, MyPeriodic)
      call MSG_to_contiguous(MyEID, my_eid,
     &     FirstGlobalIndex, LastGlobalIndex, MyPeriodic)
      do i=1,3
         MyGlobalOffset(i) = MyEID(2*i-1) - my_eid_s(i)
         my_eid_f(i) = my_eid_s(i) + MyEID(2*i) - MyEID(2*i-1) 
         PeriodicShift(i)=LastGlobalIndex(i)-FirstGlobalIndex(i)+1
      enddo
c
c     find all intersection of his LD and my EID
c
      do iz=my_eid_s(3),my_eid_f(3)
         giz = iz + MyGlobalOffset(3)
         if(HisPeriodic(3).eq.-1.and.giz.gt.LastGlobalIndex(3))
     &      giz = giz - PeriodicShift(3)
         if(HisPeriodic(3).eq.1.and.giz.lt.FirstGlobalIndex(3))
     &      giz = giz + PeriodicShift(3)
         if(giz.ge.HisLD(5).and.giz.le.HisLD(6)) then
         do iy=my_eid_s(2),my_eid_f(2)
            giy = iy + MyGlobalOffset(2)
            if(HisPeriodic(2).eq.-1.and.giy.gt.LastGlobalIndex(2))
     &      giy = giy - PeriodicShift(2)
            if(HisPeriodic(2).eq.1.and.giy.lt.FirstGlobalIndex(2))
     &      giy = giy + PeriodicShift(2)
            if(giy.ge.HisLD(3).and.giy.le.HisLD(4)) then
            do ix=my_eid_s(1),my_eid_f(1)
               gix = ix + MyGlobalOffset(1)
               if(HisPeriodic(1).eq.-1.and.gix.gt.LastGlobalIndex(1))
     &            gix = gix - PeriodicShift(1)
               if(HisPeriodic(1).eq.1.and.gix.lt.FirstGlobalIndex(1))
     &            gix = gix + PeriodicShift(1)
               if(gix.ge.HisLD(1).and.gix.le.HisLD(2)) then
c
c                 add this element to the list
c
                  j = j + 1
                  index(j) = (iz-1)*my_las(1)*my_las(2)*sfa+
     *                       (iy-1)*my_las(1)*sfa+
     *                       (ix-1)*sfa+pfa
                  ss = ss + 1
               endif
            enddo
            endif
         enddo
         endif
      enddo
c
c     set the pointer to the next processor's segment
c
      ipr(2*nproc+1) = ipr(2*nproc) + ss
#ifndef BUFFER_ALWAYS
c
c     if the data segment is contiguous set the indicator:
c     a negative first index of a segment would indicate
c     that this segment is contigous and will be given
c     to the communication routines in place (no buffering)
c    
      if(ss.gt.1) then 
         IfCont = .true.
         j = ipr(2*nproc) + 1
         do while(j.lt.ipr(2*nproc+1).and.IfCont)
            IfCont = index(j).eq.(index(j-1)+1)
            j = j + 1
         enddo
         if(IfCont) index(ipr(2*nproc)) = -index(ipr(2*nproc))
      endif
#endif
      return
      end


      subroutine MSG_set_outgoing(his_las, his_eid_s, 
     *                            his_ld, his_eid,
     *                            my_las, my_eid_s, 
     *                            my_ld, my_eid,
     *                            FirstGlobalIndex, LastGlobalIndex,
     *                            HisPeriodic, MyPeriodic,
     *                            nproc, ipr, index, sfa, pfa)
      implicit none
      integer his_ld(6), his_eid(6), my_ld(6), my_eid(6),
     *        his_las(3), my_las(3), his_eid_s(3), my_eid_s(3),
     *        FirstGlobalIndex(3), LastGlobalIndex(3),
     *        HisPeriodic(3), MyPeriodic(3), 
     *        nproc, ipr(*), index(*), sfa, pfa
c     local data
      integer lc1, lc2, lc3, ix, iy, iz, gix, giy, giz, j, i 
      integer HisGlobalOffset(3), MyLocalOffset(3), ss,
     &        HisEID(6), HisLD(6), MyEID(6), MyLD(6),
     &        PeriodicShift(3), his_eid_f(3)
      logical IfCont
c
      j = ipr(2*nproc-1) - 1 
      ss = 0
c
c     translate the segment's boundaries into
c     contiguous coordinates
c
      call MSG_to_contiguous(HisLD, his_ld, 
     &     FirstGlobalIndex, LastGlobalIndex, HisPeriodic) 
      call MSG_to_contiguous(HisEID, his_eid,
     &     FirstGlobalIndex, LastGlobalIndex, HisPeriodic)
      call MSG_to_contiguous(MyLD, my_ld,
     &     FirstGlobalIndex, LastGlobalIndex, MyPeriodic)
      call MSG_to_contiguous(MyEID, my_eid,
     &     FirstGlobalIndex, LastGlobalIndex, MyPeriodic)
      do i=1,3
         HisGlobalOffset(i) = HisEID(2*i-1) - his_eid_s(i)
         MyLocalOffset(i) = my_eid_s(i) - MyEid(2*i-1) 
         his_eid_f(i) = his_eid_s(i) + HisEID(2*i) - HisEID(2*i-1) 
         PeriodicShift(i)=LastGlobalIndex(i)-FirstGlobalIndex(i)+1
      enddo
c
c     find all intersection of his EID and my LD
c
      do iz=his_eid_s(3),his_eid_f(3)
         giz = iz + HisGlobalOffset(3)
         if(MyPeriodic(3).eq.-1.and.giz.gt.LastGlobalIndex(3))
     &      giz = giz - PeriodicShift(3)
         if(MyPeriodic(3).eq.1.and.giz.lt.FirstGlobalIndex(3))
     &      giz = giz + PeriodicShift(3)
         if(giz.ge.MyLD(5).and.giz.le.MyLD(6)) then
         lc3 = giz + MyLocalOffset(3)
         do iy=his_eid_s(2),his_eid_f(2)
            giy = iy + HisGlobalOffset(2)
            if(MyPeriodic(2).eq.-1.and.giy.gt.LastGlobalIndex(2))
     &      giy = giy - PeriodicShift(2)
            if(MyPeriodic(2).eq.1.and.giy.lt.FirstGlobalIndex(2))
     &      giy = giy + PeriodicShift(2)
            if(giy.ge.MyLD(3).and.giy.le.MyLD(4)) then
            lc2 = giy + MyLocalOffset(2) 
            do ix=his_eid_s(1),his_eid_f(1)
               gix = ix + HisGlobalOffset(1)
               if(MyPeriodic(1).eq.-1.and.gix.gt.LastGlobalIndex(1))
     &            gix = gix - PeriodicShift(1)
               if(MyPeriodic(1).eq.1.and.gix.lt.FirstGlobalIndex(1))
     &            gix = gix + PeriodicShift(1)
               if(gix.ge.MyLD(1).and.gix.le.MyLD(2)) then
               lc1 = gix +  MyLocalOffset(1)
c
c                    add this element to the list
c
                     j = j + 1
                     index(j) = (lc3-1)*my_las(1)*my_las(2)*sfa+
     *                          (lc2-1)*my_las(1)*sfa+
     *                          (lc1-1)*sfa+pfa 
                     ss = ss + 1               
               endif
            enddo
            endif
         enddo
         endif
      enddo
c
c     set the pointer to the incoming segment
c
      ipr(2*nproc) = ipr(2*nproc-1) + ss
#ifndef BUFFER_ALWAYS
c
c     if the data segment is contiguous set the indicator:
c     a negative first index of a segment would indicate 
c     that this segment is contiguous and will be given
c     to the communication routines in place (no buffering)
c    

      if(ss.gt.1) then
         IfCont = .true.
         j = ipr(2*nproc-1) + 1
         do while(j.lt.ipr(2*nproc).and.IfCont)
            IfCont = index(j).eq.(index(j-1)+1)
            j = j + 1
         enddo
         if(IfCont) index(ipr(2*nproc-1)) = -index(ipr(2*nproc-1)) 
      endif
#endif
      return
      end



      subroutine MSG_to_contiguous(ContSegment, NonContSegment,
     &           FirstGlobalIndex, LastGlobalIndex, Periodic)
c
c     utility function to translate noncontiguous coordinates
c     of a given segment into contiguous coordinates
c
      implicit none
      integer ContSegment(6), NonContSegment(6),  Periodic(3),
     &        FirstGlobalIndex(3), LastGlobalIndex(3)
      integer axis
c
      do axis=1,3
         if(NonContSegment(2*axis-1).le.NonContSegment(2*axis)) then
c           the segment is not on a periodic boundary
            ContSegment(2*axis-1) = NonContSegment(2*axis-1)
            ContSegment(2*axis) = NonContSegment(2*axis)
         else
           
           if(Periodic(axis).eq.-1) then
c              left periodic boundary
               ContSegment(2*axis-1) = NonContSegment(2*axis-1) -
     &                                 LastGlobalIndex(axis) +
     &                                 FirstGlobalIndex(axis) - 1
               ContSegment(2*axis) = NonContSegment(2*axis) 
           else
c              right periodic boundary
               ContSegment(2*axis-1) = NonContSegment(2*axis-1) 
               ContSegment(2*axis) = NonContSegment(2*axis) +
     &                               LastGlobalIndex(axis) -
     &                               FirstGlobalIndex(axis) + 1
           endif
         endif         
      enddo
      return
      end


      subroutine MSG_even_odd(gc_ld, myproc, numproc, IfEven,
     &                        MyProcIndex, ProcGridSize)
c
c     utility function to find the indices of my processor
c     on the grid of processors, the processor grid size
c     and establish if the indices of my processor are even orr odd 
c
      implicit none
      integer myproc, numproc
      integer gc_ld(6, numproc), MyProcIndex(3), ProcGridSize(3)
      logical IfEven(3)
c     local data
      integer NL, NR, axis, slice, MyIndex, iproc
      do axis = 1, 3
c        
c        find the numbers of subdomaines 
c        on the left side and on the right side of my processor
c
         NL = 0
         NR = 0
         do iproc = 1,numproc
            if(gc_ld(2*axis-1,iproc).lt.gc_ld(2*axis-1,myproc))
     &         NL = NL + 1
            if(gc_ld(2*axis-1, iproc).gt.gc_ld(2*axis-1,myproc))
     &         NR = NR + 1
         enddo
         slice = numproc - NL - NR
         MyIndex = NL/slice + 1
         MyProcIndex(axis) = MyIndex
         ProcGridSize(axis) = numproc/slice 
         if(MOD(MyIndex,2).eq.0) then
            IfEven(axis) = .true.
         else
            IfEven(axis) = .false.
         endif
      enddo
      return
      end


      logical function MSG_intersect 
     &                 (my_first, my_last, his_first, his_last)
c
c     utility function to find if two intervals have an intersection
c
      implicit none
      integer i,my_first,my_last,his_first,his_last
      MSG_intersect = .false.
      do i=my_first, my_last
         if(i.ge.his_first.and.i.le.his_last) then
            MSG_intersect = .true. 
            return
         endif
      enddo 
      return
      end


      subroutine MSG_set_grid(gc_ld,gc_eid,numproc,if_periodic,
     *                        grid_size,proc_size,overlap)
      implicit none
      integer numproc
      integer gc_ld(6,numproc), gc_eid(6,numproc), 
     *        if_periodic(3), overlap(3), proc_size(3), grid_size(3)
      integer j, ix, iy, iz, nlx, nly, nlz, iproc
      nlx = grid_size(1)/proc_size(1)
      nly = grid_size(2)/proc_size(2)
      nlz = grid_size(3)/proc_size(3)
      do ix=1,proc_size(1)
         do iy=1,proc_size(2)
            do iz=1,proc_size(3)
               iproc=(iz-1)*proc_size(1)*proc_size(2)+
     *               (iy-1)*proc_size(1)+ix
c
c              set boundaries of the local data segments
c
               gc_ld(1,iproc)=(ix-1)*nlx+1
               gc_ld(2,iproc)=ix*nlx
               gc_ld(3,iproc)=(iy-1)*nly+1
               gc_ld(4,iproc)=iy*nly
               gc_ld(5,iproc)=(iz-1)*nlz+1
               gc_ld(6,iproc)=iz*nlz
               if(ix.eq.proc_size(1).and.
     *            gc_ld(2,iproc).lt.grid_size(1)) then
                      gc_ld(2,iproc) = grid_size(1)
               endif
               if(iy.eq.proc_size(2).and.
     *            gc_ld(4,iproc).lt.grid_size(2)) then
                      gc_ld(4,iproc) = grid_size(2)
               endif
               if(iz.eq.proc_size(3).and.
     *            gc_ld(6,iproc).lt.grid_size(3)) then
                      gc_ld(6,iproc) = grid_size(3)
               endif
c
c              set boundaries of the external interface segments
c
               do j=1,3
                  gc_eid(2*j-1,iproc)=gc_ld(2*j-1,iproc)-overlap(j)
                  gc_eid(2*j,iproc)=gc_ld(2*j,iproc)+overlap(j)
                  if(gc_eid(2*j-1,iproc).le.0) then
                     if(if_periodic(j).ne.0) then 
                        gc_eid(2*j-1,iproc)=grid_size(j)-overlap(j)+1
                     else
                        gc_eid(2*j-1,iproc)=1
                     endif
                  endif
                  if(gc_eid(2*j,iproc).gt.grid_size(j)) then
                     if(if_periodic(j).ne.0) then
                        gc_eid(2*j,iproc)=overlap(j)
                     else
                        gc_eid(2*j,iproc)=grid_size(j)
                     endif 
                  endif 
               enddo 
            enddo
         enddo
      enddo
      return
      end


      subroutine MSG_set_local_geometry(la_size,eid_s,gc_ld,gc_eid,
     *                                  grid_size,numproc,overlap,ifp)
      implicit none
      integer numproc
      integer la_size(3,numproc), gc_ld(6,numproc), gc_eid(6,numproc),
     *        eid_s(3,numproc), grid_size(3), overlap(3), ifp(3)
      integer iproc, j
c
c     local array dimensions are all equal to local grid size + overlap 
c
      do iproc=1,numproc
         la_size(1,iproc)=1+gc_ld(2,iproc)-gc_ld(1,iproc)+2*overlap(1)
         la_size(2,iproc)=1+gc_ld(4,iproc)-gc_ld(3,iproc)+2*overlap(2)
         la_size(3,iproc)=1+gc_ld(6,iproc)-gc_ld(5,iproc)+2*overlap(3) 
         do j=1,3
            if(gc_ld(2*j-1,iproc).eq.1.and.ifp(j).ne.1) then
               eid_s(j,iproc) = overlap(j)+1   
            else
               eid_s(j,iproc) = 1 
            endif
         enddo
c------------------------------------------------------------------
c
c        this code should be used instead if the dimensions of 
c        a local array are equal to the size of EID segment for
c        all the processors 
c
c        call MSG_local_grid_size(gc_ld(1,iproc),gc_eid(1,iproc),
c    *                            grid_size,la_size(1,iproc))
c        eid_s(1,iproc) = 1
c        eid_s(2,iproc) = 1
c        eid_s(3,iproc) = 1
c-------------------------------------------------------------------
      enddo 
      return
      end



      subroutine MSG_local_grid_size(gc_ld,gc_eid,grid_size,lgs)
      implicit none
      integer gc_ld(6),gc_eid(6),grid_size(3),lgs(3)
c
c    utility subroutine; finds the size of EID+LD segment
c
c     local variables
c
      integer overlap, cf, cl, j
      do j=1,3
         cf = 2*j-1
         cl = 2*j
         if(gc_eid(cf).le.gc_eid(cl)) then
c
c           regular (interior) case
c
            lgs(j) = gc_eid(cl) - gc_eid(cf) + 1
         else
c
c           periodic case
c
            if(gc_eid(cf).gt.gc_ld(cf)) then
c 
c              left boundary
c
               overlap = grid_size(j) - gc_eid(cf) + 1
               lgs(j) = gc_eid(cl) - gc_ld(cf) + 1 + overlap
            else
c
c              right boundary
c
               overlap = gc_eid(cl)
               lgs(j) = gc_ld(cl) - gc_eid(cf) + 1 + overlap 
            endif    
         endif 
      enddo
      return
      end

