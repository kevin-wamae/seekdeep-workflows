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
#SBATCH --output=job.%j.out
#SBATCH --error=job.%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=kkariuki@kemri-wellcome.org

# #--- End of slurm commands ---
# ========================================================

# NB: run this script while in the seekdeep-workflows/wf-seekdeep-nanopore-mid directory
# --------------------------------------------------

# Check if the script is being run from the correct directory
if [[ ! $(pwd) =~ seekdeep-workflows/wf-seekdeep-nanopore-mids$ ]]; then
	echo "Please run this script from this directory: seekdeep-workflows/wf-seekdeep-nanopore-mids/"
	exit 1
fi

# working directories, files and variables
# ========================================================
WD=$(pwd)

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
