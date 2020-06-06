#include <cuda_runtime.h>

__global__ void reduceLines(char *g_idata, int *g_odata, int inputLength) {
  // Need to figure out if 512 is optimal
	extern __shared__ int sdata[1024];
	// each thread loads one element from global to shared mem
	unsigned int tid = threadIdx.x;
	unsigned int i = blockIdx.x*blockDim.x + threadIdx.x;

	sdata[tid] = g_idata[i] == '\n' ? 1 : 0;
	__syncthreads();
	// do reduction in shared mem
	for(unsigned int s=1; s < blockDim.x; s *= 2) {
		if (tid % (2*s) == 0) {
			sdata[tid] += sdata[tid + s];
		}
	__syncthreads();
	}
	// write result for this block to global mem
	if (tid == 0) g_odata[blockIdx.x] = sdata[0];
}

__global__ void reduceWords(char *g_idata, int *g_odata, int inputLength) {
  // Need to figure out if 512 is optimal
	extern __shared__ int sdata[1024];
	// each thread loads one element from global to shared mem
	unsigned int tid = threadIdx.x;
	unsigned int i = blockIdx.x*blockDim.x + threadIdx.x;
  if (i < inputLength) {
	  sdata[tid] = (g_idata[i] == '\n' || g_idata[i] == '\t' || g_idata[i] == ' ') && (g_idata[i+1] != '\n' && g_idata[i+1] != '\t' && g_idata[i+1] != ' ') ? 1 : 0;
  }
	__syncthreads();

	// do reduction in shared mem
	for(unsigned int s=1; s < blockDim.x; s *= 2) {
		if (tid % (2*s) == 0) {
			sdata[tid] += sdata[tid + s];
		}
	__syncthreads();
	}
	// write result for this block to global mem
	if (tid == 0) g_odata[blockIdx.x] = sdata[0];
}
