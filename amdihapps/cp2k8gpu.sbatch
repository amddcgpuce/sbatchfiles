#!/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --cpus-per-task=16
#SBATCH --mem=0
#SBATCH --gres=gpu:8
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


module load rocm-5.4.3

tmp=/tmp/$USER/tmp-$$

mkdir -p $tmp

singularity run /shared/apps/bin/cp2k:2022.2.amd3_76.sif cp -r /opt/cp2k/benchmarks $tmp

# Run H2O-DFT-LS-NREP2 Test
mkdir -p $tmp/H2O-DFT-LS-NREP2-8GPU-$$
singularity run  --bind $tmp/benchmarks/:/opt/cp2k/benchmarks/ --bind $tmp/H2O-DFT-LS-NREP2-8GPU-$$:/tmp /shared/apps/bin/cp2k:2022.2.amd3_76.sif benchmark H2O-DFT-LS-NREPS2 --arch VEGA90A --gpu-type MI250 --rank-stride 8 --omp-thread-count 8 --ranks 16 --gpu-count 8 --cpu-count 128 --output /tmp/H2O-DFT-LS-NREP2-8GPU
cp -r $tmp/H2O-DFT-LS-NREP2-8GPU-$$ `pwd`/

# Run 32-H2O-RPA test
rm -rf $tmp/benchmarks/logs
mkdir -p $tmp/32-H2O-RPA-8GPU-$$
singularity run  --bind $tmp/benchmarks/:/opt/cp2k/benchmarks/ --bind $tmp/32-H2O-RPA-8GPU-$$:/tmp /shared/apps/bin/cp2k:2022.2.amd3_76.sif benchmark 32-H2O-RPA --arch VEGA90A  --gpu-type MI250 --rank-stride 8 --omp-thread-count 8 --ranks 16 --gpu-count 8 --cpu-count 128 --output /tmp/32-H2O-RPA-8GPU

cp -r $tmp/32-H2O-RPA-8GPU-$$ `pwd`/

# Cleanup the benchmark data which was copied
rm -rf $tmp

