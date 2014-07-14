#! /usr/bin/env bash

# project path
export PRO="${HOME}/projects/current_date.PROJECT_TITLE"
# results path
export RESULT="${PRO}/result/MACS2/date_PROJECT_MACS2_PEAK_CALLING"
mkdir -p ${RESULT}
# input bam path
export DATA="${PRO}/data"

export SCRIPT_DIR=`pwd`

# genome info
export GENOME="mm9"
export GENOME_MACS="mm"

# parameters for HOMER GO analysis
GO_HOMER_P_VAL_CUTOFF=0.05

# main body of the pipeline
function DoMacs2(){
    declare -a INPUT=("${!1}")
    declare -a T=("${!2}")
    GENOME_MACS=${3}
    RES_NAME=${4}
    GENOME=${5}
    RESULT=${6}
    SCRIPT_DIR=${7}

    cd ${RESULT}
    macs2 callpeak -t ${T[@]} -c ${INPUT[@]} -f BAM -g ${GENOME_MACS} -n ${RES_NAME}
    # if the model building is failed, then use --nomodel to turn off the estimation of shiftsize
    # macs2 callpeak -t ${T[@]} -c ${INPUT[@]} -f BAM -g ${GENOME_MACS} \
    #     -n ${RES_NAME} --nomodel --shiftsize 150

    # use HOMER to annotate the peak list and run GO analysis
    mkdir -p ${RES_NAME}_HOMER
    annotatePeaks.pl ${RES_NAME}_peaks.narrowPeak ${GENOME} \
        -go ${RES_NAME}_HOMER -genomeOntology ${RES_NAME}_HOMER \
        > ${RES_NAME}_HOMER/annotatePeaks.txt
    GO_homer_ggplot2.R ${RES_NAME}_HOMER ${GO_HOMER_P_VAL_CUTOFF}

    # use region_analysis package to annotate the peak list
    region_analysis.py -i ${RES_NAME}_peaks.narrowPeak -g ${GENOME}

    # use ChIPpeakAnno package to annotate the peak list and run GO analysis
    cd ${SCRIPT_DIR}
    B_chipanno.R ${RESULT} ${RES_NAME}_peaks.narrowPeak ${GENOME}
}
export -f DoMacs2

# set the patterns of bam files
INPUT="${DATA}/*input.bam"
T="${DATA}/*_treatment.bam"

# set the name tag for the results
RES_NAME="RESULT_OF_MACS2"

DoMacs2 INPUT[@] T[@] ${GENOME_MACS} ${RES_NAME} ${GENOME} ${RESULT} ${SCRIPT_DIR} \
    ${GO_HOMER_P_VAL_CUTOFF}
