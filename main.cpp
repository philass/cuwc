#include <libc.h>
#include <iostream>
#include <cuda_runtime.h>

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
    
  char* string = "this \n is \n a \n \n test \ntew";
  size_t mem_size; = strlen(chararray);
  char* d_in;
  int* d_out;
  cudaMalloc((void**)&d_in, mem_size);
  cudaMalloc((void**)&d_out, mem_size);
  cudaMemcpy(d_in, string, mem_size, cudaMemcpyHostToDevice);
  lineCount<<<num_blocks, block_size>>>(d_in, d_out);
  int* h_out = (int*) malloc(mem_size);
  cudaMemcpy(h_out, d_out, mem_size, cudaMemcpyDeviceToHost);
  std::cout << h_out[0] << std::endl;
}

