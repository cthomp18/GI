INC=-I$(EIGEN3_INCLUDE_DIR)
CC=g++

all:	
	$(CC) -O3 $(INC) -g -fopenmp -openmp -o trace *.cpp
