cmake_minimum_required(VERSION 3.9)

project(CUWC LANGUAGES CUDA CXX)

add_executable(cuwc main.cu kernels.cuh)

