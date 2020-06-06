#include <iostream>
#include <fstream>
#include <string>
#include <cuda_runtime.h>
#include "kernels.cuh"


int getSum(int* values, int size) {
  int sum = 0;
  for (int i = 0; i < size; i++) {
    sum += values[i];
  }
  return sum;
}


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
  int file_length = getdelim( &string, &len, '\0', fp);
  // Check if file reading failed
  if (file_length == -1) {
    std::cout << "Couldn't read file!" << std::endl;
    return 1;
  }

  int lineSum = 0;
  int wordSum = 0;
  if (get_l || get_w) {
    size_t mem_size = sizeof(char) * file_length;
    char* d_in;
    cudaMalloc((void**)&d_in, mem_size);
    cudaMemcpy(d_in, string, mem_size, cudaMemcpyHostToDevice);

    int numBlocks = file_length / 1024 + 1;
    if (get_l) {
      int* d_out_lines;
      cudaMalloc((void**)&d_out_lines, file_length * sizeof(int));
      reduceLines<<<numBlocks, 1024 >>>(d_in, d_out_lines, file_length);
      cudaDeviceSynchronize();
      int* h_out_lines = (int*) malloc(sizeof(int) * numBlocks);
      cudaMemcpy(h_out_lines, d_out_lines, mem_size, cudaMemcpyDeviceToHost);
      lineSum = getSum(h_out_lines, numBlocks);
    }
    
    if (get_w) {
      int* d_out_words;
      cudaMalloc((void**)&d_out_words, file_length * sizeof(int));
      reduceWords<<<numBlocks, 1024 >>>(d_in, d_out_words, file_length);
      cudaDeviceSynchronize();
      int* h_out_words = (int*) malloc(sizeof(int) * numBlocks);
      cudaMemcpy(h_out_words, d_out_words, mem_size, cudaMemcpyDeviceToHost);
      wordSum = getSum(h_out_words, numBlocks);
    }
  }
  
  if (get_l) std::cout << lineSum << " ";
  if (get_w) std::cout << wordSum << " ";
  if (get_c) std::cout << file_length << " ";
  std::cout << firstFile << std::endl;
 
}

