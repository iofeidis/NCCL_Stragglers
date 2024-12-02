## NCCL_Stragglers

**Mitigating Stragglers in NCCL Operations**

### Introduction

This repository contains source code for benchmarking various NCCL operations in the presence of stragglers. We utilize both the official NCCL code and the provided NCCL-tests for our benchmarks, which are conducted directly on GPUs.

### Installation

1. **Introduce Artificial Delay with Busy-Waiting (for loops)**
   - First, measure how much each for loop takes to execute. Compile and execute the below script:
     ```sh
     export CUDA_HOME=/usr/local/cuda
     export PATH=${CUDA_HOME}/bin:${PATH}
     export LD_LIBRARY_PATH=${CUDA_HOME}/lib64:$LD_LIBRARY_PATH
     nvcc -o measure_loop_time measure_loop_time.cu -lcudart
     ./measure_loop_time 100 1000 # #iterations #runs
     ```

2. **Modify NCCL Operations**
   - Make any necessary changes to NCCL operations (e.g., `src/device/all_reduce.h`) or leave them as is for initial benchmarking.
   - See `example_all_reduce.h` for reference.

3. **Build NCCL Locally**
   - Follow the instructions in the [NCCL README](/nccl/README.md).
   - Currenly, one build takes ~10mins.
   - One way to work is to have the default NCCL build in the parent folder and the modified NCCL build in the child folder, so as to quickly test between them, just by adding a `..` on the library path (see `run_experiment.sh`). You can also modify the `makefiles/version.mk` to `NCCL_SUFFIX := modified`, to make sure which build is being benchmarked.

4. **Build NCCL-Tests Locally**
   - Follow the instructions in the [NCCL-Tests README](/nccl-tests/README.md).
   - Specify `NCCL_HOME` to point to your previous NCCL build:
     ```sh
     cd ../nccl-tests
     make MPI=1 NCCL_HOME=../nccl/build/nccl.h
     ```

5. Initialize empty folders:
```
cd ../
mkdir results
mkdir figures
mkdir logs
```

5. **Run Benchmarks**
   - Navigate to the root directory.
   - Refer to the NCCL-Tests README for argument details. You can experiment with the below configurations:
     - Different reduce operations: `sum`, `prod`, `max`, `min`, `avg`, `mulsum` (No Recompile Needed - NRC)
     - Different points of delay:
       - Before sending data to the next GPU part 1 (Recompile Needed - RC)
       - Before receiving and reducing (RC)
       - Before final sharing (RC)
     - Different amounts of delay: (~1us, ~10us, ~100us, ~1ms, ~10ms) (RC)
     - Different data sizes (NRC)
     - Different number of GPUs (NRC)
     - Different number of stragglers (currently only rank=0 is a straggler)
     - Different number of threads, blocking enabled, etc. (NRC)
     - Different algorithms: `Ring`, `Tree` (NRC)
     - Different collective operations: `AllReduce`, `Broadcast`, `Reduce`, `AllGather`, `ReduceScatter` (RC)

   - Modify and execute `run_experiment.sh` based on your experiment. Save the results in your folder of preference, e.g., `/results`.
     - Check the `LD_LIBRARY_PATH` environment variable to link to the correct library to be benchmarked.
     ```sh
     ./run_experiment.sh
     ```

6. **Plot Results**
   - Modify and execute `plot_experiments.py` based on your experiment. Save the results in your folder of preference, e.g., `/figures`.
     ```python
     python plot_experiments.py
     ```

### Example Usage

1. **Running an Experiment**
   - Modify `run_experiment.sh` based on your specific experiment arguments.
   - Example command to run an experiment with the result file name as argument:
     ```sh
     ./run_experiment.sh 5ms_delay.txt
     ```

2. **Plotting Results**
   - Example command to plot results:
     ```python
     python plot_experiments.py
     ```

### Additional Notes

- Ensure that the `LD_LIBRARY_PATH` is correctly set to point to the NCCL library you wish to benchmark.
- The `run_experiment.sh` script appends the current Unix time to the output file name for easy identification of different runs.
- The `plot_experiments.py` script generates plots comparing the performance of different NCCL versions based on the provided `.txt` files.