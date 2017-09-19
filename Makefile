CPPFLAGS=-g --compiler-options "-Wall \
    -Wextra -Wcast-align \
    -Wcast-qual  -Wchar-subscripts  -Wcomment \
    -Wdisabled-optimization \
    -Werror -Wno-unknown-pragmas -Wno-long-long -Wformat -Wno-unused-function -Wno-variadic-macros -Wno-unused-parameter -Wformat=2 \
    -Wformat-nonliteral -Wformat-security  \
    -Wformat-y2k \
    -Wimport  -Winit-self \
    -Winvalid-pch   \
    -Wunsafe-loop-optimizations -Wmissing-braces \
    -Wmissing-field-initializers -Wmissing-format-attribute   \
    -Wmissing-include-dirs -Wmissing-noreturn \
    -Wpacked -Wparentheses  -Wpointer-arith \
    -Wreturn-type \
    -Wsequence-point -Wsign-compare  -Wstack-protector \
    -Wstrict-aliasing -Wstrict-aliasing=2 -Wswitch \
    -Wswitch-enum -Wtrigraphs  -Wuninitialized \
    -Wunreachable-code -Wunused \
    -Wunused-label \
    -Wunused-value  -Wunused-variable \
    -Wvolatile-register-var  -Wwrite-strings"
NVFLAGS3= -O2 -ccbin g++  -m64 --ptxas-options=-v -gencode arch=compute_20,code=sm_20 -gencode arch=compute_30,code=sm_30 -gencode arch=compute_35,code=sm_35 -gencode arch=compute_37,code=sm_37 -gencode arch=compute_50,code=sm_50 -gencode arch=compute_52,code=sm_52 -gencode arch=compute_52,code=compute_52 -Xcudafe "--diag_suppress=called_function_redeclared_inline"
NVFLAGS4= -O2 -ccbin g++ -m64 -maxrregcount=32 -gencode arch=compute_20,code=sm_20 -gencode arch=compute_30,code=sm_30 -gencode arch=compute_35,code=sm_35 -gencode arch=compute_37,code=sm_37 -gencode arch=compute_50,code=sm_50 -gencode arch=compute_52,code=sm_52 -gencode arch=compute_52,code=compute_52 -Xcudafe "--diag_suppress=called_function_redeclared_inline"
NVFLAGS2= -O2 -ccbin g++ -m64 -gencode arch=compute_20,code=sm_20 -gencode arch=compute_30,code=sm_30 -gencode arch=compute_35,code=sm_35 -gencode arch=compute_37,code=sm_37 -gencode arch=compute_50,code=sm_50 -gencode arch=compute_52,code=sm_52 -gencode arch=compute_52,code=compute_52 -Xcudafe "--diag_suppress=called_function_redeclared_inline"
NVFLAGS5= -O2 -ccbin g++ -m64 -Xptxas="-v" -gencode arch=compute_20,code=sm_20 -gencode arch=compute_30,code=sm_30 -gencode arch=compute_35,code=sm_35 -gencode arch=compute_37,code=sm_37 -gencode arch=compute_50,code=sm_50 -gencode arch=compute_52,code=sm_52 -gencode arch=compute_52,code=compute_52 -Xcudafe "--diag_suppress=called_function_redeclared_inline"
NVFLAGS= -O2 -ccbin g++ -m64 -Xptxas="-v" -gencode arch=compute_52,code=sm_52 -Xcudafe "--diag_suppress=called_function_redeclared_inline"
CC=nvcc

CPP_SRCS := $(wildcard *.cpp)
CU_SRCS := $(wildcard *.cu)
CPP_OBJECTS= $(patsubst %.cpp, %.o, $(CPP_SRCS))
CU_OBJECTS= $(patsubst %.cu, %.o, $(CU_SRCS))

INCLUDES := -I/usr/local/cuda-8.0/samples/common/inc

all: trace

structs: otherstructs trace
	rm main.o RayTracer.o tracer.o Collision.o

otherstructs:
	rm main.o RayTracer.o tracer.o Collision.o

trace: $(CPP_OBJECTS) $(CU_OBJECTS) structs.h
	$(CC) $(CPPFLAGS) $(NVFLAGS) $(INCLUDES) -lcuda -lcudart -D GLM_FORCE_RADIANS -w -lGL -rdc=true $(CPP_OBJECTS) $(CU_OBJECTS) -o trace
	
$(CPP_OBJECTS): %.o : %.cpp
	$(CC) $(CPPFLAGS) $(NVFLAGS) $(INCLUDES) -lcuda -lcudart -D GLM_FORCE_RADIANS -w -lGL -dc $< -o $@
	
$(CU_OBJECTS): %.o : %.cu
	$(CC) $(CPPFLAGS) $(NVFLAGS) $(INCLUDES) -lcuda -lcudart -D GLM_FORCE_RADIANS -w -lGL -dc $< -o $@


clean:
	rm -rf *o trace
