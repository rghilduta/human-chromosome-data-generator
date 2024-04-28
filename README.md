# Human Chromosome Data Generator

This bash script generates a specified number of rows of DNA sequence data from a selected human chromosome using the `art_illumina` tool from the `art-nextgen-simulation-tools` package.

## Prerequisites

- Linux operating system (tested on Ubuntu)
- `wget` command-line utility
- `art-nextgen-simulation-tools` package

## Installation

1. Clone this repository:
```git clone https://github.com/yourusername/human-chromosome-data-generator.git```

2. Navigate to the cloned directory:
```cd human-chromosome-data-generator```

3. Make the script executable:
```chmod +x generate_chromosome_data.sh```

## Usage

Run the script with the following command:
```./generate_chromosome_data.sh -c <chromosome> -l <line_length> -r <num_rows>```
- `-c <chromosome>`: Specify the chromosome number (1-22) or X or Y. Default is 11.
- `-l <line_length>`: Specify the length of each row in the output file. Default is 800.
- `-r <num_rows>`: Specify the number of rows to generate in the output file. Default is 1200.

Example:
```./generate_chromosome_data.sh -c 1 -l 1000 -r 500```
This command will generate 500 rows of length 1000 from chromosome 1.

## Output

The script will generate a file named `generate_out.csv` containing the specified number of rows of DNA sequence data from the selected chromosome. The file will be created in the same directory as the script.

## Dependencies

The script relies on the following dependencies:

- `art-nextgen-simulation-tools`: This package provides the `art_illumina` tool used for generating the DNA sequence data. The script will automatically install this package if it is not already installed.

- `wget`: This command-line utility is used for downloading the chromosome reference files from the UCSC Genome Browser. It is assumed to be already installed on the system.

## Notes

- The script performs MD5 checksum verification of the downloaded chromosome reference files to ensure data integrity.
- If the chromosome reference file is already downloaded and the MD5 checksum matches, the script will skip the download step to save time.
- The script uses a fixed random seed (`--rndSeed 42`) for reproducibility of the generated data.
- The generated output file (`generate_out.csv`) will contain the specified number of rows, with each row having the specified length of DNA sequence data.

## License

This script is open-source and available under the [MIT License](LICENSE).
