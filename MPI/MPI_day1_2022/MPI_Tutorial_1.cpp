// MPI_Tutorial_1.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <iostream>
#include "mpi.h"

using namespace std;

/*
The goal of this program is to let the user input a number, then calculate the sum 1+2+3+....user inputted number.
The last number is included. For example, if the user inputs 100, the sum from 1 to 100 will include 100.
This program will run with as many threads as you give it, which is what all properly designed MPI applications should do.
*/

int main(int argc, char* argv[])
{

	int maxNum;

	int  nTasks, rank; 
    MPI_Init( &argc, &argv );
    MPI_Comm_size( MPI_COMM_WORLD, &nTasks );
    MPI_Comm_rank( MPI_COMM_WORLD, &rank );

	if (rank == 0)
	{
		printf ("Number of threads = %d\n", nTasks);
		do
		{
			cout << "Please input number between 0 and 50000: ";
			cin >> maxNum;
		} while(maxNum < 0 || maxNum > 50000);
	}

	MPI_Barrier(MPI_COMM_WORLD);
	
	MPI_Bcast(&maxNum, 1, MPI_INT, 0, MPI_COMM_WORLD);

	//printf("Thread %d Recieved %d\n", rank, maxNum);

	// Each thread only needs to compute a portion of the problem.
	int portion = maxNum / nTasks;

	int startNum = rank * portion;	// calculate the starting number for this thread
	int endNum = (rank + 1) * portion;	// calculate the ending number +1 for this thread
	if (rank == nTasks-1)
	{
		// if We're the last thread, then we should automatically set the ending number.
		// This is because when we divided maxNum by nTasks, there could have been a remainder left off.
		// My manually setting the ending number, we ensure that all numbers are properly computed.
		endNum = maxNum+1;
	}

	int total = 0;
	for (int i=startNum; i < endNum; i++)
	{
		total += i;
	}

	printf("Thread %d computed %d\n", rank, total);

	if (rank == 0)
	{
		// The master thread will need to receive all computations from all other threads.
		MPI_Status status;

		// MPI_Recv(void *buf, int count, MPI_Datatype datatype, int source, int tag, MPI_Comm comm, MPI_Status *status)
		// We need to go and receive the data from all other threads.
		// The arbitrary tag we choose is 1, for now.

		for (int i=1; i < nTasks; i++)
		{
			int temp;
			MPI_Recv(&temp, 1, MPI_INT, i,1, MPI_COMM_WORLD, &status);
			//printf("RECEIVED %d from thread %d\n", temp, i);
			total += temp;
		}
	}
	else
	{
		// We are finished with the results in this thread, and need to send the data to thread 1.
		// MPI_Send(void *buf, int count, MPI_Datatype datatype, int dest, int tag, MPI_Comm comm)
		// The destination is thread 0, and the arbitrary tag we choose for now is 1.
		MPI_Send(&total, 1, MPI_INT, 0, 1, MPI_COMM_WORLD);
	}

	if (rank == 0)
	{
		// Display the final calculated value
		printf("The calculated value is %d\n", total);
	}

	MPI_Finalize();
	return 0;
}

