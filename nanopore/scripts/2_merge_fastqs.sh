#!/bin/bash

# This script merges all fastq files in each barcode subdirectory into a single fastq file.
# It should be executed while in the root directory of this project:

# *****************************************************************

# get working directory
# --------------------------------------------------
wd=$(pwd)

# source directory
# --------------------------------------------------
src_dir="$wd/input/fastq_barcodes"

# destination directory
# --------------------------------------------------
dest_dir="$wd/input/fastq_barcodes_merged"

# loop through each barcode subdirectory
# --------------------------------------------------
for barcode_dir in "$src_dir"/*; do
	# check if it's a directory
	if [ -d "$barcode_dir" ]; then
		# get the name of the barcode (subdirectory name)
		barcode=$(basename "$barcode_dir")

		# concatenate all gzipped fastq files inside the barcode directory and save to the destination directory
		zcat "$barcode_dir"/*.fastq.gz | gzip -c >"$dest_dir"/"$barcode".fastq.gz
	fi
done
