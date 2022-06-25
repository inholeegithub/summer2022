#include "stdafx.h"
#include <iostream>
#include "mpi.h"

using namespace std;

/*
The purpose of this tutorial is to show you how to transfer large amounts of data between threads.

The goal of this program is to let the user input a string, then count how many times that string appears in a text file.
For the purposes of this tutorial, the text file will be the bible, which is large enough to justify parallel computation.
It is also free to download, which is also very nice. At Supercomputingblog.com, I encourage completely free developement
environments, tools, and tutorials.
*/

#define C_MAX_NUM_LINES		32000		// define the maximum number of lines we support.
#define C_MAX_LINE_WIDTH	512			// define the maximum number of characters per line we support.


int main(int argc, char* argv[])
{

	int maxNum;

	char szSearchWord[80] = "";
	int  nTasks, rank;
    MPI_Init( &argc, &argv );
    MPI_Comm_size( MPI_COMM_WORLD, &nTasks );
    MPI_Comm_rank( MPI_COMM_WORLD, &rank );

	// When creating out buffer, we use the new operator to avoid stack overflow.
	// If you are programming in C instead of C++, you'll want to use malloc.
	// Please note that this is not the most efficient way to use memory.
	// We are sacrificing memory now in order to gain more performance later.

	int *pLineStartIndex = new int[C_MAX_NUM_LINES];	// keep track of which lines start where. Mainly for debugging
	char *pszFileBuffer = new char[C_MAX_NUM_LINES * C_MAX_LINE_WIDTH];
	int nTotalLines = 0;
	int hasData = 0;	// This helps us determine which thread read the file.
	int hasSearchWord = 0;		// which thread gets user input? Either 0 or 1
	int searchWordLength;

	if (rank == 0)
	{
		printf ("Number of threads = %d\n", nTasks);

		cout << "Please input the string you would like to search for: ";
		cin >> szSearchWord;
		
		hasSearchWord = rank;
		searchWordLength = strlen(szSearchWord);
	}

	if (rank == 0)
	{
		printf ("Thread zero is reading file\n", nTasks);
		// File I/O often takes as much time, or more time than the actual computation.
		// If you would like some exercise, modify this program so that one thread will
		// get user input, and another thread will read the file. Remember, the program
		// may be instantiated with 1 or more processors.

		char szLine[C_MAX_LINE_WIDTH];

		FILE *pFile = fopen ("bbe.txt", "rt");  // Open the file

		pLineStartIndex[0] = 0;
		while(fgets(szLine, C_MAX_LINE_WIDTH, pFile) != NULL)
		{
			strcpy(pszFileBuffer + pLineStartIndex[nTotalLines], szLine);	// copy line into our buffer

			int length = strlen(szLine);
			nTotalLines++;
			// store where the next line will start
			pLineStartIndex[nTotalLines] = pLineStartIndex[nTotalLines-1] + length + 1;
		}
		fclose(pFile);	// Close the file.
		hasData = 1;	// This thread read the data, and thus, has the data.
	}

	// Because all threads will need to know what we're searching for,
	// thread zero will have to broadcast that data to all threads.
	// Unlike the previous tutorial, we will be sending a string instead of an integer.
	// Notice how the second parameter is the length of the word + 1. This is because
	// We need to account for the '\0' at the end of the string.
	
	// Threads do not know how long the search word is, so we have to broadcast that first
	// Alternatively, we could just send all 80 possible characters. It's a tradeoff that deserves experimentation.

	
	MPI_Bcast(&searchWordLength, 1, MPI_INT, hasSearchWord, MPI_COMM_WORLD);

	// Now receive the Word. We're adding 1 to the length to allow for NULL termination.
	MPI_Bcast(szSearchWord, searchWordLength+1, MPI_CHAR, hasSearchWord, MPI_COMM_WORLD);

	// All threads now know what word we're searching for.

	// Thread zero needs to distribute data to other threads.
	// Because this is a relatively large amount of data, we SHOULD NOT send the entire dataset to all threads.
	// Instead, it's best to intelligently break up the data, and only send relevant portions to each thread.
	// Data communication is an expensive resource, and we have to minimize it at all costs.
	// This is a key concept to learn in order to make high performce applications.

 	int totalChars = 0;
	int portion = 0;
	int startNum = 0;
	int endNum = 0;
	
	if (rank == 0)
	{
		totalChars = pLineStartIndex[nTotalLines];

		portion = totalChars / nTasks;
		startNum = 0;
		endNum = portion;
		totalChars = endNum - startNum;

		for (int i=1; i < nTasks; i++)
		{
			// calculate the data for each thread.
			int curStartNum = i * portion - searchWordLength+1;
			int curEndNum = (i+1) * portion;
			if (i == nTasks-1) { curEndNum = pLineStartIndex[nTotalLines]-1;}
			if (curStartNum < 0) { curStartNum = 0; }

			// we need to send a thread the number of characters it will be receiving.
			int curLength = curEndNum - curStartNum;
			MPI_Send(&curLength, 1, MPI_INT, i, 1, MPI_COMM_WORLD);
			MPI_Send(pszFileBuffer+curStartNum, curLength, MPI_CHAR, i, 2, MPI_COMM_WORLD);
		}
	}
	else
	{
		// We are not the thread that read the file.
		// We need to receive data from whichever thread 
		MPI_Status status;
		MPI_Recv(&totalChars, 1, MPI_INT, 0,1, MPI_COMM_WORLD, &status);
		MPI_Recv(pszFileBuffer, totalChars, MPI_CHAR, 0,2, MPI_COMM_WORLD, &status);

		portion = totalChars;
		startNum = rank * portion;
		endNum = (rank + 1) * portion;
		// Thread 0 is responsible for making sure the startNum and endNum calculated here are valid.
		// This is because thread 0 tells us exactly how many characters we were send.
	}

	// Do the search
	int totalCount = 0;	// count how many matches we have

	int curIndex = 0;
	while(curIndex < endNum-startNum)
	{
		// check to see if the current letter is the start of the match word
		int match = 1;
		for (int i=0; i < searchWordLength; i++)
		{
			if (pszFileBuffer[curIndex+i] != szSearchWord[i]) {match = 0; i = searchWordLength;}
		}
		if (match == 1) totalCount++;
		curIndex++;

	}

	printf("Thread %d counted %d\n", rank, totalCount);

	// At this point, all threads need to communicate their results to thread 0.

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
			MPI_Recv(&temp, 1, MPI_INT, i,3, MPI_COMM_WORLD, &status);
			//printf("RECEIVED %d from thread %d\n", temp, i);
			totalCount += temp;
		}
	}
	else
	{
		// We are finished with the results in this thread, and need to send the data to thread 1.
		// MPI_Send(void *buf, int count, MPI_Datatype datatype, int dest, int tag, MPI_Comm comm)
		// The destination is thread 0, and the arbitrary tag we choose for now is 1.
		MPI_Send(&totalCount, 1, MPI_INT, 0, 3, MPI_COMM_WORLD);
	}

	if (rank == 0)
	{
		// Display the final calculated value
		printf("The calculated value is %d\n", totalCount);
	}

	MPI_Finalize();
	return 0;
}

