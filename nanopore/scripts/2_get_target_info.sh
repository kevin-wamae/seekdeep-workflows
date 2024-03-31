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

# NB: run this script while in the seekdeep-workflows/nanopore directory
# --------------------------------------------------

# Check if the script is being run from the correct directory
if [[ ! $(pwd) =~ seekdeep-workflows/nanopore$ ]]; then
   echo "Please run this script from this directory: seekdeep-workflows/nanopore/"
   exit 1
fi

# Activate a conda environment with the required tools:
# bowtie2, blast, samtools, cmake, openssl
# ========================================================
source "${HOME}/miniforge3/etc/profile.d/conda.sh"
conda activate seekdeep

# working directories, files and variables
# ========================================================
wd=/data/isabella_group/data/2024_01_22_turkana_embatalk_nanopore

# resources (genome, gff, known mutations)
resourcesDir=../resources

# primers
primers=$wd/input/run_files/primers.txt

# insert size
insert_size=400

# output directories for targets
out_dir=$wd/output/reference_targets

# number of threads for pipeline and clustering
threads=8

# ========================================================
# get target info from genomes using elucidator or seekdeep
# ========================================================
elucidator genTargetInfoFromGenomes \
   --primers $primers \
   --pairedEndLength $insert_size \
   --gffDir $resourcesDir/info/gff/ \
   --genomeDir $resourcesDir/genomes/ \
   --errors 0 \
   --dout $out_dir \
   --numThreads $threads \
   --shortNames \
   --overWriteDir

# deactivate conda environment
# ========================================================
conda deactivate
