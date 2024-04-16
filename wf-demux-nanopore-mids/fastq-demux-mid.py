import gzip
from Bio import SeqIO


def demultiplex_fastq(input_file, primer, output_dir):
    # Open the gzipped FASTQ file for reading
    with gzip.open(input_file, "rt") as handle:
        # Parsing the FASTQ file
        for record in SeqIO.parse(handle, "fastq"):
            sequence = str(record.seq)
            # Locate the primer in the sequence
            primer_pos = sequence.find(primer)
            if (
                primer_pos != -1 and primer_pos >= 10
            ):  # Check if there's space for the MID
                # Extract the MID (10 bases before the primer)
                mid = sequence[primer_pos - 10 : primer_pos]
                # Extract barcode from the record description
                barcode = [
                    s for s in record.description.split() if s.startswith("barcode=")
                ][0].split("=")[1]
                # Prepare the output file name
                output_file = f"{output_dir}/{barcode}-{mid}.fastq"
                # Write the record to the corresponding output file
                with open(output_file, "a") as output_handle:
                    SeqIO.write(record, output_handle, "fastq")


# Usage example:
demultiplex_fastq("input/barcode03.fastq.gz", "GAAATGTCCAGTATTTGGTAAAGG", "output")
