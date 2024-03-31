#!/bin/bash
#*********************************************************
# This script is for running SeekDeep analysis on nanopore data_dir.
# It should be run from the root of the project directory

# slurm directives
# ========================================================
#SBATCH --job-name=tads
#SBATCH --partition=longrun
#SBATCH --time=06:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=100G
#SBATCH --output=job.%j.out
#SBATCH --error=job.%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=kkariuki@kemri-wellcome.org
# ========================================================

# NB: run this script while in the seekdeep-workflows/nanopore directory
# --------------------------------------------------

# Check if the script is being run from the correct directory
if [[ ! $(pwd) =~ seekdeep-workflows/nanopore$ ]]; then
	echo "Please run this script from this directory: seekdeep-workflows/nanopore/"
	exit 1
fi

# Activate a conda environment with the required tools:
# bowtie2, blast, samtools, cmake, openssl
# ========================================================

source "${HOME}/miniforge3/etc/profile.d/conda.sh"
conda activate seekdeep

# working directories, files and variables
# ========================================================
wd=/data/isabella_group/data/2024_01_22_turkana_embatalk_nanopore
data_dir=$wd/input/fastq_barcodes_merged

# sample names
sampleNames=$wd/input/run_files/sampleNames.txt

# resources (genome, gff, known mutations)
resourcesDir=../resources

# primers
primers=$wd/input/run_files/primers.txt

# target info
genomeTargetInfo=$wd/output/reference_targets

# output directory, rename to user's preference
out_dir=$wd/output/analysis/2024_03_31-01

# insert size
insert_size=400

# number of threads for pipeline and clustering
threadsPipeline=10
threadsClustering=2

# analysis - setup tar amp analysis to generate wrapper scripts
# ========================================================
elucidator setupTarAmpAnalysis \
	--samples $sampleNames \
	--outDir $out_dir \
	--technology nanopore \
	--uniqueKmersPerTarget $genomeTargetInfo/forSeekDeep/uniqueKmers.tab.txt.gz \
	--inputDir $data_dir \
	--idFile $primers \
	--lenCutOffs $genomeTargetInfo/forSeekDeep/lenCutOffs.txt \
	--doNotGuessRecFlags \
	--extraExtractorCmds="--primerWithinStart 100 \
							--minLenCutOff 100 \
							--qualCheckLevel 11" \
	--extraKlusterCmds="--readLengthMinDiff 100 \
						--numThreads $threadsClustering" \
	--extraProcessClusterCmds="--sampleMinTotalReadCutOff 250 \
								--replicateMinTotalReadCutOff 250 \
								--lowFreqHaplotypeFracCutOff 0.05" \
	--previousPopSeqsDir $genomeTargetInfo/forSeekDeep/refSeqs \
	--numThreads $threadsPipeline

# run the analysis
# ========================================================
cd $out_dir
./runAnalysis.sh $threadsPipeline

# deactivate conda environment
# ========================================================
conda deactivate
