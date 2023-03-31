#!/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --cpus-per-task=12
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


module purge
module load rocm-5.4.3

tmp=/tmp/$USER/tmp-$$
mkdir -p $tmp

singularity run /shared/apps/bin/namd3_3.0a9.sif cp -r /examples ./examples-$$


# jac benchmark run
singularity run --bind ./examples-$$:/examples-$$ --pwd /examples-$$ /shared/apps/bin/namd3_3.0a9.sif /opt/namd/bin/namd3 jac/jac.namd +p1 +pemap 0 --CUDASOAintegrate on +devices 0 2>&1 | tee -a ./examples-$$/jac-gpu0.log &
singularity run --bind ./examples-$$:/examples-$$ --pwd /examples-$$ /shared/apps/bin/namd3_3.0a9.sif /opt/namd/bin/namd3 jac/jac.namd +p1 +pemap 8 --CUDASOAintegrate on +devices 1 2>&1 | tee -a ./examples-$$/jac-gpu1.log &
singularity run --bind ./examples-$$:/examples-$$ --pwd /examples-$$ /shared/apps/bin/namd3_3.0a9.sif /opt/namd/bin/namd3 jac/jac.namd +p1 +pemap 16 --CUDASOAintegrate on +devices 2 2>&1 | tee -a ./examples-$$/jac-gpu2.log &
singularity run --bind ./examples-$$:/examples-$$ --pwd /examples-$$ /shared/apps/bin/namd3_3.0a9.sif /opt/namd/bin/namd3 jac/jac.namd +p1 +pemap 32 --CUDASOAintegrate on +devices 3 2>&1 | tee -a ./examples-$$/jac-gpu3.log &
singularity run --bind ./examples-$$:/examples-$$ --pwd /examples-$$ /shared/apps/bin/namd3_3.0a9.sif /opt/namd/bin/namd3 jac/jac.namd +p1 +pemap 48 --CUDASOAintegrate on +devices 4 2>&1 | tee -a ./examples-$$/jac-gpu4.log &
singularity run --bind ./examples-$$:/examples-$$ --pwd /examples-$$ /shared/apps/bin/namd3_3.0a9.sif /opt/namd/bin/namd3 jac/jac.namd +p1 +pemap 56 --CUDASOAintegrate on +devices 5 2>&1 | tee -a ./examples-$$/jac-gpu5.log &
singularity run --bind ./examples-$$:/examples-$$ --pwd /examples-$$ /shared/apps/bin/namd3_3.0a9.sif /opt/namd/bin/namd3 jac/jac.namd +p1 +pemap 64 --CUDASOAintegrate on +devices 6 2>&1 | tee -a ./examples-$$/jac-gpu6.log &
singularity run --bind ./examples-$$:/examples-$$ --pwd /examples-$$ /shared/apps/bin/namd3_3.0a9.sif /opt/namd/bin/namd3 jac/jac.namd +p1 +pemap 72 --CUDASOAintegrate on +devices 7 2>&1 | tee -a ./examples-$$/jac-gpu7.log

