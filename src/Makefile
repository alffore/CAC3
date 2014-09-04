#
# Makefile 
# 
# AAFR, 2014
#

NVCC= /Developer/NVIDIA/CUDA-6.5/bin/nvcc

NVCC_OPTS=-O2 -arch=sm_12 -Xcompiler -Wall -Xcompiler -Wextra -m64

GCC_OPTS=-O3 -Wall -Wextra -m64


OBJ= main.o \
	algoritmo.o \
	algoritmo_cuda.o \
	imprimeRes.o \
	recuperaInfoL.o \
	recuperaInfoR.o \
	recuperaT.o
	 
DIR_SRC=./cuda/
DIR_BIN=./bin/


all: clean $(OBJ) 
	$(NVCC) -link -o $(DIR_BIN)cuda_cac3.exe $(OBJ)  $(NVCC_OPTS)



%.o: $(DIR_SRC)%.cu 
	$(NVCC) -c  $(NVCC_OPTS) $<



clean:
	@rm -rfv *.o	

