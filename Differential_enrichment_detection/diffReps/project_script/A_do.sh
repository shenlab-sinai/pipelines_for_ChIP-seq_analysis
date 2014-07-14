#! /usr/bin/env bash

# project path
export PRO="${HOME}/projects/current_date.PROJECT_TITLE"
# results path
export RESULT="${PRO}/result/diffReps/date_PROJECT_diffReps"
mkdir -p ${RESULT}
# input bam path
export DATA="${PRO}/data"

# cores to be used in processing
export CORES=8

# genome info
export GENOME_DIFFREPS=mm9
export GENOME=mm9

# preprocess for the bam files, from bam to bed
BAMS=`ls ${DATA}/*.bam`
BAMS=${BAMS//${DATA}\//}
BAMS=${BAMS//.bam/}

# parameters for diffReps
P_VAL="1e-4"
FDR_CUTOFF=0.10
FC_CUTOFF=1 # cutoff of log2(foldchange), 1=log2(2)
DIFFREPS_TEST="nb"
NSD=2

# parameters for HOMER GO analysis
GO_HOMER_P_VAL_CUTOFF=0.05

function BAM2BED(){
    bamToBed -i ${2}/${1}.bam > ${3}/01_${1}.bed;
}
export -f BAM2BED
echo -e "${BAMS[@]}" | xargs -P ${CORES} -n 1 -I{} bash -c 'BAM2BED "{}" "${DATA}" "${RESULT}"'
wait

# remove duplicates from bed
function RMDUPofBED(){
    RESULT=${1}
    BAM=${2}
    rmdup_sorted_bed.pl ${RESULT}/01_${BAM}.bed ${RESULT}/02_${BAM}.bed 1
    grep -v random ${RESULT}/02_${BAM}.bed | grep -v chrUn > ${RESULT}/03_${BAM}.bed;
}
export -f RMDUPofBED
echo -e "${BAMS[@]}" | xargs -P ${CORES} -n 1 -I{} bash -c 'RMDUPofBED "${RESULT}" "{}"'
wait

# main body of the pipeline
function doDiffReps(){
    declare -a T=("${!1}")
    declare -a C=("${!2}")
    declare -a TI=("${!3}")
    declare -a CI=("${!4}")
    CORES=${5}
    GENOME_DIFFREPS=${6}
    RESULT=${7}
    TAG=${8}
    DIFFREPS_TEST=${9}
    P_VAL=${10}
    NSD=${11}
    FC_CUTOFF=${12}
    FDR_CUTOFF=${13}
    GENOME=${14}
    GO_HOMER_P_VAL_CUTOFF=${15}
    diffReps.pl -tr ${T[@]} -co ${C[@]} --btr ${TI[@]} --bco ${CI[@]} \
        --nproc ${CORES} -gn ${GENOME_DIFFREPS} \
        --re ${RESULT}/04_diff.${TAG}.${DIFFREPS_TEST}.txt \
        -me ${DIFFREPS_TEST} -pval ${P_VAL} --nsd ${NSD}

    awk -v fc=${FC_CUTOFF} -v fdr=${FDR_CUTOFF} \
        '{if(($12>=fc)&&($14<=fdr)&&($11=="Up")){print $0}}' \
        ${RESULT}/04_diff.${TAG}.${DIFFREPS_TEST}.txt.annotated \
        > ${RESULT}/result/${TAG}_up_anno.txt
    head -1 ${RESULT}/04_diff.${TAG}.${DIFFREPS_TEST}.txt.annotated \
        | cat - ${RESULT}/result/${TAG}_up_anno.txt \
        > ${RESULT}/temp && mv ${RESULT}/temp ${RESULT}/result/${TAG}_up_anno.xls
    awk -v fc=${FC_CUTOFF} -v fdr=${FDR_CUTOFF} \
        '{if(($12<=(-fc))&&($14<=fdr)&&($11=="Down")){print $0}}' \
        ${RESULT}/04_diff.${TAG}.${DIFFREPS_TEST}.txt.annotated \
        > ${RESULT}/result/${TAG}_down_anno.txt
    head -1 ${RESULT}/04_diff.${TAG}.${DIFFREPS_TEST}.txt.annotated \
        | cat - ${RESULT}/result/${TAG}_down_anno.txt \
        > ${RESULT}/temp && mv ${RESULT}/temp ${RESULT}/result/${TAG}_down_anno.xls
    awk 'BEGIN{OFS="\t"};{print $1, $2, $3}' ${RESULT}/result/${TAG}_up_anno.txt \
        > ${RESULT}/result/${TAG}_up_anno.bed
    awk 'BEGIN{OFS="\t"};{print $1, $2, $3}' ${RESULT}/result/${TAG}_down_anno.txt \
        > ${RESULT}/result/${TAG}_down_anno.bed
    Anno_piechart.R ${RESULT}/result ${TAG}_up_anno.txt 25 FALSE
    Anno_piechart.R ${RESULT}/result ${TAG}_down_anno.txt 25 FALSE
    ChIPpeakAnno_BED.R ${RESULT}/result ${TAG}_up_anno.bed ${GENOME_DIFFREPS}
    ChIPpeakAnno_BED.R ${RESULT}/result ${TAG}_down_anno.bed ${GENOME_DIFFREPS}

    # Use HOMER to do GO analysis
    mkdir -p ${RESULT}/result/${TAG}_up_HOMER
    annotatePeaks.pl ${RESULT}/result/${TAG}_up_anno.bed \
        ${GENOME} -go ${RESULT}/result/${TAG}_up_HOMER \
        -genomeOntology ${RESULT}/result/${TAG}_up_HOMER \
        > ${RESULT}/result/${TAG}_up_HOMER/annotatePeaks.txt
    GO_homer_ggplot2.R ${RESULT}/result/${TAG}_up_HOMER/ ${GO_HOMER_P_VAL_CUTOFF}
    mkdir -p ${RESULT}/result/${TAG}_down_HOMER
    annotatePeaks.pl ${RESULT}/result/${TAG}_down_anno.bed \
        ${GENOME} -go ${RESULT}/result/${TAG}_down_HOMER \
        -genomeOntology ${RESULT}/result/${TAG}_down_HOMER \
        > ${RESULT}/result/${TAG}_down_HOMER/annotatePeaks.txt
    GO_homer_ggplot2.R ${RESULT}/result/${TAG}_down_HOMER/ ${GO_HOMER_P_VAL_CUTOFF}
}
export -f doDiffReps

# mkdir for the significant results
mkdir -p ${RESULT}/result

T=`ls ${RESULT}/03_TREATED*.bed`
C=`ls ${RESULT}/03_CONTROL*.bed`
TI=`ls ${RESULT}/03_Input_CONTROL*.bed`
CI=`ls ${RESULT}/03_Input_TREATED*.bed`

# treated vs. control
# name tag for the comparison
TAG="TvsC"

doDiffReps T[@] C[@] TI[@] CI[@] ${CORES} ${GENOME_DIFFREPS} ${RESULT} \
    ${TAG} ${DIFFREPS_TEST} ${P_VAL} ${NSD} ${FC_CUTOFF} ${FDR_CUTOFF} \
    ${GENOME} ${GO_HOMER_P_VAL_CUTOFF}
