date
echo "This is more like an interactive script, try to use it manually"


### local variables
pipe_path="/data/sml6467/github/Microbial_dark_matter_explore/src"
data="/data/sml6467/github/Microbial_dark_matter_explore/data"
out="/data/sml6467/github/Microbial_dark_matter_explore/local_test"
all_ref_files="/data/shared_data/sourmash_data/redo_gtdb_genomes_reps_r207_sketch/file_list.txt"
sourmash_ref_dir="/data/shared_data/sourmash_data/redo_gtdb_genomes_reps_r207_sketch/out_dir"
cami2_sig_files="/data/sml6467/github/Microbial_dark_matter_explore/data/cami2_sourmash_sketch/abs_path_cami2_sig.txt"


### build sourmash sketch
# download from their web
# build by sketch / compute (depreciated) based on your data
# check here: 
# /data/shared_data/sourmash_data/redo_gtdb_genomes_reps_r207_sketch/run_parallel.sh



################################## part1, input data
### download test input data
cd ${data}
# gold standard genomes
wget https://frl.publisso.de/data/frl:6425521/strain/strmgCAMI2_genomes.tar.gz
# sample 1 short reads
wget https://frl.publisso.de/data/frl:6425521/strain/short_read/strmgCAMI2_sample_1_reads.tar.gz
# sample 1 contigs
wget https://frl.publisso.de/data/frl:6425521/strain/short_read/strmgCAMI2_sample_1_contigs.tar.gz
# sample 1 bam
wget https://frl.publisso.de/data/frl:6425521/strain/short_read/strmgCAMI2_sample_1_bam.tar.gz



### check ref genomes
tar -xvzf  strmgCAMI2_genomes.tar.gz
# there are 408 ref genomes
mv short_read/source_genomes/ CAMI2_ref_genomes
rmdir short_read
rm strmgCAMI2_genomes.tar.gz
# build sourmash sketch
mkdir -p cami2_sourmash_sketch 
readlink -f ./CAMI2_ref_genomes/*.fasta > ./cami2_sourmash_sketch/abs_path_cami2_ref.txt
cd cami2_sourmash_sketch
for file in $(cat abs_path_cami2_ref.txt); do
  sourmash compute -k 31 --dna --scaled 2000 ${file}
done
# get a list of cami2 sig files (may mask out part)
readlink -f *sig > abs_path_cami2_sig.txt
cd ../..
# build bwa ref ???



### check short reads
# anonymous_reads are fq, and the mapping file is the truth
tar -xvzf strmgCAMI2_sample_1_reads.tar.gz
mv short_read/2018.09.07_11.43.52_sample_1/reads/*.gz .
rm -r short_read
rm strmgCAMI2_sample_1_reads.tar.gz




################################## part2, sourmash gather of metagenome
## additional note:
# 1. need to run quality filter and containmination scan first for real data

input_genome=${data}/anonymous_reads.fq.gz
cd ${out}
mkdir output_cami2_sample1
cd output_cami2_sample1
sourmash compute -k 31 --dna --scaled 10000 ${input_genome}
# too many sigs: argument list too long, need to use traverse-dir
ltime sourmash gather -o sourmash_gather_out.csv  anonymous_reads.fq.gz.sig ${sourmash_ref_dir} --traverse-directory
### SL comments:
# 1. need to specify cutoffs for better efficienty (e.g. >5% CI or > 500k overlap)
# default is <40k
# for GTDB: 26min with <1G MEM

### clean sourmash gather output file
grep GC  sourmash_gather_out.csv | cut -d"," -f 4 > temp
cat temp | sed 's|^.*\/GC|GC|g' > hit_genomes.txt && rm temp 
grep -f  hit_genomes.txt ${all_ref_files}  > target_list.txt
target_genome_list=$(readlink -f target_list.txt)
# merge into one file
touch merged_genome.fa.gz
for file in $(cat ${genome_list}); do
  cat ${file} >> merged_genome.fa.gz
done






################################## Call out Pipe1, alignment-based filter
bash ${pipe_path}/pipe1_alignment-based_filter_for_high_simi_reads.sh ${input_genome} ${target_genome} 







################################## Call out Pipe2, de novo assembly + seed-extension for undiscovered contigs/MAGs





################################## Call out Pipe3, taxonomic assignment of novel MAGs OR ref-guided exploration 






################################## is there anything remains?







