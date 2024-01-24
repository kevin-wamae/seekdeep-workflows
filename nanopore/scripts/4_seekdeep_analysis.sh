#!/bin/bash
#*********************************************************
# This script is for running SeekDeep analysis on nanopore data_dir.
# It should be run from the root of the project directory

# ========================================================
#--- Start of slurm commands ---
# ========================================================

#SBATCH -J SeekDeep
#SBATCH --time=01:00:00
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=10G
#SBATCH -o job.%j.out
#SBATCH -e job.%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=wamaekevin@gmail.com

# ========================================================
# load modules, if needed, otherwise load conda environment with these tools
# ========================================================

# module load gcc
# module load samtools
# module load bowtie2

# ========================================================
# activate conda environment, if not using modules
# ========================================================

source "${HOME}/mambaforge/etc/profile.d/conda.sh"
conda activate seekdeep

# ========================================================
# variables for SeekDeep analysis
# ========================================================

# directories and files
# --------------------------------------------------------
wd=${PWD}
data_dir=$wd/input/fastq_barcodes_merged

# sample names
# --------------------------------------------------------
sampleNames=$wd/input/run_files/sampleNames.txt

# reference (genome, gff, known mutations)
# --------------------------------------------------------
reference=$wd/input/genomes

# primers
# --------------------------------------------------------
primers=$wd/input/run_files/primers.txt

# output directory, rename to user's preference
# --------------------------------------------------------
out_dir=$wd/output/2024_01_01-test

# insert size
# --------------------------------------------------------
insert_size=300

# output directories for targets
# --------------------------------------------------------
genomeTargetInfo=$wd/input/genome_target_info

# number of threads for pipeline and clustering
# --------------------------------------------------------
threadsPipeline=4
threadsClustering=2

# define a variable for control samples to be excluded from population analysis
# this is applicable if you have control samples in your dataset, which this test
# dataset does not have
# --------------------------------------------------------
control_samples="Control-3D7,Control-7G8,Control-HB3"

# ========================================================
# SeekDeep - setup tar amp analysis to generate wrapper scripts
# ========================================================

SeekDeep setupTarAmpAnalysis \
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
   --extraProcessClusterCmds="--controlSamples $control_samples \
                              --sampleMinTotalReadCutOff 250 \
                              --replicateMinTotalReadCutOff 250 \
                              --lowFreqHaplotypeFracCutOff 0.05 \
                              --gffFnp $reference/info/gff/Pf3D7.gff \
                              --genomeFnp $reference/genomes/Pf3D7.fasta \
                              --knownAminoAcidChangesFnp $reference/info/pf_drug_resistant_aaPositions.tsv" \
   --previousPopSeqsDir $genomeTargetInfo/forSeekDeep/refSeqs \
   --numThreads $threadsPipeline

# run the analysis
# --------------------------------------------------------
cd $out_dir
./runAnalysis.sh $threadsPipeline

# ========================================================
# unload modules
# ========================================================

# module unload gcc
# module unload samtools
# module unload bowtie2

# ========================================================
# deactivate conda environment
# ========================================================

conda deactivate
