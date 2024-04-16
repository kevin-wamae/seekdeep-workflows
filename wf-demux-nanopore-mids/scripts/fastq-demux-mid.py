import gzip
from Bio import SeqIO
import os


def read_mids(mid_file):
    # Read MID mappings from a tab-separated file
    mids = {}
    with open(mid_file, "r") as f:
        next(f)  # Skip the header
        for line in f:
            parts = line.strip().split("\t")
            mids[parts[1]] = parts[0]  # mid-sequence to mid-name mapping
    return mids


def read_primers(primer_file):
    # Read primer mappings from a tab-separated file
    primers = {}
    with open(primer_file, "r") as f:
        next(f)  # Skip the header
        for line in f:
            parts = line.strip().split("\t")
            primers[parts[1]] = parts[0]  # forward primer to target mapping
    return primers


def demultiplex_fastq(input_dir, output_dir, mids, primers):
    # Loop over all barcode files
    for i in range(1, 97):
        input_file = f"{input_dir}/barcode{str(i).zfill(2)}.fastq.gz"
        if not os.path.exists(input_file):
            continue
        with gzip.open(input_file, "rt") as handle:
            for record in SeqIO.parse(handle, "fastq"):
                sequence = str(record.seq)
                # Check each primer in the sequence
                for primer_seq, target in primers.items():
                    primer_pos = sequence.find(primer_seq)
                    if primer_pos != -1 and primer_pos >= 10:
                        mid_seq = sequence[primer_pos - 10 : primer_pos]
                        if mid_seq in mids:
                            mid_name = mids[mid_seq]
                            barcode = input_file.split("/")[-1].split(".")[0]
                            output_file = (
                                f"{output_dir}/{barcode}-{target}-{mid_name}.fastq.gz"
                            )
                            # Open the output file in append mode with gzipped format
                            with gzip.open(output_file, "at") as output_handle:
                                SeqIO.write(record, output_handle, "fastq")


# Read MID and primer information
mids = read_mids("input/run_files/mids.tsv")
primers = read_primers("input/run_files/primers.tsv")

# Directory containing barcode FASTQ files
input_dir = "input/fastq"
# Directory to save demultiplexed FASTQ files
output_dir = "output"
if not os.path.exists(output_dir):
    os.makedirs(output_dir)

# Process the files
demultiplex_fastq(input_dir, output_dir, mids, primers)
