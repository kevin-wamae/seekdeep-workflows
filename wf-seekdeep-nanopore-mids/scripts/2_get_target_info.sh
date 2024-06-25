#!/bin/bash
#*********************************************************

# This script will generate target info from reference genomes

# slurm directives
# ========================================================
#SBATCH --job-name=tads
#SBATCH --partition=longrun
#SBATCH --time=00:30:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=10G
#SBATCH --output=job.%j.out
#SBATCH --error=job.%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=kkariuki@kemri-wellcome.org
# ========================================================

# NB: run this script while in the seekdeep-workflows/wf-seekdeep-nanopore-mid directory
# --------------------------------------------------

# Check if the script is being run from the correct directory
if [[ ! $(pwd) =~ seekdeep-workflows/wf-seekdeep-nanopore-mids$ ]]; then
   echo "Please run this script from this directory: seekdeep-workflows/wf-seekdeep-nanopore-mids/"
   exit 1
fi

# Activate a conda environment with the required tools:
# bowtie2, blast, samtools, cmake, openssl
# ========================================================
source "${HOME}/miniforge3/etc/profile.d/conda.sh"
conda activate seekdeep

# working directories, files and variables
# ========================================================
WD=$(pwd)

# resources (genome, gff, known mutations)
DIR_RESOURCES=../resources

# primers
PRIMERS=$WD/input/run_files/primers.txt

# insert size
INSERT_SIZE=400

# output directories for targets
mkdir -p $WD/output/
DIR_OUT=$WD/output/reference_targets

# number of threads to use
THREADS=8

# ========================================================
# get target info from genomes using elucidator or seekdeep
# ========================================================
elucidator genTargetInfoFromGenomes \
   --primers $PRIMERS \
   --pairedEndLength $INSERT_SIZE \
   --gffDir $DIR_RESOURCES/info/gff/ \
   --genomeDir $DIR_RESOURCES/genomes/ \
   --errors 0 \
   --dout $DIR_OUT \
   --numThreads $THREADS \
   --shortNames \
   --overWriteDir

# deactivate conda environment
# ========================================================
conda deactivate
