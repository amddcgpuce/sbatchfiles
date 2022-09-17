#!/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=20
#SBATCH --mem=64GB
#SBATCH -o %x-%N-%j.out
#SBATCH -e %x-%N-%j.err
#SBATCH --gres=gpu:1

source /etc/profile.d/modules.sh
module load rocm/5.2.3

tmp=/tmp/$USER/gpu1-$$
mkdir -p $tmp

singularity run --pwd /benchmark --writable-tmpfs /shared/apps/bin/lammps.sif /opt/lammps/tpl/openmpi/bin/mpirun -np 1 /opt/lammps/bin/lmp -k on g 1 -sf kk -pk kokkos cuda/aware on neigh full comm device neigh/qeq full newton on -v x 8 -v y 8 -v z 8 -v steps 600 -in in.lj -nocite -log /tmp/$USER/gpu1-$$/lj

singularity run --pwd /benchmark --writable-tmpfs /shared/apps/bin/lammps.sif /opt/lammps/tpl/openmpi/bin/mpirun -np 1 /opt/lammps/bin/lmp -k on g 1 -sf kk -pk kokkos cuda/aware on neigh full comm device neigh/qeq full newton on -v x 8 -v y 8 -v z 8 -v steps 300 -in in.eam -nocite -log /tmp/$USER/gpu1-$$/eam

singularity run --pwd /benchmark --writable-tmpfs /shared/apps/bin/lammps.sif /opt/lammps/tpl/openmpi/bin/mpirun -np 1 /opt/lammps/bin/lmp -k on g 1 -sf kk -pk kokkos cuda/aware on neigh half binsize 5.6 comm device neigh/qeq full newton on -v x 10 -v y 10 -v z 10 -v steps 300 -in in.tersoff -nocite -log /tmp/$USER/gpu1-$$/tersoff

singularity run --pwd /benchmark --writable-tmpfs /shared/apps/bin/lammps.sif /opt/lammps/tpl/openmpi/bin/mpirun -np 1 /opt/lammps/bin/lmp -k on g 1 -sf kk -pk kokkos cuda/aware on neigh half comm device neigh/qeq full newton on -v x 16 -v y 16 -v z 16 -v steps 300 -in in.reaxc.hns -nocite -log /tmp/$USER/gpu1-$$/reaxff

singularity run --pwd /benchmark --writable-tmpfs /shared/apps/bin/lammps.sif /opt/lammps/tpl/openmpi/bin/mpirun -np 1 /opt/lammps/bin/lmp -k on g 1 -sf kk -pk kokkos cuda/aware on neigh half comm device neigh/qeq full newton on -v steps 400 -in in.snap.exaalt -nocite -log /tmp/$USER/gpu1-$$/snap

rm -rf /tmp/$USER/gpu1-$$
