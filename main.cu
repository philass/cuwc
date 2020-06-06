#include <iostream>
#include <fstream>
#include <unistd.h>
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
  if (argc == 1) {
    std::cout << "Missing arguments" << std::endl;
    return 0;
  }
  int opt;
  bool get_c = false, get_w = false, get_l = false;
  while ((opt = getopt(argc, argv, "cwl")) != -1) {
    switch (opt) {
      case 'c': get_c = true; break;
      case 'w': get_w = true; break;
      case 'l': get_l = true; break;
      default: 
        fprintf(stderr, "Usage: %s [-cwl] [file...]\n", argv[0]);
        exit(EXIT_FAILURE);
    }
  }
  if (optind == 1) get_c = get_w = get_l = true;

  // READ FILE
  FILE *fp;
  fp = fopen (argv[optind], "rb");
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
  std::cout << argv[optind] << std::endl;
  return 0;
}

