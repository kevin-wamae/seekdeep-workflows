#!/bin/bash
#*********************************************************
# This script merges all fastq files in each barcode subdirectory into a single fastq file.
# It should be executed while in the root directory of this project:

# ========================================================
#--- Start of slurm commands ---
# ========================================================

#SBATCH -J mergeFqs
#SBATCH --partition=longrun
#SBATCH --time=12:00:00
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=4G
#SBATCH -o job.%j.out
#SBATCH -e job.%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=kkariuki@kemri-wellcome.org

# *****************************************************************

# get working directory
# --------------------------------------------------
# wd=$(pwd)
wd=/data/isabella_group/data/2024_01_22_turkana_tads_nanopore

# source directory
# --------------------------------------------------
src_dir="$wd/fastq_barcodes"

# destination directory
# --------------------------------------------------
dest_dir="$wd/fastq_barcodes_merged"

# loop through each barcode subdirectory
# --------------------------------------------------
for barcode_dir in "$src_dir"/*; do
	# check if it's a directory
	if [ -d "$barcode_dir" ]; then
		# get the name of the barcode (subdirectory name)
		barcode=$(basename "$barcode_dir")

		# concatenate all gzipped fastq files inside the barcode directory and save to the destination directory
		echo "Processing file: $barcode_dir/"
		zcat "$barcode_dir"/*.fastq.gz | gzip -c >"$dest_dir"/"$barcode".fastq.gz
		echo "Processed file: $dest_dir/$barcode.fastq.gz"
	fi
done
