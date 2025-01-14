## Generate HiCorr reference files for given restriction enzyme cutting site and genome build
Download chr.fa and chrom.size in UCSC FTP sites, e.g. hg19:

**_chr.fa files_**: https://hgdownload.cse.ucsc.edu/goldenPath/hg19/chromosomes/ </br>
**_chrom.size_**: https://hgdownload.soe.ucsc.edu/goldenPath/hg19/bigZips/hg19.chrom.sizes </br>
**_blacklist region_**: https://github.com/Boyle-Lab/Blacklist </br>
All the scripts are in https://github.com/JinLabBioinfo/HiCorr/tree/master/documents/lib

Define the following variable before run the next trunk
```
# DpnII cutting site: GATC </br>
genome=hg19
Enzyme=DPNII
seq=GATC
# get $blacklist by overlapping ${genome}.${Enzyme}.frag.bed and blacklist file
blacklist.frag= 
chr.fa.dir=
chromsize=
```
## Note: We suggest users run the following commands in the "HiCorr/documents/lib/" directory


```
lib=./lib/

#step1 : generate the cutting sites bed files
$lib/find_RE_sites.pl $chr.fa.di $chromsiz $seq > $genome.$seq.cutting.sites 

#step2: transfer the cutting sites to the fragment bed
$lib/sites_to_frag.py $genome.size $genome.$seq.cutting.sites | awk '{print $0,$3-$2+1}' OFS='\t' >  $genome.$seq.frag.bed

#step3: map the fragment to anchor
$lib/generate.fragment.py $genome.$seq.frag.bed 5000 > frag.2.anchor 

#step4: Generate the average length of each anchor
$lib/get_aveg_frag_length.py frag.2.anchor anchor.bed > $genome.$seq.anchor.5kb.bed

#step5: Generate the length group
$lib/get_group_range.pl $genome.$seq.anchor.5kb.bed 6 20 > $genome_anchor_length.groups

#step6: Generate the trans possible pairs
$lib/count_trans_pairs_by_GC.pl $genome.$seq.anchor.5kb.bed $genome.$seq.anchor.5kb.bed ${genome}_anchor_length.groups > $genome.trans.possible.pairs

#step7: Generate the whole matrix
$lib/list_full_matrix.pl $genome.$seq.anchor.5kb.bed 2000000 | python $lib/remove.blacklist.py $blacklist.frag > $genome.full.filter.matrix 

```
## The reference files can be generated by the commands above or upon request.
