#!/bin/bash
#*********************************************************
# This script demultplexes illumina paired-end reads whose amplicons
# were tagged with MIDs. The script uses the elucidator tool
# and needs to be run from the seekdeep-workflows/wf-demux-illumina-mids directory

# slurm directives
# ========================================================
#SBATCH --job-name=demux_MIDs
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

# directory containing the input fastq files
# ----------------------------------------------------
INDIR=/data/isabella_group/data/ssurvey_2022/western_kenya/2024_04_16_kwtrp_illumina_2x300/input/fastq

# directory where the output directories will be created
# ----------------------------------------------------
OUTDIR=output/1_demuxed_by_MIDs
mkdir -p $OUTDIR

# location of the MIDs file
# ----------------------------------------------------
MIDS=/data/isabella_group/data/ssurvey_2022/western_kenya/2024_04_16_kwtrp_illumina_2x300/input/run_files/primers.txt

# extract the fastq files by MIDs
for r1_file in ${INDIR}/*_R1.fastq.gz; do
    # Extract the base name without the full path and _R1.fastq.gz
    base_name=$(basename ${r1_file} _R1.fastq.gz)

    # Construct the corresponding R2 file name
    r2_file="${INDIR}/${base_name}_R2.fastq.gz"

    # Construct the output directory for this pair of FASTQ files
    out_dir="${OUTDIR}/${base_name}"

    # Run the elucidator command
    elucidator extractByMIDs \
        --fastq1gz "${r1_file}" \
        --fastq2gz "${r2_file}" \
        --id $MIDS \
        --dout "${out_dir}" \
        --overWriteDir
done
