#!/bin/bash

#SBATCH --job-name=torch-ddp16gpu
#SBATCH --exclusive
#SBATCH --nodes=2
#SBATCH --mem=0
#SBATCH --gres=gpu:8

source /etc/profile.d/modules.sh
source /shared/share/aac1plano.modules.bash

module purge
module load rocm-5.4.3

node_list=$(scontrol show hostnames $SLURM_JOB_NODELIST)
node_array=(${node_list})
master_node=${node_array[0]}

wget https://github.com/ozziemoreno/files/raw/main/elastic_ddp.py

# Run using one line
srun -N ${SLURM_NNODES} \
	singularity run /shared/apps/bin/pytorch_rocm5.4_ubuntu20.04_py3.8_pytorch_1.12.1.sif torchrun \
	--nnodes=${SLURM_NNODES} \
	--nproc_per_node=${SLURM_GPUS_ON_NODE} \
	--rdzv_id=100 \
	--rdzv_backend=c10d \
	--rdzv_endpoint=${master_node}:29400 \
	elastic_ddp.py

rm elastic_ddp.py

