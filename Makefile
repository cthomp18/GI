CC=g++

all:	
	$(CC) -O3 -g -w -lGL -fopenmp -openmp -o trace *.cpp
