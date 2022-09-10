#!/bin/bash

# usage: bash <pipe> <meta fq> <target genome>
date

raw_reads=$1
genome_list=$2
[ -z "${raw_reads}" ] && echo "missing parameter" && exit 1
[ -z "${target_genome}" ] && echo "missing parameter" && exit 1
# put thread to parameters in future
threads=16



ltime="/usr/bin/time -av -o temp_runLog"
pipe_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


minimap2 -o minimap2_out.sam -ax sr -t ${threads} -2 -n 1 --secondary=yes ${target_genome} ${raw_reads}


####### separate aligned and unaligned reads
### uniquely mapped reads
# don't use sort -u, too slow and disrupt the original order
# these numbers have been verified by counting fq file
samtools view -q 30 minimap2_out.sam | cut -f 1 | awk 'p!=$0; {p=$0}' > seq_id_uniquely_mapped.txt
samtools view -F 12 minimap2_out.sam | cut -f 1 | awk 'p!=$0; {p=$0}' > seq_id_mapped.txt
less ${raw_reads} | awk 'NR%4==1' | sed 's/@//g' | sed 's|\/[1,2]||g' | awk 'p!=$0; {p=$0}' > seq_id_all.txt 
grep -v -w -f seq_id_mapped.txt seq_id_all.txt > seq_id_non_map.txt
### count all numbers
wc -l seq_id_* | awk '{print $2"\t"$1}' | sed -n '1,4p' > output_read_number_in_each_category.txt




######## split fastq file (this step could be slow when fq is large)
less ${raw_reads} | paste - - - - > temp_oneline_fq.fq
# grep and re-line
grep -F -f <(awk '{print "@"$0"/"}' seq_id_non_map.txt) temp_oneline_fq.fq | tr '\t' '\n' > reads_unmapped.fq
grep -F -f <(awk '{print "@"$0"/"}' seq_id_mapped.txt) temp_oneline_fq.fq | tr '\t' '\n' > reads_mapped.fq
grep -F -f <(awk '{print "@"$0"/"}' seq_id_uniquely_mapped.txt) temp_oneline_fq.fq | tr '\t' '\n' > reads_uniquely_mapped.fq
rm temp_oneline_fq.fq

### run fastq
mkdir output_fastqc_unmapped
fastqc -t $threads reads_unmapped.fq -o output_fastqc_unmapped
mkdir output_fastqc_mapped
fastqc -t $threads reads_mapped.fq -o output_fastqc_mapped
mkdir output_fastqc_uniquely_mapped
fastqc -t $threads reads_uniquely_mapped.fq -o output_fastqc_uniquely_mapped



### add some summarize plots?













