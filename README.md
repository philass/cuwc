# cuwc

cuwc is a Cuda implementation of the common linux word count utility wc.

# Requirements
- CUDA
- CMake

# Installation
```bash
git clone https://github.com/philass/cuwc.git
```

# Usage
First build the project by running CMake 
```bash
mkdir build && cd build
cmake ..
```
Now you can simply run cuwc
```bash
./wc -l example_file.txt
```

