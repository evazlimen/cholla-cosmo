#!/bin/bash -l
#SBATCH -J CS_2048_50Mpc
#SBATCH -N 64
#SBATCH -t 2:00:00
#SBATCH -A AST206
#SBATCH -o CS_2048_50Mpc.o%j


#-- set CHOLLA location
CHOLLA_HOME=/ccs/home/[username]/github/cholla

EXECUTABLE=${CHOLLA_HOME}/bin/cholla.cosmology.frontier
source ${CHOLLA_HOME}/builds/setup.frontier.cce.sh

export MPICH_ALLTOALL_SYNC_FREQ=2
export MPICH_OFI_CXI_COUNTER_REPORT=2
export OMP_NUM_THREADS=7

env &> job.environ
scontrol show hostnames > job.nodes
ldd $EXECUTABLE > job.exec.ldd

srun -u -N 64 -n 512 -c 7 --gpu-bind=closest --gpus-per-task=1 \
$EXECUTABLE param.txt |& tee STDOUT

#srun -u -N 64 -n 512 -c 7 --gpu-bind=closest --gpus-per-task=1 \
#$EXECUTABLE param.txt init=Read_Grid indir=./data/167/ outdir=./data/ nfile=167 |& tee STDOUT

