#!/bin/bash
#*********************************************************
# This script merges all fastq files in each barcode subdirectory into a single fastq file.
# It should be executed while in the root directory of this project:

# ========================================================
#--- slurm commands ---

#SBATCH --job-name demux
#SBATCH --partition=<>		 # specify the partition name (e.g. debug, longrun)
#SBATCH --time=06:00:00
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=20
#SBATCH --mem=10G
#SBATCH --output=job.%j.out
#SBATCH --error=job.%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=<>       # email address

# #--- End of slurm commands ---
# ========================================================

source "${HOME}/miniforge3/etc/profile.d/conda.sh"
conda activate biopython

python scripts/fastq-demux-mid.py

conda deactivate
