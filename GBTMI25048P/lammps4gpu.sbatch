#!/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --cpus-per-task=12
#SBATCH --mem=256GB
#SBATCH --gres=gpu:4
#SBATCH -o %x-%N-%j.out
#SBATCH -e %x-%N-%j.err

source /etc/profile.d/modules.sh

# Use partition name to load OS-specific modulespath to use to override
# login node environment
if [[ $(echo $SLURM_JOB_PARTITION | grep -i ubuntu) = *Ubuntu* ]]; then
    module use /shared/apps/modules/ubuntu/modulefiles
    module unuse /shared/apps/modules/rhel8/modulefiles
    module unuse /shared/apps/modules/rhel9/modulefiles
    module unuse /shared/apps/modules/sles15sp4/modulefiles
    module unuse /shared/apps/modules/centos8/modulefiles
    module unuse /shared/apps/modules/rocky9/modulefiles
elif [[ $(echo $SLURM_JOB_PARTITION | grep -i rhel8) = *RHEL8* ]]; then
    module unuse /shared/apps/modules/ubuntu/modulefiles
    module use /shared/apps/modules/rhel8/modulefiles
    module unuse /shared/apps/modules/rhel9/modulefiles
    module unuse /shared/apps/modules/sles15sp4/modulefiles
    module unuse /shared/apps/modules/centos8/modulefiles
    module unuse /shared/apps/modules/rocky9/modulefiles
elif [[ $(echo $SLURM_JOB_PARTITION | grep -i rhel9) = *RHEL9* ]]; then
    module unuse /shared/apps/modules/ubuntu/modulefiles
    module unuse /shared/apps/modules/rhel8/modulefiles
    module use /shared/apps/modules/rhel9/modulefiles
    module unuse /shared/apps/modules/sles15sp4/modulefiles
    module unuse /shared/apps/modules/centos8/modulefiles
    module unuse /shared/apps/modules/rocky9/modulefiles
elif [[ $(echo $SLURM_JOB_PARTITION | grep -i sles15) = *SLES15* ]]; then
    module unuse /shared/apps/modules/ubuntu/modulefiles
    module unuse /shared/apps/modules/rhel8/modulefiles
    module unuse /shared/apps/modules/rhel9/modulefiles
    module use /shared/apps/modules/sles15sp4/modulefiles
    module unuse /shared/apps/modules/centos8/modulefiles
    module unuse /shared/apps/modules/rocky9/modulefiles
elif [[ $(echo $SLURM_JOB_PARTITION | grep -i centos8) = *CentOS8* ]]; then
    module unuse /shared/apps/modules/ubuntu/modulefiles
    module unuse /shared/apps/modules/rhel8/modulefiles
    module unuse /shared/apps/modules/rhel9/modulefiles
    module unuse /shared/apps/modules/sles15sp4/modulefiles
    module use /shared/apps/modules/centos8/modulefiles
    module unuse /shared/apps/modules/rocky9/modulefiles
elif [[ $(echo $SLURM_JOB_PARTITION | grep -i rocky9) = *Rocky9* ]]; then
    module unuse /shared/apps/modules/ubuntu/modulefiles
    module unuse /shared/apps/modules/rhel8/modulefiles
    module unuse /shared/apps/modules/rhel9/modulefiles
    module unuse /shared/apps/modules/sles15sp4/modulefiles
    module unuse /shared/apps/modules/centos8/modulefiles
    module use /shared/apps/modules/rocky9/modulefiles
fi


module purge
module load rocm-5.4.3

tmp=/tmp/$USER/gpu4-$$
mkdir -p $tmp

singularity run --pwd /benchmark --writable-tmpfs /shared/apps/bin/lammps_2022.5.04_130.sif /opt/lammps/tpl/openmpi/bin/mpirun -np 4 /opt/lammps/bin/lmp -k on g 4 -sf kk -pk kokkos cuda/aware on neigh full comm device neigh/qeq full newton on -v x 10 -v y 10 -v z 10 -v steps 600 -in in.lj -nocite -log /tmp/$USER/gpu4-$$/lj 

singularity run --pwd /benchmark --writable-tmpfs /shared/apps/bin/lammps_2022.5.04_130.sif /opt/lammps/tpl/openmpi/bin/mpirun -np 4 /opt/lammps/bin/lmp -k on g 4 -sf kk -pk kokkos cuda/aware on neigh full comm device neigh/qeq full newton on -v x 12 -v y 12 -v z 12 -v steps 300 -in in.eam -nocite -log /tmp/$USER/gpu4-$$/eam

singularity run --pwd /benchmark --writable-tmpfs /shared/apps/bin/lammps_2022.5.04_130.sif /opt/lammps/tpl/openmpi/bin/mpirun -np 4 /opt/lammps/bin/lmp -k on g 4 -sf kk -pk kokkos cuda/aware on neigh half binsize 5.6 comm device neigh/qeq full newton on -v x 6 -v y 6 -v z 6 -v steps 300 -in in.tersoff -nocite -log /tmp/$USER/gpu4-$$/tersoff

singularity run --pwd /benchmark --writable-tmpfs /shared/apps/bin/lammps_2022.5.04_130.sif /opt/lammps/tpl/openmpi/bin/mpirun -np 4 /opt/lammps/bin/lmp -k on g 4 -sf kk -pk kokkos cuda/aware on neigh half comm device neigh/qeq full newton on -v x 38 -v y 38 -v z 38 -v steps 300 -in in.reaxc.hns -nocite -log /tmp/$USER/gpu4-$$/reaxff

singularity run --pwd /benchmark --writable-tmpfs /shared/apps/bin/lammps_2022.5.04_130.sif /opt/lammps/tpl/openmpi/bin/mpirun -np 4 /opt/lammps/bin/lmp -k on g 4 -sf kk -pk kokkos cuda/aware on neigh half comm device neigh/qeq full newton on -v x 30 -v y 30 -v z 30 -v steps 400 -in in.snap.exaalt -nocite -log /tmp/$USER/gpu4-$$/snap




cp -r /tmp/$USER/gpu4-$$ $PWD/gpu4-$$-$SLURM_JOB_NODELIST-$SLURM_JOB_ID

rm -rf /tmp/$USER/gpu4-$$
