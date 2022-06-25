/****************************************************/
/* MSG2.0 C functions and wallclock timer           */
/* written by Andrei Malevsky, version May 16, 1997 */
/* 

   Reaord of changes for this version:

   two functions (MSG_SAVE_ARRAY and MSG_RESTORE_ARRAY) have
   been added April 7, 1997; 
   the wrappers for MSG_TSETUP and MSG_TP_SETUP 
   have been added
   and the function MSG_RESTORE_ARRAY has been modified
   April 22, 1997; 
   include <stdlib.h> was added May 16, 1997 
*/

#include <stdio.h>
#include <sys/time.h>
#include <stdlib.h>

#define MAX_TIMERS 16 
/* define names of the timer functions */
#ifdef _CSPP
#define MSG_TIMER_CLEAR msg_timer_clear
#define MSG_TIMER_START msg_timer_start
#define MSG_TIMER_STOP msg_timer_stop
#define MSG_TIMER msg_timer
#define MSG_SAVE_ARRAY msg_save_array
#define MSG_RESTORE_ARRAY msg_restore_array
#define MSG_TSETUP msg_tsetup
#define MSG_TSETUP_INT msg_tsetup_int
#define MSG_TP_SETUP msg_tp_setup
#define MSG_TP_SETUP_INT msg_tp_setup_int
#else
#ifdef _CRAY
#define MSG_TIMER_CLEAR MSG_TIMER_CLEAR
#define MSG_TIMER_START MSG_TIMER_START
#define MSG_TIMER_STOP MSG_TIMER_STOP
#define MSG_TIMER MSG_TIMER
#define MSG_SAVE_ARRAY MSG_SAVE_ARRAY
#define MSG_RESTORE_ARRAY MSG_RESTORE_ARRAY
#define MSG_TSETUP MSG_TSETUP
#define MSG_TSETUP_INT MSG_TSETUP_INT
#define MSG_TP_SETUP MSG_TP_SETUP
#define MSG_TP_SETUP_INT MSG_TP_SETUP_INT
#else
#define MSG_TIMER_CLEAR msg_timer_clear_
#define MSG_TIMER_START msg_timer_start_
#define MSG_TIMER_STOP msg_timer_stop_
#define MSG_TIMER msg_timer_
#define MSG_SAVE_ARRAY msg_save_array_
#define MSG_RESTORE_ARRAY msg_restore_array_
#define MSG_TSETUP msg_tsetup_
#define MSG_TSETUP_INT msg_tsetup_int_
#define MSG_TP_SETUP msg_tp_setup_
#define MSG_TP_SETUP_INT msg_tp_setup_int_

#endif
#endif

struct timeval start_tp[MAX_TIMERS] ;
struct timeval current_tp[MAX_TIMERS] ;
double myclock[MAX_TIMERS] ;
int *StorePtr; 

void MSG_TSETUP(numproc,myproc,ptrn,
                grid_size,proc_size,overlap,ifp,
                nproc,proc,ipr,index,sfa,pfa,ier)
int *numproc, *myproc, *ptrn,
    *grid_size, *proc_size, *overlap, *ifp,
    *nproc, *proc, *ipr, *index, *sfa, *pfa, *ier;
{
   int nbytes, *gc_ld, *gc_eid, *la_size, *eid_s;
   nbytes = *numproc * 6 * sizeof(int);
   gc_ld = (int *) malloc(nbytes);
   gc_eid = (int *) malloc(nbytes);
   nbytes = *numproc * 3 * sizeof(int);
   la_size = (int *) malloc(nbytes);
   eid_s = (int *) malloc(nbytes);
   MSG_TSETUP_INT(numproc,myproc,ptrn,
                grid_size,proc_size,overlap,ifp,
                nproc,proc,ipr,index,sfa,pfa,ier,
                gc_ld, gc_eid, la_size, eid_s);
   free(gc_ld);
   free(gc_eid);
   free(gc_eid);
   free(la_size);
   free(eid_s);
}


void MSG_TP_SETUP(la_size, eid_s, gc_ld, gc_eid,
                  numproc, myproc, nproc, proc, ipr, index,
                  sfa, pfa, ier)
