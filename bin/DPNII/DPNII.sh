#!/bin/bash

ref=$1
bin=$2
cis_loop=$3
trans_loop=$4
name=$5
genome=$6
anchorbed=${ref}/${genome}_DPNII_anchors_avg.bed

cat $cis_loop | ${bin}/remove.blacklist_DPNII.py $ref/${genome}_5kb_anchors_blacklist |${bin}/get_dist_DPNII.py $anchorbed | awk '{if($4<=2000000) print $0}' > end_loop.2M.rmbl &

cat $trans_loop |${bin}/remove.blacklist_DPNII.py $ref/${genome}_5kb_anchors_blacklist |${bin}/get_dist_DPNII.py $anchorbed | awk '{if($4>2000000) print $0}' > end_loop.gt.2M &

cat $trans_loop |${bin}/remove.blacklist_DPNII.py $ref/${genome}_5kb_anchors_blacklist > end_loop.rmbl.trans  &
wait

cat end_loop.gt.2M end_loop.rmbl.trans | cut -f1-3 > end_loop.merged.trans

${bin}/merge_sorted_anchor_loop_DPNII.pl $ref/${genome}.full.matrix end_loop.2M.rmbl > end_loop.full &

${bin}/get_trans.avg_by_len_DPNII.pl end_loop.merged.trans $ref/${genome}_anchor_length.groups $anchorbed $ref/${genome}.trans.possible.pairs > trans.stat &

wait

${bin}/get_corr_factor_by_len_DPNII.py trans.stat > len.factor 

$bin/correct.trans.reads.by.corr_DPNII.pl end_loop.merged.trans $anchorbed $ref/${genome}_anchor_length.groups len.factor > trans.corr.by.all 

${bin}/sum_anchor_reads_DPNII.py trans.corr.by.all > anchors.sum 

avg=`cat anchors.sum | awk '{s+=$2;n++}END{print s/n}'`

cat anchors.sum | awk -v avg=$avg '{print $1,$2/avg}' OFS='\t'  > anchor.vis.list

${bin}/get_group_statistics_DPNII.pl end_loop.full $anchorbed $ref/${genome}_anchor_length.groups $ref/${genome}.dist.401.group > dist.len.stat 

${bin}/get_loop_lambda_DPNII.pl end_loop.full $anchorbed $ref/${genome}_anchor_length.groups $ref/${genome}.dist.401.group dist.len.stat > end_loop.after.dist.len

${bin}/add.vis.to.cis.2M_DPNII.pl end_loop.after.dist.len anchor.vis.list > end_loop.after.vis
wait

Rscript $bin/integrated.r $fullstat

mkdir HiCorr_output
for file in `ls split/`;do
        chr=${file#anchor_2_anchor.loop.}
	$bin/list_full_matrix_DPNII.pl <(cat $anchorbed | awk '{if($1=="'$chr'")print}')> 2000000 | perl $bin/merge_sorted_anchor_loop_DPNII.pl - ./split/anchor_2_anchor.loop.$chr | python $bin/remove.blacklist_DPNII.py $blacklist | $bin/get_loop_lambda_DPNII.pl - $anchorbed $ref/${genome}_anchor_length.groups $ref/${genome}.dist.401.group integrated.dist.len.stat | $bin/add.vis.to.cis.2M_DPNII.pl - anchor.vis.list > HiCorr_output/anchor_2_anchor.loop.$chr
done

