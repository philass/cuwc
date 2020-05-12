#include <iostream>
#include <cuda_runtime.h>
#include "kernels.cu.h"

/*__global__ void reduce(int *input, int *output, unsigned int n)
{
    // Determine this thread's various ids
    unsigned int block_size = blockDim.x;
    unsigned int thread_id = threadIdx.x;
    unsigned int block_id = blockIdx.x;

    // Determine the number of values the threads in this block will need to operate upon
    // (remember, the last block may need fewer than the others).
    unsigned int chunk_size = (block_id * block_size * 2 + block_size * 2 > n) ? n % (block_size * 2) : block_size * 2;
    // How read the line above: if we're the last block and n is not divisible by
    // (block_size * 2), then set chunk size to the number of leftover elements, otherwise
    // set chunk_size to the usual (full) number of elements (block_size * 2)

    // Declare an array in shared memory. All threads in a block will have access to this
    // array. The size will be (chunk_size / 2), which is a maximum of 1024 / 2 = 512.
    // The reason we don't need the full chunk_size space is because we'll do an extra step
    // when we transfer our data from global to shared memory: first, we'll read half of it
    // (chunk_size / 2 elements) from global memory and store it in the shared array. Then, we'll
    // read the other half and add it into the existing values in the shared array.
    // In other words, we'll do the first step of our usual for loop in advance. 
    // This means our for loop can be run for one fewer iteration than usual.
    __shared__ int shared[512]; // Note: ideally, the size here would read chunk_size / 2,
                                  // but CUDA forces us to use a constant (512) so the compiler
                                  // can deduce how much shared memory will be required at compile time.

    // Calculate the index that this block's chunk of values starts at.
    // As last time, each thread adds 2 values, so each block adds a total of
    // block_size * 2 values.
    unsigned int block_start = block_id * block_size * 2 + thread_id;

    // Copy half the data from our chunk into shared memory, then add in the other half
    // (as described above).
    if (thread_id < chunk_size / 2)
    {
        shared[thread_id] = input[block_start] + input[block_start + chunk_size / 2];
    }
    // Since shared memory is shared by all warps running on a block (which may
    // not be synchronized), we need to sync here to make sure everybody finishes
    // the above copy before we move on.
    __syncthreads();

    // Perform the rest of the reduction, using the shared memory array.
    // Note that the starting stride is divided by 4 instead of by 2 like we've done in the past.
    // This reflects the fact that we already did one step of the
    // reduction when we copied the data to shared memory above.
    for (unsigned int stride = chunk_size / 4; stride > 0; stride /= 2)
    {
        // we may be running more threads than we need
        if (thread_id < stride)
        {
            shared[thread_id] += shared[thread_id + stride];
        }
        // still need to sync here as usual
        __syncthreads();
    }

    // Thread 0 writes this block's partial result to the output buffer.
    // This time that means we need to copy from *shared memory*
    // back to global memory.
    // The partial result will be in shared array index 0 (remember, 
    // there is a *separate* shared array allocated for each block).
    if (!thread_id)
    {
        output[block_id] = shared[0];
    }
}
*/

int main(int argc, char *argv[]) {
  int fileStarts;
  bool get_c; bool get_w; bool get_l;
  if (argv[1][0] != '-') {
    get_c = true;
    get_w = true;
    get_l = true;
    fileStarts = 1;
  } else {
    get_c = false;
    get_w = false;
    get_l = false;
    for (int i = 1; i < argc; i++) {
      if (argv[i][0] == '-') {
        int j = 1;
        while (argv[i][j] != '\0') {
          switch (argv[i][j]) {
            case 'c':
              get_c = true;
              break;
            case 'w':
              get_w = true;
              break;
            case 'l':
              get_l = true;
              break;
            default:
              std::cout << "Unrecognized option : -" << argv[i][j] << std::endl;
              return 1;
          }
          j++;
        }
      } else {
        fileStarts = i;
        break;
      }
    }
  }
  std::cout << "c, w, l -> " << get_c << " " << get_w << " " << get_l << std::endl;
  std::cout << "fileStarts -> " << fileStarts << " " << argv[fileStarts] << std::endl;
    
  char string[] = "this \n is \n a \n \n test \ntew";
  //int vals[10] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
  size_t mem_size = sizeof(char) * 33;
  char* d_in;
  int* d_out;
  cudaMalloc((void**)&d_in, mem_size);
  cudaMalloc((void**)&d_out, mem_size);
  cudaMemcpy(d_in, string, mem_size, cudaMemcpyHostToDevice);
  reduce0<<<1, 512>>>(d_in, d_out);
  cudaDeviceSynchronize();
  int* h_out = (int*) malloc(sizeof(int) * 1);
  cudaMemcpy(h_out, d_out, mem_size, cudaMemcpyDeviceToHost);
  std::cout << h_out[0] << std::endl;
}

