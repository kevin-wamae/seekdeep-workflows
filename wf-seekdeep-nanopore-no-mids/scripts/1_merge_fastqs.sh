#!/bin/bash
#*********************************************************
# This script merges all fastq files in each barcode subdirectory into a single fastq file.
# It should be executed while in the root directory of this project:

# ========================================================
#--- slurm commands ---

#SBATCH --job-name fastq_merge
#SBATCH --partition=longrun
#SBATCH --time=02:00:00
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=4G
#SBATCH --output=log/job.%j.out
#SBATCH --error=log/job.%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=kkariuki@kemri-wellcome.org

# #--- End of slurm commands ---
# ========================================================

# working directories, files and variables
# ========================================================
# WD=$(PWD)
WD=/data/isabella_group/data/multidrug_resistance_lab_kisumu/2024_04_19_nanopore_r10.4.1/

# source directory
DIR_IN="$WD/input/fastq_barcodes"

# destination directory
DIR_OUT="$WD/input/fastq_barcodes_merged"
mkdir -p "$DIR_OUT"

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
