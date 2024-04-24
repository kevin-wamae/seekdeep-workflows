#!/bin/bash
#*********************************************************
# This script is for running SeekDeep analysis on illumina DATA_DIR.
# It should be run from the root of the project directory

# slurm directives
# ========================================================
#SBATCH --job-name=seekdeep
#SBATCH --partition=longrun
#SBATCH --time=07:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24
#SBATCH --mem=50G
#SBATCH --output=log/job.%j.out
#SBATCH --error=log/job.%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=kkariuki@kemri-wellcome.org
# ========================================================

# NB: run this script while in the seekdeep-workflows/nanopore directory
# --------------------------------------------------

# Check if the script is being run from the correct directory
if [[ ! $(pwd) =~ seekdeep-workflows/wf-seekdeep-illumina-mids$ ]]; then
	echo "Please run this script from this directory: seekdeep-workflows/wf-seekdeep-illumina-mids/"
	exit 1
fi

# Activate a conda environment with the required tools:
# bowtie2, blast, samtools, cmake, openssl
# ========================================================

source "${HOME}/miniforge3/etc/profile.d/conda.sh"
conda activate seekdeep

# working directories, files and variables
# ========================================================

# working directory
WD=/data/isabella_group/data/ssurvey_2022/western_kenya/2024_02_23_ilri_illumina_2x300

# data directory
DATA_DIR=$WD/input/fastq

# sample names
SAMPLE_NAMES=$WD/input/run_files/sampleNames.txt

# primers
PRIMERS=$WD/input/run_files/primers.txt

# target info
GENOME_TARGET_INFO=$WD/output/reference_targets/forSeekDeep

# resources (genome, gff, known mutations)
REF_GENOME=/home/KWTRP/kkariuki/software/seekdeep-workflows/resources/genomes/Pf3D7.fasta
REF_GFF=/home/KWTRP/kkariuki/software/seekdeep-workflows/resources/info/gff/Pf3D7.gff
KNOWN_MUTATIONS=/home/KWTRP/kkariuki/software/seekdeep-workflows/resources/info/pf_drug_resistant_aaPositions_k13_updated.tsv

# output directory, rename to user's preference
mkdir -p $WD/output/analysis
DIR_OUT=$WD/output/analysis/2024_04_24-01-seekdeep

# number of threads to use
THREADS=30

# analysis - setup tar amp analysis to generate wrapper scripts
# ========================================================

elucidator setupTarAmpAnalysis \
	--samples $SAMPLE_NAMES \
	--outDir $DIR_OUT \
	--inputDir $DATA_DIR \
	--idFile $PRIMERS \
	--overlapStatusFnp $GENOME_TARGET_INFO/overlapStatuses.txt \
	--lenCutOffs $GENOME_TARGET_INFO/lenCutOffs.txt \
	--refSeqsDir $GENOME_TARGET_INFO/refSeqs/ \
	--extraExtractorCmds="--checkShortenBars" \
	--extraQlusterCmds="--useAllInput" \
	--extraProcessClusterCmds="--allowHomopolymerCollapse \
                               --lowFreqHaplotypeFracCutOff 0.05 \
							   --genomeFnp $REF_GENOME \
                               --gffFnp $REF_GFF \
                               --knownAminoAcidChangesFnp $KNOWN_MUTATIONS" \
	--numThreads $THREADS

# run the analysis
# ========================================================

# connect to working directory
cd $DIR_OUT

# run analysis
./runAnalysis.sh 30

# deactivate conda environment
# ========================================================
conda deactivate

# or unload modules if not using conda
# ========================================================
# module unload bowtie2
# module unload samtools
# module unload gcc/12.3.1
