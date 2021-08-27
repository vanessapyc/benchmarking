#!/usr/bin/env bash

# This is a script for benchmarking

# Databases used for ${KRAKEN_DB}
# 1. Default (RefSeq bacteria, archaea and viral libraries, and GRCh38 human genome): minikraken2_v2_8GB_201904_UPDATE,
# url = https://ccb.jhu.edu/software/kraken2/index.shtml?t=downloads (ftp://ftp.ccb.jhu.edu/pub/data/kraken2_dbs/old/minikraken2_v2_8GB_201904.tgz)
# 2. Default + nanopore genomes: database name of your choice
# 3. Bacteria: database name of your choice
# 4. nt: database name of your choice
# 5. 16S Silva: database name of your choice
# 6. GTDB_r89_54k: gtdb_r89_54k_kraken2_04gb, url = https://bridges.monash.edu/articles/dataset/GTDB_r89_54k/8956970?file=16378262

# 1. Building the Kraken 2 Databases:
# Databases for the default and GTDB_r89_54k databases are pre-built and located in the above links.

# Building the Kraken 2 default (RefSeq bacteria, archaea and viral libraries, and GRCh38 human genome) and nanopore genome database:
kraken2-build --download-taxonomy --db ${KRAKEN_DB} --threads ${THREADS}

kraken2-build --download-library bacteria --db ${KRAKEN_DB} --threads ${THREADS}
kraken2-build --download-library archaea --db ${KRAKEN_DB} --threads ${THREADS}
kraken2-build --download-library viral --db ${KRAKEN_DB} --threads ${THREADS}
kraken2-build --download-library human --db ${KRAKEN_DB} --threads ${THREADS}

kraken2-build --add-to-library ${NANOPORE_FILE1}.fasta --db ${KRAKEN_DB}
kraken2-build --add-to-library ${NANOPORE_FILE2}.fasta --db ${KRAKEN_DB}
kraken2-build --add-to-library${NANOPORE_FILE3}.fasta --db ${KRAKEN_DB}
kraken2-build --add-to-library ${NANOPORE_FILE4}.fasta --db ${KRAKEN_DB}

kraken2-build --build --db ${KRAKEN_DB} --threads ${THREADS}

# Building the Kraken 2 bacteria database:
kraken2-build --download-taxonomy --db ${KRAKEN_DB} --threads ${THREADS}
kraken2-build --download-library bacteria --db ${KRAKEN_DB} --threads ${THREADS}
kraken2-build --build --db ${KRAKEN_DB} --threads ${THREADS}

# Building the Kraken 2 nt database:
kraken2-build --download-taxonomy --db ${KRAKEN_DB} --threads ${THREADS}
kraken2-build --download-library nt --db ${KRAKEN_DB} --threads ${THREADS}
kraken2-build --build --db ${KRAKEN_DB} --threads ${THREADS}

# Building the Kraken 2 16S silva database:
kraken2-build --download-taxonomy --db ${KRAKEN_DB} --threads ${THREADS}
kraken2-build --db silva_db --special silva --threads ${THREADS}
kraken2-build --build --db ${KRAKEN_DB} --threads ${THREADS}

# 2. Running Kraken 2:
kraken2 --db ${KRAKEN_DB} --report ${REPORT_NAME}.report.txt --gzip-compressed --paired ${SAMPLE_R1}.fastq.gz ${SAMPLE_R2}.fastq.gz > ${KRAKEN_OUTPUT_FILE}.kraken --threads ${THREADS}

# 3. Generating the Bracken database files:
bracken-build -d ${KRAKEN_DB} -t ${THREADS} -l ${READ_LEN}

# Note: The Bracken database files for the default (RefSeq and human genome) Kraken2 database is already included in the Minikraken2 file.

# 4. Running Bracken:
bracken -d ${KRAKEN_DB} -i ${REPORT_NAME}.report.txt -l S -o ${BRACKEN_OUTPUT_FILE}.bracken -r ${READ_LEN} 

# Centrifuge ${INDEX_FILENAME} for different databases
# 1. Default (bacteria, archaea, viruses, human (compressed)): p_compressed+h+v
# url = http://www.ccb.jhu.edu/software/centrifuge/index.shtml (https://genome-idx.s3.amazonaws.com/centrifuge/p_compressed%2Bh%2Bv.tar.gz)
# 2. GTDB_r89_54k: ex, url = https://bridges.monash.edu/articles/dataset/GTDB_r89_54k/8956970?file=16378439 (gtdb_r89_54k_centrifuge.tar)

# 5. Running Centrifuge:
centrifuge -x ${INDEX_FILENAME} -1 ${SAMPLE_R1}.fastq.gz -2 ${SAMPLE_R2}.fastq.gz --report-file ${REPORT_NAME}.report.txt -S {CLASSIFICATION_OUTPUT}.txt

# Databases for Kaiju
# 1. Default (RefSeq): url = https://kaiju.binf.ku.dk/server (https://kaiju.binf.ku.dk/database/kaiju_db_refseq_2021-02-26.tgz)
# 2. proGenomes: url = https://kaiju.binf.ku.dk/server (https://kaiju.binf.ku.dk/database/kaiju_db_progenomes_2021-03-02.tgz)

# 6. Running Kaiju and Krona:
kaiju -t nodes.dmp -f ${KAIJU_DB}.fmi -i ${SAMPLE_R1}.fastq.gz -j ${SAMPLE_R2}.fastq.gz -o ${KAIJU_OUTPUT}.out 
kaiju2krona -t nodes.dmp -n names.dmp -i ${KAIJU_OUTPUT}.out -o ${KRONA_OUTPUT}.krona -u 
ktImportText -o ${KRONA_OUTPUT}.krona.html ${KRONA_OUTPUT}.krona

# Note: {KAIJU_DB}.fmi should be replaced by the actual .fmi file, which depends on the database being used.