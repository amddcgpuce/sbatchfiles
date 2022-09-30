#!/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=2
#SBATCH --cpus-per-task=8
#SBATCH --mem=64GB
#SBATCH --gres=gpu:2
#SBATCH -o %x-%N-%j.err
#SBATCH -e %x-%N-%j.out

source /etc/profile.d/modules.sh
module load rocm/5.2.3

tmp=/tmp/$USER/gpu2-$$
mkdir -p $tmp

# Example with MPI: STMV Benchmark
mkdir -p $tmp/stmv
singularity run /shared/apps/bin/gromacs.sif tar -xvf /benchmarks/stmv/stmv.tar.gz -C $tmp/stmv 1>/dev/null
singularity run /shared/apps/bin/gromacs.sif mpirun -np 4 gmx_mpi mdrun -pin on -nsteps 100000 -resetstep 90000 -ntomp 16 -noconfout -nb gpu -bonded cpu -pme gpu -npme 1 -v -nstlist 200 -gpu_id 01 -s $tmp/stmv/topol.tpr -g $tmp/stmv/md.log -e $tmp/stmv/ener.eder -cpo $tmp/stmv/state.cpt

# Do the clean-up
/bin/rm -rf $tmp
