#!/bin/bash
#*********************************************************

# This script will generate target info from reference genomes

# slurm directives
# ========================================================
#SBATCH --job-name=seekdeep
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
if [[ ! $(pwd) =~ seekdeep-workflows/illumina_mids_no_replicates$ ]]; then
  echo "Please run this script from this directory: seekdeep-workflows/illumina_mids_no_replicates/"
  exit 1
fi

# Activate a conda environment with the required tools:
# bowtie2, blast, samtools, cmake, openssl
# ========================================================

source "${HOME}/miniforge3/etc/profile.d/conda.sh"
conda activate seekdeep

# or load required modules if not using conda
# --------------------------------------------------------
# module load bowtie2
# module load samtools
# module load gcc/12.3.1

# working directories, files and variables
# ========================================================

# working directory
WD=/data/isabella_group/data/ssurvey_2022/western_kenya/2024_02_23_ilri_illumina_2x300

# output directory, rename to user's preference
mkdir -p $WD/output/
DIR_OUT=$WD/output/reference_targets

# primers
PRIMERS=$WD/input/run_files/primers.txt

# resources directory
REF_GENOMES=/home/KWTRP/kkariuki/software/seekdeep-workflows/resources/genomes
REF_GFFS=/home/KWTRP/kkariuki/software/seekdeep-workflows/resources/info/gff

# threads to use
THREADS=10

# seekdeep script
# --------------------------------------------------------

# k13
elucidator genTargetInfoFromGenomes \
  --genomeDir $REF_GENOMES/ \
  --gffDir $REF_GFFS/ \
  --primers $PRIMERS \
  --numThreads $THREADS \
  --pairedEndLength 300 \
  --dout $DIR_OUT \
  --overWriteDir

# deactivate conda environment
# ========================================================
conda deactivate

# or unload modules if not using conda
# ========================================================
# module unload bowtie2
# module unload samtools
# module unload gcc/12.3.1
