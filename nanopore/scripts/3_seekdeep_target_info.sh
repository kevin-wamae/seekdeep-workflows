#!/bin/bash
#*********************************************************
# This script is for generating target info from genomes using SeekDeep.
# It should be run from the root of the project directory

# ********************************************************
#--- Start of slurm commands ---
# ********************************************************

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

# ********************************************************
# load modules, if needed
# ********************************************************
# e.g.
# module load gcc/10.2
# module load samtools/1.16.1
# module load bowtie2/2.4.2


# ********************************************************
# activate conda environment
# ********************************************************
source "${HOME}/mambaforge/etc/profile.d/conda.sh"
conda activate seekdeep


# ********************************************************
# working directories and files
# ********************************************************

# input directories and files
# --------------------------------------------------------
dirWrk=${PWD}
dirData=$dirWrk/input/fastq_barcodes_merged


# resources (genome, gff, known mutations)
resources=/nfs/jbailey5/baileyweb/colabs/kwamae/resources/seekdeep_ref_genomes/plasmodium_plasmodb_pacbio


# primers
# --------------------------------------------------------
primers=$dirWrk/input/run_files/primers.txt


# insert sizes
# --------------------------------------------------------
insert_size=300


# output directories for targets
# --------------------------------------------------------
dirRefs=$dirWrk/target_info


# number of threads for pipeline and clustering
# --------------------------------------------------------
threads=10


# ********************************************************
# SeekDeep - get target info from genomes
# ********************************************************
SeekDeep genTargetInfoFromGenomes \
   --primers $primers \
   --pairedEndLength $insert_size \
   --genomeDir $resources/genomes/ \
   --gffDir $resources/info/gff \
   --errors 2 \
   --dout $dirRefs \
   --numThreads $threads \
   --shortNames \
   --overWriteDir

conda deactivate