# apoa1 benchmark run
singularity run --bind ./examples-$$:/examples-$$ --pwd /examples-$$ /shared/apps/bin/namd3_3.0a9.sif /opt/namd/bin/namd3 apoa1/apoa1.namd +p1 +pemap 0 --CUDASOAintegrate on +devices 0 2>&1 | tee -a ./examples-$$/apoa1-gpu0.log &
singularity run --bind ./examples-$$:/examples-$$ --pwd /examples-$$ /shared/apps/bin/namd3_3.0a9.sif /opt/namd/bin/namd3 apoa1/apoa1.namd +p1 +pemap 8 --CUDASOAintegrate on +devices 1 2>&1 | tee -a ./examples-$$/apoa1-gpu1.log &
singularity run --bind ./examples-$$:/examples-$$ --pwd /examples-$$ /shared/apps/bin/namd3_3.0a9.sif /opt/namd/bin/namd3 apoa1/apoa1.namd +p1 +pemap 16 --CUDASOAintegrate on +devices 2 2>&1 | tee -a ./examples-$$/apoa1-gpu2.log &
singularity run --bind ./examples-$$:/examples-$$ --pwd /examples-$$ /shared/apps/bin/namd3_3.0a9.sif /opt/namd/bin/namd3 apoa1/apoa1.namd +p1 +pemap 32 --CUDASOAintegrate on +devices 3 2>&1 | tee -a ./examples-$$/apoa1-gpu3.log &
singularity run --bind ./examples-$$:/examples-$$ --pwd /examples-$$ /shared/apps/bin/namd3_3.0a9.sif /opt/namd/bin/namd3 apoa1/apoa1.namd +p1 +pemap 48 --CUDASOAintegrate on +devices 4 2>&1 | tee -a ./examples-$$/apoa1-gpu4.log &
singularity run --bind ./examples-$$:/examples-$$ --pwd /examples-$$ /shared/apps/bin/namd3_3.0a9.sif /opt/namd/bin/namd3 apoa1/apoa1.namd +p1 +pemap 56 --CUDASOAintegrate on +devices 5 2>&1 | tee -a ./examples-$$/apoa1-gpu5.log &
singularity run --bind ./examples-$$:/examples-$$ --pwd /examples-$$ /shared/apps/bin/namd3_3.0a9.sif /opt/namd/bin/namd3 apoa1/apoa1.namd +p1 +pemap 64 --CUDASOAintegrate on +devices 6 2>&1 | tee -a ./examples-$$/apoa1-gpu6.log &
singularity run --bind ./examples-$$:/examples-$$ --pwd /examples-$$ /shared/apps/bin/namd3_3.0a9.sif /opt/namd/bin/namd3 apoa1/apoa1.namd +p1 +pemap 72 --CUDASOAintegrate on +devices 7 2>&1 | tee -a ./examples-$$/apoa1-gpu7.log

# f1atpase benchmark run
singularity run --bind ./examples-$$:/examples-$$ --pwd /examples-$$ /shared/apps/bin/namd3_3.0a9.sif /opt/namd/bin/namd3 f1atpase/f1atpase.namd +p1 +pemap 0 --CUDASOAintegrate on +devices 0 2>&1 | tee -a ./examples-$$/f1atpase-gpu0.log &
singularity run --bind ./examples-$$:/examples-$$ --pwd /examples-$$ /shared/apps/bin/namd3_3.0a9.sif /opt/namd/bin/namd3 f1atpase/f1atpase.namd +p1 +pemap 8 --CUDASOAintegrate on +devices 1 2>&1 | tee -a ./examples-$$/f1atpase-gpu1.log &
singularity run --bind ./examples-$$:/examples-$$ --pwd /examples-$$ /shared/apps/bin/namd3_3.0a9.sif /opt/namd/bin/namd3 f1atpase/f1atpase.namd +p1 +pemap 16 --CUDASOAintegrate on +devices 2 2>&1 | tee -a ./examples-$$/f1atpase-gpu2.log &
singularity run --bind ./examples-$$:/examples-$$ --pwd /examples-$$ /shared/apps/bin/namd3_3.0a9.sif /opt/namd/bin/namd3 f1atpase/f1atpase.namd +p1 +pemap 32 --CUDASOAintegrate on +devices 3 2>&1 | tee -a ./examples-$$/f1atpase-gpu3.log &
singularity run --bind ./examples-$$:/examples-$$ --pwd /examples-$$ /shared/apps/bin/namd3_3.0a9.sif /opt/namd/bin/namd3 f1atpase/f1atpase.namd +p1 +pemap 48 --CUDASOAintegrate on +devices 4 2>&1 | tee -a ./examples-$$/f1atpase-gpu4.log &
singularity run --bind ./examples-$$:/examples-$$ --pwd /examples-$$ /shared/apps/bin/namd3_3.0a9.sif /opt/namd/bin/namd3 f1atpase/f1atpase.namd +p1 +pemap 56 --CUDASOAintegrate on +devices 5 2>&1 | tee -a ./examples-$$/f1atpase-gpu5.log &
singularity run --bind ./examples-$$:/examples-$$ --pwd /examples-$$ /shared/apps/bin/namd3_3.0a9.sif /opt/namd/bin/namd3 f1atpase/f1atpase.namd +p1 +pemap 64 --CUDASOAintegrate on +devices 6 2>&1 | tee -a ./examples-$$/f1atpase-gpu6.log &
singularity run --bind ./examples-$$:/examples-$$ --pwd /examples-$$ /shared/apps/bin/namd3_3.0a9.sif /opt/namd/bin/namd3 f1atpase/f1atpase.namd +p1 +pemap 72 --CUDASOAintegrate on +devices 7 2>&1 | tee -a ./examples-$$/f1atpase-gpu7.log

