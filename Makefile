CC=g++

all:	
	$(CC) -O3 -D GLM_FORCE_RADIANS -g -w -lGL -fopenmp -openmp -o trace *.cpp
