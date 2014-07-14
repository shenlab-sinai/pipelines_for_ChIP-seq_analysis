#! usr/bin/env bash

# project path
export PRO="${HOME}/projects/current_date.PROJECT_TITLE"
# results path
export RESULT="${PRO}/result/puasing_index/date_PROJECT_PAUSING_INDEX"
mkdir -p ${RESULT}
# input bam path
export DATA="${PRO}/data/rmdup"
## the bams should be named following the patterns as $BAMS shown below:
## treated: treated_*PolII.bam
## DNA input of treated: treated_input.bam
## control: control_*PolII.bam
## DNA input of treated: control_input.bam


export CORES=8

## generate the gene annotations for coverageBed
# ./getBEDAnno.R

# calculate the reads in TSS and genebody
BAMS=`ls ${DATA}/*.bam`
BAMS=${BAMS//${DATA}\//}
BAMS=${BAMS//.bam/}

echo -e "${BAMS[@]}" | xargs -P ${CORES} -n 1 -I {} \
	bash -c 'coverageBed -abam "${DATA}/{}.bam" -b mm9.ensembl.coding.tss_200bp.bed > "${RESULT}/{}_tss.txt"'

echo -e "${BAMS[@]}" | xargs -P ${CORES} -n 1 -I {} \
	bash -c 'coverageBed -abam "${DATA}/{}.bam" -b mm9.ensembl.coding.gb_400bp.bed > "${RESULT}/{}_GB.txt"'

# Caculate the PI of treated group
BAMS=`ls ${DATA}/treated_*PolII.bam`
BAMS=${BAMS//${DATA}\//}
BAMS=${BAMS//.bam/}

echo -e "${BAMS[@]}" | xargs -P ${CORES} -n 1 -I {} \
	bash -c './calPausingIndex.R "${DATA}" "${RESULT}" "{}" tretated_input'

BAMS=`ls ${DATA}/control_*PolII.bam`
BAMS=${BAMS//${DATA}\//}
BAMS=${BAMS//.bam/}

echo -e "${BAMS[@]}" | xargs -P ${CORES} -n 1 -I {} \
	bash -c './calPausingIndex.R "${DATA}" "${RESULT}" "{}" control_input'

TREAT="treated"
CONTROL="control"
./diffPI.R ${RESULT} ${TREAT} ${CONTROL} 