# stmv benchmark run
singularity run --bind ./examples-$$:/examples-$$ --pwd /examples-$$ /shared/apps/bin/namd3_3.0a9.sif /opt/namd/bin/namd3 stmv/stmv.namd +p1 +pemap 0 --CUDASOAintegrate on +devices 0 2>&1 | tee -a ./examples-$$/stmv-gpu0.log &
singularity run --bind ./examples-$$:/examples-$$ --pwd /examples-$$ /shared/apps/bin/namd3_3.0a9.sif /opt/namd/bin/namd3 stmv/stmv.namd +p1 +pemap 8 --CUDASOAintegrate on +devices 1 2>&1 | tee -a ./examples-$$/stmv-gpu1.log &
singularity run --bind ./examples-$$:/examples-$$ --pwd /examples-$$ /shared/apps/bin/namd3_3.0a9.sif /opt/namd/bin/namd3 stmv/stmv.namd +p1 +pemap 16 --CUDASOAintegrate on +devices 2 2>&1 | tee -a ./examples-$$/stmv-gpu2.log &
singularity run --bind ./examples-$$:/examples-$$ --pwd /examples-$$ /shared/apps/bin/namd3_3.0a9.sif /opt/namd/bin/namd3 stmv/stmv.namd +p1 +pemap 32 --CUDASOAintegrate on +devices 3 2>&1 | tee -a ./examples-$$/stmv-gpu3.log &
singularity run --bind ./examples-$$:/examples-$$ --pwd /examples-$$ /shared/apps/bin/namd3_3.0a9.sif /opt/namd/bin/namd3 stmv/stmv.namd +p1 +pemap 48 --CUDASOAintegrate on +devices 4 2>&1 | tee -a ./examples-$$/stmv-gpu4.log &
singularity run --bind ./examples-$$:/examples-$$ --pwd /examples-$$ /shared/apps/bin/namd3_3.0a9.sif /opt/namd/bin/namd3 stmv/stmv.namd +p1 +pemap 56 --CUDASOAintegrate on +devices 5 2>&1 | tee -a ./examples-$$/stmv-gpu5.log &
singularity run --bind ./examples-$$:/examples-$$ --pwd /examples-$$ /shared/apps/bin/namd3_3.0a9.sif /opt/namd/bin/namd3 stmv/stmv.namd +p1 +pemap 64 --CUDASOAintegrate on +devices 6 2>&1 | tee -a ./examples-$$/stmv-gpu6.log &
singularity run --bind ./examples-$$:/examples-$$ --pwd /examples-$$ /shared/apps/bin/namd3_3.0a9.sif /opt/namd/bin/namd3 stmv/stmv.namd +p1 +pemap 72 --CUDASOAintegrate on +devices 7 2>&1 | tee -a ./examples-$$/stmv-gpu7.log

cp -r ./examples-$$   $PWD/gpu8-$$-$SLURM_JOB_NODELIST-$SLURM_JOB_ID

rm -rf examples-$$/
