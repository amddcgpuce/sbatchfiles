#!/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=2
#SBATCH --cpus-per-task=20
#SBATCH --mem=64GB
#SBATCH -o %x-%N-%j.out
#SBATCH -e %x-%N-%j.err
#SBATCH --gres=gpu:2

source /etc/profile.d/modules.sh
module load rocm/5.2.3

tmp=/tmp/$USER/gpu2-$$
mkdir -p $tmp

singularity run --pwd /benchmark --writable-tmpfs /shared/apps/bin/lammps.sif /opt/lammps/tpl/openmpi/bin/mpirun -np 2 /opt/lammps/bin/lmp -k on g 2 -sf kk -pk kokkos cuda/aware on neigh full comm device neigh/qeq full newton on -v x 8 -v y 8 -v z 8 -v steps 600 -in in.lj -nocite -log /tmp/$USER/gpu2-$$/lj

singularity run --pwd /benchmark --writable-tmpfs /shared/apps/bin/lammps.sif /opt/lammps/tpl/openmpi/bin/mpirun -np 2 /opt/lammps/bin/lmp -k on g 2 -sf kk -pk kokkos cuda/aware on neigh full comm device neigh/qeq full newton on -v x 8 -v y 8 -v z 8 -v steps 300 -in in.eam -nocite -log /tmp/$USER/gpu2-$$/eam

singularity run --pwd /benchmark --writable-tmpfs /shared/apps/bin/lammps.sif /opt/lammps/tpl/openmpi/bin/mpirun -np 2 /opt/lammps/bin/lmp -k on g 2 -sf kk -pk kokkos cuda/aware on neigh half binsize 5.6 comm device neigh/qeq full newton on -v x 10 -v y 10 -v z 10 -v steps 300 -in in.tersoff -nocite -log /tmp/$USER/gpu2-$$/tersoff

singularity run --pwd /benchmark --writable-tmpfs /shared/apps/bin/lammps.sif /opt/lammps/tpl/openmpi/bin/mpirun -np 2 /opt/lammps/bin/lmp -k on g 2 -sf kk -pk kokkos cuda/aware on neigh half comm device neigh/qeq full newton on -v x 16 -v y 16 -v z 16 -v steps 300 -in in.reaxc.hns -nocite -log /tmp/$USER/gpu2-$$/reaxff

singularity run --pwd /benchmark --writable-tmpfs /shared/apps/bin/lammps.sif /opt/lammps/tpl/openmpi/bin/mpirun -np 2 /opt/lammps/bin/lmp -k on g 2 -sf kk -pk kokkos cuda/aware on neigh half comm device neigh/qeq full newton on -v steps 400 -in in.snap.exaalt -nocite -log /tmp/$USER/gpu2-$$/snap

rm -rf /tmp/$USER/gpu2-$$
