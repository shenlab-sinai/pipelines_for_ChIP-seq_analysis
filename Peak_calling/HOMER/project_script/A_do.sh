#! /usr/bin/env bash

# project path
export PRO="${HOME}/projects/current_date.PROJECT_TITLE"
# results path
export RESULT="${PRO}/result/HOMER/date_PROJECT_HOMER_PEAK_CALLING"
mkdir -p ${RESULT}
# input bam path
export DATA="${PRO}/data"

# cores to be used in the processing
export CORES=8

# genome info
export GENOME="mm9"

# peak calling mode
export STYLE="factor"
# export STYLE="histone"

export SCRIPT_DIR=`pwd`

# parameters for HOMER GO analysis
GO_HOMER_P_VAL_CUTOFF=0.05

# pipeline main body
function DoHOMER(){
    RESULT=$1
    RES_NAME=$2
    STYLE=$3
    GENOME=$4
    CORES=$5
    GO_HOMER_P_VAL_CUTOFF=$6

    # peak calling
    findPeaks ${RESULT}/01_${RES_NAME}/ -style ${STYLE} -o auto -i ${RESULT}/01_INPUT/

    # annotate and GO analysis
    mkdir -p ${RESULT}/02_${RES_NAME}

    case "$style" in
        factor) annotatePeaks.pl ${RESULT}/01_${RES_NAME}/peaks.txt ${GENOME} \
                -go ${RESULT}/02_${RES_NAME} -genomeOntology ${RESULT}/02_${RES_NAME} \
                > ${RESULT}/02_${RES_NAME}/annotatePeaks.txt
            findMotifsGenome.pl ${RESULT}/01_${RES_NAME}/peaks.txt \
                ${GENOME} ${RESULT}/02_${RES_NAME}/ -p ${CORES}
            ;;
        histone) annotatePeaks.pl ${RESULT}/01_${RES_NAME}/regions.txt ${GENOME} \
                -go ${RESULT}/02_${RES_NAME} -genomeOntology ${RESULT}/02_${RES_NAME} \
                > ${RESULT}/02_${RES_NAME}/annotatePeaks.txt
            findMotifsGenome.pl ${RESULT}/01_${RES_NAME}/regions.txt \
                ${GENOME} ${RESULT}/02_${RES_NAME}/ -p ${CORES}
            ;;
        *) echo "STYLE should be histone or factor!"
            ;;
    esac
    GO_homer_ggplot2.R ${RESULT}/02_${RES_NAME}/ ${GO_HOMER_P_VAL_CUTOFF}
}
export -f DoHOMER

# set the name tag for the results
RES_NAME="RESULT_OF_HOMER"

# set the patterns of bam files
INPUT="${DATA}/*input.bam"
makeTagDirectory ${RESULT}/01_INPUT -genome ${GENOME} -checkGC ${INPUT[@]}
T="${DATA}/*_treatment.bam"
makeTagDirectory ${RESULT}/01_${RES_NAME} -genome ${GENOME} -checkGC ${T[@]}

DoHOMER ${RESULT} ${RES_NAME} ${STYLE} ${GENOME} ${CORES} ${GO_HOMER_P_VAL_CUTOFF}
