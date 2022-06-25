#########################################################
##                                                     ##
##            MAKEFILE for tensor product grid         ##
##            communications                           ##
##                                                     ## 
##                 version 2.0                         ##
##               MPI/SUN cluster                       ##
##                                                     ##
#########################################################

.KEEP_STATE:

PRECISION	= SINGLE

ARCH_TYPE	= PARALLEL

FC		= f77

CC		= gcc

DEBUG		=

FFLAGS		= $(DEBUG)

FCFLAGS		= -D$(PRECISION) -D$(ARCH_TYPE) $(FFLAGS)

CFLAGS		= -D_SUN

LFLAGS		=

MSG_HOME	= $(HOME)/MSG2.0

TARGET		= jacobi2DMSG2

MSG_LIBS	= $(MSG_HOME)/mpi_msg.o \
		  $(MSG_HOME)/tp_setup.o \
		  $(MSG_HOME)/wc_timer.o

OBJ		= $(TARGET).o

LDR		= mpif77 

ARCH		= SOLARIS 

COMM		= ch_p4

default:	$(TARGET)

$(TARGET):	$(OBJ) $(MSG_LIBS)
	$(LDR) $(LFLAGS) -o $(TARGET) $(OBJ) $(MSG_LIBS)

.SUFFIXES : .F .f .c .o

.f.o : ;	mpif77 -c $*.f; $(FC) $(FFLAGS) -c $*.f	

.c.o : ;	$(CC) $(CFLAGS) -c $*.c

.F.o : ;	mpif77 -c $*.F; $(FC) $(FCFLAGS) -c $*.F

clean   :
	rm -f $(OBJ) $(TARGET) $(MSG_LIBS) mpif.h
