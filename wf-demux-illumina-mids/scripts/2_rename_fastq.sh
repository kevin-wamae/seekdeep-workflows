#!/bin/bash
#*********************************************************
# This script renames the fastq files that have been demultiplexed by
# the 1_demuxed_by_MIDs.sh script. Prior to running this script, the
# fastq files will be within the output/1_demuxed_by_MIDs directory and
# in subdirectories named by the sample names. The script reads a tsv
# file that contains the original fastq file names and the new names to
# be used. The script then renames the files and moves them to the output/2_renamed_fastq
# directory. The script needs to be run from the `seekdeep-workflows/wf-demux-illumina-mids` directory

# slurm directives
# ========================================================
#SBATCH --job-name=seekdeep
#SBATCH --partition=longrun
#SBATCH --time=03:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=10G
#SBATCH --output=job.%j.out
#SBATCH --error=job.%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=kkariuki@kemri-wellcome.org
# ========================================================

# NB: run this script while in the seekdeep-workflows/nanopore directory
# --------------------------------------------------

# Check if the script is being run from the correct directory
if [[ ! $(pwd) =~ seekdeep-workflows/wf-demux-illumina-mids$ ]]; then
    echo "Please run this script from this directory: seekdeep-workflows/wf-demux-illumina-mids/"
    exit 1
fi

# Change into working directory
# ----------------------------------------------------
cd output

# Ensure the 'renamed' directory exists, if not create it
# ----------------------------------------------------
mkdir -p 2_renamed_fastq

# location of the tsv file
# ----------------------------------------------------
TSV=../input/run_files/rename-fastq.tsv

# Read the tsv file and rename/move the files
# ----------------------------------------------------
awk -F'\t' 'NR>1 {print $1, $3, $2, $4}' $TSV | while read -r fq1 newname1 fq2 newname2; do
    if [[ -f "$fq1" ]]; then
        cp "$fq1" "$newname1"
    else
        echo "File not found: $fq1"
    fi

    if [[ -f "$fq2" ]]; then
        cp "$fq2" "$newname2"
    else
        echo "File not found: $fq2"
    fi
done