int *la_size, *eid_s, *gc_ld, *gc_eid,
    *numproc, *myproc, *nproc, *proc, *ipr, *index,
    *sfa, *pfa, *ier;
{
   int nbytes, *Periodic;
   nbytes = *numproc * 3 * sizeof(int);
   Periodic = (int *) malloc(nbytes);
   MSG_TP_SETUP_INT(la_size, eid_s, gc_ld, gc_eid,
                    numproc, myproc, nproc, proc, ipr, index,
                    sfa, pfa, ier, Periodic);
   free(Periodic);
}
 

void MSG_SAVE_ARRAY (Array, ArraySize)
int *Array, *ArraySize;
{
   int nbytes, i, *TmpPtr, *ArrayPtr;
   
   nbytes = *ArraySize * sizeof(int);
   StorePtr = (int *) malloc(nbytes);
   TmpPtr = StorePtr;
   ArrayPtr = Array;
   for (i=0; i<*ArraySize; i++) 
   {
    *TmpPtr = *ArrayPtr;
    TmpPtr++; ArrayPtr++;
   }
}

void MSG_RESTORE_ARRAY (Array, ArraySize)
int *Array, *ArraySize;
{
   int i, *TmpPtr, *ArrayPtr;
   TmpPtr = StorePtr;
   ArrayPtr = Array;
   for (i=0; i<*ArraySize; i++) 
   {
    *ArrayPtr = *TmpPtr;
    TmpPtr++; ArrayPtr++;
   }
   free (StorePtr);
}
 
void MSG_TIMER_CLEAR (timer)
int *timer;
{
     int res ;
     if ( *timer < 0 || *timer > MAX_TIMERS )
     {fprintf(stderr,"Wrong timer specified:%d\n",*timer);exit(1);}
     myclock[*timer] = 0.0;
     
}


void MSG_TIMER_START (timer)
int *timer;
{
     int res ;
     if ( *timer < 0 || *timer > MAX_TIMERS ) 
     {fprintf(stderr,"Wrong timer specified:%d\n",*timer);exit(1);}
     res = gettimeofday( &start_tp[*timer] , NULL ) ;
     if ( res<0 ) 
     {fprintf(stderr,"Bad gettimeofday at start_wallclock_timer\n");exit(1);}
#ifdef _DEBUG
     printf("timer: %d\n",*timer);
     printf("start_tp.tv_sec  = %ld\n",start_tp[*timer].tv_sec );
     printf("start_tp.tv_usec = %ld\n",start_tp[*timer].tv_usec );
#endif

}

void MSG_TIMER_STOP (timer)
int *timer;
{
     int res ;
     double a , b ;
     if ( *timer < 0 || *timer > MAX_TIMERS ) 
     {fprintf(stderr,"Wrong timer specified:%d\n",*timer);exit(1);}
     res = gettimeofday( &current_tp[*timer] , NULL ) ;
     if ( res<0 ) 
     {fprintf(stderr,"Bad gettimeofday at stop_wallclock_timer\n");exit(1);}
     a = (double) (current_tp[*timer].tv_sec) * 1e6
         + (double) current_tp[*timer].tv_usec ;
     b = (double) (start_tp[*timer].tv_sec  ) * 1e6
         + (double) start_tp[*timer].tv_usec ;
     a = (a - b) * 1e-6 ;
     myclock[*timer] += a;
#ifdef _DEBUG
     printf("timer: %d\n",*timer);
     printf("current_tp.tv_sec  = %ld\n",current_tp[*timer].tv_sec  );
     printf("current_tp.tv_usec = %ld\n",current_tp[*timer].tv_usec );
#endif

}

double MSG_TIMER (timer)
int *timer;
{
    if ( *timer < 0 || *timer > MAX_TIMERS )
    {fprintf(stderr,"Wrong timer specified:%d\n",*timer);exit(1);}
    return myclock[*timer];
 
}

/*  -------------------- test -------------------------------- */
#ifdef _DEBUG
main()
{ 
  double tribble ;
  int timer = MAX_TIMERS;

  MSG_TIMER_CLEAR (&timer) ;
  MSG_TIMER_START (&timer) ;
  sleep ( 5 ) ;
  MSG_TIMER_STOP (&timer) ;
  sleep ( 7 ) ;
  MSG_TIMER_START (&timer) ;
  sleep ( 3 ) ;
  MSG_TIMER_STOP (&timer) ;

  tribble = MSG_TIMER (&timer);
  printf("Elapsed time should be about 8 seconds, is reported to be %f\n", 
  tribble );

}

#endif 

