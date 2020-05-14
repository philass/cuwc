#include <iostream>
#include <fstream>
#include <string>
#include <cuda_runtime.h>
#include "kernels.cu.h"

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

  std::string firstFile = argv[fileStarts];
  std::ifstream in(firstFile);
  std::string contents((std::istreambuf_iterator<char>(in)), 
  std::istreambuf_iterator<char>());
  int file_length = contents.length();
  const char* string = contents.c_str();

  //char string[] = "this \n is \n a \n \n test \ntew";
  //int vals[10] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
  size_t mem_size = sizeof(char) * file_length;
  char* d_in;
  int* d_out;
  cudaMalloc((void**)&d_in, mem_size);
  cudaMalloc((void**)&d_out, mem_size);
  cudaMemcpy(d_in, string, mem_size, cudaMemcpyHostToDevice);
  reduce0<<<1, 512 >>>(d_in, d_out);
  cudaDeviceSynchronize();
  int* h_out = (int*) malloc(sizeof(int) * 10);
  cudaMemcpy(h_out, d_out, mem_size, cudaMemcpyDeviceToHost);
  std::cout << h_out[0] << " " << firstFile << std::endl;
  std::cout << h_out[1] << std::endl;
  std::cout << h_out[2] << std::endl;
  std::cout << h_out[3] << std::endl;
}

