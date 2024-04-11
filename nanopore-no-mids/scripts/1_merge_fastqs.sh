#!/bin/bash
#*********************************************************
# This script merges all fastq files in each barcode subdirectory into a single fastq file.
# It should be executed while in the root directory of this project:

# ========================================================
#--- slurm commands ---

#SBATCH --job-name mergeFqs
#SBATCH --partition=longrun
#SBATCH --time=12:00:00
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=4G
#SBATCH --output=job.%j.out
#SBATCH --error=job.%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=kkariuki@kemri-wellcome.org

# #--- End of slurm commands ---
# ========================================================

# working directories, files and variables
# ========================================================
# WD=$(PWD)
WD =/data/isabella_group/data/2024_01_22_turkana_tads_nanopore

# source directory
DIR_IN="$WD/fastq_barcodes"

# destination directory
DIR_OUT="$WD/fastq_barcodes_merged"

# loop through each barcode subdirectory and merge all fastq files
# ========================================================
for barcode_dir in "$DIR_IN"/*; do
	# check if it's a directory
	if [ -d "$barcode_dir" ]; then
		# get the name of the barcode (subdirectory name)
		barcode=$(basename "$barcode_dir")

		# concatenate all gzipped fastq files inside the barcode directory and save to the destination directory
		echo "Processing file: $barcode_dir/"
		zcat "$barcode_dir"/*.fastq.gz | gzip -c >"$DIR_OUT"/"$barcode".fastq.gz
		echo "Processed file: $DIR_OUT/$barcode.fastq.gz"
	fi
done
