#!/bin/bash

# ========================================================
#--- slurm commands ---
# ========================================================

#SBATCH -J demuxFqs
#SBATCH --partition=longrun
#SBATCH --time=12-00:00:00
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=10G
#SBATCH -o job.%j.out
#SBATCH -e job.%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=kkariuki@kemri-wellcome.org

# ========================================================
# activate conda environment
# ========================================================

source "${HOME}/miniforge3/etc/profile.d/conda.sh"
conda activate seekdeep

elucidator extractByIlluminaAaptors \
	--fastqgz /data/isabella_group/data/2024_03_11_turkana_tads_illumina_nanopore/input/fastq_barcodes_merged/all_barcodes.fastq.gz \
	--overWriteDir --dout /data/isabella_group/data/2024_03_11_turkana_tads_illumina_nanopore/input/fastq_demux_2 \
	--illuminaBarcodeSampleSheet /home/KWTRP/kkariuki/software/seekdeep-analysis-workflows/demux/illumina-indices_copy.tsv

# ========================================================
# deactivate conda environment
# ========================================================
conda deactivate
