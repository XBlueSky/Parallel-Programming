/**********************************************************************
 * DESCRIPTION:
 *   Serial Concurrent Wave Equation - C Version
 *   This program implements the concurrent wave equation
 *********************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>

#define MAXPOINTS 1000000
#define MAXSTEPS 1000000
#define MINPOINTS 20
#define PI 3.14159265

void check_param(void);

void update (void);
void printfinal (void);

int nsteps,                 	/* number of time steps */
    tpoints, 	     		/* total points along string */
    rcode;                  	/* generic return code */
float  values[MAXPOINTS+2], 	/* values at time t */
       oldval[MAXPOINTS+2], 	/* values at time (t-dt) */
       newval[MAXPOINTS+2]; 	/* values at time (t+dt) */


/**********************************************************************
 *	Checks input values from parameters
 *********************************************************************/
void check_param(void)
{
   char tchar[20];

   /* check number of points, number of iterations */
   while ((tpoints < MINPOINTS) || (tpoints > MAXPOINTS)) {
      printf("Enter number of points along vibrating string [%d-%d]: "
           ,MINPOINTS, MAXPOINTS);
      scanf("%s", tchar);
      tpoints = atoi(tchar);
      if ((tpoints < MINPOINTS) || (tpoints > MAXPOINTS))
         printf("Invalid. Please enter value between %d and %d\n", 
                 MINPOINTS, MAXPOINTS);
   }
   while ((nsteps < 1) || (nsteps > MAXSTEPS)) {
      printf("Enter number of time steps [1-%d]: ", MAXSTEPS);
      scanf("%s", tchar);
      nsteps = atoi(tchar);
      if ((nsteps < 1) || (nsteps > MAXSTEPS))
         printf("Invalid. Please enter value between 1 and %d\n", MAXSTEPS);
   }

   printf("Using points = %d, steps = %d\n", tpoints, nsteps);

}

// __device__ inline unsigned global_thread_id() {
//       return blockIdx.x * blockDim.x + threadIdx.x;
// }
/**********************************************************************
 *     Initialize points on line
 *********************************************************************/
 __global__ void init_line(float *gpuValue, float *gpuOldval, int tpoints)
{
    unsigned id = blockIdx.x * blockDim.x + threadIdx.x;
    /* Calculate initial values based on sine curve */
    gpuValue[id] = sin((2.0 * PI) * ((float)id / (float)(tpoints - 1))); 
    gpuOldval[id] = sin((2.0 * PI) * ((float)id / (float)(tpoints - 1))); 
}

/**********************************************************************
 *     Update all values along line a specified number of times
 *********************************************************************/
 __global__ void update(float *gpuValue, float *gpuOldval, float *gpuNewval, int nsteps, int tpoints)
{
   int i;
   unsigned id = blockIdx.x * blockDim.x + threadIdx.x;
   /* Update values for each time step */
   for (i = 1; i<= nsteps; i++) {
    /* Update points along line for this time step */
        /* global endpoints */
        if ((id == 0) || (id  == tpoints - 1))
            gpuNewval[id] = 0.0;
        else
            gpuNewval[id] = 1.82 * gpuValue[id] - gpuOldval[id];

        /* Update old values with new values */
        gpuOldval[id] = gpuValue[id];
        gpuValue[id] = gpuNewval[id];
   }
}

/**********************************************************************
 *     Print final results
 *********************************************************************/
void printfinal()
{
   int i;

   for (i = 0; i < tpoints; i++) {
      printf("%6.4f ", values[i]);
      if (i%10 == 0)
         printf("\n");
   }
}

/**********************************************************************
 *	Main program
 *********************************************************************/
int main(int argc, char *argv[])
{
	sscanf(argv[1],"%d",&tpoints);
	sscanf(argv[2],"%d",&nsteps);
    check_param();
    float *gpuValue, *gpuOldval, *gpuNewval;

    cudaMalloc(&gpuValue, sizeof(values));
    cudaMalloc(&gpuOldval, sizeof(values));
    cudaMalloc(&gpuNewval, sizeof(values));

	printf("Initializing points on the line...\n");
    init_line<<<((tpoints + 1023) >> 10), 1024>>>(gpuValue, gpuOldval, tpoints);
    cudaMemcpy(values, gpuValue, sizeof(values), cudaMemcpyDeviceToHost);
    cudaMemcpy(oldval, gpuOldval, sizeof(values), cudaMemcpyDeviceToHost);

    printf("Updating all points for all time steps...\n");
	update<<<((tpoints + 1023) >> 10), 1024>>>(gpuValue, gpuOldval, gpuNewval, nsteps, tpoints);
    cudaMemcpy(values, gpuValue, sizeof(values), cudaMemcpyDeviceToHost);

    printf("Printing final results...\n");
	printfinal();
	printf("\nDone.\n\n");
	
	return 0;
}