# Overview

The [SeekDeep](https://github.com/bailey-lab/SeekDeep) pipeline is a bioinformatics tool for analyzing targetted sequencing data.

It is designed to identify and quantify genetic variants in a mixed population of DNA sequences and tutorials can be found [here](https://seekdeep.brown.edu/)

This pipeline for analysing nanopore data consists of four main steps:

- Downloading preformatted blast databases for the genomes of interest.
- Merging the fastq files from the different barcodes
- Generating target info (information) files for SeekDeep, and
- Running the analysis pipeline using the merged fastq files and the target info files.

---

# Directory structure

```
.
├── input
│   ├── fastq_barcodes
│   │   ├── barcode01
│   │   └── barcode02
│   ├── fastq_barcodes_merged
│   ├── genomes
│   ├── genome_target_info
│   └── run_files
│       ├── primers.txt
│       └── sampleNames.txt
├── output
└── scripts
    ├── 1_download_genomes.sh
    ├── 2_merge_fastqs.sh
    ├── 3_seekdeep_target_info.sh
    └── 4_seekdeep_analysis.sh
```

---

# Pipeline Steps

This pipeline should be run from the `projects/seekdeep/nanopore` directory.

## **Step 1: Download Preformatted Blast Databases**

The pipeline begins with either downloading or the generation of bowtie2 indexes corresponding to the genomes of interest. These indexes are essential for SeekDeep's functionality, as they facilitate the extraction of target sequences using the provided primers.

- The indexes used here contains genome sequences of _P. falciparum_.

- To execute this step, run:
  - `bash scripts/1_download_genomes.sh`

## **Step 2: Merge Fastq Files**

Next, we merge multiple FastQ files from the different barcodes (`input/fastq_barcodes/barcode*/`) into single FastQ files (`input/fastq_barcodes_merged/barcode*/`). This simplification step is crucial for streamlining the SeekDeep analysis.

- To perform this merging, run:
  - `bash scripts/2_merge_fastq.sh`

## **Step 3: Generate Target Info Files**

The third step involves generating target info files for SeekDeep. It automatically generates several of the files used by the SeekDeep pipeline mostly in the extraction step. It is also useful for checking if primers match against several reference genomes.

- For each target being analyzed, the primers used to amplify the target sequence are provided in a separate file (`input/run_files/primers.txt`).
- Additional, for each sample being analyzed, the sample name file (`input/run_files/sampleNames.txt`) must contain the target(s) being analyzed, the sample name and the barcode matching the respective sample.

- To create the target info files, run:
  - `bash scripts/3_generate_target_info.sh`

- Alternatively, you can submit the target info generation as a job to a cluster using the following command:
  - `sbatch scripts/3_generate_target_info.sh`

## **Step 4: Run SeekDeep Analysis**

The final step is to run the SeekDeep analysis pipeline using the merged FastQ files and the target info files. This step involves executing the SeekDeep analysis command with the appropriate parameters.

- To run the SeekDeep analysis, execute:
  - `bash scripts/4_run_seekdeep.sh`

- Alternatively, you can submit the SeekDeep analysis as a job to a cluster using the following command:
  - `sbatch scripts/4_run_seekdeep.sh`

---

## **Feedback and Issues**

Report any issues or bugs by openning an issue [here](https://github.com/kevin-wamae/seekdeep-analysis-workflows/issues) or contact me via email at **wamaekevin[at]gmail.com**
