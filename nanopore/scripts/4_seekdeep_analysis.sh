#!/bin/bash
#*********************************************************
# VERSION 2

# ********************************************************
#--- Start of slurm commands ---
# ********************************************************

#SBATCH -J CRT
#SBATCH --time=01:00:00
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=25G
#SBATCH -o job.%j.out
#SBATCH -e job.%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=wamaekevin@gmail.com

# ********************************************************
# load modules
# ********************************************************

# module load gcc/10.2
# module load samtools/1.16.1
# module load bowtie2/2.4.2

# ********************************************************
# activate conda environment
# ********************************************************

source "${HOME}/mambaforge/etc/profile.d/conda.sh"
conda activate seekdeep

# ********************************************************
# working directories and files
# ********************************************************

# input directories and files
# --------------------------------------------------------
dirWrk=/nfs/jbailey5/baileyweb/colabs/kwamae/projects/ade_ont_tads_nigeria_seekdeep
dirData=$dirWrk/input/fastq_barcodes_merged

# sample names
# --------------------------------------------------------
sampleNames_2x150=$dirWrk/input/run_files/sampleNames_2x150.txt

# resources (genome, gff, known mutations)
resources=/nfs/jbailey5/baileyweb/colabs/kwamae/resources/seekdeep_ref_genomes/plasmodium_plasmodb_pacbio

# primers
# --------------------------------------------------------
primers_2x150=$dirWrk/input/run_files/primers_2x150.txt

# output directories per primer set
# --------------------------------------------------------
dirOut_2x150=$dirWrk/output/2023_12_03-CRT

# insert sizes
# --------------------------------------------------------
insert_size_150=150

# output directories for targets
# --------------------------------------------------------
dirRefs_2x150=$dirWrk/target_info/2x150

# number of threads for pipeline and clustering
# --------------------------------------------------------
threadsPipeline=10
threadsClustering=2

# ********************************************************
# SeekDeep - get target info from genomes
# ********************************************************

# # generate the target info
# # --------------------------------------------------------
# SeekDeep genTargetInfoFromGenomes \
#    --primers $primers_2x150 \
#    --pairedEndLength $insert_size_150 \
#    --genomeDir $resources/genomes/ \
#    --gffDir $resources/info/gff \
#    --errors 2 \
#    --dout $dirRefs_2x150 \
#    --numThreads $threadsPipeline \
#    --shortNames \
#    --overWriteDir

# ********************************************************
# SeekDeep - setup tar amp analysis
# ********************************************************

# generate wrapper scripts
# --------------------------------------------------------
SeekDeep setupTarAmpAnalysis \
   --samples $sampleNames_2x150 \
   --outDir $dirOut_2x150 \
   --technology nanopore \
   --uniqueKmersPerTarget $dirRefs_2x150/forSeekDeep/uniqueKmers.tab.txt.gz \
   --inputDir $dirData \
   --idFile $primers_2x150 \
   --lenCutOffs $dirRefs_2x150/forSeekDeep/lenCutOffs.txt \
   --doNotGuessRecFlags \
   --extraExtractorCmds="--primerWithinStart 100 \
                         --minLenCutOff 100 \
                         --qualCheckLevel 11" \
   --extraKlusterCmds="--readLengthMinDiff 100 \
                       --numThreads $threadsClustering" \
   --extraProcessClusterCmds="--controlSamples Control-3D7,Control-7G8,Control-HB3 \
                              --sampleMinTotalReadCutOff 250 \
                              --replicateMinTotalReadCutOff 250 \
                              --lowFreqHaplotypeFracCutOff 0.05 \
                              --gffFnp $resources/info/gff/Pf3D7.gff \
                              --genomeFnp $resources/genomes/Pf3D7.fasta \
                              --knownAminoAcidChangesFnp $resources/info/pf_drug_resistant_aaPositions_k13_all.tsv" \
   --previousPopSeqsDir $dirRefs_2x150/forSeekDeep/refSeqs \
   --numThreads $threadsPipeline

# run the analysis
# --------------------------------------------------------
cd $dirOut_2x150
./runAnalysis.sh $threadsPipeline

# ********************************************************
# unload modules
# ********************************************************

# module unload gcc/10.2
# module unload samtools/1.16.1
# module unload bowtie2/2.4.2

# ********************************************************
# deactivate conda environment
# ********************************************************

conda deactivate
