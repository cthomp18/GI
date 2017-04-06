#ifndef CUDA_HELP_H
#define CUDA_HELP_H

#pragma GCC diagnostic push  // require GCC 4.6
#pragma GCC diagnostic ignored "-Wcast-qual"

#include <cuda.h>
#include <cuda_runtime.h>
#include <thrust/host_vector.h>
#include <thrust/device_vector.h>

// CUDA and CUBLAS functions
#include <helper_functions.h>
#include <helper_cuda.h>

#pragma GCC diagnostic pop

#ifdef __CUDACC__
#define CUDA_CALLABLE __host__ __device__
#else
#define CUDA_CALLABLE
#endif

#endif
