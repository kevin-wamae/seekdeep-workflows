import gzip
from Bio import SeqIO
import os
from multiprocessing import Pool


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


def process_file(input_file):
    with gzip.open(input_file, "rt") as handle:
        for record in SeqIO.parse(handle, "fastq"):
            sequence = str(record.seq)
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
                        with gzip.open(output_file, "at") as output_handle:
                            SeqIO.write(record, output_handle, "fastq")


def demultiplex_fastq(input_dir, output_dir):
    input_files = [
        f"{input_dir}/barcode{str(i).zfill(2)}.fastq.gz"
        for i in range(1, 97)
        if os.path.exists(f"{input_dir}/barcode{str(i).zfill(2)}.fastq.gz")
    ]
    with Pool() as pool:
        pool.map(process_file, input_files)


# Read MID and primer information
mids = read_mids("input/run_files/mids.tsv")
primers = read_primers("input/run_files/primers.tsv")

# Directory containing barcode FASTQ files
input_dir = "/data/isabella_group/data/turkana_embatalk/2024_04_12_nanopore_r10.4.1/input/fastq_barcodes_merged"
# Directory to save demultiplexed FASTQ files
output_dir = "/data/isabella_group/data/turkana_embatalk/2024_04_12_nanopore_r10.4.1/input/fastq_demultiplexed"
if not os.path.exists(output_dir):
    os.makedirs(output_dir)

# Process the files
demultiplex_fastq(input_dir, output_dir)
