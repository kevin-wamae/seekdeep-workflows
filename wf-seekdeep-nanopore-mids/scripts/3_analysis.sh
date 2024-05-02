#!/bin/bash
#*********************************************************
# This script is for running SeekDeep analysis on nanopore DATA_DIR.
# It should be run from the root of the project directory

# slurm directives
# ========================================================
#SBATCH --job-name=seekdeep
#SBATCH --partition=longrun
#SBATCH --time=06:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24
#SBATCH --mem=100G
#SBATCH --output=job.%j.out
#SBATCH --error=job.%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=kkariuki@kemri-wellcome.org
# ========================================================

# NB: run this script while in the seekdeep-workflows/nanopore directory
# --------------------------------------------------

# Check if the script is being run from the correct directory
if [[ ! $(pwd) =~ seekdeep-workflows/wf-seekdeep-nanopore-mids$ ]]; then
	echo "Please run this script from this directory: seekdeep-workflows/wf-seekdeep-nanopore-mids/"
	exit 1
fi

# Activate a conda environment with the required tools:
# bowtie2, blast, samtools, cmake, openssl
# ========================================================

source "${HOME}/miniforge3/etc/profile.d/conda.sh"
conda activate seekdeep

# working directories, files and variables
# ========================================================
WD=/data/isabella_group/data/chmi/ama1_validation
DATA_DIR=$WD/input/fastq_barcodes_merged

# sample names
SAMPLE_NAMES=$WD/input/run_files/sampleNames.txt

# resources (genome, gff, known mutations)
REF_GENOME=/home/KWTRP/kkariuki/software/seekdeep-workflows/resources/genomes/Pf3D7.fasta
REF_GFF=/home/KWTRP/kkariuki/software/seekdeep-workflows/resources/info/gff/Pf3D7.gff
KNOWN_MUTATIONS=/home/KWTRP/kkariuki/software/seekdeep-workflows/resources/info/pf_drug_resistant_aaPositions.tsv

# primers
PRIMERS=$WD/input/run_files/primers.txt

# target info
GENOME_TARGET_INFO=$WD/output/reference_targets

# output directory, rename to user's preference
mkdir -p $WD/output/analysis
DIR_OUT=$WD/output/analysis/2024_05_02-02-seekdeep

# number of threads for pipeline and clustering
THREADS_PIPELINE=24
THREADS_CLUSTERING=24

# analysis - setup tar amp analysis to generate wrapper scripts
# ========================================================
SeekDeep setupTarAmpAnalysis \
	--samples $SAMPLE_NAMES \
	--outDir $DIR_OUT \
	--technology nanopore \
	--uniqueKmersPerTarget $GENOME_TARGET_INFO/forSeekDeep/uniqueKmers.tab.txt.gz \
	--inputDir $DATA_DIR \
	--idFile $PRIMERS \
	--lenCutOffs $GENOME_TARGET_INFO/forSeekDeep/lenCutOffs.txt \
	--extraExtractorCmds="--minLenCutOff 100 \
						  --qualCheckLevel 11" \
	--extraKlusterCmds="--readLengthMinDiff 100 \
						--maxReadAmountForDownsample 1000000 \
						--numThreads $THREADS_CLUSTERING" \
	--extraProcessClusterCmds="--sampleMinTotalReadCutOff 250 \
							   --replicateMinTotalReadCutOff 250 \
							   --lowFreqHaplotypeFracCutOff 0.05 \
							   --genomeFnp $REF_GENOME \
							   --gffFnp $REF_GFF \
							   --knownAminoAcidChangesFnp $KNOWN_MUTATIONS" \
	--previousPopSeqsDir $GENOME_TARGET_INFO/forSeekDeep/refSeqs \
	--numThreads $THREADS_PIPELINE

# run the analysis
# ========================================================
cd $DIR_OUT
./runAnalysis.sh $THREADS_PIPELINE

# deactivate conda environment
# ========================================================
conda deactivate
