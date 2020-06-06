#include <iostream>
#include <fstream>
#include <string>
#include <cuda_runtime.h>
#include "kernels.cuh"



int main(int argc, char *argv[]) {
  int fileStarts;
  if (argc == 1) {
    std::cout << "Missing arguments" << std::endl;
    return 0;
  }
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

  // READ FILE
  FILE *fp;
  std::string firstFile = argv[fileStarts];
  fp = fopen (argv[fileStarts], "rb");
  char* string = NULL;
  size_t len;
  ssize_t file_length = getdelim( &string, &len, '\0', fp);
  // Check if file reading failed
  if (file_length == -1) {
    std::cout << "Couldn't read file!" << std::endl;
    return 1;
  }

  // Make GPU allocations
  size_t mem_size = sizeof(char) * file_length;
  char* d_in;
  int* d_out;
  cudaMalloc((void**)&d_in, mem_size);
  cudaMalloc((void**)&d_out, mem_size);

  // Copy to GPU Memory
  cudaMemcpy(d_in, string, mem_size, cudaMemcpyHostToDevice);

  // Call Kernel
  int numBlocks = file_length / 1024 + 1;
  reduce0<<<numBlocks, 1024 >>>(d_in, d_out);
  cudaDeviceSynchronize();
  
  // Get the result in host memory
  int* h_out = (int*) malloc(sizeof(int) * 10);
  cudaMemcpy(h_out, d_out, mem_size, cudaMemcpyDeviceToHost);
  
  // Sum the results from different blocks
  int sum;
  for (int i = 0; i < numBlocks; i++) {
    sum += h_out[i];
  }

  // Print the results
  if (get_l) std::cout << sum << " " << firstFile << std::endl;
}

