#include <stdio.h>
#include <cuda_runtime.h>

// Kernel to execute the loop
__global__ void loopKernel(int iterations) {
    for (int i = 0; i < iterations; i++) {
        printf("");
    }
}

int main(int argc, char* argv[]) {
    if (argc != 3) {
        printf("Usage: %s <number_of_iterations> <number_of_runs>\n", argv[0]);
        return 1;
    }

    int iterations = atoi(argv[1]);
    int runs = atoi(argv[2]);

    // Initialize CUDA events
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    // Warm-up run
    loopKernel<<<1, 1>>>(iterations);
    cudaDeviceSynchronize();

    float totalMilliseconds = 0;

    for (int i = 0; i < runs; i++) {
        // Record the start event
        cudaEventRecord(start);

        // Launch the kernel
        loopKernel<<<1, 1>>>(iterations);

        // Record the stop event
        cudaEventRecord(stop);

        // Synchronize and calculate the elapsed time
        cudaEventSynchronize(stop);
        float milliseconds = 0;
        cudaEventElapsedTime(&milliseconds, start, stop);

        totalMilliseconds += milliseconds;
    }

    // Calculate the average time
    float averageMilliseconds = totalMilliseconds / runs;

    // Print the average elapsed time
    printf("Average time for loop with %d iterations over %d runs: %f milliseconds\n", iterations, runs, averageMilliseconds);

    // Clean up CUDA events
    cudaEventDestroy(start);
    cudaEventDestroy(stop);

    return 0;
}