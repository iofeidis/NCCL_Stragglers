#!/bin/bash

# Set environment variables
export LD_LIBRARY_PATH=nccl/build/lib
export NCCL_DEBUG=VERSION
export NCCL_ALGO=Ring

# Get the output file name from the first argument
BASE_OUTPUT_FILE=$1

# Append the current Unix time to the output file name
TIMESTAMP=$(date +%s)
OUTPUT_FILE="${BASE_OUTPUT_FILE}_${TIMESTAMP}.txt"

# Define the command to run
COMMAND="mpirun -np 2 -N 2 \
    ./nccl-tests/build/all_reduce_perf \
    -b 8M \
    -e 256M \
    -f 2 \
    -w 5 \
    -o all"

# Write configurations to the output file
{
    echo "LD_LIBRARY_PATH=$LD_LIBRARY_PATH"
    echo "NCCL_DEBUG=$NCCL_DEBUG"
    echo "NCCL_ALGO=$NCCL_ALGO"
    echo "$COMMAND"
    echo ""
} > "results/$OUTPUT_FILE"

# Run the command and append the output to the file
$COMMAND >> "results/$OUTPUT_FILE"