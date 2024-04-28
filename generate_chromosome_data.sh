#!/bin/bash

# Function to check if the input is a valid chromosome number or X/Y
is_valid_chromosome() {
    if [[ $1 =~ ^([1-9]|1[0-9]|2[0-2]|[XY])$ ]]; then
        return 0
    else
        return 1
    fi
}

CHROMO=11
LINE_LEN=800
NUM_ROWS=1200
# Check if the -c option is provided
while getopts ":c:l:r:" opt; do
    case $opt in
        c)
            if is_valid_chromosome "$OPTARG"; then
                CHROMO="$OPTARG"
                echo "Chromosome set to: $CHROMO"
            else
                echo "Invalid chromosome specified. Please provide a number between 1 and 22 (inclusive) or X or Y."
                exit 1
            fi
            ;;
        l)
            if [[ $OPTARG =~ ^[0-9]+$ ]]; then
                LINE_LEN="$OPTARG"
                echo "[+] Line length set to: $LINE_LEN"
            else
                echo "[-] Invalid line length specified. Please provide a positive integer."
                exit 1
            fi
            ;;
        r)
            if [[ $OPTARG =~ ^[0-9]+$ ]]; then
                NUM_ROWS="$OPTARG"
                echo "[+] Row count set to: $NUM_ROWS"
            else
                echo "[-] Invalid row count specified. Please provide a positive integer."
                exit 1
            fi
            ;;
        \?)
            echo "Invalid option: -$OPTARG"
            exit 1
            ;;
    esac
done

echo "Selecting Human Chromosome $CHROMO"

# Rest of your script commands go here
# ...
# Check if art-nextgen-simulation-tools is already installed
if dpkg -s art-nextgen-simulation-tools >/dev/null 2>&1; then
    echo "[+] art-nextgen-simulation-tools is already installed."
else
    echo "[ ] art-nextgen-simulation-tools is not installed. Installing now..."
    
    # Update package list
    sudo apt update
    
    # Install art-nextgen-simulation-tools
    sudo apt install -y art-nextgen-simulation-tools
    
    if [ $? -eq 0 ]; then
        echo "[+] art-nextgen-simulation-tools installation completed successfully."
    else
        echo "[-] Failed to install art-nextgen-simulation-tools. Please check the error messages."
	exit 1
    fi
fi


# Check if chr${CHROMO}.subst.fa.gz file already exists
if [ -f "chr${CHROMO}.subst.fa.gz" ] || [ -f "chr${CHROMO}.subst.fa" ]; then
    echo "[+] chr${CHROMO}.subst.fa.gz already exists. Skipping download."
else
    # Download the chr${CHROMO}.subst.fa.gz file
    echo "[ ] Downloading chr${CHROMO}.subst.fa.gz..."
    wget -q "https://hgdownload.soe.ucsc.edu/goldenPath/hg38/snp151Mask/chr${CHROMO}.subst.fa.gz"

    if [ $? -ne 0 ]; then
        echo "[-] Failed to download chr${CHROMO}.subst.fa.gz. Please check the URL and try again."
        exit 1
    fi
    echo "[+] Downloaded chr${CHROMO}.subst.fa.gz."
fi

if [ -f "chr${CHROMO}.subst.fa.gz" ]; then
    # Check if md5sum.txt file already exists
    if [ -f "md5sum.txt" ]; then
        echo "[+] md5sum.txt already exists. Skipping download."
    else
        # Download the md5sum.txt file
        echo "[ ] Downloading md5sum.txt..."
        wget -q "https://hgdownload.soe.ucsc.edu/goldenPath/hg38/snp151Mask/md5sum.txt"
    
        if [ $? -ne 0 ]; then
            echo "[-] Failed to download md5sum.txt. Please check the URL and try again."
            exit 1
        fi
        echo "[+] Downloaded md5sum.txt."
    fi
    
    # Extract the expected MD5 checksum for chr${CHROMO}.subst.fa.gz from md5sum.txt
    expected_md5=$(grep "chr${CHROMO}.subst.fa.gz" md5sum.txt | cut -d ' ' -f 1)
    
    if [ -z "$expected_md5" ]; then
        echo "[-] No MD5 checksum found for chr${CHROMO}.subst.fa.gz in md5sum.txt."
        exit 1
    fi
    
    # Calculate the MD5 checksum of the chr${CHROMO}.subst.fa.gz file
    actual_md5=$(md5sum chr${CHROMO}.subst.fa.gz | cut -d ' ' -f 1)
    
    # Compare the expected and actual MD5 checksums
    if [ "$expected_md5" != "$actual_md5" ]; then
        echo "[-] MD5 checksum verification failed for chr${CHROMO}.subst.fa.gz."
        echo "[-] Expected: $expected_md5"
        echo "[-] Actual:   $actual_md5"
        exit 1
    else
        echo "[+] MD5 checksum verification successful for chr${CHROMO}.subst.fa.gz."
    fi
    gunzip -d ./chr${CHROMO}.subst.fa.gz
fi


echo "[ ] Generating $NUM_ROWS rows of $LINE_LEN length data."
set +e
art_illumina -ss MSv3 -sam -i ./chr${CHROMO}.subst.fa -c $((NUM_ROWS*LINE_LEN*4/250)) -l 250 -o temp_output --rndSeed 42 > /dev/null
echo "[+] Finished"
 
grep -v "^@" temp_output.sam | grep -v "^##" | sed 's/[^ATGC]//g' | grep -v '^$' |
while read -r line; do
    echo $line;
done | sed '1~2d' | tr -d '\n' | fold -w $LINE_LEN | head -n $NUM_ROWS > generate_out.csv
echo "Generated file contains $(wc -l generate_out.csv) rows of length $(tail -n 1 generate_out.csv | tr -d '\n' |  wc -c)"
