NVFLAGS=-O3 -ccbin g++ -m64 -gencode arch=compute_20,code=sm_20 -gencode arch=compute_30,code=sm_30 -gencode arch=compute_35,code=sm_35 -gencode arch=compute_37,code=sm_37 -gencode arch=compute_50,code=sm_50 -gencode arch=compute_52,code=sm_52 -gencode arch=compute_52,code=compute_52
CC=nvcc

CPP_SRCS := $(wildcard *.cpp)
CU_SRCS := $(wildcard *.cu)
CPP_OBJECTS= $(patsubst %.cpp, %.o, $(CPP_SRCS))
CU_OBJECTS= $(patsubst %.cu, %.o, $(CU_SRCS))

INCLUDES := -I/usr/local/cuda-8.0/samples/common/inc

all: trace

trace: $(CPP_OBJECTS) $(CU_OBJECTS)
	$(CC) $(NVFLAGS) $(INCLUDES) -lcuda -lcudart -D GLM_FORCE_RADIANS -g -w -lGL $(CPP_OBJECTS) $(CU_OBJECTS) -o trace
	
$(CPP_OBJECTS): %.o : %.cpp
	$(CC) $(NVFLAGS) $(INCLUDES) -lcuda -lcudart -D GLM_FORCE_RADIANS -w -lGL -dc $< -o $@
	
$(CU_OBJECTS): %.o : %.cu
	$(CC) $(NVFLAGS) $(INCLUDES) -lcuda -lcudart -D GLM_FORCE_RADIANS -w -lGL -dc $< -o $@

clean:
	rm -rf *o trace
