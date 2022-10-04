#!/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --cpus-per-task=8
#SBATCH --mem=64GB
#SBATCH --gres=gpu:8
#SBATCH -o %x-%N-%j.out
#SBATCH -e %x-%N-%j.err

source /etc/profile.d/modules.sh
module load rocm/5.2.3

logdir=$HOME/gpu8-$SLURM_JOB_ID
mkdir -p $logdir

singularity run --pwd /benchmark --writable-tmpfs /shared/apps/bin/lammps_2022.5.04_130.sif /opt/lammps/tpl/openmpi/bin/mpirun -np 8 /opt/lammps/bin/lmp -k on g 8 -sf kk -pk kokkos cuda/aware on neigh full comm device neigh/qeq full newton on -v x 8 -v y 8 -v z 8 -v steps 600 -in in.lj -nocite -log $logdir/lj

singularity run --pwd /benchmark --writable-tmpfs /shared/apps/bin/lammps_2022.5.04_130.sif /opt/lammps/tpl/openmpi/bin/mpirun -np 8 /opt/lammps/bin/lmp -k on g 8 -sf kk -pk kokkos cuda/aware on neigh full comm device neigh/qeq full newton on -v x 8 -v y 8 -v z 8 -v steps 300 -in in.eam -nocite -log $logdir/eam

singularity run --pwd /benchmark --writable-tmpfs /shared/apps/bin/lammps_2022.5.04_130.sif /opt/lammps/tpl/openmpi/bin/mpirun -np 8 /opt/lammps/bin/lmp -k on g 8 -sf kk -pk kokkos cuda/aware on neigh half binsize 5.6 comm device neigh/qeq full newton on -v x 10 -v y 10 -v z 10 -v steps 300 -in in.tersoff -nocite -log $logdir/tersoff

singularity run --pwd /benchmark --writable-tmpfs /shared/apps/bin/lammps_2022.5.04_130.sif /opt/lammps/tpl/openmpi/bin/mpirun -np 8 /opt/lammps/bin/lmp -k on g 8 -sf kk -pk kokkos cuda/aware on neigh half comm device neigh/qeq full newton on -v x 16 -v y 16 -v z 16 -v steps 300 -in in.reaxc.hns -nocite -log $logdir/reaxff

singularity run --pwd /benchmark --writable-tmpfs /shared/apps/bin/lammps_2022.5.04_130.sif /opt/lammps/tpl/openmpi/bin/mpirun -np 8 /opt/lammps/bin/lmp -k on g 8 -sf kk -pk kokkos cuda/aware on neigh half comm device neigh/qeq full newton on -v steps 400 -in in.snap.exaalt -nocite -log $logdir/snap

