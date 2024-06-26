#!/bin/bash
#SBATCH --job-name=cholla       # Job name
#SBATCH --partition=gpuq  # Partition name
#SBATCH --account=gpuq    # Account name
#SBATCH --ntasks=160            # Number of MPI ranks
#SBATCH --nodes=4               # Total number of nodes requested
#SBATCH --exclusive             # Prevent other jobs from running on a node
#SBATCH --ntasks-per-node=40    # How many tasks on each node
#SBATCH --time=24:00:00         # Time limit (hh:mm:ss)
#SBATCH --output=concat_%j.log  # Standard output and error log

module load python37

export NUM=1
python3 concat_3d_data.py -s data/$NUM -o data/$NUM --dtype float32 -n 2 -c $NUM
python3 concat_particles.py -s data/$NUM -o data/$NUM --dtype float32 -n 2 -c $NUM
