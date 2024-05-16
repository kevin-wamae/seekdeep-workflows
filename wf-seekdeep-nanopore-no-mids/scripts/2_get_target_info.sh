#!/bin/bash
#*********************************************************

# This script will generate target info from reference genomes

# slurm directives
# ========================================================
#SBATCH --job-name=getTargets
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
if [[ ! $(pwd) =~ seekdeep-workflows/wf-seekdeep-nanopore-no-mids$ ]]; then
   echo "Please run this script from this directory: seekdeep-workflows/wf-seekdeep-nanopore-no-mids/"
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
WD=/data/isabella_group/data/multidrug_resistance_lab_kisumu/2024_04_19_nanopore_r10.4.1

# resources directory, these must be absolute paths
REF_GENOMES=/home/KWTRP/kkariuki/software/seekdeep-workflows/resources/genomes
REF_GFFS=/home/KWTRP/kkariuki/software/seekdeep-workflows/resources/info/gff

# primers
PRIMERS=$WD/input/run_files/primers.txt

# insert size
INSERT_SIZE=400

# output directories for targets
DIR_OUT=$WD/output/reference_targets
mkdir -p $DIR_OUT

# number of threads to use
THREADS=8

# get target info from genomes using elucidator or seekdeep
# ========================================================
elucidator genTargetInfoFromGenomes \
   --primers $PRIMERS \
   --pairedEndLength $INSERT_SIZE \
   --genomeDir $REF_GENOMES \
   --gffDir $REF_GFFS \
   --errors 0 \
   --dout $DIR_OUT \
   --numThreads $THREADS \
   --shortNames \
   --overWriteDir

# deactivate conda environment
# ========================================================
conda deactivate

# or unload modules if not using conda
# ========================================================
# module unload bowtie2
# module unload samtools
# module unload gcc/12.3.1
