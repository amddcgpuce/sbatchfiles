#!/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --cpus-per-task=16
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

tmp=/tmp/$USER/tmp-$$
mkdir -p $tmp

singularity run /shared/apps/bin/namd2.15a2-20211101.sif cp -r /examples ./examples-$$

singularity run --bind ./examples-$$:/examples-$$ --pwd /examples-$$ /shared/apps/bin/namd2.15a2-20211101.sif /opt/namd/bin/namd2 jac/jac.namd +p4 +pemap 0-3 +devices 0,1,2,3 

singularity run --bind ./examples-$$:/examples-$$ --pwd /examples-$$ /shared/apps/bin/namd2.15a2-20211101.sif /opt/namd/bin/namd2 apoa1/apoa1.namd +p4 +pemap 0-3 +devices 0,1,2,3

singularity run --bind ./examples-$$:/examples-$$ --pwd /examples-$$ /shared/apps/bin/namd2.15a2-20211101.sif /opt/namd/bin/namd2 f1atpase/f1atpase.namd +p4 +pemap 0-3 +devices 0,1,2,3 

singularity run --bind ./examples-$$:/examples-$$ --pwd /examples-$$ /shared/apps/bin/namd2.15a2-20211101.sif /opt/namd/bin/namd2 stmv/stmv.namd +p4 +pemap 0-3 +devices 0,1,2,3 

cp -r ./examples-$$   $PWD/gpu4-$$-$SLURM_JOB_NODELIST-$SLURM_JOB_ID

rm -rf examples-$$/
