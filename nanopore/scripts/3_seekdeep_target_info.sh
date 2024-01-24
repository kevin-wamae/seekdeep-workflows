#!/bin/bash
#*********************************************************
# This script is for generating target info from genomes using SeekDeep.
# It should be run from the root of the project directory

# ========================================================
#--- Start of slurm commands ---
# ========================================================

#SBATCH -J SeekDeep
#SBATCH --time=01:00:00
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=10G
#SBATCH -o job.%j.out
#SBATCH -e job.%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=wamaekevin@gmail.com

# ========================================================
# load modules, if needed, otherwise load conda environment with these tools
# ========================================================
# e.g.
# module load gcc
# module load samtools
# module load bowtie2

# ========================================================
# activate conda environment, if not using modules
# ========================================================
source "${HOME}/mambaforge/etc/profile.d/conda.sh"
conda activate seekdeep

# ========================================================
# working directories and files
# ========================================================

# input directories and files
# --------------------------------------------------------
wd=${PWD}
dirData=$wd/input/fastq_barcodes_merged

# resources (genome, gff, known mutations)
resources=$wd/input/genomes

# primers
# --------------------------------------------------------
primers=$wd/input/run_files/primers.txt

# insert size
# --------------------------------------------------------
insert_size=300

# output directories for targets
# --------------------------------------------------------
out_dir=$wd/input/genome_target_info

# number of threads for pipeline and clustering
# --------------------------------------------------------
threads=2

# ========================================================
# SeekDeep - get target info from genomes
# ========================================================
SeekDeep genTargetInfoFromGenomes \
   --primers $primers \
   --pairedEndLength $insert_size \
   --genomeDir $resources/genomes/ \
   --gffDir $resources/info/gff \
   --errors 2 \
   --dout $out_dir \
   --numThreads $threads \
   --shortNames \
   --overWriteDir

conda deactivate
