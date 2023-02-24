#!/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --cpus-per-task=12
#SBATCH --mem=0
#SBATCH --gres=gpu:8
#SBATCH -o %x-%N-%j.out
#SBATCH -e %x-%N-%j.err

source /etc/profile.d/modules.sh

# Use partition name to load OS-specific modulespath to use to override # login node environment 
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

export DOWNLOAD_DIR=/datasets/

singularity exec --pwd /app/alphafold -B $ROCM_PATH:$ROCM_PATH -B /shareddata/ALPHAFOLD_DBS:/datasets/alphafold --env HHLIB=/opt/hhsuite /shared/apps/bin/deepmind_rocm5.4.1_jax0.3.24.sif python3 ./run_alphafold_2GPUs.py --fasta_paths=T1050.fasta --model_preset=monomer --use_gpu_relax=True --benchmark=True --uniref90_database_path=${DOWNLOAD_DIR}/alphafold/uniref90/uniref90.fasta --mgnify_database_path=${DOWNLOAD_DIR}/alphafold/mgnify/mgy_clusters_2018_12.fa --pdb70_database_path=${DOWNLOAD_DIR}/alphafold/pdb70/pdb70 --data_dir=${DOWNLOAD_DIR}/alphafold --template_mmcif_dir=${DOWNLOAD_DIR}/alphafold/pdb_mmcif/mmcif_files --obsolete_pdbs_path=${DOWNLOAD_DIR}/alphafold/pdb_mmcif/obsolete.dat --small_bfd_database_path=${DOWNLOAD_DIR}/alphafold/small_bfd/bfd-first_non_consensus_sequences.fasta --output_dir=$HOME/alphafold/output --max_template_date=2020-05-14 --db_preset=reduced_dbs --logtostderr --hhsearch_binary_path=/opt/hhsuite/bin/hhsearch --hhblits_binary_path=/opt/hhsuite/bin/hhblits


